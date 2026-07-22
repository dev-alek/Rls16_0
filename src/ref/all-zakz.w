/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список Заказов

Автор: Чернова Светлана Александровна
Дата создания: 02/02/01
Author: Svetlana Chernova
Creation date: 02/02/01

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter g#type       as character no-undo .
define input  parameter g#stat       as character no-undo .
define input  parameter list-mode      as character no-undo .
define input  parameter p-doc-rec        as recid no-undo .
define input  parameter p-buttons as character no-undo .
define input  parameter p-str-recid as character no-undo .
define output parameter del-list as char no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список Заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  new }
{ str/tt-tax.i   new }
{ cmp/croslist.i }
{ cmp/strcodec.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/extclass.i }
{ cus/str-edi.i }

define new shared variable doc-rec   as recid no-undo .
define new shared variable next-prev as logical   no-undo .
DEFINE new shared VARIABLE sch-code  as character format "x(12)" view-as fill-in size 12 by 1 no-undo.
DEFINE new shared VARIABLE sch-date  as date view-as fill-in size 12 by 1 format "99/99/9999" no-undo.
DEFINE new shared VARIABLE sch-fact  as date view-as fill-in size 12 by 1 format "99/99/9999" no-undo.
define new shared variable sch-num   as integer view-as fill-in size 3 by 1 no-undo.
define new shared variable x-mode    as character  no-undo .
define new shared variable br-handle as handle no-undo.
DEFINE new SHARED BUFFER   shar-buf_ord-doc for ub.ord-doc.
DEFINE new shared QUERY    br-docs  for shar-buf_ord-doc SCROLLING.
define variable str-status-edoc-nn as character no-undo .
define variable v-color as integer no-undo init ?.
/* для жесткого фильтра по оплате */
define new shared buffer sch-pay  for ub.pay-type.
/* для жесткого фильтра по валюте */
define new shared buffer sch-curr for ub.currency.
/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
define new shared buffer sch-cli  for ub.clients.
/* для жесткого фильтра по cons */
define new shared buffer sch-cons for ub.ord-cons.
/* для жесткого фильтра по contract */
define new shared buffer sch-contract for ub.contract.
/* для списка мешающих документов по инвентаризации */
define new shared buffer sch-inv      for ub.ord-doc.

DEFINE NEW SHARED VARIABLE Sort-gr AS LOGICAL INIT false
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

DEFINE NEW Shared VARIABLE print-graft AS LOGICAL INIT true
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.


define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
if store-type = ? or store-type = "" then do:
    g#host-code = v-cntxt-host-code-obj .
    define buffer buf_clients-name for ub.clients  .
    find first buf_clients-name no-lock where buf_clients-name.obj-code =  g#host-code and
                                              buf_clients-name.obj-type = {&cmp} no-error .

   g#host-name = buf_clients-name.obj-name.
end.
else do:
  g#host-code   = v-cntxt-host-code-obj.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
{ cmp/df-sub.i pr }
end.
run get-report-num in parParentProc ( output g#report-num ).




&Scop g-type-tit ~
( if g#type = {&o-p} THEN {&o-p-full} ELSE ~
  (if g#type = {&o-f} THEN {&o-f-full} else ~
      (if g#type = {&f-p} THEN {&f-p-full} else ? )))



&Scop if-not-true ~
if not g#log then do: ~
  find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock. ~
  return no-apply. ~
end.

&Scop net-proc ~
if not available shar-buf_ord-doc then do: ~
  message "Неправильно выбран документ.". ~
  return no-apply. ~
end. ~
doc-rec = recid (shar-buf_ord-doc). ~
do on stop undo, return no-apply : ~
  find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .  /* сетевая проверка */ ~
end. ~
if shar-buf_ord-doc.status_     = {&fact} and shar-buf_ord-doc.flag_= true  then do: ~
   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock. ~
   message "Данный документ закрыт по факту .". ~
   return no-apply. ~
end.

&Scop net-proc-lkp ~
if not available shar-buf_ord-doc then do: ~
  message "Неправильно выбран документ.". ~
  return no-apply. ~
end. ~
doc-rec = recid (shar-buf_ord-doc). ~
do on stop undo, return no-apply : ~
  find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock .  /* сетевая проверка */ ~
end.

&Scop WINDOW-NAME d-all-docs
&Scop FRAME-NAME  d-all-docs
&Scop BROWSE-NAME br-docs

&scop ch-b-sost    if g#type = ~{&o-f} or g#type = ~{&o-p} then do: ~
  b-sost:tooltip in FRAME ~{&frame-name} = "Проставить статус 'Отказать' по заказу 'ОФ'". ~
  end. ~
else disable b-sost with FRAME ~{&frame-name}.


&glob send-to-news  ~
  run str/callnews.p ~
    (input "ord-doc"  ~
    ,input (buffer shar-buf_ord-doc:handle)~
    ) no-error .      ~
  if error-status:error then do: ~
    Assign shar-buf_ord-doc.flag_ = True  shar-buf_ord-doc.status_ = ~{&g___new}. ~
    Message                                                ~
      vss-workfile vss-revision vss-description skip       ~
      "Ошибка при передаче заказа в новости" skip          ~
      "Документ" shar-buf_ord-doc.doc-code skip                       ~
      view-as alert-box .                                  ~
      return no-apply.                                     ~
  end.


DEFINE BUFFER t-doc-line for ub.ord-line.
define variable pay-type as char format "x(64)" no-undo .

define buffer cli-buf for ub.clients.  /* для вывода м-ра, исп-ля, кл-ка */
define buffer t-d-b for ub.ord-doc.  /* для поиска по номеру, дате, факт */
define variable sch-field as char no-undo.
define variable mark as char no-undo.
define variable blank#name as character no-undo .
define variable  blank#name-rcv as character no-undo .
{ gbl/flt-def.i }
define variable v-fo          as   character             no-undo.

define variable old-list as char no-undo.
define variable old-stat as char no-undo.
define buffer c-in       for ub.ord-doc.
define variable chg-qnty like ub.gds-dtl.doc-qnty no-undo.
/*для вызова справочника оплат*/
define variable payment-type as char no-undo.
/*выбор отчетов */
define variable choice   as      logical no-undo    init ?.
define variable objects as integer no-undo.
define variable is-edi as logical no-undo .
define variable is-edoc-nn as logical no-undo .

define temp-table tt-ord-doc-rcv no-undo
        field nn as integer
        field gds-name like ub.goods.gds-name
        field gds-sort like ub.goods.sort
        field gds-code like ub.goods.gds-code
        field unit-cli like ub.ord-line-rcv.unit-cli
        field OKEI     as character
        field cli-art  as character
        field artic    like ub.goods.artic
        field cli-qnty like ub.ord-line-rcv.cli-qnty
        field price-cli like ub.ord-line-rcv.price-cli
        field summa   as decimal
        field cost    like ub.ord-line-rcv.price-cli
        field cli-name like ub.ord-doc.cli-name
        field cli-code like ub.ord-doc.cli-code
        field cli-type like ub.ord-doc.cli-type
        field addres1  like ub.firm.addres1
        field addres2  like ub.firm.addres2    
        index pi nn
        .

/* ----------------------------  верхний ряд батонов  -------------------------------- */

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     TOOLTIP "Выход из режима"
     SIZE 12 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     TOOLTIP "Выход из режима и выбор текущего номера  заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     TOOLTIP "Список отчетов по заказам"
     SIZE 12 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     TOOLTIP "Фильтр по списку заказов"
     SIZE 12 BY 1.

DEFINE BUTTON b-payment
     LABEL "П&латежи":L
     TOOLTIP "Платежи по документу и по контрагенту"
     SIZE 12 BY 1.

DEFINE BUTTON b-sost
     LABEL "Отказ":L
     SIZE 12 BY 1.

DEFINE BUTTON b-exec
     LABEL "Расч&ёт":L
     TOOLTIP "Функции автоматического заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 12 BY 1.

/* ----------------------------  нижний ряд батонов  -------------------------------- */

DEFINE BUTTON b-add
     LABEL "&Добавить":L
     TOOLTIP "Добавить новый заказ"
     SIZE 9 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     TOOLTIP "Просмотр заказа без корректировки"
     SIZE 12 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     TOOLTIP "Корректировка заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     TOOLTIP "Удалитиь заказ"
     SIZE 12 BY 1.

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     TOOLTIP "Закрыть корректировку заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть":L
     TOOLTIP "Открыть корректировку заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-copy
     LABEL "К&опия":L
     TOOLTIP "Копирование заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     TOOLTIP "Печать заказа"
     SIZE 12 BY 1.

DEFINE BUTTON b-print-rcv
     LABEL "b-print-rcv"
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-history
     LABEL "&История":L
     TOOLTIP "История заказа"
     SIZE 12 BY 1.


DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     TOOLTIP "Дополнительные сведения по заказу"
     SIZE 98 BY 2 NO-UNDO.

DEFINE BUTTON b-cons
     LABEL "&s":L
     TOOLTIP "Объединение нескольких заказов в один, ALT-S"
     SIZE 3 BY 1.
     
DEFINE BUTTON b-email
    LABEL "&s":L
    TOOLTIP "Отправка файла на e-mail"
    SIZE 3 BY 1.
    
    
define MENU m-rep
    .

DEFINE MENU M-print
       MENU-ITEM m_print1       LABEL "ТОРГ-26" ACCELERATOR "ALT-7"
       MENU-ITEM m_print2       LABEL "Печать по форме Поставщика" ACCELERATOR "ALT-8"
       MENU-ITEM m_print6       LABEL "Заказ по форме поставщика с детализацией по поставкам"
       menu-item m_print4       LABEL "Стандартная форма"
       menu-item m_print5       LAbel "Печатная форма по объектам для заказов Фирма-поставщик"
       RULE
       MENU-ITEM m_print3       LABEL "Выбор формы печати" ACCELERATOR "ALT-9"
 .
DEFINE MENU M-print-rcv
       MENU-ITEM m_print1-rcv       LABEL "Печать Поставки"
       MENU-ITEM m_print2-rcv       LABEL "Печать по форме Поставщика"
       RULE
       MENU-ITEM m_print3-rcv       LABEL "Выбор формы печати"
 .

define MENU m-payment
    MENU-ITEM m-client       Label "Все платежи контрагента" ACCELERATOR "ALT-3"
    MENU-ITEM m-doc          Label "Платежи по документу" ACCELERATOR "ALT-4"
  .
define MENU m-exec
    MENU-ITEM m-exp          Label "Расчет потребности товаров"   ACCELERATOR "ALT-5"
    MENU-ITEM m-cycle        Label "Расчет цикличных заказов" ACCELERATOR "ALT-6"
    MENU-ITEM m-del-cycle    Label "Снять пометку у цикличного заказа" ACCELERATOR "ALT-6"
    RULE
    MENU-ITEM m-cl           Label "Закрытие выполненных заказов"
    MENU-ITEM m-del          Label "Удаление невыполненных заказов"
    RULE
    MENU-ITEM m-imp          Label "Импорт заказов"                  ACCELERATOR "ALT-0"
    menu-item m-edi          Label "Повторный Экспорт EDI"           disabled
    menu-item m-edoc-nn      Label "Отправить заказ вручную (по EDOC_NN)"
    menu-item m-edoc-rpl-ok  Label "Отправить подтверждения rpl-ok,pst-ok вручную (по EDOC_NN)"
    menu-item m-edoc-ok      Label "Получить ответ  вручную (по EDOC_NN)"
    RULE
    menu-item m-sost         Label "Состояние заказа"
    RULE
    MENU-ITEM m_gen-1        Label "Генерация ФО поставщиков"
    MENU-ITEM m_gen-1_buyer  Label "Генерация ФО покупателей"
    MENU-ITEM m_lkp-fo       Label "Просмотр  ФО"
    MENU-ITEM m_gen-2        Label "Отказаться от генерации ФО"
    MENU-ITEM m_gen-3        Label "Снять признак - есть генерация ФО"
    MENU-ITEM m_gen-4        Label "Снять 'не опред'"
    RULE
    MENU-ITEM m_gen-2-2      Label "Отказаться от генерации 2го-ФО"
    MENU-ITEM m_gen-3-2      Label "Снять признак - есть генерация 2го-ФО"
    MENU-ITEM m_gen-4-2      Label "Снять 'не опред' 2го-ФО"
    .

FUNCTION mark-string RETURN CHAR (buffer loc-t-doc for shar-buf_ord-doc ).
  if can-do (del-list, string (recid (loc-t-doc))) then RETURN "*".
  else RETURN "".
END FUNCTION.

FUNCTION f-fo RETURNS CHARACTER
  ( buffer loc-t-doc for ub.ord-doc ) :
define buffer bufb_contract for ub.contract  .
define variable v-proc as character no-undo .
   find first bufb_contract no-lock where
              bufb_contract.contract-code = loc-t-doc.contract-code and
              bufb_contract.host-code     = loc-t-doc.host-code and
              bufb_contract.usl-opl       = {&contr-buyer-ord-prc}
              no-error .
if available bufb_contract then v-proc = "%" + trim( string(bufb_contract.srok-opl)).
                           else v-proc = "".

if v-proc = ? then v-proc = "err" .

 if loc-t-doc.cr-fo = yes then do:
   if loc-t-doc.status_ = {&fact}
   then do:
    if loc-t-doc.cr-fo2 = yes then return substring(string ( loc-t-doc.fo-date, "99/99/99"),1,5) + "-" + substring (string (loc-t-doc.fo-date2, "99/99/99"),1,5)  .
    else return string (loc-t-doc.fo-date, "99/99/99") + v-proc.
   end.

   else return string (loc-t-doc.fo-date, "99/99/99") + v-proc.
 end.
 else do:
   if loc-t-doc.need-fo = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-fo = 1 then do:
     return "".
   end.
   if loc-t-doc.need-fo = 2 then do:
     return "не опред".
   end.
 end.
END FUNCTION.



DEFINE BROWSE br-docs QUERY br-docs NO-LOCK DISPLAY
      mark-string (buffer shar-buf_ord-doc) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
      if shar-buf_ord-doc.order-type = 1 then "*" Else "" COLUMN-LABEL "Ц" FORMAT "x(1)"    COLUMN-FGCOLOR 3
      (substring (shar-buf_ord-doc.doc-type, 1, 2)) COLUMN-LABEL "Т" FORMAT "x(2)"
      IF (shar-buf_ord-doc.status_ = {&fact} or shar-buf_ord-doc.status_ = {&ord-close}) THEN (shar-buf_ord-doc.status_ + string(shar-buf_ord-doc.flag_,"+/-")) ELSE (shar-buf_ord-doc.status_) COLUMN-LABEL "Статус" format "x(8)"
      status-edoc-edi-light (buffer shar-buf_ord-doc, input no, input no, output v-color) @ str-status-edoc-nn COLUMN-LABEL "Статус EDOC" FORMAT "x(12)"
      shar-buf_ord-doc.doc-code format "x(12)"
      shar-buf_ord-doc.doc-date   format "99/99/9999" column-label "Дата"
      shar-buf_ord-doc.fact-date  format "99/99/9999" COLUMN-LABEL "Факт"
      shar-buf_ord-doc.cli-type + " " + String(shar-buf_ord-doc.cli-code)   format "x(13)" column-label "Код"
      shar-buf_ord-doc.cli-name  format "x(27)"
      shar-buf_ord-doc.cons-code  column-label "Ссылка"
      shar-buf_ord-doc.host-code format ">>>>>>>>9" column-label "Фирма"
      shar-buf_ord-doc.obj-type + " " + string(shar-buf_ord-doc.obj-code)  column-label "Объект"
      shar-buf_ord-doc.ship-date column-label "Доставка"
      string(shar-buf_ord-doc.ship-time,"hh:mm") column-label "Время"
      f-fo ( buffer shar-buf_ord-doc ) @ v-fo column-label "ФО" format "x(11)"
      /*
      shar-buf_ord-doc.need-fo   column-label 'need-fo'
      shar-buf_ord-doc.cr-fo     column-label 'cr-fo'
      shar-buf_ord-doc.fo-date   column-label 'fo-date'
      shar-buf_ord-doc.need-fo2  column-label 'need-fo2'
      shar-buf_ord-doc.cr-fo2    column-label 'cr-fo2'
      shar-buf_ord-doc.fo-date2  column-label 'fo-date2'
       */
    WITH SIZE 98 BY 15 separators.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&frame-name}
     /* 1-й ряд батонов */

     b-quit AT ROW 1 COL 2
     b-sel  AT ROW 1 COL 14
     b-rep  AT ROW 1 COL 26

     b-payment  AT ROW 1 COL 38
     b-sost     AT ROW 1 COL 50
     b-exec     AT ROW 1 COL 74
     b-help     AT ROW 1 COL 86
     b-sch      AT ROW 1 COL 38
     /* 2-й ряд батонов */
     b-mark   AT ROW 2 COL 2
     b-add    AT ROW 2 COL 5
     b-lkp    AT ROW 2 COL 14
     b-chg    AT ROW 2 COL 26
     b-del    AT ROW 2 COL 38
     b-close  AT ROW 2 COL 50
     b-open   AT ROW 2 COL 62
     b-copy   AT ROW 2 COL 74
     b-print  AT ROW 2 COL 86
     b-print-rcv AT ROW 2 COL 86
     b-history AT ROW 2 COL 62
     b-cons    at row 2 col 87.5
     b-email   AT ROW 2 COL 90.5
     br-docs  AT ROW 3 COL 1
     pay-type at row 18 col 5 COLON-ALIGNED LABEL "Опл" VIEW-AS FILL-IN SIZE 64 BY 1 fgcolor 4
     shar-buf_ord-doc.tot-lines at row 18 col 80 COLON-ALIGNED LABEL "Кол-во строк" VIEW-AS TEXT SIZE 14 BY .79 fgcolor 4

     boss-name at row 19 col 5 COLON-ALIGNED    LABEL "М-р" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     agnt-name at row 19 col 30 COLON-ALIGNED   LABEL "Исп" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     wrkr-name at row 19 col 55 COLON-ALIGNED   LABEL "Кл-к" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     v-user-name at row 19 col 80 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4

     ed-notes AT ROW 20 COL 1 no-label bgcolor 8 fgcolor 4
     sch-code at row 22 col 2  label "&Начало номера"
     sch-date at row 22 col 32 label "Д&ата"
     sch-fact at row 22 col 52 label "Фа&кт"
     sch-num  at row 22 col 70 label "Найдено" fgcolor 12

    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.


/* { gbl/app_help.i } */
 hide b-print-rcv in frame {&frame-name} .
{ cus/zakz-rcv.i false }