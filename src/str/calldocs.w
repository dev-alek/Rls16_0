/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список удаленных документов (история документов)

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

define  input parameter parparentproc   as   widget-handle           no-undo.
define  input parameter parlist-mode    as   character               no-undo.
define  input parameter parstat         as   character               no-undo.
define  input parameter partype         as   character               no-undo.
define  input parameter parflag         as   logical                 no-undo.
define  input parameter parinternal     as   logical                 no-undo.
define  input parameter bttns           as   character               no-undo.
define  input parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define  input parameter paris-hold      as   logical                 no-undo.
define  input parameter doc-rec         as   recid                   no-undo.
define  input parameter p-obj-type      like ub.trn-doc.obj-type     no-undo.
define  input parameter p-obj-code      like ub.trn-doc.obj-code     no-undo.
define output parameter mark-list       as   character               no-undo.
/*
message
'parlist-mode     '  parlist-mode         skip
'parstat          '  parstat              skip
'partype          '  partype              skip
'parflag          '  parflag              skip
'parinternal      '  parinternal          skip
'bttns            '  bttns                skip
'parext-doc-type  '  parext-doc-type      skip
'paris-hold       '  paris-hold           skip
'doc-rec          '  doc-rec              skip
'p-obj-type       '  p-obj-type           skip
'p-obj-code       '  p-obj-code           skip
.
*/
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Список удаленных документов":U .

{ cmp/vssrevis.i "substitute('&1|&2',bttns,parext-doc-type)" }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/showinf.i }
{ str/get-pr.i   def }
{ gbl/fltfield.i     }
{ str/tt-tax.i   new }
{ str/lib-trn.i      }
{ gbl/flt-def.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ gbl/waitfram.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }

define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable filter-point as character no-undo init "Список удаленных документов" .
define variable filter-point0 as character no-undo init "calldocs" .
define variable title0 as character no-undo init "Удаленные документы " .
define variable title1 as character no-undo init "История документа " .
define variable sort-column-name as character no-undo .
define variable is-finvalue as character no-undo.
define variable is-fintype  as character no-undo.

define temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
index pi is unique primary
f_name.

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY BR-changes FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


&scop if-not-true ~
if varlog <> yes then do: ~
  find c-t-doc no-lock where recid( c-t-doc ) = doc-rec. ~
  return no-apply. ~
end.

&scop window-name d-calldocs
&glob frame-name  d-calldocs
&scop browse-name br-docs

define new shared variable br-handle as handle no-undo.

define new shared buffer c-t-doc  for ub.c-trn-doc.

/* для жесткого фильтра по оплате */
define new shared buffer sch-pay  for ub.pay-type.

/* для жесткого фильтра по валюте */
define new shared buffer sch-curr for ub.currency.

/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
define new shared buffer sch-cli  for ub.clients.

define variable varempty-string as   character               no-undo.

assign
varempty-string = ''
.

define buffer cli-buf for ub.clients.   /* для вывода м-ра, исп-ля, кл-ка */
define buffer c-t-d-b for ub.c-trn-doc. /* для поиска по номеру, дате, факт */

define variable sch-field   as character no-undo.
define variable v_shift     as character no-undo initial ?. /* учет по сменам на объекте */
define variable v_data-type as character no-undo initial ?.

define variable varhold         as character no-undo.
define variable varhold-type    as character no-undo.
define variable objects         as integer   no-undo.
define variable mark            as character no-undo.
define variable varlog          as logical   no-undo.
define variable g#report-num    as integer   no-undo.
define variable v-button-order   as character no-undo .

run get-report-num in parparentproc ( output g#report-num ).

define buffer bf_clients for ub.clients.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.
{ gbl/conf-rd.i "'is-fin'"  "''" "''" 0 "''" "''" "''" no is-finvalue is-fintype no-error }
/* для ВЗАИМОРАСЧЕТОВ -------------------------------------------------------------------------------------------------- */
if is-finvalue = "yes" then do:

  DEFINE MENU POPUP-MENU-b-gen
    MENU-ITEM m_gen-1  LABEL "Финансовые обязательства"                                     ACCELERATOR "ALT-1"
    MENU-ITEM m_gen-2  LABEL "Отказаться от генерации финобязательств по поставке"          ACCELERATOR "ALT-2"
    MENU-ITEM m_gen-3  LABEL "Отказаться от генерации финобязательств по реализации"        ACCELERATOR "ALT-3"
    MENU-ITEM m_gen-4  LABEL "Снять признак - есть генерация финобязательств по поставке"   ACCELERATOR "ALT-4"
    MENU-ITEM m_gen-5  LABEL "Снять признак - есть генерация финобязательств по реализации" ACCELERATOR "ALT-5"
  .
  define buffer buf_name_clients for clients.


  find first buf_name_clients no-lock where
             buf_name_clients.obj-code = v-cntxt-host-code-obj and
             buf_name_clients.obj-type = {&cmp}
       .

  if available buf_name_clients then do:
    assign v-host-name = buf_name_clients.obj-name.
     assign
      v-host-code = v-cntxt-host-code-obj
      p-obj-type  = v-cntxt-obj-type
      p-obj-code  = v-cntxt-obj-code
    .
  end.

  run make-gen-button in this-procedure.
  run make-fo-button  in this-procedure.
  v-button-order = "b-quit,b-mark," + (if lookup("b-sel", bttns) > 0 then "b-sel," else '') + "but-fo,but-gen,b-lkp,b-lines,b-sums,b-sch,b-help".
  on choose of menu-item m_gen-1 in menu popup-menu-b-gen do: run proc-m_gen-1 in this-procedure. end.
  on choose of menu-item m_gen-2 in menu popup-menu-b-gen do: run proc-m_gen-2 in this-procedure. end.
  on choose of menu-item m_gen-3 in menu popup-menu-b-gen do: run proc-m_gen-3 in this-procedure. end.
  on choose of menu-item m_gen-4 in menu popup-menu-b-gen do: run proc-m_gen-4 in this-procedure. end.
  on choose of menu-item m_gen-5 in menu popup-menu-b-gen do: run proc-m_gen-5 in this-procedure. end.

end. /* --------------------------------------------------------------------------------------------------------------- */
else do:
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    find first buf_name_clients no-lock where buf_name_clients.obj-code = v-host-code
         and buf_name_clients.obj-type = {&cmp}
         .
    if available buf_name_clients then do:
      assign v-host-name = buf_name_clients.obj-name.
    end.
end.


/* ----------------------------  верхний ряд батонов  -------------------------------- */

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     size 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     size 10 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     size 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     size 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     size 3 BY 1.



DEFINE BUTTON b-lines
     LABEL "&Строки"
     size 10 BY 1.

define variable agnt-name as character format "x(256)":u
      view-as text
     size 14.5 by 1 no-undo.

define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14.5 by 1 no-undo.

define variable boss-name as character format "x(256)":u
      view-as text
     size 14.5 by 1 no-undo.

define variable obj-name as character format "x(256)":u
      view-as text
     size 34 by 1 no-undo.

define variable ed-notes as character
     view-as editor
     size 98 by 2 no-undo.

define variable varpost   as character no-undo.
define variable varrealiz as character no-undo.
define variable varchold  as logical   no-undo.

define variable sch-code like ub.trn-doc.doc-code                       no-undo.
define variable sch-date as   date    view-as fill-in size 9.00 by 1.00 no-undo.
define variable sch-fact as   date    view-as fill-in size 9.00 by 1.00 no-undo.
define variable sch-num  as   integer view-as fill-in size 3.00 by 1.00 no-undo.

define new shared query br-docs    for c-t-doc      scrolling.
define            query br-changes for temp-changes scrolling.


function mark-string returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( if lookup( string( recid( loc-c-t-doc ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function first-symb-type returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( substring( loc-c-t-doc.doc-type, 1, 1 ) ).
end function.

function day-month returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( substring( ( string( loc-c-t-doc.doc-date ) ), 1, 5 ) ).
end function.

function shift-day-month returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( substring( ( string( loc-c-t-doc.shift-date ) ), 1, 5 ) ).
end function.

function shift-name return char  ( p-rec as recid ) :
def buffer c-loc-t-doc for ub.c-trn-doc .
find first c-loc-t-doc no-lock where recid(c-loc-t-doc) = p-rec no-error . if error-status :error then return "" .
  if c-loc-t-doc.shift-date = ? then do:
    return "":u.
  end.
  else do:
    if c-loc-t-doc.shift-num = integer(c-loc-t-doc.shift-name) then do:
      return c-loc-t-doc.shift-name.
    end.
    else do:
      return c-loc-t-doc.shift-name + "(" + string(c-loc-t-doc.shift-num) + ")".
    end.
  end.
end function.

function object-label returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  return ( trim( loc-c-t-doc.obj-type ) + " ":U + string( loc-c-t-doc.obj-code, ">>>>9":U ) ).
end function.

function total-sum returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.tot-rubl else loc-c-t-doc.tot-doc ).
end function.

function total-dsc returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  if lookup( loc-c-t-doc.doc-type, {&expense_write-off_return} ) > 0 then do:
    return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.discnt-rubl /* для статуса факт это неправильно */
                                       else loc-c-t-doc.tot-doc - loc-c-t-doc.tot-cli ).
  end.
  else do:
    return ( 0.00 ).
  end.
end function.

function total-fact returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.tot-sale else loc-c-t-doc.tot-fact ).
end function.

function total-dsc-fact returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ?.
  if lookup( loc-c-t-doc.doc-type, {&expense_write-off_return} ) > 0 then do:
    return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.discnt-rubl else loc-c-t-doc.tot-calc ).
  end.
  else do:
    return ( 0.00 ).
  end.
end function.

function total-pay-fact returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  if loc-c-t-doc.doc-type = {&income} and
     loc-c-t-doc.internal = no        then do:
    return ( loc-c-t-doc.tot-calc ).
  end.
  else do:
    return ( if loc-c-t-doc.print-rubl then ( loc-c-t-doc.tot-sale - loc-c-t-doc.discnt-rubl )
                                       else ( loc-c-t-doc.tot-fact - loc-c-t-doc.tot-calc    ) ).
  end.
end function.

function total-vat returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.vat-rubl else loc-c-t-doc.vat-base ).
end function.

function total-slt returns decimal ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return ? .
  return ( if loc-c-t-doc.print-rubl then loc-c-t-doc.slt-rubl else loc-c-t-doc.slt-base ).
end function.

function fo-postavka returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  if loc-c-t-doc.cr-incfo = yes then do:
    return string( loc-c-t-doc.incfo-date, "99/99/99":U ).
  end.
  else do:
    if loc-c-t-doc.need-incfo = 0 then do:
      return "--------".
    end.
    if loc-c-t-doc.need-incfo = 1 then do:
      return "".
    end.
    if loc-c-t-doc.need-incfo = 2 then do:
      return "не опред".
    end.
  end.
end function.

function fo-realiz returns character ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return "" .
  if loc-c-t-doc.cr-expfo = yes then do:
    return string( loc-c-t-doc.expfo-date, "99/99/99":U ).
  end.
  else do:
    if loc-c-t-doc.need-expfo = 0 then do:
      return "--------".
    end.
    if loc-c-t-doc.need-expfo = 1 then do:
      return "".
    end.
    if loc-c-t-doc.need-expfo = 2 then do:
      return "не опред".
    end.
  end.
end function.

function c-holding returns logical ( p-rec as recid ) :
def buffer loc-c-t-doc for ub.c-trn-doc .
find first loc-c-t-doc no-lock where recid(loc-c-t-doc) = p-rec no-error . if error-status :error then return false  .
  define variable l_holding as logical no-undo.

  run get-c-holding in this-procedure ( input loc-c-t-doc.doc-code, output l_holding ) no-error.
  return ( if error-status :error or l_holding <> yes then no else yes ).
end function. /* c-holding */

&scop label-clmn_1-br-dtl  '*'
&scop sort-clmn_1-br-dtl   mark-string( recid (c-t-doc) )
&scop label-clmn_2-br-dtl  'Т'
&scop sort-clmn_2-br-dtl   first-symb-type( recid (c-t-doc) )
&scop label-clmn_3-br-dtl  'Стат'
&scop sort-clmn_3-br-dtl   c-t-doc.status_
&scop label-clmn_4-br-dtl  'OK'
&scop sort-clmn_4-br-dtl   c-t-doc.flag_
&scop label-clmn_5-br-dtl  'Номер'
&scop sort-clmn_5-br-dtl   c-t-doc.doc-code
&scop label-clmn_6-br-dtl  'Дата'
&scop sort-clmn_6-br-dtl   day-month( recid (c-t-doc) )
&scop label-clmn_7-br-dtl  'Факт'
&scop sort-clmn_7-br-dtl   c-t-doc.fact-date
&scop label-clmn_8-br-dtl  'Удал(корр)'
&scop sort-clmn_8-br-dtl   c-t-doc.corr-date
&scop label-clmn_9-br-dtl  'Смена'
&scop sort-clmn_9-br-dtl   shift-day-month( recid (c-t-doc) )
&scop label-clmn_10-br-dtl '№'
&scop sort-clmn_10-br-dtl  shift-name (recid (c-t-doc))
&scop label-clmn_11-br-dtl 'В'
&scop sort-clmn_11-br-dtl  c-t-doc.internal
&scop label-clmn_12-br-dtl 'Контрагент'
&scop sort-clmn_12-br-dtl  c-t-doc.cli-name
&scop label-clmn_13-br-dtl 'Объект'
&scop sort-clmn_13-br-dtl  object-label( recid (c-t-doc) )
&scop label-clmn_14-br-dtl 'У'
&scop sort-clmn_14-br-dtl  c-t-doc.office
&scop label-clmn_15-br-dtl 'Кол-во по док.'
&scop sort-clmn_15-br-dtl  c-t-doc.doc-qnty
&scop label-clmn_16-br-dtl 'Кол-во факт'
&scop sort-clmn_16-br-dtl  c-t-doc.fact-qnty
&scop label-clmn_17-br-dtl '$'
&scop sort-clmn_17-br-dtl  c-t-doc.print-rubl
&scop label-clmn_18-br-dtl 'Сумма по док'
&scop sort-clmn_18-br-dtl  total-sum( recid (c-t-doc) )
&scop label-clmn_19-br-dtl 'Скидка по док'
&scop sort-clmn_19-br-dtl  total-dsc( recid (c-t-doc) )
&scop label-clmn_20-br-dtl 'Сумма факт'
&scop sort-clmn_20-br-dtl  total-fact( recid (c-t-doc) )
&scop label-clmn_21-br-dtl 'Скидка факт'
&scop sort-clmn_21-br-dtl  total-dsc-fact( recid (c-t-doc) )
&scop label-clmn_22-br-dtl 'К оплате факт'
&scop sort-clmn_22-br-dtl  total-pay-fact( recid (c-t-doc) )
&scop label-clmn_23-br-dtl 'НДС'
&scop sort-clmn_23-br-dtl  total-vat( recid (c-t-doc) )
&scop label-clmn_24-br-dtl 'Налог прод.'
&scop sort-clmn_24-br-dtl  total-slt( recid (c-t-doc) )
&scop label-clmn_25-br-dtl 'Скидка (%)'
&scop sort-clmn_25-br-dtl  c-t-doc.discnt-pc
&scop label-clmn_26-br-dtl 'Тип скидки'
&scop sort-clmn_26-br-dtl  c-t-doc.discnt-type
&scop label-clmn_27-br-dtl 'Курс'
&scop sort-clmn_27-br-dtl  c-t-doc.base-rate
&scop label-clmn_28-br-dtl 'А'
&scop sort-clmn_28-br-dtl  c-t-doc.ov
&scop label-clmn_29-br-dtl 'Авт. переоц. (баз.вал.)'
&scop sort-clmn_29-br-dtl  c-t-doc.tot-ov
&scop label-clmn_30-br-dtl 'Инвойс'
&scop sort-clmn_30-br-dtl  c-t-doc.inv-num
&scop label-clmn_31-br-dtl 'Заказ'
&scop sort-clmn_31-br-dtl  c-t-doc.ord-num
&scop label-clmn_32-br-dtl 'Отгрузка'
&scop sort-clmn_32-br-dtl  c-t-doc.ship-num
&scop label-clmn_33-br-dtl 'Дата'
&scop sort-clmn_33-br-dtl  c-t-doc.ship-date
&scop label-clmn_34-br-dtl 'На док-т'
&scop sort-clmn_34-br-dtl  c-t-doc.out-code
&scop label-clmn_35-br-dtl 'Задним числом'
&scop sort-clmn_35-br-dtl  c-t-doc.is-back-date
&scop label-clmn_36-br-dtl 'Выгрузка'
&scop sort-clmn_36-br-dtl  c-t-doc.bge-date
&scop label-clmn_37-br-dtl 'Резерв'
&scop sort-clmn_37-br-dtl  c-t-doc.rsrv-date
&scop label-clmn_38-br-dtl 'ФО.поставка'
&scop sort-clmn_38-br-dtl  fo-postavka( recid (c-t-doc) )
&scop label-clmn_39-br-dtl 'ФО.реализация'
&scop sort-clmn_39-br-dtl  fo-realiz( recid (c-t-doc) )
&scop label-clmn_40-br-dtl 'Меж.фирм'
&scop sort-clmn_40-br-dtl  c-holding( recid (c-t-doc) )
&scop label-clmn_41-br-dtl  'Кто'
&scop sort-clmn_41-br-dtl   c-t-doc.corr-user-name
&scop label-clmn_42-br-dtl  '№ изменения'
&scop sort-clmn_42-br-dtl   c-t-doc.chip-num
&scop label-clmn_43-br-dtl  'Код причины'
&scop sort-clmn_43-br-dtl   c-t-doc.reason-code
&scop label-clmn_44-br-dtl  'Действие'
&scop sort-clmn_44-br-dtl   c-t-doc.action
&scop label-clmn_45-br-dtl  'Время'
&scop sort-clmn_45-br-dtl    string(c-t-doc.corr-time, "HH:MM")

&scop enabled-clmn-br-dtl  {&sort-clmn_32-br-dtl}

define browse br-docs query br-docs no-lock display
  {&sort-clmn_1-br-dtl}              column-label {&label-clmn_1-br-dtl}  format "x(1)"
  {&sort-clmn_2-br-dtl}              column-label {&label-clmn_2-br-dtl}  format "x(1)"
  {&sort-clmn_3-br-dtl}              column-label {&label-clmn_3-br-dtl}  format "x(4)"
  {&sort-clmn_4-br-dtl}              column-label {&label-clmn_4-br-dtl}  format "+/-"
  {&sort-clmn_5-br-dtl}              column-label {&label-clmn_5-br-dtl}
  {&sort-clmn_6-br-dtl}              column-label {&label-clmn_6-br-dtl}  format "x(5)"
  {&sort-clmn_7-br-dtl}              column-label {&label-clmn_7-br-dtl}
  {&sort-clmn_8-br-dtl}              column-label {&label-clmn_8-br-dtl}
  {&sort-clmn_45-br-dtl}             column-label {&label-clmn_45-br-dtl}
  {&sort-clmn_33-br-dtl}             column-label {&label-clmn_33-br-dtl}
  {&sort-clmn_41-br-dtl}             column-label {&label-clmn_41-br-dtl}
  usrfulnf(c-t-doc.user-name)        column-label "Исправил"
  {&sort-clmn_44-br-dtl}             column-label {&label-clmn_44-br-dtl}
  {&sort-clmn_42-br-dtl}             column-label {&label-clmn_42-br-dtl} format ">>>,>>>,>>9"
  {&sort-clmn_43-br-dtl}             column-label {&label-clmn_43-br-dtl}
  {&sort-clmn_9-br-dtl}              column-label {&label-clmn_9-br-dtl}  format "x(6)"
  {&sort-clmn_10-br-dtl}             column-label {&label-clmn_10-br-dtl} format "99"
  {&sort-clmn_11-br-dtl}             column-label {&label-clmn_11-br-dtl} format "+/-"
  {&sort-clmn_12-br-dtl}             column-label {&label-clmn_12-br-dtl} format "x(26)"
  {&sort-clmn_13-br-dtl}             column-label {&label-clmn_13-br-dtl} format "x(9)"
  {&sort-clmn_14-br-dtl}             column-label {&label-clmn_14-br-dtl} format "+/-"
  {&sort-clmn_15-br-dtl}             column-label {&label-clmn_15-br-dtl}
  {&sort-clmn_16-br-dtl}             column-label {&label-clmn_16-br-dtl}
  {&sort-clmn_17-br-dtl}             column-label {&label-clmn_17-br-dtl} format "-/$"
  {&sort-clmn_18-br-dtl}             column-label {&label-clmn_18-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_19-br-dtl}             column-label {&label-clmn_19-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_20-br-dtl}             column-label {&label-clmn_20-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_21-br-dtl}             column-label {&label-clmn_21-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_22-br-dtl}             column-label {&label-clmn_22-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_23-br-dtl}             column-label {&label-clmn_23-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_24-br-dtl}             column-label {&label-clmn_24-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
  {&sort-clmn_25-br-dtl}             column-label {&label-clmn_25-br-dtl} format "->,>>9.99"
  {&sort-clmn_26-br-dtl}             column-label {&label-clmn_26-br-dtl}
  {&sort-clmn_27-br-dtl}             column-label {&label-clmn_27-br-dtl}
  {&sort-clmn_28-br-dtl}             column-label {&label-clmn_28-br-dtl}
  {&sort-clmn_29-br-dtl}             column-label {&label-clmn_29-br-dtl}
  {&sort-clmn_30-br-dtl}             column-label {&label-clmn_30-br-dtl}
  {&sort-clmn_31-br-dtl}             column-label {&label-clmn_31-br-dtl}
  {&sort-clmn_32-br-dtl}             column-label {&label-clmn_32-br-dtl}
  {&sort-clmn_34-br-dtl}             column-label {&label-clmn_34-br-dtl}
  {&sort-clmn_35-br-dtl}             column-label {&label-clmn_35-br-dtl}
  {&sort-clmn_36-br-dtl}             column-label {&label-clmn_36-br-dtl}
  {&sort-clmn_37-br-dtl}             column-label {&label-clmn_37-br-dtl}
  {&sort-clmn_38-br-dtl} @ varpost   column-label {&label-clmn_38-br-dtl} format "x(8)"
  {&sort-clmn_39-br-dtl} @ varrealiz column-label {&label-clmn_39-br-dtl} format "x(8)"
  {&sort-clmn_40-br-dtl} @ varchold  column-label {&label-clmn_40-br-dtl} format "Межфирм/ ":U
  usrfulnf(c-t-doc.creid)            column-label "Создал"
  

enable 
  {&enabled-clmn-br-dtl}
with size 98 by 14.5 separators.

DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(25)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.

/* ************************  Frame Definitions  *********************** */
define frame {&frame-name}
  /* 1-й ряд батонов */
  b-quit            at row  1.00 col  1.00
  b-mark            at row  1.00 col 10.00
  b-sel             at row  1.00 col 13.00
  b-lkp             at row  1.00 col 23.00
  b-lines           at row  1.00 col 53.00

  b-sch             at row  1.00 col 92.00
  b-help            at row  1.00 col 95.00
  br-docs           at row  2.30 col  1.00

  sch-code          at row 20.00 col  2.00                  label "&Начало номера"
  sch-date          at row 20.00 col 32.00                  label "Д&ата"
  sch-fact          at row 20.00 col 52.00                  label "Фа&кт"
  sch-num           at row 20.00 col 70.00                  label "Найдено"                             fgcolor 12
  pay-type.obj-name at row 18.00 col  5.00 colon-aligned    label "Опл"    view-as fill-in size 34 by 1 fgcolor  4
  obj-name          at row 18.00 col 55.00 colon-aligned    label "Объект" view-as fill-in size 34 by 1 fgcolor  4
  boss-name         at row 19.00 col  5.00 colon-aligned    label "М-р"    view-as fill-in size 14 by 1 fgcolor  4
  agnt-name         at row 19.00 col 30.00 colon-aligned    label "Исп"    view-as fill-in size 14 by 1 fgcolor  4
  wrkr-name         at row 19.00 col 55.00 colon-aligned    label "Кл-к"   view-as fill-in size 14 by 1 fgcolor  4
  c-t-doc.creid     at row 19.00 col 80.00 colon-aligned    label "Опер"   view-as fill-in size 14 by 1 fgcolor  4
  ed-notes          at row 21.00 col  1.00               no-label                             bgcolor 8 fgcolor  4
  br-changes        at row 17    col 1
  space( 0 ) skip( 0.5 )
with view-as dialog-box keep-tab-order
         side-labels no-underline three-d scrollable
         default-button b-quit.

{ gbl/ed_date.i sch-date }
{ gbl/ed_date.i sch-fact }

/* Файл живет на старых фильтрах поэтому сортировку по колонкам сделать не удалось.
   Есть только начальное размещение колонок */
{ gbl/srt-clmn.i
    &browse-name   = {&browse-name}
    &frame-name    = {&frame-name}
    &table-name    = "c-t-doc"
    &ext-col       = 44
    &start-column  = 5
    &label-clmn_1  = "{&label-clmn_1-br-dtl}"
    &sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
    &label-clmn_2  = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
    &label-clmn_3  = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
    &label-clmn_4  = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
    &label-clmn_5  = "{&label-clmn_5-br-dtl}"
    &sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
    &label-clmn_6  = "{&label-clmn_6-br-dtl}"
    &sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
    &label-clmn_7  = "{&label-clmn_7-br-dtl}"
    &sort-clmn_7   = "{&sort-clmn_7-br-dtl}"
    &label-clmn_8  = "{&label-clmn_8-br-dtl}"
    &sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
    &label-clmn_33 = "{&label-clmn_33-br-dtl}"
    &sort-clmn_33  = "{&sort-clmn_33-br-dtl}"
    &label-clmn_41 = "{&label-clmn_41-br-dtl}"
    &sort-clmn_41  = "{&sort-clmn_41-br-dtl}"
    &label-clmn_44 = "{&label-clmn_44-br-dtl}"
    &sort-clmn_44  = "{&sort-clmn_44-br-dtl}"
    &label-clmn_42 = "{&label-clmn_42-br-dtl}"
    &sort-clmn_42  = "{&sort-clmn_42-br-dtl}"
    &label-clmn_43 = "{&label-clmn_43-br-dtl}"
    &sort-clmn_43  = "{&sort-clmn_43-br-dtl}"
    &label-clmn_9  = "{&label-clmn_9-br-dtl}"
    &sort-clmn_9   = "{&sort-clmn_9-br-dtl}"
    &label-clmn_10 = "{&label-clmn_10-br-dtl}"
    &sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
    &label-clmn_11 = "{&label-clmn_11-br-dtl}"
    &sort-clmn_11  = "{&sort-clmn_11-br-dtl}"
    &label-clmn_12 = "{&label-clmn_12-br-dtl}"
    &sort-clmn_12  = "{&sort-clmn_12-br-dtl}"
    &label-clmn_13 = "{&label-clmn_13-br-dtl}"
    &sort-clmn_13  = "{&sort-clmn_13-br-dtl}"
    &label-clmn_14 = "{&label-clmn_14-br-dtl}"
    &sort-clmn_14  = "{&sort-clmn_14-br-dtl}"
    &label-clmn_15 = "{&label-clmn_15-br-dtl}"
    &sort-clmn_15  = "{&sort-clmn_15-br-dtl}"
    &label-clmn_16 = "{&label-clmn_16-br-dtl}"
    &sort-clmn_16  = "{&sort-clmn_16-br-dtl}"
    &label-clmn_17 = "{&label-clmn_17-br-dtl}"
    &sort-clmn_17  = "{&sort-clmn_17-br-dtl}"
    &label-clmn_18 = "{&label-clmn_18-br-dtl}"
    &sort-clmn_18  = "{&sort-clmn_18-br-dtl}"
    &label-clmn_19 = "{&label-clmn_19-br-dtl}"
    &sort-clmn_19  = "{&sort-clmn_19-br-dtl}"
    &label-clmn_20 = "{&label-clmn_20-br-dtl}"
    &sort-clmn_20  = "{&sort-clmn_20-br-dtl}"
    &label-clmn_21 = "{&label-clmn_21-br-dtl}"
    &sort-clmn_21  = "{&sort-clmn_21-br-dtl}"
    &label-clmn_22 = "{&label-clmn_22-br-dtl}"
    &sort-clmn_22  = "{&sort-clmn_22-br-dtl}"
    &label-clmn_23 = "{&label-clmn_23-br-dtl}"
    &sort-clmn_23  = "{&sort-clmn_23-br-dtl}"
    &label-clmn_24 = "{&label-clmn_24-br-dtl}"
    &sort-clmn_24  = "{&sort-clmn_24-br-dtl}"
    &label-clmn_25 = "{&label-clmn_25-br-dtl}"
    &sort-clmn_25  = "{&sort-clmn_25-br-dtl}"
    &label-clmn_26 = "{&label-clmn_26-br-dtl}"
    &sort-clmn_26  = "{&sort-clmn_26-br-dtl}"
    &label-clmn_27 = "{&label-clmn_27-br-dtl}"
    &sort-clmn_27  = "{&sort-clmn_27-br-dtl}"
    &label-clmn_28 = "{&label-clmn_28-br-dtl}"
    &sort-clmn_28  = "{&sort-clmn_28-br-dtl}"
    &label-clmn_29 = "{&label-clmn_29-br-dtl}"
    &sort-clmn_29  = "{&sort-clmn_29-br-dtl}"
    &label-clmn_30 = "{&label-clmn_30-br-dtl}"
    &sort-clmn_30  = "{&sort-clmn_30-br-dtl}"
    &label-clmn_31 = "{&label-clmn_31-br-dtl}"
    &sort-clmn_31  = "{&sort-clmn_31-br-dtl}"
    &label-clmn_32 = "{&label-clmn_32-br-dtl}"
    &sort-clmn_32  = "{&sort-clmn_32-br-dtl}"
    &label-clmn_34 = "{&label-clmn_34-br-dtl}"
    &sort-clmn_34  = "{&sort-clmn_34-br-dtl}"
    &label-clmn_35 = "{&label-clmn_35-br-dtl}"
    &sort-clmn_35  = "{&sort-clmn_35-br-dtl}"
    &label-clmn_36 = "{&label-clmn_36-br-dtl}"
    &sort-clmn_36  = "{&sort-clmn_36-br-dtl}"
    &label-clmn_37 = "{&label-clmn_37-br-dtl}"
    &sort-clmn_37  = "{&sort-clmn_37-br-dtl}"
    &label-clmn_38 = "{&label-clmn_38-br-dtl}"
    &sort-clmn_38  = "{&sort-clmn_38-br-dtl}"
    &label-clmn_39 = "{&label-clmn_39-br-dtl}"
    &sort-clmn_39  = "{&sort-clmn_39-br-dtl}"
    &label-clmn_40 = "{&label-clmn_40-br-dtl}"
    &sort-clmn_40  = "{&sort-clmn_40-br-dtl}"
    &label-clmn_41 = "{&label-clmn_41-br-dtl}"
    &sort-clmn_41  = "{&sort-clmn_41-br-dtl}"
    
    


    &open-query           = "run OpenBr in this-procedure ( input yes, input no, input no  )."
    &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no  )."
    &re-move-clmn   = "no"
    &mv-brw-default = "yes"
}

/* Убиваем srt-clmn.i :))) */
on start-search, ctrl-o of {&browse-name} in frame {&frame-name} do:

end.

/* ***************  Runtime Attributes and UIB Settings  ************** */

assign
  frame {&frame-name} :scrollable       = false
  br-docs :num-locked-columns in frame {&frame-name} = 5
.

/* ************************  Control Triggers  ************************ */

/* для устранения подвисания при неправильных нажатиях */
on any-printable of br-docs in frame {&frame-name} do:
  apply "entry" to sch-code in frame {&frame-name}.
end.

on choose of b-sch in frame {&frame-name} do:
  run init-flt in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  do on stop undo, leave :
    run gbl/filter.w ( input parparentproc,
                   input filter-point,
                   input tbl,
                   input join-tbl,
                   input fld,
                   input lab,
                   input spr,
                   input dim ).
    run OpenBr in this-procedure ( input yes, input no, input no ).
  end.
end.


ON CHOOSE OF b-sel IN FRAME {&frame-name} /* {&choose} */
DO:
 run local-sel in this-procedure.
END.

on choose of b-mark in frame {&frame-name} do:
define variable glog as logical no-undo .
  RUN local-mark.
  glog = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.

ON CHOOSE OF b-lkp IN FRAME {&frame-name} /* Просмотр */
DO:
  if available c-t-doc then do:
    run str/c-doc.w ( input parparentproc, input c-t-doc.doc-code, input c-t-doc.chip-num ).
  end.
end.

on choose of b-quit in frame {&frame-name} /* Выход */
do:
  assign doc-rec = ?.
end.

on entry of ed-notes in frame {&frame-name}
do:
  if not available c-t-doc then do:
    message "Неправильный выбор документа." view-as alert-box.
    return no-apply.
  end.
  assign
    doc-rec = recid( c-t-doc ).
  if c-t-doc.status_     <> {&fact}      and
     c-t-doc.discnt-type <> {&cash-desk} and
     substring( c-t-doc.ps, 1, 1 ) = "@" then do:
    message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @." view-as alert-box.
  end.
end.

on leave of ed-notes in frame {&frame-name}
do:
  do transaction :
    find c-t-d-b exclusive-lock where recid( c-t-d-b ) = doc-rec no-error no-wait.
    if not available c-t-d-b then do:
      message "Запись захвачена другим пользователем." skip
              "Редактирование запрещено."
      view-as alert-box.
    end.
    else do:
      assign c-t-d-b.ps = input frame {&frame-name} ed-notes.
    end.
  end.
end.

on return, mouse-select-dblclick of ed-notes in frame {&frame-name} do:
  apply "entry" to br-docs in frame {&frame-name}.
  return no-apply.
end.

on return, mouse-select-dblclick of br-docs in frame {&frame-name} do:
  apply "choose" to b-lkp in frame {&frame-name}.
end.

on value-changed of br-docs do:
  if available c-t-doc then do:
    find first cli-buf no-lock where cli-buf.obj-type = {&prs} and cli-buf.obj-code = c-t-doc.boss no-error.
    assign boss-name = ( if available cli-buf then cli-buf.obj-name else ? ).

    find first cli-buf no-lock where cli-buf.obj-type = {&prs} and cli-buf.obj-code = c-t-doc.agnt no-error.
    assign agnt-name = ( if available cli-buf then cli-buf.obj-name else ? ).

    find first cli-buf no-lock where cli-buf.obj-type = {&prs} and cli-buf.obj-code = c-t-doc.wrkr no-error.
    assign wrkr-name = ( if available cli-buf then cli-buf.obj-name else ? ).

    find first pay-type no-lock where pay-type.obj-code = c-t-doc.pay-code no-error.
/*    if available pay-type then do: display     pay-type.obj-name with frame {&frame-name}. end.*/
/*                          else do: display ? @ pay-type.obj-name with frame {&frame-name}. end.*/

    assign ed-notes = c-t-doc.PS.
    find first cli-buf no-lock where
               cli-buf.obj-type = c-t-doc.obj-type and
               cli-buf.obj-code = c-t-doc.obj-code no-error.
    assign obj-name = ( if available cli-buf then cli-buf.obj-name else ? ).

/*    display ed-notes obj-name boss-name agnt-name wrkr-name c-t-doc.creid with frame {&frame-name}.*/

    if doc-rec <> recid( c-t-doc ) then do:
      assign sch-num = 0.
      hide sch-num in frame {&frame-name}.
    end.

    run proc-view-changes in this-procedure no-error.
  end. /* if available c-t-doc */
end.


on choose of b-lines in frame {&frame-name} do:
if not available c-t-doc then return .
  define variable v-list as character no-undo.
  run str/docclins.w (
      input        parparentproc,   /* parParentProc  */
      input        '':U,           /* p-bttns        */
      input        'doc':U,         /* p-mode         */
      input        ?,               /* p-obj-type     */
      input        ?,               /* p-obj-code     */
      input        c-t-doc.doc-code,/* p-doc-code     */
      input        ?,               /* p-artic        */
      input        ?,               /* p-prod-type    */
      input        ?,               /* p-prod-code    */
      input-output v-list           /* p-rid-list     */
      ).
end.

ON CTRL-J, RETURN OF sch-date IN FRAME {&frame-name}
DO:
  run proc-find-date in this-procedure(lastkey <> keycode("return"), input frame {&frame-name} sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.

ON CTRL-J, return OF sch-fact IN FRAME {&frame-name}
DO:
  run proc-find-date in this-procedure(lastkey <> keycode("return"), input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.

ON CTRL-J, return OF sch-code IN FRAME {&frame-name}
DO:
  run proc-find-code in this-procedure(lastkey <> keycode("return"), input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

{ gbl/hot-key.i b-lkp }

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/algnbttn.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
/*run gbl/inidebug.p.*/
  /* для жесткого фильтра по оплате */
  find first sch-pay  no-lock where recid( sch-pay  ) = doc-rec no-error.

  /* для жесткого фильтра по валюте */
  find first sch-curr no-lock where recid( sch-curr ) = doc-rec no-error.

  /* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
  find first sch-cli  no-lock where recid( sch-cli  ) = doc-rec no-error.

  /* чтобы не усложнять условие жесткого фильтра и использовать в нем v-host-code */
  if parlist-mode = {&client-cmp}                     and
     available sch-cli                             and
     (sch-cli.obj-type = {&stock} or sch-cli.obj-type = {&shop}) then do:
    if sch-cli.obj-type = {&stock} then do:
      find first store no-lock where store.obj-code = sch-cli.obj-code.
      if store.host-code <> v-host-code then do:
        message "Список документов, в которых данный склад является контрагентом,"
                "смотрите из той фирмы, к которой он относится."
        view-as alert-box.
        return.
      end.
    end.
    else do:
      find first shop no-lock where shop.obj-code = sch-cli.obj-code.
      if shop.host-code <> v-host-code then do:
        message "Список документов, в которых данный магазин является контрагентом,"
                "смотрите из той фирмы, к которой он относится."
        view-as alert-box.
        return.
      end.
    end.
  end.
  enable
    b-quit b-lkp b-sch b-help  br-docs sch-code sch-date sch-fact ed-notes
    b-sel when lookup("b-sel":U, bttns) > 0
    b-mark when lookup("b-mark":U, bttns) > 0
    b-lines

  with frame {&frame-name}.

  if parlist-mode = 'doc':u then do:
     enable BR-changes with frame {&frame-name} .
     hide sch-code
          sch-date
          sch-fact
          sch-num
          pay-type.obj-name
          obj-name
          boss-name
          agnt-name
          wrkr-name
          c-t-doc.creid
          ed-notes
          in frame {&frame-name} .
  end.
  else do:
     hide BR-changes in frame {&frame-name} .
  end.



  if is-finvalue = "yes" then do:
     run align-buttons in this-procedure (input (frame {&frame-name}:handle), input v-button-order, input 1).
  end.
  if parlist-mode = 'doc':u or parlist-mode = {&g___object} then do:
     c-t-doc.corr-date:label = "Изменен" .
  end.
  else do:
     c-t-doc.corr-date:label = "Удален" .
  end.
  if parlist-mode = 'doc':u then do:
      if not can-find ( first ub.c-doc-line no-lock where ub.c-doc-line.doc-code = parext-doc-type ) then
        disable b-lines with frame {&frame-name} .
  end.
  view frame {&frame-name} .
  run OpenBr in this-procedure ( input yes, input no, input no ).

  if p-obj-type <> "" and
     p-obj-code <> 0  then do:
    find first bf_clients no-lock where
               bf_clients.obj-type = p-obj-type and
               bf_clients.obj-code = p-obj-code.
    if bf_clients.obj-type = {&shop} then do:
      find first bf_shop no-lock where bf_shop.obj-code = bf_clients.obj-code.
      assign
        v_shift = string( bf_shop.shift-on ).
    end.
    else do:
      find first bf_store no-lock where bf_store.obj-code = bf_clients.obj-code.
      assign
        v_shift = string( bf_store.shift-on ).
    end.
  end.
  else do:
    assign
      v_shift = "no":U.
  end.

{ gbl/mv-clmn.i
    &ext-col      = 42
    &frame-name   = "{&frame-name}"
    &browse-name  = "{&browse-name}"
    &table-name   = "c-t-doc"
    &start-column = 6
    /*&prev-order-column_1 = "'5,6,7,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36'"
    &prev-order-column-condition_1 = " v_shift <> 'yes' "
    */
}

  wait-for go of frame {&frame-name} focus br-docs.
END. /* MAIN-BLOCK */

RUN disable_UI IN THIS-PROCEDURE.


/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&FRAME-NAME} NO-PAUSE.
END PROCEDURE.

procedure OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

  assign {&enabled-clmn-br-dtl} :read-only in browse {&browse-name} = yes.
  /* ------------------------------------------------------------------------------------------------------------ */
  if p-open-query = yes then do:
    frame {&frame-name} :title = "ВСЕ  ДОКУМЕНТЫ".
    assign sch-num = 0.
    hide sch-num in frame {&frame-name}.
  end.
  else do:
    assign doc-rec = ?.
  end.

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH c-t-doc

&scop flt-open-dyn_open-query  FOR EACH c-t-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name c-t-doc

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name c-t-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer c-t-doc for ub.c-trn-doc.

&scop flt-open-waitfram yes


  if           paris-hold = no  then do:
    if lookup( parlist-mode, '{&bef-c-work},{&bef-c-company},{&bef-c-g___object},{&bef-c-type}':U ) > 0 then do:
      run OpenBr-3 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition  ).
    end.
    else do:
      run OpenBr-4 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
  end.
  else if paris-hold = yes then do:
    if lookup( parlist-mode, '{&bef-c-work},{&bef-c-company},{&bef-c-g___object},{&bef-c-type}':U ) > 0 then do:
      run OpenBr-5 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
    else do:
      run OpenBr-6 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
  end.
  else do:
    if lookup( parlist-mode, '{&bef-c-work},{&bef-c-company},{&bef-c-g___object},{&bef-c-type}':U ) > 0 then do:
      run OpenBr-1 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
    else do:
      run OpenBr-2 in this-procedure ( input p-open-query, input p-find-next, input p-find-condition ).
    end.
  end.

  if p-open-query <> yes   and
     available c-t-d-b then do:
    assign doc-rec = recid( c-t-d-b ).
  end.
  if doc-rec <> ? then do:
    if p-open-query <> yes then do:
      assign  sch-num = sch-num + 1.
      display sch-num with frame {&frame-name}.
    end.
    reposition br-docs to recid doc-rec no-error.
  end.
  else do:
    if p-open-query <> yes then do:
      message "Документ не найден." view-as alert-box.
      assign sch-num = 0.
    end.
  end.

if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.

  apply "entry"         to br-docs in frame {&frame-name}.
  apply "value-changed" to br-docs in frame {&frame-name}.
end procedure. /* OpenBr */


procedure OpenBr-1 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
case sort-column-name :
  when "" then do:
    assign
    sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
    sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

case parlist-mode :
  when {&c-work} then do:
    frame {&frame-name} :title = title0.
    assign filter-point = parlist-mode.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.is-del = yes "
    &dyn_where-cond = "' c-t-doc.is-del = yes '"
    &use-ind = "   "
    &by         = "  " }
  end. /* {&c-work} */
  when {&c-company} then do:
    frame {&frame-name} :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = {&c-work}
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.host-code = v-host-code  and c-t-doc.is-del    = yes "
    &dyn_where-cond =   " substitute ( ' c-t-doc.host-code = &1  and c-t-doc.is-del    = yes ', v-host-code )"
    &use-ind = " use-index host-date "
    &by         = "  " }
  end. /* {&c-company} */
  when {&c-g___object} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = parlist-mode
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type = p-obj-type ~
                  and c-t-doc.obj-code = p-obj-code ~
                  and c-t-doc.is-del   = yes "
    &dyn_where-cond =   " substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 and c-t-doc.is-del = yes ', ~{&double-quote~} , p-obj-type , p-obj-code  )"
    &use-ind = " use-index obj-date "
    &by         = "  " }
  end. /* {&c-g___object} */
  when {&c-type} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  " + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                              entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
    assign filter-point = {&c-all} + partype
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type     = p-obj-type      ~
                  and c-t-doc.obj-code     = p-obj-code      ~
                  and c-t-doc.internal     = parinternal      ~
                  and c-t-doc.doc-type     = partype          ~
                  and c-t-doc.ext-doc-type = parext-doc-type ~
                  and c-t-doc.is-del       = yes "
    &dyn_where-cond =   " substitute ( '
            c-t-doc.obj-type = &1&2&1     ~
        and c-t-doc.obj-code = &3         ~
        and c-t-doc.internal =  &4        ~
        and c-t-doc.doc-type =  &1&5&1    ~
        and c-t-doc.ext-doc-type = &1&6&1 ~
        and c-t-doc.is-del = yes ', ~{&double-quote~} , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type ) "
    &use-ind = " use-index type-date "
    &by         = "  " }
  end. /* {&c-type} */
end case. /* parlist-mode */
end procedure. /* OpenBr-1 */


procedure OpenBr-2 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
case sort-column-name :
  when "" then do:
    assign
    sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
    sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

case parlist-mode :
  when {&work} then do:
    assign filter-point = {&work}.
    { gbl/fltopend.i
    &where-cond = " yes "
    &dyn_where-cond = " 'yes' "
    &use-ind = "    "
    &by         = "  " }
  end. /* {&work} */
  when {&company} then do:
    frame {&frame-name} :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = {&work}
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.host-code = v-host-code "
    &dyn_where-cond = " substitute ( ' c-t-doc.host-code = &1 ', v-host-code )"
    &use-ind = " use-index host-date "
    &by         = "  " }
  end. /* {&company} */
  when {&g___object} then do:
    frame {&frame-name} :title = "История по документам " + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = {&g___object}
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type = p-obj-type ~
                  and c-t-doc.obj-code = p-obj-code "
    &dyn_where-cond =   " substitute ( ' c-t-doc.obj-type = &1&2&1 and c-t-doc.obj-code = &3 ', ~{&double-quote~} , p-obj-type , p-obj-code  )"
    &use-ind = " use-index obj-date "
    &by         = "  " }
  end. /* {&g___object} */
  when {&type} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  ":U + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                  entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
    assign filter-point = {&all} + partype
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type     = p-obj-type      ~
                    and c-t-doc.obj-code     = p-obj-code      ~
                    and c-t-doc.internal     = parinternal      ~
                    and c-t-doc.doc-type     = partype          ~
                    and c-t-doc.ext-doc-type = parext-doc-type "
    &dyn_where-cond =   " substitute ( '
            c-t-doc.obj-type = &1&2&1     ~
        and c-t-doc.obj-code = &3         ~
        and c-t-doc.internal =  &4        ~
        and c-t-doc.doc-type =  &1&5&1    ~
        and c-t-doc.ext-doc-type = &1&6&1 ~
        ', ~{&double-quote~} , p-obj-type , p-obj-code ,parinternal , partype , parext-doc-type ) "

    &use-ind = " use-index type-date "
    &by         = "  " }
  end. /* {&type} */
  when 'doc':U then do:
    frame {&frame-name} :title = title1 + parext-doc-type .
    assign filter-point = 'doc':U
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.doc-code = parext-doc-type "
    &dyn_where-cond =   " substitute ( ' c-t-doc.doc-code = &1&2&1 ', ~{&double-quote~} , parext-doc-type )"
    &use-ind = "   "
    &by         = "  " }
  end. /* 'doc':U */
end case. /* parlist-mode */
end procedure. /* OpenBr-2 */


procedure OpenBr-3 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
case sort-column-name :
  when "" then do:
    assign
    sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
    sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

case parlist-mode :
  when {&c-work} then do:
     assign frame {&frame-name}:title = title0 .
    assign filter-point = parlist-mode.
    { gbl/fltopend.i
    &where-cond = "
        c-t-doc.is-del = yes and ~
      ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
      ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' )
      "
    &dyn_where-cond =   " substitute ( '
      c-t-doc.is-del = yes and ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} )"
    &use-ind = " "
    &by         = "  " }
  end. /* {&c-work} */
  when {&c-company} then do:
    frame {&frame-name} :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = {&c-work}
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.host-code = v-host-code ~
                  and c-t-doc.is-del    = yes and ~
                    ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                    ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '
      c-t-doc.is-del = yes and ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} )"

    &use-ind = " use-index host-date "
    &by         = "  " }
  end. /* {&c-company} */
  when {&c-g___object} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = parlist-mode
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type = p-obj-type ~
                  and c-t-doc.obj-code = p-obj-code ~
                  and c-t-doc.is-del   = yes and ~
                    ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                    ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.is-del = yes and ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} , p-obj-type , p-obj-code )"

    &use-ind = " use-index obj-date "
    &by         = "  " }
  end. /* {&c-g___object} */
  when {&c-type} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  " + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                              entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
    assign filter-point = {&c-all} + partype
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type     = p-obj-type      ~
                    and c-t-doc.obj-code     = p-obj-code      ~
                    and c-t-doc.internal     = parinternal      ~
                    and c-t-doc.doc-type     = partype          ~
                    and c-t-doc.ext-doc-type = parext-doc-type ~
                    and c-t-doc.is-del       = yes and ~
                      ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                      ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "

    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.is-del = yes and ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
      c-t-doc.internal     = &4 and  ~
      c-t-doc.doc-type     = &1&5&1 and  ~
      c-t-doc.ext-doc-type = &1&6&1 and  ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type ) "

    &use-ind = " use-index type-date "
    &by         = "  " }
  end. /* {&c-type} */
end case. /* parlist-mode */

assign frame {&frame-name} :title = frame {&frame-name} :title + " (внешние контрагенты)".
end procedure. /* OpenBr-3 */


procedure OpenBr-4 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
case sort-column-name :
  when "" then do:
    assign
    sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
    sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

case parlist-mode :
  when {&work} then do:
    assign frame {&frame-name}:title = title0.
    assign filter-point = {&work}.
    { gbl/fltopend.i
    &where-cond = " ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                    ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "

    &dyn_where-cond =   " substitute ( '  ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} ) "


    &use-ind = " "
    &by      = "  " }
  end. /*  {&work} */
  when {&company} then do:
    frame {&frame-name} :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = {&work}
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.host-code = v-host-code and ~
                    ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                    ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.host-code = &2 and  ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} ,  v-host-code ) "

    &use-ind = " use-index host-date "
    &by         = "  " }
  end. /* {&company} */
  when {&g___object} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = {&g___object}
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type = p-obj-type and ~
                      c-t-doc.obj-code = p-obj-code and ~
                    ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                    ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} , p-obj-type , p-obj-code ) "

    &use-ind = " use-index obj-date "
    &by         = "  " }
  end. /* {&g___object} */
  when {&type} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  ":U + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                  entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
    assign filter-point = {&all} + partype
            objects = 2.
    { gbl/fltopend.i
      &where-cond = " c-t-doc.obj-type     = p-obj-type ~
                  and c-t-doc.obj-code     = p-obj-code ~
                  and c-t-doc.internal     = parinternal      ~
                  and c-t-doc.doc-type     = partype          ~
                  and c-t-doc.ext-doc-type = parext-doc-type and ~
                    ( c-t-doc.hold-doc-code-child  = '' or c-t-doc.hold-doc-code-child  = 'no-hold' ) and ~
                    ( c-t-doc.hold-doc-code-parent = '' or c-t-doc.hold-doc-code-parent = 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
      c-t-doc.internal     = &4 and  ~
      c-t-doc.doc-type     = &1&5&1 and  ~
      c-t-doc.ext-doc-type = &1&6&1 and  ~
    ( c-t-doc.hold-doc-code-child  = &1&1 or c-t-doc.hold-doc-code-child  = &1no-hold&1 ) and ~
    ( c-t-doc.hold-doc-code-parent = &1&1 or c-t-doc.hold-doc-code-parent = &1no-hold&1 )
      ', ~{&double-quote~} , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type ) "

      &use-ind = " use-index type-date "
    &by         = "  " }
  end. /* {&type} */
  when 'doc':U then do:
    frame {&frame-name} :title = title1 + parext-doc-type .
    assign filter-point = 'doc':U
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.doc-code = parext-doc-type "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.ext-doc-type = &1&2&1  ~
      ', ~{&double-quote~}  ,  parext-doc-type ) "

    &use-ind = "  "
    &by         = "  " }
  end. /* 'doc':U */
end case. /* parlist-mode */

if parlist-mode <> 'doc':U then do:
  assign frame {&frame-name} :title = frame {&frame-name} :title + " (внешние контрагенты)".
end.
end procedure. /* OpenBr-4 */


procedure OpenBr-5 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
case sort-column-name :
  when "" then do:
    assign
    sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
    sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
case parlist-mode :
  when {&c-work} then do:
    assign frame {&frame-name}:title = title0.
    assign filter-point = parlist-mode.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.is-del = yes and ~
                  ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                    c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.is-del = yes and  ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~}  ) "

    &use-ind = " "
    &by         = "  " }
  end. /* {&c-work} */
  when {&c-company} then do:
    frame {&frame-name} :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = {&c-work}
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.host-code = v-host-code ~
                  and c-t-doc.is-del    = yes and ~
                    ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                      c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond     = " substitute ( '  ~
      c-t-doc.is-del    = yes
      c-t-doc.host-code = &2 and ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~} , v-host-code ) "

    &use-ind = " use-index host-date "
    &by         = "  " }
  end. /* {&c-company} */
  when {&c-g___object} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = parlist-mode
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type = p-obj-type ~
                  and c-t-doc.obj-code = p-obj-code ~
                  and c-t-doc.is-del   = yes and ~
                    ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                      c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
      c-t-doc.is-del   = yes and ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~} , p-obj-type , p-obj-code ) "

    &use-ind = " use-index obj-date "
    &by         = "  " }
  end. /* {&c-g___object} */
  when {&c-type} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  " + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                              entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
    assign filter-point = {&c-all} + partype
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type     = p-obj-type      ~
                    and c-t-doc.obj-code     = p-obj-code      ~
                    and c-t-doc.internal     = parinternal      ~
                    and c-t-doc.doc-type     = partype          ~
                    and c-t-doc.ext-doc-type = parext-doc-type ~
                    and c-t-doc.is-del       = yes and ~
                      ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                        c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.is-del       = yes and ~
      c-t-doc.obj-code = &3 and ~
      c-t-doc.internal     = &4 and  ~
      c-t-doc.doc-type     = &1&5&1 and  ~
      c-t-doc.ext-doc-type = &1&6&1 and  ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~} , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type ) "

    &use-ind = " use-index type-date "
    &by         = "  " }
  end. /* {&c-type} */
end case. /* parlist-mode */
  assign frame {&frame-name} :title = frame {&frame-name} :title + " (межфирменные перемещения)".
end procedure. /* OpenBr-5 */


procedure OpenBr-6 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
case sort-column-name :
  when "" then do:
    assign
    sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
    sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
case parlist-mode :
  when {&work} then do:
    assign frame {&frame-name}:title = title0.
    assign filter-point = {&work}.
    { gbl/fltopend.i
    &where-cond = " ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                      c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~}  ) "

    &use-ind = "  "
    &by         = "  " }
  end. /* {&work} */
  when {&company} then do:
    frame {&frame-name} :title = title0 + "Фирма : " + v-host-name.
    assign filter-point = {&work}
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.host-code = v-host-code and ~
                    ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                      c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.host-code = &2 and ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~} , v-host-code ) "

    &use-ind = " use-index host-date "
    &by         = "  " }
  end. /* {&company} */
  when {&g___object} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code ).
    assign filter-point = {&g___object}
            objects = 2.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.obj-type = p-obj-type and ~
                      c-t-doc.obj-code = p-obj-code and ~
                    ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                      c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
    (( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
     ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 ))
      ', ~{&double-quote~} , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type ) "

    &use-ind = " use-index obj-date "
    &by         = "  " }
  end. /* {&g___object} */
  when {&type} then do:
    frame {&frame-name} :title = title0 + "Объект : " + p-obj-type + " ":U + string( p-obj-code )
                                              + "  ":U + string( parinternal, "внутр/внеш" )
                                              + "  Тип : " + partype + " Расширенный тип: " +
                                  entry( lookup( parext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
    assign filter-point = {&all} + partype
            objects = 2.
      { gbl/fltopend.i
      &where-cond = " c-t-doc.obj-type     = p-obj-type ~
                    and c-t-doc.obj-code     = p-obj-code ~
                    and c-t-doc.internal     = parinternal      ~
                    and c-t-doc.doc-type     = partype          ~
                    and c-t-doc.ext-doc-type = parext-doc-type and ~
                      ( c-t-doc.hold-doc-code-child  <> '' and c-t-doc.hold-doc-code-child  <> 'no-hold' or ~
                        c-t-doc.hold-doc-code-parent <> '' and c-t-doc.hold-doc-code-parent <> 'no-hold' ) "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.obj-type = &1&2&1 and ~
      c-t-doc.obj-code = &3 and ~
      c-t-doc.internal     = &4 and  ~
      c-t-doc.doc-type     = &1&5&1 and  ~
      c-t-doc.ext-doc-type = &1&6&1 and  ~
    ( c-t-doc.hold-doc-code-child  <> &1&1 and c-t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
    ( c-t-doc.hold-doc-code-parent <> &1&1 and c-t-doc.hold-doc-code-parent <> &1no-hold&1 )
      ', ~{&double-quote~} , p-obj-type , p-obj-code , parinternal , partype ,  parext-doc-type ) "

      &use-ind = " use-index type-date "
      &by         = "  " }
  end. /* {&type} */
  when 'doc':U then do:
    frame {&frame-name} :title = title1 + parext-doc-type .
    assign filter-point = 'doc':U
            objects = 1.
    { gbl/fltopend.i
    &where-cond = " c-t-doc.doc-code = parext-doc-type "
    &dyn_where-cond =   " substitute ( '  ~
      c-t-doc.doc-code = &1&2&1 ~
      ', ~{&double-quote~} ,  parext-doc-type ) "

    &use-ind = " "
    &by         = "  " }
  end. /* 'doc':U */
end case. /* parlist-mode */
if parlist-mode <> 'doc':U then do:
  assign frame {&frame-name} :title = frame {&frame-name} :title + " (межфирменные перемещения)".
end.
end procedure. /* OpenBr-6 */


procedure init-flt :
  assign
    tbl = 'c-trn-doc'
    join-tbl = 'c-t-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .
    run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure ('flag_', 'OK', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-code', 'Номер', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('shift-name', 'Номер смены', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    if lookup( parlist-mode, '{&bef-c-work},{&bef-c-company},{&bef-work},{&bef-company}':U ) > 0 then do:
    run fltfield-add in this-procedure('obj-type', 'Тип объекта', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.

    run fltfield-add in this-procedure('boss', 'Менеджер', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-rubl', 'Сумма ({&abbr_rub})', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('discnt-rubl', 'Скидка ({&abbr_rub})', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('discnt-type', 'Тип скидки', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('internal', 'Внутренняя', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-name', 'Название контр-а', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('creid', 'Создал', 'usr',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('agnt', 'Исполнитель', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('out-code', 'На док-т', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('acc-date', 'Проводка', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('base-rate', 'Курс', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('inv-num', 'Инвойс', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ord-num', 'Заказ', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('office', 'Услуги', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('print-rubl', '{&abbr_rublevy_firstshift}', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ship-num', 'Отгрузка', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ship-date', 'Дата отгрузки', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('ov', 'Акт', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('tot-ov', 'Сумма акта', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('exch-code', 'Валюта', 'cur',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('reason-code', 'Код основания (причины)', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('PS', 'Примечание', '',
                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

end procedure. /* init-flt */


procedure make-gen-button :
  do
  on error undo, return error return-value
  :
    if parlist-mode = 'doc':U then return .
    define variable  but-gen  as widget-handle.

    create button but-gen
    assign
      row          = 1
      column       = 63
      HEIGHT-CHARS = 1
      WIDTH-CHARS  = 10
      name         = "but-gen"
      label        = "Г&енерация"
      tooltip      = "Генерация Фин.обязательств по удаленным накладным"
      frame        = frame {&frame-name}:handle
      sensitive    = true
      visible      = true
      POPUP-MENU   = MENU POPUP-MENU-b-gen :HANDLE
      MENU-MOUSE   = 1
        .

  end. /* do */
end procedure. /* make-gen-button */


procedure make-fo-button :
  do
  on error undo, return error return-value
  :
  if parlist-mode = 'doc':U then return .
  define variable  but-fo  as widget-handle.
  create button but-fo
  assign
      row = 1
      column = 73
      HEIGHT-CHARS = 1
      WIDTH-CHARS = 10
      name = "but-fo"
      label = "Фин.Об"
      tooltip = "Список Фин.обязательств по накладной"
      frame = frame {&frame-name}:handle
      sensitive = true
      visible = true
        triggers :
          on choose persistent run list-fo in this-procedure.
        end triggers.


 end. /* do */
end procedure. /* make-fo-button */

procedure list-fo :
  do
  on error undo, return error return-value
  :
    find current c-t-doc no-lock no-error .
    if available c-t-doc then do:
      run str/fi-trns.w (
          input parparentproc,
          input v-host-code,
          input ?              ,
          input c-t-doc.doc-code ,
          input "trn-doc":U
          ) .
    end.

  end. /* do */
end procedure. /* list-fo */

procedure local-mark :
  if not available c-t-doc then do:
    message "Неправильный выбор строки." view-as alert-box.
    return no-apply.
  end.
  { gbl/markstrn.i c-t-doc mark-list }
  {&browse-name} :refresh() in frame {&frame-name}.
  apply "entry" to {&browse-name} in frame {&frame-name}.
end procedure. /* local-mark */

procedure proc-m_gen-1 :
  do
  on error undo, return error return-value
  :

    if num-entries(mark-list) = 0 then do:
      message "Не выделено ни одной накладной для генерации финансовых обязательств !" view-as alert-box .
      return error .
    end.
    run str/gen-fl.w (
        input parparentproc,
        input v-host-code,
        input mark-list,
        input "del"
    )   .

    assign
      mark-list = ""
      .
    run OpenBr in this-procedure ( input yes, input no, input no ).
  end. /* do */
end procedure. /* proc-m_gen-1 */

procedure proc-m_gen-2 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.

  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.

  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.

    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-incfo = yes then do:
        message "По документу " bf_c-trn-doc.doc-code " уже генерилось финансовое обязательство от "
                bf_c-trn-doc.incfo-date " числа."
        view-as alert-box error.
      end.
      else do:
        assign
          bf_c-trn-doc.need-incfo = 0.
        if bf_c-trn-doc.need-incfo = 0 and
           bf_c-trn-doc.need-expfo = 0 then do:
          assign
            bf_c-trn-doc.need-incorexpfo = 0.
        end.
        reposition {&browse-name} to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-postavka( recid( bf_c-trn-doc) ) @ varpost with browse {&browse-name}.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end. /* on error */
end procedure. /* proc-m_gen-2 */

procedure proc-m_gen-3 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.

  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.

  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.

    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-expfo = yes then do:
        message "По документу " bf_c-trn-doc.doc-code " уже генерилось финансовое обязательство от "
                bf_c-trn-doc.expfo-date " числа."
        view-as alert-box error.
      end.
      else do:
        assign
          bf_c-trn-doc.need-expfo = 0.
        if bf_c-trn-doc.need-incfo = 0 and
           bf_c-trn-doc.need-expfo = 0 then do:
          assign
            bf_c-trn-doc.need-incorexpfo = 0.
        end.
        reposition {&browse-name} to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-postavka( recid( bf_c-trn-doc )) @ varpost with browse {&browse-name}.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end. /* on error */
end procedure. /* proc-m_gen-3 */

procedure proc-m_gen-4 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.

  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.
  define variable varcr-incfo as logical no-undo.
  define variable varinc-exp  as integer no-undo.

  define buffer buf_parts    for ub.parts.
  define buffer buf_contract for ub.contract.

  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.

    vari-cycle:
    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-incfo = yes then do:
        assign
          varlog = no.
        message "По документу " bf_c-trn-doc.doc-code " было создано финансовое обязательство от " bf_c-trn-doc.incfo-date " ." skip
                "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          next vari-cycle.
        end.
        assign
          bf_c-trn-doc.cr-incfo   = no
          bf_c-trn-doc.incfo-date = 01/01/1990.
        if bf_c-trn-doc.cr-incfo = no and
           bf_c-trn-doc.cr-expfo = no then do:
          assign
            bf_c-trn-doc.cr-incorexpfo = no.
        end.
        reposition {&browse-name} to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-postavka( recid( bf_c-trn-doc) ) @ varpost with browse {&browse-name}.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end. /* on error */
end procedure. /* proc-m_gen-4 */

procedure proc-m_gen-5 :
  define buffer bf_sysconf   for ub.sysconf.
  define buffer bf_c-trn-doc for ub.c-trn-doc.

  define variable vari        as integer no-undo.
  define variable vardoc-code as integer no-undo.
  define variable varcr-expfo as logical no-undo.
  define variable varinc-exp  as integer no-undo.

  define buffer buf_parts    for ub.parts.
  define buffer buf_contract for ub.contract.

  do
  on error undo, return error return-value
  :
    if mark-list = "" then do:
      if available c-t-doc then do:
        assign
          mark-list = string( recid( c-t-doc ) ).
      end.
    end.

    vari-cycle:
    do vari = 1 to num-entries( mark-list ) :
      assign
        vardoc-code = integer( entry( vari, mark-list ) ).
      find first bf_c-trn-doc exclusive-lock where recid( bf_c-trn-doc ) = vardoc-code.
      if bf_c-trn-doc.status_ <> {&fact} then do:
        message "Документ " bf_c-trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
        view-as alert-box.
        next.
      end.
      find first bf_sysconf no-lock where bf_sysconf.host-code = bf_c-trn-doc.host-code.
      if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
        message "Главная БД для фирмы по документу с кодом " bf_c-trn-doc.doc-code " не является текущей БД." skip
                "Текущая БД: " v-cntxt-db-num skip
                "Главная БД фирмы: " bf_sysconf.firm-db-num
        view-as alert-box error.
        return error.
      end.
      if bf_c-trn-doc.cr-expfo = yes then do:
        assign
          varlog = no.
        message "По документу " bf_c-trn-doc.doc-code " было создано финансовое обязательство от " bf_c-trn-doc.incfo-date " ." skip
                "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
        view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          next vari-cycle.
        end.
        assign
          bf_c-trn-doc.cr-expfo   = no
          bf_c-trn-doc.expfo-date = 01/01/1990.
        if bf_c-trn-doc.cr-incfo = no and
           bf_c-trn-doc.cr-expfo = no then do:
          assign
            bf_c-trn-doc.cr-incorexpfo = no.
        end.
        reposition {&browse-name} to recid recid( bf_c-trn-doc ) no-error.
        if not error-status :error then do:
          display fo-realiz( recid( bf_c-trn-doc )) @ varrealiz with browse {&browse-name}.
        end.
      end.
    end.
    assign
      mark-list = "":U.
  end. /* on error */
end procedure. /* proc-m_gen-5 */


procedure get-c-holding :
  define  input parameter p-doc-code as character no-undo.
  define output parameter p-holding  as logical   no-undo.

  define variable l_is-holding as logical no-undo.

  do on error undo, return error return-value :
    { str/holdcdoc.i p-doc-code l_is-holding no-error }
    assign p-holding = ( if error-status :error or l_is-holding <> yes then no else yes ).
  end. /* on error */
end procedure. /* get-c-holding */

procedure local-sel :
if not available c-t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
if mark-list <> "" then do:
  assign doc-rec = recid (c-t-doc).
end.
else do:
  mark-list = string(recid(c-t-doc)).
  assign doc-rec = recid (c-t-doc).
end.
apply "go" to frame {&frame-name}.
end procedure.

PROCEDURE proc-find-date :
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.trn-doc.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-code
"":U @ sch-num
with frame {&frame-name}.

CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-fact = ?
      .
      display
      sch-fact
      '' @ sch-code
      with frame {&frame-name}.
    end.
    when "fact-date":U then do:
      assign
      sch-date = ?
      .
      display
      sch-date
      '' @ sch-code
      with frame {&frame-name}.
    end.
END CASE.

assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

CASE p-what-date:
    when "doc-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and c-t-doc.doc-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-date in frame {&frame-name}.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and c-t-doc.fact-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-fact in frame {&frame-name}.
    end.
END CASE.
END PROCEDURE.

PROCEDURE proc-find-code :
define input parameter p-next as logical no-undo.
define input parameter p-doc-code like ub.c-trn-doc.doc-code no-undo.
assign
sch-date = ?
sch-fact = ?
.

display
sch-date
sch-fact
with frame {&frame-name}.

assign
  p-doc-code = replace(p-doc-code, {&single-quote}, {&single-quote} + {&single-quote})
.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and c-t-doc.doc-code begins '&1'"
      ,p-doc-code)
    ).
apply "entry":u to sch-code in frame {&frame-name} .
END PROCEDURE.

PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer new_c-trn-doc for ub.c-trn-doc.
define buffer current_trn-doc for ub.trn-doc.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available c-t-doc then do:
  open query br-changes for each temp-changes.
  return.
end.

find first new_c-trn-doc no-lock where
           new_c-trn-doc.doc-code  = c-t-doc.doc-code
       and new_c-trn-doc.chip-num  > c-t-doc.chip-num no-error.

if not available new_c-trn-doc then do:
    find first current_trn-doc no-lock where
               current_trn-doc.doc-code  = c-t-doc.doc-code no-error.
         if not available current_trn-doc then do:
         return error.
    end.
    buffer-compare current_trn-doc to c-t-doc
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-trn-doc except chip-num corr-date corr-user-db-num  action to c-t-doc
    save result in v-chg-fields.
end.
&scop  disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign ~
    temp-changes.f_name = "~{&field-name~}":U ~
    temp-changes.l_name = ~{&field-label~} ~
    temp-changes.v_old = string(c-t-doc.~{&field-name~}) ~
    temp-changes.v_new = (if available new_c-trn-doc  ~
                             then string(new_c-trn-doc.~{&field-name~})  ~
                             else string(current_trn-doc.~{&field-name~})) ~
    . ~
  end. ~

define variable v-nn as integer   no-undo .
v-nn = num-entries(v-chg-fields) .
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):

&scop field-name  acc-date
&scop field-label "дата"
{&disp-field}
&scop field-name  agnt
&scop field-label "исполнитель"
{&disp-field}
&scop field-name  bge-date
&scop field-label "дата выгрузки"
{&disp-field}
&scop field-name  boss
&scop field-label "менеджер"
{&disp-field}
&scop field-name  buyer-fo-date
&scop field-label "ФО покупателя"
{&disp-field}
&scop field-name  cli-code
&scop field-label "Код контрагента"
{&disp-field}
&scop field-name  cli-name
&scop field-label "Контрагент"
{&disp-field}
&scop field-name  hold-obj-code
&scop field-label "Объект МФ"
{&disp-field}
&scop field-name  hold-obj-type
&scop field-label "Тип объекта МФ"
{&disp-field}
&scop field-name  cli-qnty
&scop field-label "Кол-во в ед.пос-ка"
{&disp-field}
&scop field-name  cli-type
&scop field-label "Тип Контрагента"
{&disp-field}
&scop field-name  closed
&scop field-label "партии закрыты."
{&disp-field}
/*
&scop field-name  corr-date
&scop field-label "дата корр-ки"
{&disp-field}
&scop field-name  corr-fbr-code
&scop field-label "документ пр-во"
{&disp-field}
&scop field-name  corr-inkas-code
&scop field-label "чек"
{&disp-field}
&scop field-name  corr-man
&scop field-label "кто."
{&disp-field}
&scop field-name  corr-shift-date
&scop field-label "сменная дата"
{&disp-field}
&scop field-name  corr-shift-name
&scop field-label "№смены"
{&disp-field}
&scop field-name  corr-shift-num
&scop field-label "Порядок смены"
{&disp-field}
&scop field-name  corr-time
&scop field-label "Время корр."
{&disp-field}

&scop field-name  corr-user-db-num
&scop field-label "БД корр."
{&disp-field}
*/

&scop field-name  cr-db-num
&scop field-label "БД создания"
{&disp-field}
&scop field-name  cr-expfo
&scop field-label "Создано ФО по расх"
{&disp-field}
&scop field-name  cr-factur
&scop field-label "Создан счет-фактура"
{&disp-field}
&scop field-name  cr-fo-buyer
&scop field-label "Создано ФО покупателя"
{&disp-field}
&scop field-name  cr-incfo
&scop field-label "Создано ФО по прих"
{&disp-field}
&scop field-name  cr-incorexpfo
&scop field-label "Создано ФО поставщика"
{&disp-field}
&scop field-name  creid
&scop field-label "создал"
{&disp-field}
&scop field-name  cst-code
&scop field-label "ГТД"
{&disp-field}
&scop field-name  d-card
&scop field-label "Дисконтная карта"
{&disp-field}
&scop field-name  discnt-pc
&scop field-label "Скидка"
{&disp-field}

&scop field-name  discnt-rubl
&scop field-label "Скидка в нац.вал."
{&disp-field}
&scop field-name  discnt-type
&scop field-label "Тип скидки"
{&disp-field}
&scop field-name  doc-qnty
&scop field-label "Кол-во по док-ту"
{&disp-field}
&scop field-name  exch-code
&scop field-label "валюта док-та"
{&disp-field}

&scop field-name  exch-date
&scop field-label "дата валюты"
{&disp-field}
&scop field-name  excise
&scop field-label "акциз"
{&disp-field}
&scop field-name  expfo-date
&scop field-label "дата расх ФО"
{&disp-field}
&scop field-name  ext-doc-type
&scop field-label "тип док-та"
 {&disp-field}
&scop field-name  fact-base
&scop field-label "факт сумма в баз.вал."
 {&disp-field}
&scop field-name  fact-num
&scop field-label "№ пп"
{&disp-field}
&scop field-name  fact-qnty
&scop field-label "Кол-во факт"
 {&disp-field}
&scop field-name  fact-rubl
&scop field-label "факт сумма в нац.вал."
{&disp-field}
&scop field-name  fact-time
&scop field-label "время закрытия"
{&disp-field}
&scop field-name  factur-date
&scop field-label "дата счета-фактуры"
{&disp-field}
&scop field-name  fbr-code
&scop field-label "производсво"
{&disp-field}

&scop field-name  flag_
&scop field-label "ОК"
{&disp-field}
&scop field-name  flora-order-date
&scop field-label "Дата заказа (букет)"
 {&disp-field}
&scop field-name  flora-pay-date
&scop field-label "Дата оплаты(букет)"
{&disp-field}
&scop field-name  hold-doc-code-child
&scop field-label "МФ №док-та ребенка"
 {&disp-field}
&scop field-name  hold-doc-code-parent
&scop field-label "МФ №док-та родителя"
 {&disp-field}
&scop field-name  hold-obj-code
&scop field-label "МФ объект"
{&disp-field}
&scop field-name  hold-obj-type
&scop field-label "МФ тип объекта"
 {&disp-field}
&scop field-name  incfo-date
&scop field-label "дата прих ФО"
{&disp-field}
&scop field-name  internal
&scop field-label "внутр. док-т"
{&disp-field}
&scop field-name  inv-num
&scop field-label "инвентаризация"
 {&disp-field}
&scop field-name  is-back-date
&scop field-label "Кор-ка задним числом"
{&disp-field}
&scop field-name  is-del
&scop field-label "Удален"
 {&disp-field}

&scop field-name  is-flora
&scop field-label "Букет"
{&disp-field}
&scop field-name  need-buyer
&scop field-label "Нужно ФО покупателя"
{&disp-field}
&scop field-name  need-expfo
&scop field-label "Нужно ФО по расходу"
{&disp-field}
&scop field-name  need-factur
&scop field-label "Нужен счет-фактура"
{&disp-field}
&scop field-name  need-incfo
&scop field-label "Нужно ФО по приходу"
{&disp-field}
&scop field-name  need-incorexpfo
&scop field-label "Нужно ФО поставщика"
{&disp-field}
&scop field-name  obj-code
&scop field-label "объект"
{&disp-field}
&scop field-name  obj-type
&scop field-label "тип объекта"
 {&disp-field}
&scop field-name  office
&scop field-label "услуги"
{&disp-field}
&scop field-name  ord-num
&scop field-label "Номер заказа"
{&disp-field}
&scop field-name  out-code
&scop field-label "Ссылка на док-т"
{&disp-field}

&scop field-name  ov
&scop field-label "акт авт.переоценки"
 {&disp-field}
&scop field-name  pay-code
&scop field-label "Способ платежа"
 {&disp-field}
&scop field-name  place-io-code
&scop field-label "Место п/о"
{&disp-field}
&scop field-name  point-code
&scop field-label "Пункт п/о"
 {&disp-field}
&scop field-name  print-rubl
&scop field-label "Печать в нац.вал."
  {&disp-field}
&scop field-name  PS
&scop field-label "Примечание"
  {&disp-field}
&scop field-name  purch-code
&scop field-label "тип приобретения"
 {&disp-field}
&scop field-name  re-grading-parts-minus
&scop field-label "пересорт по -парт."
 {&disp-field}
&scop field-name  real-date-create
&scop field-label "дата создания"
 {&disp-field}
&scop field-name  real-time-create
&scop field-label "время создания"
{&disp-field}
&scop field-name  reason-code
&scop field-label "Код причины"
  {&disp-field}
&scop field-name  ret-supp
&scop field-label "возврат поставщика"
  {&disp-field}


&scop field-name  road-tax
&scop field-label "дор.налог"
 {&disp-field}
&scop field-name  rsrv-date
&scop field-label "резервирование"
{&disp-field}
&scop field-name  scf-date
&scop field-label "счет-фактура"
 {&disp-field}
&scop field-name  shift-date
&scop field-label "сменная дата"
 {&disp-field}
&scop field-name  shift-name
&scop field-label "№ смены"
{&disp-field}
&scop field-name  shift-num
&scop field-label "Порядок смены"
{&disp-field}
&scop field-name  ship-date
&scop field-label "Дата отгрузки"
{&disp-field}
&scop field-name  ship-num
&scop field-label "Отгрузка"
{&disp-field}
&scop field-name  SLT-base
&scop field-label "НДС б.в."
{&disp-field}
&scop field-name  SLT-rubl
&scop field-label "НДС н.в"
{&disp-field}
&scop field-name  SLT-type

&scop field-label "НДС тип"
{&disp-field}
&scop field-name  status_
&scop field-label "статус"
{&disp-field}
&scop field-name  sys-date
&scop field-label "Системная дата"
{&disp-field}
&scop field-name  sys-time
&scop field-label "Системное время"
{&disp-field}
&scop field-name  tot-calc
&scop field-label "Расчет"
{&disp-field}
&scop field-name  tot-cli
&scop field-label "По ТТН"
{&disp-field}
&scop field-name  tot-doc
&scop field-label "По накл."
{&disp-field}
&scop field-name  tot-fact
&scop field-label "Факт"
{&disp-field}
&scop field-name  tot-lines
&scop field-label "Строк"
{&disp-field}
&scop field-name  tot-other
&scop field-label "Прочие"
{&disp-field}
&scop field-name  tot-ov
&scop field-label "По акту"
{&disp-field}
&scop field-name  tot-rubl
&scop field-label "По накл.н.в."
{&disp-field}
&scop field-name  tot-sale
&scop field-label "Сумма накладной Факт "
{&disp-field}

&scop field-name  tot-transp
&scop field-label "трансп.расх"
{&disp-field}
&scop field-name  user-db-num
&scop field-label "БД корректирования"
{&disp-field}
&scop field-name  user-name
&scop field-label "оператор"
{&disp-field}
&scop field-name  VAT-base
&scop field-label "НсП б.в"
{&disp-field}
&scop field-name  VAT-rubl
&scop field-label "НсП н.в"
{&disp-field}
&scop field-name  VAT-type
&scop field-label "НсП тип"
{&disp-field}
&scop field-name  whole-send-news
&scop field-label "ушла в новости"
{&disp-field}
&scop field-name  wrkr
&scop field-label "кладовщик"
{&disp-field}
&scop field-name  base-rate
&scop field-label "м-б баз.ва."
{&disp-field}

&scop field-name  base-scale
&scop field-label "шкала баз.вал."
{&disp-field}

&scop field-name  contract-code
&scop field-label "Номер договора"
{&disp-field}

&scop field-name  doc-date
&scop field-label "Дата создания"
{&disp-field}

&scop field-name  doc-type
&scop field-label "Тип"
{&disp-field}

&scop field-name  exch-rate
&scop field-label "м-б валюты платежа"
{&disp-field}

&scop field-name  exch-scale
&scop field-label "шкала валюты платежа"
{&disp-field}

&scop field-name  fact-date
&scop field-label "Дата факт"
{&disp-field}

&scop field-name  fact-order
&scop field-label "факт-ордер"
{&disp-field}

&scop field-name  host-code
&scop field-label "Код фирмы"
{&disp-field}


&scop field-name  status_
&scop field-label "Статус"
{&disp-field}

end case.
end.
open query br-changes for each temp-changes.

END PROCEDURE.


&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME