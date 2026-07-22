/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список документов флористов

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

здесь только внешний расход !!!

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter bttns          as character no-undo .
define input  parameter list-mode      as character no-undo .
define input  parameter g#flag         as logical   no-undo .
define input  parameter g#stat         as character no-undo .
define output parameter mark-list      as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов флористов".

define variable  parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable v-sys-key   as character         no-undo.
define variable  paris-hold      as   logical              no-undo.
define variable  varlog as logical   no-undo .
define variable  line-rec as recid no-undo .
define variable v-nn as integer   no-undo .

{ cmp/vssrevis.i "substitute('&1|&2',bttns,parext-doc-type)"  }
{ cmp/trg-def.i    }
{ str/get-pr.i def }
{ gbl/fltfield.i   }
{ str/tt-tax.i new }
{ cmp/library.i    }
{ str/lib-trn.i    }
{ str/lib-farh.i   }
{ gbl/waitfram.i   noprocess }
{ cmp/gds-list.i gds-list def "new shared"}
{ str/trdcalib.i     }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/fltopend.i defproc }
{ cmp/strcodec.i }


define new shared variable next-prev  as logical   no-undo .
define variable doc-rec               as recid     no-undo .
define variable pardoc-rec            as recid     no-undo .
define variable v-log                 as logical   no-undo .
define variable g#report-num          as integer   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable v-sale                as logical   no-undo .

define variable from-date  as   date no-undo.
define variable to-date    as   date no-undo.


{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
  /*
  g # side-active = (v-cntxt-db-num-obj = v-cntxt-db-num)
  g # obj-remote  = (v-cntxt-db-num-obj <> 0)
  g # db-remote   = (v-cntxt-db-num <> 0)
  */

{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code  v-cntxt-host-code-obj v-cntxt-host-name-obj }
run get-report-num  in parParentProc ( output g#report-num ).

assign
  parext-doc-type =  {&TDEDT_Ras_Vnesh}
  paris-hold = false
.


&Scop if-not-true ~
if not v-log then do: ~
  find t-doc where recid (t-doc) = doc-rec no-lock. ~
  return no-apply. ~
end.

&Scop net-proc ~
if not available t-doc then do: ~
  message "Неправильно выбран документ.". ~
  return no-apply. ~
end. ~
doc-rec = recid (t-doc). ~
pardoc-rec = recid (t-doc). ~
do on stop undo, return no-apply : ~
  find t-doc where recid (t-doc) = doc-rec exclusive.  /* сетевая проверка */ ~
end. ~
if t-doc.status_      = {&fact}                     or       ~
   t-doc.status_      = {&ready}                    or       ~
   t-doc.status_      = {&rejected}                 or       ~
   t-doc.status_      = {&doc-froze}                or       ~
   t-doc.status_      = {&manufactured}                      ~
   then do: ~
   find t-doc where recid (t-doc) = doc-rec no-lock. ~
   message "Данный документ закрыт по факту или не может быть обработан в этом списке.". ~
   return no-apply. ~
end.
&Scop net-del ~
if not available t-doc then do: ~
  message "Неправильно выбран документ.". ~
  return no-apply. ~
end. ~
doc-rec = recid (t-doc). ~
pardoc-rec = recid (t-doc). ~
do on stop undo, return no-apply : ~
  find t-doc where recid (t-doc) = doc-rec exclusive.  /* сетевая проверка */ ~
end. ~
if t-doc.status_      = {&doc-froze}        or       ~
   t-doc.status_      = {&manufactured}              ~
   then do: ~
   find t-doc where recid (t-doc) = doc-rec no-lock. ~
   message "Данный документ не может быть удален.". ~
   return no-apply. ~
end.


&Scop WINDOW-NAME d-all-docs
&Scop FRAME-NAME     d-all-docs
&Scop BROWSE-NAME br-docs


define new shared var br-handle as handle no-undo.
define variable bf-handle as handle no-undo.

DEFINE new SHARED BUFFER t-doc for ub.trn-doc.



/* для жесткого фильтра по оплате */
define  new shared buffer sch-pay for ub.pay-type.
/* для жесткого фильтра по валюте */
define  new shared buffer sch-curr for ub.currency.
/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
define  new shared buffer sch-cli for ub.clients.
/* для списка мешающих документов по инвентаризации */
define  new shared buffer sch-inv for ub.trn-doc.

define new shared variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define new shared variable varis-hold      as   logical                 no-undo.

assign
  varext-doc-type = parext-doc-type
  varis-hold      = paris-hold
.

define  buffer cli-buf for ub.clients.  /* для вывода м-ра, исп-ля, кл-ка */
define  buffer t-d-b for ub.trn-doc.  /* для поиска по номеру, дате, факт */

/* список recid для внешней программы (кнопка b-ext) */
define temp-table temp_recid-list no-undo
    field string-trn-doc-recid as character
    index pi is primary unique string-trn-doc-recid
.

define variable sch-field as character no-undo.
/*define variable mark-list as char no-undo.*/
define variable mark      as character no-undo.
{ gbl/flt-def.i }

define variable old-list           as character  no-undo.
define variable old-stat           as character  no-undo.
define variable chg-qnty like ub.gds-dtl.doc-qnty no-undo.
define variable choice             as logical    no-undo  initial ?.
define variable objects            as integer    no-undo.
define variable varfact-date       as date       no-undo.
define variable varshift-date      as date       no-undo.
define variable varshift-num       as integer    no-undo.
define variable varshift-name      as character  no-undo.
define variable varcheck-return    as logical    no-undo.
define variable varpost            as character  no-undo.
define variable varrealiz          as character  no-undo.
define variable v-ext-button-label as character  no-undo.
define variable v_shift            as character  no-undo  initial ?. /* учет по сменам на объекте */
define variable v_data-type        as character  no-undo  initial ?.
define variable varhold            as character  no-undo.
define variable varhold-type       as character  no-undo.
define variable sort-column-name   as character  no-undo.
define variable filter-point       as character  no-undo.
define variable l-query-was-opened as logical    no-undo.
define variable sort-column-phrase as character  no-undo.
define variable parschdoc-code     like ub.trn-doc.doc-code     no-undo.
define variable parschcurr-code    like ub.currency.curr-code   no-undo.
define variable parschobj-code     like ub.clients.obj-code     no-undo.
define variable parschcli-type     like ub.clients.obj-type     no-undo.
define variable parschcli-code     like ub.clients.obj-code     no-undo.

define buffer exp_trn-doc for ub.trn-doc.
define buffer ret-doc     for ub.trn-doc.

/* ----------------------------  верхний ряд батонов  -------------------------------- */

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 8 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 8 BY 1.

DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 10 BY 1.

DEFINE BUTTON b-bc
     LABEL "&Ценник":L
     SIZE 10 BY 1.

DEFINE BUTTON b-akt
     LABEL "АПерео&ц":L
     SIZE 10 BY 1.


DEFINE BUTTON b-ext
     LABEL "Запус&к":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

/* ----------------------------  нижний ряд батонов  -------------------------------- */

DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-close-new
     LABEL "&Закрыть":L
     SIZE 10 BY 1.
DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 1 BY 1.


DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 10 BY 1.


DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 4 BY 1.

define button b-exp
     label "Экспорт":l
     size 10 by 1.


DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.


DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98 BY 2 NO-UNDO.

define  MENU m-rep
    MENU-ITEM m-rep-1 LABEL "По документам"  ACCELERATOR "ALT-1"
    MENU-ITEM m-rep-2 LABEL "Отчет по оплате заказов на исполнение"  ACCELERATOR "ALT-2"
    .

define new shared variable sch-code    like ub.trn-doc.doc-code no-undo.
define new shared variable sch-date    as   date view-as fill-in size 9 by 1 no-undo.
define new shared variable sch-fact    as   date view-as fill-in size 9 by 1 no-undo.
define new shared variable sch-objtype like ub.clients.obj-type no-undo.
define new shared variable sch-objcode like ub.clients.obj-code no-undo.
define new shared variable sch-sum     like ub.trn-doc.tot-fact no-undo.
define new shared variable sch-num     as   integer view-as fill-in size 3 by 1 no-undo.
define new shared variable sch-order    as   date view-as fill-in size 9 by 1 no-undo.

define new shared query br-docs for t-doc  scrolling.
{ str/all-docs.i }
{ str/all-docc.i }
{ str/all-doc1.i }

function fn-time return char
(input p-rec as recid ) .
define buffer loc-t-doc for ub.trn-doc.
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return '' .
define variable v-val as character no-undo init "".
define variable v-type as character no-undo .
  { str/tdat-val.i
      loc-t-doc.doc-code
      {&trdcattr-ord_time}
      v-val
      v-type
      no-error
  }
  if error-status :error then v-val = "" .
  return ( v-val ) .
end function.

function fn-deliv return logical
(input p-rec as recid ) .
define buffer loc-t-doc for ub.trn-doc.
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return false  .
define variable v-val1 as character no-undo  .
define variable v-val  as logical   no-undo  initial false .
define variable v-type as character no-undo .
  { str/tdat-val.i
      loc-t-doc.doc-code
      {&trdcattr-ord_dl}
      v-val1
      v-type
      no-error
  }
  if not error-status :error and  v-val1 = "yes" then v-val = true .
  return ( v-val ) .
end function.

function fn-ord-itogo return decimal
(input p-rec as recid ) .
define buffer loc-t-doc for ub.trn-doc.
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error . if error-status :error then return 0 .

define variable v-val  as character no-undo initial "".
define variable v-type as character no-undo .
define variable v-dec  as decimal   no-undo .
if loc-t-doc.status_ = {&fact} then do:
   v-dec = decimal(total-pay-fact (recid( loc-t-doc))) .
   return v-dec   .
   end.
  { str/tdat-val.i
      loc-t-doc.doc-code
      {&trdcattr-discnt-stop}
      v-val
      v-type
      no-error
  }

  if error-status :error then v-val = "" .
  return (decimal(v-val) ) .
end function.

&scop label-clmn_1-br-dtl  '*'
&scop sort-clmn_1-br-dtl   mark-string (recid( t-doc))
&scop dyn_sort-clmn_1-br-dtl   substitute('dynamic-function(&1mark-string&1, ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_2-br-dtl  'Стат'
&scop sort-clmn_2-br-dtl   t-doc.status_
&scop label-clmn_3-br-dtl  'OK'
&scop sort-clmn_3-br-dtl   t-doc.flag_
&scop label-clmn_4-br-dtl  'Номер'
&scop sort-clmn_4-br-dtl   t-doc.doc-code
&scop label-clmn_5-br-dtl  'Дата'
&scop sort-clmn_5-br-dtl   t-doc.doc-date
&scop label-clmn_6-br-dtl  'Факт'
&scop sort-clmn_6-br-dtl   t-doc.fact-date
&scop label-clmn_7-br-dtl 'Контрагент'
&scop sort-clmn_7-br-dtl  fcli-name (recid(t-doc))
&scop dyn_sort-clmn_7-br-dtl  substitute('dynamic-function(&1fcli-name&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_8-br-dtl 'Дата заказа'
&scop sort-clmn_8-br-dtl  t-doc.flora-order-date
&scop label-clmn_9-br-dtl 'Время'
&scop sort-clmn_9-br-dtl  fn-time (recid(t-doc))
&scop dyn_sort-clmn_9-br-dtl  substitute('dynamic-function(&1fn-time&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_10-br-dtl 'Д'
&scop sort-clmn_10-br-dtl  fn-deliv (recid(t-doc))
&scop dyn_sort-clmn_10-br-dtl  substitute('dynamic-function(&1fn-deliv&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_11-br-dtl 'Объект'
&scop sort-clmn_11-br-dtl  object-label (recid(t-doc))
&scop dyn_sort-clmn_11-br-dtl  substitute('dynamic-function(&1fobject-label&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_12-br-dtl 'Кол-во по док.'
&scop sort-clmn_12-br-dtl  t-doc.doc-qnty
&scop label-clmn_13-br-dtl 'Кол-во факт'
&scop sort-clmn_13-br-dtl  t-doc.fact-qnty
&scop label-clmn_14-br-dtl '$'
&scop sort-clmn_14-br-dtl  t-doc.print-rubl
&scop label-clmn_15-br-dtl 'Сумма по док'
&scop sort-clmn_15-br-dtl  total-sum (recid(t-doc))
&scop dyn_sort-clmn_15-br-dtl  substitute('dynamic-function(&1total-sum&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_16-br-dtl 'Скидка по док'
&scop sort-clmn_16-br-dtl  total-dsc (recid(t-doc))
&scop dyn_sort-clmn_16-br-dtl  substitute('dynamic-function(&1total-dsc&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_17-br-dtl 'Сумма факт'
&scop sort-clmn_17-br-dtl  total-fact (recid(t-doc))
&scop dyn_sort-clmn_17-br-dtl  substitute('dynamic-function(&1total-fact&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_18-br-dtl 'Скидка факт'
&scop sort-clmn_18-br-dtl  total-dsc-fact (recid(t-doc))
&scop dyn_sort-clmn_18-br-dtl  substitute('dynamic-function(&1total-dsc-fact&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_19-br-dtl 'К оплате факт'
&scop sort-clmn_19-br-dtl  fn-ord-itogo (recid(t-doc))
&scop dyn_sort-clmn_19-br-dtl  substitute('dynamic-function(&1fn-ord-itogo&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_20-br-dtl 'НДС'
&scop sort-clmn_20-br-dtl  total-vat (recid(t-doc))
&scop dyn_sort-clmn_20-br-dtl  substitute('dynamic-function(&1total-vat&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_21-br-dtl 'Налог прод.'
&scop sort-clmn_21-br-dtl  total-slt (recid(t-doc))
&scop dyn_sort-clmn_21-br-dtl  substitute('dynamic-function(&1total-slt&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_22-br-dtl 'Скидка (%)'
&scop sort-clmn_22-br-dtl  t-doc.discnt-pc
&scop label-clmn_23-br-dtl 'Тип скидки'
&scop sort-clmn_23-br-dtl  t-doc.discnt-type
&scop label-clmn_24-br-dtl 'Курс'
&scop sort-clmn_24-br-dtl  t-doc.base-rate
&scop label-clmn_25-br-dtl 'А'
&scop sort-clmn_25-br-dtl  t-doc.ov
&scop label-clmn_26-br-dtl 'Авт. переоц. (прод.)'
&scop sort-clmn_26-br-dtl  t-doc.tot-ov
&scop label-clmn_27-br-dtl 'Инвойс'
&scop sort-clmn_27-br-dtl  t-doc.inv-num
&scop label-clmn_28-br-dtl 'Заказ'
&scop sort-clmn_28-br-dtl  t-doc.ord-num
&scop label-clmn_29-br-dtl 'Отгрузка приход'
&scop sort-clmn_29-br-dtl  t-doc.ship-num
&scop label-clmn_30-br-dtl 'Дата'
&scop sort-clmn_30-br-dtl  t-doc.ship-date
&scop label-clmn_31-br-dtl 'На док-т'
&scop sort-clmn_31-br-dtl  t-doc.out-code
&scop label-clmn_32-br-dtl 'Проводка'
&scop sort-clmn_32-br-dtl  t-doc.acc-date
&scop label-clmn_33-br-dtl 'Экспорт'
&scop sort-clmn_33-br-dtl  t-doc.bge-date
&scop label-clmn_34-br-dtl  'Смена'
&scop sort-clmn_34-br-dtl   shift-day-month (recid(t-doc))
&scop dyn_sort-clmn_34-br-dtl  substitute('dynamic-function(&1shift-day-month&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_35-br-dtl  '№'
&scop sort-clmn_35-br-dtl   shift-name (recid(t-doc))
&scop dyn_sort-clmn_35-br-dtl  substitute('dynamic-function(&1shift-name&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_36-br-dtl  'Трансп.расх.(Доставка)'
&scop sort-clmn_36-br-dtl   t-doc.tot-transp
&scop label-clmn_37-br-dtl  'Дата оплаты'
&scop sort-clmn_37-br-dtl   t-doc.flora-pay-date

define browse br-docs query br-docs no-lock display
      {&sort-clmn_1-br-dtl}  column-label {&label-clmn_1-br-dtl}  format "x(1)"
      {&sort-clmn_2-br-dtl}  column-label {&label-clmn_2-br-dtl}  format "x(4)"
      {&sort-clmn_3-br-dtl}  column-label {&label-clmn_3-br-dtl}  format "+/-"
      {&sort-clmn_4-br-dtl}  column-label {&label-clmn_4-br-dtl}
      {&sort-clmn_5-br-dtl}  column-label {&label-clmn_5-br-dtl}  format "99/99/99"
      {&sort-clmn_6-br-dtl}  column-label {&label-clmn_6-br-dtl}
      {&sort-clmn_7-br-dtl}  column-label {&label-clmn_7-br-dtl}  format "x(26)"
      {&sort-clmn_8-br-dtl}  column-label {&label-clmn_8-br-dtl}  format "99/99/9999"
      {&sort-clmn_9-br-dtl}  column-label {&label-clmn_9-br-dtl}  format "x(5)"
      {&sort-clmn_10-br-dtl} column-label {&label-clmn_10-br-dtl} format "+/-"
      {&sort-clmn_15-br-dtl} column-label {&label-clmn_15-br-dtl} format "->>>,>>>,>>9.99"
      {&sort-clmn_19-br-dtl} column-label {&label-clmn_19-br-dtl} format "->>>,>>>,>>9.99"
      {&sort-clmn_12-br-dtl} column-label {&label-clmn_12-br-dtl}
      {&sort-clmn_13-br-dtl} column-label {&label-clmn_13-br-dtl}
      {&sort-clmn_14-br-dtl} column-label {&label-clmn_14-br-dtl}  format "+/-"
      {&sort-clmn_11-br-dtl} column-label {&label-clmn_11-br-dtl}  format "x(9)"
      {&sort-clmn_16-br-dtl} column-label {&label-clmn_16-br-dtl}  format "->>>,>>>,>>9.99"
      {&sort-clmn_18-br-dtl} column-label {&label-clmn_18-br-dtl}  format "->>>,>>>,>>9.99"
      {&sort-clmn_20-br-dtl} column-label {&label-clmn_20-br-dtl}  format "->,>>>,>>>,>>9.99"
      {&sort-clmn_22-br-dtl} column-label {&label-clmn_22-br-dtl}  format "->,>>9.99"
      {&sort-clmn_23-br-dtl} column-label {&label-clmn_23-br-dtl}
      {&sort-clmn_24-br-dtl} column-label {&label-clmn_24-br-dtl}
      {&sort-clmn_25-br-dtl} column-label {&label-clmn_25-br-dtl}
      {&sort-clmn_26-br-dtl} column-label {&label-clmn_26-br-dtl}
      {&sort-clmn_27-br-dtl} column-label {&label-clmn_27-br-dtl}
      {&sort-clmn_31-br-dtl} column-label {&label-clmn_31-br-dtl}
      {&sort-clmn_32-br-dtl} column-label {&label-clmn_32-br-dtl}
      {&sort-clmn_33-br-dtl} column-label {&label-clmn_33-br-dtl}
      {&sort-clmn_34-br-dtl} column-label {&label-clmn_34-br-dtl}
      {&sort-clmn_35-br-dtl} column-label {&label-clmn_35-br-dtl} format "x(6)"
      {&sort-clmn_36-br-dtl} column-label {&label-clmn_36-br-dtl}
      {&sort-clmn_37-br-dtl} column-label {&label-clmn_37-br-dtl}
    enable {&sort-clmn_32-br-dtl} with size 98 by 13.5 separators.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&frame-name}
     /* 1-й ряд батонов */
     b-quit AT ROW 1 COL 2
     b-mark AT ROW 1 COL 10
     b-sel  AT ROW 1 COL 14
     b-rep  AT ROW 1 COL 22
     b-bc   AT ROW 1 COL 32
     b-akt  AT ROW 1 COL 42
     b-ext  AT ROW 1 COL 52
     b-exp  at row 1 col 62
     b-sch  AT ROW 1 COL 32
     b-help AT ROW 1 COL 86
     /* 2-й ряд батонов */
     b-add    AT ROW 2.3 COL 2
     b-lkp    AT ROW 2.3 COL 12
     b-chg    AT ROW 2.3 COL 22
     b-del    AT ROW 2.3 COL 32
     b-close-new  AT ROW 2.3 COL 42
     b-open   AT ROW 2.3 COL 52


     b-print  AT ROW 2.3 COL 86
     br-docs  AT ROW 3.5 COL 1
     sch-code at row 19 col 2 label "&Начало номера"
     sch-date at row 19 col 33 label "Д&ата"
     sch-fact at row 19 col 52 label "Фа&кт"
     sch-objcode at row 19 col 71 label "&Контрагент"
     sch-objtype at row 19 col 94 no-label
     sch-order at row 20 col 33 label "Дата заказа"
     sch-sum at row 20 col 2 label "&Сумма факт   "
     sch-num at row 19 col 80 label "Найдено" fgcolor 12
     ub.pay-type.obj-name at row 17 col 5 COLON-ALIGNED LABEL "Опл" VIEW-AS FILL-IN SIZE 34 BY 1 fgcolor 4
     obj-name at row 17 col 55 COLON-ALIGNED LABEL "Объект" VIEW-AS FILL-IN SIZE 34 BY 1 fgcolor 4
     boss-name at row 18 col 5 COLON-ALIGNED LABEL "М-р" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     agnt-name at row 18 col 30 COLON-ALIGNED LABEL "Исп" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     wrkr-name at row 18 col 55 COLON-ALIGNED LABEL "Кл-к" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     v-user-name at row 18 col 80 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 16 BY 1 fgcolor 4
     ed-notes AT ROW 21 COL 1 no-label bgcolor 8 fgcolor 4
     b-close AT ROW 21 COL 1
     SPACE(0) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.

{ gbl/srt-clmd.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "t-doc"
&ext-col = 36
&start-column  = 6
&label-clmn_1  = "{&label-clmn_1-br-dtl}"
&sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
&dyn_sort-clmn_1   = "{&dyn_sort-clmn_1-br-dtl}"
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
&dyn_sort-clmn_7   = "{&dyn_sort-clmn_7-br-dtl}"
&label-clmn_8  = "{&label-clmn_8-br-dtl}"
&sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
&label-clmn_9  = "{&label-clmn_9-br-dtl}"
&sort-clmn_9   = "{&sort-clmn_9-br-dtl}"
&dyn_sort-clmn_9   = "{&dyn_sort-clmn_9-br-dtl}"
&label-clmn_10 = "{&label-clmn_10-br-dtl}"
&sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
&dyn_sort-clmn_10  = "{&dyn_sort-clmn_10-br-dtl}"
&label-clmn_11 = "{&label-clmn_11-br-dtl}"
&sort-clmn_11  = "{&sort-clmn_11-br-dtl}"
&dyn_sort-clmn_11  = "{&dyn_sort-clmn_11-br-dtl}"
&label-clmn_12 = "{&label-clmn_12-br-dtl}"
&sort-clmn_12  = "{&sort-clmn_12-br-dtl}"
&label-clmn_13 = "{&label-clmn_13-br-dtl}"
&sort-clmn_13  = "{&sort-clmn_13-br-dtl}"
&label-clmn_14 = "{&label-clmn_14-br-dtl}"
&sort-clmn_14  = "{&sort-clmn_14-br-dtl}"
&label-clmn_15 = "{&label-clmn_15-br-dtl}"
&sort-clmn_15  = "{&sort-clmn_15-br-dtl}"
&dyn_sort-clmn_15  = "{&dyn_sort-clmn_15-br-dtl}"
&label-clmn_16 = "{&label-clmn_16-br-dtl}"
&sort-clmn_16  = "{&sort-clmn_16-br-dtl}"
&dyn_sort-clmn_16  = "{&dyn_sort-clmn_16-br-dtl}"
&label-clmn_17 = "{&label-clmn_17-br-dtl}"
&sort-clmn_17  = "{&sort-clmn_17-br-dtl}"
&dyn_sort-clmn_17  = "{&dyn_sort-clmn_17-br-dtl}"
&label-clmn_18 = "{&label-clmn_18-br-dtl}"
&sort-clmn_18  = "{&sort-clmn_18-br-dtl}"
&dyn_sort-clmn_18  = "{&dyn_sort-clmn_18-br-dtl}"
&label-clmn_19 = "{&label-clmn_19-br-dtl}"
&sort-clmn_19  = "{&sort-clmn_19-br-dtl}"
&dyn_sort-clmn_19  = "{&dyn_sort-clmn_19-br-dtl}"
&label-clmn_20 = "{&label-clmn_20-br-dtl}"
&sort-clmn_20  = "{&sort-clmn_20-br-dtl}"
&dyn_sort-clmn_20  = "{&dyn_sort-clmn_20-br-dtl}"
&label-clmn_21 = "{&label-clmn_21-br-dtl}"
&sort-clmn_21  = "{&sort-clmn_21-br-dtl}"
&dyn_sort-clmn_21  = "{&dyn_sort-clmn_21-br-dtl}"
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
&label-clmn_33 = "{&label-clmn_33-br-dtl}"
&sort-clmn_33  = "{&sort-clmn_33-br-dtl}"
&label-clmn_34 = "{&label-clmn_34-br-dtl}"
&sort-clmn_34  = "{&sort-clmn_34-br-dtl}"
&dyn_sort-clmn_34  = "{&dyn_sort-clmn_34-br-dtl}"
&label-clmn_35 = "{&label-clmn_35-br-dtl}"
&sort-clmn_35  = "{&sort-clmn_35-br-dtl}"
&dyn_sort-clmn_35  = "{&dyn_sort-clmn_35-br-dtl}"
&label-clmn_36 = "{&label-clmn_36-br-dtl}"
&sort-clmn_36  = "{&sort-clmn_36-br-dtl}"
&label-clmn_37 = "{&label-clmn_37-br-dtl}"
&sort-clmn_37  = "{&sort-clmn_37-br-dtl}"
&open-query = "run ui-on ('open')."
&open-query-otherwise = "run ui-on ('open')."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name"
}
/* &sort-column-name     = "sort-column-name" */
/* ***************  Runtime Attributes and UIB Settings  ************** */
ASSIGN
  FRAME {&frame-name} :SCROLLABLE       = FALSE
  br-docs :NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 5.

ASSIGN b-rep :POPUP-MENU IN FRAME {&frame-name} = MENU m-rep :HANDLE.
ASSIGN b-rep :MENU-MOUSE = 1.


/* ************************  Control Triggers  ************************ */

ON CHOOSE OF MENU-ITEM m-rep-1 in menu m-rep DO:  /* шапки */

  define variable buf-handle as handle no-undo .
  define variable q-handle as handle no-undo .
  buf-handle = buffer t-doc :handle .
  q-handle   = query br-docs :handle .
  run rep/rep-par.w (input  parparentproc , input   frame {&frame-name}:title , input  q-handle , input buf-handle ).

  choice = ?.
END.

ON CHOOSE OF MENU-ITEM m-rep-2 in menu m-rep DO:  /* товары */
  run rep/g-flora.p (input parparentproc ).
  choice = ?.
END.

on choose of b-mark in frame {&frame-name} do:
  RUN local-mark.
  v-log = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.

/* для устранения подвисания при неправильных нажатиях */
on any-printable of br-docs in frame {&frame-name} do:
  assign
    sch-code:screen-value = sch-code:screen-value + last-event:label.
  apply "entry" to sch-code in frame {&frame-name}.
end.
on ctrl-j of sch-code in frame {&frame-name} /* номеру */
do:
  run proc-find-code in this-procedure(yes, input frame {&frame-name} sch-code).
end.
on return of sch-code in frame {&frame-name} /* номеру */
do:
  run proc-find-code in this-procedure(no, input frame {&frame-name} sch-code).
  return no-apply.
end.
on ctrl-j of sch-date in frame {&frame-name} /* дате */
do:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-date, "doc-date").
end.
on return of sch-date in frame {&frame-name} /* дате */
DO:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-date, "doc-date":U).
  return no-apply.
END.
on ctrl-j of sch-fact in frame {&frame-name}
do:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-fact, "fact-date":u).
end.
on return of sch-fact in frame {&frame-name} /* дате факт */
do:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-fact, "fact-date":u).
  return no-apply.
end.
on ctrl-j of sch-objtype in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
end.
on return of sch-objtype in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
  return no-apply.
end.
on return of sch-objcode in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
  return no-apply.
end.

on ctrl-j of sch-sum in frame {&frame-name}
do:
  run proc-find-sum in this-procedure(input frame {&frame-name} sch-sum).
end.
on return of sch-sum in frame {&frame-name}
do:
  run proc-find-sum in this-procedure(input frame {&frame-name} sch-sum).
  return no-apply.
end.

on ctrl-j of sch-order in frame {&frame-name} /* дате */
do:
  run proc-find-order in this-procedure(yes, input frame {&frame-name} sch-order).
end.
on return of sch-order in frame {&frame-name} /* дате */
DO:
  run proc-find-order in this-procedure(no, input frame {&frame-name} sch-order).
  return no-apply.
END.


ON CHOOSE OF b-close-new IN FRAME {&frame-name} /* Закр */
DO:
define variable v-err as logical no-undo .
define variable v-recid as recid no-undo .

if not available t-doc then return.
v-recid = recid(t-doc) .
run str/fl-cls.p ( input parParentProc ,
                   input  t-doc.doc-code ,
                   output v-err ) .
if v-err = false then return .

if t-doc.status_ = {&wayb} and t-doc.flag_  = false  then do:
   run proc-close no-error .
   if error-status :error then return no-apply.
end.
else do:
   if t-doc.status_ = {&inquiry} and  t-doc.flag_  = false  then do:
       run proc-close-zapr no-error.
       if error-status:error then return no-apply.
   end.
   else do:
    { gbl/int-clos.i
      parparentproc
      t-doc.doc-code
      gds-list
      no-error }
      {&browse-name}:refresh() in frame {&frame-name}.
   end.
end.

find t-doc where recid (t-doc) = v-recid no-lock.
run UI-on ("open").
reposition {&browse-name} to recid v-recid no-error.
END.

on choose of b-add in frame {&frame-name} /* Добав */
do:
define variable  v-recid as recid no-undo .
  run local-add in this-procedure no-error.
  v-recid = pardoc-rec.
  if pardoc-rec <> ? then do:
    run UI-on ("open").
    reposition {&browse-name} to recid v-recid no-error.
  end.
end.

ON CHOOSE OF b-chg IN FRAME {&frame-name} /* Изм */
DO:
  run proc-b-chg in this-procedure.
END.

ON CHOOSE OF b-del IN FRAME {&frame-name} /* Удал */ DO:
  run proc-b-del no-error .
  if error-status :error then return no-apply.
  run UI-on ("open").
end.


on choose of b-sch in frame {&frame-name} do:
  run proc-b-sch in this-procedure.
end.

ON CHOOSE OF b-akt IN FRAME {&frame-name} /* Просмотр авт переоценки */
DO:
  run proc-b-akt no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF b-lkp IN FRAME {&frame-name} /* Просмотр */
DO:
  run proc-b-lkp no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF b-print IN FRAME {&frame-name} /* {&print} */
DO:
  run proc-b-print no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF b-bc IN FRAME {&frame-name} /* Бар-код */
DO:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  assign
    doc-rec    = recid (t-doc)
    pardoc-rec = recid (t-doc)
  .
  run rep/tick-doc.p (parParentProc, doc-rec, "trn", 1, no, no).
  apply "entry" to br-docs in frame {&frame-name}.
END.



ON CHOOSE OF b-ext IN FRAME {&frame-name} /* Запуск внешней программы */
DO:
  run proc-b-ext no-error .
  if error-status :error then return no-apply.
END.

ON CHOOSE OF b-rep IN FRAME {&frame-name} /* {&reports} */
DO:
  if choice = ? then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
END.
on choose of b-exp in frame {&frame-name} /* Экспорт */
do:
  run local-export.
end.

ON CHOOSE OF b-sel IN FRAME {&frame-name} /* {&choose} */
DO:
 run local-sel in this-procedure.
END.

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Выход */
DO:
  assign
    doc-rec = ?
    pardoc-rec = ?
  .
END.

on entry of ed-notes in frame {&frame-name}
do:
  run entry-notes in this-procedure.
end.

on leave of ed-notes in frame {&frame-name}
do:
  run local-notes.
end.

on return, mouse-select-dblclick of ed-notes in frame {&frame-name} do:
  apply "entry" to br-docs in frame {&frame-name}.
  return no-apply.
end.

on return, mouse-select-dblclick of br-docs in frame {&frame-name} do:
  apply "choose" to b-lkp in frame {&frame-name}.
end.

on value-changed of br-docs do:
  run local-value-changed.
end.

{ str/trn-clos.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-open }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }


sch-code   :TOOLTIP = "Поиск по началу номера документа".
sch-date   :TOOLTIP = "Поиск по дате создания документа".
sch-order  :TOOLTIP = "Поиск по дате заказа".
sch-fact   :TOOLTIP = "Поиск по дате закрытия док-та на факт".
sch-objtype:TOOLTIP = "Поиск по типу контрагента".
sch-objcode:TOOLTIP = "Поиск по номеру контрагента ".
sch-sum    :TOOLTIP = "Поиск по сумме".
sch-num    :TOOLTIP = "Поиск по началу номера документа".

main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:
  run local-conf-rd    in this-procedure.
  run local-enable     in this-procedure.

run UI-on ("open").
{ gbl/mv-clmn.i
 &ext-col = 37
 &frame-name = "{&frame-name}"
 &browse-name = "{&browse-name}"
 &table-name = "t-doc"
 &start-column = 6
}
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.
end.

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
define  input param fnc as char no-undo.
assign {&sort-clmn_32-br-dtl}:read-only in browse {&browse-name} = yes.
hide b-close in frame {&frame-name} .
/* ------------------------------------------------------------------------------------------------------------ */
if fnc = "open" then do:
  frame {&frame-name}:title = "ВСЕ  заказы на исполнение".
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
else
assign
  doc-rec = ?
  pardoc-rec = ?
.

if lookup (list-mode , {&is-flor} + ","  + {&is-flor} + {&g___object} + ","  + {&is-flor} + {&status}   )  > 0 then do:
  run enb-1 (fnc).
end.
else message "Неверный вызов процедуры all-docf.w" .


if fnc <> "open"   and
   available t-d-b then do:
  assign
    doc-rec = recid (t-d-b)
    pardoc-rec = recid (t-d-b).
end.
run openbr( yes, no, '':U, fnc).
end procedure.

PROCEDURE local-mark:
  if not available t-doc then do:
    message "Неправильный выбор строки.".
    return error.
  end.
  { gbl/markstrn.i t-doc mark-list }
  {&browse-name}:refresh() in frame {&frame-name}.
END PROCEDURE.

procedure proc-b-sch :
assign
  tbl      = 'trn-doc'
  join-tbl = 't-doc'
  fld      = ""
  lab      = ""
  spr      = ""
  dim      = '0'
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
run fltfield-add in this-procedure('ext-doc-type', 'Расширенный тип', 'ext-doc-type',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rsrv-date', 'Дата резервирования', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
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
run fltfield-add in this-procedure('creid', 'Создал', '',
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
run fltfield-add in this-procedure('PS', 'Примечание', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('purch-code', 'Тип приобретения', 'purch-code',
                                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flora-order-date', 'Дата заказа БУКЕТЫ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flora-pay-date', 'Оплата заказа БУКЕТЫ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
   ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
   ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( parParentProc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
RUN OpenBr( yes, no, '':U, 'open':U).
END. /* Filter-Block */
end procedure.

procedure OpenBr :
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.


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

assign
  parschdoc-code  = (if available sch-inv  then sch-inv.doc-code   else ?)
  parschcurr-code = (if available sch-curr then sch-curr.curr-code else ?)
  parschobj-code  = (if available sch-pay  then sch-pay.obj-code   else ?)
  parschcli-type  = (if available sch-cli  then sch-cli.obj-type   else ?)
  parschcli-code  = (if available sch-cli  then sch-cli.obj-code   else ?)
.

&scop flt-open-open-query open query br-docs for each t-doc  use-index obj-date

&scop flt-open-dyn_open-query  FOR EACH t-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name t-doc

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-debug-file

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name t-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer t-doc for ub.trn-doc.


define variable l-open-query as logical   no-undo .
      run modes-3 (
        p-open-query     ,
        p-find-next      ,
        p-find-condition ,
        fnc
        ).

if doc-rec <> ? then do:
  if fnc <> "open" then do:
    assign sch-num = sch-num + 1.
    disp sch-num with frame {&frame-name}.
  end.
  reposition br-docs to recid doc-rec no-error.

end.
else do:
  if fnc <> "open" then do:
    message "Документ не найден.".
    assign sch-num = 0.
  end.
end.


run waitfram-hide in this-procedure .
apply "value-changed" to br-docs in frame {&frame-name}.
apply "entry" to br-docs.

end procedure.

procedure modes-3:
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
    case list-mode :
      /* ---------------------------------------------------------------------------------------------------------------- */
      when {&is-flor} then do:
        if fnc = "open" then do:
          assign
          frame {&frame-name}:title = "Заказы на исполнение ВСЕ " .
          assign
           filter-point = "Заказы на исполнение".
          { gbl/fltopend.i
            &where-cond = " t-doc.is-flora = yes  "
            &dyn_where-cond = " 't-doc.is-flora = yes'  "
            &use-ind    = " "
          }
        end.
      end.

      when {&is-flor} + {&g___object} then do:
        if fnc = "open" then do:
          assign
            frame {&frame-name}:title = "Заказы на исполнение  по " + v-cntxt-obj-type + " " + string (v-cntxt-obj-code)
            objects = 2
            .
          assign
            filter-point = list-mode.
          { gbl/fltopend.i
            &where-cond = "t-doc.is-flora = yes
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code
                       and t-doc.status_ <> '{&bef-ready}'
                       and t-doc.status_ <> '{&bef-rejected}'  "
            &dyn_where-cond = " ~
            substitute('  ~
                  t-doc.is-flora = yes ~
              and t-doc.obj-type = &1&2&1 ~
              and t-doc.obj-code = &3    ~
              and t-doc.status_ <> &1&4&1 ~
              and t-doc.status_ <> &1&5&1 ~
               ', ~{&double-quote~}, v-cntxt-obj-type , v-cntxt-obj-code ,~{&ready~} ,~{&rejected~} ) ~
                "
            &use-ind = " "
          }
        end.
      end.

      when {&is-flor} + {&status} then do:
        if fnc = "open" then do:
          assign
            frame {&frame-name}:title = "Заказы на исполнение  по " + v-cntxt-obj-type + " " + string (v-cntxt-obj-code) + "  Статус : " + g#stat
            objects = 2
            .
          assign
            filter-point = list-mode.
          { gbl/fltopend.i
            &where-cond = "t-doc.is-flora = yes
                       and t-doc.status_ = g#stat
                       and t-doc.obj-type = v-cntxt-obj-type
                       and t-doc.obj-code = v-cntxt-obj-code  "
            &dyn_where-cond = " ~
            substitute('  ~
                  t-doc.is-flora = yes ~
              and t-doc.obj-type = &1&2&1 ~
              and t-doc.obj-code = &3    ~
              and t-doc.status_ = &1&4&1 ~
               ', ~{&double-quote~}, v-cntxt-obj-type , v-cntxt-obj-code ,  g#stat ) ~
                "

            &use-ind = " "
          }
        end.
      end.
      otherwise do:
        message "ошибка!" list-mode  view-as alert-box error .
      end.
    end case.

if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.

end procedure.

PROCEDURE enb-1 :
define  input param fnc as char no-undo.
  if fnc = "open" then do:
      enable b-chg b-del b-add b-close-new b-open  WITH FRAME {&frame-name}.
  end.
end procedure.

PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.inkas.inkas-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'' @ sch-objtype
'' @ sch-objcode
'' @ sch-sum
'' @ sch-order
with frame {&frame-name}.
assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input par-next  /* p-find-next  */
  ,input substitute("and t-doc.doc-code   begins &1 ", pardoc-code)
  ,input "open"
  ).
apply "entry":u to sch-code in frame {&frame-name} .
end procedure.

procedure proc-find-date :
/*------------------------------------------------------------------------------
  purpose:
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define input parameter parwhat-date as character no-undo.

define variable var-datechr as character no-undo.
display
'':u @ sch-code
'':u @ sch-objcode
'':u @ sch-objtype
'':u @ sch-sum
'':u @ sch-order
with frame {&frame-name}.

assign
var-datechr = string(day(par-date)) + {&slash-char} +
               string(month(par-date)) + {&slash-char} +

              string(year(par-date)).

case parwhat-date:
  when "doc-date":u then do:
    display
    "  /  /":u @ sch-fact
    with frame {&frame-name}.
    run openbr in this-procedure
    (input false /* p-open-query */
    ,input true  /* p-find-next  */
    ,input substitute("and t-doc.doc-date = &1 "
      , var-datechr)
    , "open"
    ).
    apply "entry":u to sch-date in frame {&frame-name}.
  end.
  when "fact-date":u then do:
    display
    "  /  /":u @ sch-date
    with frame {&frame-name}.
    run openbr in this-procedure
      (input false /* p-open-query */
      ,input true  /* p-find-next  */
      ,input substitute("and t-doc.fact-date = &1 "
      , var-datechr)
      , "open"
      ).
    apply "entry":u to sch-fact in frame {&frame-name}.
  end.

end.

end procedure.
PROCEDURE proc-find-cli :
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
display
'':u @ sch-code
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'':u  @ sch-sum
'':u  @ sch-order
with frame {&frame-name}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input yes  /* p-find-next  */
  ,input substitute("and t-doc.cli-type = '&1' and t-doc.cli-code = &2", parcli-type, parcli-code)
  ,input "open"
  ) no-error .

apply "entry":u to sch-objtype in frame {&frame-name} .
end procedure.
PROCEDURE proc-find-sum :
define input parameter parsum as decimal no-undo.
display
'':u @ sch-code
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'':u @ sch-objtype
'':u @ sch-objcode
with frame {&frame-name}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input yes  /* p-find-next  */
  ,input substitute("and (t-doc.print-rubl = yes and round(t-doc.tot-sale, 2) = &1 or t-doc.print-rubl = no and round(t-doc.tot-fact, 2) = &1)", parsum)
  ,input "open"
  ).
apply "entry":u to sch-sum in frame {&frame-name} .
end procedure.

procedure proc-find-order :
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define variable v-recid     as recid     no-undo .
define variable var-datechr as character no-undo .
var-datechr = string(day(par-date)) + {&slash-char} +
              string(month(par-date)) + {&slash-char} +
              string(year(par-date)).

display
'':u @ sch-code
'':u @ sch-objcode
'':u @ sch-objtype
'':u @ sch-sum
'':u @ sch-date
'':u @ sch-fact
with frame {&frame-name}.
    run openbr in this-procedure
      (input false /* p-open-query */
      ,input true  /* p-find-next  */
      ,input substitute(" and t-doc.flora-order-date = &1 "
      , var-datechr)
      , "open"
      ).
    apply "entry":u to sch-order in frame {&frame-name}.

end procedure.


PROCEDURE set-filter-name :
  define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end. /* do with frame */
END PROCEDURE.
procedure local-add:
define buffer bf_clients for ub.clients.
define buffer bf_sysconf for ub.sysconf.
define variable varis-active as logical no-undo.
define variable v-dead-doc   as character initial no no-undo.
define variable v-type       as character initial ? no-undo.
{ gbl/conf-rd.i
  "'dead-doc'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-dead-doc
  v-type
  no-error
}
if  error-status :error  = false then do:
    if v-dead-doc = "yes"  then  do:
      message "В системе установлен запрет на ввод документов!"
      view-as alert-box error .
      return error  .
    end.
end.


/*doc-mode = {&add-def}. */

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_expense_preparation':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  0
  0
  0
  true
  v-log
}



if not v-log then return error.

  if g#stat = ? then do:
    if (v-cntxt-db-num-obj = v-cntxt-db-num) or
       not (v-cntxt-db-num-obj <> 0) then do:
      assign
        g#stat = {&inquiry}.
    end.
    else do:
      assign
        g#stat = {&inquiry}.
    end.
  end.
  if g#stat = {&inquiry} then do:
    v-log = yes.
    message "Внимание !  Создаю новый ЗАПРОС !" skip (2)
                    "Продолжать ?" view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then return no-apply.
    run str/out-doc.w (
         input         parparentproc
       , input-output  pardoc-rec
       , input         {&add-def}
       , input         list-mode
       , input         {&expense}
       , input         false
       , input-output next-prev
       , input        {&TDEDT_Ras_Vnesh}
       , input        false
       , input-output line-rec
       , input (br-docs:handle in frame {&frame-name})
       , input (buffer t-doc :handle in frame {&frame-name} )
       , input        g#stat
       ).
  end.
  else do:
    message "Добавление нового документа не работает в этом списке" view-as alert-box information .
    return no-apply.
  end.

if doc-rec = ? then do:
  return error.
end.
run UI-on ("open").
end procedure.



procedure proc-b-del :
do on error undo, return error return-value :
define variable del-rec          as recid     no-undo.  /* recid for reposition */
define variable unrv-qnty        as decimal   no-undo.  /* количество из gds-dtl, по которому снимаются резервы перед удалением */
define variable varmes           as character no-undo.
define variable v-user-action    as character no-undo.
define variable v-printed        as logical   no-undo.
define variable varchip-num-main as integer   no-undo.
define variable varchip-num      as integer   no-undo.
define buffer bf-acp_trn-doc for ub.trn-doc.
define buffer bf-pri_trn-doc for ub.trn-doc.
define buffer bf-vzv_trn-doc for ub.trn-doc.
define buffer bf_clients     for ub.clients.
define buffer bf-c_clients   for ub.clients.
define variable vardel-rec as recid no-undo.
define variable vardel-doc-code like ub.trn-doc.doc-code no-undo.
{&net-del}
if can-do ({&wayb_inquiry}, t-doc.status_) and t-doc.flag_ then do:
    v-log = no.
    message "Редактирование документа уже закончено. Вы уверены, что хотите удалить его?"
                    view-as alert-box question buttons OK-Cancel update v-log.
    {&if-not-true}
end.
else do:
  if t-doc.status_ = {&fact} then do:
    assign
    v-log = no.
    message "Документ закрыт на 'ФАКТ'." skip
            "Удаление документа повлечет за собой пересчет данных, связанных с данным документом."
            "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update v-log.
    {&if-not-true}
  end.
  else do:
    assign
    v-log = no.
    message "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update v-log.
    {&if-not-true}
  end.
end.

br-handle = br-docs:handle in frame {&frame-name} .
assign
  vardel-rec = recid (t-doc).
if valid-handle (br-handle) then do:
  v-log = br-handle:select-next-row().
  if not v-log then v-log = br-handle:select-prev-row().
  assign
    doc-rec    = recid(t-doc)
    pardoc-rec = recid(t-doc)
  .
end.
if search ("del-doc.err") <> ? then do:
  os-delete "del-doc.err".
end.
assign
  varchip-num-main = next-value (s-corr-chip, {&db-name_schema}).
find first t-doc where recid(t-doc) = vardel-rec.


/* Для жесткости */
define buffer bufd_doc-line for ub.doc-line  .
define buffer bufd_gds-dtl  for ub.gds-dtl   .

if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
   t-doc.status_      = {&wayb}            and
   t-doc.flag_        = false           then do:
   { str/delnabor.i
     parParentProc
     t-doc.doc-code
     no-error }
end.

assign
  vardel-doc-code = t-doc.doc-code.
if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} and
   t-doc.status_      = {&fact}            then do:
  find first bf_clients where bf_clients.obj-type = t-doc.obj-type and
                              bf_clients.obj-code = t-doc.obj-code no-lock.
  find first bf-c_clients where bf-c_clients.obj-type = t-doc.cli-type and
                                bf-c_clients.obj-code = t-doc.cli-code no-lock.
  if bf_clients.db-num <> bf-c_clients.db-num then do:
    message substitute("Во внутреннем документе &1 по объекту &2 &3 базы данных &4 контрагентом является объект &5 &6 базы данных &7. Нельзя удалять внутренние документы относящиеся к разным базам данных.",
                            t-doc.doc-code,
                            t-doc.obj-type,
                            t-doc.obj-code,
                            bf_clients.db-num,
                            t-doc.cli-type,
                            t-doc.cli-code,
                            bf-c_clients.db-num
                            ) view-as alert-box error.
    return error.
  end.

  find first bf-pri_trn-doc where bf-pri_trn-doc.out-code     = t-doc.doc-code     and
                                  bf-pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} exclusive-lock.
  if bf-pri_trn-doc.status_ = {&fact} then do:
    find first bf-vzv_trn-doc where bf-vzv_trn-doc.out-code     = bf-pri_trn-doc.doc-code and
                                    bf-vzv_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}  exclusive-lock no-error.
    if available bf-vzv_trn-doc then do:
      if bf-vzv_trn-doc.status_ = {&fact} then do:
        run str/del-doc.p
          ( input parParentProc,
            input bf-vzv_trn-doc.doc-code,
            input v-cntxt-db-num,
            input "del-doc.err",
            input ?,
            input ?,
            input v-cntxt-userid,
            input 0,
            input  varchip-num-main,
            output varchip-num )
          no-error.
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа возврата." skip
            return-value skip
            trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            view-as alert-box error.
          if search ("del-doc.err") <> ? then do:
            run gbl/prnfilen.w
              (input  "Ошибки при удалении документа"
              ,input  0
              ,input  "del-doc.err"
              ,input  7
              ,output v-user-action
              ,output v-printed
              ).
          end.
          return error.
        end.
      end.
      else do:
        message "Имеется открытый документ внутреннего возврата по данному внутреннему расходу." skip
                "Номер документа: " bf-vzv_trn-doc.doc-code skip
        view-as alert-box error.
        return error.
      end.
    end.
    run str/del-doc.p
      ( input parParentProc,
        input  bf-pri_trn-doc.doc-code,
        input  v-cntxt-db-num,
        input  "del-doc.err",
        input  ?,
        input  ?,
        input  v-cntxt-userid,
        input  0,
        input  varchip-num-main,
        output varchip-num )
      no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении документа прихода." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        view-as alert-box error.
      if search ("del-doc.err") <> ? then do:
        run gbl/prnfilen.w
          (input  "Ошибки при удалении документа"
          ,input  0
          ,input  "del-doc.err"
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
      return error.
    end.
  end.
  else do:
    message "Имеется открытый документ внутреннего прихода по данному внутреннему расходу." skip
            "Номер документа: " bf-pri_trn-doc.doc-code skip
    view-as alert-box error.
    return error.
  end.
end.

run str/del-doc.p
  ( input parParentProc,
    input  t-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  0,
    input  varchip-num-main,
    output varchip-num )
no-error.
if error-status:error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при удалении документа." skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  if search ("del-doc.err") <> ? then do:
    run gbl/prnfilen.w
      (input  "Ошибки при удалении документа"
      ,input  0
      ,input  "del-doc.err"
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
  end.
  return error.
end.
find first bf-acp_trn-doc where bf-acp_trn-doc.out-code     = vardel-doc-code         and
                                bf-acp_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} no-lock no-error.
if available bf-acp_trn-doc then do:
  run str/del-doc.p
  ( input parParentProc,
    input  bf-acp_trn-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  vardel-doc-code,
    input  varchip-num-main,
    output varchip-num )
  no-error.
  if error-status:error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при удалении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       trim(error-status :get-message(2))
       trim(error-status :get-message(3))
       trim(error-status :get-message(4))
       trim(error-status :get-message(5)) skip
       view-as alert-box error.
     if search ("del-doc.err") <> ? then do:
       run gbl/prnfilen.w
         (input  "Ошибки при удалении документа"
         ,input  0
         ,input  "del-doc.err"
         ,input 7
         ,output v-user-action
         ,output v-printed
         ).
     end.
     return error.
  end.
end.
find first bf-acp_trn-doc where bf-acp_trn-doc.out-code     = vardel-doc-code           and
                                bf-acp_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} no-lock no-error.
if available bf-acp_trn-doc then do:
  run str/del-doc.p
  ( input parParentProc,
    input  bf-acp_trn-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  vardel-doc-code,
    input  varchip-num-main,
    output varchip-num )
  no-error.
  if error-status:error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при удалении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       trim(error-status :get-message(2))
       trim(error-status :get-message(3))
       trim(error-status :get-message(4))
       trim(error-status :get-message(5)) skip
       view-as alert-box error.
     if search ("del-doc.err") <> ? then do:
       run gbl/prnfilen.w
         (input  "Ошибки при удалении документа"
         ,input  0
         ,input  "del-doc.err"
         ,input 7
         ,output v-user-action
         ,output v-printed
         ).
     end.
     return error.
  end.
end.


end. /* do */
end procedure. /* proc-b-del */


procedure proc-b-ext :
 do
 on error undo, return error return-value
 :
    define variable v-list-index     as integer           no-undo.
    define variable v-trn-doc-recid  as recid             no-undo.

    for each temp_recid-list
    :
        delete temp_recid-list.
    end.
    if available t-doc
    then do:
        assign
            v-trn-doc-recid = recid( t-doc )
            v-nn = num-entries( mark-list )
        .
        do v-list-index = 1 to v-nn :
            create temp_recid-list .
            assign
                temp_recid-list.string-trn-doc-recid = entry( v-list-index, mark-list )
            .
        end.
    end.
    else do:
        assign
            v-trn-doc-recid = 0
        .
    end.
    run str/run-ext.p ( input v-trn-doc-recid
                  , input table temp_recid-list
                  , input {&documents}
                  , input ""
                  , output v-ext-button-label
                  ) no-error.
    if error-status :error
    then do:
        /* Ошибка при выполнении внешней программы или нет прав */
        return error .
    end.


 end. /* do */
end procedure. /* proc-b-ext */



procedure proc-b-chg :
define variable varrecid as recid no-undo.
 do
 on error undo, return error return-value
 :
{&net-proc}

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_expense_preparation':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  v-log
}

{&if-not-true}
  /*doc-mode = {&update} */
  /*пересчитаем запрос */

if t-doc.status_ = {&inquiry} then do:
  run gbl/calc-trn.p (input parParentProc, input recid(t-doc)).
  assign
    varrecid = recid(t-doc).
  run str/out-doc.w (
         input         parparentproc
       , input-output  varrecid
       , input         {&update}
       , input         list-mode
       , input         {&expense}
       , input         false
       , input-output  next-prev
       , input         {&TDEDT_Ras_Vnesh}
       , input         false
       , input-output  line-rec
       , input         br-handle
       , input (buffer t-doc :handle in frame {&frame-name} )
       , input         t-doc.status_
       ).

end.
else
run str/out-docf.w (
      input parParentProc ,
      input {&update} ,
      input t-doc.status_ ,
      input (br-docs:handle in frame {&frame-name}) ,
      input (buffer t-doc :handle in frame {&frame-name} )
      ).

apply "entry" to br-docs in frame {&frame-name}.
if error-status:error then do:
  find t-doc where recid (t-doc) = doc-rec no-lock.  /* буфер ломается при return error */
  return error.
end.
else run UI-on ("open").


 end. /* do */
end procedure. /* proc-b-chg */



procedure proc-b-akt :
 do
 on error undo, return error return-value
 :
next-prev = no.
br-handle = br-docs:handle in frame {&frame-name} .
do while next-prev <> ?:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return error.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_lookup':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    v-log
  }

  if not v-log then return no-apply.
  assign
    doc-rec = recid (t-doc)
    pardoc-rec = recid (t-doc)
  .
  bf-handle = buffer t-doc:handle in frame {&frame-name} .
   run str/trn-pr.w
     (input parparentproc ,
      input recid(t-doc) ,
      input {&lookup} ,
      input-output next-prev ,
      input ? ,
      input ? ,
      input ? ,
      input br-handle ,
      input bf-handle)
      no-error .
end.
if br-handle = ? then reposition br-docs to recid doc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "iteration-changed" to br-docs in frame {&frame-name}.


 end. /* do */
end procedure. /* proc-b-akt */



procedure proc-b-lkp :
 do
 on error undo, return error return-value
 :

next-prev = no.
br-handle = br-docs:handle  in frame {&frame-name} .
do while next-prev <> ?:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return error.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_expense_lookup':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    v-log
  }
  if not v-log then
    return error.
    assign
      doc-rec    = recid (t-doc)
      pardoc-rec = recid (t-doc)
    .
    /*doc-mode = {&lookup}*/
    if t-doc.status_ = {&inquiry} then
            run str/out-doc.w  (
                input         parparentproc
              , input-output  doc-rec
              , input         {&lookup}
              , input         list-mode
              , input         {&expense}
              , input         false
              , input-output  next-prev
              , input         {&TDEDT_Ras_Vnesh}
              , input         false
              , input-output  line-rec
              , input (br-docs:handle in frame {&frame-name})
              , input (buffer t-doc :handle in frame {&frame-name} )
              , input         t-doc.status_
              ).

    else    run str/out-docf.w
                  ( input parParentProc ,
                    input {&lookup} ,
                    input t-doc.status_ ,
                    input (br-docs:handle in frame {&frame-name}) ,
                    input (buffer t-doc:handle in frame {&frame-name} )
                    ) .
end.
if br-handle = ? then reposition br-docs to recid doc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "iteration-changed" to br-docs in frame {&frame-name}.


 end. /* do */
end procedure. /* proc-b-lkp */



procedure proc-b-print :
 do
 on error undo, return error return-value
 :

if not available t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
assign
  pardoc-rec = recid (t-doc)
  doc-rec    = recid (t-doc)
.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_expense_print':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  v-log
}
if not v-log then return no-apply.
find t-doc where recid (t-doc) = doc-rec .
run rep/doc-prn.p (
      input parParentProc
    , input this-procedure
    , input doc-rec
).
apply "entry" to br-docs in frame {&frame-name}.

 end. /* do */
end procedure. /* proc-b-print */


procedure local-export :
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
run str/xml-doc.p (input t-doc.doc-code, input ?) no-error .
if error-status :error
then do:
  if error-status :get-message(1) <> ""
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы xml-doc.p" skip
      error-status :get-message(1) skip
      return-value
      view-as alert-box error .
  end.
  else do:
    message
      return-value
      view-as alert-box information .
  end.
  return no-apply .
end.
define variable v-sys-key   as character         no-undo.
{ gbl/currsysk.i
  v-sys-key
  no-error
}
assign
v-file-name =  str-encode ( replace(t-doc.doc-code , "*", "$") /*p-init-string*/
                          , "" /*p-encode-char    */
                          , {&file-name-invalid-char}  /* p-special-char-list */
                          ) + ".xml".
if search ("xml-doc.bat") <> ? then do:
  os-command silent value(search ("xml-doc.bat") + {&space-char} + {&double-quote} +  v-file-name + {&double-quote} + {&space-char} + v-sys-key + {&space-char} + v-cntxt-userid ).
end.
else do:
  if search (v-file-name ) <> ? then do:
    message
    substitute("Документ выгружен в файл &1"
               ,v-file-name
               )
    view-as alert-box.
  end.
end.
end procedure.
procedure entry-notes :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
assign
  pardoc-rec = recid (t-doc)
  doc-rec    = recid (t-doc)
.
if t-doc.status_ <> {&fact} and t-doc.discnt-type <> {&cash-desk} and substring (t-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
end.
procedure local-notes:
do on stop undo, return no-apply:
  find t-d-b where recid (t-d-b) = doc-rec exclusive no-error no-wait.
  if not available t-d-b then do:
     message "Запись захвачена другим пользователем." skip
             "Редактирование запрещено."
     view-as alert-box.
  end.
  else t-d-b.PS = input frame {&frame-name} ed-notes.
end.
end procedure.
procedure local-value-changed :
if available t-doc then do:
  find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = t-doc.boss no-lock no-error.
  if available cli-buf then boss-name = cli-buf.obj-name. else boss-name = ?.
  find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = t-doc.agnt no-lock no-error.
  if available cli-buf then agnt-name = cli-buf.obj-name. else agnt-name = ?.
  find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = t-doc.wrkr no-lock no-error.
  if available cli-buf then wrkr-name = cli-buf.obj-name. else wrkr-name = ?.
  { gbl/usrfulnm.i
    t-doc.creid
    v-user-name }

  find ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock no-error.
  if available ub.pay-type then disp ub.pay-type.obj-name with frame {&frame-name}.
  else disp ? @ ub.pay-type.obj-name with frame {&frame-name}.
  ed-notes = t-doc.PS.
  find cli-buf where cli-buf.obj-type = t-doc.obj-type and cli-buf.obj-code = t-doc.obj-code no-lock no-error.
  if available cli-buf then obj-name = cli-buf.obj-name. else obj-name = ?.
  display ed-notes obj-name boss-name agnt-name wrkr-name v-user-name with frame {&frame-name}.
  if doc-rec <> recid (t-doc) then do:
    sch-num = 0.
    hide sch-num in frame {&frame-name}.
  end.
end.
end procedure.
procedure local-sel :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
if mark-list <> "" then do:
  assign
    pardoc-rec = recid (t-doc)
    doc-rec = recid (t-doc)
  .
end.
else do:
  assign
    mark-list = string(recid(t-doc))
    pardoc-rec = recid (t-doc)
    doc-rec = recid (t-doc)
    .
end.
apply "go" to frame {&frame-name}.
end procedure.


procedure local-conf-rd:
define buffer bf_clients for ub.clients.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.
{ gbl/conf-rd.i
  "'holding'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  varhold
  varhold-type
  no-error
}

{ gbl/currsysk.i
  v-sys-key
  no-error
}

if v-cntxt-obj-type <> "" and
   v-cntxt-obj-code <> 0  then do:
  find first bf_clients where bf_clients.obj-type = v-cntxt-obj-type and
                              bf_clients.obj-code = v-cntxt-obj-code no-lock.
  if bf_clients.obj-type = {&shop} then do:
    find first bf_shop where bf_shop.obj-code = bf_clients.obj-code no-lock.
    assign
      v_shift = string(bf_shop.shift-on).
  end.
  else do:
    find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock.
    assign
      v_shift = string(bf_store.shift-on).
  end.
end.
else do:
  assign
    v_shift = "no":u.
end.
end procedure.


procedure local-enable :
ENABLE
b-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
b-quit b-lkp b-print b-exp b-sch b-help br-docs b-rep sch-code sch-date sch-order sch-fact sch-objtype sch-objcode sch-sum ed-notes
WITH FRAME {&frame-name}.

hide b-akt in frame {&frame-name} .

if v-cntxt-obj-type = {&stock} or v-cntxt-obj-type = {&shop}  then do:
  enable b-bc WITH FRAME {&frame-name}.
end.

/*---START--------- Проверка, нужна ли кнопка для внешней программы. Если нужна, включаем b-ext ---------------------*/
run str/run-ext.p ( input ?
                , input table temp_recid-list
                , input {&documents}
                , input "init"
                , output v-ext-button-label
                ) no-error.
if error-status :error
then do:        /* Не выводим кнопку, ошибка при инициализации или нет прав */
    assign
        b-ext :visible   = no
    .
end.
else do:
    assign
        b-ext :label     = v-ext-button-label
        b-ext :visible   = yes
        b-ext :sensitive = yes
    .
end.
end procedure.

procedure proc-close :

  do
  on error undo, return error return-value
  :
  define variable v-close-type as integer   no-undo .
  define variable varchg-inv as logical   no-undo .

            run gbl/d-askw.w
              (input "Вопрос" /* Заголовок окна */
              ,input "Закрытие запроса на исполнение" + {&new-line} /* Общее сообщение */
                + substitute("РН        &1", t-doc.doc-code) + {&new-line}
                + substitute("Дата      &1", string(t-doc.doc-date, '99/99/9999':u)) + {&new-line}
                + (if t-doc.fact-date <> ? then substitute("Факт дата &1", string(t-doc.fact-date, '99/99/9999':u)) else "") + {&new-line}
                + substitute("Оператор  &1", t-doc.user-name)
              ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                          /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                          /* второй символ - разделитель атрибутов в описании кнопок */
              ,input "Разр+" + '|':u
                  + "Факт+" + '|':u
                  + "Отмена" /* список названий кнопок  */
                              /* каждая кнопка может иметь необязательный */
                              /* список атрибутов, влияющих на поведение кнопки */
              ,input "Возможно открыть заказ на корректировку до накл- и изменить фактическое количество в разр+|" /* список описаний кнопок */
                  + "Закрыть заказ без возможности корректировки |"
                  + "Отмена закрытия заказа на исполнение"
              ,input 1 /* значение возвращаемое при нажатии enter */
              ,input 3 /* значение возвращаемое при нажатии escape */
              ,output v-close-type /* выбор пользователя */
              ).
            case v-close-type
            :
              when 1
              then do:
                    { gbl/chk-actg.i
                      v-cntxt-db-num
                      v-cntxt-userid
                      {&action-head-code-main}
                      'actn_expense_preparation':U
                      {&cntxt-object}
                      t-doc.host-code
                      t-doc.obj-type
                      t-doc.obj-code
                      0
                      0
                      0
                      true
                      v-log
                    }

                  { gbl/int-clos.i
                    parparentproc
                    t-doc.doc-code
                    gds-list
                    no-error }
                    {&browse-name}:refresh() in frame {&frame-name}.
                    if error-status:error then do:
                      find t-doc where recid (t-doc) = doc-rec no-lock.
                      return error.
                    end.
                    if t-doc.status_ = {&wayb} and t-doc.flag_ = true then do:
                            run str/trn-stat.p (input parParentProc,
                                            input this-procedure ,
                                            input  {&close-doc},
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             {&browse-name}:refresh() in frame {&frame-name}.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.
              end.
              when 2
              then do:
                    { gbl/chk-actg.i
                      v-cntxt-db-num
                      v-cntxt-userid
                      {&action-head-code-main}
                      'actn_expense_fact':U
                      {&cntxt-object}
                      t-doc.host-code
                      t-doc.obj-type
                      t-doc.obj-code
                      0
                      0
                      0
                      true
                      v-log
                    }
                    if t-doc.status_ = {&wayb} and t-doc.flag_ = false then do:
                      { gbl/int-clos.i
                        parparentproc
                        t-doc.doc-code
                        gds-list
                        no-error }
                        {&browse-name}:refresh() in frame {&frame-name}.
                        if error-status:error then do:
                          find t-doc where recid (t-doc) = doc-rec no-lock.
                          return error.
                        end.
                    end.
                    if t-doc.status_ = {&wayb} and t-doc.flag_ = true then do:
                            run str/trn-stat.p (input parParentProc,
                                            input this-procedure ,
                                            input  {&close-doc},
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             {&browse-name}:refresh() in frame {&frame-name}.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.
                    if t-doc.status_ = {&permitted} then do:
                            run str/trn-stat.p (input parParentProc,
                            input this-procedure ,
                                            input  {&close-doc},
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.
                             {&browse-name}:refresh() in frame {&frame-name}.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.

                    end.
              end.
              when 3
              then do:
                if doc-rec <> ? then do:
                  find t-doc where recid (t-doc) = doc-rec no-lock.
                end.
                return error.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Способ закрытия накладной" skip
                  "Неизвестное значение" v-close-type skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
    if varchg-inv = yes then do:
      assign v-log = no.
      message "За время пребывания в статусе разр- было движение товаров, участвующих в инвентаризации." SKIP
      "Показать список товаров по которым было движение?"
        view-as alert-box question buttons yes-no update v-log .
      if v-log then run str/gds-list.w (input parParentProc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).

     end.
end.
end procedure. /* proc-close */

procedure proc-close-zapr :

  do
  on error undo, return error return-value
  :
  define variable v-close-type as integer   no-undo .
  define variable varchg-inv as logical   no-undo .

            run gbl/d-askw.w
              (input "Вопрос" /* Заголовок окна */
              ,input "Закрытие запроса на исполнение" + {&new-line} /* Общее сообщение */
                + substitute("РН        &1", t-doc.doc-code) + {&new-line}
                + substitute("Дата      &1", string(t-doc.doc-date, '99/99/9999':u)) + {&new-line}
                + (if t-doc.fact-date <> ? then substitute("Факт дата &1", string(t-doc.fact-date, '99/99/9999':u)) else "") + {&new-line}
                + substitute("Оператор  &1", t-doc.user-name)
              ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                          /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                          /* второй символ - разделитель атрибутов в описании кнопок */
              ,input "Запр+" + '|':u
                  + "Накл-" + '|':u
                  + "Отмена" /* список названий кнопок  */
                              /* каждая кнопка может иметь необязательный */
                              /* список атрибутов, влияющих на поведение кнопки */
              ,input "Возможно открыть заказ на корректировку |" /* список описаний кнопок */
                  + "Передать заказ флористам |"
                  + "Отмена закрытия заказа на исполнение"
              ,input 1 /* значение возвращаемое при нажатии enter */
              ,input 3 /* значение возвращаемое при нажатии escape */
              ,output v-close-type /* выбор пользователя */
              ).
            case v-close-type
            :
            when 1 then do:
                  { gbl/int-clos.i
                    parparentproc
                    t-doc.doc-code
                    gds-list
                    no-error }
                    {&browse-name}:refresh() in frame {&frame-name}.
                    if error-status:error then do:
                      find t-doc where recid (t-doc) = doc-rec no-lock.
                      return error.
                    end.
            end.
            when 2 then do:
                 { gbl/int-clos.i
                    parparentproc
                    t-doc.doc-code
                    gds-list
                    no-error }
                    {&browse-name}:refresh() in frame {&frame-name}.
                    if error-status:error then do:
                      find t-doc where recid (t-doc) = doc-rec no-lock.
                      return error.
                    end.
                    if t-doc.status_ = {&inquiry} and t-doc.flag_ = true then do:
                            run str/trn-stat.p (input parParentProc,
                                            input this-procedure ,
                                            input  {&close-doc},
                                            input  t-doc.doc-code,
                                            input  varcheck-return,
                                            input  v-cntxt-db-num,
                                            input  v-cntxp-in-ov,
                                            input  v-cntxp-rsrv-time,
                                            input  v-cntxp-load-time,
                                            input  v-cntxp-holidays,
                                            input  yes,
                                            output varchg-inv,
                                            output table gds-list) no-error.

                             {&browse-name}:refresh() in frame {&frame-name}.
                            if error-status:error then do:
                              message
                                vss-workfile vss-revision vss-description skip
                                "Ошибка при закрытии документа " t-doc.doc-code skip
                                return-value skip
                                trim(error-status :get-message(1)) skip
                                view-as alert-box error.
                              find t-doc where recid (t-doc) = doc-rec no-lock.
                              return error.
                            end.
                    end.

            end.

            end case.



  end.

end procedure. /* proc-close-zapr */

/*==========================================================================*/
procedure get-browse-buffer-handle :
define output parameter p-browse-buffer-handle      as handle           no-undo.

do
on error undo, return error
:
    assign
        p-browse-buffer-handle = buffer t-doc :handle in frame {&frame-name}
    .
end.
end procedure. /* get-browse-buffer-handle */

/*==========================================================================*/
procedure get-browse-query-handle :
define output parameter p-browse-query-handle      as handle           no-undo.

do
on error undo, return error
:
    assign
        p-browse-query-handle = query br-docs :handle in frame {&frame-name}
    .
end.
end procedure. /* get-browse-buffer-handle */

&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME