&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_bar-code FOR bar-code.
DEFINE NEW SHARED BUFFER buf_goods FOR goods.
DEFINE NEW SHARED BUFFER buf_price-doc-forming FOR price-doc-forming.
DEFINE NEW SHARED BUFFER buf_price-doc-forming-gds FOR price-doc-forming-gds.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документ назначения цены

Автор: Чернова Светлана Александровна
Дата создания: 12/15/05
Author: Svetlana Chernova
Creation date: 12/15/05

{&pr-calc-slt},{&pr-calc-slt-wbill}  убить в БД клиентов при переходе на 15 версию
{&pr-calc-costobj}                   заменить на  {&pr-calc-cost}

*/

define input  parameter parParentProc     as handle    no-undo .
define input  parameter p-mode            as character no-undo .
define input  parameter p-plt-id          as integer   no-undo .
define input  parameter p-plt-db-num      as integer   no-undo .
define input  parameter p-recid-gds       as recid     no-undo .
define output parameter p-rec-list        as character no-undo .

define input-output parameter p-doc-rec   as recid     no-undo.
define input-output parameter p-br-handle as handle    no-undo .
define input-output parameter p-buffer-handle as handle    no-undo .
define input-output parameter p-next-prev as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ назначения цены".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }
{ cmp/gds-list.i gds-list def "new shared" }
define variable v-str as character no-undo .

{ ref/xobjgrp.i  }  /* список объектов  */
{ gbl/thbj-def.i }
{ ref/grpobj.i }
{ ref/gdsoattr.i }
{ gbl/waitfram.i }
{ gbl/color.i    }
{ str/hvrdtax.i  }
{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/alt-calc.i "ver-modificator-price-is-null" }

{ str/mpl-lib.i  pr-doc }
{ str/mpl-lib3.i }
{ trg/factord.i  }
{ gbl/tax-name.i }
{ str/lastincs.i }
{ trg/check-bc.i }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ str/pdf-attr.i }
{ gbl/clntattr.i }
{ ref/gds-attr.i }

define variable gds-rec as integer   no-undo .     /* для f9 */
define variable g#log   as logical   no-undo .

define variable par-is-pharm   as character no-undo .
define variable v-pricewithvat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .

define buffer buf-price-list-type    for ub.price-list-type  .
define buffer buf_qnty-in-qnty-group for ub.qnty-in-qnty-group  .
define buffer buf_sum-in-sum-group   for ub.sum-in-sum-group  .
define buffer buf_tnv-in-tnv-group   for ub.tnv-in-turnover-group  .
define buffer buf_global-state       for ub.global-state  .
define buffer buf_doc-line           for ub.doc-line .

define stream imp.


define variable v-base-code  as integer   no-undo .
define variable v-line-num   as integer   no-undo .
define variable v-sec        as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable FILL-IN_start-shift-name as character no-undo .
define variable FILL-IN_end-shift-name   as character no-undo .
define variable v-bgr-name               as character no-undo .
define variable v-last-obj-type  as character no-undo . /* последний объект в списке , если группа , иначе текущий  */
define variable v-last-obj-code  as integer   no-undo .
define variable p-new-calc-method as character no-undo .
define variable calc-rec as recid no-undo.
define variable del-list as character no-undo.
define variable var-vat-pc as decimal   no-undo .

{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }

define temp-table tt_price-doc-forming-gds-xxx no-undo like ub.price-doc-forming-gds-qnty .

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.


function f-ost-part return decimal
( input p-b-code as integer     ,
  input p-obj-type as character ,
  input p-obj-code as integer   )
  :
define variable v-qnty as decimal   no-undo .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .

v-qnty = ? .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code no-error .
  find first buf_gds-obj no-lock where
              buf_gds-obj.gds-code  = buf_bar-code.gds-code and
              buf_gds-obj.obj-type  = p-obj-type  and
              buf_gds-obj.obj-code = p-obj-code  no-error .
if buf_bar-code.in-code = "" then do:
   if available buf_gds-obj then  v-qnty =  buf_gds-obj.fact-qnty.
end.
else do:
    find first buf_parts no-lock where
               buf_parts.artic     = buf_gds-obj.artic and
               buf_parts.prod-type = buf_gds-obj.prod-type  and
               buf_parts.prod-code = buf_gds-obj.prod-code  and
               buf_parts.obj-type  = buf_gds-obj.obj-type  and
               buf_parts.obj-code  = buf_gds-obj.obj-code  and
               buf_parts.in-code   = buf_bar-code.in-code    and
               buf_parts.part-code = buf_bar-code.part-code  and
               buf_parts.out-code   = {&free-code} and
               buf_parts.rsrv-free  = true and
               buf_parts.status_    = false  no-error .
     if available buf_parts then v-qnty = buf_parts.fact-qnty .
end.
  return v-qnty .
end function.



function func-part-code return character
( input p-rec as recid ) :
define  BUFFER local-pdf FOR ub.price-doc-forming-gds .
define buffer buf_bar-code for ub.bar-code  .

find first local-pdf no-lock where recid (local-pdf) = p-rec no-error .
if error-status :error then return "" .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = local-pdf.b-code no-error .
if error-status :error then return "" .
   return buf_bar-code.part-code .
end function.


function func-old-pc return decimal
( input p-rec as recid ) :
define  BUFFER local-pdf FOR ub.price-doc-forming-gds .
find first local-pdf no-lock where recid (local-pdf) = p-rec no-error .
if error-status :error then return ? .
define variable old-pc as decimal no-undo.
  old-pc = (local-pdf.price-sale-doc / local-pdf.price-prev-doc - 1) * 100.
  if old-pc > 9999 then
    old-pc = ?. /* чтоб влезало в формат */
  return (old-pc).
end function.

function func-calc-pc return decimal
( input p-rec as recid ) :
define  BUFFER local-pdf FOR ub.price-doc-forming-gds .
find first local-pdf no-lock where recid (local-pdf) = p-rec no-error .
if error-status :error then return ? .
define variable old-pc as decimal no-undo.
  old-pc = (local-pdf.price-sale-doc / local-pdf.price-calc-doc - 1) * 100.
  if old-pc > 9999 then
    old-pc = ?. /* чтоб влезало в формат */
  return (old-pc).
end function.

FUNCTION get-mark RETURNS CHARACTER
(buffer local-doc-line for buf_price-doc-forming-gds ):
if lookup (string (recid (local-doc-line)), del-list) > 0  then return "*".
                                                           else return "".
end function.

function name-grp returns character
 ( buffer loc-table for tt_price-doc-forming-gds-xxx   ) :
   return "" .
end function.

define temp-table tt-table1 no-undo
field f1 as character
field f2 as character
field f3 as character
field f4 as character
.

define temp-table tt-table2 no-undo
field f1 as character
field f2 as character
field f3 as character
field f4 as character
.

define temp-table tt-table3 no-undo
field f1 as character
field f2 as character
field f3 as character
field f4 as character
.
define variable v-name as character no-undo .
&scop cop-l0      get-mark  (BUFFER buf_price-doc-forming-gds)
&scop cop-l1      buf_price-doc-forming-gds.line-num
&scop cop-l2      buf_price-doc-forming-gds.b-code
&scop cop-l3      buf_price-doc-forming-gds.artic
&scop cop-l4      buf_bar-code.unit-cli
&scop cop-l5      v-name
&scop cop-l6      buf_price-doc-forming-gds.vat-pc
&scop cop-l7      buf_price-doc-forming-gds.price-sale-doc
&scop cop-l8      buf_price-doc-forming-gds.price-prev-doc
&scop cop-l9      func-old-pc(recid(buf_price-doc-forming-gds))
&scop dyn_cop-l9  substitute('dynamic-function(&1func-old-pc&1,recid(buf_price-doc-forming-gds))', ~{&double-quote~})
&scop cop-l10     buf_price-doc-forming-gds.price-calc-doc
&scop cop-l11      func-calc-pc(recid(buf_price-doc-forming-gds))
&scop dyn_cop-l11  substitute('dynamic-function(&1func-calc-pc&1,recid(buf_price-doc-forming-gds))', ~{&double-quote~})
&scop cop-l12     buf_price-doc-forming-gds.road-tax-doc
&scop cop-l13     buf_price-doc-forming-gds.excise-doc
&scop cop-l14     buf_price-doc-forming-gds.stts
&scop cop-l15     buf_price-doc-forming-gds.price-sale-rubl
&scop cop-l16     buf_price-doc-forming-gds.price-prev-rubl
&scop cop-l17     buf_price-doc-forming-gds.price-calc-rubl
&scop cop-l18     buf_price-doc-forming-gds.road-tax-rubl
&scop cop-l19     buf_price-doc-forming-gds.excise-rubl
&scop cop-l20     buf_price-doc-forming-gds.price-sale-base
&scop cop-l21     buf_price-doc-forming-gds.price-prev-base
&scop cop-l22     buf_price-doc-forming-gds.price-calc-base
&scop cop-l23     buf_price-doc-forming-gds.road-tax-base
&scop cop-l24     buf_price-doc-forming-gds.excise-base
&scop cop-l25     buf_price-doc-forming-gds.prev-doc-code
&scop cop-l26      func-part-code(recid(buf_price-doc-forming-gds))
&scop dyn_cop-l26  substitute('dynamic-function(&1func-part-code&1,recid(buf_price-doc-forming-gds))', ~{&double-quote~})


&scop col-l0  '*'
&scop col-l1  '№'
&scop col-l2  'Бар-код'
&scop col-l3  'Артикул'
&scop col-l4  'Ед.'
&scop col-l5  'Наименование'
&scop col-l6  'НДС%'
&scop col-l7  'Новая (вал.док)'
&scop col-l8  'Последняя (вал.док)'
&scop col-l9  '%Н/П'
&scop col-l10 'Исходная  (вал.док)'
&scop col-l11 '%Н/И'
&scop col-l12 'Комп.цены (вал.док)'
&scop col-l13 'Акциз (вал.док)'
&scop col-l14 'Статус'
&scop col-l15 'Новая (нац.вал)'
&scop col-l16 'Последняя (нац.вал)'
&scop col-l17 'Исходная  (нац.вал)'
&scop col-l18 'Комп.цены (нац.вал)'
&scop col-l19 'Акциз (нац.вал)'
&scop col-l20 'Новая (баз.вал)'
&scop col-l21 'Последняя (баз.вал)'
&scop col-l22 'Исходная  (баз.вал)'
&scop col-l23 'Комп.цены (баз.вал)'
&scop col-l24 'Акциз (баз.вал)'
&scop col-l25 'Посл.ДНЦ'
&scop col-l26 '№ Партии'

define variable sort-column-name as character no-undo .
define variable filter-point as character no-undo init "Документ назначения цены" .
define variable doc-rec as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_price-doc-forming-gds buf_goods ~
buf_bar-code tt_price-doc-forming-gds-xxx buf_price-doc-forming

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 {&cop-l0} {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} fnc-gds-name ( recid( buf_goods ) , recid( buf_bar-code)) @ {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l14} {&cop-l15} {&cop-l16} {&cop-l17} {&cop-l18} {&cop-l19} {&cop-l20} {&cop-l21} {&cop-l22} {&cop-l23} {&cop-l24} {&cop-l25} {&cop-l26}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1 {&cop-l7}
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH buf_price-doc-forming-gds OF buf_price-doc-forming NO-LOCK, ~
             EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK, ~
             EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH buf_price-doc-forming-gds OF buf_price-doc-forming NO-LOCK, ~
             EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK, ~
             EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 buf_price-doc-forming-gds buf_goods ~
buf_bar-code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 buf_price-doc-forming-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1 buf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-1 buf_bar-code


/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt_price-doc-forming-gds-xxx.ggr-qnty tt_price-doc-forming-gds-xxx.price-sale-doc tt_price-doc-forming-gds-xxx.price-sale-rubl tt_price-doc-forming-gds-xxx.price-sale-base tt_price-doc-forming-gds-xxx.d-pcnt
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 tt_price-doc-forming-gds-xxx.price-sale-doc
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 ~
tt_price-doc-forming-gds-xxx
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 tt_price-doc-forming-gds-xxx
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt_price-doc-forming-gds-xxx OF                                  buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH tt_price-doc-forming-gds-xxx OF                                  buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt_price-doc-forming-gds-xxx
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt_price-doc-forming-gds-xxx


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}~
    ~{&OPEN-QUERY-BROWSE-2}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH buf_price-doc-forming ~
      WHERE         buf_price-doc-forming.plt-id     =  price-doc-forming.plt-id        and ~
        buf_price-doc-forming.plt-db-num =  price-doc-forming.plt-db-num    and ~
        buf_price-doc-forming.pdf-id     =  price-doc-forming.pdf-id        and ~
        buf_price-doc-forming.pdf-db     =  price-doc-forming.pdf-db ~
 NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH buf_price-doc-forming ~
      WHERE         buf_price-doc-forming.plt-id     =  price-doc-forming.plt-id        and ~
        buf_price-doc-forming.plt-db-num =  price-doc-forming.plt-db-num    and ~
        buf_price-doc-forming.pdf-id     =  price-doc-forming.pdf-id        and ~
        buf_price-doc-forming.pdf-db     =  price-doc-forming.pdf-db ~
 NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame buf_price-doc-forming
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame buf_price-doc-forming


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-prev b-next b-mark b-sel-all ~
b-unmark b-add b-del b-chg b-special b-obj b-grp b-cust b-notes B-import ~
B-history b-help calc-method increase-pc round-method round-base ~
FILL-IN_base-rate FILL-IN_base-scale FILL-IN_have-start-period l-loc-hour ~
l-loc-min R-mode-code b-log-2 b-log b-type-price FILL-IN_exch-rate ~
FILL-IN_exch-scale FILL-IN_have-end-period l-loc-hour-2 l-loc-min-2 ~
BROWSE-1 BROWSE-2 a-n-c loc-art loc-name loc-code FILL-IN_name ~
v-curr-abbr-bv v-curr-abbr-vd p-calc-metod p-old p-new p-pc-prev ~
p-pr-doc-old p-op-pr-doc-old p-pc-pr-doc-old p-pc-op-pr-doc-old p-avrg ~
p-op-avrg p-pc-avrg p-pc-op-avrg p-last p-op-last p-pc-last p-pc-op-last ~
prev-price_doc-num v-ost obj-in-code v-new-price-vat obj-in-date ~
v-prod-price-prc v-prod-price v-prod-price-prc-2 v-priceprodwithvat-2 ~
v-prod-price-prc-3
&Scoped-Define DISPLAYED-OBJECTS calc-method increase-pc round-method ~
round-base FILL-IN_base-rate FILL-IN_base-scale FILL-IN_have-start-period ~
l-loc-hour l-loc-min R-mode-code FILL-IN_exch-rate FILL-IN_exch-scale ~
FILL-IN_have-end-period l-loc-hour-2 l-loc-min-2 a-n-c loc-art FILL-IN_name ~
v-curr-abbr-bv v-curr-abbr-vd p-calc-metod p-old p-new p-pc-prev ~
p-pr-doc-old p-op-pr-doc-old p-pc-pr-doc-old p-pc-op-pr-doc-old p-avrg ~
p-op-avrg p-pc-avrg p-pc-op-avrg p-last p-op-last p-pc-last p-pc-op-last ~
prev-price_doc-num v-ost obj-in-code v-new-price-vat obj-in-date ~
v-prod-price-prc v-prod-price v-prod-price-prc-2 v-priceprodwithvat-2 ~
v-prod-price-prc-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnc-color Dialog-Frame
FUNCTION fnc-color RETURNS integer

  ( buffer b-goods for ub.goods , buffer b-bar-code for ub.bar-code )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnc-gds-name Dialog-Frame
FUNCTION fnc-gds-name RETURNS CHARACTER
( input p-rec1 as recid , input p-rec2 as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-chg
       MENU-ITEM m-one-chg      LABEL "Текущая строка -<<ctrl-o>>"
       MENU-ITEM m-all-chg      LABEL "Выбранные строки".

DEFINE MENU m-import
       MENU-ITEM m-import-txt   LABEL "Импорт из txt"
       MENU-ITEM m-import-bb    LABEL "Импорт из списка кодов".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 7 BY 1 TOOLTIP "Добавление в переоценку цен на главные коды".

DEFINE BUTTON b-alt
     LABEL "Н&еосн":L
     SIZE 8 BY 1 TOOLTIP "Добавление скидок и цен на неосновные коды".

DEFINE BUTTON b-chg
     LABEL "Рас&чет":L
     SIZE 7 BY 1 TOOLTIP "Пересчет цен в строке (строках)".

DEFINE BUTTON b-cust
     LABEL "Клиенты":L
     SIZE 7.88 BY 1 TOOLTIP "Группа покупателей".

DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 7 BY 1 TOOLTIP "Удаление строк из переоценки".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 6 BY 1 TOOLTIP "Выход из документа с сохранением состояния".

DEFINE BUTTON b-grp
     LABEL "Группы":L
     SIZE 8 BY 1 TOOLTIP "Группы товаров".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1 TOOLTIP "Помощь".

DEFINE BUTTON B-history
     LABEL "И":L
     SIZE 3.5 BY 1 TOOLTIP "История строки".

DEFINE BUTTON B-import
     IMAGE-UP FILE "cmp/imp-txt.bmp":U
     LABEL "И":L
     SIZE 3.5 BY 1 TOOLTIP "Импорт".

DEFINE BUTTON b-log
     LABEL "п/п":L
     SIZE 4 BY 1 TOOLTIP "Перенумеровать строки".

DEFINE BUTTON b-log-2
     LABEL "п/п":L
     SIZE 4 BY 1 TOOLTIP "Перенумеровать строки".

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1 TOOLTIP "Отметить строки ДНЦ".

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру следующему документу списка".

DEFINE BUTTON b-notes
     LABEL "П&рим":L
     SIZE 8 BY 1 TOOLTIP "Просмотр примечания к ДНЦ".

DEFINE BUTTON b-obj
     LABEL "Объекты":L
     SIZE 8 BY 1 TOOLTIP "Список объектов ценообразования".

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру предыдущего ДНЦ списка".

DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1 TOOLTIP "Отметить строки ДНЦ".

DEFINE BUTTON b-special
     LABEL "&Осн":L
     SIZE 7 BY 1 TOOLTIP "Добавление в ДНЦ спеццен на основные коды (шкала)".

DEFINE BUTTON b-type-price
     LABEL "&Т":L
     SIZE 3 BY 1 TOOLTIP "Тип прайс-листа".

DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1 TOOLTIP "Отметить строки ДНЦ".

DEFINE BUTTON r-copy
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-copy"
     SIZE 3 BY .88.

DEFINE VARIABLE calc-method AS CHARACTER FORMAT "x(12)"
     LABEL "Исходная"
     VIEW-AS COMBO-BOX INNER-LINES 20
     LIST-ITEMS "Товар","Учетная","Учет-объект","Учет-резерв","Приходная","Прих-объект","Старая","Новая","Объект","Накладная","Переоценка","Накл-безНДС","Учет-безНДС","Стар-безНДС","Единая","НсП","НсП+накл","Отсутствует","Не-считать","Спецификация"
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE round-method AS CHARACTER FORMAT "x(15)"
     LABEL "Окру&гление"
     VIEW-AS COMBO-BOX INNER-LINES 7
      LIST-ITEMS
      {&pr-round-9end},
      {&pr-round-9-99end},
      {&pr-round-integer},
      {&pr-round-select},
      {&pr-round-up},
      {&pr-round-coef},
      {&pr-round-off}
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN_name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 39.5 BY 1.42 TOOLTIP "Название ДНЦ"
     FONT 4 NO-UNDO.

DEFINE VARIABLE common-price AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE copy-code AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE copy-type AS CHARACTER FORMAT "x(8)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE doc-code AS CHARACTER FORMAT "X(20)"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN_base-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Баз.вал."
     VIEW-AS FILL-IN
     SIZE 12 BY .79
     FGCOLOR 1 .

DEFINE VARIABLE FILL-IN_base-scale AS INTEGER FORMAT ">>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY .79
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE FILL-IN_end-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата объекта".

DEFINE VARIABLE FILL-IN_end-shift-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Сменная дата".

DEFINE VARIABLE FILL-IN_end-shift-num AS INTEGER FORMAT ">>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4 BY .83.

DEFINE VARIABLE FILL-IN_end-sys-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата сервера".

DEFINE VARIABLE FILL-IN_exch-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Вал.док."
     VIEW-AS FILL-IN
     SIZE 12 BY .79
     FGCOLOR 1 .

DEFINE VARIABLE FILL-IN_exch-scale AS INTEGER FORMAT ">>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY .79
     FGCOLOR 1 .

DEFINE VARIABLE FILL-IN_start-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата объекта".

DEFINE VARIABLE FILL-IN_start-shift-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Сменная дата".

DEFINE VARIABLE FILL-IN_start-shift-num AS INTEGER FORMAT ">>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4 BY .83.

DEFINE VARIABLE FILL-IN_start-sys-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата сервера".

DEFINE VARIABLE increase-pc AS DECIMAL FORMAT "->>>>>9.<<<<<%" INITIAL 0
     LABEL "На&ценка"
     VIEW-AS FILL-IN
     SIZE 10.25 BY 1 NO-UNDO.

DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14 BY .79 TOOLTIP "Поиск по артикулу" NO-UNDO.

DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(16)"
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 14 BY .79 TOOLTIP "Поиск" NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(20)"
     LABEL "Нач.назв"
     VIEW-AS FILL-IN
     SIZE 14 BY .79 NO-UNDO.

DEFINE VARIABLE obj-in-code AS CHARACTER FORMAT "X(16)"
     LABEL "ПН"
      VIEW-AS TEXT
     SIZE 16.5 BY .67 NO-UNDO.

DEFINE VARIABLE obj-in-date AS DATE FORMAT "99/99/99"
     LABEL "Дата ПН"
      VIEW-AS TEXT
     SIZE 8.63 BY .67 NO-UNDO.

DEFINE VARIABLE p-avrg AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена учет."
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Текущая средняя учетная цена по группе объектов" NO-UNDO.
     
DEFINE VARIABLE v-free-qnty AS DECIMAL FORMAT "->>>>>>>9.<<" INITIAL ?
     LABEL "Свободно"
      VIEW-AS TEXT
     SIZE 12 BY .67 NO-UNDO.
     
DEFINE VARIABLE v-fact-qnty AS DECIMAL FORMAT "->>>>>>>9.<<" INITIAL ?
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 12 BY .67 NO-UNDO.
     
DEFINE VARIABLE v-in-doc-qnty AS DECIMAL FORMAT "->>>>>>>9.<<" INITIAL ?
     LABEL "Приход"
      VIEW-AS TEXT
     SIZE 12 BY .67 NO-UNDO.

DEFINE VARIABLE p-calc-metod AS CHARACTER FORMAT "x(17)"
      VIEW-AS TEXT
     SIZE 22 BY .67 TOOLTIP "Метод расчета новой продажной цены товара" NO-UNDO.

DEFINE VARIABLE p-last AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена прих."
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена последней внешней ПН " NO-UNDO.

DEFINE VARIABLE p-new AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена нов."
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена после закрытия ДНЦ"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-old AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена старая"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена предыдущего ДНЦ" NO-UNDO.

DEFINE VARIABLE p-op-avrg AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Старая/Учет"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Старая цена по отношению к учетной цене в процентах" NO-UNDO.

DEFINE VARIABLE p-op-last AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Старая/Прих"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Старая цена по отношению к цене последнего прихода в процентах" NO-UNDO.

DEFINE VARIABLE p-op-pr-doc-old AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Стар/Переоц"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Старая цена по отношению к переоценке в процентах"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE p-pc-avrg AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Новая/Учет"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Новая цена по отношению к учетной цене в процентах" NO-UNDO.

DEFINE VARIABLE p-pc-last AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Новая/Прих"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Новая цена по отношению к цене последнего прихода в процентах" NO-UNDO.

DEFINE VARIABLE p-pc-op-avrg AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Разница процентов (по отношению к учетной цене)" NO-UNDO.

DEFINE VARIABLE p-pc-op-last AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Разница процентов (по отношению к цене последнего прихода)" NO-UNDO.

DEFINE VARIABLE p-pc-op-pr-doc-old AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Разница процентов (по отношению к учетной цене(факт))"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE p-pc-pr-doc-old AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов/Переоц"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Новая цена по отношению к переоценке в процентах"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE p-pc-prev AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "На сколько изменилась цена после переоценки в процентах" NO-UNDO.

DEFINE VARIABLE p-pr-doc-old AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена переоц"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена последней переоценки"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE prev-price_doc-num AS CHARACTER FORMAT "X(16)"
     LABEL "Переоценка"
      VIEW-AS TEXT
     SIZE 16.5 BY .67 TOOLTIP "Номер Переоценки с первого объекта группы".

DEFINE VARIABLE round-base AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE v-curr-abbr-bv AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-curr-abbr-vd AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-new-price-vat AS DECIMAL FORMAT ">>>>>>>>>>9.99":U INITIAL 0
     LABEL "Новая без НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Новая прадажная цена без НДС" NO-UNDO.

DEFINE VARIABLE v-ost AS DECIMAL FORMAT "->>>>>>>>>>9.99":U INITIAL 0
     LABEL "Остаток"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Текущий остаток по партии"
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE v-priceprodwithvat-2 AS DECIMAL FORMAT ">>>>>>>>>>9.99":U INITIAL 0
     LABEL "Цена Произ С НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Цена производителя с НДС"
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE v-prod-price AS DECIMAL FORMAT ">>>>>>>>>>9.99":U INITIAL 0
     LABEL "Цена Произв без НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Текущая Цена производителя без НДС"
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE v-prod-price-prc AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов с НДС/ЦПроизв безНДС"
      VIEW-AS TEXT
     SIZE 8 BY .67 TOOLTIP "Новая цена С НДС по отношению к текущей цене ПРОИЗВОДИТЕЛЯ без НДС в процентах"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE v-prod-price-prc-2 AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов безНДС/ЦПроизв сНДС"
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Новая цена без НДС по отношению к текущей цене ПРОИЗВОДИТЕЛЯ с НДС в процентах"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE v-prod-price-prc-3 AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов сНДС/ЦПроизв сНДС"
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Новая цена с НДС по отношению к текущей цене ПРОИЗВОДИТЕЛЯ с НДС в процентах"
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     SIZE 11.5 BY .71 TOOLTIP "Поиск" NO-UNDO.

DEFINE VARIABLE R-mode-code AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "все", 1,
"осн", 2
     SIZE 12 BY 1 TOOLTIP "Все коды или основные" NO-UNDO.

DEFINE VARIABLE FILL-IN_have-end-period AS LOGICAL INITIAL no
     LABEL "Есть конец"
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY .83 TOOLTIP "Есть ограничение на период действия" NO-UNDO.

DEFINE VARIABLE FILL-IN_have-start-period AS LOGICAL INITIAL no
     LABEL "Есть начало"
     VIEW-AS TOGGLE-BOX
     SIZE 13.38 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY BROWSE-1 FOR
 buf_price-doc-forming-gds,
 buf_goods,
 buf_bar-code SCROLLING.


DEFINE QUERY BROWSE-2 FOR
      tt_price-doc-forming-gds-xxx SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      buf_price-doc-forming SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 NO-LOCK DISPLAY
      {&cop-l0}  COLUMN-LABEL {&col-l0}  FORMAT "X(1)":U
    {&cop-l1}  COLUMN-LABEL {&col-l1}  FORMAT ">>>>>>9":U
    {&cop-l2}  COLUMN-LABEL {&col-l2}  FORMAT "99999999999":U
    {&cop-l3}  COLUMN-LABEL {&col-l3}  FORMAT "X(16)":U
    {&cop-l4}  COLUMN-LABEL {&col-l4}  FORMAT "X(3)":U
    fnc-gds-name ( recid( buf_goods ) , recid( buf_bar-code)) @ {&cop-l5}  COLUMN-LABEL {&col-l5}  FORMAT "X(60)":U WIDTH 20
    {&cop-l6}  COLUMN-LABEL {&col-l6}  FORMAT ">9.9<%":U
    {&cop-l7}  COLUMN-LABEL {&col-l7}  FORMAT "->>>,>>>,>>9.99":U
    {&cop-l8}  COLUMN-LABEL {&col-l8}  FORMAT "->>>,>>>,>>9.99":U
    {&cop-l9}  COLUMN-LABEL {&col-l9}  FORMAT "->>>9.99":U
    {&cop-l10} COLUMN-LABEL {&col-l10} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l11} COLUMN-LABEL {&col-l11} FORMAT "->>>9.99":U
    {&cop-l12} COLUMN-LABEL {&col-l12} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l13} COLUMN-LABEL {&col-l13} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l14} COLUMN-LABEL {&col-l14} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l15} COLUMN-LABEL {&col-l15} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l16} COLUMN-LABEL {&col-l16} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l17} COLUMN-LABEL {&col-l17} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l18} COLUMN-LABEL {&col-l18} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l19} COLUMN-LABEL {&col-l19} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l20} COLUMN-LABEL {&col-l20} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l21} COLUMN-LABEL {&col-l21} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l22} COLUMN-LABEL {&col-l22} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l23} COLUMN-LABEL {&col-l23} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l24} COLUMN-LABEL {&col-l24} FORMAT "->>>,>>>,>>9.99":U
    {&cop-l25} COLUMN-LABEL {&col-l25} FORMAT "x(20)":U
    {&cop-l26} COLUMN-LABEL {&col-l26} FORMAT "x(20)":U

    enable
    {&cop-l7}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99.75 BY 7.75 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt_price-doc-forming-gds-xxx.ggr-qnty COLUMN-LABEL "Количество" FORMAT "->>>,>>>,>>>,>>9.999":U
            WIDTH 16
      tt_price-doc-forming-gds-xxx.price-sale-doc COLUMN-LABEL "Цена (док-та)" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 19
      tt_price-doc-forming-gds-xxx.price-sale-rubl COLUMN-LABEL "Цена (нац.вал)" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 19
      tt_price-doc-forming-gds-xxx.price-sale-base COLUMN-LABEL "Цена (б.в.)" FORMAT "->>>,>>>,>>9.99":U
        WIDTH 19

      tt_price-doc-forming-gds-xxx.d-pcnt COLUMN-LABEL "Скидка %" FORMAT "->>>,>>9.999":U


      ENABLE
          tt_price-doc-forming-gds-xxx.price-sale-doc
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99.75 BY 4.71 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN TOOLTIP "Цена продажи по группам".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 7
     b-next AT ROW 1 COL 10
     b-mark AT ROW 1 COL 13 WIDGET-ID 6
     b-sel-all AT ROW 1 COL 16 WIDGET-ID 24
     b-unmark AT ROW 1 COL 19 WIDGET-ID 26
     b-add AT ROW 1 COL 22
     b-del AT ROW 1 COL 29
     b-chg AT ROW 1 COL 36
     b-special AT ROW 1 COL 43
     b-alt AT ROW 1 COL 50
     b-obj AT ROW 1 COL 58
     b-grp AT ROW 1 COL 66
     b-cust AT ROW 1 COL 74
     b-notes AT ROW 1 COL 82
     B-import AT ROW 1 COL 90 WIDGET-ID 4
     B-history AT ROW 1 COL 94 WIDGET-ID 2
     b-help AT ROW 1 COL 97.63
     doc-code AT ROW 1.96 COL 23 COLON-ALIGNED NO-LABEL
     calc-method AT ROW 2 COL 10 COLON-ALIGNED
     common-price AT ROW 2 COL 23 COLON-ALIGNED NO-LABEL
     copy-type AT ROW 2 COL 23 COLON-ALIGNED NO-LABEL
     copy-code AT ROW 2 COL 30 COLON-ALIGNED NO-LABEL
     r-copy AT ROW 2 COL 39.63
     increase-pc AT ROW 2 COL 50 COLON-ALIGNED
     round-method AT ROW 2 COL 73 COLON-ALIGNED
     round-base AT ROW 2 COL 87.63 COLON-ALIGNED NO-LABEL
     FILL-IN_base-rate AT ROW 3 COL 9.5 COLON-ALIGNED
     FILL-IN_base-scale AT ROW 3 COL 21.5 COLON-ALIGNED NO-LABEL
     FILL-IN_have-start-period AT ROW 3 COL 33.63
     FILL-IN_start-date AT ROW 3 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_start-shift-date AT ROW 3 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_start-sys-date AT ROW 3 COL 45.75 COLON-ALIGNED NO-LABEL
     FILL-IN_start-shift-num AT ROW 3 COL 54.88 COLON-ALIGNED NO-LABEL
     l-loc-hour AT ROW 3 COL 62 COLON-ALIGNED
     l-loc-min AT ROW 3 COL 65 COLON-ALIGNED NO-LABEL
     R-mode-code AT ROW 3.75 COL 81.13 NO-LABEL
     b-log-2 AT ROW 3.75 COL 93.38
     b-log AT ROW 3.75 COL 93.63
     b-type-price AT ROW 3.75 COL 97.63
     FILL-IN_exch-rate AT ROW 3.83 COL 9.5 COLON-ALIGNED
     FILL-IN_exch-scale AT ROW 3.83 COL 21.5 COLON-ALIGNED NO-LABEL
     FILL-IN_have-end-period AT ROW 3.83 COL 33.63
     FILL-IN_end-shift-date AT ROW 3.83 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_end-sys-date AT ROW 3.83 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_end-date AT ROW 3.83 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_end-shift-num AT ROW 3.83 COL 54.75 COLON-ALIGNED NO-LABEL
     l-loc-hour-2 AT ROW 3.83 COL 62 COLON-ALIGNED
     l-loc-min-2 AT ROW 3.83 COL 65 COLON-ALIGNED NO-LABEL
     BROWSE-1 AT ROW 4.75 COL 1
     BROWSE-2 AT ROW 12.46 COL 1.13
     a-n-c AT ROW 17.33 COL 1 NO-LABEL
     loc-name AT ROW 17.92 COL 11 COLON-ALIGNED
     loc-code AT ROW 17.92 COL 11 COLON-ALIGNED
     loc-art AT ROW 17.92 COL 11 COLON-ALIGNED
     FILL-IN_name AT ROW 21 COL 61.5 NO-LABEL
     v-curr-abbr-bv AT ROW 3.04 COL 27 COLON-ALIGNED NO-LABEL
     v-curr-abbr-vd AT ROW 3.88 COL 27 COLON-ALIGNED NO-LABEL
     p-calc-metod AT ROW 17.33 COL 77 COLON-ALIGNED NO-LABEL
     p-old AT ROW 18 COL 39.13 COLON-ALIGNED
     p-new AT ROW 18 COL 65 COLON-ALIGNED
     p-pc-prev AT ROW 18 COL 89 COLON-ALIGNED
     p-pr-doc-old AT ROW 18.75 COL 12.21 COLON-ALIGNED
     p-op-pr-doc-old AT ROW 18.79 COL 40.5 COLON-ALIGNED
     p-pc-pr-doc-old AT ROW 18.79 COL 66.63 COLON-ALIGNED
     p-pc-op-pr-doc-old AT ROW 18.79 COL 89 COLON-ALIGNED
     p-avrg AT ROW 19.42 COL 11 COLON-ALIGNED
     p-op-avrg AT ROW 19.46 COL 40.5 COLON-ALIGNED
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     p-pc-avrg AT ROW 19.46 COL 66.63 COLON-ALIGNED
     p-pc-op-avrg AT ROW 19.46 COL 89 COLON-ALIGNED
     p-last AT ROW 20.13 COL 11 COLON-ALIGNED
     p-op-last AT ROW 20.17 COL 40.5 COLON-ALIGNED
     p-pc-last AT ROW 20.17 COL 66.63 COLON-ALIGNED
     p-pc-op-last AT ROW 20.17 COL 89 COLON-ALIGNED
     prev-price_doc-num AT ROW 20.92 COL 12 COLON-ALIGNED
     v-free-qnty AT ROW 20.92 COL 40.5 COLON-ALIGNED
     v-ost AT ROW 21.13 COL 44.25 COLON-ALIGNED WIDGET-ID 8
     obj-in-code AT ROW 21.67 COL 11 COLON-ALIGNED
     v-fact-qnty AT ROW 21.67 COL 40.5 COLON-ALIGNED
     v-new-price-vat AT ROW 21.75 COL 44.25 COLON-ALIGNED WIDGET-ID 16
     obj-in-date AT ROW 22.38 COL 11 COLON-ALIGNED
     v-in-doc-qnty AT ROW 22.38 COL 40.5 COLON-ALIGNED
     v-prod-price-prc AT ROW 22.42 COL 89 COLON-ALIGNED WIDGET-ID 14
     v-prod-price AT ROW 22.5 COL 44.25 COLON-ALIGNED WIDGET-ID 12
     v-prod-price-prc-2 AT ROW 23 COL 89 COLON-ALIGNED WIDGET-ID 20
     v-priceprodwithvat-2 AT ROW 23.25 COL 44.25 COLON-ALIGNED WIDGET-ID 18
     v-prod-price-prc-3 AT ROW 23.58 COL 89 COLON-ALIGNED WIDGET-ID 22
     " Информация по строке" VIEW-AS TEXT
          SIZE 22 BY .67 AT ROW 17.25 COL 40
          FGCOLOR 4
     SPACE(39.24) SKIP(6.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ назначения цены".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_bar-code B "NEW SHARED" ? ub bar-code
      TABLE: buf_goods B "NEW SHARED" ? ub ub.goods
      TABLE: buf_price-doc-forming B "NEW SHARED" ? ub price-doc-forming
      TABLE: buf_price-doc-forming-gds B "NEW SHARED" ? ub price-doc-forming-gds
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1 l-loc-min-2 Dialog-Frame */
/* BROWSE-TAB BROWSE-2 BROWSE-1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-alt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-chg:HANDLE.

ASSIGN
       B-import:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-import:HANDLE.

/* SETTINGS FOR FILL-IN common-price IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       common-price:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN copy-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       copy-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN copy-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       copy-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN doc-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       doc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN_end-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_end-shift-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_end-shift-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_end-sys-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_start-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_start-shift-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_start-shift-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN FILL-IN_start-sys-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN l-loc-hour IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-hour-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc-code IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       loc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN loc-name IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       loc-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON r-copy IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-copy:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_price-doc-forming-gds OF buf_price-doc-forming NO-LOCK,
      EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,
      EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE new shared QUERY BROWSE-1 FOR
 buf_price-doc-forming-gds,
 buf_goods,
 buf_bar-code SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_price-doc-forming-gds-xxx OF
                                 buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.buf_price-doc-forming"
     _Options          = "NO-LOCK"
     _Where[1]         = "        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db
"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Документ назначения цены */
DO:
 if p-mode = {&lookup} then return.
  run save-proc in this-procedure no-error.
  if error-status :error  then do:
  message
    "Ошибка сохранения ! "
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error
    .
    return no-apply .
  end.

END.

on end-error, stop of frame {&frame-name}  do:
  apply "choose" to b-exit in frame {&frame-name} .
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ назначения цены */
DO:
  p-next-prev = no.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  assign a-n-c .
   case a-n-c :
      when "art"
      then do:
         hide loc-name loc-code in frame {&frame-name} .
         display loc-art with frame {&frame-name} .
         apply "ENTRY":U to loc-art in frame {&FRAME-NAME}.
      end.
      when "name"
      then do:
         hide loc-art loc-code in frame {&frame-name} .
         display loc-name with frame {&frame-name} .
         apply "ENTRY":U to loc-name in frame {&FRAME-NAME}.
      end.
      when "code"
      then do:
         hide loc-name loc-art in frame {&frame-name} .
         display loc-code with frame {&frame-name} .
         apply "ENTRY":U to loc-code in frame {&FRAME-NAME}.
      end.
   end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добав */
DO:
  empty temp-table tt-gds-list.
  run proc-add-gds in this-procedure  ( input 1 , ?).
  run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.line-num   = v-line-num no-error .
   reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
   apply "value-changed" to browse-1 in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-alt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-alt Dialog-Frame
ON CHOOSE OF b-alt IN FRAME Dialog-Frame /* Неосн */
DO:
if not available buf_price-doc-forming then return.
if not available buf_bar-code then return.
  /* Работа с неосновными кодами */
  run str/mpl-alt.w
  (  input         parParentProc
    ,input         v-last-obj-type
    ,input         v-last-obj-code
    ,input         recid (buf_price-doc-forming)
    ,input         p-mode
    ,input         "code"
    ,input         buf_bar-code.b-code
    ,input-output  round-method
    ,input-output  round-base
    ,input-output  v-sec
    ).

  run OpenBr in this-procedure (yes, no, '':U).
  reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
  apply "value-changed" to browse-1 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Расчет */
DO:
  /**/
  run OpenBr in this-procedure (yes, no, '':U).
  apply "value-changed" to browse-1 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cust
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cust Dialog-Frame
ON CHOOSE OF b-cust IN FRAME Dialog-Frame /* Клиенты */
DO:
  run str/vi-tt.w
    ( table tt-table3 ,
      v-bgr-name + {&delim-par} + "Код"  + {&delim-par} + "Покупатели"
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удал */
DO:
define variable varlog as logical   no-undo .
define variable line-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable  varlns-cnt  as integer   no-undo .
define variable rr as recid no-undo .

if del-list = "" then do:
  /* удаление 1 строки */
  if not available buf_price-doc-forming-gds then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  varlog = no.
  message "Удалить строку ДНЦ ?   Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update varlog.
  if NOT varlog then return no-apply.

  line-rec = recid (buf_price-doc-forming-gds).

  g#log = {&browse-name}:select-next-row () in frame {&frame-name} no-error .
  rep-rec =  recid (buf_price-doc-forming-gds) no-error .
  del-list = "".
  run del-doc-line1 ( line-rec ) .
  run OpenBr in this-procedure (yes, no, '':U).
  reposition {&browse-name} to recid rep-rec no-error.
  run vc-pdf in this-procedure .
end.
else do:
  /* удаление отмеченных строк */
  varlog = ?.
  message "Удалить строки ДНЦ ?" skip (2)
          "ДА - удалить все отмеченные строки" skip
          "НЕТ - оставить только отмеченные строки и удалить все остальные"
  view-as alert-box question buttons yes-no-cancel update varlog.
  if varlog = ? then return no-apply.
end.
if varlog then do:
  /* удалить отмеченные */
  assign
    varlns-cnt = 1.
  do while varlns-cnt <= num-entries (del-list):
    assign
      line-rec   = integer (entry (varlns-cnt, del-list))
      varlns-cnt = varlns-cnt + 1.
      reposition {&browse-name} to recid line-rec no-error.
      g#log = {&browse-name}:select-next-row () in frame {&frame-name} no-error .
      rep-rec =  recid (buf_price-doc-forming-gds) no-error .
      run del-doc-line1 ( line-rec ) .
  end.
end.
else do:
  /* оставить отмеченные */
  for each buf_price-doc-forming-gds where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db :
    if can-do (del-list, string (recid (buf_price-doc-forming-gds))) then next.
       line-rec = recid (buf_price-doc-forming-gds) .
        reposition {&browse-name} to recid line-rec no-error.
        g#log = {&browse-name}:select-next-row () in frame {&frame-name} no-error .
        rep-rec =  recid (buf_price-doc-forming-gds) no-error .
        run del-doc-line1 ( line-rec ) .
    end.
 end.
del-list = "" .
run OpenBr in this-procedure (yes, no, '':U).
reposition {&browse-name} to recid rep-rec no-error.
run vc-pdf in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  p-next-prev = NO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-grp Dialog-Frame
ON CHOOSE OF b-grp IN FRAME Dialog-Frame /* Группы */
DO:
  run str/vi-tt.w
    ( TABLE tt-table2 ,
    "Список групп товаров по документу назначения цены" + {&delim-par} + " " + {&delim-par} + "Наименование группы"
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* И */
DO:
{ gbl/stdbtn.i }
  if not available buf_price-doc-forming-gds then return .
  run ref/cpr-form.w
      ( parParentProc ,
        buf_price-doc-forming-gds.plt-id     ,
        buf_price-doc-forming-gds.plt-db-num ,
        buf_price-doc-forming-gds.pdf-id     ,
        buf_price-doc-forming-gds.pdf-db
        ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-log
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-log Dialog-Frame
ON CHOOSE OF b-log IN FRAME Dialog-Frame /* п/п */
DO:

define variable row-i as integer   no-undo .
define variable g-log as logical   no-undo .
  row-i = 0 .
  reposition browse-1 to  row 1 no-error .
  get first  browse-1 exclusive-lock .

  do while available buf_price-doc-forming-gds :
      assign
        row-i = row-i + 1
        buf_price-doc-forming-gds.line-num = row-i
      .
      get next  browse-1 exclusive-lock.
  end.

  release buf_price-doc-forming-gds.
  run OpenBr in this-procedure (yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-log-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-log-2 Dialog-Frame
ON CHOOSE OF b-log-2 IN FRAME Dialog-Frame /* п/п */
DO:

define variable row-i as integer   no-undo .
define variable g-log as logical   no-undo .
  row-i = 0 .
  reposition browse-1 to  row 1 no-error .
  get first  browse-1 exclusive-lock .

  do while available buf_price-doc-forming-gds :
      assign
        row-i = row-i + 1
        buf_price-doc-forming-gds.line-num = row-i
      .
      get next  browse-1 exclusive-lock.
  end.

  release buf_price-doc-forming-gds.
  run OpenBr in this-procedure (yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  {&stdbtn}
  run proc-b-mark in this-procedure no-error.
  run vc-pdf in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:

 /*  gbl/stdbtn.i }*/
    run proc-b-move(input self:name) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-notes Dialog-Frame
ON CHOOSE OF b-notes IN FRAME Dialog-Frame /* Прим */
DO:
{ gbl/stdbtn.i }
define variable notes as character no-undo .

notes = buf_price-doc-forming.des.
if p-mode = {&lookup} then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
  if return-value = 'false':u
  then do:
    return .
  end.
  if buf_price-doc-forming.des <> notes then do:
    do transaction on error undo, return no-apply :
      find current buf_price-doc-forming exclusive-lock .
      assign
        buf_price-doc-forming.des = notes.
    end.
  end.
end.

  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj Dialog-Frame
ON CHOOSE OF b-obj IN FRAME Dialog-Frame /* Объекты */
DO:
  run str/vi-ttpdf.w
  ( TABLE tt-table1 ,
    "Список объектов по документу назначения цены" + {&delim-par} + "Код" + {&delim-par} + "Наименование объекта" + {&delim-par} + "*" ,
    p-mode ,
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ) .
   run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .
   run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).
   if return-value = "nullobj"  then
   do:
    message
      "Внимание !!! Нет ни одного объекта для ДНЦ !!!"
      view-as alert-box error
      .
     return no-apply .
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
{ gbl/stdbtn.i }
    run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all Dialog-Frame
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame /* + */
DO:
  assign del-list = "".
  if not available buf_price-doc-forming-gds then return.
  for each buf_price-doc-forming-gds
     where buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
       and buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
       and buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
       and buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db no-lock :
    { gbl/markstrn.i buf_price-doc-forming-gds del-list }
  end.
  {&browse-name}:refresh() in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-special
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-special Dialog-Frame
ON CHOOSE OF b-special IN FRAME Dialog-Frame /* Осн */
DO:
 define variable v-rec-id  as recid no-undo .
 if not available buf_price-doc-forming then return.
 if not available buf_bar-code then return.
 v-rec-id = recid(buf_price-doc-forming-gds).
  /* ввод признаков */
  run add-spec in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
  reposition browse-1 to recid v-rec-id no-error.
  apply "value-changed" to browse-1 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-type-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-type-price Dialog-Frame
ON CHOOSE OF b-type-price IN FRAME Dialog-Frame /* Т */
DO:
  define variable v-rec-1 as recid no-undo .
  v-rec-1 = recid(buf-price-list-type) .
  run ref/tp-price.w (input parparentproc ,buf-price-list-type.main , input {&LOOKUP} , input-output v-rec-1) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame /* - */
DO:
  if not available buf_price-doc-forming-gds then return.
  del-list  = "".
  {&browse-name}:refresh() in frame {&frame-name} .
  run vc-pdf in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON LEAVE OF BROWSE-1 IN FRAME Dialog-Frame
DO:
END.

on end-error of {&cop-l7} in browse browse-1
DO:
   run OpenBr in this-procedure (yes, no, '':U).
end.

on leave of {&cop-l7} in browse browse-1
DO:
define variable v-rec-id as recid no-undo .
define variable g#log as logical   no-undo .
define variable loc#log as logical   no-undo .
  if not available buf_price-doc-forming-gds then return.

  if decimal ({&cop-l7} :screen-value in browse browse-1) <> round ({&cop-l7},2)
     and buf_bar-code.unit-cli <> buf_goods.unit-base
     then do:
          message "Изменение в режиме НЕОСНОВНЫЕ ЦЕНЫ !" view-as alert-box information .
          display  {&cop-l7}  with browse browse-1.
          apply "value-changed" to browse-1 in frame {&frame-name}.
  end.

  if decimal ({&cop-l7} :screen-value in browse browse-1) <> round ({&cop-l7},2)
  and   buf_bar-code.unit-cli = buf_goods.unit-base
    then do:
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons yes-no update g#log.

          if g#log then do:
            /* пересчитать строку по товару */
            find current buf_price-doc-forming-gds exclusive-lock no-error .
            assign  buf_price-doc-forming-gds.price-calc-doc = buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * v-exch-rate / v-exch-scale
                    buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / v-base-rate * v-base-scale
                    buf_price-doc-forming-gds.calc-method = {&pr-calc-no}
                    .

                /* изменилась цена - записываем, что она была изменена вручную */
                /* пересчитываем цены по неосновным для этого кода */
                run calc-price-sub in this-procedure
                                 (input  buf_price-doc-forming-gds.b-code,
                                  input  recid (buf_price-doc-forming),
                                  input  calc-method,
                                  input  increase-pc,
                                  input  round-method,
                                  input  round-base,
                                  input  doc-code,
                                  input  common-price,
                                  input  copy-type,
                                  input  copy-code,
                                  output calc-rec ) no-error.

                    run recalc-neos (
                        buf_price-doc-forming-gds.b-code,
                        buf_price-doc-forming-gds.artic,
                        buf_price-doc-forming-gds.prod-type,
                        buf_price-doc-forming-gds.prod-code
                        ) no-error .
                        if error-status :error then do:
                          message
                            vss-workfile vss-revision vss-description skip
                            error-status :get-message(1) skip
                            return-value skip
                            "ошибка пересчета 2"
                            view-as alert-box error
                          .
                        end.

                if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "calc-price-sub"
                      view-as alert-box error
                    .
                      display  {&cop-l7}  with browse browse-1.
                      apply "value-changed" to browse-1 in frame {&frame-name}.
                      undo, return.
                  end.
                /* показываем итоги с вопросительными знаками */
                run OpenBr in this-procedure (yes, no, '':U).
                reposition browse-1 to recid calc-rec no-error .
            /* записать в историю */

            run upd-br-field in this-procedure .
            /* пересчитать строки по количествам */
            run make-xxx-line in this-procedure .
            v-rec-id = recid(buf_price-doc-forming-gds).
            run OpenBr in this-procedure (yes, no, '':U).
            reposition browse-1 to recid v-rec-id no-error.
            apply "value-changed" to browse-1 in frame {&frame-name}.
          end.
    display  {&cop-l7}  with browse browse-1.
    g#log = browse-1:select-next-row ().
    apply "value-changed" to browse-1 in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON RETURN OF BROWSE-1 IN FRAME Dialog-Frame
DO:
END.

on return of {&cop-l7} in browse browse-1
DO:
define variable v-rec-id as recid no-undo .
define variable g#log as logical   no-undo .
define variable loc#log as logical   no-undo .
  if not available buf_price-doc-forming-gds then return.

  if decimal ({&cop-l7} :screen-value in browse browse-1) <> round ({&cop-l7},2)
     and buf_bar-code.unit-cli <> buf_goods.unit-base
     then do:
          message "Изменение в режиме НЕОСНОВНЫЕ ЦЕНЫ !" view-as alert-box information .
          display  {&cop-l7}  with browse browse-1.
          apply "value-changed" to browse-1 in frame {&frame-name}.
  end.

  if decimal ({&cop-l7} :screen-value in browse browse-1) <> round ({&cop-l7},2)
  and   buf_bar-code.unit-cli = buf_goods.unit-base
    then do:
            /* пересчитать строку по товару */
            find current buf_price-doc-forming-gds exclusive-lock no-error .
            assign  buf_price-doc-forming-gds.price-calc-doc = buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * v-exch-rate / v-exch-scale
                    buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / v-base-rate * v-base-scale
                    buf_price-doc-forming-gds.calc-method = {&pr-calc-no}
                    .

                /* изменилась цена - записываем, что она была изменена вручную */
                /* пересчитываем цены по неосновным для этого кода */
                run calc-price-sub in this-procedure
                                 (input  buf_price-doc-forming-gds.b-code,
                                  input  recid (buf_price-doc-forming),
                                  input  calc-method,
                                  input  increase-pc,
                                  input  round-method,
                                  input  round-base,
                                  input  doc-code,
                                  input  common-price,
                                  input  copy-type,
                                  input  copy-code,
                                  output calc-rec ) no-error.

                    run recalc-neos (
                        buf_price-doc-forming-gds.b-code,
                        buf_price-doc-forming-gds.artic,
                        buf_price-doc-forming-gds.prod-type,
                        buf_price-doc-forming-gds.prod-code
                        ) no-error .
                        if error-status :error then do:
                          message
                            vss-workfile vss-revision vss-description skip
                            error-status :get-message(1) skip
                            return-value skip
                            "ошибка пересчета 2"
                            view-as alert-box error
                          .
                        end.

                if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "calc-price-sub"
                      view-as alert-box error
                    .
/*                      display  {&cop-l7}  with browse browse-1.                */
/*                      apply "value-changed" to browse-1 in frame {&frame-name}.*/
/*                      undo, return.                                            */
                  end.
                /* показываем итоги с вопросительными знаками */
/*                run OpenBr in this-procedure (yes, no, '':U).        */
/*                reposition browse-1 to recid calc-rec no-error .     */
/*            /* записать в историю */                                 */
            run upd-br-field in this-procedure .
            /* пересчитать строки по количествам */
/*            run make-xxx-line in this-procedure .       */
/*            v-rec-id = recid(buf_price-doc-forming-gds).*/
/*            run OpenBr in this-procedure (yes, no, '':U).            */
/*            reposition browse-1 to recid v-rec-id no-error.          */
            apply "value-changed" to browse-1 in frame {&frame-name}.
    display  {&cop-l7}  with browse browse-1.
/*    apply "value-changed" to browse-1 in frame {&frame-name}.*/
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON row-display OF BROWSE-1 IN FRAME Dialog-Frame
DO:
define variable v-color as integer   no-undo .
v-color =  fnc-color( BUFFER buf_goods, BUFFER buf_bar-code) .
    {&cop-l5}:fgcolor in browse BROWSE-1 = v-color .
    {&cop-l4}:fgcolor in browse BROWSE-1 = v-color .
    {&cop-l3}:fgcolor in browse BROWSE-1 = v-color .
    {&cop-l2}:fgcolor in browse BROWSE-1 = v-color .
    {&cop-l1}:fgcolor in browse BROWSE-1 = v-color .

END.

on mouse-select-dblclick of browse-1 in frame {&frame-name}
do:
define variable stp-cycl as logical no-undo .
define variable t-r as recid no-undo .
define variable g#log  as logical   no-undo .
  if available buf_price-doc-forming-gds then do:
     t-r = recid(buf_price-doc-forming-gds).
     if calc-method =  {&pr-calc-no} then do:
        g#log =  session:set-wait-state("") .
        run str/mplform.w (
            input parParentProc ,
            input (if p-mode = {&lookup} then p-mode else {&update})   ,
            input recid (buf_price-doc-forming)    ,
            input recid (buf_price-doc-forming-gds) ,
            input increase-pc ,
            input round-method,
            input round-base,
            input calc-method,
            input v-exch-rate,
            input v-exch-scale,
            input v-base-rate ,
            input v-base-scale,
            output stp-cycl ) no-error .
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "Ошибка"
              view-as alert-box error
            .
            g#log = browse-1:refresh( )  in frame {&frame-name}.
            apply "value-changed" to browse-1 in frame {&frame-name}.
            run recalc-neos (
                buf_price-doc-forming-gds.b-code,
                buf_price-doc-forming-gds.artic,
                buf_price-doc-forming-gds.prod-type,
                buf_price-doc-forming-gds.prod-code
                ) no-error .
                if error-status :error then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    return-value skip
                    "ошибка пересчета 2"
                    view-as alert-box error
                  .
                end.


         if p-mode <> {&lookup} then do:
            run make-xxx-line in this-procedure .
            run OpenBr in this-procedure (yes, no, '':U).
            reposition browse-1 to recid t-r no-error.
            apply "value-changed" to browse-1 in frame {&frame-name}.
            g#log = browse-1:refresh( )  in frame {&frame-name}.
         end.
     end.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    IF AVAILABLE buf_price-doc-forming-gds THEN DO:
      {&OPEN-QUERY-BROWSE-2}
      run vc-pdf in this-procedure .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME calc-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL calc-method Dialog-Frame
ON VALUE-CHANGED OF calc-method IN FRAME Dialog-Frame /* Исходная */
DO:
  /* Исходная */
  ASSIGN calc-method
  doc-code = ""
  .
  hide copy-type copy-code doc-code common-price r-copy in frame {&frame-name}.
  run proc-value-1 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN_have-end-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN_have-end-period Dialog-Frame
ON VALUE-CHANGED OF FILL-IN_have-end-period IN FRAME Dialog-Frame /* Есть конец */
DO:
   ASSIGN FILL-IN_have-end-period .
   run proc-end-o in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN_have-start-period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN_have-start-period Dialog-Frame
ON VALUE-CHANGED OF FILL-IN_have-start-period IN FRAME Dialog-Frame /* Есть начало */
DO:
    ASSIGN FILL-IN_have-start-period .
    run proc-start-o in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame /* Время */
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour-2 IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON CURSOR-UP OF l-loc-hour-2 IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON LEAVE OF l-loc-hour-2 IN FRAME Dialog-Frame /* Время */
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON CURSOR-UP OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON LEAVE OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-art
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-art Dialog-Frame
ON LEAVE OF loc-art IN FRAME Dialog-Frame /* Артикул */
DO:
END.
ON CTRL-J OF loc-art IN FRAME Dialog-Frame /* Артикул */
do:
  assign loc-art .
  run seach-artic in this-procedure ( loc-art , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-art IN FRAME Dialog-Frame
DO:
assign loc-art no-error .
  if error-status:error then return no-apply.
  run seach-artic in this-procedure ( loc-art , false  ) no-error .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-code Dialog-Frame
ON LEAVE OF loc-code IN FRAME Dialog-Frame /* Бар-код */
DO:
END.
ON CTRL-J OF loc-code IN FRAME Dialog-Frame /* Артикул */
do:
  assign loc-code .
  run seach-code in this-procedure ( loc-code , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-code IN FRAME Dialog-Frame
DO:
assign loc-code no-error .
  if error-status:error then return no-apply.
  run seach-code in this-procedure ( loc-code , false  ) no-error .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON LEAVE OF loc-name IN FRAME Dialog-Frame /* Нач.назв */
DO:
  /**/
END.
ON CTRL-J OF loc-name IN FRAME Dialog-Frame /* Артикул */
do:
  assign loc-name .
  run seach-name in this-procedure ( loc-name , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-name IN FRAME Dialog-Frame
DO:
assign loc-name no-error .
  if error-status:error then return no-apply.
  run seach-name in this-procedure ( loc-name , false  ) no-error .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-all-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-all-chg Dialog-Frame
ON CHOOSE OF MENU-ITEM m-all-chg /* Выбранные строки */
DO:
define variable v-prt as logical   no-undo .
define variable vrec as recid no-undo .

message
"Рассчитать продажные цены для выбранных товаров ?"
  view-as alert-box question
  BUTTONS yes-no
  UPDATE v-ok as logical .
if not v-ok then return.

if input frame {&frame-name} increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to {&BROWSE-name} in frame {&frame-name}.
  return no-apply.
end.
if not available buf_price-doc-forming-gds then do:
  message "Задайте товары клавишей 'ДОБАВИТЬ' ! "
          view-as alert-box error.
  return no-apply.
end.

  for each buf_price-doc-forming-gds
     where buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
       and buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
       and buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
       and buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db no-lock :
          assign vrec = recid(buf_price-doc-forming-gds) no-error .
          if lookup(string(vrec), del-list) = 0 then next.
          find first buf_goods
               where buf_goods.artic     = buf_price-doc-forming-gds.artic
                 and buf_goods.prod-type = buf_price-doc-forming-gds.prod-type
                 and buf_goods.prod-code = buf_price-doc-forming-gds.prod-code no-lock no-error .
          empty temp-table  tt-gds-list .
          create tt-gds-list.
          buffer-copy buf_goods to tt-gds-list .

          run ver-bar-code-prt (input buf_price-doc-forming-gds.b-code , output v-prt ) .

          if v-prt then do:
            run proc-add-gds in this-procedure ( 3 , buf_price-doc-forming-gds.b-code ) .
          end.
          else do:
            run proc-add-gds in this-procedure ( 2 , ? ) .
          end.
  end.

reposition browse-1 to recid vrec no-error .
run vc-pdf in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-import-bb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-import-bb Dialog-Frame
ON CHOOSE OF MENU-ITEM m-import-bb /* Импорт из списка кодов */
DO:
  run import-proc in this-procedure  ("bb").
  run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.line-num   = v-line-num no-error .
   reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
   apply "value-changed" to browse-1 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-import-txt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-import-txt Dialog-Frame
ON CHOOSE OF MENU-ITEM m-import-txt /* Импорт из txt */
DO:
  run import-proc in this-procedure  ("txt").
  run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.line-num   = v-line-num no-error .
   reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
   apply "value-changed" to browse-1 in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-one-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one-chg Dialog-Frame
ON CHOOSE OF MENU-ITEM m-one-chg /* Текущая строка -<<ctrl-o>> */
DO:
define variable v-prt as logical   no-undo .
define variable vrec as recid no-undo .

if input frame {&frame-name} increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to {&BROWSE-name} in frame {&frame-name}.
  return no-apply.
end.
if not available buf_price-doc-forming-gds then do:
  message "Задайте товары клавишей 'ДОБАВИТЬ' ! "
          view-as alert-box error.
  return no-apply.
end.
find first buf_goods no-lock where
           buf_goods.artic     = buf_price-doc-forming-gds.artic          and
           buf_goods.prod-type = buf_price-doc-forming-gds.prod-type  and
           buf_goods.prod-code = buf_price-doc-forming-gds.prod-code  no-error .
empty temp-table  tt-gds-list .
create tt-gds-list.
buffer-copy buf_goods to tt-gds-list .
vrec = recid(buf_price-doc-forming-gds) no-error .
run ver-bar-code-prt (input buf_price-doc-forming-gds.b-code , output v-prt ) .

if v-prt then do:
   run proc-add-gds in this-procedure ( 3 , buf_price-doc-forming-gds.b-code ) .
end.
else do:
   run proc-add-gds in this-procedure ( 2 , ? ) .
   end.

reposition browse-1 to recid vrec no-error .
run vc-pdf in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-copy Dialog-Frame
ON CHOOSE OF r-copy IN FRAME Dialog-Frame /* r-copy */
DO:
{ gbl/stdbtn.i }
define variable loc-ref-list as character no-undo .
define variable ref-list as character no-undo .
define variable ref-rec as recid no-undo .
case calc-method:
  when {&pr-calc-obj} then do:
    run ref/cli-all.w
      ( parParentProc
        , "b-sel"
        , ?
        , ?
        , ?
        , ?
        , ?
        , ?
        , output ref-list) .
    apply "entry" to copy-type in frame {&frame-name}.
    if ref-list = "" then
      return no-apply.
    ref-rec = integer (ref-list).
    find ub.clients where recid (ub.clients) = ref-rec no-lock.
    if not ( ub.clients.obj-type = {&stock} or
             ub.clients.obj-type = {&shop} ) then do:
      message "Объектом для копирования цены может быть только склад или магазин."
              view-as alert-box error.
      return no-apply.
    end.
    assign
      copy-code = ub.clients.obj-code
      copy-type = ub.clients.obj-type
      .
    display copy-type copy-code with frame {&frame-name}.
  end.
  when {&pr-calc-wbill}  or
  when {&pr-calc-slt-wbill} or
  when {&pr-calc-wbill-novat} then do:
    assign
      doc-rec = ?  .
    run str/all-docs.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code, input {&g___object}, input ?, input ?, input ?, input ?, input "b-sel":u, input ?, input ?, input ?, output loc-ref-list).
    find ub.trn-doc where recid (ub.trn-doc) = int (loc-ref-list) no-lock no-error .
    if not available ub.trn-doc then do:
      message "Накладная не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    doc-code = ub.trn-doc.doc-code.
    display doc-code with frame {&frame-name}.
  end.
  when {&pr-common} then do:
    display common-price with frame {&frame-name}.
  end.

  when {&pr-calc-pdf} then do:
    /* Список всех ДНЦ */
    run str/docsprls.w ( parparentproc , "all" , ? , ? , "b-sel" , input-output loc-ref-list) .
    find first ub.price-doc-forming no-lock where recid ( ub.price-doc-forming ) = integer ( loc-ref-list ) no-error.
    if not available ub.price-doc-forming then do:
       message "ДНЦ не выбран." error-status :get-message(1)  view-as alert-box error.
       return no-apply.
    end.
    /* выбрана переоценка */
    doc-code = string(ub.price-doc-forming.pdf-id) + "|" +  string(ub.price-doc-forming.pdf-db)  .
    display doc-code with frame {&frame-name}.
  end.

  when {&pr-calc-ov} then do:
    /* Список всех переоценок */
    run str/pr-docs.w (
        input parParentProc ,
        input "b-sel":U ,
        input {&work} ,
        input "" ,
        input v-cntxt-obj-type ,
        input v-cntxt-obj-code ,
        input "" ,
        output loc-ref-list ).
    doc-rec = integer ( loc-ref-list ) .
    find ub.price-doc where recid (ub.price-doc) = doc-rec no-lock no-error.
    if not available ub.price-doc then do:
      message "Переоценка не выбрана."
              view-as alert-box error.
      return no-apply.
    end.

    /* выбрана переоценка */
    doc-code = ub.price-doc.doc-num.
    display doc-code with frame {&frame-name}.
  end.
  otherwise do:
         assign
              doc-rec = ?  .
            run str/all-docs.w
               (input parparentproc,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input  {&type},
                input  ?   ,
                input  {&income} ,
                input  ?         ,
                input  no        ,
                input  "b-sel":U ,
                input  {&TDEDT_Pri_Vnesh},
                input  false          ,
                input  ?              ,
                output loc-ref-list).
            find ub.trn-doc where recid (ub.trn-doc) = int (loc-ref-list) no-lock no-error .
            if not available ub.trn-doc then do:
              message "Накладная не выбрана."
                      view-as alert-box error.
              return no-apply.
            end.
            doc-code = ub.trn-doc.doc-code.
            display doc-code with frame {&frame-name}.
    end.
end case.

  if par-is-pharm = "yes" then do:
    find first ub.trn-doc no-lock  where ub.trn-doc.doc-code = doc-code no-error .
    if available ub.trn-doc then do:
        message
        "Добавить товары и партии из накладной"
          doc-code "в ДНЦ ?"
          view-as alert-box question
          BUTTONS yes-no
          UPDATE v-ok as logical .

            if v-ok then do:
               empty temp-table tt-gds-list.
               run proc-add-gds in this-procedure  ( input 4 , ? ).
               run OpenBr in this-procedure (yes, no, '':U).
            end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-mode-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-mode-code Dialog-Frame
ON VALUE-CHANGED OF R-mode-code IN FRAME Dialog-Frame
DO:
  ASSIGN R-mode-code.
  RUN OpenBr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL round-method Dialog-Frame
ON VALUE-CHANGED OF round-method IN FRAME Dialog-Frame /* Округление */
DO:
 assign round-method .
 run proc-value-2 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

assign
  b-chg     :popup-menu in frame {&frame-name}         = menu m-chg  :handle
  b-chg     :menu-mouse                                = 1
  b-import  :popup-menu in frame {&frame-name}         = menu m-import :handle
  b-import  :menu-mouse                                = 1
.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
 { gbl/app_help.i }
 { gbl/ed_date.i FILL-IN_start-shift-date }
 { gbl/ed_date.i FILL-IN_start-date       }
 { gbl/ed_date.i FILL-IN_start-sys-date   }
 { gbl/ed_date.i FILL-IN_end-shift-date }
 { gbl/ed_date.i FILL-IN_end-date       }
 { gbl/ed_date.i FILL-IN_end-sys-date   }
 { gbl/hot-key.i b-mark }

{ gbl/setfltnm.i no-button }

{ gbl/brwrefre.i "run OpenBr in this-procedure (yes, no, '':U)." }

{ gbl/srt-clmd.i
  &browse-name      =   "browse-1"
  &frame-name       =   "{&frame-name}"
  &table-name       =   "buf_price-doc-forming-gds"
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10    =   "{&col-l10}"
  &label-clmn_11    =   "{&col-l11}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &label-clmn_14    =   "{&col-l14}"
  &label-clmn_15    =   "{&col-l15}"
  &label-clmn_16    =   "{&col-l16}"
  &label-clmn_17    =   "{&col-l17}"
  &label-clmn_18    =   "{&col-l18}"
  &label-clmn_19    =   "{&col-l19}"
  &label-clmn_20    =   "{&col-l20}"
  &label-clmn_21    =   "{&col-l21}"
  &label-clmn_22    =   "{&col-l22}"
  &label-clmn_23    =   "{&col-l23}"
  &label-clmn_24    =   "{&col-l24}"
  &label-clmn_25    =   "{&col-l25}"
  &label-clmn_26    =   "{&col-l0}"
  &label-clmn_27    =   "{&col-l26}"

  &sort-clmn_1    =   "{&cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &dyn_sort-clmn_9   =   "{&dyn_cop-l9}"
  &sort-clmn_10      =   "{&cop-l10}"
  &sort-clmn_11      =   "{&cop-l11}"
  &dyn_sort-clmn_11  =   "{&dyn_cop-l11}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13   =   "{&cop-l13}"
  &sort-clmn_14   =   "{&cop-l14}"
  &sort-clmn_15   =   "{&cop-l15}"
  &sort-clmn_16   =   "{&cop-l16}"
  &sort-clmn_17   =   "{&cop-l17}"
  &sort-clmn_18   =   "{&cop-l18}"
  &sort-clmn_19   =   "{&cop-l19}"
  &sort-clmn_20   =   "{&cop-l20}"
  &sort-clmn_21   =   "{&cop-l21}"
  &sort-clmn_22   =   "{&cop-l22}"
  &sort-clmn_23   =   "{&cop-l23}"
  &sort-clmn_24   =   "{&cop-l24}"
  &sort-clmn_25   =   "{&cop-l25}"
  &sort-clmn_26   =   "{&cop-l0}"
  &sort-clmn_27   =   "{&cop-l26}"
  &dyn_sort-clmn_27  =   "{&dyn_cop-l26}"

&open-query           = "run OpenBr (yes, no, '':U)."
&open-query-otherwise = "run Open1 ."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "no"
&mv-brw-default       = "no" }

{ gbl/f2.i {&browse-name} goods-recid   get-gds-rec  parParentProc }

{&cop-l7}:label-fgcolor in browse browse-1 = blue_color .
{&cop-l13}:label-fgcolor in browse browse-1 = blue_color .
{&cop-l18}:label-fgcolor in browse browse-1 = blue_color .

define variable dor-nal as character no-undo .
 run tax-name in this-procedure ( input {&road-tax}, output  dor-nal) .
 assign
   buf_price-doc-forming-gds.road-tax-doc :label  = dor-nal + " в.д."
   buf_price-doc-forming-gds.road-tax-rubl :label = dor-nal + " {&abbr_rub}"
   buf_price-doc-forming-gds.road-tax-base :label = dor-nal + " б.в."
   .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

p-next-prev = yes.
n-p: do while p-next-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run init-proc in this-procedure .
  run enable_ui in this-procedure .
  if p-mode = {&lookup} then do:
      run my_lookup in this-procedure .
      run OpenBr in this-procedure (yes, no, '':U).
      if  p-recid-gds <> ? then do:
          reposition BROWSE-1 to recid p-recid-gds no-error .
      end.
  end.
  else do:
    run my_enable in this-procedure .
    run Open1 .
  end.
  
  if par-is-pharm = "yes" then do:
      display
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
        doc-code
      with frame {&frame-name} no-error .
      enable doc-code with frame {&frame-name} .
  end.
  else do :
    hide
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
      in frame {&frame-name}  .
    display
      v-free-qnty
      v-fact-qnty
      v-in-doc-qnty
    with frame {&frame-name} no-error .  
  end.
  
  a-n-c = "art" .
  apply "value-change" to a-n-c in frame {&frame-name} .
  display a-n-c with frame {&frame-name} .

  if p-mode <> {&lookup} then do:
    run select-header .
    display calc-method with frame {&frame-name}.
  end.
  wait-for go of frame {&frame-name} focus BROWSE-1 /*fill-in_name*/ .
end.

end. /* do while */
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-spec Dialog-Frame
PROCEDURE add-spec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable num-rec as integer   no-undo .
define variable recid-list as character no-undo .
define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .
define variable v-prev-doc-code   as character no-undo .

define buffer buf_scl_bar-code for ub.bar-code  .
 if par-is-pharm = "yes" then do:
  run ref/bas-cds.w
     ( parParentProc,
       v-last-obj-type,
       v-last-obj-code,
       "par-gds-free",
       buf_bar-code.gds-code,
       output recid-list
       ) .
 end.
 else do:
  run ref/bas-cds.w
     ( parParentProc,
       v-last-obj-type,
       v-last-obj-code,
       "scl-gds-all",
       buf_bar-code.gds-code,
       output recid-list
       ) .
 end.

  run last-num in this-procedure (input recid(buf_price-doc-forming) , output v-line-num ) .
  define variable v-nn as integer   no-undo .
  define variable v-d-pcnt as decimal   no-undo .
  v-nn = num-entries (recid-list).
  do num-rec = 1 to v-nn:

    find first buf_scl_bar-code no-lock where
        recid (buf_scl_bar-code) = integer (entry (num-rec, recid-list)) no-error .

    if available buf_scl_bar-code  and
       ( par-is-pharm = "yes"  or  ( buf_scl_bar-code.part-code = "" and  buf_scl_bar-code.in-code = "" ))
    then do:
        v-line-num = v-line-num + 1.
        run calc-price-line  in this-procedure (
          input  calc-method
        , input  increase-pc
        , input  round-method
        , input  round-base
        , input  buf_scl_bar-code.b-code
        , input  buf_goods.gds-code
        , input  buf_goods.artic
        , input  buf_goods.prod-type
        , input  buf_goods.prod-code
        , input  v-base-rate
        , input  v-base-scale
        , input  v-exch-scale
        , input  v-exch-rate
        , input  doc-code
        , input  common-price
        , input  copy-type
        , input  copy-code
        , output p-new-calc-method
        , output v-price-calc-base
        , output v-price-calc-doc
        , output v-price-calc-rubl
        , output v-price-prev-base
        , output v-price-prev-doc
        , output v-price-prev-rubl
        , output v-price-sale-base
        , output v-price-sale-doc
        , output v-price-sale-rubl
        , output v-road-tax-base
        , output v-road-tax-doc
        , output v-road-tax-rubl
        , output v-excise-base
        , output v-excise-doc
        , output v-excise-rubl
        , output v-vat-pc
        , output v-slt-pc
        , output v-prev-doc-code
        , output v-d-pcnt
        ).

        run create-line  in this-procedure (
           buf_price-doc-forming.plt-db-num
          ,buf_price-doc-forming.plt-id
          ,buf_price-doc-forming.pdf-db
          ,buf_price-doc-forming.pdf-id
          ,v-line-num
          ,buf_scl_bar-code.b-code
          ,buf_goods.artic
          ,buf_goods.prod-type
          ,buf_goods.prod-code
          ,p-new-calc-method
          ,v-d-pcnt
          ,FILL-IN_have-start-period
          ,FILL-IN_start-date
          ,FILL-IN_start-shift-date
          ,FILL-IN_start-shift-name
          ,FILL-IN_start-shift-num
          ,FILL-IN_start-sys-date
          ,( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 )
          ,FILL-IN_have-end-period
          ,FILL-IN_end-date
          ,FILL-IN_end-shift-date
          ,FILL-IN_end-shift-name
          ,FILL-IN_end-shift-num
          ,FILL-IN_end-sys-date
          , ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 )
          ,v-price-calc-base
          ,v-price-calc-doc
          ,v-price-calc-rubl
          ,v-price-prev-base
          ,v-price-prev-doc
          ,v-price-prev-rubl
          ,v-price-sale-base
          ,v-price-sale-doc
          ,v-price-sale-rubl
          ,v-road-tax-base
          ,v-road-tax-doc
          ,v-road-tax-rubl
          ,v-excise-base
          ,v-excise-doc
          ,v-excise-rubl
          ,v-vat-pc
          ,v-slt-pc
          ,v-prev-doc-code
          ,0
          ,input-output v-sec

          ) no-error .
          if error-status :error then
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "bbbb"
            view-as alert-box error
          .

        /* подготовка шаблона по количественным группам */
          find first buf_price-doc-forming-gds no-lock  where
                    buf_price-doc-forming-gds.plt-db-num  =  buf_price-doc-forming.plt-db-num and
                    buf_price-doc-forming-gds.plt-id      =  buf_price-doc-forming.plt-id     and
                    buf_price-doc-forming-gds.pdf-db      =  buf_price-doc-forming.pdf-db     and
                    buf_price-doc-forming-gds.pdf-id      =  buf_price-doc-forming.pdf-id     and
                    buf_price-doc-forming-gds.b-code      =  buf_scl_bar-code.b-code
                    no-error .
          run make-xxx-line in this-procedure .
          run calc-price-sub in this-procedure
              (input  buf_scl_bar-code.b-code ,
              input  recid ( buf_price-doc-forming ) ,
              input  calc-method,
              input  increase-pc,
              input  round-method,
              input  round-base,
              input  doc-code,
              input  common-price,
              input  copy-type,
              input  copy-code,
              output calc-rec) no-error.
           if error-status :error then
           message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             "calc-price-sub"
             view-as alert-box error
           .
      end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-doc-line1 Dialog-Frame
PROCEDURE del-doc-line1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-recid  as recid no-undo .

define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b-gds-prt for ub.gds-prt.

define buffer buf_bar-code for ub.bar-code  .

define variable v-artic     as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer   no-undo .


find first buf_price-doc-forming-gds exclusive-lock where
           recid(buf_price-doc-forming-gds)  = p-recid no-error .
find first buf_bar-code no-lock  where
           buf_bar-code.b-code  = buf_price-doc-forming-gds.b-code no-error .
find first buf_goods no-lock  where
           buf_goods.gds-code = buf_bar-code.gds-code no-error .

if not available buf_price-doc-forming-gds then return.


  assign
    v-artic      = buf_price-doc-forming-gds.artic
    v-prod-type  = buf_price-doc-forming-gds.prod-type
    v-prod-code  = buf_price-doc-forming-gds.prod-code
  .


find first b-gds-prt no-lock where b-gds-prt.node-code = buf_bar-code.node-code no-error .

    if b-gds-prt.upper-code = buf_goods.prt-root and
       buf_goods.unit-base = buf_bar-code.unit-cli and
       buf_bar-code.in-code = ""     then  do: /* main-price */
        for each buf2_price-doc-forming-gds exclusive-lock  where
              buf2_price-doc-forming-gds.pdf-db     = buf_price-doc-forming-gds.pdf-db  and
              buf2_price-doc-forming-gds.pdf-id     = buf_price-doc-forming-gds.pdf-id  and
              buf2_price-doc-forming-gds.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
              buf2_price-doc-forming-gds.plt-id     = buf_price-doc-forming-gds.plt-id and
              buf2_price-doc-forming-gds.artic      =  v-artic     and
              buf2_price-doc-forming-gds.prod-type  =  v-prod-type and
              buf2_price-doc-forming-gds.prod-code  =  v-prod-code  :
          for each tt_price-doc-forming-gds-xxx  where
                tt_price-doc-forming-gds-xxx.b-code      = buf2_price-doc-forming-gds.b-code     and
                tt_price-doc-forming-gds-xxx.pdf-db      = buf2_price-doc-forming-gds.pdf-db     and
                tt_price-doc-forming-gds-xxx.pdf-id      = buf2_price-doc-forming-gds.pdf-id     and
                tt_price-doc-forming-gds-xxx.plt-db-num  = buf2_price-doc-forming-gds.plt-db-num and
                tt_price-doc-forming-gds-xxx.plt-id      = buf2_price-doc-forming-gds.plt-id
                :
                delete tt_price-doc-forming-gds-xxx .
          end.
          delete buf2_price-doc-forming-gds .
       end.
    end.
    else do:
       for each buf2_price-doc-forming-gds exclusive-lock  where
           recid(buf2_price-doc-forming-gds) = recid (buf_price-doc-forming-gds) :
                for each tt_price-doc-forming-gds-xxx  where
                      tt_price-doc-forming-gds-xxx.b-code      = buf2_price-doc-forming-gds.b-code     and
                      tt_price-doc-forming-gds-xxx.pdf-db      = buf2_price-doc-forming-gds.pdf-db     and
                      tt_price-doc-forming-gds-xxx.pdf-id      = buf2_price-doc-forming-gds.pdf-id     and
                      tt_price-doc-forming-gds-xxx.plt-db-num  = buf2_price-doc-forming-gds.plt-db-num and
                      tt_price-doc-forming-gds-xxx.plt-id      = buf2_price-doc-forming-gds.plt-id
                      :
                      delete tt_price-doc-forming-gds-xxx .
                end.
           delete buf2_price-doc-forming-gds .
       end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY calc-method increase-pc round-method round-base FILL-IN_base-rate
          FILL-IN_base-scale FILL-IN_have-start-period l-loc-hour l-loc-min
          R-mode-code FILL-IN_exch-rate FILL-IN_exch-scale
          FILL-IN_have-end-period l-loc-hour-2 l-loc-min-2 a-n-c loc-art
          FILL-IN_name v-curr-abbr-bv v-curr-abbr-vd p-calc-metod p-old p-new
          p-pc-prev p-pr-doc-old p-op-pr-doc-old p-pc-pr-doc-old
          p-pc-op-pr-doc-old p-avrg p-op-avrg p-pc-avrg p-pc-op-avrg p-last
          p-op-last p-pc-last p-pc-op-last prev-price_doc-num v-ost obj-in-code
          v-new-price-vat obj-in-date v-prod-price-prc v-prod-price
          v-prod-price-prc-2 v-priceprodwithvat-2 v-prod-price-prc-3
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-prev b-next b-mark b-sel-all b-unmark b-add b-del b-chg
         b-special b-obj b-grp b-cust b-notes B-import B-history b-help
         calc-method increase-pc round-method round-base FILL-IN_base-rate
         FILL-IN_base-scale FILL-IN_have-start-period l-loc-hour l-loc-min
         R-mode-code b-log-2 b-log b-type-price FILL-IN_exch-rate
         FILL-IN_exch-scale FILL-IN_have-end-period l-loc-hour-2 l-loc-min-2
         BROWSE-1 BROWSE-2 a-n-c loc-art loc-name loc-code FILL-IN_name
         v-curr-abbr-bv v-curr-abbr-vd p-calc-metod p-old p-new p-pc-prev
         p-pr-doc-old p-op-pr-doc-old p-pc-pr-doc-old p-pc-op-pr-doc-old p-avrg
         p-op-avrg p-pc-avrg p-pc-op-avrg p-last p-op-last p-pc-last
         p-pc-op-last prev-price_doc-num v-ost obj-in-code v-new-price-vat
         obj-in-date v-prod-price-prc v-prod-price v-prod-price-prc-2
         v-priceprodwithvat-2 v-prod-price-prc-3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-rec Dialog-Frame
PROCEDURE get-gds-rec :
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
   gds-rec = ? .
   if not available buf_price-doc-forming-gds then return.
      find first buf_goods no-lock where
                 buf_goods.artic     = buf_price-doc-forming-gds.artic     and
                 buf_goods.prod-type = buf_price-doc-forming-gds.prod-type and
                 buf_goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
      if available buf_goods then gds-rec = recid(buf_goods).
  end.

end procedure. /* get-gds-rec */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-proc Dialog-Frame
PROCEDURE import-proc :
define input  parameter p-mode as character no-undo .

define variable l-ok     as logical   no-undo .
define variable imp-save as integer   no-undo .
define variable v-file-name as char no-undo.
define variable i1 as integer no-undo.
define variable impc as integer   no-undo .
define variable s  as character no-undo.
define variable owner   as character no-undo INITIAL "".
define variable v-price like ub.price-list.price-sale no-undo.
define variable v-bar-code as integer no-undo.
define variable main-b-code  as integer   no-undo .

define variable v-doc-num    like ub.price-list.doc-num    no-undo .
define variable v-price-sale like ub.price-list.price-sale no-undo .
define variable v-road-tax   like ub.price-list.road-tax   no-undo .
define variable v-excise     like ub.price-list.excise     no-undo .

define buffer main_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer bf_bar-code for ub.bar-code  .
if p-mode = "txt"
    then do:
      v-str = "Проводить импорт из текстового файла  формата:     бар-код;цена    ? ".
    end.
    else do:
      v-str = "Проводить импорт из списка кодов ?".
    end.
  l-ok = true .

  message v-str
    view-as alert-box question
    buttons yes-no
    update l-ok .
  if l-ok = false then return.

  system-dialog get-file v-file-name
  title "Выберите файл для заполнения переоценки"
  filters "Текстовый файл (*.csv)"   "*.csv" ,
          "Текстовый файл (*.txt)"   "*.txt" ,
          "Список кодов   (*.bb)"    "*.bb" ,
          "Все файлы" "*.*"
           update l-ok.
  if not l-ok then return.


  input stream imp from value ( v-file-name ) .

 repeat :
     s = "".
     import stream imp unformatted s NO-ERROR.
     if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     end.

     assign
      impc   = impc + 1
      i1 = i1 + 1
      s = trim (s)
     .
     if s = "" then leave.


 if p-mode = "txt" then do:
     assign
      v-price = decimal ( replace (entry (2, s, ";") ,"," , ".") )
      v-bar-code = integer(entry (1, s, ";"))
     no-error.
 end.

 if p-mode = "bb" then do:
    v-bar-code = integer(entry (1, s, " ")) no-error.
      { gbl/bcodeprc.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-bar-code
        0
        0
        v-doc-num
        v-price
        v-road-tax
        v-excise
        no-error
      }
 end.

     if v-price <= 0 or v-price = ? then next.
     if v-bar-code <= 0 or v-bar-code = ? then next.

  display
  impc  label "Прочитано"
  i1    label "Сохранено"
  v-bar-code format ">>>>>>>>>9" label "Bar-code"
  with frame ff view-as dialog-box
  title substitute(": Импорт товаров из файла в ДНЦ"  ) .
  pause 0.

     find first bf_bar-code where bf_bar-code.b-code = v-bar-code
     no-lock no-error.
     if not available bf_bar-code then do:
            message "Отсутствует БК для товара с bar-code:" v-bar-code .
            next.
     end.
     find first buf_goods where buf_goods.gds-code = bf_bar-code.gds-code  no-lock no-error.

     if not available buf_goods then do:
            message "Отсутствует товар с gds-code:" bf_bar-code.gds-code .
            next.
     end.

    { gbl/gdsbcode.i
      buf_goods.gds-code
      ?
      main-b-code }

      find first buf_price-doc-forming-gds exclusive-lock where
                 buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
            and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
            and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
            and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
            and  buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
      if available buf_price-doc-forming-gds then do:
        delete buf_price-doc-forming-gds.
      end.
      imp-save = imp-save + 1 .
      if buf_goods.unit-base = bf_bar-code.unit-cli then do: /* ++++++++++++++++++++++ОСНОВНОЙ КОД */
          find first buf_price-doc-forming-gds exclusive-lock where
                     buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
                and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
                and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
                and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
                and  buf_price-doc-forming-gds.b-code     = main-b-code no-error .
          if not available buf_price-doc-forming-gds then do:
          run prcreate-new-price-doc-forming-gds in this-procedure (
              input recid ( buf_price-doc-forming )
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input par-pr-notls
            , input par-pr-altex
            , input par-pr-sclex
            , input imp-save
            , input buf_goods.gds-code
            , input v-price  /* цена */
            ) no-error.
            if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
            end.
            end.
            if main-b-code  <>  bf_bar-code.b-code then do:
                find first buf_price-doc-forming-gds exclusive-lock where
                          buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                          buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                          buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                          buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                          buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
                if available buf_price-doc-forming-gds then do:
                  delete buf_price-doc-forming-gds .
                end.
                assign
                  imp-save = imp-save + 1
                  v-sec =  v-sec + 1
                .

                  run create-line-pdf-mpl-lib (
                      input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input imp-save
                      ,input bf_bar-code.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input v-price
                      ,input ""
                      ,input 0
                      ,input-output v-sec ) no-error .
            end.
        end.
        else do: /* неосновной код */
        /* если нет основного */

        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code no-error .
        if not available main_price-doc-forming-gds then do:
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = v-cntxt-obj-type  and
                   buf_gds-obj.obj-code = v-cntxt-obj-code  and
                   buf_gds-obj.gds-code = buf_goods.gds-code     no-error .

        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input imp-save
          , input buf_goods.gds-code
          , input ( if available buf_gds-obj and buf_gds-obj.price-sale <> 0 then buf_gds-obj.price-sale else v-price / bf_bar-code.cli-base-rate )
          ) no-error.
          if error-status :error then do:
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               "Создание основного кода для неосновного"
               view-as alert-box error
             .
          end.
         /* +++++++++++ */
        end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
        if available buf_price-doc-forming-gds then do:
           delete buf_price-doc-forming-gds .
        end.
        assign
          imp-save = imp-save + 1
          v-sec =  v-sec + 1
        .
        run create-line-pdf-mpl-lib (
             input buf_price-doc-forming.plt-db-num
            ,input buf_price-doc-forming.plt-id
            ,input buf_price-doc-forming.pdf-db
            ,input buf_price-doc-forming.pdf-id
            ,input imp-save
            ,input bf_bar-code.b-code
            ,input buf_goods.artic
            ,input buf_goods.prod-type
            ,input buf_goods.prod-code
            ,input ""
            ,input 0
            ,input v-price
            ,input ""
            ,input 0
            ,input-output v-sec ) no-error .
            if error-status :error then do:
               message
                 vss-workfile vss-revision vss-description skip
                 error-status :get-message(1) skip
                 return-value skip
                 "неосновной код"
                 view-as alert-box error
               .
            end.
        /* Подправим скидку по неосновному коду */
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code
                   no-error .

        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code
                   no-error .

        if available buf_price-doc-forming-gds then do:
           buf_price-doc-forming-gds.d-pcnt =
           (( (main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) - v-price  ) * 100) /
             ( main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) no-error .

        end.
        end. /* НЕОСНОВНОЙ  */
  end.
  input stream imp close.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
empty temp-table tt_price-doc-forming-gds-xxx .
empty temp-table tt-gds-list .
empty temp-table tt-table1 .
empty temp-table tt-table2 .
empty temp-table tt-table3 .

if p-mode <> {&lookup} then do:
   p-next-prev = no.
end.

find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
/* Параметры из секции ПЕРЕОЦЕНКА */
define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
      ) no-error .

/* ИСПОЛЬЗУЕМЫЙ Тип прайс-листа */
if p-mode = {&lookup} then do:
   find first ub.price-doc-forming no-lock where recid(ub.price-doc-forming) = p-doc-rec no-error .
    find first  buf-price-list-type no-lock where
                buf-price-list-type.plt-id     = ub.price-doc-forming.plt-id and
                buf-price-list-type.plt-db-num = ub.price-doc-forming.plt-db-num no-error .
end.
else do:
    find first  buf-price-list-type no-lock where
                buf-price-list-type.plt-id     = p-plt-id and
                buf-price-list-type.plt-db-num = p-plt-db-num no-error .
end.

{ gbl/conf-rd.i "'is-pharm'" v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code "''" "''" "''" no par-is-pharm par-type no-error}.
  if par-is-pharm <> "yes" then par-is-pharm = "no" .
  else do:
     { str/opharm.i v-cntxt-obj-type v-cntxt-obj-code par-is-pharm }
  end.

/* Метод расчета и округления по умолчанию */


define variable p-list as character no-undo .
run str/pr-listv.p
    (input {&pr-calc-methods-inf-DFP}  ,
     input {&pr-calc-fix},
     output p-list
     ) .
calc-method:list-items in frame {&frame-name}  = p-list .

  round-method:list-items in frame {&frame-name}  =
  {&pr-round-9end} + "," + {&pr-round-9-99end} + "," + {&pr-round-integer} + "," + {&pr-round-select} + "," + {&pr-round-up} + "," + {&pr-round-coef} + "," + {&pr-round-off} .

assign
  calc-method  = buf-price-list-type.calc-method
  increase-pc  = buf-price-list-type.calc-increase-pc
  round-method = buf-price-list-type.calc-round-method
  round-base   = buf-price-list-type.calc-round-base
.

/* Баз вал */
if /* ( v-base-code <> 0 and buf-price-list-type.fix-cource-crc-base = true ) or buf-price-list-type.main = true */ true = true then do:
  { gbl/exchrate.i
    v-base-code
    TODAY
    FILL-IN_base-rate
    FILL-IN_base-scale
    v-curr-abbr-bv }
    v-base-rate  = FILL-IN_base-rate .
    v-base-scale = FILL-IN_base-scale .
end.

/* Вал док */
if /* ( buf-price-list-type.curr-code <> 0 and buf-price-list-type.fix-cource-crc-doc = true ) or buf-price-list-type.main */ true = true    then do:
  { gbl/exchrate.i
    buf-price-list-type.curr-code
    TODAY
    FILL-IN_exch-rate
    FILL-IN_exch-scale
    v-curr-abbr-vd }
    v-exch-rate  = FILL-IN_exch-rate  .
    v-exch-scale = FILL-IN_exch-scale .
end.

/* Создание шапки документа  */
if p-mode = {&add-def} then do:
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = buf-price-list-type.plt-id
      ub.price-doc-forming.plt-db-num   = buf-price-list-type.plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , {&db-name_schema})
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = FILL-IN_base-rate
      ub.price-doc-forming.base-scale   = FILL-IN_base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = FILL-IN_exch-rate
      ub.price-doc-forming.exch-scale   = FILL-IN_exch-scale
      ub.price-doc-forming.stts         = integer({&pdf-new})
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "@"
      p-rec-list   = string(recid(ub.price-doc-forming))
      p-doc-rec    = recid(ub.price-doc-forming)
      FILL-IN_name = ( if buf-price-list-type.ban-discnt > 0 then "Скидочное ДНЦ:" + string(buf-price-list-type.ban-discnt) else "@" )
   .

   find first buf_price-doc-forming  exclusive-lock where
        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db       no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Поиск"
          view-as alert-box error
        .

end.

if p-mode = {&update} then do:
   find first ub.price-doc-forming no-lock where recid(ub.price-doc-forming) = p-doc-rec no-error .
   find first buf_price-doc-forming  exclusive-lock where
        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db        no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "корректировка"
          view-as alert-box error
        .

end.
if p-mode = {&lookup} then do:
   find first ub.price-doc-forming no-lock where recid(ub.price-doc-forming) = p-doc-rec no-error .
   find first buf_price-doc-forming  no-lock  where
        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db        no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "просмотр"
          view-as alert-box error
        .

end.

if p-mode = {&lookup}  or
   p-mode = {&update}   then do:
   assign
      FILL-IN_name              =   buf_price-doc-forming.name
      FILL-IN_have-start-period =   logical ( buf_price-doc-forming.have-start-period )
      FILL-IN_start-sys-date    =   buf_price-doc-forming.start-sys-date
      FILL-IN_start-shift-num   =   buf_price-doc-forming.start-shift-num
      FILL-IN_start-shift-name  =   buf_price-doc-forming.start-shift-name
      FILL-IN_start-date        =   buf_price-doc-forming.start-date
      FILL-IN_start-shift-date  =   buf_price-doc-forming.start-shift-date
      FILL-IN_have-end-period   =   logical ( buf_price-doc-forming.have-end-period  )
      FILL-IN_end-sys-date      =   buf_price-doc-forming.end-sys-date
      FILL-IN_end-shift-num     =   buf_price-doc-forming.end-shift-num
      FILL-IN_end-date          =   buf_price-doc-forming.end-date
      FILL-IN_end-shift-date    =   buf_price-doc-forming.end-shift-date
      FILL-IN_base-rate         =   buf_price-doc-forming.base-rate
      FILL-IN_base-scale        =   buf_price-doc-forming.base-scale
      FILL-IN_exch-rate         =   buf_price-doc-forming.exch-rate
      FILL-IN_exch-scale        =   buf_price-doc-forming.exch-scale .
      l-loc-hour                =   integer(entry(1, string (buf_price-doc-forming.start-sys-time, "HH:MM"), ":")) no-error.
      l-loc-hour-2              =   integer(entry(1, string (buf_price-doc-forming.end-sys-time,   "HH:MM"), ":")) no-error.
      l-loc-min                 =   integer(entry(2, string (buf_price-doc-forming.start-sys-time, "HH:MM"), ":")) no-error.
      l-loc-min-2               =   integer(entry(2, string (buf_price-doc-forming.end-sys-time,   "HH:MM"), ":")) no-error.

  run select-xxx-line in this-procedure .

 end.

 if v-exch-scale = 0  or v-exch-scale = ? then do:
  { gbl/exchrate.i
    buf-price-list-type.curr-code
    today
    v-exch-rate
    v-exch-scale
    v-curr-abbr-vd }
 end.
 if v-base-scale = 0 and v-base-scale = ? then do:
  { gbl/exchrate.i
    v-base-code
    today
    v-base-rate
    v-base-scale
    v-curr-abbr-bv }
  end.

 frame {&frame-name}:TITLE = "Документ назначения цены № "
                            + string(buf_price-doc-forming.pdf-id)
                            + " БД:"
                            + string(buf_price-doc-forming.pdf-db)
                            + " -- "
                            + caps(p-mode)    .

    /* список объектов */
    if buf-price-list-type.gop-id <> 0 then do:
        run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .
        for each x_obj-group :
          create tt-table1.
          assign
            tt-table1.f1    = x_obj-group.obj-type + " " + string(x_obj-group.obj-code)
            tt-table1.f2    = x_obj-group.obj-name
            tt-table1.f3    = ""
            tt-table1.f4    = ""
            v-last-obj-type = x_obj-group.obj-type
            v-last-obj-code = x_obj-group.obj-code
          .
        end.
    end.
    else do:
       run metod-gop-obj in this-procedure ( v-cntxt-db-num, buf-price-list-type.gop-id , buf-price-list-type.gop-db-num ) .
       disable b-obj with frame {&frame-name} .
       assign
        v-last-obj-type = v-cntxt-obj-type
        v-last-obj-code = v-cntxt-obj-code
       .
    end.

    /* список групп */
    define buffer buf_gds-grp for ub.gds-grp  .
    define buffer buf_price-list-type-gds-grp for ub.price-list-type-gds-grp  .
    define variable v-name as character no-undo .

    if buf-price-list-type.use-gds-group <> 0 then do:
          for each  buf_price-list-type-gds-grp no-lock where
                    buf_price-list-type-gds-grp.plt-id      = buf-price-list-type.plt-id and
                    buf_price-list-type-gds-grp.plt-db-num  = buf-price-list-type.plt-db-num
                    :

            find first buf_gds-grp no-lock where  buf_gds-grp.node-code = buf_price-list-type-gds-grp.node-code no-error .
            if available buf_gds-grp then do:
                create tt-table2.
                assign
                  tt-table2.f3 = ""
                  tt-table2.f4 = ""
                .
               { gbl/grpgdsnm.i buf_gds-grp.node-code v-name}
                assign
                  tt-table2.f1 = ""
                  tt-table2.f2 = v-name
                .
            end.
          end.
    end.
    else disable b-grp with frame {&frame-name} .

define buffer buf_buyer-group for ub.buyer-group  .
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_clients for ub.clients  .

    /* по группе ПОКУПАТЕЛЕЙ */
    if buf-price-list-type.bgr-id <> 0 then do:
          for each  buf_buyer-group no-lock where
                    buf_buyer-group.bgr-id      = buf-price-list-type.bgr-id and
                    buf_buyer-group.bgr-db-num  = buf-price-list-type.bgr-db-num
                    :
                for each buf_buyer-in-buyer-group no-lock where
                         buf_buyer-in-buyer-group.bgr-id      = buf_buyer-group.bgr-id     and
                         buf_buyer-in-buyer-group.bgr-db-num  = buf_buyer-group.bgr-db-num
                         :
                    v-bgr-name = buf_buyer-group.name .
                    find first buf_clients no-lock where
                               buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type and
                               buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code no-error .
                    if available buf_clients then do:
                        create tt-table3.
                        assign
                          tt-table3.f1 = buf_clients.obj-type + string(buf_clients.obj-code)
                          tt-table3.f2 = buf_clients.obj-name
                          tt-table3.f3 = ""
                          tt-table3.f4 = ""
                        .
                          end.
                end.
          end.
    end.
    else disable b-cust with frame {&frame-name} .

    /* Есть цены на неосновные коды */
    if buf_global-state.pl-use-add-code = false then do:
       hide b-alt in frame {&frame-name} .
    end.
    else do:
        if logical(buf-price-list-type.have-rs-qnty-group) = true  or
                   buf-price-list-type.have-rs-sum-group   = true  or
           logical(buf-price-list-type.have-rs-turn-group) = true then do:
              disable b-alt with frame {&frame-name} .
           end.
           else do:
              enable b-alt with frame {&frame-name} .
           end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame
PROCEDURE local-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if not available buf_price-doc-forming-gds then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i buf_price-doc-forming-gds del-list }
  {&browse-name}:refresh() in frame {&frame-name} .
  run vc-pdf in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-xxx-line Dialog-Frame
PROCEDURE make-xxx-line :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if not available buf_price-doc-forming-gds then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "234"
      view-as alert-box error
    .
    return .
end.
if logical(buf-price-list-type.have-rs-qnty-group) = true then do:
for each  buf_qnty-in-qnty-group   no-lock where
          buf_qnty-in-qnty-group.qgr-id      = buf-price-list-type.qgr-id and
          buf_qnty-in-qnty-group.qgr-db-num  = buf-price-list-type.qgr-db-num and
          buf_qnty-in-qnty-group.stts        = integer({&pdf-new}) :
  find first tt_price-doc-forming-gds-xxx where
      tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num and
      tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id     and
      tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db     and
      tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id     and
      tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code     and
      tt_price-doc-forming-gds-xxx.qgr-id      = buf_qnty-in-qnty-group.qgr-id       and
      tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_qnty-in-qnty-group.qgr-db-num   and
      tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_qnty-in-qnty-group.ggr-qnty
      no-error .

       if not available tt_price-doc-forming-gds-xxx  then do:
          create tt_price-doc-forming-gds-xxx .
          BUFFER-COPY buf_price-doc-forming-gds TO tt_price-doc-forming-gds-xxx
          assign
              tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num
              tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id
              tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db
              tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id
              tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code
              tt_price-doc-forming-gds-xxx.qgr-id      = buf_qnty-in-qnty-group.qgr-id
              tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_qnty-in-qnty-group.qgr-db-num
              tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_qnty-in-qnty-group.ggr-qnty
          .
       end.

        if buf_qnty-in-qnty-group.use-discnt or buf_qnty-in-qnty-group.discnt-pc <> ? then do :
           tt_price-doc-forming-gds-xxx.d-pcnt   = buf_qnty-in-qnty-group.discnt-pc .
        end.
        else do:
           tt_price-doc-forming-gds-xxx.d-pcnt   =  0 .
        end.
        /* пересчитать цены по количествам  */
        assign
          tt_price-doc-forming-gds-xxx.price-sale-doc   = buf_price-doc-forming-gds.price-sale-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.price-calc-doc   = buf_price-doc-forming-gds.price-calc-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.road-tax-doc     = buf_price-doc-forming-gds.road-tax-doc   * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
        .
  /* Пересчет по курсу валюты док */
  assign
    tt_price-doc-forming-gds-xxx.price-calc-rubl = tt_price-doc-forming-gds-xxx.price-calc-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-sale-rubl = tt_price-doc-forming-gds-xxx.price-sale-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.road-tax-rubl   = tt_price-doc-forming-gds-xxx.road-tax-doc   * v-exch-rate / v-exch-scale
    /* Пересчет по курсу валюты док */
    tt_price-doc-forming-gds-xxx.price-calc-base = tt_price-doc-forming-gds-xxx.price-calc-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.price-sale-base = tt_price-doc-forming-gds-xxx.price-sale-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.road-tax-base   = tt_price-doc-forming-gds-xxx.road-tax-rubl   / v-base-rate * v-base-scale
  .
end. /* for each */
end.
/*-------*/
if buf-price-list-type.have-rs-sum-group = true then do:
for each  buf_sum-in-sum-group   no-lock where
          buf_sum-in-sum-group.sgr-id      = buf-price-list-type.sgr-id     and
          buf_sum-in-sum-group.sgr-db-num  = buf-price-list-type.sgr-db-num and
          buf_sum-in-sum-group.stts        = integer({&pdf-new}) :
  find first tt_price-doc-forming-gds-xxx where
      tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num and
      tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id     and
      tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db     and
      tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id     and
      tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code     and
      tt_price-doc-forming-gds-xxx.qgr-id      = buf_sum-in-sum-group.sgr-id       and
      tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_sum-in-sum-group.sgr-db-num   and
      tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_sum-in-sum-group.ssg-summa
      no-error .

       if not available tt_price-doc-forming-gds-xxx  then do:
          create tt_price-doc-forming-gds-xxx .
          BUFFER-COPY buf_price-doc-forming-gds TO tt_price-doc-forming-gds-xxx
          assign
              tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num
              tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id
              tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db
              tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id
              tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code
              tt_price-doc-forming-gds-xxx.qgr-id      = buf_sum-in-sum-group.sgr-id
              tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_sum-in-sum-group.sgr-db-num
              tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_sum-in-sum-group.ssg-summa
          .
       end.
        if buf_sum-in-sum-group.use-discnt or buf_sum-in-sum-group.discnt-pc <> ? then do :
           tt_price-doc-forming-gds-xxx.d-pcnt   = buf_sum-in-sum-group.discnt-pc .
        end.
        else do:
           tt_price-doc-forming-gds-xxx.d-pcnt   =  0 .
        end.
        /* пересчитать цены по количествам  */
        assign
          tt_price-doc-forming-gds-xxx.price-sale-doc = buf_price-doc-forming-gds.price-sale-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.price-calc-doc = buf_price-doc-forming-gds.price-calc-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.road-tax-doc   = buf_price-doc-forming-gds.road-tax-doc   * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
        .
  /* Пересчет по курсу валюты док */
  assign
    tt_price-doc-forming-gds-xxx.price-calc-rubl = tt_price-doc-forming-gds-xxx.price-calc-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-sale-rubl = tt_price-doc-forming-gds-xxx.price-sale-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.road-tax-rubl   = tt_price-doc-forming-gds-xxx.road-tax-doc   * v-exch-rate / v-exch-scale
    /* Пересчет по курсу валюты док */
    tt_price-doc-forming-gds-xxx.price-calc-base = tt_price-doc-forming-gds-xxx.price-calc-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.price-sale-base = tt_price-doc-forming-gds-xxx.price-sale-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.road-tax-base   = tt_price-doc-forming-gds-xxx.road-tax-rubl   / v-base-rate * v-base-scale
  .
end. /* for each */
end.
/*-------*/
if logical(buf-price-list-type.have-rs-turn-group) = true then do:
for each  buf_tnv-in-tnv-group   no-lock where
          buf_tnv-in-tnv-group.tog-id      = buf-price-list-type.have-tog-id     and
          buf_tnv-in-tnv-group.tog-db-num  = buf-price-list-type.have-tog-db-num and
          buf_tnv-in-tnv-group.stts        = integer({&pdf-new}) :

  find first tt_price-doc-forming-gds-xxx where
      tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num and
      tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id     and
      tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db     and
      tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id     and
      tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code     and
      tt_price-doc-forming-gds-xxx.qgr-id      = buf_tnv-in-tnv-group.tog-id       and
      tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_tnv-in-tnv-group.tog-db-num   and
      tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_tnv-in-tnv-group.ttg-summa
      no-error .

       if not available tt_price-doc-forming-gds-xxx  then do:
          create tt_price-doc-forming-gds-xxx .
          BUFFER-COPY buf_price-doc-forming-gds TO tt_price-doc-forming-gds-xxx
          assign
              tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num
              tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id
              tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db
              tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id
              tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code
              tt_price-doc-forming-gds-xxx.qgr-id      = buf_tnv-in-tnv-group.tog-id
              tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_tnv-in-tnv-group.tog-db-num
              tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_tnv-in-tnv-group.ttg-summa
          .
       end.
        if buf_tnv-in-tnv-group.use-discnt or buf_tnv-in-tnv-group.discnt-pc <> ? then do :
           tt_price-doc-forming-gds-xxx.d-pcnt   = buf_tnv-in-tnv-group.discnt-pc .
        end.
        else do:
           tt_price-doc-forming-gds-xxx.d-pcnt   =  0 .
        end.
        /* пересчитать цены по группировке  */
        assign
          tt_price-doc-forming-gds-xxx.price-sale-doc = buf_price-doc-forming-gds.price-sale-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.price-calc-doc = buf_price-doc-forming-gds.price-calc-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.road-tax-doc   = buf_price-doc-forming-gds.road-tax-doc   * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
        .
  /* Пересчет по курсу валюты док */
  assign
    tt_price-doc-forming-gds-xxx.price-calc-rubl = tt_price-doc-forming-gds-xxx.price-calc-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-sale-rubl = tt_price-doc-forming-gds-xxx.price-sale-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.road-tax-rubl   = tt_price-doc-forming-gds-xxx.road-tax-doc   * v-exch-rate / v-exch-scale
    /* Пересчет по курсу валюты док */
    tt_price-doc-forming-gds-xxx.price-calc-base = tt_price-doc-forming-gds-xxx.price-calc-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.price-sale-base = tt_price-doc-forming-gds-xxx.price-sale-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.road-tax-base   = tt_price-doc-forming-gds-xxx.road-tax-rubl   / v-base-rate * v-base-scale
  .
end. /* for each */
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
v-sec = 0 .
hide b-prev in frame {&frame-name}
     b-next in frame {&frame-name}
     loc-name
     loc-code
.
/* Баз вал */
if v-base-code <> 0 and buf-price-list-type.fix-cource-crc-base = true  then do:
  enable FILL-IN_base-rate  FILL-IN_base-scale with frame {&frame-name}   .
end.
else do:
   hide FILL-IN_base-rate FILL-IN_base-scale v-curr-abbr-bv in frame {&frame-name} .
end.

/* Вал док */
if buf-price-list-type.curr-code <> 0 and buf-price-list-type.fix-cource-crc-doc = true  then do:
  enable FILL-IN_exch-rate  FILL-IN_exch-scale with frame {&frame-name}    .
end.
else do:
   hide FILL-IN_exch-rate FILL-IN_exch-scale v-curr-abbr-vd in frame {&frame-name} .
end.
/* round */
run proc-value-2 in this-procedure .
/* Исходная */
run proc-value-1 in this-procedure .
/* Ограничение на начало периода */
run proc-start-o in this-procedure .
/* Ограничение на конец периода */
run proc-end-o   in this-procedure .
/* второй браус      --------------------------------------------------------------------------------------------------- */
if logical ( buf-price-list-type.have-rs-qnty-group ) = true  or
             buf-price-list-type.have-rs-sum-group    = true  or
  logical  ( buf-price-list-type.have-rs-turn-group ) = true  then do:
     enable browse-2 with frame {&frame-name} .
     if buf-price-list-type.under-hand-corr = 0 then
        tt_price-doc-forming-gds-xxx.price-sale-doc:read-only in browse browse-2 = true .
       if           buf-price-list-type.have-rs-sum-group    = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Суммы" .
       if logical  ( buf-price-list-type.have-rs-turn-group ) = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Обороты" .
     browse-1:HEIGHT-CHARS in frame {&frame-name}  = 7.75.
   end.
   else do:
     browse-1:HEIGHT-CHARS in frame {&frame-name}  = 12.5.
     hide browse-2 in frame {&frame-name} .
   end.

/* --------------------------------------------------------------------------------------------------------------------- */

    /* список объектов */
    if buf-price-list-type.gop-id <> 0 then do:
    end.
    else disable b-obj with frame {&frame-name} .

    /* список групп */
    if buf-price-list-type.use-gds-group <> 0 then do:
    end.
    else disable b-grp with frame {&frame-name} .
    /* Список покупателей */
    if buf-price-list-type.bgr-id <> 0 then do:
    end.
    else disable b-cust with frame {&frame-name} .



  buf_price-doc-forming-gds.artic:RESIZABLE  in browse browse-1  = true .
  {&cop-l5} :RESIZABLE                       in browse browse-1  = true .
  buf_bar-code.unit-cli:RESIZABLE            in browse browse-1  = true .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_lookup Dialog-Frame
PROCEDURE my_lookup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

if  p-recid-gds <> ? then do:
    reposition BROWSE-1 to recid p-recid-gds no-error .
end.
hide calc-method  in  frame {&frame-name}
     b-add b-del b-special b-chg b-log b-import b-mark b-sel-all b-unmark
     loc-name
     loc-code
     increase-pc round-method round-base in  frame {&frame-name} .
if FILL-IN_have-start-period:visible then disable FILL-IN_have-start-period with frame {&frame-name} .
if FILL-IN_have-end-period:visible then disable FILL-IN_have-end-period with frame {&frame-name} .
disable FILL-IN_name FILL-IN_base-rate FILL-IN_base-scale FILL-IN_exch-rate FILL-IN_exch-scale  with frame {&frame-name} .

run proc-start-o in this-procedure .
/* Ограничение на конец периода */
run proc-end-o   in this-procedure .

/* второй браус */
if logical(buf-price-list-type.have-rs-qnty-group) = true  or
           buf-price-list-type.have-rs-sum-group   = true  or
   logical(buf-price-list-type.have-rs-turn-group) = true
   then do:
     display browse-2 with frame {&frame-name} .
     tt_price-doc-forming-gds-xxx.price-sale-doc:read-only in browse browse-2 = true .
     browse-1:HEIGHT-CHARS in frame {&frame-name}  = 7.75.
   end.
   else do:
     browse-1:HEIGHT-CHARS in frame {&frame-name}  = 12.5.
     hide browse-2 in frame {&frame-name} .
   end.

    /* список объектов */
    if buf-price-list-type.gop-id <> 0 then do:
    end.
    else disable b-obj with frame {&frame-name} .

    /* список групп */
    if buf-price-list-type.use-gds-group <> 0 then do:
    end.
    else disable b-grp with frame {&frame-name} .
   {&cop-l7}:read-only in browse browse-1 = true .

    /* Список покупателей */
    if buf-price-list-type.bgr-id <> 0 then do:
    end.
    else disable b-cust with frame {&frame-name} .

  buf_price-doc-forming-gds.artic:RESIZABLE  in browse browse-1  = true .
  {&cop-l5} :RESIZABLE                       in browse browse-1  = true .
  buf_bar-code.unit-cli:RESIZABLE            in browse browse-1  = true .
/* второй браус      --------------------------------------------------------------------------------------------------- */
if logical ( buf-price-list-type.have-rs-qnty-group ) = true  or
             buf-price-list-type.have-rs-sum-group    = true  or
  logical  ( buf-price-list-type.have-rs-turn-group ) = true  then do:
     enable browse-2 with frame {&frame-name} .
     if buf-price-list-type.under-hand-corr = 0 then
        tt_price-doc-forming-gds-xxx.price-sale-doc:read-only in browse browse-2 = true .
       if           buf-price-list-type.have-rs-sum-group    = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Суммы" .
       if logical  ( buf-price-list-type.have-rs-turn-group ) = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Обороты" .
     browse-1:HEIGHT-CHARS in frame {&frame-name}  = 7.75.
   end.
   else do:
     browse-1:HEIGHT-CHARS in frame {&frame-name}  = 12.5.
     hide browse-2 in frame {&frame-name} .
   end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE new-price-sub Dialog-Frame
PROCEDURE new-price-sub :
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-pdf-db     as integer   no-undo .
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-artic      as character no-undo .
define input  parameter p-prod-type  as character no-undo .
define input  parameter p-prod-code  as integer   no-undo .


define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .

for each buf2_price-doc-forming-gds no-lock where
        buf2_price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
        buf2_price-doc-forming-gds.plt-id      =  p-plt-id     and
        buf2_price-doc-forming-gds.pdf-db      =  p-pdf-db     and
        buf2_price-doc-forming-gds.pdf-id      =  p-pdf-id     and
        buf2_price-doc-forming-gds.artic       =  p-artic      and
        buf2_price-doc-forming-gds.prod-type   =  p-prod-type  and
        buf2_price-doc-forming-gds.prod-code   =  p-prod-code  :

  find first buf_price-doc-forming-gds no-lock  where
             buf_price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
             buf_price-doc-forming-gds.plt-id      =  p-plt-id     and
             buf_price-doc-forming-gds.pdf-db      =  p-pdf-db     and
             buf_price-doc-forming-gds.pdf-id      =  p-pdf-id     and
             buf_price-doc-forming-gds.b-code      =  buf2_price-doc-forming-gds.b-code
             no-error .
    run make-xxx-line in this-procedure .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open1 Dialog-Frame
PROCEDURE open1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 OPEN QUERY browse-1 FOR EACH buf_price-doc-forming-gds OF buf_price-doc-forming NO-LOCK,
             EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,
             EACH buf_bar-code OF buf_price-doc-forming-gds no-lock
             by buf_price-doc-forming-gds.artic
             by buf_bar-code.node-code
             by buf_price-doc-forming-gds.line-num.
run vc-pdf in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.


{&SetCursorWait}
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  when "v-name" then do:
    assign
      sort-column-phrase = 'by Buf_goods.gds-name' .
    .
  end.

  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY BROWSE-1 FOR EACH buf_price-doc-forming-gds no-lock

&scop flt-open-dyn_open-query  FOR EACH buf_price-doc-forming-gds

&scop flt-open-query-handle query BROWSE-1:handle

&scop flt-open-find-buffer-name buf_price-doc-forming-gds

&scop flt-open-open-query-tail   , EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK, ~
                                   EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK


&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_price-doc-forming-gds

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .
case R-mode-code :
when 1 then do:
&scop flt-open-open-query-tail   , EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK, ~
                                   EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK

  { gbl/fltopend.i
    &where-cond = " buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and  ~
                    buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and ~
                    buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and ~
                    buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db "
    &dyn_where-cond =
                   " substitute ( ' ~
                    buf_price-doc-forming-gds.plt-id     = &1 and ~
                    buf_price-doc-forming-gds.plt-db-num = &2 and ~
                    buf_price-doc-forming-gds.pdf-id     = &3 and ~
                    buf_price-doc-forming-gds.pdf-db     = &4 ' , ~
                    buf_price-doc-forming.plt-id , ~
                    buf_price-doc-forming.plt-db-num , ~
                    buf_price-doc-forming.pdf-id , ~
                    buf_price-doc-forming.pdf-db ) "

    &use-ind    = " "
    &by         = " by buf_price-doc-forming-gds.line-num  "  }
end.
when 2 then do:
&scop flt-open-open-query-tail   , EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK, ~
                                   EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK ~
                                   where buf_goods.unit-base = buf_bar-code.unit-cli

  { gbl/fltopend.i
    &where-cond = " buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and  ~
                    buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and ~
                    buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and ~
                    buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db "
    &dyn_where-cond =
                   " substitute ( ' ~
                    buf_price-doc-forming-gds.plt-id     = &1 and ~
                    buf_price-doc-forming-gds.plt-db-num = &2 and ~
                    buf_price-doc-forming-gds.pdf-id     = &3 and ~
                    buf_price-doc-forming-gds.pdf-db     = &4 ' , ~
                    buf_price-doc-forming.plt-id , ~
                    buf_price-doc-forming.plt-db-num , ~
                    buf_price-doc-forming.pdf-id , ~
                    buf_price-doc-forming.pdf-db ) "

    &use-ind    = " "
    &by         = " by buf_price-doc-forming-gds.line-num  "  }
end.
end case.

run vc-pdf in this-procedure .
if not p-open-query then
reposition browse-1 to recid doc-rec no-error.

if not p-open-query and v-fltopend-rowid[1] <> ? then
query browse-1:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

if logical(buf-price-list-type.have-rs-qnty-group) = true  or
           buf-price-list-type.have-rs-sum-group   = true  or
   logical(buf-price-list-type.have-rs-turn-group) = true then do:
  {&OPEN-QUERY-BROWSE-2}
end.
{&SetCursorNo}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-gds Dialog-Frame
PROCEDURE proc-add-gds :
define input  parameter p-mode   as integer   no-undo .
define input  parameter p-b-code as integer   no-undo .

define buffer buf_goods for ub.goods  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_price-list for ub.price-list  .
define buffer buf_gds-obj for ub.gds-obj  .

/*
mode 1 - добавление новых товаров и расчет
mode 2 - расчет по списку
mode 3 - расчет по 1 признаку по p-b-code
mode 4 - добавление товаров по партиям из указанной накладной
*/

assign  frame {&frame-name}
  calc-method
  increase-pc
  round-method
  round-base
  doc-code
  copy-code
  copy-type
  common-price
  .


define buffer buf1_price-list-type-gds-grp for ub.price-list-type-gds-grp  .
define buffer buf2_price-doc-forming-gds   for ub.price-doc-forming-gds  .
define buffer bufo_price-doc-forming-gds   for ub.price-doc-forming-gds.
define buffer bufo_price-doc-forming       for ub.price-doc-forming  .

define variable varschartic as character no-undo .
define variable ref-list    as character no-undo .
define variable stp-cycl as logical   no-undo .
if p-mode = 4 then do:
    if par-is-pharm = "yes" then do:
    for each buf_doc-line no-lock where buf_doc-line.doc-code = doc-code :
        find first buf_goods no-lock where
                   buf_goods.artic     = buf_doc-line.artic and
                   buf_goods.prod-type = buf_doc-line.prod-type and
                   buf_goods.prod-code = buf_doc-line.prod-code no-error .
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = v-cntxt-obj-type and
                   buf_gds-obj.obj-code = v-cntxt-obj-code and
                   buf_gds-obj.gds-code = buf_goods.gds-code  and
                   buf_gds-obj.fact-qnty <> 0
                   no-error .
        if not available buf_gds-obj then  next.
        find first tt-gds-list where tt-gds-list.gds-code = buf_goods.gds-code no-error .
        if not available tt-gds-list then do:
            create tt-gds-list.
            buffer-copy buf_goods to tt-gds-list .
        end.
    end.
    end.
end.
else do:
  if not ( calc-method = {&pr-calc-wbill} or
           calc-method = {&pr-calc-wbill-novat} or
           calc-method = {&pr-calc-slt-wbill} or
           calc-method = {&pr-calc-ov} or
           calc-method = {&pr-calc-pdf}
           )
  then do:
    if p-mode = 1 then do:
            run str/chsgdsls.w
            (   input parParentProc ,
                input "price-list" ,
                input "Строка документа"  ,
                input ? ,
                input ? ,
                input v-cntxt-host-code-obj ,
                input-output varschartic,
                output ref-list,
                output table tt-gds-list,
                input false
                ) no-error.
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
    end.
  end.
  else do:
      if p-mode <> 2 then do:
      case calc-method :

        when {&pr-calc-pdf} then do:
        find first bufo_price-doc-forming no-lock where
                   bufo_price-doc-forming.pdf-id = integer(entry( 1 , doc-code , "|" )) and
                   bufo_price-doc-forming.pdf-db = integer(entry( 2 , doc-code , "|" )) no-error .
          if available bufo_price-doc-forming then do:
          for each bufo_price-doc-forming-gds no-lock where
                   bufo_price-doc-forming-gds.pdf-id = bufo_price-doc-forming.pdf-id and
                   bufo_price-doc-forming-gds.pdf-db = bufo_price-doc-forming.pdf-db and
                   bufo_price-doc-forming-gds.plt-id = bufo_price-doc-forming.plt-id and
                   bufo_price-doc-forming-gds.plt-db-num = bufo_price-doc-forming.plt-db-num
                  :
              find first buf_goods no-lock where
                         buf_goods.artic     = bufo_price-doc-forming-gds.artic     and
                         buf_goods.prod-type = bufo_price-doc-forming-gds.prod-type and
                         buf_goods.prod-code = bufo_price-doc-forming-gds.prod-code
                         no-error .
              find first tt-gds-list where
                         tt-gds-list.gds-code = buf_goods.gds-code
                         no-error .
              if not available tt-gds-list then do:
                create tt-gds-list.
                buffer-copy buf_goods to tt-gds-list .
              end.
          end.
          end.
        end.

        when {&pr-calc-ov} then do:
          for each buf_price-list no-lock where buf_price-list.doc-num = doc-code :
              find first buf_goods no-lock where
                        buf_goods.artic     = buf_price-list.artic and
                        buf_goods.prod-type = buf_price-list.prod-type and
                        buf_goods.prod-code = buf_price-list.prod-code no-error .
              find first tt-gds-list where tt-gds-list.gds-code = buf_goods.gds-code no-error .
              if not available tt-gds-list then do:
                  create tt-gds-list.
                  buffer-copy buf_goods to tt-gds-list .
              end.
          end.
        end.
        when {&pr-calc-wbill} or
        when {&pr-calc-wbill-novat} then do:
          for each buf_doc-line no-lock where buf_doc-line.doc-code = doc-code by buf_doc-line.line-num :
              find first buf_goods no-lock where
                        buf_goods.artic     = buf_doc-line.artic and
                        buf_goods.prod-type = buf_doc-line.prod-type and
                        buf_goods.prod-code = buf_doc-line.prod-code no-error .
              find first tt-gds-list where tt-gds-list.gds-code = buf_goods.gds-code no-error .
              if not available tt-gds-list then do:
                  create tt-gds-list.
                  buffer-copy buf_goods to tt-gds-list .
              end.
          end.
        end.
       otherwise do:
       end.
       end case.

    end.
  end.
end.

/* есть ограничение по группе  ограничение по ТПЛ */
if  logical(buf-price-list-type.use-gds-group) = true then do:
    for each tt-gds-list :
        find first tt-table2 no-lock where  ( tt-gds-list.grp-name begins tt-table2.f2 ) no-error .
        if not available tt-table2 then do:
           delete tt-gds-list .
        end.
    end.
end.

if p-mode = 1 or p-mode = 4 then do: /* Добавление */
    run ver-pr-conf no-error .
    if error-status :error then return error return-value .

    run last-num in this-procedure (
        input recid(buf_price-doc-forming) ,
        output v-line-num )
        .
end.

/* Ограничение по виду товаров */
define variable v-type-goods as integer   no-undo .
define variable i as integer   no-undo .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .
define variable v-next as logical   no-undo .


if par-pr-goods = "" or num-entries (par-pr-goods,".") <> 2 then v-type-goods = integer({&pr-gds-ino-ban}) .
repeat i = 1 to 8 :
  if par-pr-goods begins string(i) + "."  then  do:
     v-type-goods = i .
     leave.
  end.
end.
define variable v-errr as logical   no-undo .
define variable v-errstr as character no-undo .
v-errr = false .
v-errstr = "" .


define buffer buf1_bar-code for ub.bar-code  .
define buffer gg_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf1_goods for ub.goods  .
for each tt-gds-list ,
    first buf1_bar-code no-lock where
          buf1_bar-code.gds-code   = tt-gds-list.gds-code   and
          buf1_bar-code.in-code    = ""                     and
          buf1_bar-code.part-code  = ""                     and
          buf1_bar-code.unit-cli   = tt-gds-list.unit-base  and
          ( p-mode <> 3 or buf1_bar-code.b-code = p-b-code )
          :
  find buf1_goods   where buf1_goods.gds-code       = tt-gds-list.gds-code no-lock .

    { str/is-petrl.i
      buf1_goods.artic
      buf1_goods.prod-type
      buf1_goods.prod-code
      is-petrolium
      is-pieces
    }

  /* Исключение из Запрета */
  run ver-pr-nogds ( input  buf1_goods.gds-code , input par-pr-nogds, output v-next , output v-errstr ) .

  if not v-next then do:

  case string(v-type-goods) :
    when {&pr-gds-iban}       then do:
      v-errr = true .
      v-errstr = "Запрет на  включение в переоценку товаров, услуг и топлива" .
      leave .
    end.
    when {&pr-gds-ino-ban}    then do:
    end.
    when {&pr-gds-igoods}     then do:
        if buf1_goods.gds-type = {&gds-goods}  and is-petrolium = false  then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление товаров в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
    when {&pr-gds-ipetrol}    then do:
        if is-petrolium then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление топлива в переоценку " , buf1_goods.artic, buf1_goods.gds-name ) .
           next .
        end.
    end.
    when {&pr-gds-iserv}      then do:
        if buf1_goods.gds-type = {&gds-office} then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление услуг в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
    when {&pr-gds-igds-serv}  then do:
        if buf1_goods.gds-type = {&gds-goods} and is-petrolium = false  then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type , buf1_goods.unit-base ) .
           next .
        end.
        if buf1_goods.gds-type = {&gds-office} then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
    when {&pr-gds-igds-ptrl}  then do:
        if buf1_goods.gds-type <> {&gds-office}  then do:
            v-errr = true .
            v-errstr = substitute("Запрет на добавление топлива и товара в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type, buf1_goods.unit-base ) .
           next .
        end.
    end.
    when {&pr-gds-iserv-ptrl} then do:
        if buf1_goods.gds-type = {&gds-goods} and is-petrolium = true   then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.unit-base ) .
           next .
        end.
        if buf1_goods.gds-type = {&gds-office} then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
  end case.
  end.
  else do:
    /* Исключения из запрета тут */
  end.


   run create-calc-bc in this-procedure
       ( input  recid( buf_price-doc-forming )
        ,input  calc-method
        ,input  increase-pc
        ,input  round-method
        ,input  round-base
        ,input  buf1_bar-code.b-code
        ,input  tt-gds-list.gds-code
        ,input  tt-gds-list.artic
        ,input  tt-gds-list.prod-type
        ,input  tt-gds-list.prod-code
        ,input  v-base-rate
        ,input  v-base-scale
        ,input  v-exch-scale
        ,input  v-exch-rate
        ,input  doc-code
        ,input  common-price
        ,input  copy-type
        ,input  copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "create-calc-bc"
        view-as alert-box error
      .

/* развернуть основные и неосновные цены */
define buffer buf-gds-prt  for ub.gds-prt   .
define buffer buf-bar-code for ub.bar-code  .
define buffer buf-goods    for ub.goods     .
define buffer buf_parts for ub.parts  .

define variable cur-recid as recid    no-undo .
define variable cur-pr    as decimal  no-undo .
define variable cur-rt    as decimal  no-undo .
define variable cur-ex    as decimal  no-undo .
define variable new-num   as recid    no-undo .
define variable new-rec   as recid    no-undo .

  find  buf-bar-code no-lock where
        buf-bar-code.b-code = buf1_bar-code.b-code.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find first buf_parts no-lock where
      ( buf_parts.out-code   = {&free-code}  or
        buf_parts.out-code   = buf-bar-code.in-code)  and
        buf_parts.status_    = false   and
        buf_parts.in-code    = buf-bar-code.in-code  and
        buf_parts.part-code  = buf-bar-code.part-code  and
        buf_parts.artic      = buf-goods.artic  and
        buf_parts.prod-type  = buf-goods.prod-type  and
        buf_parts.prod-code  = buf-goods.prod-code no-error .


    if  ( buf-gds-prt.upper-code = buf-goods.prt-root and
          buf-bar-code.in-code   = "" and
          buf-bar-code.part-code = "" and
          buf-bar-code.unit-cli  = buf-goods.unit-base  )
          or
            available buf_parts
          then do:
/* main-price */
/* если цена главная и есть настройки, разворачиваем спеццены */
/* находим номер последнего закрытого ДНЦ */

      { gbl/bc-mpl.i
        buf-price-list-type.gop-id
        buf-price-list-type.gop-db-num
        buf1_bar-code.b-code
        0
        0
        cur-recid
        cur-pr
        cur-rt
        cur-ex
        no-error }
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "от bc-mpl"
          view-as alert-box error
        .
      if cur-pr <> ? then do:
        /* был этот товар в более ранней переоценке */

        run expose-prt in this-procedure
            ( input calc-method ,
              input increase-pc ,
              input buf1_bar-code.b-code,
              input cur-recid    ,  /* старый ДНЦ */
              input recid( buf_price-doc-forming ),
              input round-method ,
              input round-base   ,
              input doc-code     ,
              input common-price ,
              input copy-type    ,
              input copy-code    ,
              input-output v-line-num  ,
              input-output v-sec   ,
              output new-rec) no-error.
              if error-status :error then do:
                message
                  "Ошибка вызова процедуры разворота специальных и неосновных цен."
                  view-as alert-box error.
                undo , return error.
              end.
      end.

        find first gg_price-doc-forming-gds exclusive-lock where
                   gg_price-doc-forming-gds.b-code     = buf1_bar-code.b-code and
                   gg_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                   gg_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                   gg_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                   gg_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
                   no-error .

          if available gg_price-doc-forming-gds and (
              ( calc-method = {&pr-calc-no}
                or
              ( calc-method <> {&pr-calc-no}
                and gg_price-doc-forming-gds.price-sale-doc = ?
                and calc-method <> {&pr-calc-fix}  )))
                and
                ( p-mode = 1 or gg_price-doc-forming-gds.price-sale-doc = ? )
              then do:
                  run str/mplform.w (
                    input  parParentProc ,
                    input  "ЦИКЛ":U    ,
                    input recid (buf_price-doc-forming)    ,
                    input recid (gg_price-doc-forming-gds) ,
                    input increase-pc ,
                    input round-method,
                    input round-base,
                    input calc-method,
                    input v-exch-rate,
                    input v-exch-scale,
                    input v-base-rate ,
                    input v-base-scale,
                    output stp-cycl )
                    no-error .
                    if error-status :error then
                       message error-status :error
                               error-status :get-message(1)
                               "Ошибка mplform"
                               .
                      if return-value = "error" then do:
                          delete gg_price-doc-forming-gds .
                          next.
                      end.
                      /*apply "leave" to {&cop-l7} in browse browse-1 .*/
                   if stp-cycl = true then leave.
              end.
        run recalc-neos (
            gg_price-doc-forming-gds.b-code,
            gg_price-doc-forming-gds.artic,
            gg_price-doc-forming-gds.prod-type,
            gg_price-doc-forming-gds.prod-code
            ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "ошибка пересчета"
                view-as alert-box error
              .
            end.
    end.
    else do: /* main-price = no */
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        /* неосновная цена - нужно для скидки задать нач значение ?, тогда
           она проинициируется из старой переоценки */
        /* buf_price-doc-forming-gds.d-pcnt = ?. */
      end.
    end.

   /* подготовка шаблона по .......енным группам */
  find first buf_price-doc-forming-gds no-lock  where
             buf_price-doc-forming-gds.plt-db-num  =  buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.plt-id      =  buf_price-doc-forming.plt-id     and
             buf_price-doc-forming-gds.pdf-db      =  buf_price-doc-forming.pdf-db     and
             buf_price-doc-forming-gds.pdf-id      =  buf_price-doc-forming.pdf-id     and
             buf_price-doc-forming-gds.b-code      =  buf1_bar-code.b-code
             no-error .
             if error-status :error
             then
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               "123"  skip
               buf_price-doc-forming.plt-db-num   skip
               buf_price-doc-forming.plt-id       skip
               buf_price-doc-forming.pdf-db       skip
               buf_price-doc-forming.pdf-id       skip
               buf1_bar-code.b-code               skip
               view-as alert-box error
             .

        run make-xxx-line in this-procedure no-error .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "make-xxx-line"
          view-as alert-box error
        .
        run calc-price-sub in this-procedure  /*  Пересчитывает неосновные и основные цены */
           (input  buf1_bar-code.b-code ,
            input  recid(buf_price-doc-forming) ,
            input  calc-method,
            input  increase-pc,
            input  round-method,
            input  round-base,
            input  doc-code,
            input  common-price,
            input  copy-type,
            input  copy-code,
            output calc-rec)
            no-error.
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "calc-price-sub"
              view-as alert-box error
            .
    run new-price-sub in this-procedure  (
         buf_price-doc-forming.plt-db-num
       , buf_price-doc-forming.plt-id
       , buf_price-doc-forming.pdf-db
       , buf_price-doc-forming.pdf-id
       , buf1_bar-code.b-code
       , buf-goods.artic
       , buf-goods.prod-type
       , buf-goods.prod-code
    ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "new-price-sub"
        view-as alert-box error
      .
end.

if v-errr = true then
    message
      "Не все выбранные товары были добавлены в переоценку" skip
      v-errstr
      view-as alert-box information .

run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock  where
             buf_price-doc-forming-gds.plt-db-num  =  buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.plt-id      =  buf_price-doc-forming.plt-id     and
             buf_price-doc-forming-gds.pdf-db      =  buf_price-doc-forming.pdf-db     and
             buf_price-doc-forming-gds.pdf-id      =  buf_price-doc-forming.pdf-id     and
             buf_price-doc-forming-gds.line-num    =  v-line-num no-error .
reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to browse-1 in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable varlog as logical   no-undo .
  if not available buf_price-doc-forming-gds then return.
  run local-mark in this-procedure.
  assign varlog = {&browse-name} :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  {&browse-name}:refresh() in frame {&frame-name} .
  run vc-pdf in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-move Dialog-Frame
PROCEDURE proc-b-move :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-action as character no-undo.
define variable  loc#log as logical no-undo .
  assign
  p-doc-rec = recid( buf_price-doc-forming )
  .
  case par-action:
    when "b-next":u then do:
      if valid-handle (p-br-handle) then do:
          loc#log = p-br-handle:select-next-row().
      end.
    end.
    when "b-prev":u then do:
      if valid-handle (p-br-handle) then do:
          loc#log = p-br-handle:select-prev-row().
      end.
    end.
  end case.

  assign p-doc-rec = p-buffer-handle:recid .

  if not loc#log then do:
    message
      "Это" ( if par-action = "b-next":u then "последний" else "первый" )
      "документ в списке!"
    view-as alert-box information.
    return no-apply.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-end-o Dialog-Frame
PROCEDURE proc-end-o :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
   hide FILL-IN_end-shift-date in frame {&frame-name}
        FILL-IN_end-shift-num
        FILL-IN_end-date
        FILL-IN_end-sys-date

        l-loc-hour-2
        l-loc-min-2
        in frame {&frame-name} .

if buf-price-list-type.main = true then do:
   hide FILL-IN_have-end-period in frame {&frame-name} .
   return .
end.

if FILL-IN_have-end-period   =  true then do:
   case buf-price-list-type.work-date:
   when integer( {&mpl-date-obj} ) then do:
      if p-mode <> {&lookup}
      then enable FILL-IN_end-date with frame {&frame-name} .
      display FILL-IN_end-date with frame {&frame-name} .
   end.
   when integer( {&mpl-date-shift} ) then do:
      display FILL-IN_end-shift-date FILL-IN_end-shift-num  with frame {&frame-name} .
      if p-mode <> {&lookup} then enable FILL-IN_end-shift-date FILL-IN_end-shift-num  with frame {&frame-name} .
   end.
   when integer( {&mpl-date-sys} ) then do:
      display FILL-IN_end-sys-date l-loc-hour-2 l-loc-min-2 with frame {&frame-name} .
      if p-mode <> {&lookup} then enable FILL-IN_end-sys-date l-loc-hour-2 l-loc-min-2  with frame {&frame-name} .
   end.
   end case.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-start-o Dialog-Frame
PROCEDURE proc-start-o :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
   hide FILL-IN_start-shift-date in frame {&frame-name}
        FILL-IN_start-shift-num
        FILL-IN_start-date
        FILL-IN_start-sys-date
        l-loc-hour
        l-loc-min
        in frame {&frame-name} .

if buf-price-list-type.main = true then do:
   hide FILL-IN_have-start-period in frame {&frame-name} .
   return .
end.

if FILL-IN_have-start-period  =  true then do:
   case buf-price-list-type.work-date:
   when integer ( {&mpl-date-obj} ) then do:
      display FILL-IN_start-date with frame {&frame-name} .
      if p-mode <> {&lookup} then enable FILL-IN_start-date with frame {&frame-name} .
   end.
   when integer ( {&mpl-date-shift} ) then do:
      display FILL-IN_start-shift-date FILL-IN_start-shift-num with frame {&frame-name} .
      if p-mode <> {&lookup} then enable FILL-IN_start-shift-date FILL-IN_start-shift-num  with frame {&frame-name} .
   end.
   when integer ( {&mpl-date-sys} ) then do:
      display FILL-IN_start-sys-date l-loc-hour l-loc-min with frame {&frame-name} .
      if p-mode <> {&lookup} then enable FILL-IN_start-sys-date l-loc-hour l-loc-min with frame {&frame-name} .
   end.
   end case.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-1 Dialog-Frame
PROCEDURE proc-value-1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  case calc-method :
    when {&pr-calc-obj} then do:
      enable copy-type copy-code r-copy with frame {&frame-name}.
      display copy-type copy-code with frame {&frame-name}.
    end.
    when {&pr-calc-wbill} or
    when {&pr-calc-wbill-novat} or
    when {&pr-calc-slt-wbill} or
    when {&pr-calc-ov} or
    when {&pr-calc-pdf}
    then do:
      enable doc-code r-copy with frame {&frame-name}.
      display doc-code with frame {&frame-name}.
    end.
    when {&pr-common} then do:
      enable common-price with frame {&frame-name}.
      display common-price with frame {&frame-name}.
    end.

  end case.

if (calc-method = {&pr-calc-wbill} or
    calc-method = {&pr-calc-wbill-novat} or
    calc-method = {&pr-calc-slt-wbill} or
    calc-method = {&pr-calc-ov} or
    calc-method = {&pr-calc-pdf}
    ) and
   doc-code = "" then
  /* после выбора одной из этих опций встаем на поле номера документа */
  apply "entry" to doc-code in frame {&frame-name}.
else do:
   if (calc-method = {&pr-common} ) then apply "entry" to common-price in frame {&frame-name}.
   else
   apply "entry" to browse-1 in frame {&frame-name}.
end.

  if par-is-pharm = "yes" then do:
      display
        doc-code
      with frame {&frame-name} no-error .
      enable doc-code r-copy with frame {&frame-name} .
   end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-2 Dialog-Frame
PROCEDURE proc-value-2 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if  lookup( input frame {&frame-name} round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable round-base with frame {&frame-name}.
end.
ELSE do:
    hide round-base in frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-neos Dialog-Frame
PROCEDURE recalc-neos :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-b-code    as integer   no-undo . /* главный код */
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .

define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .

for each buf_price-doc-forming-gds exclusive-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.artic = p-artic and
             buf_price-doc-forming-gds.prod-type = p-prod-type and
             buf_price-doc-forming-gds.prod-code = p-prod-code and
             buf_price-doc-forming-gds.b-code    <>  p-b-code
             :

  run calc-price-alt in this-procedure
      (input  buf_price-doc-forming-gds.b-code
      ,input  recid ( buf_price-doc-forming )
      ,input  buf_price-doc-forming-gds.d-pcnt
      ,input  round-method
      ,input  round-base
      ,output buf_price-doc-forming-gds.price-sale-base
      ,output buf_price-doc-forming-gds.price-sale-doc
      ,output buf_price-doc-forming-gds.price-sale-rubl
      ).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-header Dialog-Frame
PROCEDURE save-header :
do
  on error undo, return error return-value
  :
  define variable v-param-sp as character no-undo .
  if calc-method  = ? then calc-method  = ''.
  if increase-pc  = ? then     increase-pc  = 0 .
  if round-method = ? then     round-method = ''.
  if round-base   = ? then     round-base   =  0.
  if doc-code     = ? then     doc-code     = '' .
  if common-price = ? then     common-price =   0 .
  if copy-type    = ? then     copy-type    = ''  .
  if copy-code    = ? then     copy-code    =    0 .

v-param-sp =                       calc-method + {&delim-par}      .
v-param-sp = v-param-sp + string(  increase-pc   ) + {&delim-par}.
v-param-sp = v-param-sp +          round-method    + {&delim-par}.
v-param-sp = v-param-sp +  string( round-base   ) + {&delim-par}.
v-param-sp = v-param-sp +          doc-code        + {&delim-par}.
v-param-sp = v-param-sp +  string( common-price ) + {&delim-par}.
v-param-sp = v-param-sp +          copy-type                  .
v-param-sp = v-param-sp +  string( copy-code    ) .

run pdf-write (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db  ,
    buf_price-doc-forming.plt-id  ,
    buf_price-doc-forming.plt-db-num ,
    {&pdf-pricedocI} ,
    v-param-sp
    ) no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.

  end.

end procedure. /* save-header */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes: сохраним шапку документа .
------------------------------------------------------------------------------*/
   run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .
   run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).
    if return-value = "nullobj"  then
   do:
    message
      "Внимание !!! Нет ни одного объекта для ДНЦ !!!"
      view-as alert-box error
      .
     return error "Внимание !!! Нет ни одного объекта для ДНЦ !!!" .
   end.

find current buf_price-doc-forming exclusive-lock no-error .
if error-status :error then return error "запись захвачена" .
 assign frame {&frame-name}
    FILL-IN_base-rate
    FILL-IN_base-scale
    FILL-IN_exch-rate
    FILL-IN_exch-scale
    FILL-IN_name
    FILL-IN_have-start-period
    FILL-IN_start-sys-date
    FILL-IN_start-shift-num
    FILL-IN_start-date
    FILL-IN_start-shift-date
    FILL-IN_have-end-period
    FILL-IN_end-sys-date
    FILL-IN_end-shift-num
    FILL-IN_end-date
    FILL-IN_end-shift-date
    l-loc-hour
    l-loc-min
    l-loc-hour-2
    l-loc-min-2
    calc-method
    common-price
    copy-code
    copy-type
    doc-code
    increase-pc
    round-base
    round-method
     .

    if FILL-IN_base-rate = 0  or  FILL-IN_base-rate  < 0 or FILL-IN_base-rate  = ? or
       FILL-IN_base-scale = 0 or  FILL-IN_base-scale < 0 or FILL-IN_base-scale = ? then  do:
      { gbl/exchrate.i
        v-base-code
        TODAY
        FILL-IN_base-rate
        FILL-IN_base-scale
        v-curr-abbr-bv }
    end.
    if FILL-IN_exch-rate = 0  or  FILL-IN_exch-rate  < 0 or FILL-IN_exch-rate  = ? or
       FILL-IN_exch-scale = 0 or  FILL-IN_exch-scale < 0 or FILL-IN_exch-scale = ? then  do:
        { gbl/exchrate.i
          buf-price-list-type.curr-code
          TODAY
          FILL-IN_exch-rate
          FILL-IN_exch-scale
          v-curr-abbr-vd }
   end.

    if FILL-IN_base-rate = 0  or  FILL-IN_base-rate  < 0 or FILL-IN_base-rate  = ? then  return error SUBSTITUTE("Неверно установлено значение базовой валюты"  ) .
    if FILL-IN_exch-rate = 0  or  FILL-IN_exch-rate  < 0 or FILL-IN_exch-rate  = ? then  return error SUBSTITUTE("Неверно установлено значение курса валюты"    ) .
    if FILL-IN_base-scale = 0 or  FILL-IN_base-scale < 0 or FILL-IN_base-scale = ? then  return error SUBSTITUTE("Неверно установлено значение м-ба базовой валюты"  ) .
    if FILL-IN_exch-scale = 0 or  FILL-IN_exch-scale < 0 or FILL-IN_exch-scale = ? then  return error SUBSTITUTE("Неверно установлено значение м-ба валюты"      ) .

 assign
    buf_price-doc-forming.name              = FILL-IN_name
    buf_price-doc-forming.have-start-period = int(FILL-IN_have-start-period )
    buf_price-doc-forming.start-sys-date    = FILL-IN_start-sys-date
    buf_price-doc-forming.start-sys-time    = ( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 )
    buf_price-doc-forming.start-shift-num   = FILL-IN_start-shift-num
    buf_price-doc-forming.start-date        = FILL-IN_start-date
    buf_price-doc-forming.start-shift-date  = FILL-IN_start-shift-date
    buf_price-doc-forming.have-end-period   = int(FILL-IN_have-end-period )
    buf_price-doc-forming.end-sys-date      = FILL-IN_end-sys-date
    buf_price-doc-forming.end-sys-time    = ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 )
    buf_price-doc-forming.end-shift-num     = FILL-IN_end-shift-num
    buf_price-doc-forming.end-date          = FILL-IN_end-date
    buf_price-doc-forming.end-shift-date    = FILL-IN_end-shift-date
    buf_price-doc-forming.base-rate         = FILL-IN_base-rate
    buf_price-doc-forming.base-scale        = FILL-IN_base-scale
    buf_price-doc-forming.db-num-chg        = v-cntxt-db-num
    buf_price-doc-forming.exch-rate         = FILL-IN_exch-rate
    buf_price-doc-forming.exch-scale        = FILL-IN_exch-scale
    buf_price-doc-forming.stts              = integer({&pdf-new})
    buf_price-doc-forming.sys-date          = today
    buf_price-doc-forming.sys-time          = time
    buf_price-doc-forming.sys-time-chr      = string ( buf_price-doc-forming.sys-time , "hh:mm" )
       .
    /* По количествам , суммам или оборотам */
    run save-tt-line in this-procedure .
    /* проверки */
    if can-find (first buf_price-doc-forming-gds where
                       buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                       buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                       buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                       buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
                       buf_price-doc-forming-gds.price-sale = ? no-lock)
                   then do:
      g#log = no.
      message "В документе есть нерассчитанные строки. Удалить их ?"
      view-as alert-box question buttons yes-no update g#log.
          if g#log then do:
              for each buf_price-doc-forming-gds no-lock where
                        buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                        buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                        buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                        buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
                        buf_price-doc-forming-gds.price-sale = ? :
                      run del-doc-line ( input recid (buf_price-doc-forming-gds)) no-error  .
                      if error-status :error then do:
                          message  vss-workfile vss-revision vss-description skip
                          " Нельзя удалить " buf_price-doc-forming-gds.b-code skip
                          error-status :get-message(1) .
                      end.
                end.
          end.
  end.

    run ver-dfc-mpl-lib3 in this-procedure ( recid (buf_price-doc-forming) ) no-error  .
    if error-status :error and return-value <> "no-records":U then do:
       message
       return-value
       skip
       "Документ нельзя записать в БД, удалить его ? "  view-as alert-box question
       buttons yes-no
       update v-ok1 as logical
       .
       error-status :error = false .
       if v-ok1 = true then  do:
          delete buf_price-doc-forming .
       end.
    end.

    if return-value = "no-records":U then do:
       message "В документе нет ни одной строки , удалить ?" view-as alert-box question
       buttons yes-no
       update v-ok as logical
       .
       if v-ok = true then  do:
          delete buf_price-doc-forming .
       end.
    end.
    else do:
       if error-status :error then return error SUBSTITUTE("- &1  &2" , return-value , error-status :get-message(1)) .
    end.
  /* проверка на превышение процента наценки */
  define variable p-err as logical   no-undo .
  if available buf_price-doc-forming then do:
    /* по номеру накладной указанной в интерфейсе */
    if doc-code <> "" and par-pr-discm = 'sale-' then do:
      buf_price-doc-forming.out-code = doc-code .
    end.
    run save-header.

      run ver-pr-discnS in this-procedure (
        input buf_price-doc-forming.plt-id   ,
        input buf_price-doc-forming.plt-db-num ,
        input buf_price-doc-forming.pdf-id ,
        input buf_price-doc-forming.pdf-db ,
        input "",
        input buf_price-doc-forming.out-code ,
        output p-err )
          no-error .
          if error-status :error then do:
              message "Ошибка при проверке процента наценки!" skip
              "Остаться в документе для исправления строки ?" skip
              view-as alert-box question
              buttons yes-no
              Title "Внимание !!!"
              update v-qqq as logical
                .
          if v-qqq then p-err = true .
          else p-err = false .
          /*
          line-rec = int(return-value).
          reposition br-list to recid line-rec no-error.
          */
        if p-err then return error return-value .
     end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-tt-line Dialog-Frame
PROCEDURE save-tt-line :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
for each tt_price-doc-forming-gds-xxx :
   if logical(buf-price-list-type.have-rs-qnty-group) = true then do:
   find first buf_price-doc-forming-gds-qnty exclusive-lock where
              buf_price-doc-forming-gds-qnty.plt-id       = tt_price-doc-forming-gds-xxx.plt-id     and
              buf_price-doc-forming-gds-qnty.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num and
              buf_price-doc-forming-gds-qnty.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id     and
              buf_price-doc-forming-gds-qnty.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db     and
              buf_price-doc-forming-gds-qnty.b-code       = tt_price-doc-forming-gds-xxx.b-code     and
              buf_price-doc-forming-gds-qnty.qgr-id       = tt_price-doc-forming-gds-xxx.qgr-id     and
              buf_price-doc-forming-gds-qnty.qgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num and
              buf_price-doc-forming-gds-qnty.ggr-qnty     = tt_price-doc-forming-gds-xxx.ggr-qnty
              no-error .
              if not available buf_price-doc-forming-gds-qnty then do:
                create buf_price-doc-forming-gds-qnty.
                assign
                  buf_price-doc-forming-gds-qnty.plt-id       = tt_price-doc-forming-gds-xxx.plt-id
                  buf_price-doc-forming-gds-qnty.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num
                  buf_price-doc-forming-gds-qnty.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id
                  buf_price-doc-forming-gds-qnty.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db
                  buf_price-doc-forming-gds-qnty.b-code       = tt_price-doc-forming-gds-xxx.b-code
                  buf_price-doc-forming-gds-qnty.qgr-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-qnty.qgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-qnty.ggr-qnty     = tt_price-doc-forming-gds-xxx.ggr-qnty
                .
              end.
              buffer-copy tt_price-doc-forming-gds-xxx to buf_price-doc-forming-gds-qnty .
    end.

end.
define buffer buf_price-doc-forming-gds-sum for ub.price-doc-forming-gds-sum  .
for each tt_price-doc-forming-gds-xxx :
   if buf-price-list-type.have-rs-sum-group = true then do:
   find first buf_price-doc-forming-gds-sum exclusive-lock where
              buf_price-doc-forming-gds-sum.plt-id       = tt_price-doc-forming-gds-xxx.plt-id     and
              buf_price-doc-forming-gds-sum.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num and
              buf_price-doc-forming-gds-sum.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id     and
              buf_price-doc-forming-gds-sum.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db     and
              buf_price-doc-forming-gds-sum.b-code       = tt_price-doc-forming-gds-xxx.b-code     and
              buf_price-doc-forming-gds-sum.sgr-id       = tt_price-doc-forming-gds-xxx.qgr-id     and
              buf_price-doc-forming-gds-sum.sgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num and
              buf_price-doc-forming-gds-sum.ssg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              no-error .
              if not available buf_price-doc-forming-gds-sum then do:
                create buf_price-doc-forming-gds-sum.
                assign
                  buf_price-doc-forming-gds-sum.plt-id       = tt_price-doc-forming-gds-xxx.plt-id
                  buf_price-doc-forming-gds-sum.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num
                  buf_price-doc-forming-gds-sum.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id
                  buf_price-doc-forming-gds-sum.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db
                  buf_price-doc-forming-gds-sum.b-code       = tt_price-doc-forming-gds-xxx.b-code
                  buf_price-doc-forming-gds-sum.sgr-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-sum.sgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-sum.ssg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
                .
              end.
              buffer-copy tt_price-doc-forming-gds-xxx to buf_price-doc-forming-gds-sum
              assign
                  buf_price-doc-forming-gds-sum.sgr-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-sum.sgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-sum.ssg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              .
    end.
end.
define buffer buf_price-doc-forming-gds-tnv for ub.price-doc-forming-gds-tnv  .
for each tt_price-doc-forming-gds-xxx :
   if logical(buf-price-list-type.have-rs-turn-group) = true then do:
   find first buf_price-doc-forming-gds-tnv exclusive-lock where
              buf_price-doc-forming-gds-tnv.plt-id       = tt_price-doc-forming-gds-xxx.plt-id     and
              buf_price-doc-forming-gds-tnv.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num and
              buf_price-doc-forming-gds-tnv.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id     and
              buf_price-doc-forming-gds-tnv.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db     and
              buf_price-doc-forming-gds-tnv.b-code       = tt_price-doc-forming-gds-xxx.b-code     and
              buf_price-doc-forming-gds-tnv.tog-id       = tt_price-doc-forming-gds-xxx.qgr-id     and
              buf_price-doc-forming-gds-tnv.tog-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num and
              buf_price-doc-forming-gds-tnv.ttg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              no-error .
              if not available buf_price-doc-forming-gds-tnv then do:
                create buf_price-doc-forming-gds-tnv.
                assign
                  buf_price-doc-forming-gds-tnv.plt-id       = tt_price-doc-forming-gds-xxx.plt-id
                  buf_price-doc-forming-gds-tnv.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num
                  buf_price-doc-forming-gds-tnv.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id
                  buf_price-doc-forming-gds-tnv.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db
                  buf_price-doc-forming-gds-tnv.b-code       = tt_price-doc-forming-gds-xxx.b-code
                  buf_price-doc-forming-gds-tnv.tog-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-tnv.tog-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-tnv.ttg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
                .
              end.
              buffer-copy tt_price-doc-forming-gds-xxx to buf_price-doc-forming-gds-tnv
              assign
                  buf_price-doc-forming-gds-tnv.tog-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-tnv.tog-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-tnv.ttg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              .
    end.
end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE seach-artic Dialog-Frame
PROCEDURE seach-artic :
define input  parameter p-artic as character no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.artic begins loc-art and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Еще запись не найдена ! " view-as alert-box information .
                return .
              end.
end.
else do:
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.artic begins loc-art and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition {&browse-name} to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE seach-code Dialog-Frame
PROCEDURE seach-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.b-code = p-b-code and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Еще запись не найдена ! " view-as alert-box information .
                return .
              end.
end.
else do:
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.b-code = p-b-code and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition {&browse-name} to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE seach-name Dialog-Frame
PROCEDURE seach-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-name as character no-undo .
define input  parameter p-next as logical   no-undo .

if p-next = true then do:
   find next buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             can-find ( ub.goods where ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
                                       ub.goods.prod-code = buf_price-doc-forming-gds.prod-code and
                                       ub.goods.artic     = buf_price-doc-forming-gds.artic and
                                       ub.goods.gds-name begins p-name         )             no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Еще запись не найдена ! " view-as alert-box information .
                return .
              end.
end.
else do:
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             can-find ( ub.goods where ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
                                       ub.goods.prod-code = buf_price-doc-forming-gds.prod-code and
                                       ub.goods.artic     = buf_price-doc-forming-gds.artic and
                                       ub.goods.gds-name begins p-name         )             no-error .

              if not available buf_price-doc-forming-gds then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition {&browse-name} to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-header Dialog-Frame
PROCEDURE select-header :
do
  on error undo, return error return-value
  :

define variable v-exist as logical   no-undo .
define variable v-param-sp as character no-undo .
define variable p-type as character no-undo .

run pdf-exist (
      buf_price-doc-forming.pdf-id  ,
      buf_price-doc-forming.pdf-db  ,
      buf_price-doc-forming.plt-id  ,
      buf_price-doc-forming.plt-db-num ,
      {&pdf-pricedocI} ,
      output v-exist ).
if v-exist then  do:
   run pdf-value (
      buf_price-doc-forming.pdf-id  ,
      buf_price-doc-forming.pdf-db  ,
      buf_price-doc-forming.plt-id  ,
      buf_price-doc-forming.plt-db-num ,
      {&pdf-pricedocI},
      output v-param-sp
      ) .
   if num-entries(v-param-sp,{&delim-par}) >= 3 then
      assign
        calc-method  = entry (1,v-param-sp,{&delim-par})
        increase-pc  = decimal (entry(2,v-param-sp,{&delim-par}))
        round-method = entry (3,v-param-sp,{&delim-par})
        round-base   = decimal (entry(4,v-param-sp,{&delim-par}))
        doc-code     = entry (5,v-param-sp,{&delim-par})
        common-price = decimal(entry (6,v-param-sp,{&delim-par}))
        copy-type    = substring(entry (7,v-param-sp,{&delim-par}),1,3)
        copy-code    = integer(substring(entry (7,v-param-sp,{&delim-par}),4,15))
        .

   calc-method:screen-value in frame {&frame-name}  = calc-method  .
   doc-code:screen-value in frame {&frame-name}     = doc-code     .
   increase-pc:screen-value in frame {&frame-name}  = string(increase-pc)  .
   round-method:screen-value in frame {&frame-name} = round-method .
   round-base:screen-value in frame {&frame-name}   = string(round-base )  .
   common-price:screen-value in frame {&frame-name} = string(common-price) .
   copy-type:screen-value in frame {&frame-name}    = copy-type    .
   copy-code:screen-value in frame {&frame-name}    = string(copy-code)    .
   run proc-value-1 in this-procedure .
   run proc-value-2 in this-procedure .

end.
end.
end procedure. /* select-header */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-xxx-line Dialog-Frame
PROCEDURE select-xxx-line :
/* по количествам */
    if logical(buf-price-list-type.have-rs-qnty-group) = true then do:
        define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
        for each buf_price-doc-forming-gds-qnty no-lock where
                buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming.pdf-db    and
                buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming.pdf-id    and
                buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming.plt-db-num and
                buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming.plt-id     :
            create tt_price-doc-forming-gds-xxx.
            buffer-copy buf_price-doc-forming-gds-qnty to tt_price-doc-forming-gds-xxx.
        end.
    end.
    /* по суммам */
    if buf-price-list-type.have-rs-sum-group = true then do:
        define buffer buf_price-doc-forming-gds-sum  for ub.price-doc-forming-gds-sum   .
        for each buf_price-doc-forming-gds-sum no-lock where
                buf_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming.pdf-db    and
                buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming.pdf-id    and
                buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming.plt-db-num and
                buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming.plt-id     :
            create tt_price-doc-forming-gds-xxx.
            buffer-copy buf_price-doc-forming-gds-sum to tt_price-doc-forming-gds-xxx
            assign
                tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_price-doc-forming-gds-sum.ssg-summa
                tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_price-doc-forming-gds-sum.sgr-db-num
                tt_price-doc-forming-gds-xxx.qgr-id      = buf_price-doc-forming-gds-sum.sgr-id
                .
        end.
    end.
    /* по oborotam */
    if logical(buf-price-list-type.have-rs-turn-group) = true then do:
        define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv   .
        for each buf_price-doc-forming-gds-tnv no-lock where
                buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming.pdf-db    and
                buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming.pdf-id    and
                buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming.plt-db-num and
                buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming.plt-id     :
            create tt_price-doc-forming-gds-xxx.
            buffer-copy buf_price-doc-forming-gds-tnv to tt_price-doc-forming-gds-xxx
            assign
                tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_price-doc-forming-gds-tnv.ttg-summa
                tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_price-doc-forming-gds-tnv.tog-db-num
                tt_price-doc-forming-gds-xxx.qgr-id      = buf_price-doc-forming-gds-tnv.tog-id
                .
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-br-field Dialog-Frame
PROCEDURE upd-br-field :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-recid as recid no-undo .
v-recid = recid (buf_price-doc-forming-gds) .

define buffer loc_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first loc_price-doc-forming-gds no-lock where recid(loc_price-doc-forming-gds ) = v-recid no-error .

run ref/h-pdfgds.p
  ( buffer loc_price-doc-forming-gds ,
     input buf_price-doc-forming-gds.price-sale-doc :screen-value in browse browse-1 ,
     input-output v-sec
     ) no-error .
     if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "h-pdfgds.p"
          view-as alert-box error
        .
     end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE vc-pdf Dialog-Frame
PROCEDURE vc-pdf :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
v-in-doc-qnty = ? .
if not available buf_price-doc-forming-gds then return.

define variable v1-recid as recid no-undo .
define buffer bf_goods for ub.goods   .
/* находим среднюю и последнюю цену по объекту */
define variable p-avrg1  as decimal   no-undo .
define variable p-qnty1  as decimal   no-undo .
assign
  p-avrg1 = 0
  p-qnty1 = 0
  obj-in-date = 01/01/1990
  obj-in-code = ""
  p-last = 0
  v-free-qnty = 0
  v-fact-qnty = 0
  v-in-doc-qnty = ?
.
find first bf_goods no-lock where
           bf_goods.artic = buf_price-doc-forming-gds.artic and
           bf_goods.prod-type = buf_price-doc-forming-gds.prod-type and
           bf_goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .


run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).

for each x_obj-group :
    find ub.gds-obj no-lock where
        ub.gds-obj.artic     = buf_price-doc-forming-gds.artic     and
        ub.gds-obj.prod-type = buf_price-doc-forming-gds.prod-type and
        ub.gds-obj.prod-code = buf_price-doc-forming-gds.prod-code and
        ub.gds-obj.obj-type  = x_obj-group.obj-type and
        ub.gds-obj.obj-code  = x_obj-group.obj-code no-error.
        if available ub.gds-obj and ub.gds-obj.avrg-rubl <> ? then do:
           assign
            p-avrg1 = p-avrg1 + (if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base) * ub.gds-obj.avrg-qnty
            p-qnty1 = p-qnty1 + ub.gds-obj.avrg-qnty
           .
        end.

        if available ub.gds-obj and ub.gds-obj.in-date <> ? then do:
            if obj-in-date < ub.gds-obj.in-date then do:
                assign
                  obj-in-date = ub.gds-obj.in-date
                  obj-in-code = ub.gds-obj.in-code
                  p-last = if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
                  v-free-qnty = ub.gds-obj.free-qnty
                  v-fact-qnty = ub.gds-obj.fact-qnty
                .
            end.
        end.
end.

if obj-in-code <> ? and obj-in-code > "" and available bf_goods
then do:
  find first buf_doc-line no-lock where buf_doc-line.doc-code  = obj-in-code
                                   and buf_doc-line.artic     = bf_goods.artic
                                   and buf_doc-line.prod-type = bf_goods.prod-type
                                   and buf_doc-line.prod-code = bf_goods.prod-code no-error .
  if available buf_doc-line
  then do:
    v-in-doc-qnty = buf_doc-line.fact-qnty .
  end.  
  else do: 
    v-in-doc-qnty = ? .
  end.                               
end.
if obj-in-date = 01/01/1990  then obj-in-date = ?.
if p-qnty1 = 0 or p-qnty1 = ? then p-avrg = ? .
                              else p-avrg = p-avrg1 / p-qnty1.

define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .

find first x_obj-group no-error .
if error-status :error then return .
{ gbl/bcodeprc.i
  x_obj-group.obj-type
  x_obj-group.obj-code
  buf_price-doc-forming-gds.b-code
  0
  0
  v-cur-dn
  v-cur-pr
  v-cur-rt
  v-cur-ex }

if par-is-pharm = "yes"  then do:
  { gbl/proprice.i
    buf_price-doc-forming-gds.b-code
    x_obj-group.obj-type
    x_obj-group.obj-code
    v-prod-price
    v-priceprodwithvat-2
    v-prod-vat
    v-str1
    v-str1
  }
  /*Остаток по партиям*/
  v-ost  = f-ost-part ( buf_price-doc-forming-gds.b-code,x_obj-group.obj-type , x_obj-group.obj-code ) .
  var-vat-pc = 0 .
  { gbl/pftxvalg.i
    bf_goods.gds-code
   {&vat-tax-code}
  ?
  v-cntxt-host-code-obj
  x_obj-group.obj-type
  x_obj-group.obj-code
  var-vat-pc
  no-error }

end.
assign
  p-pr-doc-old = v-cur-pr
  prev-price_doc-num =  v-cur-dn
  p-old = buf_price-doc-forming-gds.price-prev-doc
  p-new = buf_price-doc-forming-gds.price-sale-doc
  p-pc-prev = (p-new / p-old  - 1) * 100
  p-op-avrg = (p-old / p-avrg - 1) * 100
  p-pc-avrg = (p-new / p-avrg - 1) * 100
  p-op-pr-doc-old = (p-old / p-pr-doc-old - 1) * 100
  p-pc-pr-doc-old = (p-new / p-pr-doc-old - 1) * 100
  p-op-last = (p-old / p-last - 1) * 100
  p-pc-last = (p-new / p-last - 1) * 100
  p-pc-op-pr-doc-old = p-pc-pr-doc-old - p-op-pr-doc-old
  p-pc-op-avrg = p-pc-avrg - p-op-avrg
  p-pc-op-last = p-pc-last - p-op-last
  p-calc-metod = buf_price-doc-forming-gds.calc-method
  v-new-price-vat  = p-new - ( p-new * var-vat-pc / (100 + var-vat-pc))
  v-prod-price-prc   = ( p-new  / v-prod-price - 1 ) * 100
  v-prod-price-prc-2 = ( v-new-price-vat / v-priceprodwithvat-2 - 1 ) * 100
  v-prod-price-prc-3 = ( p-new / v-priceprodwithvat-2 - 1 ) * 100
  .
  if num-entries(buf_price-doc-forming-gds.calc-method,{&delim-par}) >= 2 then do:
     p-calc-metod          = entry(1,buf_price-doc-forming-gds.calc-method,{&delim-par}) .

     p-calc-metod:tooltip in frame {&frame-name}  = entry(2,buf_price-doc-forming-gds.calc-method,{&delim-par}) .
  end.
  else do:
   p-calc-metod:tooltip in frame {&frame-name}  = "" .
  end.


  if p-pc-prev > 9999 then
    p-pc-prev = ?. /* чтоб влезало в формат */

  if p-pc-avrg > 9999 then
    p-pc-avrg = ?. /* чтоб влезало в формат */

  if p-op-avrg > 9999 then
    p-op-avrg = ?. /* чтоб влезало в формат */

  if p-pc-pr-doc-old > 9999 then
    p-pc-pr-doc-old = ?. /* чтоб влезало в формат */

  if p-op-pr-doc-old > 9999 then
    p-op-pr-doc-old = ?. /* чтоб влезало в формат */


  if p-pc-last > 9999 then
    p-pc-last = ?. /* чтоб влезало в формат */

  if p-op-last > 9999 then
    p-op-last = ?. /* чтоб влезало в формат */

  if   p-pc-op-avrg > 9999 then
    p-pc-op-avrg = ?. /* чтоб влезало в формат */

  if   p-pc-op-pr-doc-old > 9999 then
    p-pc-op-pr-doc-old = ?. /* чтоб влезало в формат */


  if p-pc-op-last > 9999 then
    p-pc-op-last = ?. /* чтоб влезало в формат */

  if v-prod-price-prc > 9999 then
     v-prod-price-prc = ?.

display
     p-new p-old  prev-price_doc-num
     p-last obj-in-code obj-in-date    p-pc-op-last p-calc-metod
     p-pc-prev   p-op-last p-pc-last
     p-avrg
     p-op-avrg
     p-pc-avrg
     p-pc-op-avrg
     p-pr-doc-old
     p-op-pr-doc-old
     p-pc-pr-doc-old
     p-pc-op-pr-doc-old
     with frame {&frame-name} no-error .

  if par-is-pharm = "yes" then do:
      display
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
        doc-code
      with frame {&frame-name} no-error .
      enable doc-code with frame {&frame-name} .
  end.
  else do :
    hide
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
      in frame {&frame-name}  .
    display
      v-free-qnty
      v-fact-qnty
      v-in-doc-qnty
    with frame {&frame-name} no-error .  
  end.

if p-mode = {&lookup} then  disable doc-code with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-bar-code-prt Dialog-Frame
PROCEDURE ver-bar-code-prt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-b-code as integer   no-undo .
define output parameter p-is-prt as logical   no-undo .
define buffer main_bar-code for ub.bar-code  .
define buffer buf1_bar-code for ub.bar-code  .
define buffer buf1_goods    for ub.goods  .
define variable main-b-code as integer   no-undo .


find first buf1_bar-code no-lock where
           buf1_bar-code.b-code = p-b-code no-error .
find first buf1_goods no-lock where
           buf1_goods.gds-code = buf1_bar-code.gds-code no-error .

{ gbl/gdsbcode.i
  buf1_goods.gds-code
  ?
  main-b-code
 }

 p-is-prt = false  .
 if main-b-code <> p-b-code and buf1_goods.unit-base = buf1_bar-code.unit-cli then p-is-prt = true .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-pr-conf Dialog-Frame
PROCEDURE ver-pr-conf :
/* -----------------------------------------------------------
  Purpose: Проверка на возможность ввода товаров в ДНЦ исходя из тучи параметров pr-
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf-bar-code  for ub.bar-code.
define buffer buf-goods     for ub.goods.
define buffer buf-gds-prt   for ub.gds-prt.
define buffer curr_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer f_price-doc   for ub.price-doc  .

define variable v-ex1               as logical   no-undo .
define variable v-ex1-doc-num       as character no-undo .
define variable v-ex1-doc-status    as character no-undo .
define variable v-ex1-doc-obj-type  as character no-undo .
define variable v-ex1-doc-obj-code  as integer   no-undo .
define variable v-ret               as logical   no-undo .
define variable bc-main             as integer   no-undo .
define variable g#log               as logical   no-undo .


for each  x_obj-group :
for each tt-gds-list :
    find  buf-goods no-lock where
          buf-goods.gds-code = tt-gds-list.gds-code.
    { gbl/gdsbcode.i tt-gds-list.gds-code ?  bc-main }
   /* должен быть не модификатор */
    run ver-modificator-price-is-null (
        input  tt-gds-list.artic ,
        input  tt-gds-list.prod-type ,
        input  tt-gds-list.prod-code ,
        input  v-cntxt-obj-type ,
        input  v-cntxt-obj-code ,
        output v-ret ).
        if v-ret = false then do:
            message
              "На модификатор : " skip
              "Артикул : " buf-goods.artic skip
                buf-goods.gds-name skip
              "не должно быть цены! "
              view-as alert-box information .
              delete tt-gds-list .
              next.
        end.


      if par-pr-dpl-q = "yes" then do:
        /* проверяем, нет ли этой строки в другом ПРИКАЗЕ по ЭТОМ ЖЕ объектам */
          assign
            v-ex1 = false
            v-ex1-doc-num =    ""
            v-ex1-doc-status   = ""
            v-ex1-doc-obj-type = ""
            v-ex1-doc-obj-code = 0
          .
                for each  ub.price-list no-lock where
                          ub.price-list.b-code   = bc-main and
                          ub.price-list.obj-type = x_obj-group.obj-type and
                          ub.price-list.obj-code = x_obj-group.obj-code and
                          ub.price-list.price-type = "" and
                          ub.price-list.fact-order = 0 ,
                          first f_price-doc no-lock where
                                f_price-doc.doc-num = ub.price-list.doc-num and
                              ( f_price-doc.status_ = {&order} or  f_price-doc.status_ = {&permitted} )
                          :
                          assign
                            v-ex1 = true
                            v-ex1-doc-num =     ub.price-list.doc-num
                            v-ex1-doc-status   = f_price-doc.status_
                            v-ex1-doc-obj-type = f_price-doc.obj-type
                            v-ex1-doc-obj-code = f_price-doc.obj-code
                            .
                          leave.
                end.
        if v-ex1 = true  then do:
          g#log = yes.
          message "Строка :" buf-goods.artic buf-goods.gds-name /* buf-gds-prt.node-name */
                  "ЕСТЬ в ПЕРЕОЦЕНКЕ №" v-ex1-doc-num  "статус:" v-ex1-doc-status
                  "для" v-ex1-doc-obj-type v-ex1-doc-obj-code skip
                  "Продолжать?"
                  view-as alert-box question buttons ok-cancel update g#log.
          if not g#log then do:
            delete tt-gds-list .
            next.
          end.
        end.
      end. /*par-pr-dpl-q*/

/* проверяем, нет ли такой строки в ЭТОМ ЖЕ документе */
    if par-pr-clt-q = "yes" then do:
    find first curr_price-doc-forming-gds no-lock where
              curr_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db     and
              curr_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and
              curr_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
              curr_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and
              curr_price-doc-forming-gds.artic      = buf-goods.artic                  and
              curr_price-doc-forming-gds.prod-type  = buf-goods.prod-type              and
              curr_price-doc-forming-gds.prod-code  = buf-goods.prod-code  no-error .

      if available curr_price-doc-forming-gds then do:
          g#log = yes.
          message "Строка :" buf-goods.artic buf-goods.gds-name
                  "уже ЕСТЬ в заполняемом ДНЦ, цена =" curr_price-doc-forming-gds.price-sale-doc skip
                  "Продолжать?"
                  view-as alert-box question buttons ok-cancel update g#log.
          if not g#log then  do:
            delete tt-gds-list .
            next.
          end.
      end.
    end.

end.  /* tt-gds-list */
end. /* x_obj-group */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnc-color Dialog-Frame
FUNCTION fnc-color RETURNS integer

  ( buffer b-goods for ub.goods , buffer b-bar-code for ub.bar-code ) :

define buffer b-gds-prt for ub.gds-prt.
find first b-gds-prt no-lock where b-gds-prt.node-code = b-bar-code.node-code no-error .
if available b-gds-prt then do:
   if b-gds-prt.upper-code = b-goods.prt-root then do:
      if b-goods.unit-base = b-bar-code.unit-cli then return ?.
                                                 else return dark_gray_color .
   end.
  else do:
    if b-goods.unit-base = b-bar-code.unit-cli then return dark_green_color .
                                               else return blue_color .
  end.
end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnc-gds-name Dialog-Frame
FUNCTION fnc-gds-name RETURNS CHARACTER
( input p-rec1 as recid , input p-rec2 as recid ) :
define buffer b-goods    for ub.goods  .
define buffer b-bar-code for ub.bar-code  .
define buffer b-gds-prt  for ub.gds-prt.
define buffer buf_parts  for ub.parts  .
define variable v-name as character no-undo .

find first b-goods    no-lock where recid(b-goods) = p-rec1 no-error .
     if error-status :error then return '' .

find first b-bar-code no-lock where recid(b-bar-code)  = p-rec2 no-error .
find first b-gds-prt no-lock where b-gds-prt.node-code = b-bar-code.node-code no-error .
find first buf_parts no-lock where
           buf_parts.part-code  = b-bar-code.part-code and
           buf_parts.in-code    = b-bar-code.in-code and
           buf_parts.out-code   = b-bar-code.in-code and
           buf_parts.artic      = b-goods.artic      and
           buf_parts.prod-type  = b-goods.prod-type      and
           buf_parts.prod-code  = b-goods.prod-code    no-error .

 v-name = if b-gds-prt.upper-code = b-goods.prt-root
         then
         if b-bar-code.in-code = ''
            then  b-goods.gds-name
            else  substitute("  &1  ПН &2 до &3" , b-bar-code.part-code, b-bar-code.in-code , if available buf_parts then  string(buf_parts.last-date , "99/99/9999") else "" )
      else        substitute("    &1" , b-gds-prt.f-name)
      .
      return v-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME