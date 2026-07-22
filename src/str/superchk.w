&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
using ibs.th.gbl.env.prmtrs.edo.
using ibs.th.str.marking.sts.*.
{ ref/extclass.i }
/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cash-desk FOR cash-desk.
DEFINE BUFFER buf_cashier FOR clients.
DEFINE BUFFER buf_clients FOR clients.
DEFINE BUFFER buf_dis-card FOR dis-card.
DEFINE BUFFER buf_obj FOR clients.
DEFINE BUFFER buf_sales-man FOR clients.
DEFINE BUFFER cashier FOR person.
DEFINE BUFFER gds_bar-code FOR bar-code.
DEFINE BUFFER gds_goods FOR goods.
DEFINE BUFFER gds_parts FOR parts.
DEFINE BUFFER gds_prod-bc FOR prod-bc.
DEFINE BUFFER locked_chk-discnt FOR chk-discnt.
DEFINE BUFFER locked_chk-doc FOR chk-doc.
DEFINE BUFFER locked_chk-doc-attr FOR chk-doc-attr.
DEFINE BUFFER locked_chk-gds FOR chk-gds.
DEFINE BUFFER locked_chk-pay FOR chk-pay.
DEFINE BUFFER pay_cash-pay FOR cash-pay.
DEFINE BUFFER pay_currency FOR currency.
DEFINE BUFFER sales-man FOR person.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_chk-doc-attr for ub.chk-doc-attr .
define buffer buf_chk-gds-attr for ub.chk-gds-attr .
define variable v-corr-osnov1 as integer no-undo .
define variable v-susp as character no-undo .
DEFINE NEW SHARED TEMP-TABLE tt-chk-discnt NO-UNDO LIKE chk-discnt
       field  real-value-abs as decimal
       field  real-value-pcnt as decimal.
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE chk-doc
       field real-subdiscnt as decimal.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-gds NO-UNDO LIKE chk-gds.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE chk-pay.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа ручного создания/редактирования/просмотра чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 25/11/2002
Author: Bakhtadze Natalya
Creation date: 25/11/2002

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc as Widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter p-doc-rec as recid no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "чек : добавление, изменение, просмотр":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ str/round-m.i  }
{ str/get-pr.i def }
{ gbl/tax-name.i }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ str/shftnmef.i chk-doc shift-name }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ ref/cp-attr.i }
{ gbl/print-xml.i }
{ gbl/sel-date.i }
{gbl/tmprecid.i }
{ str/is-corr.i }
{ ref/gds-attr.i }
{ str/temp_upd.i }
{ utl/gtin.i }
{ str/cspromo-chk.i } /* функции для работы с промоакциями по НП */

DEFINE VARIABLE var-mode as character no-undo.
/*настройка - разрешено ли менять на бар-код с другой текущей прейскурантной ценой*/
DEFINE VARIABLE ch-bc-ck as logical no-undo init no.
DEFINE VARIABLE is-prt as logical no-undo init no.
/*настройка - откуда брать номер магазина при чтении чеков из спула - из спула- yes или
по умолчанию номер магазина в котором принимается почта*/
define variable hnum as logical no-undo init no.
/*юти переменные просто должны быть определены*/
define variable ibmgroup as logical no-undo init yes.
define variable lll as int no-undo initial 0. /*счетчик принятых чеков*/
define variable v-is-top as logical no-undo . /*есть ли бензоколонки*/
/*текущая смена*/
DEFINE VARIABLE v-shift-date as date no-undo.
DEFINE VARIABLE v-shift-num as integer no-undo.
DEFINE VARIABLE conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE conf-par as char no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE par-type as char no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE varcurr-name like ub.currency.curr-name no-undo.
DEFINE VARIABLE vargds-name like ub.goods.gds-name no-undo.
DEFINE VARIABLE varprt-name like ub.goods.gds-name no-undo.
define variable discnt-option as character no-undo.
DEFINE VARIABLE v-is-sub-d as logical no-undo .
define variable v-pay-name as character no-undo label "Назв. платежа" FORMAT "X(18)".
define variable v-pay-card like ub.chk-pay.pay-card no-undo.
define variable v-global-err as logical no-undo .
define variable glog as logical no-undo .
define variable v-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-is-update as logical no-undo .
define variable exch-date_ like ub.curr-shop.exch-date no-undo .
define variable exch-time_ like ub.curr-shop.exch-time no-undo .
define variable v-exch-time-str as character no-undo.
define variable dc-change as logical no-undo .
DEFINE VARIABLE v-br-discnt-current-type AS INTEGER NO-UNDO.
define variable v-tax-type as character no-undo label "Вид налога" FORMAT "X(10)".
define variable v-OVDtax-type as character no-undo label "Вид налога ОФД" FORMAT "X(14)".
define buffer buf_shop for ub.shop.
define variable v-host-code as integer   no-undo .
define variable v-gds-attr-value as character no-undo .
define variable v-gds-attr-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .
define variable actn#log as logical no-undo .
define variable actn#log_bonus as logical no-undo .
define variable p-view-log as logical no-undo.
define variable  charKey_one as character no-undo .
{ str/get-chkc.i def  update }
/*{ str/getcheck.i UPDATE this-procedure }*/
{ gbl/gbclcode.i }
define variable p-pos-type as character no-undo .
{ str/paycardv.i }

define buffer buf_marking-chk for ub.marking-chk .
{ gbl/objsrv.i }
def var Marking as class mark no-undo .
define variable EDOParSec as class edo.
&SCOP discnt-v-code string(tt-chk-discnt.value-type)
&scop discnt-target-code string(tt-chk-discnt.line-type)
&scop discnt-type-code string(tt-chk-discnt.discnt-type)
&SCOPED-DEFINE LABEL_templ-rl-root "Шаблон скидки"
DEFINE NEW SHARED TEMp-TABLE tt-gds-info no-undo
field doc-code as character
FIELD gds-code LIKE ub.goods.gds-code
FIELD line-num like ub.chk-gds.line-num
FIELD artic like ub.goods.artic
FIELD gds-name like ub.goods.gds-name
FIELD salesman-name like ub.clients.obj-name
FIELD prt-name like ub.gds-prt.f-name
FIELD src-d-pcnt like ub.chk-doc.d-pcnt
FIELD src-price-netto like ub.chk-gds.price-base
FIELD src-sum-netto like ub.chk-doc.netto
FIELD d-pcnt like ub.chk-doc.d-pcnt
FIELD price-netto like ub.chk-gds.price-base
FIELD sum-netto like ub.chk-doc.netto
index pi is unique PRIMARY
doc-code
line-num
.

DEFINE NEW SHARED TEMp-TABLE tt-pay-info no-undo
field doc-code as character
FIELD line-num like ub.chk-pay.line-num
field calc-rate like ub.curr-shop.exch-rate
field exch-date like ub.curr-shop.exch-date
field exch-time like ub.curr-shop.exch-time
field exch-time-str as character
field exch-rate like ub.curr-shop.exch-rate
field exch-scale like ub.curr-shop.exch-scale
index pi is unique PRIMARY
doc-code
line-num
.

define dataset superchk for
tt-chk-doc,
tt-chk-gds,
tt-gds-info,
tt-chk-pay,
tt-pay-info,
tt-chk-discnt
data-relation line-gds for tt-chk-doc, tt-chk-gds relation-fields (doc-code, doc-code) nested
data-relation line-gds2 for tt-chk-doc, tt-gds-info relation-fields (doc-code, doc-code) nested
data-relation line-pay for tt-chk-doc, tt-chk-pay relation-fields (doc-code, doc-code) nested
data-relation line-pay2 for tt-chk-doc, tt-pay-info relation-fields (doc-code, doc-code) nested
data-relation line-discnt for tt-chk-doc, tt-chk-discnt relation-fields (doc-code, doc-code) nested
.

&scop  fatal-errs message ~
    "В этом чеке имеются фатальные ошибки, которые возможно исправить не удастся!!!!!" skip ~
    "В этом случае постарайтесь пересоздать его руками" skip ~
    "или обратитесь к администратору Вашей системы" ~
    view-as alert-box WARNING.

&GLOBAL-DEFINE wro-code STRING(if tt-chk-gds.write-off-code = ? then 0 else tt-chk-gds.write-off-code)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-discnt

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-chk-discnt tt-chk-gds tt-gds-info ~
tt-chk-pay tt-pay-info tt-chk-doc

/* Definitions for BROWSE BR-discnt                                     */
&Scoped-define FIELDS-IN-QUERY-BR-discnt tt-chk-discnt.line-num {&discnt-v-name} tt-chk-discnt.object-line-num {&discnt-target-name} (IF tt-chk-discnt.record-type < 4 THEN {&discnt-type-name} ELSE STRING(tt-chk-discnt.discnt-type)) tt-chk-discnt.real-value-abs tt-chk-discnt.real-value-pcnt tt-chk-discnt.src-d-card tt-chk-discnt.discnt-id tt-chk-discnt.kateg tt-chk-discnt.d-card get-templ-rl-name( INPUT tt-chk-discnt.templ-rl-root) tt-chk-discnt.promo-id   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-discnt tt-chk-discnt.real-value-abs tt-chk-discnt.real-value-pcnt   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-discnt tt-chk-discnt
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-discnt tt-chk-discnt
&Scoped-define SELF-NAME BR-discnt
&Scoped-define OPEN-QUERY-BR-discnt CASE par-mode:   WHEN {&add-def} OR WHEN {&UPDATE} THEN DO:     OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt WHERE            tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type         by tt-chk-discnt.line-num.   END.    WHEN  {&LOOKUP} or when "susp-type" THEN DO:        OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt NO-LOCK              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code            AND tt-chk-discnt.record-type = v-br-discnt-current-type            by tt-chk-discnt.line-num.     END. END CASE.
&Scoped-define TABLES-IN-QUERY-BR-discnt tt-chk-discnt
&Scoped-define FIRST-TABLE-IN-QUERY-BR-discnt tt-chk-discnt


/* Definitions for BROWSE BR-gds                                        */
&Scoped-define FIELDS-IN-QUERY-BR-gds tt-chk-gds.line-num tt-chk-gds.src-code tt-chk-gds.is-error tt-chk-gds.b-code tt-gds-info.artic tt-gds-info.gds-name tt-chk-gds.src-qnty tt-chk-gds.src-price tt-chk-gds.src-discnt tt-gds-info.src-d-pcnt tt-gds-info.src-price-netto tt-gds-info.src-sum-netto tt-gds-info.prt-name tt-chk-gds.doc-qnty tt-chk-gds.price-base tt-chk-gds.discnt tt-gds-info.d-pcnt tt-gds-info.price-netto tt-gds-info.sum-netto tt-chk-gds.pump tt-chk-gds.nozzle-code tt-chk-gds.loc1 tt-chk-gds.src-pl-code tt-chk-gds.pl-code if (tt-chk-gds.write-off-code = 1 and can-do("14,15,16,17,36", string(tt-chk-doc.chk-type))) then "Пролито" else {&wro-name} tt-chk-gds.depart-id tt-chk-gds.depart-code tt-chk-gds.sales-man tt-gds-info.salesman-name tt-chk-gds.road-tax tt-chk-gds.src-sum tt-chk-gds.density tt-chk-gds.pass-gds tt-chk-gds.vat-pc tt-chk-gds.vat-sum-rubl   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds tt-chk-gds.src-code ~
tt-chk-gds.b-code ~
tt-chk-gds.doc-qnty ~
tt-chk-gds.pump ~
tt-chk-gds.nozzle-code ~
tt-chk-gds.loc1 ~
tt-chk-gds.pl-code ~
tt-chk-gds.depart-id ~
tt-chk-gds.depart-code ~
tt-chk-gds.src-qnty ~
tt-chk-gds.src-price ~
tt-chk-gds.src-discnt ~
tt-chk-gds.road-tax ~
tt-chk-gds.density ~
tt-chk-gds.pass-gds ~
tt-chk-gds.vat-pc ~
tt-chk-gds.vat-sum-rubl   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gds tt-chk-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gds tt-chk-gds
&Scoped-define SELF-NAME BR-gds
&Scoped-define OPEN-QUERY-BR-gds CASE par-mode:     WHEN {&add-def}     OR     WHEN {&update} THEN DO:        IF dflt-cd = {&cd-type-magia-xml} THEN OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds       WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code , ~
             FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).     ELSE     OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds           WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code , ~
                 FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.      END.     WHEN {&LOOKUP} or when "susp-type" THEN DO:            IF dflt-cd = {&cd-type-magia-xml} THEN         OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code , ~
                     FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code , ~
                         FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.      END. END CASE.
&Scoped-define TABLES-IN-QUERY-BR-gds tt-chk-gds tt-gds-info
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds tt-chk-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-gds tt-gds-info


/* Definitions for BROWSE BR-pay                                        */
&Scoped-define FIELDS-IN-QUERY-BR-pay tt-chk-pay.line-num tt-chk-pay.pay-code tt-chk-pay.curr-code tt-chk-pay.is-error get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name varcurr-name tt-chk-pay.tot-sum tt-chk-pay.tot-base tt-chk-pay.tot-rubl tt-chk-pay.pay-card tt-pay-info.calc-rate tt-pay-info.exch-date tt-pay-info.exch-time-str tt-pay-info.exch-rate tt-pay-info.exch-scale tt-chk-pay.cash-rate tt-chk-pay.src-val tt-chk-pay.src-qnty tt-chk-pay.par-val tt-chk-pay.doc-qnty tt-chk-pay.bank-rate tt-chk-pay.bank-scale   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pay tt-chk-pay.pay-code ~
tt-chk-pay.curr-code ~
tt-chk-pay.tot-sum ~
tt-chk-pay.pay-card ~
tt-chk-pay.cash-rate ~
tt-chk-pay.src-val ~
tt-chk-pay.src-qnty ~
tt-chk-pay.par-val ~
tt-chk-pay.doc-qnty   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-pay tt-chk-pay
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-pay tt-chk-pay
&Scoped-define SELF-NAME BR-pay
&Scoped-define OPEN-QUERY-BR-pay CASE par-mode:   WHEN {&add-def}   OR   WHEN {&UPDATE}  THEN DO:      OPEN QUERY {&SELF-NAME} FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code , ~
           first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END.   WHEN {&LOOKUP} or when "susp-type" THEN DO:      OPEN QUERY {&SELF-NAME} FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code , ~
           first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.  END. END CASE.
&Scoped-define TABLES-IN-QUERY-BR-pay tt-chk-pay tt-pay-info
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pay tt-chk-pay
&Scoped-define SECOND-TABLE-IN-QUERY-BR-pay tt-pay-info


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-chk-doc.src-tot-doc ~
tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man ~
tt-chk-doc.obj-code tt-chk-doc.d-card tt-chk-doc.pay-desk ~
tt-chk-doc.doc-num tt-chk-doc.doc-num2 tt-chk-doc.chk-num ~
tt-chk-doc.z-number tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date ~
tt-chk-doc.cash-rate tt-chk-doc.cash-scale tt-chk-doc.shift-name ~
tt-chk-doc.shift-num tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc ~
tt-chk-doc.discnt tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-chk-doc.src-tot-doc ~
tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man ~
tt-chk-doc.obj-code tt-chk-doc.d-card tt-chk-doc.pay-desk ~
tt-chk-doc.doc-num tt-chk-doc.doc-num2 tt-chk-doc.chk-num ~
tt-chk-doc.z-number tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date ~
tt-chk-doc.cash-rate tt-chk-doc.cash-scale tt-chk-doc.shift-name ~
tt-chk-doc.shift-num tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc ~
tt-chk-doc.discnt tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-chk-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-chk-doc
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-pay}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-chk-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-chk-doc.src-tot-doc tt-chk-doc.chk-date ~
tt-chk-doc.cashier tt-chk-doc.sales-man tt-chk-doc.obj-code ~
tt-chk-doc.d-card tt-chk-doc.pay-desk tt-chk-doc.doc-num ~
tt-chk-doc.doc-num2 tt-chk-doc.chk-num tt-chk-doc.z-number ~
tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date tt-chk-doc.cash-rate ~
tt-chk-doc.cash-scale tt-chk-doc.shift-name tt-chk-doc.shift-num ~
tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc tt-chk-doc.discnt ~
tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date 
&Scoped-define ENABLED-TABLES tt-chk-doc
&Scoped-define FIRST-ENABLED-TABLE tt-chk-doc
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-prev B-next Cb-chk-type ~
b-func br-attr B-print B-hist B-help RECT-1 fhour fmin fsec B-card b-cd ~
v-corr-osnov v-corr-type v-susp-chk v-doc-osnov corr-date f-num-corr ~
BUTTON-1 b-choose-date BUTTON-susp v-link-chk f-cause-corr v-src-d-card ~
b-addbonus B-adddiscnt B-addgds Btn_sht-from BR-corr BR-gds BR-discnt ~
BR-pay b-slip-chk B-addpay B_mark b-cf F-cashier F-salesman f-cli-name 
&Scoped-Define DISPLAYED-FIELDS tt-chk-doc.src-tot-doc tt-chk-doc.chk-date ~
tt-chk-doc.cashier tt-chk-doc.sales-man tt-chk-doc.obj-code ~
tt-chk-doc.d-card tt-chk-doc.pay-desk tt-chk-doc.doc-num ~
tt-chk-doc.doc-num2 tt-chk-doc.chk-num tt-chk-doc.z-number ~
tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date tt-chk-doc.cash-rate ~
tt-chk-doc.cash-scale tt-chk-doc.shift-name tt-chk-doc.shift-num ~
tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc tt-chk-doc.discnt ~
tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date 
&Scoped-define DISPLAYED-TABLES tt-chk-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-chk-doc
&Scoped-Define DISPLAYED-OBJECTS Cb-chk-type fhour fmin fsec v-corr-osnov ~
v-corr-type text-4 text-1 v-susp-chk v-doc-osnov corr-date f-num-corr ~
v-link-chk f-cause-corr v-src-d-card F-cashier F-salesman f-cli-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


/* Browse definitions                                                   */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName d-utd
FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-good Dialog-Frame 
FUNCTION get-good RETURNS CHARACTER
  (
    input  parb-code as integer
  , output pargds-code AS integer
  , output pargds-name as character
  , output parprt-name as character
  , output paris-error as logical)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-pay Dialog-Frame 
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-tax-type Dialog-Frame 
FUNCTION get-tax-type RETURNS CHARACTER
  ( input p-tax-code as integer) :

case p-tax-code :
  when 1 then return "18%" .
  when 2 then return "10%" .
  when 3 then return "0%" .
  when 4 then return "Б/Н" .
  when 5 then return "18/118" .
  when 6 then return "10/110" .
  otherwise return "Неизвестн." .
end case .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-tax-type Dialog-Frame 
FUNCTION get-OVDtax-type RETURNS CHARACTER
  ( input p-tax-code as integer) :

case p-tax-code :
  when 1102 then return "18%" .
  when 1103 then return "10%" .
  when 1104 then return "0%" .
  when 1105 then return "Б/Н" .
  when 1106 then return "18/118" .
  when 1107 then return "10/110" .
  otherwise return "Неизвестн." .
end case .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-salesman Dialog-Frame 
FUNCTION get-salesman RETURNS CHARACTER
  ( input  p-salesman as integer, input p-date as date, output p-psn-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-templ-rl-name Dialog-Frame 
FUNCTION get-templ-rl-name RETURNS CHARACTER
  ( INPUT p-templ-rl-root AS INTEGER )  FORWARD.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GdsName Dialog-Frame 
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.  

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-prt 
       MENU-ITEM m-gds          LABEL "Товар"         
       MENU-ITEM m-prt-1        LABEL "Признаки"      
       MENU-ITEM m-prt-2        LABEL "Партии"        
       MENU-ITEM m-write-off    LABEL "Код списания"  
       MENU-ITEM m-modificator  LABEL "Признак модификатора с нулевой ценой"
       MENU-ITEM m-sales-man    LABEL "Продавец или официант".

DEFINE MENU MENU-b-addbonus 
       MENU-ITEM m_cash-abs-bon LABEL "На подитог"    
       MENU-ITEM m_gds-abs-bon  LABEL "На товар"      .

DEFINE MENU MENU-B-adddiscnt 
       MENU-ITEM m_cash-abs     LABEL "На подитог абсолютная"
       MENU-ITEM m_cash-pcnt    LABEL "На подитог процентная"
       MENU-ITEM m_gds-abs      LABEL "На товар абсолютная"
       MENU-ITEM m_without      LABEL "Товар без скидки на итог".

DEFINE MENU MENU-BR-pay 
       MENU-ITEM m-pay          LABEL "Оплата"        .

DEFINE MENU m_marks 
       MENU-ITEM m_marks-utd    LABEL "Марки по чеку" 
       MENU-ITEM m_marks-lines  LABEL "Марки по линии".

DEFINE MENU m-func 
       MENU-ITEM m-add-blocked-marks       LABEL "Автозаполнение по заблок. маркам".

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-addbonus 
     LABEL "Бонусы" 
     SIZE 14 BY 1.

DEFINE BUTTON B-adddiscnt 
     LABEL "Скидки" 
     SIZE 14 BY 1.

DEFINE BUTTON B-addgds 
     LABEL "Доб. товар" 
     SIZE 14 BY 1.

DEFINE BUTTON B-addpay 
     LABEL "Оплата" 
     SIZE 10 BY 1.

DEFINE BUTTON B-card 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON b-cd 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-cf 
     LABEL "&Фиск" 
     SIZE 10 BY 1.

DEFINE BUTTON b-choose-date 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date" 
     SIZE 3 BY .88.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "&История" 
     SIZE 3 BY 1.

DEFINE BUTTON B-next AUTO-GO 
     LABEL "&>>" 
     SIZE 4 BY 1.

DEFINE BUTTON B-prev AUTO-GO 
     LABEL "&<<" 
     SIZE 4 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON br-attr 
     LABEL "Атр" 
     SIZE 4 BY 1.
define button b-func
    label "функ."
    size 6 by 1 .

DEFINE BUTTON Btn_sht-from 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .88.

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 2.63 BY 1 TOOLTIP "Выбор оснований".

DEFINE BUTTON BUTTON-susp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 2.63 BY 1 TOOLTIP "Выбор причин".

DEFINE BUTTON B_mark 
     LABEL "Марки" 
     SIZE 9.13 BY 1.

DEFINE BUTTON b-slip-chk 
     LABEL "Просмотр слипов" 
     SIZE 15.75 BY 2.
     

DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 27 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-susp-chk AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 250 SCROLLBAR-VERTICAL
     SIZE 94.38 BY 1.71 NO-UNDO.

DEFINE VARIABLE corr-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-cashier AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 19.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-cause-corr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Описание корректировки" 
     VIEW-AS FILL-IN 
     SIZE 64 BY 1 TOOLTIP "Краткое описание причины проведения корректировки" NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Клиент" 
      VIEW-AS TEXT 
     SIZE 20.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-corr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE F-salesman AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 19.63 BY 1 NO-UNDO.

DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE text-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Основание корректировки" 
     VIEW-AS FILL-IN 
     SIZE 24 BY .75 NO-UNDO.

DEFINE VARIABLE text-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Причина подозрительного чека" 
     VIEW-AS FILL-IN 
     SIZE 30 BY .75 NO-UNDO.

DEFINE VARIABLE v-corr-osnov AS CHARACTER FORMAT "X(80)" 
     LABEL "Основание" 
     VIEW-AS FILL-IN 
     SIZE 53.25 BY 1 NO-UNDO.

DEFINE VARIABLE v-corr-type AS CHARACTER FORMAT "X(15)" 
     LABEL "Тип коррекции" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE v-doc-osnov AS CHARACTER FORMAT "X(256)":U 
     LABEL "Документ" 
     VIEW-AS FILL-IN 
     SIZE 32.38 BY 1 NO-UNDO.

DEFINE VARIABLE v-link-chk AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ссылка на ~"корректный~" чек" 
     VIEW-AS FILL-IN 
     SIZE 66.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-src-d-card AS CHARACTER FORMAT "x(8)" 
     LABEL "ДК в чеке" 
     VIEW-AS FILL-IN 
     SIZE 20.13 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 100.5 BY 3.5 TOOLTIP "Основание корректировки".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-discnt FOR 
      tt-chk-discnt SCROLLING.

DEFINE QUERY BR-gds FOR 
      tt-chk-gds, 
      tt-gds-info SCROLLING.
      
DEFINE QUERY BR-corr FOR 
      tt-chk-gds SCROLLING.      

DEFINE QUERY BR-pay FOR 
      tt-chk-pay, 
      tt-pay-info SCROLLING.

DEFINE QUERY Dialog-Frame FOR 
      tt-chk-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-discnt Dialog-Frame _FREEFORM
  QUERY BR-discnt SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-discnt.line-num COLUMN-LABEL "N строки!начисления"
{&discnt-v-name} COLUMN-LABEL "Тип!знач"
tt-chk-discnt.object-line-num COLUMN-LABEL "N строки!товара!-объекта"
{&discnt-target-name} COLUMN-LABEL "Объект!скидки/!бонуса" FORMAT "X(15)"
(IF tt-chk-discnt.record-type < 4
 THEN {&discnt-type-name}
 ELSE STRING(tt-chk-discnt.discnt-type)) COLUMN-LABEL "Тип скидки/!код схемы" FORMAT "X(20)"
tt-chk-discnt.real-value-abs COLUMN-LABEL "abs!Знач.скидки/!бонуса"
tt-chk-discnt.real-value-pcnt COLUMN-LABEL "% Знач.скидки/!бонуса" FORMAT "->>9.99"
tt-chk-discnt.src-d-card COLUMN-LABEL "№ Карты!для начисления"
tt-chk-discnt.discnt-id COLUMN-LABEL "ID!транзакц" FORMAT ">>>>>>>>9"
tt-chk-discnt.kateg COLUMN-LABEL "Код !валюты" FORMAT "->>>9"
tt-chk-discnt.d-card COLUMN-LABEL "№ карты" FORMAT "X(20)"
get-templ-rl-name( INPUT tt-chk-discnt.templ-rl-root) COLUMN-LABEL {&label_templ-rl-root} FORMAT "X(255)" WIDTH 50
tt-chk-discnt.promo-id COLUMN-LABEL "Промо" FORMAT "X(20)"
ENABLE
tt-chk-discnt.real-value-abs
tt-chk-discnt.real-value-pcnt
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 102.5 BY 6.67
         FONT 4.

DEFINE BROWSE BR-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds Dialog-Frame _FREEFORM
  QUERY BR-gds SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-gds.line-num COLUMN-LABEL "NN"  FORMAT "->>>>9"
      tt-chk-gds.src-code COLUMN-LABEL "Исходный код" format "X(19)" width 14
      tt-chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/"
      tt-chk-gds.b-code FORMAT "99999999999":U
      tt-gds-info.artic COLUMN-LABEL "Артикул" FORMAT "X(16)"
      tt-gds-info.gds-name COLUMN-LABEL "Название товара" FORMAT "X(48)" width 20
      tt-chk-gds.src-qnty
      tt-chk-gds.src-price
      tt-chk-gds.src-discnt      
      tt-gds-info.src-d-pcnt COLUMN-LABEL "%" FORMAT "->>9.99%"
      tt-gds-info.src-price-netto  COLUMN-LABEL "Цена нетто в чеке" FORMAT "->>>,>>>,>>9.99"
      tt-gds-info.src-sum-netto COLUMN-LABEL "Итого в чеке" FORMAT "->>>,>>>,>>>,>>9.99"
      tt-gds-info.prt-name COLUMN-LABEL "Признак/!шкала" FORMAT "X(40)" width 20
      tt-chk-gds.doc-qnty COLUMN-LABEL "Количество БД"
      tt-chk-gds.price-base COLUMN-LABEL "Цена БД"
      tt-chk-gds.discnt COLUMN-LABEL "Скидка БД"
      tt-gds-info.d-pcnt COLUMN-LABEL "%" FORMAT "->>9.99%"
      tt-gds-info.price-netto COLUMN-LABEL "Цена нетто БД" FORMAT "->>>,>>>,>>9.99"
      tt-gds-info.sum-netto COLUMN-LABEL "Итого БД" FORMAT "->>>,>>>,>>>,>>9.99"
      tt-chk-gds.pump COLUMN-LABEL  "ТРК" FORMAT ">>9"
      tt-chk-gds.nozzle-code COLUMN-LABEL  "Пист" FORMAT ">>9"
      tt-chk-gds.loc1 COLUMN-LABEL  "Рез." FORMAT "X(3)"
      tt-chk-gds.src-pl-code COLUMN-LABEL  "Скл.!место!в чеке" FORMAT ">>>>>>>>9"
      tt-chk-gds.pl-code COLUMN-LABEL  "Скл.!место!БД" FORMAT ">>>>>>>>>>9"
      if (tt-chk-gds.write-off-code = 1 and can-do("14,15,16,17,36", string(tt-chk-doc.chk-type))) then "Пролито"       
      else {&wro-name} COLUMN-LABEL "Код спис" FORMAT "X(20)"
      tt-chk-gds.depart-id COLUMN-LABEL "Объект!кухни!в чеке" FORMAT ">>>>9" 
      tt-chk-gds.depart-code COLUMN-LABEL "Объект!кухни!в БД" FORMAT ">>>>9"
      tt-chk-gds.sales-man COLUMN-LABEL "Код!продавца"
      tt-gds-info.salesman-name COLUMN-LABEL "Продавец" FORMAT "X(16)"
      tt-chk-gds.road-tax COLUMN-LABEL "Дор. налог/! или тара"
      tt-chk-gds.src-sum COLUMN-LABEL "Сумма в чеке"
      tt-chk-gds.density COLUMN-LABEL "Плотность"
      tt-chk-gds.pass-gds COLUMN-LABEL "Тип!ввода"
      tt-chk-gds.vat-pc COLUMN-LABEL "% НДС" format "->9.9<%" 
      tt-chk-gds.vat-sum-rubl COLUMN-LABEL "Сумма!НДС"
  ENABLE
      tt-chk-gds.src-code
      tt-chk-gds.b-code
      tt-chk-gds.doc-qnty
      tt-chk-gds.pump
      tt-chk-gds.nozzle-code
      tt-chk-gds.loc1
      tt-chk-gds.pl-code
      tt-chk-gds.depart-id
      tt-chk-gds.depart-code
      tt-chk-gds.src-qnty
      tt-chk-gds.src-price
      tt-chk-gds.src-discnt
      tt-chk-gds.road-tax
      tt-chk-gds.vat-pc
      tt-chk-gds.vat-sum-rubl
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 102.5 BY 6.67
         FONT 4 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE BR-corr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-corr Dialog-Frame _FREEFORM
  QUERY BR-corr SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-gds.line-num COLUMN-LABEL "NN"  FORMAT "->>>>9"
      tt-chk-gds.b-code column-label "Номер!налога" format "9"
      get-tax-type(tt-chk-gds.b-code) @ v-tax-type
      tt-chk-gds.src-sum COLUMN-LABEL "Сумма" FORMAT "->>>,>>>,>>>,>>9.99"
      tt-chk-gds.depart-type COLUMN-LABEL "Номер!налога ОФД" format "X(4)"
      get-OVDtax-type(integer(tt-chk-gds.depart-type)) @ v-OVDtax-type
      tt-chk-gds.road-tax COLUMN-LABEL "Налог ОФД"
/*  ENABLE                    */
/*      tt-chk-gds.b-code     */
/*      tt-chk-gds.src-sum    */
/*      tt-chk-gds.depart-type*/
/*      tt-chk-gds.road-tax   */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 6.67
         FONT 4 ROW-HEIGHT-CHARS .67.

DEFINE BROWSE BR-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pay Dialog-Frame _FREEFORM
  QUERY BR-pay SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-pay.line-num COLUMN-LABEL "NN"
      tt-chk-pay.pay-code COLUMN-LABEL "Платеж"
      tt-chk-pay.curr-code COLUMN-LABEL "Валюта"
      tt-chk-pay.is-error COLUMN-LABEL "Ош" FORMAT "+/"
      get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
      varcurr-name COLUMN-LABEL "Валюта"
      tt-chk-pay.tot-sum COLUMN-LABEL "Сумма платежа"
      tt-chk-pay.tot-base COLUMN-LABEL "Баз.вал."
      tt-chk-pay.tot-rubl COLUMN-LABEL "{&abbr_rubli_firstshift}"
      tt-chk-pay.pay-card COLUMN-LABEL "№ плат.карты/!или № талона"
      tt-pay-info.calc-rate COLUMN-LABEL "Рассчит.курс!вал.пл-жа в БД"
      tt-pay-info.exch-date COLUMN-LABEL "Дата курса!маг-на" format "99/99/9999"
      tt-pay-info.exch-time-str COLUMN-LABEL "Время курса!маг-на" format "X(8)"
      tt-pay-info.exch-rate COLUMn-LABEL "Курс маг-на!вал.пл-жа"
      tt-pay-info.exch-scale COLUMn-LABEL "Масштаб маг-на!вал. пл-жа"
      tt-chk-pay.cash-rate COLUMN-LABEL "Курс вал. пл-жа!/к б.в.кассы"
      tt-chk-pay.src-val COLUMN-LABEL "Номинал!в чеке"
      tt-chk-pay.src-qnty COLUMN-LABEL "Кол-во!в чеке" FORMAT "->>>,>>9.99"
      tt-chk-pay.par-val COLUMN-LABEL "Номинал!в БД"
      tt-chk-pay.doc-qnty COLUMN-LABEL "Кол-во!в БД" FORMAT "->>>,>>9.99"
      tt-chk-pay.bank-rate
      tt-chk-pay.bank-scale
  ENABLE
      tt-chk-pay.pay-code
      tt-chk-pay.curr-code
      tt-chk-pay.tot-sum
      tt-chk-pay.pay-card
      tt-chk-pay.cash-rate
      tt-chk-pay.src-val
      tt-chk-pay.src-qnty
      tt-chk-pay.par-val
      tt-chk-pay.doc-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 102.5 BY 4.21
         FONT 4 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-prev AT ROW 1 COL 21
     B-next AT ROW 1 COL 25
     Cb-chk-type AT ROW 1 COL 36 COLON-ALIGNED NO-LABEL
     b-func AT ROW 1 COL 83.5
     br-attr AT ROW 1 COL 89.75 WIDGET-ID 8
     B-print AT ROW 1 COL 93.75
     B-hist AT ROW 1 COL 96.75
     B-help AT ROW 1 COL 99.75
     tt-chk-doc.src-tot-doc AT ROW 1.04 COL 75.63 COLON-ALIGNED WIDGET-ID 2
          LABEL "Брутто-чек" FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 11.88 BY 1 TOOLTIP "Брутто-чек"
          FGCOLOR 11 
     tt-chk-doc.chk-date AT ROW 2.08 COL 11.63 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN 
          SIZE 11.38 BY 1
     tt-chk-doc.cashier AT ROW 2.08 COL 35.75 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     fhour AT ROW 3.21 COL 11.75 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.21 COL 16 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.21 COL 20 COLON-ALIGNED NO-LABEL
     tt-chk-doc.sales-man AT ROW 3.21 COL 35.75 COLON-ALIGNED
          LABEL "Продавец"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     tt-chk-doc.obj-code AT ROW 4.42 COL 11.63 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN 
          SIZE 11.38 BY 1
     tt-chk-doc.d-card AT ROW 4.42 COL 35.75 COLON-ALIGNED
          LABEL "Карта"
          VIEW-AS FILL-IN 
          SIZE 17.38 BY 1
     B-card AT ROW 4.42 COL 55.5
     tt-chk-doc.pay-desk AT ROW 5.58 COL 11.63 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN 
          SIZE 5.63 BY 1
     b-cd AT ROW 5.58 COL 19.63 WIDGET-ID 6
     v-corr-osnov AT ROW 6.75 COL 11.63 COLON-ALIGNED
     tt-chk-doc.doc-num AT ROW 6.75 COL 28.63 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 24.88 BY 1
     tt-chk-doc.doc-num2 AT ROW 6.75 COL 64.63 COLON-ALIGNED WIDGET-ID 6
          LABEL "№ заказа"
          VIEW-AS FILL-IN 
          SIZE 36.38 BY 1
     v-corr-type AT ROW 6.75 COL 81 COLON-ALIGNED
     text-4 AT ROW 7.75 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     text-1 AT ROW 7.75 COL 40 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     v-susp-chk AT ROW 8.54 COL 3 NO-LABEL WIDGET-ID 86
     v-doc-osnov AT ROW 8.75 COL 12.13 COLON-ALIGNED WIDGET-ID 56
     corr-date AT ROW 8.75 COL 55.5 COLON-ALIGNED WIDGET-ID 24
     f-num-corr AT ROW 8.75 COL 100.5 RIGHT-ALIGNED WIDGET-ID 30
     BUTTON-1 AT ROW 8.79 COL 47 WIDGET-ID 54
     b-choose-date AT ROW 8.79 COL 69.5 WIDGET-ID 36
     BUTTON-susp AT ROW 8.79 COL 98.38 WIDGET-ID 88
     v-link-chk AT ROW 10.30 COL 28.88 COLON-ALIGNED WIDGET-ID 92
     f-cause-corr AT ROW 10.25 COL 100.5 RIGHT-ALIGNED WIDGET-ID 32
     tt-chk-doc.chk-num AT ROW 11.58 COL 12.13 COLON-ALIGNED
          LABEL "N по кассе" FORMAT "->>>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 12.63 BY 1
     tt-chk-doc.z-number AT ROW 11.58 COL 36.25 COLON-ALIGNED
          LABEL "Z-отчет"
          VIEW-AS FILL-IN 
          SIZE 10.63 BY 1
     tt-chk-doc.src-d-pcnt AT ROW 11.58 COL 65.13 COLON-ALIGNED
          LABEL "Скидка клиен.(%)"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     tt-chk-doc.src-shift-date AT ROW 12.71 COL 12.13 COLON-ALIGNED
          LABEL "&Дата смены" FORMAT "99/99/9999"
          VIEW-AS FILL-IN 
          SIZE 11.38 BY 1
     tt-chk-doc.cash-rate AT ROW 12.71 COL 65.13 COLON-ALIGNED
          LABEL "Курс нац вал."
          VIEW-AS FILL-IN 
          SIZE 19.75 BY 1
     tt-chk-doc.cash-scale AT ROW 12.71 COL 94.63 COLON-ALIGNED
          LABEL "Масштаб"
          VIEW-AS FILL-IN 
          SIZE 6.75 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-chk-doc.shift-name AT ROW 13.88 COL 12 COLON-ALIGNED
          LABEL "№ смены"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     tt-chk-doc.shift-num AT ROW 13.88 COL 16.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 4.25 BY 1
     v-src-d-card AT ROW 13.88 COL 36.13 COLON-ALIGNED
     b-addbonus AT ROW 13.88 COL 61.63
     B-adddiscnt AT ROW 13.88 COL 75.5
     B-addgds AT ROW 13.88 COL 89.5
     Btn_sht-from AT ROW 13.96 COL 23.13 WIDGET-ID 34
     BR-corr AT ROW 14.96 COL 1
     BR-gds AT ROW 14.96 COL 1
     BR-discnt AT ROW 14.96 COL 1
     BR-pay AT ROW 21.67 COL 1
     tt-chk-doc.PS AT ROW 26 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 69.38 BY 2
     b-slip-chk AT ROW 26.04 COL 71.38
     B-addpay AT ROW 26.04 COL 88.5
     B_mark AT ROW 27 COL 97.51 RIGHT-ALIGNED WIDGET-ID 80
     b-cf AT ROW 27.04 COL 88.63 WIDGET-ID 4
     F-cashier AT ROW 2.08 COL 43.13 COLON-ALIGNED NO-LABEL
     tt-chk-doc.tot-doc AT ROW 2.08 COL 81 COLON-ALIGNED
          LABEL "Сумма брутто"
           VIEW-AS TEXT 
          SIZE 20 BY 1
     F-salesman AT ROW 3.21 COL 43.13 COLON-ALIGNED NO-LABEL
     tt-chk-doc.discnt AT ROW 3.21 COL 81 COLON-ALIGNED
          LABEL "Скидка общ."
           VIEW-AS TEXT 
          SIZE 20 BY 1
     tt-chk-doc.sub-discnt AT ROW 4.42 COL 81 COLON-ALIGNED
          LABEL "Сумма списаний"
           VIEW-AS TEXT 
          SIZE 20 BY 1
     f-cli-name AT ROW 5.58 COL 35.75 COLON-ALIGNED
     tt-chk-doc.netto AT ROW 5.58 COL 81 COLON-ALIGNED
          LABEL "Сумма оплат(нетто)"
           VIEW-AS TEXT 
          SIZE 20 BY 1
     tt-chk-doc.d-pcnt AT ROW 11.58 COL 94.63 COLON-ALIGNED
          LABEL "Скидка итоговая(%)"
           VIEW-AS TEXT 
          SIZE 6.75 BY 1
     tt-chk-doc.shift-date AT ROW 12.71 COL 36.25 COLON-ALIGNED
          LABEL "Дата учета" FORMAT "99/99/9999"
           VIEW-AS TEXT 
          SIZE 10.63 BY 1
          FGCOLOR 12 
     "Тип чека" VIEW-AS TEXT
          SIZE 8.63 BY 1.04 AT ROW 1 COL 29
          FGCOLOR 4 
     "Время:" VIEW-AS TEXT
          SIZE 6.63 BY 1 AT ROW 3 COL 5.63
     RECT-1 AT ROW 8 COL 2 WIDGET-ID 26
     SPACE(1.24) SKIP(16.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cash-desk B "?" ? ub cash-desk
      TABLE: buf_cashier B "?" ? ub clients
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_dis-card B "?" ? ub dis-card
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_sales-man B "?" ? ub clients
      TABLE: cashier B "?" ? ub person
      TABLE: gds_bar-code B "?" ? ub bar-code
      TABLE: gds_goods B "?" ? ub goods
      TABLE: gds_parts B "?" ? ub parts
      TABLE: gds_prod-bc B "?" ? ub prod-bc
      TABLE: locked_chk-discnt B "?" ? ub chk-discnt
      TABLE: locked_chk-doc B "?" ? ub chk-doc
      TABLE: locked_chk-doc-attr B "?" ? ub chk-doc-attr
      TABLE: locked_chk-gds B "?" ? ub chk-gds
      TABLE: locked_chk-pay B "?" ? ub chk-pay
      TABLE: pay_cash-pay B "?" ? ub cash-pay
      TABLE: pay_currency B "?" ? ub currency
      TABLE: sales-man B "?" ? ub person
      TABLE: tt-chk-discnt T "NEW SHARED" NO-UNDO ub chk-discnt
      TABLE: tt-chk-doc T "NEW SHARED" NO-UNDO ub chk-doc
      ADDITIONAL-FIELDS:
          field real-subdiscnt as decimal
      END-FIELDS.
      TABLE: tt-chk-doc-attr T "?" NO-UNDO ub chk-doc-attr
      TABLE: tt-chk-gds T "NEW SHARED" NO-UNDO ub chk-gds
      TABLE: tt-chk-pay T "NEW SHARED" NO-UNDO ub chk-pay
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-discnt Btn_sht-from Dialog-Frame */
/* BROWSE-TAB BR-gds BR-discnt Dialog-Frame */
/* BROWSE-TAB BR-corr BR-gds Dialog-Frame */
/* BROWSE-TAB BR-pay BR-corr Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       b-addbonus:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-addbonus:HANDLE.

ASSIGN 
       B-adddiscnt:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-adddiscnt:HANDLE.

ASSIGN 
       BR-gds:POPUP-MENU IN FRAME Dialog-Frame             = MENU m-prt:HANDLE.

ASSIGN 
       BR-pay:POPUP-MENU IN FRAME Dialog-Frame             = MENU MENU-BR-pay:HANDLE.

/* SETTINGS FOR BUTTON B_mark IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
       B_mark:POPUP-MENU IN FRAME Dialog-Frame       = MENU m_marks:HANDLE.
ASSIGN b_mark:MENU-MOUSE = 1.

assign b-func:popup-menu IN FRAME Dialog-Frame       = MENU m-func:HANDLE.
ASSIGN b-func:MENU-MOUSE = 1.
/* SETTINGS FOR FILL-IN tt-chk-doc.cash-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.cash-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.cashier IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.chk-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.chk-num IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-chk-doc.d-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.d-pcnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.discnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.doc-num2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-cause-corr IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-num-corr IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN tt-chk-doc.netto IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.pay-desk IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.sales-man IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-chk-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.src-d-pcnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.src-shift-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-chk-doc.src-tot-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-chk-doc.sub-discnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN text-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       text-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN text-4 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       text-4:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-chk-doc.tot-doc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.z-number IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-discnt
/* Query rebuild information for BROWSE BR-discnt
     _START_FREEFORM
CASE par-mode:
  WHEN {&add-def} OR WHEN {&UPDATE} THEN DO:
    OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt WHERE
           tt-chk-discnt.doc-code = tt-chk-doc.doc-code
           AND tt-chk-discnt.record-type = v-br-discnt-current-type
        by tt-chk-discnt.line-num.
  END.
   WHEN  {&LOOKUP} THEN DO:
       OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt NO-LOCK
             WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code
           AND tt-chk-discnt.record-type = v-br-discnt-current-type
           by tt-chk-discnt.line-num.

   END.
END CASE.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _TblOptList       = ", FIRST"
     _JoinCode[1]      = "Temp-Tables.tt-chk-gds.doc-code = ub.chk-gds.doc-code
  AND Temp-Tables.tt-chk-gds.line-num = ub.chk-gds.line-num"
     _Where[1]         = "ub.chk-gds.doc-code = tt-chk-doc.doc-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-discnt */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds
/* Query rebuild information for BROWSE BR-gds
     _START_FREEFORM
CASE par-mode:
    WHEN {&add-def}
    OR
    WHEN {&update} THEN DO:
       IF dflt-cd = {&cd-type-magia-xml} THEN
OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds
      WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,
      FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by abs(tt-chk-gds.line-num).
    ELSE
    OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds
          WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,
          FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num  by tt-chk-gds.line-num.

    END.
    WHEN {&LOOKUP} THEN DO:
           IF dflt-cd = {&cd-type-magia-xml} THEN
        OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds NO-LOCK
            WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,
              FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num
            by abs(tt-chk-gds.line-num).
         ELSE
            OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds NO-LOCK
                WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code ,
                  FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num
                by tt-chk-gds.line-num.

    END.
END CASE.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _TblOptList       = ", FIRST, FIRST"
     _JoinCode[1]      = "Temp-Tables.tt-chk-gds.doc-code = ub.chk-gds.doc-code
  AND Temp-Tables.tt-chk-gds.line-num = ub.chk-gds.line-num"
     _Where[1]         = "ub.chk-gds.doc-code = tt-chk-doc.doc-code"
     _JoinCode[2]      = "tt-gds-info.line-num = ub.chk-gds.line-num"
     _Query            is NOT OPENED
*/  /* BROWSE BR-gds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pay
/* Query rebuild information for BROWSE BR-pay
     _START_FREEFORM
CASE par-mode:
  WHEN {&add-def}
  OR
  WHEN {&UPDATE}  THEN DO:
     OPEN QUERY {&SELF-NAME} FOR EACH  tt-chk-pay
         WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,
    first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num
         by tt-chk-pay.line-num.
 END.
  WHEN {&LOOKUP} THEN DO:
     OPEN QUERY {&SELF-NAME} FOR EACH  tt-chk-pay
         WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,
    first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num
         by tt-chk-pay.line-num.
 END.
END CASE.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _TblOptList       = ", FIRST, FIRST"
     _JoinCode[1]      = "Temp-Tables.tt-chk-pay.doc-code = ub.chk-pay.doc-code
  AND Temp-Tables.tt-chk-pay.line-num = ub.chk-pay.line-num"
     _Where[1]         = "ub.chk-pay.doc-code = tt-chk-doc.doc-code"
     _JoinCode[2]      = "tt-pay-info.line-num = ub.chk-pay.line-num"
     _Query            is OPENED
*/  /* BROWSE BR-pay */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-chk-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ANy-key OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
      return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
      apply "choose" to B-quit in frame {&frame-name}.
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON STOP OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
   apply "choose" to b-quit in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-addbonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-addbonus Dialog-Frame
ON CHOOSE OF b-addbonus IN FRAME Dialog-Frame /* Бонусы */
DO:
  run proc-b-addbonus in this-procedure  no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-adddiscnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-adddiscnt Dialog-Frame
ON CHOOSE OF B-adddiscnt IN FRAME Dialog-Frame /* Скидки */
DO:
  run proc-b-adddiscnt in this-procedure  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-addgds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-addgds Dialog-Frame
ON CHOOSE OF B-addgds IN FRAME Dialog-Frame /* Доб. товар */
DO:
{ gbl/stdbtn.i }
  run proc-b-addgds in this-procedure  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-addpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-addpay Dialog-Frame
ON CHOOSE OF B-addpay IN FRAME Dialog-Frame /* Оплата */
DO:
{ gbl/stdbtn.i }
  run proc-b-addpay in this-procedure  no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-slip-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-slip-chk Dialog-Frame
ON CHOOSE OF b-slip-chk IN FRAME Dialog-Frame /* Слипы (чек) */
DO:
{ gbl/stdbtn.i }
  run proc-b-slip in this-procedure  (input "chk")  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-card Dialog-Frame
ON CHOOSE OF B-card IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
  DEFINE VARIABLE cli-list as character no-undo .
    run ref/discards.w (
                     input parparentproc
                    ,input "b-sel":U
                    ,input {&all}
                    ,input get-chkc_context.host-code
                    ,input tt-chk-doc.obj-type
                    ,input tt-chk-doc.obj-code
                    ,input '':U
                    ,input ?
                    ,output cli-list ) no-error.

    if not cli-list  = "" then do:
      FIND FIRST buf_dis-card no-lock where
                  recid(buf_dis-card) = integer(cli-list).
      if buf_dis-card.status_ = {&nonused-status}
      or buf_dis-card.status_ = {&chown-status}
      then do:
        message
        substitute("Нельзя создать чек с картой &1&2" +
                  "Карта имеет статус &3, &4"
                  , buf_dis-card.d-card
                  , {&new-line}
                  , buf_dis-card.status_
                  , (if buf_dis-card.status_ = {&nonused-status}
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца")
                   )
        view-as alert-box error .
        return no-apply.
      end.
      DISPLAY
      buf_dis-card.d-card @ tt-chk-doc.d-card
      with frame {&frame-name}.
      find first buf_clients no-lock where
                  buf_clients.obj-type = buf_dis-card.cli-type
            AND  buf_clients.obj-code = buf_dis-card.cli-code.
      display
      buf_clients.obj-name @ f-cli-name
      with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd Dialog-Frame
ON CHOOSE OF b-cd IN FRAME Dialog-Frame /* Btn 1 */
DO:
  run sel-cd in this-procedure no-error.
  if error-status:error then return no-apply.
  else do:
    assign
    tt-chk-doc.pay-desk = buf_cash-desk.cash-num
    .
    display
    tt-chk-doc.pay-desk
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cf Dialog-Frame
ON CHOOSE OF b-cf IN FRAME Dialog-Frame /* Фиск */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run str/cf-cdtrs.w ( INPUT parparentproc
                      ,INPUT '':U /* bttns  */
                       ,INPUT 'chk-id' /*p-list-mode*/
                       ,INPUT 0 /* p-trans-type*/
                       ,INPUT tt-chk-doc.obj-type
                       ,INPUT tt-chk-doc.obj-code
                       ,INPUT ? /* p-start-date */
                       ,INPUT ? /*p-end-date*/
                       ,INPUT '' /*p-charkey-one*/
                       ,INPUT tt-chk-doc.chk-id
                       ,OUTPUT v-rid-list ) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-date Dialog-Frame
ON CHOOSE OF b-choose-date IN FRAME Dialog-Frame /* b-choose-date */
DO:
  run sel-date in this-procedure
    (input corr-date :handle
    ,input ""
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  if par-mode <>  "susp-type" then do: 
{ gbl/stdbtn.i }
  if par-mode = {&lookup} then.
  else do:
    run check-this-check in this-procedure no-error.
    if error-status:error then do:
      return no-apply.
    end.
  end.
  end.
  else do:
      v-is-update = true .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
    if available locked_chk-doc THEN
    run str/cchkdocs.w (
                        input parparentproc
                       , "":U /*bttns*/
                       , "one":U
                       , locked_chk-doc.doc-code
                       , p-obj-type
                       , p-obj-code
                       , input-output v-rid-list
                    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
{ gbl/stdbtn.i }
  run reposition-chk-doc in this-procedure
  (input 'next':U
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
{ gbl/stdbtn.i }
  run reposition-chk-doc in this-procedure
  (input 'prev':U
  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
or Right-Mouse-CLICK OF b-print IN FRAME {&frame-name}
DO:
define variable v-normal-call as logical no-undo .
{ gbl/stdbtn.i }
  if last-event:lABEL = "CHOOSE"
  or last-event:lABEL = "ENTER" then do:
    v-normal-call = yes.
  end.
  if v-normal-call then do:
    run str/checkp.p ( input parparentproc, input tt-chk-doc.doc-code).
  end.
  else do:
    run print-xml in this-procedure ( input (dataset superchk:handle)
                                        ,input tt-chk-doc.doc-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при выводе в XML"

      error-status:get-message(1)
      return-value
      view-as alert-box .
    end.
    else do:
      message
      "Чек напечатан в XML"
      view-as alert-box .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
/*UNDO, RETURN.*/
DO:
{ gbl/stdbtn.i }
  case par-mode:
    when {&add-def} then do:          
      /*if available locked_chk-doc then
       delete locked_chk-doc.*/       
       p-doc-rec = ?.       
    end.
  END CASE.  
  p-next-prev = "quit".
END. 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON CHOOSE OF br-attr IN FRAME Dialog-Frame /* Атр */
DO:
  if available locked_chk-doc then 
  run str\superchk-attr.w( input parparentproc,
                            input locked_chk-doc.doc-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-discnt
&Scoped-define SELF-NAME BR-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-discnt Dialog-Frame
ON DELETE-CHARACTER OF BR-discnt IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-line-num like ub.chk-discnt.line-num no-undo .
DEFINE VARIABLE v-value-type like ub.chk-discnt.value-type no-undo .
DEFINE VARIABLE v-line-type  like ub.chk-discnt.line-type no-undo .
define variable v-record-type as integer no-undo .
define variable v-discnt-type like ub.chk-discnt.discnt-type no-undo .
define buffer loc-tt-chk-discnt for tt-chk-discnt.
 if par-mode <> {&add-def} then return no-apply.
 glog = yes.
 if dflt-cd <> {&cd-type-ncr-gm}
 and dflt-cd <> {&cd-type-ncr-as-r}
 and tt-chk-discnt.record-type = 0
 then do:
  if tt-chk-discnt.object-line-num <> 0 then do:
    message
    "Нельзя удалить скидку/бонус"
    view-as alert-box .
    return no-apply.
  end.
 end.
  message
  "Удалить скидку/бонус из чека ?"
   view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return.
  assign
  v-line-num = tt-chk-discnt.line-num
  v-value-type = tt-chk-discnt.value-type
  v-line-type  = tt-chk-discnt.line-type
  v-record-type = tt-chk-discnt.record-type
  v-discnt-type = tt-chk-discnt.discnt-type
  .
  find first locked_chk-discnt where
           locked_chk-discnt.doc-code = tt-chk-doc.doc-code
      AND locked_chk-discnt.line-num = tt-chk-discnt.line-num
      AND locked_chk-discnt.object-line-num = tt-chk-discnt.object-line-num
      AND locked_chk-discnt.discnt-id = tt-chk-discnt.discnt-id.
  delete locked_chk-discnt.
  delete tt-chk-discnt.
  {&OPEN-QUERY-BR-discnt}
  if v-record-type < 4 then do:
  run get-discnt in this-procedure (
                                          input v-line-num
                                          ,input v-value-type
                                          ,input v-line-type
                                          ,input v-discnt-type
                                          ).
  v-is-sub-d = no.
  for each loc-tt-chk-discnt:
    if loc-tt-chk-discnt.line-type = integer({&discnt-sub-total}) then do:
      assign
      v-is-sub-d = yes
      .
    end.
  end.
  run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds
&Scoped-define SELF-NAME BR-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds Dialog-Frame
ON DELETE-CHARACTER OF BR-gds IN FRAME Dialog-Frame
DO:
if par-mode <> {&add-def} then return no-apply.
 glog = yes.
  message
  "Удалить товар из чека ?"
   view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return.
 find first locked_chk-gds where
          locked_chk-gds.doc-code= tt-chk-gds.doc-code
      AND locked_chk-gds.line-num = tt-chk-gds.line-num.
  for each locked_chk-discnt where
                locked_chk-discnt.doc-code = tt-chk-doc.doc-code and
                locked_chk-discnt.line-num = tt-chk-gds.line-num,
        each tt-chk-discnt where
                tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
                tt-chk-discnt.line-num = tt-chk-gds.line-num:
        if tt-chk-discnt.line-type = integer({&discnt-sub-total})  OR
           TT-chk-discnt.line-type = INTEGER({&discnt-total})
        then
        tt-chk-discnt.line-num = tt-chk-discnt.line-num - 1.
        else
        delete tt-chk-discnt.
        delete locked_chk-discnt.
    end.
  delete locked_chk-gds.
  delete tt-chk-gds.
  delete tt-gds-info.
  {&OPEN-QUERY-BR-gds}
  run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-pay
&Scoped-define SELF-NAME BR-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pay Dialog-Frame
ON DELETE-CHARACTER OF BR-pay IN FRAME Dialog-Frame
DO:
if par-mode <> {&add-def} then return no-apply.
   glog = yes.
  message
  "Удалить оплату из чека ?"
  view-as alert-box question buttons OK-Cancel update glog.
  if glog <> true then return.
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  delete locked_chk-pay.
  delete tt-chk-pay.
  delete tt-pay-info.
 {&OPEN-QUERY-BR-pay}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pay Dialog-Frame
ON ENTRY OF BR-pay IN FRAME Dialog-Frame
DO:
  APPLY "VALUE-CHANGED" TO br-pay.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pay Dialog-Frame
ON VALUE-CHANGED OF BR-pay IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
IF par-mode = {&UPDATE}  THEN do:

IF AVAILABLE tt-chk-pay
AND tt-chk-pay.pay-card <> ''
AND tt-chk-pay.pay-card <> '0' THEN DO:

  RUN cp-attr-value IN THIS-PROCEDURE (
                                         input tt-chk-pay.pay-code
                                        ,INPUT tt-chk-pay.curr-code
                                        ,INPUT 0 /*область действия глобально*/
                                        ,INPUT '' /*область действия глобально*/
                                         ,INPUT 0 /*область действия глобально*/
                                        ,INPUT {&cp-attr-paycard-edit-prefix}
                                         ,OUTPUT v-value
                                         ,OUTPUT v-type) no-ERROR.
    DO v-ii = 1 TO NUM-ENTRIES(v-value):
       IF tt-chk-pay.pay-card BEGINS ENTRY(v-ii, v-value) THEN DO:
           tt-chk-pay.pay-card:READ-ONLY IN BROWSE br-pay = NO.
       END.
    END.   /*do- v-ii*/
  END.
  ELSE DO:
   tt-chk-pay.pay-card:READ-ONLY IN BROWSE br-pay = YES.
  END.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_sht-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_sht-from Dialog-Frame
ON CHOOSE OF Btn_sht-from IN FRAME Dialog-Frame
DO:
  define variable c_shift-list   as character no-undo.
    run str/sht-all.w (parparentproc, 
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "b-sel",
        "obj",
        v-cntxt-obj-type,
        v-cntxt-obj-code,
        "",
        input-output c_shift-list) no-error.
    if error-status:error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
        return no-apply.
    end.
    if c_shift-list =  "":U then 
    do:
        return no-apply.
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (c_shift-list) no-lock.
    tt-chk-doc.src-shift-date:screen-value = string(buf_shift-obj.shift-date) no-error.
    tt-chk-doc.shift-name:screen-value = string(buf_shift-obj.shift-name) no-error.
    tt-chk-doc.shift-num:screen-value = string(buf_shift-obj.shift-num) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  def var p-corr-osnov as character no-undo.
  def var rid# as character no-undo .
  
  do with frame {&frame-name}:

    run ref/codelayout.p(parparentproc,{&select},"","OsnovCorr", "Основание коррекции",output table tmprecid).
/*          run ref/CorrOsnov.w */
/*        (input  parparentproc */
/*        ,input  'b-sel,b-mark'*/
/*        ,output rid#          */
/*        ) no-error.           */
    
    for first tmprecid where tmprecid.fTable = "code" no-lock:
      find first ub.Code no-lock where recid (ub.Code) = integer(tmprecid.Frecid) no-error .
      v-doc-osnov = ub.Code.CodeName.
      v-corr-osnov1 = integer(ub.Code.code) .
      display v-doc-osnov with frame {&frame-name} .
      apply "LEAVE":U to v-doc-osnov.
    end.
  end. /* do with frame */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-susp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-susp Dialog-Frame
ON CHOOSE OF BUTTON-susp IN FRAME Dialog-Frame
DO:
  define variable v-code as character no-undo .
  define buffer buf_reason for ub.code .  
  do with frame {&frame-name}:

    run ref/reasonSuspCheck.w(parparentproc,{&select},output v-code).

    find first buf_reason no-lock where buf_reason.parent = {&extclass_reasons-suspicious-check} and 
    buf_reason.code = v-code no-error .
    if available (buf_reason) then do:
        if buf_reason.code = "0" then do:
            charKey_one = buf_reason.code .
            v-susp = "Иная: " .
            v-susp-chk = "" .
            display v-susp-chk .
            enable v-susp-chk with frame {&frame-name} .
            v-susp-chk:read-only = false .
        end.
        else do:
            v-susp = "".
            charKey_one = buf_reason.code .
            v-susp-chk = buf_reason.CodeName . 
            display v-susp-chk .
            enable v-susp-chk with frame {&frame-name} .
            v-susp-chk:read-only = true .
            find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code no-error .
            if available (ub.susp-chk) then do:
                assign
                ub.susp-chk.reason-name = v-susp-chk
                .
            end.
        end.
    end.
  end. /* do with frame */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.cashier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.cashier Dialog-Frame
ON LEAVE OF tt-chk-doc.cashier IN FRAME Dialog-Frame /* Кассир */
DO:
  assign
    tt-chk-doc.cashier.
  run get-staff in this-procedure ( input tt-chk-doc.cashier, input {&role-cashier}, input tt-chk-doc.chk-date ) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.cashier Dialog-Frame
ON RETURN OF tt-chk-doc.cashier IN FRAME Dialog-Frame /* Кассир */
DO:
  assign
    tt-chk-doc.cashier.
  run get-staff in this-procedure ( input tt-chk-doc.cashier, input {&role-cashier}, input tt-chk-doc.chk-date) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-chk-type Dialog-Frame
ON VALUE-CHANGED OF Cb-chk-type IN FRAME Dialog-Frame
DO:
DEFINE variable old-chk-type AS CHARACTER NO-UNDO.
  IF CAN-FIND(FIRST tt-chk-gds WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code)
  OR CAN-FIND(FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
      THEN DO:
      MESSAGE
      "Установить тип чека можно только в самом начале процесса создания чека" SKIP
      "когда еще не созданы товарные строки и строк оплаты"
      VIEW-AS ALERT-BOX ERROR.
      display cb-chk-type
      with frame {&frame-name} .
      RETURN NO-APPLY.
  END.
  ASSIGN
  old-chk-type = cb-chk-type
  CB-chk-type
  .
&scop RECEIPT-CODE cb-chk-type
  if cb-chk-type = {&rcpt-annu} then do:
    if get-chkc_context.annu-check = no then do:
      message
      substitute("Чек типа &1 можно получить только если включен параметр <принимать аннулированные чеки>&2" +
                  "АРМ Администратор-Справочники-Магазины-Параметры-Опции закачки чеков&2" +
                  "или&2" +
                  "АРМ Администратор-Список фирм-Параметры-Опции закачки чеков"
                , {&receipt-name}
                , {&new-line}
                )
      view-as alert-box error .
      assign
      cb-chk-type = {&rcpt-sale}.
      display
      cb-chk-type
      with frame {&frame-name} .
      return no-apply.
    end.
    if get-chkc_context.z-check = no then do:
      message
      substitute("Чек типа &1 можно получить только если включен параметр <принимать чеки z-отчета>&2" +
                  "АРМ Администратор-Справочники-Магазины-Параметры-Опции закачки чеков&2" +
                  "или&2" +
                  "АРМ Администратор-Список фирм-Параметры-Опции закачки чеков"
                , {&receipt-name}
                , {&new-line}
                )
      view-as alert-box error .
      assign
      cb-chk-type = {&rcpt-sale}.
      display
      cb-chk-type
      with frame {&frame-name} .
      return no-apply.
    end.
  end.
  if lookup(cb-chk-type, {&petrol-receipt-codes}) > 0 then do:
    if ptrl-check = no then do:
      message
      substitute("Чек типа &1 можно получить только если включен параметр <принимать специф.чеки АЗК>&2" +
                  "АРМ Администратор-Справочники-Магазины-Параметры-Опции закачки чеков&2" +
                  "или&2" +
                  "АРМ Администратор-Список фирм-Параметры-Опции закачки чеков"
                , {&receipt-name}
                , {&new-line}
                )
      view-as alert-box error .
      assign
      cb-chk-type = {&rcpt-sale}.
      display
      cb-chk-type
      with frame {&frame-name} .
      return no-apply.
    end.
  end.
  if cb-chk-type = {&rcpt-write-off}
  or cb-chk-type = {&rcpt-return-write-off} then do:
    if not get-chkc_context.is-catering then do:
      message
      substitute("Чек типа &1 можно получить только на объекте, на котором включена опция РЕСТОРАН&2"
                , {&receipt-name})
      view-as alert-box error .
      assign
      cb-chk-type = {&rcpt-sale}.
      display
      cb-chk-type
      with frame {&frame-name} .
      return no-apply.
    end.
  end.

  assign
  tt-chk-doc.chk-type = integer(CB-chk-type).
  if par-mode = {&add-def} and available locked_chk-doc then
  locked_chk-doc.chk-type = integer(CB-chk-type).
  case CB-chk-type:
    when {&rcpt-return-write-off}
    or when {&rcpt-write-off}
    then do:
      menu-item m-write-off:sensitive in menu M-prt = no.
      menu-item m-modificator:sensitive in menu M-prt = YES.
      ASSIGN
      b-adddiscnt:SENSITIVE IN FRAME {&FRAME-NAME} = YES
      b-addbonus:SENSITIVE IN FRAME {&FRAME-NAME} = YES
      b-addpay:SENSITIVE IN FRAME {&FRAME-NAME} = YES
      .
    end.
    WHEN  {&rcpt-trans-cancell}
    OR
    WHEN  {&rcpt-trans-transfer}
    OR
    WHEN  {&rcpt-overflow}
    OR
    WHEN  {&rcpt-tech-refuell}
    or
    when {&rcpt-inventory}
    or
    when {&rcpt-unlock-trans}
    THEN DO:
         assign
         menu-item m-write-off:sensitive in menu M-prt = NO
         menu-item m-modificator:sensitive in menu M-prt = NO
         b-adddiscnt:SENSITIVE IN FRAME {&FRAME-NAME} = NO
         b-addbonus:SENSITIVE IN FRAME {&FRAME-NAME} = NO
         b-addpay:SENSITIVE IN FRAME {&FRAME-NAME} = NO
         .
    end.
    otherwise do:
        if get-chkc_context.is-catering then
         assign
         menu-item m-write-off:sensitive in menu M-prt = yes
         menu-item m-modificator:sensitive in menu M-prt = yes
         .
        ASSIGN
        b-adddiscnt:SENSITIVE IN FRAME {&FRAME-NAME} = YES
        b-addbonus:SENSITIVE IN FRAME {&FRAME-NAME} = YES
        b-addpay:SENSITIVE IN FRAME {&FRAME-NAME} = YES
        .
    END.
  END CASE.
 if CB-chk-type = {&rcpt-z-rep} then do:
    assign
    tt-chk-pay.tot-sum:read-only in browse br-pay = no
    tt-chk-pay.pay-code:read-only in browse br-pay = yes
    tt-chk-pay.pay-code:visible in browse br-pay = no
    tt-chk-pay.curr-code:visible in browse br-pay = no
    tt-chk-pay.pay-card:visible in browse br-pay = no
    tt-chk-pay.tot-sum:label in browse br-pay = "Сумма"
    b-addpay:visible = no
    .
    RUN create-z-rep IN THIS-PROCEDURE NO-ERROR.
  end.
  else do:
    assign
    tt-chk-pay.tot-sum:read-only in browse br-pay = no
    tt-chk-pay.pay-code:visible in browse br-pay = yes
    tt-chk-pay.curr-code:visible in browse br-pay = yes
    tt-chk-pay.pay-card:visible in browse br-pay = yes
    tt-chk-pay.tot-sum:label in browse br-pay = "Сумма платежа"
    b-addpay:visible = yes
    .
    IF old-chk-type = {&rcpt-z-rep} THEN DO:
       RUN delete-z-rep IN THIS-PROCEDURE NO-ERROR.
    END.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-chk-doc.chk-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.chk-num Dialog-Frame
ON value-changed OF tt-chk-doc.chk-num IN FRAME Dialog-Frame /* Номер чека */
DO:
  assign
  tt-chk-doc.chk-num.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-chk-doc.chk-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.chk-date Dialog-Frame
ON LEAVE OF tt-chk-doc.chk-date IN FRAME Dialog-Frame /* Дата */
DO:
  assign
  tt-chk-doc.chk-date.
  run find-uchet-date in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-chk-doc.src-d-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.src-d-card Dialog-Frame
ON LEAVE OF v-src-d-card IN FRAME Dialog-Frame /* ДК в чеке */
DO:

  assign
  v-src-d-card .
  
  tt-chk-doc.src-d-card = v-src-d-card .
  if par-l-mask and tt-chk-doc.src-d-card <> "" then v-src-d-card = substring(tt-chk-doc.src-d-card,1,6) + "XXXXXX" + substring (tt-chk-doc.src-d-card,13,4).
  else v-src-d-card = tt-chk-doc.src-d-card .
      display
      v-src-d-card
      with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME corr-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL corr-date Dialog-Frame
ON LEAVE OF corr-date IN FRAME Dialog-Frame /* Дата */
DO:
  assign corr-date.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.d-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.d-card Dialog-Frame
ON LEAVE OF tt-chk-doc.d-card IN FRAME Dialog-Frame /* Карта */
DO:
  assign
  tt-chk-doc.d-card
  .
  find first buf_dis-card no-lock where
              buf_dis-card.d-card = trim(tt-chk-doc.d-card) no-error.
  if avail buf_dis-card then do:
    if buf_dis-card.status_ = {&nonused-status}
    or buf_dis-card.status_ = {&chown-status}
    then do:
      message
      substitute("Нельзя создать чек с картой &1&2" +
                  "Карта имеет статус &3, &4"
                  , buf_dis-card.d-card
                  , {&new-line}
                  , buf_dis-card.status_
                  , (if buf_dis-card.status_ = {&nonused-status}
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца" )
                   )
      view-as alert-box error .
      assign
      tt-chk-doc.d-card = '':U
      .
      display
      tt-chk-doc.d-card
      with frame {&frame-name} .
      return no-apply.
    end.
    find first buf_clients no-lock where
                buf_clients.obj-type = buf_dis-card.cli-type
           AND buf_clients.obj-code = buf_dis-card.cli-code no-error.
    if available buf_clients then do:
        display
        buf_clients.obj-name @ f-cli-name
        with frame {&frame-name}.
    end.
    else do:
        release buf_clients.
        display
        {&question-mark} @ f-cli-name
        with frame {&frame-name}.
    end.
  end.
  else do:
        release buf_clients.
        display
        {&question-mark} @ f-cli-name
        with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cause-corr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cause-corr Dialog-Frame
ON LEAVE OF f-cause-corr IN FRAME Dialog-Frame /* Описание корректировки */
DO:
  assign f-cause-corr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num-corr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num-corr Dialog-Frame
ON LEAVE OF f-num-corr IN FRAME Dialog-Frame /* Номер */
DO:
  assign f-num-corr.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fhour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fhour Dialog-Frame
ON LEAVE OF fhour IN FRAME Dialog-Frame
DO:
  assign fhour.
  run check-time in this-procedure ( input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fmin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fmin Dialog-Frame
ON LEAVE OF fmin IN FRAME Dialog-Frame
DO:
  assign fmin.
  run check-time in this-procedure ( input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fsec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fsec Dialog-Frame
ON LEAVE OF fsec IN FRAME Dialog-Frame
DO:
  assign fsec.
  run check-time in this-procedure ( input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.

END.

find first user-login where user-login.user-id = ibs.th.gbl.gbl-var:g#userid 
                        and user-login.db-num  = ibs.th.gbl.gbl-var:g#db-num  
                        no-lock no-error.
  if user-login.user-administrator = no then do: 
    menu-item m-gds:sensitive   in menu M-prt = no.
    menu-item m-prt-1:sensitive in menu M-prt = no.
    menu-item m-prt-2:sensitive in menu M-prt = no.
  end.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds /* Товар */
DO:
  if not avail tt-chk-gds then return no-apply.
  run proc-chg-gds in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-modificator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-modificator Dialog-Frame
ON CHOOSE OF MENU-ITEM m-modificator /* Признак модификатора с нулевой ценой */
DO:
 DEFINE VARIABLE choice AS INTEGER NO-UNDO.
 DEFINE BUFFER buf_tt-chk-gds FOR tt-chk-gds.
    if not avail tt-chk-gds then return.

  run gbl/d-askw.w ( input "Выбор кода списания",
                      input "Установить признак МОДИФИКАТОРА С 0 ЦЕНОЙ на текущую товарную позицию",
                      input "|",
                      input "Нет|Да|Да+СПИСАНИЕ|Отказ",
                      input "Не  установлен|МОДИФИКАТОР С 0-ЦЕНОЙ"
                            + (if tt-chk-doc.chk-type = integer({&rcpt-return-write-off})
                               or tt-chk-doc.chk-type = integer({&rcpt-write-off})
                               then "^disable":U
                               else "":U)
                            + "|МОДИФИКАТОР С 0-ценой+КОД СПИСАНИЯ|Отказ от установки кода списания",
                      input 1,
                      input 4,
                      output choice).

 IF choice = 4  THEN RETURN NO-APPLY.
 FIND FIRST buf_tt-chk-gds EXCLUSIVE-LOCK WHERE
        RECID(buf_tt-chk-gds) = recid(tt-chk-gds).
 CASE choice:
     WHEN 1 THEN DO:
       ASSIGN
       buf_tt-chk-gds.write-off-code = 0.
     END.
     WHEN 2 THEN DO:
        CASE tt-chk-doc.chk-type:
            WHEN INTEGER({&rcpt-sale}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-r-modificator}).

            END.
            WHEN INTEGER({&rcpt-return}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-v-modificator}).

            END.
            WHEN INTEGER({&rcpt-return-write-off}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-v-modificator-ca}).

            END.
            WHEN INTEGER({&rcpt-write-off}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-r-modificator-wp}).

            END.
        END CASE.

     END.
     WHEN 3 THEN DO:
        CASE tt-chk-doc.chk-type:
            WHEN INTEGER({&rcpt-sale}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-r-modificator-wp}).

            END.
            WHEN INTEGER({&rcpt-return}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-v-modificator-ci}).

            END.
            WHEN INTEGER({&rcpt-return-write-off}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-v-modificator-ca}).

            END.
        END CASE.
   END.
 END CASE.
 run get-sums in this-procedure no-error .
display
tt-chk-doc.tot-doc
tt-chk-doc.discnt
tt-chk-doc.netto
tt-chk-doc.src-tot-doc
with frame {&frame-name}.
 br-gds:REFRESH()  IN FRAME {&FRAME-NAME}.
 apply "entry" to br-gds in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-pay Dialog-Frame
ON CHOOSE OF MENU-ITEM m-pay /* Оплата */
DO:
if not available tt-chk-pay then return no-apply.
  run proc-chg-pay in this-procedure ( input yes, input tt-chk-pay.curr-code) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-prt-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-prt-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-prt-1 /* Признаки */
DO:
 DEFINE BUFFER b_goods for ub.goods.
  DEFINE BUFFER b_bar-code for ub.bar-code.
 if not avail tt-chk-gds then return.
 FIND FIRST b_bar-code No-LOCK WHERE
                   b_bar-code.b-code = tt-chk-gds.b-code No-ERROR.
  if not avail b_bar-code then return no-apply.
 FIND FIRST b_Goods No-LOCK WHERE
                    b_goods.gds-code = b_bar-code.gds-code No-ERROR.
  if not avail b_goods then return no-apply.
  run setprts in this-procedure ( input recid(b_goods), input recid(b_bar-code), input b_goods.prt-root, input yes) no-error.
  if error-status:error then return no-apply.
  apply "entry" to br-gds in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-prt-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-prt-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-prt-2 /* Партии */
DO:
  DEFINE BUFFER b_goods for ub.goods.
  DEFINE BUFFER b_bar-code for ub.bar-code.
 if not avail tt-chk-gds then return.
 FIND FIRST b_bar-code No-LOCK WHERE
                   b_bar-code.b-code = tt-chk-gds.b-code No-ERROR.
  if not avail b_bar-code then return no-apply.
 FIND FIRST b_Goods No-LOCK WHERE
                    b_goods.gds-code = b_bar-code.gds-code No-ERROR.
  if not avail b_goods then return no-apply.
    run setparts in this-procedure ( input b_goods.gds-code, input b_bar-code.unit-cli, input b_bar-code.node-code) no-error.
    if error-status:error then return no-apply.
    apply "entry" to br-gds in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-sales-man
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-sales-man Dialog-Frame
ON CHOOSE OF MENU-ITEM m-sales-man /* Продавец или официант */
DO:
  define variable sale-list as character no-undo .
  define buffer buf_person  for ub.person.
  if not avail tt-chk-gds then return no-apply.
  define buffer buf_staff  for ub.staff.
  run ref/staffs.w (
                 input parparentproc
                ,input "b-sel"
                ,input {&role-seller}
                ,input get-chkc_context.db-num
                ,input 0
                ,output sale-list ) .
  if sale-list = '':u then return no-apply.
  find first buf_staff no-lock where
            recid(buf_staff) = integer(sale-list) no-error .
  if not available buf_staff then return no-apply.
  assign
  tt-chk-gds.sales-man = buf_staff.staff-code + (if dflt-cd = {&cd-type-MAGIA-XML} then 10000 else 0)
  tt-gds-info.salesman-name = get-salesman (input tt-chk-gds.sales-man, input tt-chk-doc.chk-date, output tt-chk-gds.salesman-psn-code)
  .
  assign
  tt-chk-doc.sales-man = 0
  .
  run get-staff in this-procedure ( input tt-chk-doc.sales-man, input {&role-seller}, input tt-chk-doc.chk-date) no-error.
  DISPLAY
  tt-chk-gds.sales-man
  tt-gds-info.salesman-name
  with browse br-gds.
  apply "entry" to br-gds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-write-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-write-off Dialog-Frame
ON CHOOSE OF MENU-ITEM m-write-off /* Код списания */
DO:
 DEFINE VARIABLE choice AS INTEGER NO-UNDO.
 DEFINE BUFFER buf_tt-chk-gds FOR tt-chk-gds.
    if not avail tt-chk-gds then return.

  run gbl/d-askw.w (input "Выбор кода списания",
                      input "Установить признак СПИСАНИЕ на текущую товарную позицию",
                      input "|",
                      input "Нет|Да|Отказ",
                      input "Не  установлен|Установлен|Отказ от установки кода списания",
                      input 1,
                      input 3,
                      output choice).

 IF choice = 3  THEN RETURN NO-APPLY.
 FIND FIRST buf_tt-chk-gds EXCLUSIVE-LOCK WHERE
        RECID(buf_tt-chk-gds) = recid(tt-chk-gds).
 CASE choice:
     WHEN 1 THEN DO:
       ASSIGN
       buf_tt-chk-gds.write-off-code = 0.
     END.
     WHEN 2 THEN DO:
        CASE tt-chk-doc.chk-type:
            WHEN INTEGER({&rcpt-sale})
             or when integer({&rcpt-write-off})
            THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-without-payment}).

            END.
            WHEN INTEGER({&rcpt-return}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-cancell-item}).

            END.
            WHEN INTEGER({&rcpt-return-write-off}) THEN DO:
                ASSIGN
                buf_tt-chk-gds.write-off-code = INTEGER({&wro-cancell-all}).

            END.
        END CASE.

     END.
 END CASE.

 run get-sums in this-procedure no-error .
display
tt-chk-doc.tot-doc
tt-chk-doc.discnt
tt-chk-doc.netto
tt-chk-doc.src-tot-doc
with frame {&frame-name}.
 br-gds:REFRESH()  IN FRAME {&FRAME-NAME}.
 apply "entry" to br-gds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cash-abs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cash-abs Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cash-abs /* На подитог абсолютная */
DO:
   discnt-option = {&discnt-sub-total} + {&comma-char} + {&discnt-v-abs}.
    apply "choose" to b-adddiscnt in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cash-abs-bon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cash-abs-bon Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cash-abs-bon /* На подитог */
DO:
   discnt-option = {&discnt-sub-total} + {&comma-char} + {&discnt-v-bonus}.
    apply "choose" to b-addbonus in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cash-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cash-pcnt Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cash-pcnt /* На подитог процентная */
DO:
   discnt-option = {&discnt-sub-total} + {&comma-char} + {&discnt-v-pcnt}.
    apply "choose" to b-adddiscnt in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gds-abs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds-abs Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gds-abs /* На товар абсолютная */
DO:
     discnt-option = {&discnt-gds} + {&comma-char} + {&discnt-v-abs}.
    apply "choose" to b-adddiscnt in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gds-abs-bon
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds-abs-bon Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gds-abs-bon /* На товар */
DO:
    discnt-option = {&discnt-gds} + {&comma-char} + {&discnt-v-bonus}.
    apply "choose" to b-addbonus in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-add-blocked-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-add-blocked-marks Dialog-Frame
ON CHOOSE OF MENU-ITEM m-add-blocked-marks /* "Автозаполнение по заблок. маркам" */
DO:
  run add-blocked-marks .
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME m_marks-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_marks-lines Dialog-Frame
ON CHOOSE OF MENU-ITEM m_marks-lines /* Марки по линии */
DO:
    if available (tt-chk-gds) then 
    do:
       run temp-mark (input 1) .  
      if available (tt-marking-lines) then 
      do:
        
        run str/mark_browse.w (input parparentproc,
          input-output table tt-marking-lines by-reference,
          input {&lookup},
          input "Марки по чеку: " + tt-chk-doc.doc-code + " по товару " + string(tt-gds-info.gds-name) + " " + tt-gds-info.gds-name,
          input 4,
          input "" /*тип продукции*/
          ) no-error .

      end.
      else 
      do:
        message "Нет марок"
          view-as alert-box.
      end.    
    end.
    else message "Нет марок"
        view-as alert-box.  
    return no-apply .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_marks-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_marks-utd Dialog-Frame
ON CHOOSE OF MENU-ITEM m_marks-utd /* Марки по чеку */
DO:
    run temp-mark (input 2) .
    if available (tt-marking-lines) then 
    do:
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input {&lookup},
        input "Марки по чеку: " + tt-chk-doc.doc-code,
        input 4,
        input "" /*тип продукции*/
        ) no-error .
        
    end.
    else 
    do:
      message "Нет марок по документу УПД"
        view-as alert-box.
    end.    

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.sales-man
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.sales-man Dialog-Frame
ON LEAVE OF tt-chk-doc.sales-man IN FRAME Dialog-Frame /* Продавец */
DO:
   assign
    tt-chk-doc.sales-man.
  run get-staff in this-procedure ( input tt-chk-doc.sales-man, input {&role-seller}, input tt-chk-doc.chk-date) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.sales-man Dialog-Frame
ON RETURN OF tt-chk-doc.sales-man IN FRAME Dialog-Frame /* Продавец */
DO:
   assign
    tt-chk-doc.sales-man.
  run get-staff in this-procedure ( input tt-chk-doc.sales-man, input {&role-seller}, input tt-chk-doc.chk-date) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.src-d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.src-d-pcnt Dialog-Frame
ON LEAVE OF tt-chk-doc.src-d-pcnt IN FRAME Dialog-Frame /* Скидка клиен.(%) */
DO:
  assign
  tt-chk-doc.src-d-pcnt.
  run proc-pcnt-discnt in this-procedure ( input tt-chk-doc.src-d-pcnt) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.src-shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.src-shift-date Dialog-Frame
ON LEAVE OF tt-chk-doc.src-shift-date IN FRAME Dialog-Frame /* Дата смены */
DO:
  assign
  tt-chk-doc.src-shift-date.
  run find-uchet-date in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-susp-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-susp-chk Dialog-Frame
ON LEAVE OF v-susp-chk IN FRAME Dialog-Frame
DO:
  assign
    v-susp-chk.
    
            find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code no-error .
            if available (ub.susp-chk) then do:
                if v-susp = "Иная: " then ub.susp-chk.reason-name = v-susp + v-susp-chk .
                else ub.susp-chk.reason-name = v-susp-chk .
            end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-link-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-link-chk Dialog-Frame
ON LEAVE OF v-link-chk IN FRAME Dialog-Frame
DO:
  assign
    v-link-chk.
            find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code no-error .
            if available (ub.susp-chk) then do:
                ub.susp-chk.link-chk = v-link-chk .
            end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BR-corr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
  Marking = ObjSrv:Env:Marking:Sts:Mark.
{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i  &browse-name="br-gds" }
{ gbl/ed_date.i corr-date }
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-pay :handle
  ) .
run diasize_init in this-procedure .


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

on F9 of frame {&frame-name} anywhere do:
define buffer buf_bar-code  for ub.bar-code.
if not available tt-chk-gds then return no-apply.
find first buF_bar-code no-lock where
           buf_bar-code.b-code = tt-chk-gds.b-code no-error .
if not available buf_bar-code then return no-apply.
run str/showgds.p ( input parparentproc
                  ,input THIS-PROCEDURE:HANDLE /*p-call-handle*/
                  ,input buf_bar-code.gds-code
                  ,input {&lookup}) no-error .
if error-status:error then return no-apply.
apply "entry" to br-gds in frame {&frame-name}.
return no-apply.
end.

ON value-changed OF br-gds do:
/* { gbl/stdbtn.i }*/
end.

ON LEAVE OF tt-chk-gds.src-qnty IN BROWSE br-gds,
            tt-chk-gds.src-price IN BROWSE br-gds,
            tt-chk-gds.src-discnt IN BROWSE br-gds,
            tt-chk-gds.src-code IN BROWSE br-gds,
            tt-chk-gds.doc-qnty IN BROWSE br-gds,
            tt-chk-gds.b-code IN BROWSE br-gds DO:
define variable old-b-code      like tt-chk-gds.b-code no-undo .
define variable old-src-code    like tt-chk-gds.src-code no-undo .
define variable old-src-qnty like tt-chk-gds.src-qnty no-undo .
define variable old-doc-qnty like tt-chk-gds.doc-qnty no-undo .
define variable old-src-price like tt-chk-gds.src-price no-undo .
define variable old-src-sum like tt-chk-gds.src-sum no-undo .
define variable old-src-discnt like tt-chk-gds.src-discnt no-undo .
define variable old-vat-summ like tt-chk-gds.VAT-sum-rubl no-undo .

    if not avail tt-chk-gds then return no-apply.
    if self:name = "b-code":U and par-mode = {&update} and
    tt-chk-gds.b-code <> integer(tt-chk-gds.b-code:screen-value in browse br-gds) then do:        
    RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
    if error-status:error then do:
      tt-chk-gds.b-code:screen-value in browse br-gds = string(tt-chk-gds.b-code).
      return no-apply.
    end.           
    end.
    else do:
      assign
      old-b-code       = tt-chk-gds.b-code
      old-src-code     = tt-chk-gds.src-code
      old-src-qnty     = tt-chk-gds.src-qnty
      old-doc-qnty     = tt-chk-gds.doc-qnty
      old-src-price    = tt-chk-gds.src-price
      old-src-sum      = tt-chk-gds.src-sum
      old-src-discnt   = tt-chk-gds.src-discnt
      old-vat-summ     = tt-chk-gds.VAT-sum-rubl
      .
      if old-src-discnt = 0
      and decimal(tt-chk-gds.src-discnt:screen-value in browse br-gds    ) <> 0 then do:
        define variable v-vchoice as integer no-undo .
        define variable v-dchoice as integer no-undo .
        run str/askmdisc.w ( input-output v-vchoice
                            ,input-output v-dchoice) no-error.
        if v-vchoice = 0 then do:
          assign
          tt-chk-gds.src-discnt = old-src-discnt.
          display
          tt-chk-gds.src-discnt
          with browse br-gds.
          return no-apply.
        end.
      end.
      
      assign
      tt-chk-gds.b-code = integer(tt-chk-gds.b-code:screen-value in browse br-gds)
      tt-chk-gds.src-code = tt-chk-gds.src-code:screen-value in browse br-gds
      tt-chk-gds.src-qnty = decimal(tt-chk-gds.src-qnty:screen-value in browse br-gds    )
      tt-chk-gds.src-discnt = decimal(tt-chk-gds.src-discnt:screen-value in browse br-gds    )
      tt-chk-gds.src-price = decimal(tt-chk-gds.src-price:screen-value in browse br-gds    )
      tt-chk-gds.src-sum = tt-chk-gds.src-qnty * tt-chk-gds.src-price
      tt-chk-gds.VAT-sum-rubl = ((tt-chk-gds.src-price * tt-chk-gds.VAT-pc)/(100 + tt-chk-gds.VAT-pc)) * tt-chk-gds.src-qnty
      .
      run get-b-code in this-procedure ( input v-vchoice
                                        ,input v-dchoice
                                      ) no-error.
      if error-status:error then do:
        assign
        tt-chk-gds.b-code     =   old-b-code
        tt-chk-gds.src-code   =   old-src-code
        tt-chk-gds.src-qnty   =   old-src-qnty
        tt-chk-gds.doc-qnty   =   old-doc-qnty
        tt-chk-gds.src-price  =   old-src-price
        tt-chk-gds.src-sum    =   old-src-sum
        tt-chk-gds.src-discnt =   old-src-discnt
        tt-chk-gds.VAT-sum-rubl = old-vat-summ
        .
        display
        tt-chk-gds.b-code
        tt-chk-gds.src-code
        tt-chk-gds.src-qnty
        tt-chk-gds.doc-qnty
        tt-chk-gds.src-price
        tt-chk-gds.src-discnt
        tt-chk-gds.VAT-sum-rubl
        with browse br-gds.
        undo, return no-apply.
      end.
      find first buf_marking-chk no-lock where buf_marking-chk.doc-code = tt-chk-gds.doc-code
                                           and buf_marking-chk.line-num = tt-chk-gds.line-num
                                           no-error .
      if available buf_marking-chk
      then do :
        assign
          tt-chk-gds.b-code     =   old-b-code
          tt-chk-gds.src-code   =   old-src-code
          tt-chk-gds.src-qnty   =   old-src-qnty
          tt-chk-gds.doc-qnty   =   old-doc-qnty
          tt-chk-gds.src-price  =   old-src-price
          tt-chk-gds.src-sum    =   old-src-sum
          tt-chk-gds.src-discnt =   old-src-discnt
          tt-chk-gds.VAT-sum-rubl = old-vat-summ
        .
        display
          tt-chk-gds.b-code
          tt-chk-gds.src-code
          tt-chk-gds.src-qnty
          tt-chk-gds.doc-qnty
          tt-chk-gds.src-price
          tt-chk-gds.src-discnt
          tt-chk-gds.VAT-sum-rubl
        with browse br-gds.
      end .                                     
    end.
end.

ON LEAVE OF tt-chk-gds.pump IN BROWSE br-gds,
            tt-chk-gds.nozzle-code IN BROWSE br-gds,
            tt-chk-gds.loc1 IN BROWSE br-gds,
            tt-chk-gds.road-tax IN BROWSE br-gds,
            tt-chk-gds.depart-id IN BROWSE br-gds,
            tt-chk-gds.depart-code IN BROWSE br-gds,
            tt-chk-gds.pl-code IN BROWSE br-gds
            DO:
    assign
    tt-chk-gds.pump = integer(tt-chk-gds.pump:screen-value in browse br-gds    )
    tt-chk-gds.nozzle-code = integer(tt-chk-gds.nozzle-code:screen-value in browse br-gds    )
    tt-chk-gds.loc1 = tt-chk-gds.loc1:screen-value in browse br-gds
    tt-chk-gds.road-tax = decimal(tt-chk-gds.road-tax:screen-value in browse br-gds    )
    tt-chk-gds.depart-id = integer(tt-chk-gds.depart-id:screen-value in browse br-gds)
    tt-chk-gds.depart-code = integer(tt-chk-gds.depart-code:screen-value in browse br-gds)
    tt-chk-gds.pl-code = integer(tt-chk-gds.pl-code:screen-value in browse br-gds)
    .
end.

ON LEAVE OF tt-chk-discnt.real-value-abs IN BROWSE br-discnt DO:
  if tt-chk-discnt.value-type <> Integer({&discnt-v-abs}) and tt-chk-discnt.value-type <> Integer({&discnt-v-bonus}) then do:
    message
    "Для % и др. скидки редактируйте % значение скидки"
    view-as alert-box error.
    display
    tt-chk-discnt.real-value-abs
    with browse br-discnt .
  end.
  else do:
    RUN proc-leave-discnt-abs IN THIS-PROCEDURE ( input integer({&discnt-v-abs})).
  end.
end.

ON LEAVE OF tt-chk-discnt.real-value-pcnt IN BROWSE br-discnt DO:
  if tt-chk-discnt.value-type = Integer({&discnt-v-abs})  or tt-chk-discnt.value-type = Integer({&discnt-v-bonus})  then do:
    message
    "Для абс скидки редактируйте асб значение скидки"
    view-as alert-box error.
    display
    tt-chk-discnt.real-value-pcnt
    with browse br-discnt .
  end.
  else do:
    RUN proc-leave-discnt-abs IN THIS-PROCEDURE ( input integer({&discnt-v-pcnt})).
  end.
end.

ON LEAVE OF tt-chk-pay.pay-card IN BROWSE br-pay DO:
DEFINE BUFFER buf_tt-chk-pay FOR tt-chk-pay.
  find first buf_tt-chk-pay where
          buf_tt-chk-pay.doc-code = tt-chk-pay.doc-code
      AND buf_tt-chk-pay.line-num = tt-chk-pay.line-num.
  assign
  buf_tt-chk-pay.pay-card = tt-chk-pay.tot-sum:screen-value in browse br-pay
  .
END.

ON LEAVE OF tt-chk-pay.tot-sum IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.tot-sum = decimal(tt-chk-pay.tot-sum:screen-value in browse br-pay    )
  locked_chk-pay.tot-sum = tt-chk-pay.tot-sum
  .
END.

ON LEAVE OF tt-chk-pay.pay-code IN BROWSE br-pay DO:
  define buffer buf_cash-pay  for ub.cash-pay.
  assign
  tt-chk-pay.pay-code= integer(tt-chk-pay.pay-code:screen-value in browse br-pay    )
  .

  display
  get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
  varcurr-name  with browse br-pay.
  run proc-chg-pay in this-procedure ( input no, input tt-chk-pay.curr-code ).
END.

ON LEAVE OF tt-chk-pay.curr-code IN BROWSE br-pay DO:
  define variable old-curr-code like ub.chk-pay.curr-code no-undo.

  assign
   old-curr-code = tt-chk-pay.curr-code
  tt-chk-pay.curr-code= integer(tt-chk-pay.curr-code:screen-value in browse br-pay    )
  .
  display
  get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
  varcurr-name  with browse br-pay.
  run proc-chg-pay in this-procedure ( input no, input old-curr-code).
END.

ON LEAVE OF tt-chk-pay.src-qnty IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.src-qnty = decimal(tt-chk-pay.src-qnty:screen-value in browse br-pay    )
  locked_chk-pay.src-qnty = tt-chk-pay.src-qnty
  .
END.

ON LEAVE OF tt-chk-pay.doc-qnty IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.doc-qnty = decimal(tt-chk-pay.doc-qnty:screen-value in browse br-pay    )
  locked_chk-pay.doc-qnty = tt-chk-pay.doc-qnty
  .
END.

ON LEAVE OF tt-chk-pay.src-val IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.src-val = integer(tt-chk-pay.src-val:screen-value in browse br-pay    )
  locked_chk-pay.src-val = tt-chk-pay.src-val
  .
END.

ON LEAVE OF tt-chk-pay.par-val IN BROWSE br-pay DO:
  find first locked_chk-pay where
          locked_chk-pay.doc-code = tt-chk-pay.doc-code
      AND locked_chk-pay.line-num = tt-chk-pay.line-num.
  assign
  tt-chk-pay.par-val = integer(tt-chk-pay.par-val:screen-value in browse br-pay    )
  locked_chk-pay.par-val = tt-chk-pay.par-val
  .
END.




ON LEAVE OF tt-chk-doc.shift-name in frame {&frame-name} DO:
define variable v-dopi as integer no-undo .
define variable v-old-shift-name as character no-undo .
  assign
  v-old-shift-name = tt-chk-doc.shift-name
  tt-chk-doc.shift-name
  .
  assign
  v-dopi = integer(tt-chk-doc.shift-name) no-error .
  if error-status:error
  or v-dopi < 0
  or v-dopi > 99 then do:
    message
    "Неверное значение № смены"
    view-as alert-box error .
    tt-chk-doc.shift-name = v-old-shift-name .
    display
    tt-chk-doc.shift-name
    with frame {&frame-name} .
    return no-apply.
  end.
  display
  v-dopi @ tt-chk-doc.shift-num
  with frame {&frame-name} .
end.


ON RETURN OF tt-chk-gds.src-qnty IN BROWSE br-gds,
            tt-chk-gds.src-price IN BROWSE br-gds,
            tt-chk-gds.src-discnt IN BROWSE br-gds,
            tt-chk-gds.src-code IN BROWSE br-gds,
            tt-chk-gds.pump IN BROWSE br-gds,
            tt-chk-gds.nozzle-code IN BROWSE br-gds,
            tt-chk-gds.pl-code IN BROWSE br-gds,
            tt-chk-gds.loc1 IN BROWSE br-gds,
            tt-chk-gds.road-tax IN BROWSE br-gds,
            tt-chk-discnt.real-value-abs IN BROWSE br-discnt,
            tt-chk-discnt.real-value-pcnt IN BROWSE br-discnt,
            tt-chk-pay.tot-sum IN BROWSE br-pay,
            tt-chk-pay.curr-code IN BROWSE br-pay,
            tt-chk-pay.pay-code IN BROWSE br-pay DO:
  APPLY "LEAVE" to self.
end.

/*найдем номер БД*/
var-mode = par-mode.
p-next-prev = '':U.
n-p: do while p-next-prev = '':U :
MAIN-BLOCK:
DO TRANSACTION ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

 if LOOKUP(par-mode, ({&update}  + {&delim-par} + {&add-def} + {&delim-par} + {&lookup} + {&delim-par} + "susp-type"), {&delim-par} ) = 0 then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode" par-mode
      view-as alert-box ERROR.
      return error.
  end.
  if p-obj-type <> {&shop} then DO:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова p-obj-type" p-obj-type
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode <> {&lookup} then do:
    p-next-prev = 'quit':U.
  end.
  if par-mode <> {&add-def} then do:
    FIND FIRST locked_chk-doc NO-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
    assign
    shop-type = locked_chk-doc.obj-type
    shop-code = locked_chk-doc.obj-code
    .
  end.
  if par-mode = "susp-type" then do:
FIND FIRST locked_chk-doc  WHERE
                recid(locked_chk-doc) = p-doc-rec.
    assign
    shop-type = locked_chk-doc.obj-type
    shop-code = locked_chk-doc.obj-code
    .
  end.
  else do:
    assign
    shop-type = p-obj-type
    shop-code = p-obj-code
    .
  end.
  { str/get-chkc.i run shop-type shop-code }
  get-chkc_context.tt-wd-bh = buffer tt-wd:handle.
  RUn get-params in this-procedure ( input shop-type, input shop-code) no-error.
  if error-status:error then return error.
  RUn fill-tables in this-procedure no-error.
  if error-status:error then return error.
  
  { gbl/hostcode.i
  tt-chk-doc.obj-type
  tt-chk-doc.obj-code
  v-host-code
  }
  
  run Myenable in this-procedure .
  /*переставить колонки*/
  br-gds:num-locked-columns = 4.
  { gbl/mv-clmn.i
  &ext-col = 33
  &frame-name = "{&frame-name}"
  &browse-name = "br-gds"
  &start-column = "1"
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33'"
  &prev-order-column-condition_1 = " par-mode = {&add-def} "
  &prev-order-column_2 = "'1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29,30,31,32,33'"
  &prev-order-column-condition_2 = " par-mode = {&lookup} and not v-is-top"
  &prev-order-column_3 = "'1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29,30,31,32,33'"
  &prev-order-column-condition_3 = " par-mode = {&update} and NOT v-is-top"
  &prev-order-column_4 = "'1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29,30,31,32,33'"
  &prev-order-column-condition_4 = " par-mode = {&lookup} and v-is-top"
  &prev-order-column_5 = "'1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29,30,31,32,33'"
  &prev-order-column-condition_5 = " par-mode = {&update} and v-is-top"
  &num-group = "4"
  &mem-gr_1 = "1,2,3,4"
  &mem-gr_2 = "5,6"
  &mem-gr_3 = "7,8,9,10,11,12,13"
  &mem-gr_4 = "14,15,16,17,18,19"
  &mv-brw-real-default = "yes"
  }
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus v-susp-chk.
END.
run mv-brw-real-defaultbr-gds in this-procedure .
end. /* do while */
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-ch-bc-ck Dialog-Frame 
PROCEDURE check-ch-bc-ck :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-price-sale like ub.gds-obj.price-sale no-undo.
define input parameter p-price-base like ub.chk-gds.price-base no-undo.
define variable glog as logical no-undo.
if par-mode <> {&update} or p-price-base = 0 /* для подарков уберем проверку */ then return.
if p-price-sale <> p-price-base  AND not ch-bc-ck then do:
    message
    "Цена товара, с которой пробит чек, НЕ РАВНА" skip
    "прейскурантной цене товара (услуги), на который производится замена." skip
    "Редактирование не допускается" skip
    "См. АРМ Администратор-Магазины-Параметры-Опции интерфейса при работе с чеками" skip
    "Настройка <Разрешена смена товара чека (при рекакт. чека) на товар с другой ценой>"
    view-as alert-box
    ERROR.
    return error .
end.
else do:
  if p-price-sale <> p-price-base then do:
      message
      "Цена товара, с которой пробит чек, НЕ РАВНА" skip
      "прейскурантной цене товара (услуги), на который производится замена." skip
      "Подтвердить смену товара  -  ДА, отказаться от изменения - НЕТ"  
      view-as alert-box
      WARNING buttons YES-NO update glog.
      if not glog then return error.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-mark d-utd 
PROCEDURE temp-mark :
  /* --------------------------------------------------------------------
                          Purpose:     ENABLE the User Interface
                          Parameters:  <none>
                          Notes:       Here we display/view/enable the widgets in the
                                       user-interface.  In addition, OPEN all queries
                                       associated with each FRAME and BROWSE.
                                       These statements here are based on the "Other
                                       Settings" section of the widget Property Sheets.
                           -------------------------------------------------------------------- */
  define input parameter p-id as integer no-undo .
  define buffer buf_marking     for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer bf_marking      for ub.marking .
  define variable v-marking as character no-undo .
  empty temp-table tt-marking-lines .

  if p-id = 1 then 
  do:
    for each buf_marking-chk no-lock where buf_marking-chk.doc-code = tt-chk-doc.doc-code and buf_marking-chk.line-num = tt-chk-gds.line-num:
      for first buf_marking no-lock where buf_marking.mark begins buf_marking-chk.mark :
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = GdsName(buf_marking.gds-code)
          tt-marking-lines.stts        = StatusTHName(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_marking.gds-code
          tt-marking-lines.sts-utd     = buf_marking.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_marking-chk.line-num
          tt-marking-lines.doc-level   = 1
          .
        if buf_marking-chk.unit <> "UNIT" then 
        do:
          for each bf_marking no-lock where bf_marking.mark-parent = buf_marking.mark:
            create tt-marking-lines .
            assign
              tt-marking-lines.gds-name    = GdsName(bf_marking.gds-code)
              tt-marking-lines.stts        = StatusTHName(bf_marking.sts)
              tt-marking-lines.mark        = bf_marking.mark
              tt-marking-lines.mark-parent = bf_marking.mark-parent
              tt-marking-lines.gds-code    = bf_marking.gds-code
              tt-marking-lines.sts-utd     = bf_marking.sts
              tt-marking-lines.unit        = bf_marking.unit
              tt-marking-lines.box-qnty    = bf_marking.box-qnty
              tt-marking-lines.LineNum     = buf_marking-chk.line-num
              tt-marking-lines.doc-level   = 2
              .
          end.  
        end.  
      end.   
    end.  
  end.
  else 
  do:
    for each buf_marking-chk no-lock where buf_marking-chk.doc-code = tt-chk-doc.doc-code:

      for first buf_marking no-lock where buf_marking.mark begins buf_marking-chk.mark :
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = GdsName(buf_marking.gds-code)
          tt-marking-lines.stts-utd    = StatusTHName(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_marking.gds-code
          tt-marking-lines.sts-utd     = buf_marking.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_marking-chk.line-num
          tt-marking-lines.doc-level   = 1
          .
        if buf_marking-chk.unit <> "UNIT" then 
        do:
          for each bf_marking no-lock where bf_marking.mark-parent = buf_marking.mark:
            create tt-marking-lines .
            assign
              tt-marking-lines.gds-name    = GdsName(bf_marking.gds-code)
              tt-marking-lines.stts-utd    = StatusTHName(bf_marking.sts)
              tt-marking-lines.mark        = bf_marking.mark
              tt-marking-lines.mark-parent = bf_marking.mark-parent
              tt-marking-lines.gds-code    = bf_marking.gds-code
              tt-marking-lines.sts-utd     = bf_marking.sts
              tt-marking-lines.unit        = bf_marking.unit
              tt-marking-lines.box-qnty    = bf_marking.box-qnty
              tt-marking-lines.LineNum     = buf_marking-chk.line-num
              tt-marking-lines.doc-level   = 2
              .
          end.  
        end.  
      end.   
    end.  
  end.  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-dublicate Dialog-Frame 
PROCEDURE check-dublicate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer dub_chk-doc for ub.chk-doc.
      FIND first dub_chk-doc where
            dub_chk-doc.obj-type = tt-chk-doc.obj-type and
            dub_chk-doc.obj-code = tt-chk-doc.obj-code and
            dub_chk-doc.chk-date = tt-chk-doc.chk-date and
            dub_chk-doc.pay-desk = tt-chk-doc.pay-desk and
            dub_chk-doc.chk-time = tt-chk-doc.chk-time and
            dub_chk-doc.chk-num = tt-chk-doc.chk-num 
/*            and                                         */
/*            dub_chk-doc.sales-man = tt-chk-doc.sales-man*/
             NO-ERROR .
if available dub_chk-doc  and
    recid(dub_chk-doc) <> recid(locked_chk-doc) then do:
    message
    "Уже есть чек" dub_chk-doc.doc-code      "по магазину" tt-chk-doc.obj-code "в котором"
    "дата" tt-chk-doc.chk-date SKIP
"время" string(tt-chk-doc.chk-time, "HH:MM:SS":U)  SKIP
"касса" tt-chk-doc.pay-desk SKIP
"номер чека на кассе" tt-chk-doc.chk-num SKIP
"продавец" tt-chk-doc.sales-man
view-as alert-box ERROR.
return error.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-manual Dialog-Frame 
PROCEDURE check-manual :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo .
define variable v-netto as decimal no-undo .
define buffer buf_tt-chk-pay for tt-chk-pay.
if ((not can-find( first locked_chk-gds where locked_chk-gds.doc-code = tt-chk-doc.doc-code))
and tt-chk-doc.chk-type <> integer({&rcpt-z-rep})
)
or (not can-find(first locked_chk-pay where locked_chk-pay.doc-code = tt-chk-doc.doc-code)
and lookup(string(tt-chk-doc.chk-type) , {&petrol-receipt-codes}) = 0
and tt-chk-doc.chk-type <> integer({&rcpt-write-off})
and tt-chk-doc.chk-type <> integer({&rcpt-annu}))
and tt-chk-doc.chk-type <> integer({&rcpt-inventory})
then do:
  message
  "В чеке нет строк товаров и/или строк оплат" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if tt-chk-doc.pay-desk = 0 then do:
  message
  "Нельзя создать чек для кассы с номером 0"
  view-as alert-box error .
  return error .
end.
if v-doc-osnov = "" then do:
  message
  "В чеке нет документа основания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.  
if corr-date = ? then do:
  message
  "В чеке нет даты основания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.  
end. 
if f-num-corr = "" then do:
  message
  "В чеке нет номера основания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.  
end. 
if f-cause-corr = "" then do:
  message
  "В чеке нет описания корректировки" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.  
end. 
for each buf_tt-chk-pay no-lock:
  assign
  v-netto = v-netto + (if get-chkc_context.r-b = {&r-b-base}
                       then buf_tt-chk-pay.tot-base
                       else buf_tt-chk-pay.tot-rubl )
  .
end.
/*Создание атрибутов для чеков, созданных в ручную*/

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-osnov" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-osnov"
           buf_chk-doc-attr.attr-value = string(v-corr-osnov1)
           .
end.
else buf_chk-doc-attr.attr-value = string(v-corr-osnov1) .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-date" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-date"
           buf_chk-doc-attr.attr-value = string(corr-date)
           .
end.
else buf_chk-doc-attr.attr-value = string(corr-date) .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-num" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-num"
           buf_chk-doc-attr.attr-value = f-num-corr
           .
end.
else buf_chk-doc-attr.attr-value = f-num-corr .
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "corr-cause" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "corr-cause"
           buf_chk-doc-attr.attr-value = f-cause-corr
           .
end.
else buf_chk-doc-attr.attr-value = f-cause-corr .
run cur-time in this-procedure(output v-date, output v-time).
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-type" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-type"
           buf_chk-doc-attr.attr-value = "manual"
           .
end.

find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-date" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-date"
           buf_chk-doc-attr.attr-value = string(v-date,"99.99.9999")
           .
end.         
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-time" no-error .  
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-time"
           buf_chk-doc-attr.attr-value = string(v-time,"HH:MM:SS")
           .
end.
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-shift-num" no-error .           
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-shift-num"
           buf_chk-doc-attr.attr-value = string(shift-num_)
           .
end.
find first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
and buf_chk-doc-attr.attr-code  = "create-shift-date" no-error .
if not available (buf_chk-doc-attr) then do:
create buf_chk-doc-attr.
        assign
           buf_chk-doc-attr.doc-code   = tt-chk-doc.doc-code
           buf_chk-doc-attr.attr-code  = "create-shift-date"
           buf_chk-doc-attr.attr-value = string(shift-date_)
           .   
end.
for first ub.cash-pay no-lock where ub.cash-pay.obj-name = "Наличные",
first ub.chk-pay no-lock where ub.chk-pay.pay-code = ub.cash-pay.pay-code and ub.chk-pay.doc-code = tt-chk-doc.doc-code :

message "Необходимо скорректировать документы РКО/ПКО"
view-as alert-box.
end.            
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-this-check Dialog-Frame 
PROCEDURE check-this-check :
define variable v-num as integer no-undo.
define variable v-line-num as integer no-undo .
define buffer loc_chk-discnt for ub.chk-discnt.
define buffer loc_chk-gds for ub.chk-gds.
define buffer loc_chk-pay for ub.chk-pay.
define buffer loc_chk-gds-pay for ub.chk-gds-pay.
define buffer buf-tt-chk-gds for ub.chk-gds.
define buffer BUF-tt-CHK-DISCNT for tt-CHK-DISCNT.
/*проверка на наличие номера чека*/
if tt-chk-doc.chk-num < 0 or tt-chk-doc.chk-num = ? then do:
  message "Заполните номер чека по кассе"
  view-as alert-box.
  return error .
end.
assign
prev-code = tt-chk-doc.doc-code.
if par-mode = {&add-def} then do:
    run proc-save-doc in this-procedure no-error.
    if error-status:error then return error.
    run check-dublicate in this-procedure no-error.
    if error-status:error then return error.
    run check-manual in this-procedure no-error .
    if error-status:error then return error.
end.
if par-mode = {&update} and v-global-err then do:
  {&fatal-errs}
  return error.
end.
if par-mode = {&update} then do: 
    run check-dublicate in this-procedure no-error.
    if error-status:error then return error.
    run check-manual in this-procedure no-error .
    if error-status:error then return error.    
 end.

run proc-save-doc in this-procedure no-error.
if error-status:error then return error.
assign
locked_chk-doc.netto = 0
locked_chk-doc.tot-doc = 0
locked_chk-doc.src-tot-doc = 0 
locked_chk-doc.discnt = 0
locked_chk-doc.sub-discnt = 0
locked_chk-doc.correct = yes
locked_chk-doc.doc-qnty = 0
for-chk-type = "":U
.
for each loc_chk-discnt where
          loc_chk-discnt.doc-code = tt-chk-doc.doc-code:
   if loc_chk-discnt.record-type = 0 and loc_chk-discnt.line-num <> 0 then NEXT.
   if loc_chk-discnt.record-type = 4  then NEXT.
   delete loc_chk-discnt.
end.
for each loc_chk-gds-pay where loc_chk-gds-pay.doc-code = tt-chk-doc.doc-code:
  delete loc_chk-gds-pay.
end.

for each tt-wd:
  delete tt-wd.
end.
/*перезаполнить некоторые (реляционные) поля chk-gds chk-discnt chk-pay*/

for each loc_chk-gds where
         loc_chk-gds.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-gds.chk-date = tt-chk-doc.chk-date
    loc_chk-gds.line-sign = (if tt-chk-doc.chk-type = integer({&rcpt-sale})
                             then (loc_chk-gds.src-qnty >= 0)
                             else (loc_chk-gds.src-qnty <= 0)
                          )
    loc_chk-gds.line-type = "":U
    loc_chk-gds.time-oper = (if par-mode = {&add-def}
                                          then tt-chk-doc.chk-time
                                          else loc_chk-gds.time-oper)
     .
End.

for each loc_chk-pay where
            loc_chk-pay.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-pay.chk-date = tt-chk-doc.chk-date
    loc_chk-pay.obj-code =   tt-chk-doc.obj-code
    loc_chk-pay.line-sign = (if tt-chk-doc.chk-type = integer({&rcpt-sale})
                                  then (loc_chk-pay.tot-sum >= 0)
                                  else (loc_chk-pay.tot-sum <= 0)
                                  )
     loc_chk-pay.time-oper = (if par-mode = {&add-def}
                                          then tt-chk-doc.chk-time
                                          else loc_chk-pay.time-oper)
    .
End.

assign
sub-d = 0
.
for each loc_chk-discnt where
         loc_chk-discnt.doc-code = tt-chk-doc.doc-code
by loc_chk-discnt.doc-code
by loc_chk-discnt.line-num
by loc_chk-discnt.discnt-id
         :
    netto-for-sub-d = 0.
    for each buf-tt-chk-gds no-lock where
              buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
              Abs(buf-tt-chk-gds.line-num) < ABS(loc_chk-discnt.line-num) :
      assign
      netto-for-sub-d = netto-for-sub-d + buf-tt-chk-gds.src-qnty * (buf-tt-chk-gds.src-price - buf-tt-chk-gds.src-discnt)
      .
    end.
    if (loc_chk-discnt.line-type = integer({&discnt-sub-total}) OR
       loc_chk-discnt.line-type = integer({&discnt-Total}))
    and loc_chk-discnt.record-type < 4
    then do:
      assign
      sub-d = sub-d + (if loc_chk-discnt.value-type <> integer({&discnt-v-pcnt})
                       then loc_chk-discnt.discnt-value-abs
                       else 0)
      .
      for each buf-tt-chk-gds no-lock where
               buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
               Abs(buf-tt-chk-gds.line-num) = ABS(loc_chk-discnt.line-num) :
        assign
        netto-for-sub-d = netto-for-sub-d + buf-tt-chk-gds.src-qnty * (buf-tt-chk-gds.src-price - buf-tt-chk-gds.src-discnt)

       .
      end.
      FOR EACH BUF-tt-chk-discnt no-lock where
               buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
               abs(buf-tt-chk-discnt.line-num) <= abs(loc_chk-discnt.line-num):
        if buf-tt-chk-discnt.record-type >= 4 then next.
        if buf-tt-chk-discnt.discnt-id = loc_chk-discnt.discnt-id then next.
        if buf-tt-chk-discnt.line-type = integer({&discnt-gds-without-discnt}) then do:
          assign
          netto-for-sub-d = netto-for-sub-d + buf-tt-chk-discnt.object-sum
          .
        end.
        if buf-tt-chk-discnt.line-type = integer({&discnt-sub-total}) OR
          buf-tt-chk-discnt.line-type = integer({&discnt-Total}) then do:
          assign
          netto-for-sub-d = netto-for-sub-d - buf-tt-chk-discnt.discnt-value-abs
          .
        end.
      end. /*      FOR EACH BUF-tt-chk-discnt no-lock where*/
      find first buf-tt-chk-gds no-lock where
                  buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                  buf-tt-chk-gds.line-num = loc_chk-discnt.line-num no-error.

    end.
    else do:
      if v-line-num <> loc_chk-discnt.line-num then do:
        for each buf-tt-chk-gds no-lock where
                  buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                  Abs(buf-tt-chk-gds.line-num) = ABS(loc_chk-discnt.line-num) :
          assign
          netto-for-sub-d = netto-for-sub-d + buf-tt-chk-gds.src-qnty * buf-tt-chk-gds.src-price
          .
        end.
        v-line-num = loc_chk-discnt.line-num.
      end.

      find first buf-tt-chk-gds no-lock where
                  buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                  buf-tt-chk-gds.line-num = loc_chk-discnt.line-num no-error.
      if loc_chk-discnt.line-type = integer({&discnt-gds-without-discnt}) then do:
        create tt-wd.
        assign
        tt-wd.line-num = buf-tt-chk-gds.line-num
        tt-wd.doc-code = buf-tt-chk-gds.doc-code
        tt-wd.record-type = 0
        tt-wd.line-type = integer({&discnt-gds-without-discnt})
        tt-wd.discnt-id = 0
        tt-wd.wd-sum   = - loc_chk-discnt.object-sum
        .
      end.
    end.
    assign
    loc_chk-discnt.chk-date = tt-chk-doc.chk-date
    loc_chk-discnt.pay-desk = tt-chk-doc.pay-desk
    loc_chk-discnt.obj-code =   tt-chk-doc.obj-code
    loc_chk-discnt.obj-type =   tt-chk-doc.obj-type
    loc_chk-discnt.line-sign = if loc_chk-discnt.line-type = integer({&discnt-gds-without-discnt})
                               then no
                               else
                              (if tt-chk-doc.chk-type = integer({&rcpt-sale})
                                                    then (loc_chk-discnt.discnt-value-abs >= 0)
                                                    else (loc_chk-discnt.discnt-value-abs <= 0)
                                                    )
    loc_chk-discnt.time-oper = (if par-mode = {&add-def}
                                then tt-chk-doc.chk-time
                                else loc_chk-discnt.time-oper)
    loc_chk-discnt.object-qnty = if (  loc_chk-discnt.line-type = integer({&discnt-sub-total})
                                    OR loc_chk-discnt.line-type = INTEGER({&discnt-total})
                                    )
                                then loc_chk-discnt.object-qnty
                                else buf-tt-chk-gds.src-qnty
    loc_chk-discnt.object-sum = if (   loc_chk-discnt.line-type = integer({&discnt-sub-total})
                                    OR loc_chk-discnt.line-type = INTEGER({&discnt-total})
                                    )
                                then netto-for-sub-d
                                else (
                                      if loc_chk-discnt.line-type = integer({&discnt-gds-without-discnt})
                                      then loc_chk-discnt.object-sum
                                      else (buf-tt-chk-gds.src-qnty * (buf-tt-chk-gds.src-price - buf-tt-chk-gds.src-discnt) + loc_chk-discnt.discnt-value-abs)
                                     )
    loc_chk-discnt.discnt-value-pcnt = (if par-mode = {&add-def}
                                       and loc_chk-discnt.discnt-value-abs <> 0
                                       and loc_chk-discnt.discnt-value-pcnt = 0
                                       then (100 * loc_chk-discnt.discnt-value-abs / buf-tt-chk-gds.src-price / buf-tt-chk-gds.src-qnty)
                                       else loc_chk-discnt.discnt-value-pcnt )
    loc_chk-discnt.discnt-value-pcnt = if loc_chk-discnt.record-type >= 4
                                       then loc_chk-discnt.discnt-value-pcnt
                                       else (if loc_chk-discnt.object-sum <> 0
                                            then (if loc_chk-discnt.value-type = integer({&discnt-v-abs})
                                                  then loc_chk-discnt.discnt-value-abs / loc_chk-discnt.object-sum * 100
                                                  else loc_chk-discnt.discnt-value-pcnt)
                                        else 0)
    loc_chk-discnt.discnt-value-abs = if loc_chk-discnt.record-type >= 4
                                       then loc_chk-discnt.discnt-value-abs
                                       else (if loc_chk-discnt.object-sum <> 0
                                              then (if loc_chk-discnt.value-type = integer({&discnt-v-abs})
                                                    then loc_chk-discnt.discnt-value-abs
                                                    else loc_chk-discnt.discnt-value-pcnt * loc_chk-discnt.object-sum / 100)
                                              else 0)
    netto-for-sub-d = netto-for-sub-d - (if loc_chk-discnt.record-type >= 4
                                         then 0
                                         else loc_chk-discnt.discnt-value-abs)
    netto-for-sub-d = netto-for-sub-d - (if loc_chk-discnt.record-type >= 4
                                         then 0
                                         else (if loc_chk-discnt.line-type = integer({&discnt-gds-without-discnt})
                                         then loc_chk-discnt.object-sum
                                         else 0
                                         )
                                        )
    .
    if loc_chk-discnt.value-type = integer({&discnt-v-pcnt})
    and loc_chk-discnt.line-type = integer({&discnt-sub-total})
    then do:
      sub-d = sub-d + loc_chk-discnt.discnt-value-abs.
    end.
    if loc_chk-discnt.record-type < 4 then do:
    find last tt-chk-discnt where
              tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
              tt-chk-discnt.record-type = 0 no-error.
    assign
    var-discnt-id = if avail tt-chk-discnt
                    then tt-chk-discnt.discnt-id
                    else 0
    .
    end.
End.
     get-chkc_context.ll = lll.
    { str/libchkvl_getcheck.i
      "buffer get-chkc_context:handle"
      ~{&update~}
      par-mode
      yes
      yes
      ?
      lng-sub-d
      sub-d
      var-discnt-id
      prev-code
      no-error
     }
     assign
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .

if error-status:error then do:
run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame {&frame-name}.
 return error.
end.
if locked_chk-doc.correct <> yes
then do:
  if par-mode = {&add-def} then do:
        run gbl/d-askw.w
          (input "Выход из режима создания чека" /* Заголовок окна */
          ,input "Созданный Вами чек является ошибочным" + {&new-line} /* Общее сообщение */
            + "Вы действительно хотите сделать это?" + {&new-line}
          ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                      /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                      /* второй символ - разделитель атрибутов в описании кнопок */
          ,input "Сохранить|Редактировать|Не сохранять" /* список названий кнопок  */
                                          /* каждая кнопка может иметь необязательный */
                                          /* список атрибутов, влияющих на поведение кнопки */
          ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|" /* список описаний кнопок */
               + "Продолжить редактирование и постараться исправить все ошибки в чеке|"
               + "Чек не будет сохранен"
          ,input 2 /* значение возвращаемое при нажатии enter */
          ,input 3 /* значение возвращаемое при нажатии escape */
          ,output v-num /* выбор пользователя */
          ).
        CASE v-num:
            when 2 then do:
                return error.
            end.
             when 3 then do:
                p-doc-rec = ?.
                delete locked_chk-doc .
                return .
             end.
        END CASE.
  end.
  else do:
    run gbl/d-askw.w
      (input "Выход из режима редактирования чека" /* Заголовок окна */
      ,input "Редактируемый Вами чек является ошибочным" + {&new-line} /* Общее сообщение */
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input "Сохр ошибочный|Редактировать" /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|" /* список описаний кнопок */
            + "Постараться исправить все ошибки в чеке"
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 2 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).
      if v-num = 2 then return error.
  end.
end.
if par-mode = {&update} then
run trg/chk-doch.p (
                buffer locked_chk-doc
              , input yes
              , input no /*p-add*/
              , input no /*p-del*/
              , input-output v-chip-num
              , output v-is-update).
if par-mode = {&add-def} then do:
  run trg/chk-doch.p (
                  buffer locked_chk-doc
                , input no
                , input yes /*p-add*/
                , input no /*p-del*/
                , input-output v-chip-num
                , output v-is-update).
end.
if v-is-update or par-mode = {&add-def} then do:
  assign
  locked_chk-doc.PS = "!":U + (if index(locked_chk-doc.ps, "shift!") > 0 then "shift!" else '':U) +
                      (if index(locked_chk-doc.ps, "shift!") > 0
                      then substring(left-trim(locked_chk-doc.ps, "!"), 6)
                      else left-trim(locked_chk-doc.PS, "!":U))
  tt-chk-doc.PS = locked_chk-doc.pS
  .
  display
  tt-chk-doc.ps
  with frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-time Dialog-Frame 
PROCEDURE check-time :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parscreen-value as integer no-undo.
define input parameter par-mode as character no-undo.
define variable var-limit as integer no-undo.
define buffer buf_tt-pay-info for tt-pay-info.
CASE par-mode:
    when "hour":U then do:
         var-limit = 23.
    end.
    when "min":U then do:
          var-limit = 59.
    end.
    when "sec" then do:
          var-limit = 59.
    end.
END.

  if int(parscreen-value) > var-limit then do:
    bell.
    Message "Неверное время!" view-as alert-box ERROR.
    return error.
  end.
  assign
  tt-chk-doc.chk-time = fhour * 3600 + fmin * 60 + fsec * 60
  .
  run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                     input tt-chk-doc.chk-time,
                                     input get-chkc_context.base-code,
                                     output cash-rate_,
                                     output cash-scale_,
                                     output exch-date_,
                                     output exch-time_
                                     ) no-error.
 if error-status:error then return error.
  for each buf_tt-pay-info:
  run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                     input tt-chk-doc.chk-time,
                                     input tt-chk-pay.curr-code,
                                     output tt-pay-info.exch-rate,
                                     output tt-pay-info.exch-scale,
                                     output tt-pay-info.exch-date,
                                     output tt-pay-info.exch-time
                                     ) no-error.


  assign
  buf_tt-pay-info.exch-time-str = string(tt-pay-info.exch-time, "hh:mm:ss")
  .
  br-pay:refresh() in frame {&frame-name} .
 end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-z-rep Dialog-Frame 
PROCEDURE create-z-rep :
define variable varrid-list as character no-undo.
DEFine VARiable trid as recid no-undo.
define variable base-rate_   as decimal                 no-undo .
define variable base-scale_  like ub.chk-doc.cash-scale no-undo .

define buffer lnp_chk-pay for ub.chk-pay.
define buffer loc_tt-chk-pay for tt-chk-pay.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
IF CAN-FIND(FIRST ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = tt-chk-doc.doc-code) THEN DO:
&SCOPED-DEFINE receipt-code string(tt-chk-doc.chk-type)
   MESSAGE
   substitute("В чеке типа &1 не может быть строк оплат", {&receipt-name})
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
if par-mode = {&add-def} then do:
  run proc-save-doc No-ERROR.
  if error-status:error then return error.
end .
varrid-list = "" .
lnp = 0.
run find-bank-curs in this-procedure(
                                                          input tt-chk-doc.chk-date
                                                          ,input 0 /*currc-code*/
                                                          ,output bank-rate_
                                                          ,output bank-scale_
                                                          ) no-error.
run find-curs in this-procedure(
                                                          input tt-chk-doc.chk-date
                                                          ,input tt-chk-doc.chk-time
                                                          ,input 0 /*curr-code*/
                                                          ,output cash-rate_
                                                          ,output cash-scale_
                                                          ,output exch-date_
                                                          ,output exch-time_
                                                          ) no-error.
if get-chkc_context.r-b = {&r-b-base} and
get-chkc_context.base-code <> 0 then do:
  run find-curs in this-procedure(
                                                            input tt-chk-doc.chk-date
                                                            ,input tt-chk-doc.chk-time
                                                            ,input get-chkc_context.base-code
                                                            ,output base-rate_
                                                            ,output base-scale_
                                                            ,output exch-date_
                                                            ,output exch-time_
                                                            ) no-error.
end.
else do:
  assign
  base-rate_ = 1
  base-scale_ = 1
  .
end.
create tt-chk-pay.
assign
lnp = lnp + 1
tt-chk-pay.doc-code = tt-chk-doc.doc-code
tt-chk-pay.line-num = lnp
tt-chk-pay.chk-date = tt-chk-doc.chk-date
tt-chk-pay.pay-code = 0
tt-chk-pay.curr-code = 0 /*нац вал*/
tt-chk-pay.obj-code = tt-chk-doc.obj-code
tt-chk-pay.obj-type = tt-chk-doc.obj-type
tt-chk-pay.bank-rate = bank-rate_
tt-chk-pay.bank-scale = bank-scale_
tt-chk-pay.cash-rate = cash-rate_ / cash-scale_ * (if get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code <> 0 then base-rate_ / base-scale_ else 1)
tt-chk-pay.tot-base = 0
tt-chk-pay.tot-sum = 0
tt-chk-pay.tot-rubl = 0
tt-chk-pay.pay-card = "":U
tt-chk-pay.is-error = no
tt-chk-pay.pass-pay = integer({&pay-manual})
.
create tt-pay-info.
buffer-copy tt-chk-pay to tt-pay-info
assign
tt-pay-info.exch-rate = cash-rate_
tt-pay-info.exch-scale = cash-scale_
tt-pay-info.exch-date = exch-date_
tt-pay-info.exch-time = exch-time_
tt-pay-info.exch-time-str = string(exch-time_, "hh:mm:ss")
tt-pay-info.calc-rate = cash-rate_ / cash-scale_
.


CREATE locked_chk-pay .
buffer-copy tt-chk-pay to locked_chk-pay.
  trid = recid(tt-chk-pay).
{&OPEN-QUERY-br-pay}
REPOSITION br-pay to recid trid NO-ERROR.
glog = BR-pay:SET-REPOSITIONED-ROW(1, "CONDITIONAL") in frame {&frame-name}.
{&OPEN-QUERY-BR-pay}
apply "entry" to br-pay in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-z-rep Dialog-Frame 
PROCEDURE delete-z-rep :
DEFINE BUFFER buf_chk-pay FOR ub.chk-pay.
    FOR EACH tt-chk-pay WHERE
        tt-chk-pay.doc-code = tt-chk-doc.doc-code
   AND tt-chk-pay.curr-code = 0
    AND tt-chk-pay.pay-code = 0,
    FIRST buf_chk-pay WHERE
         buf_chk-pay.doc-code = tt-chk-doc.doc-code
   AND buf_chk-pay.line-num = tt-chk-pay.line-num:
   DELETE tt-chk-pay.
   DELETE buf_chk-pay.

END.
{&OPEN-QUERY-BR-pay}
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY Cb-chk-type fhour fmin fsec v-corr-osnov v-corr-type text-4 text-1 
          v-susp-chk v-doc-osnov corr-date f-num-corr v-link-chk f-cause-corr 
          v-src-d-card F-cashier F-salesman f-cli-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN 
    DISPLAY tt-chk-doc.src-tot-doc tt-chk-doc.chk-date tt-chk-doc.cashier 
          tt-chk-doc.sales-man tt-chk-doc.obj-code tt-chk-doc.d-card 
          tt-chk-doc.pay-desk tt-chk-doc.doc-num tt-chk-doc.doc-num2 
          tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt 
          tt-chk-doc.src-shift-date tt-chk-doc.cash-rate tt-chk-doc.cash-scale 
          tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.PS 
          tt-chk-doc.tot-doc tt-chk-doc.discnt tt-chk-doc.sub-discnt 
          tt-chk-doc.netto tt-chk-doc.d-pcnt tt-chk-doc.shift-date 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-prev B-next Cb-chk-type b-func br-attr B-print B-hist 
         B-help tt-chk-doc.src-tot-doc RECT-1 tt-chk-doc.chk-date 
         tt-chk-doc.cashier fhour fmin fsec tt-chk-doc.sales-man 
         tt-chk-doc.obj-code tt-chk-doc.d-card B-card tt-chk-doc.pay-desk b-cd 
         v-corr-osnov tt-chk-doc.doc-num tt-chk-doc.doc-num2 v-corr-type 
         v-susp-chk v-doc-osnov corr-date f-num-corr BUTTON-1 b-choose-date 
         BUTTON-susp v-link-chk f-cause-corr tt-chk-doc.chk-num 
         tt-chk-doc.z-number tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date 
         tt-chk-doc.cash-rate tt-chk-doc.cash-scale tt-chk-doc.shift-name 
         tt-chk-doc.shift-num v-src-d-card b-addbonus B-adddiscnt B-addgds 
         Btn_sht-from BR-gds BR-discnt BR-pay tt-chk-doc.PS b-slip-chk B-addpay 
         B_mark b-cf F-cashier tt-chk-doc.tot-doc F-salesman tt-chk-doc.discnt 
         tt-chk-doc.sub-discnt f-cli-name tt-chk-doc.netto tt-chk-doc.d-pcnt 
         tt-chk-doc.shift-date 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame 
PROCEDURE fill-tables :
define variable v-cashier-code as integer no-undo .
define variable v-seller-code as integer no-undo .
define variable v-cashier-psn-code as integer no-undo .
define variable v-seller-psn-code as integer no-undo .

define variable v-updated as logical no-undo .
define buffer no_buffer_chk-doc for ub.chk-doc.
DEFINE VARIABLE var-is-error as logical no-undo .
define variable v-sum-promo as decimal no-undo.
define variable v-pcnt-promo as decimal no-undo.
for each tt-chk-doc:
    delete tt-chk-doc.
end.
for each tt-chk-gds:
    delete tt-chk-gds.
end.
for each tt-chk-pay:
    delete tt-chk-pay.
end.
for each tt-chk-discnt:
    delete tt-chk-discnt.
end.
for each tt-chk-doc-attr:
    delete tt-chk-doc-attr.
end.
for each tt-gds-info:
  delete tt-gds-info.
END.
for each tt-pay-info:
  delete tt-pay-info.
END.

/*заполним таблицу tt-chk-doc*/
IF par-mode = {&add-def} then do:

  /*получим buf_cash-desk выбором из списка!!! а то теперь у нас и autotank еще окторый может быть не dflt-cd!!!*/
  message
  "Выберите из списка кассу, для которой Вы хотите создать чек!"
  view-as alert-box.
  run sel-cd in this-procedure no-error.
  if error-status:error then do:
    undo, return error .
  end.
   run gbl/factdate.p (
                    INPUT        shop-type,
                    INPUT        shop-code,
                    INPUT-OUTPUT chk-date_,
                    INPUT-OUTPUT chk-time_,
                    INPUT-OUTPUT shift-date_,
                    INPUT-OUTPUT shift-num_,
                    INPUT-OUTPUT shift-name_,
                    INPUT        YES
                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    if shift-name_ = ? then do:
      shift-name_ = "":U.
    end.
    assign
    v-cashier-code = gbclcode-get-this-db-first-role ( input {&role-cashier}, input get-chkc_context.db-num, input chk-date_)
    no-error .
    assign
    v-seller-code = gbclcode-get-this-db-first-role ( input {&role-seller}, input get-chkc_context.db-num, input chk-date_)
    no-error .

    /*найдем курс базовой валюты кассы по отношению к национальной*/
    run find-curs in this-procedure
                        (
                         input chk-date_
                        ,input chk-time_
                        ,input get-chkc_context.base-code
                        ,output cash-rate_
                        ,output cash-scale_
                        ,output exch-date_
                        ,output exch-time_
                        )  no-error.
    if error-status:error then undo, return error .
  /* DO TRANSACTION ON ERROR UNDO, RETURN ERROR: */

      create tt-chk-doc.
      assign
      tt-chk-doc.doc-code =   (if get-chkc_context.db-num = 0
                                then string(next-value(s-chk, {&db-name_schema}))
                                else string( shop-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
      tt-chk-doc.obj-type = shop-type
      tt-chk-doc.obj-code = shop-code
      tt-chk-doc.chk-date = chk-date_
      tt-chk-doc.chk-time = chk-time_
      tt-chk-doc.shift-num  = shift-num_
      tt-chk-doc.src-shift-date = shift-date_
      tt-chk-doc.shift-name      = shift-name_
      tt-chk-doc.cashier   = v-cashier-code
      tt-chk-doc.sales-man   = (if dflt-cd = {&cd-type-magia-xml}
                               then v-seller-code + 10000
                               else v-seller-code)
      tt-chk-doc.pay-desk    = (if available buf_cash-desk then buf_cash-desk.cash-num else 0)
      tt-chk-doc.cash-rate = if get-chkc_context.r-b = {&r-b-base}
                                        then cash-rate_
                                        else 1
      tt-chk-doc.cash-scale = if get-chkc_context.r-b = {&r-b-base}
                                        then cash-scale_
                                        else 1
      tt-chk-doc.chk-type = integer({&rcpt-sale})
      tt-chk-doc.correct = yes
      tt-chk-doc.d-card = "":U
      tt-chk-doc.src-d-card = "":U
      tt-chk-doc.src-d-pcnt = 0
      tt-chk-doc.z-number = 0
      tt-chk-doc.PS = "!"
      .
      
      create locked_chk-doc.
      buffer-copy tt-chk-doc to locked_chk-doc.
      
    /*END. */
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = shop-type AND
                buf_obj.obj-code = shop-code No-ERROR.
end.
else do:
  if par-mode = {&lookup} then do:
    FIND FIRST locked_chk-doc NO-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
  end.
  ELSE do:
    /* DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR: */
      FIND FIRST locked_chk-doc EXCLUSIVE-LOCK WHERE
                 recid(locked_chk-doc) = p-doc-rec.
     /* END. */
  END.
  IF NOT AVAIL locked_chk-doc then
  return error.
  if locked_chk-doc.out-code <> ? and par-mode <> {&lookup} and par-mode <> "susp-type" then do:
     message
     "Чек" locked_chk-doc.doc-code  "включен в продажу" locked_chk-doc.out-code SKIP
     "Изменения не допускаются"
     view-as alert-box error.
     return error.
  end.
  IF LOOKUP({&amount}, locked_chk-doc.office) > 0
  and par-mode <> {&lookup} and par-mode <> "susp-type" then do:
    message
    "Чек" locked_chk-doc.doc-code  "является чеком с продаже по группе" SKIP
    "Изменения не допускаются"
    view-as alert-box error .
    return error.
  end.
  if lookup({&summa-err}, locked_chk-doc.office ) > 0
  and par-mode = {&update} then do:
    assign
    v-global-err = yes
    .
    {&fatal-errs}
  end.
  if locked_chk-doc.out-2-code <> ?
  and par-mode = {&update}
  then do:
     message
     substitute("Чек &1 привязан к док-ту &2 - изменение невозможно"
                          , locked_chk-doc.doc-code
                          , locked_chk-doc.out-2-code)
     view-as alert-box error .
     undo, return error.
  end.
  /*обработка старых line-num*/
  if par-mode = {&lookup} or par-mode = "susp-type" then do:
    run str/chklinfx.p (
                    buffer no_buffer_chk-doc
                   ,input locked_chk-doc.doc-code
                   ,input yes /*p-with-question*/
                   ,output v-updated
                    ) no-error .

  end.
  if par-mode = {&update} then do:
    run str/chklinfx.p (
                    buffer locked_chk-doc
                   ,input locked_chk-doc.doc-code
                   ,input yes /*p-with-question*/
                   ,output v-updated
                    ) no-error .
    if error-status:error then undo, return error .
  end.
  if error-status:error then do:
    message
    "Ошибка при попытке заполнения номеров строк чека" skip
    return-value
    view-as alert-box error .
    undo, return error .
  end.
  if not v-updated then undo, return error .
  
  create tt-chk-doc.
  buffer-copy locked_chk-doc to tt-chk-doc.
  
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-chk-doc.obj-type AND
                buf_obj.obj-code = tt-chk-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Чек" locked_chk-doc.doc-code  skip
              "Неверный объект" locked_chk-doc.obj-type locked_chk-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    if tt-chk-doc.cashier-psn-code <> ? then do:
      FIND FIRST cashier No-LOCK WHERe
                cashier.psn-code = tt-chk-doc.cashier-psn-code No-ERROR.
    end.
    if tt-chk-doc.salesman-psn-code <> ? then do:
      FIND FIRST sales-man No-LOCK WHERe
                sales-man.psn-code = tt-chk-doc.salesman-psn-code No-ERROR.
    end.
    FIND FIRST buf_cash-desk No-LOCK WHERE
               buf_cash-desk.obj-code = shop-code AND
               buf_cash-desk.cash-num = tt-chk-doc.pay-desk NO-ERROR.
    IF tt-chk-doc.chk-type = ? then do:
      assign
      cb-chk-type = if tt-chk-doc.netto >= 0 then {&rcpt-sale} else {&Rcpt-return}
      .
    end.
    else do:
      cb-chk-type = string(tt-chk-doc.chk-type).
    end.
  for each locked_chk-gds where
           locked_chk-gds.doc-code = tt-chk-doc.doc-code no-lock:
        create tt-chk-gds.
        buffer-copy locked_chk-gds to tt-chk-gds.
        create tt-gds-info.
        buffer-copy locked_chk-gds to tt-gds-info
        assign
        tt-gds-info.artic = get-good(input tt-chk-gds.b-code
                                     ,OUTPUT tt-gds-info.gds-code
                                     ,output tt-gds-info.gds-name
                                     ,output tt-gds-info.prt-name
                                     ,output var-is-error)
        tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
        tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
        tt-gds-info.src-sum-netto = GetRoundSum(tt-chk-gds.doc-code, tt-chk-gds.line-num, tt-chk-gds.src-qnty,(tt-chk-gds.src-price - tt-chk-gds.src-discnt)) 
        tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
        tt-gds-info.src-price-netto = tt-chk-gds.src-price - tt-chk-gds.src-discnt
        tt-gds-info.sum-netto = GetRoundSum(tt-chk-gds.doc-code, tt-chk-gds.line-num, tt-chk-gds.doc-qnty,(tt-chk-gds.price-base - tt-chk-gds.discnt))
        tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
        tt-gds-info.price-netto = tt-chk-gds.price-base - tt-chk-gds.discnt
        .
        tt-gds-info.salesman-name = get-salesman(input tt-chk-gds.sales-man, input tt-chk-doc.chk-date, output tt-chk-gds.salesman-psn-code).
        assign
        v-is-top = locked_chk-gds.pump > 0
        tt-chk-gds.is-error = (if var-is-error then yes else tt-chk-gds.is-error)
        .
    end.
    for each locked_chk-pay no-lock where
             locked_chk-pay.doc-code = tt-chk-doc.doc-code :
        create tt-chk-pay.
        buffer-copy locked_chk-pay to tt-chk-pay
        .
        assign tt-chk-pay.pay-card = (if par-mode = {&add-def}
                                      then tt-chk-pay.pay-card
                                      else f-paycardv(tt-chk-pay.pay-card, tt-chk-pay.pay-code, tt-chk-pay.curr-code))
        .
        create tt-pay-info.
        buffer-copy locked_chk-pay to tt-pay-info
        assign
        tt-pay-info.calc-rate = tt-chk-pay.tot-rubl / tt-chk-pay.tot-sum
        .
        run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                          input tt-chk-doc.chk-time,
                                          input tt-chk-pay.curr-code,
                                          output tt-pay-info.exch-rate,
                                          output tt-pay-info.exch-scale,
                                          output tt-pay-info.exch-date,
                                          output tt-pay-info.exch-time
                                          ) no-error.
      assign
      tt-pay-info.exch-time-str = string(tt-pay-info.exch-time, "hh:mm:ss").
    end.
  for each locked_chk-doc-attr no-lock where
           locked_chk-doc-attr.doc-code = tt-chk-doc.doc-code:
        create tt-chk-doc-attr.
        buffer-copy locked_chk-doc-attr to tt-chk-doc-attr.

    end.
  for each locked_chk-discnt no-lock where
           locked_chk-discnt.doc-code = tt-chk-doc.doc-code AND
           locked_chk-discnt.record-type = 0:
    /*отсечем % скидку для IBM и т.д.*/
        if locked_chk-discnt.line-num = 0
         AND locked_chk-discnt.line-type = integer({&discnt-receipt}) then NEXT.
        /*
        if not dflt-cd = "ncr-gm" and locked_chk-discnt.line-type = integer({&discnt-gds})  then next.
        */
        create tt-chk-discnt.
        buffer-copy locked_chk-discnt to tt-chk-discnt.
        
        v-sum-promo = ChkPromoSum(locked_chk-discnt.doc-code, locked_chk-discnt.line-num).
        if v-sum-promo <> 0 
           and v-sum-promo <> ?
        then do:
           v-pcnt-promo = 100 * ( 1 - (locked_chk-discnt.object-sum / (locked_chk-discnt.object-sum + v-sum-promo))).
           assign
              tt-chk-discnt.real-value-abs = v-sum-promo
              tt-chk-discnt.real-value-pcnt = v-pcnt-promo 
              .
        end.   
        else assign
               tt-chk-discnt.real-value-abs = tt-chk-discnt.discnt-value-abs
               tt-chk-discnt.real-value-pcnt = tt-chk-discnt.discnt-value-pcnt
               . 
  end.

end.
 for each locked_chk-discnt no-lock where
                       locked_chk-discnt.doc-code = tt-chk-doc.doc-code AND
                       locked_chk-discnt.record-type = 4:
    create tt-chk-discnt.
    buffer-copy locked_chk-discnt to tt-chk-discnt.
    assign
       tt-chk-discnt.real-value-abs = tt-chk-discnt.discnt-value-abs
       tt-chk-discnt.real-value-pcnt = tt-chk-discnt.discnt-value-pcnt
       .
  end.
if not par-mode = {&lookup} and par-mode <> "susp-type" then do:
  if par-mode = {&add-def}
  and (not get-chkc_context.shift-on
  and cas-shft) then do:
    assign
    tt-chk-doc.src-shift-date = tt-chk-doc.chk-date
    tt-chk-doc.shift-date = tt-chk-doc.chk-date
    .
  end.
end.
if tt-chk-doc.cashier > 0 then do:
  if tt-chk-doc.cashier-psn-code = 0
  or tt-chk-doc.cashier-psn-code = ? then
  assign
  v-cashier-psn-code =  gbclcode-is-this-db-role (
                                                  input {&role-cashier}
                                                 ,input get-chkc_context.db-num
                                                 ,input tt-chk-doc.cashier
                                                 ,input tt-chk-doc.chk-date
                                                   )
  no-error .
  else v-cashier-psn-code = tt-chk-doc.cashier-psn-code.
  if v-cashier-psn-code > 0 then do:
    find first buf_cashier no-lock where
                buf_cashier.obj-type = {&prs}
            AND buf_cashier.obj-code = v-cashier-psn-code no-error.
  end.
  else do:
      release buf_cashier.
  end.
end.
else do:
  release buf_cashier.
end.
if tt-chk-doc.sales-man > 0 then do:
  if tt-chk-doc.salesman-psn-code = 0
  or tt-chk-doc.salesman-psn-code = ? then
  assign
  v-seller-psn-code =  gbclcode-is-this-db-role ( input {&role-seller}
                                                   ,input get-chkc_context.db-num
                                                   ,input tt-chk-doc.sales-man
                                                   ,input tt-chk-doc.chk-date
                                                   )
  no-error .
  else v-seller-psn-code = tt-chk-doc.salesman-psn-code.
  if v-seller-psn-code > 0 then do:
    find first buf_sales-man no-lock where
                buf_sales-man.obj-type = {&prs}
            AND buf_sales-man.obj-code = v-seller-psn-code no-error.
  end.
  else do:
    release buf_sales-man.
  end.
end.
else do:
  release buf_sales-man.
end.
if tt-chk-doc.d-card <> "":U then do:
      FIND FIRST buf_dis-card No-LOCK WHERe
                buf_dis-card.d-card = tt-chk-doc.d-card No-ERROR.
end.
else do:
  release buf_dis-card.
end.
if available buf_dis-card then do:
     find first buf_clients no-lock where
                buf_clients.obj-type = buf_dis-card.cli-type
           AND buf_clients.obj-code = buf_dis-card.cli-code no-error.
end.
else do:
release buf_clients.
end.
assign
F-cashier  = if available buf_cashier
                    then  buf_cashier.obj-name
                    else {&question-mark}
F-salesman = if available buf_sales-man
                    then buf_sales-man.obj-name
                    else {&question-mark}
f-cli-name  = if available buf_clients
                    then buf_clients.obj-name
                    else (if tt-chk-doc.d-card = "":U
                            then "":U
                            else {&question-mark}
                            )
fhour  = integer(substring(string(tt-chk-doc.chk-time, "hh:mm:ss":U), 1, 2))
fmin  = integer(substring(string(tt-chk-doc.chk-time, "hh:mm:ss":U), 4, 2))
fsec = integer(substring(string(tt-chk-doc.chk-time, "hh:mm:ss":U), 7, 2))
.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-bank-curs Dialog-Frame 
PROCEDURE find-bank-curs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-date as date no-undo.
DEFINE INPUT PARAMETER par-curr-code like ub.currency.curr-code no-undo.
DEFINE output PARAMETER par-rate as decimal no-undo.
DEFINE output PARAMETER par-scale as decimal no-undo.

    IF par-curr-code <> 0 then do:
        FIND LAST ub.curr-bank NO-LOCK Where
                    ub.curr-bank.curr-code = par-curr-code AND
                   ub.curr-bank.exch-date < par-date NO-ERROR .
        IF NOT AVAIL ub.curr-bank then do:
            assign
             par-rate = ?
             par-scale = ?
             .
        end.
        else do:
            assign
            par-rate = ub.curr-bank.exch-rate
            par-scale =  ub.curr-bank.exch-scale
            .
        end.
    END.
    else
    assign
    par-rate = 1
    par-scale = 1
    .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-curs Dialog-Frame 
PROCEDURE find-curs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-date as date no-undo.
DEFINE INPUT PARAMETER par-time as integer no-undo.
DEFINE INPUT PARAMETER par-curr-code like ub.currency.curr-code no-undo.
DEFINE output PARAMETER par-rate as decimal no-undo.
DEFINE output PARAMETER par-scale as decimal no-undo.
define output parameter par-exch-date as date no-undo .
define output parameter par-exch-time as integer no-undo .

    IF par-curr-code <> 0 then do:
        FIND LAST ub.curr-shop NO-LOCK Where
                             ub.curr-shop.obj-type = shop-type AND
                    ub.curr-shop.obj-code  = shop-code AND
                    ub.curr-shop.curr-code = par-curr-code AND
                   ( ( ub.curr-shop.exch-date = par-date AND
                   ub.curr-shop.exch-time <= par-time ) OR
                   ub.curr-shop.exch-date < par-date ) NO-ERROR .
        IF NOT AVAIL ub.curr-shop then do:
            message
            "Нет магазинного курса валюты на дату и время чека!" skip
            "код валюты" par-curr-code
             "дата" string(par-date, "99/99/9999")
            "время" string(par-time, "hh:mm") view-as alert-box ERROR.
           return error.
        end.
        assign
        par-rate = curr-shop.exch-rate
        par-scale =  curr-shop.exch-scale
        par-exch-date = curr-shop.exch-date
        par-exch-time = curr-shop.exch-time
        .
    END.
    else
    assign
    par-rate = 1
    par-scale = 1
    par-exch-date = 04/01/1990
    .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-uchet-date Dialog-Frame 
PROCEDURE find-uchet-date :
assign
tt-chk-doc.src-shift-date = if (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
                            then tt-chk-doc.src-shift-date
                                                        else tt-chk-doc.chk-date
tt-chk-doc.shift-date = if t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
                      then (tt-chk-doc.chk-date - 1)
                      else tt-chk-doc.src-shift-date
.
display
tt-chk-doc.shift-date
with frame {&frame-name}.
run find-curs in this-procedure ( input tt-chk-doc.chk-date,
                                     input tt-chk-doc.chk-time,
                                     input get-chkc_context.base-code,
                                     output cash-rate_,
                                     output cash-scale_,
                                     output exch-date_,
                                     output exch-time_
                                     ) no-error.
 if error-status:error then return error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-b-code Dialog-Frame 
PROCEDURE get-b-code :
define input parameter p-discnt-v-type as integer no-undo .
define input parameter p-discnt-type as integer no-undo .
DEFINE VARIABLE var-discnt-id like ub.chk-discnt.discnt-id no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE var-is-error as logical no-undo .

define buffer loc_bar-code for ub.bar-code.
define buffer loc_chk-discnt for ub.chk-discnt.
define buffer loc-tt-chk-discnt for tt-chk-discnt.
define buffer last_chk-discnt for tt-chk-discnt.
define buffer buf_goods for ub.goods.

assign
tt-chk-gds.is-error = ?
tt-chk-gds.src-sum = tt-chk-gds.src-qnty * tt-chk-gds.src-price
.
assign
bc-buf = if par-mode = {&update}
         then string(tt-chk-gds.b-code)
         else tt-chk-gds.src-code
price-from-check = tt-chk-gds.src-price
.
{ str/bc-rcnz.i
  parparentproc
  bc-buf
  price-from-check
  tt-chk-doc.obj-type
  tt-chk-doc.obj-code
  yes
  "(par-mode = {&update} or (string(tt-chk-gds.b-code) = entry(1, tt-chk-gds.src-code, ~{&delim-par~})))"
  get-chkc_context.sclspref
  get-chkc_context.scpgpref
  varresult
  vartype-bc
  varweight
  ub.bar-code
  ub.prod-bc
  ub.place
  no-error
}
if available bar-code then do:
  if par-mode = {&update} then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = bar-code.gds-code.
    if bar-code.unit-cli <> buf_goods.unit-base then do:
      message
      "Можно ввести только бар-код для ОСНОВНОЙ единицы измерения"
      view-as alert-box ERROR.
      release bar-code.
      release prod-bc.
      release place.
      assign
      tt-chk-gds.b-code = ?
      tt-gds-info.gds-name = "Неопознанный товар"
      tt-gds-info.artic = "":U
      tt-gds-info.prt-name = "-":U
      tt-chk-gds.is-error = yes
      .
      return error .
    end.
    run get-price1 in this-procedure ( input buf_goods.gds-code, input bar-code.node-code) No-ERROR.
    RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
    if error-status:error then undo, return error.
  end.
  else do:
     assign
     tt-chk-gds.b-code  = bar-code.b-code
     tt-chk-gds.is-error = no
    .
  end.
end.
else assign
tt-chk-gds.b-code = ?
tt-gds-info.gds-name = "Неопознанный товар"
tt-gds-info.artic = "":U
tt-gds-info.prt-name = "-":U
tt-chk-gds.is-error = yes
.
assign
units-rate = 1
units-dpcnt = 0
price-from-check = tt-chk-gds.src-price
.

if tt-chk-gds.b-code <> ? then do:
find first loc_bar-code no-lock where
            loc_bar-code.b-code = tt-chk-gds.b-code no-error.
    if available loc_bar-code then do:
    assign
    units-rate = (if par-mode = {&add-def} then loc_bar-code.cli-base-rate else tt-chk-gds.doc-qnty / tt-chk-gds.src-qnty)
    .
    { gbl/gdsbcode.i loc_bar-code.gds-code loc_bar-code.node-code r-bar-code no-error}
    if error-status:error then do:
      assign
      b-c = ?
      .
    end.
    else do:
      if loc_bar-code.in-code = "":U
      and loc_bar-code.part-code = "":U then do:
        assign
        b-c = r-bar-code
        .
      end.
      else do:
        { gbl/gdspcode.i loc_bar-code.gds-code loc_bar-code.node-code loc_bar-code.in-code loc_bar-code.part-code r-bar-code }
          assign
          b-c = (if error-status:error
                then ?
                else r-bar-code)
          .
     end.
     if b-c = ? then do:
       assign
       tt-chk-gds.is-error = yes
       .
     end.
     else do:
      assign
      b-c = r-bar-code
      tt-gds-info.artic = get-good(input tt-chk-gds.b-code
                                 ,output tt-gds-info.gds-code
                                 ,output tt-gds-info.gds-name
                                 ,output tt-gds-info.prt-name
                                 ,output var-is-error)
      tt-chk-gds.is-error = (if var-is-error then yes else tt-chk-gds.is-error)
      .
    end.
    end.
  end.
end.
else do:
    assign
    b-c = ?
    tt-gds-info.gds-name = "Неопознанный товар"
    tt-gds-info.artic = "":U
    tt-gds-info.prt-name = "-":U
    tt-chk-gds.is-error = yes
    .
end.
if par-mode = {&add-def} then do:
  if tt-chk-gds.src-discnt <> 0 then do:
    if dflt-cd <> {&cd-type-ncr-gm}
    and dflt-cd <> {&cd-type-ncr-as-r}
    then do:
      find first loc-tt-chk-discnt where
                loc-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
            AND  loc-tt-chk-discnt.record-type = 0
            AND loc-tt-chk-discnt.line-num = tt-chk-gds.line-num
            AND loc-tt-chk-discnt.object-line-num = tt-chk-gds.line-num no-error.
      if not avail loc-tt-chk-discnt then do:
        find last LAST_chk-discnt where
                  LAST_chk-discnt.doc-code = tt-chk-doc.doc-code and
                  last_chk-discnt.record-type = 0 no-error.
        assign
        var-discnt-id = if avail LAST_chk-discnt
                        then LAST_chk-discnt.discnt-id
                        else 0
        .
        create loc-tt-chk-discnt.
        assign
        loc-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
        loc-tt-chk-discnt.record-type = 0
        loc-tt-chk-discnt.line-num = tt-chk-gds.line-num
        loc-tt-chk-discnt.object-line-num = tt-chk-gds.line-num
        loc-tt-chk-discnt.discnt-id = VAR-DISCNT-ID + 1
        loc-tt-chk-discnt.pass-discnt = integer({&discnt-p-manual})
        loc-tt-chk-discnt.value-type = p-discnt-v-type
        loc-tt-chk-discnt.discnt-type = p-discnt-type
        loc-tt-chk-discnt.line-type = integer({&discnt-gds})
        .
        create loc_chk-discnt.
        buffer-copy loc-tt-chk-discnt to loc_chk-discnt
        .
      end.
      else do:
        find first loc_chk-discnt where
                  loc_chk-discnt.doc-code = tt-chk-doc.doc-code
              AND loc_chk-discnt.record-type = 0
              AND loc_chk-discnt.line-num = tt-chk-gds.line-num
              AND loc_chk-discnt.object-line-num = tt-chk-gds.line-num no-error.
      end.
      assign
      loc-tt-chk-discnt.discnt-value-abs = (if tt-chk-gds.src-discnt * tt-chk-gds.src-qnty = ?
                                            then 0
                                            else tt-chk-gds.src-discnt * tt-chk-gds.src-qnty)
      loc_chk-discnt.discnt-value-abs = (if tt-chk-gds.src-discnt * tt-chk-gds.src-qnty = ?
                                        then 0
                                        else tt-chk-gds.src-discnt * tt-chk-gds.src-qnty)
      .
    end.
  end.
  else if tt-chk-gds.src-discnt = 0 then do:
    for each loc_chk-discnt where
                  loc_chk-discnt.doc-code = tt-chk-doc.doc-code
              AND loc_chk-discnt.record-type = 0
              AND loc_chk-discnt.line-num = tt-chk-gds.line-num
              AND loc_chk-discnt.object-line-num = tt-chk-gds.line-num :

        if loc_chk-discnt.line-type = integer({&discnt-gds}) then do:
          find first loc-tt-chk-discnt where
                    loc-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
                AND loc-tt-chk-discnt.record-type = loc_chk-discnt.record-type
                AND loc-tt-chk-discnt.line-num = loc_chk-discnt.line-num
                AND loc-tt-chk-discnt.object-line-num = loc_chk-discnt.object-line-num
                AND loc-tt-chk-discnt.discnt-id = loc_chk-discnt.discnt-id no-error.
          delete loc_chk-discnt.
          delete loc-tt-chk-discnt.
      end.
    end.
  end.
end.

if tt-chk-gds.src-qnty <> 0 then /* ненулевое кол-во */ do:
  price-from-check = /* действие, почти обратное ibm-gds.i */
  ( tt-chk-gds.SRC-PRICE / ( 1 - units-dpcnt / 100 ) ) * abs( tt-chk-gds.src-qnty ) .
  assign
  tt-chk-gds.b-code = ( if b-c <> ? then b-c else 0)
  tt-chk-gds.is-error = (b-c = ?)
    tt-chk-gds.doc-qnty = if par-mode = {&add-def}
                        then tt-chk-gds.src-qnty * units-rate
                        else tt-chk-gds.doc-qnty
  tt-chk-gds.doc-qnty = ROUND(tt-chk-gds.doc-qnty, 3)
  tt-chk-gds.price-base = round( price-from-check / abs( tt-chk-gds.doc-qnty ), 2 )
  tt-chk-gds.line-type = '':U
  .
  assign
  tt-chk-gds.discnt = if units-rate = 1
                    then (if (tt-chk-gds.pump > 0)
                          then
                          (tt-chk-gds.src-discnt  +
                            (abs(tt-chk-gds.src-qnty * tt-chk-gds.src-price) - abs(tt-chk-gds.src-sum) )
                            / abs(tt-chk-gds.src-qnty)
                          )
                          else tt-chk-gds.src-discnt
                          )
                    else
                        ( round( tt-chk-gds.src-discnt  +

                          ( price-from-check / abs( tt-chk-gds.doc-qnty )  - tt-chk-gds.src-price / abs( units-rate ) ) +
                          ( price-from-check / abs( tt-chk-gds.doc-qnty ) - tt-chk-gds.price-base ), 2 )
                        )
  tt-chk-gds.sum-base = tt-chk-gds.doc-qnty * tt-chk-gds.price-base
  .
end. /* if tt-chk-gds.src-qnty <> 0 t*/
assign
tt-gds-info.src-sum-netto = (tt-chk-gds.src-price - tt-chk-gds.src-discnt) * tt-chk-gds.src-qnty
tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
tt-gds-info.src-price-netto = tt-chk-gds.src-price - tt-chk-gds.src-discnt
tt-gds-info.sum-netto = (tt-chk-gds.price-base - tt-chk-gds.discnt) * tt-chk-gds.doc-qnty
tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
tt-gds-info.price-netto = tt-chk-gds.price-base - tt-chk-gds.discnt
.
run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-gds.src-code
  tt-chk-gds.price-base
  tt-chk-gds.discnt
  tt-chk-gds.doc-qnty
  TT-CHK-GDS.B-CODE
  tt-gds-info.artic
  tt-gds-info.gds-name
  tt-gds-info.prt-name
  tt-chk-gds.is-error
  tt-gds-info.src-d-pcnt
  tt-gds-info.src-price-netto
  tt-gds-info.src-sum-netto
  tt-gds-info.d-pcnt
  tt-gds-info.price-netto
  tt-gds-info.sum-netto
  with browse br-gds.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame {&frame-name}.
  glog = br-gds:refresh() in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-discnt Dialog-Frame 
PROCEDURE get-discnt :
DEFINE INPUT PARAMETER p-line-num like ub.chk-discnt.line-num.
DEFINE INPUT PARAMETER p-discnt-v-type like ub.chk-discnt.value-type no-undo.
DEFINE INPUT PARAMETER p-discnt-type like ub.chk-discnt.discnt-type no-undo.
DEFINE INPUT PARAMETER p-discnt-target like ub.chk-discnt.line-type no-undo.
define variable v-discnt-value like ub.chk-discnt.discnt-value-abs no-undo.
define buffer loc_chk-gds for ub.chk-gds.
define buffer loc_chk-discnt for ub.chk-discnt.
define buffer buf-tt-chk-gds for tt-chk-gds.
define buffer buf-tt-chk-discnt for tt-chk-discnt.


if p-discnt-target = integer({&discnt-sub-total}) OR
   p-discnt-target = integer({&discnt-total})
then do:
    tt-chk-doc.real-subdiscnt = 0.
    for each buf-tt-chk-discnt no-lock where
             buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND
                     buf-tt-chk-discnt.record-type = 0 and
                      buf-tt-chk-discnt.line-type <> integer({&discnt-gds})             :
    assign
    tt-chk-doc.real-subdiscnt = tt-chk-doc.real-subdiscnt + buf-tt-chk-discnt.discnt-value-abs
     .
  end.
  run GET-SUMS IN THIS-PROCEDURE NO-ERROR.
  display
  tt-chk-doc.tot-doc
  tt-chk-doc.discnt
  tt-chk-doc.netto
  tt-chk-doc.src-tot-doc
  with frame {&frame-name}.

end.
else do:
    assign
    v-discnt-value = 0.
    for each buf-tt-chk-discnt no-lock where
            buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND
            buf-tt-chk-discnt.record-type = 0 and
            buf-tt-chk-discnt.line-num = p-line-num  AND
            buf-tt-chk-discnt.line-type = integer({&discnt-gds}) :
            assign
            v-discnt-value = v-discnt-value + buf-tt-chk-discnt.discnt-value-abs
            .
    END.
    find first loc_chk-gds where
                 loc_chk-gds.doc-code = tt-chk-doc.doc-code and
                 loc_chk-gds.line-num = p-line-num no-error.
    find first buf-tt-chk-gds where
                     buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
                     buf-tt-chk-gds.line-num = p-line-num no-error.
    assign
    loc_chk-gds.src-discnt = v-discnt-value / loc_chk-gds.src-qnty
    buf-tt-chk-gds.src-discnt = v-discnt-value / buf-tt-chk-gds.src-qnty
    .
    run get-b-code in this-procedure ( input p-discnt-v-type
                                     , input p-discnt-type).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-good-proc Dialog-Frame 
PROCEDURE get-good-proc :
define input  parameter parb-code as integer no-undo.
define output parameter pargds-code as integer no-undo.
define output parameter pargds-name as character no-undo.
define output parameter parprt-name as character no-undo.
define output parameter paris-error as logical no-undo.
define output parameter var-artic like ub.goods.artic no-undo.
define buffer loc_bar-code for ub.bar-code.
define buffer loc_goods for ub.goods.
define buffer loc_gds-prt for ub.gds-prt.
FIND FIRST loc_bar-code No-LOCK WHERE
           loc_bar-code.b-code = parb-code No-ERROR.
IF  AVAILABLE loc_bar-code then do:
    FIND FIRST loc_goods No-LOCK WHERE
                      loc_goods.gds-code = loc_bar-code.gds-code NO-ERROR.
    IF AVAILABLE loc_goods then do:
        var-artic= loc_goods.artic.
        pargds-name = loc_goods.gds-name.
        pargds-code = loc_goods.gds-code.
    end.
     FIND FIRST loc_gds-prt WHERE
                       loc_gds-prt.node-code = loc_bar-code.node-code NO-LOCK.
    assign
    paris-error = no
    parprt-name =
                    ( if loc_gds-prt.node-name = {&empty-scale} then "-"
                      else ( if loc_gds-prt.upper-code = loc_goods.prt-root
                                then "-------------------" else loc_gds-prt.f-name ) ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GEt-params Dialog-Frame 
PROCEDURE GEt-params :
DEFINE INPUT PARAMETER p-obj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.clients.obj-code no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

  /*найдем параметр - тип кассы по умолчанию*/
{ gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
get-chkc_context.pos-type = dflt-cd.
get-chkc_context.p-log-handle = this-procedure:handle.
p-pos-type = dflt-cd.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-chk-view}
    ,input  '':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-obj-type
   and thbjattr_thbj-attr.obj-code = p-obj-code
   and thbjattr_thbj-attr.upper-prop-code = {&attr-chk-view}
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-chk-view_dc-change} then do:
      assign
      dc-change = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-chk-view_ch-bc-ck} then do:
      assign
      ch-bc-ck = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
assign
is-prt = no
.

run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-dc-ref}
    ,input  {&attr-dc-ref_l-mask} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-obj-type
   and thbjattr_thbj-attr.obj-code = p-obj-code
   and thbjattr_thbj-attr.upper-prop-code = {&attr-dc-ref}
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when {&attr-dc-ref_l-mask} then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
  message
  "Внимание! На текущем объекте требуется использование смен," skip
  "а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо." skip (2)
  view-as alert-box ERROR.
  return ERROR.
end.


{ gbl/conf-rd.i
"'ch-bc-ck'"
get-chkc_context.host-code
get-chkc_context.obj-type
get-chkc_context.obj-code
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
IF not error-status:error then
ch-bc-ck = (conf-par = "yes").

{ gbl/conf-rd.i
"'is-prt'"
0
 "''"
 0
 "''"
 "''"
 "''"
 no
 conf-par
par-type
 no-error
 }
IF not error-status:error then
is-prt = (conf-par = "yes").

find first buf_shop no-lock where buf_shop.obj-code = p-obj-code .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-pay-proc Dialog-Frame 
PROCEDURE get-pay-proc :
define input parameter parpay-code as integer no-undo.
define input parameter parcurr-code as integer no-undo.
define output parameter parcurr-name as character no-undo.
define output parameter varpay-name like ub.cash-pay.obj-name no-undo.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.

if tt-chk-doc.chk-type = integer({&expense-corr})
or tt-chk-doc.chk-type = integer({&income-corr})
then do :
  case parpay-code :
    when 1031 then varpay-name = {&cash}.
    when 1081 then varpay-name = {&electronic}.
    when 1215 then varpay-name = {&prepayment}.
    when 1216 then varpay-name = {&credit}.
  /*  when 1217 then varpay-name = {&counter_presentation}. */
    otherwise varpay-name = "Неизвестная оплата".
  end case.
  parcurr-name = "Рубль".
  return.
end.

FIND FIRST loc_cash-pay No-LOCK WHERE
                  loc_cash-pay.cdpay-code = parpay-code AND
                  loc_cash-pay.curr-code = parcurr-code No-ERROR.
if avail loc_cash-pay then do:
    varpay-name = loc_cash-pay.obj-name.
end.
else do:
  if tt-chk-doc.chk-type = integer({&rcpt-z-rep})
  and parpay-code = 0
  and parcurr-code = 0
  then do:
    varpay-name = "Показания счетчиков".
  end.
  else do:
    varpay-name = "Неизвестная оплата".
end.
end.
FIND FIRST loc_currency No-LOCK WHERE
                  loc_currency.curr-code = parcurr-code No-ERROR.
if available loc_Currency then do:
    parcurr-name = loc_currency.curr-name.
end.
else parcurr-name = "Неизвестная валюта".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-pay-sums Dialog-Frame 
PROCEDURE get-pay-sums :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define parameter buffer loc_tt-chk-pay for tt-chk-pay.
define buffer loc_tt-pay-info for tt-pay-info.
find first loc_tt-pay-info where
           loc_tt-pay-info.line-num = loc_tt-chk-pay.line-num  .

    CASE ABS(loc_tt-chk-pay.curr-code):
      when 0 then do:
        assign
        loc_tt-chk-pay.tot-rubl = loc_tt-chk-pay.tot-sum
        loc_tt-chk-pay.tot-base = loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
        loc_tt-pay-info.calc-rate = loc_tt-chk-pay.tot-rubl / loc_tt-chk-pay.tot-sum
        .
      end. /*when chk-pay.curr-code = 0*/
      when get-chkc_context.base-code then do:
        assign
        loc_tt-chk-pay.tot-base = loc_tt-chk-pay.tot-sum
        loc_tt-chk-pay.tot-rubl = if get-chkc_context.r-b = {&r-b-base}
                              then loc_tt-chk-pay.tot-sum * tt-chk-doc.cash-rate
                              else loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
        loc_tt-pay-info.calc-rate = loc_tt-chk-pay.tot-rubl / loc_tt-chk-pay.tot-sum
        .
      end. /*when base-code*/
      otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
          assign
          loc_tt-chk-pay.tot-base = if get-chkc_context.r-b = {&r-b-base}
                              then loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
                              else loc_tt-chk-pay.tot-sum
          loc_tt-chk-pay.tot-rubl = if get-chkc_context.r-b = {&r-b-base}
                              then loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate * tt-chk-doc.cash-rate
                              else loc_tt-chk-pay.tot-sum / loc_tt-chk-pay.cash-rate
          loc_tt-pay-info.calc-rate = loc_tt-chk-pay.tot-rubl / loc_tt-chk-pay.tot-sum
          .
      end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
    END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-price1 Dialog-Frame 
PROCEDURE get-price1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER pargds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER parnode-code like ub.gds-prt.node-code no-undo.

{ str/get-pr.i calc tt-chk-doc.obj-type tt-chk-doc.obj-code pargds-code parnode-code "return error."}
/*todo
если бы знали как определить номер или factorder переоценки по времени

define variable v-fact-order as decimal no-undo.
{ gbl/gdsbcode.i pargds-code  parnode-code gp-b-code no-error}
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.

{ gbl/bcodeprc.i tt-chk-doc.obj-type tt-chk-doc.obj-code gp-b-code v-fact-order 0 gp-doc-num gp-price-sale gp-road-tax gp-excise no-error }
if error-status:error then do:
  return error.
end.
*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-staff Dialog-Frame 
PROCEDURE get-staff :
define input parameter p-num as integer no-undo.
define input parameter p-role as character no-undo.
define input parameter p-date as date no-undo .
define variable v-psn-code as integer no-undo .
if dflt-cd = {&cd-type-magia-XML} then do:
  CASE p-role:
    when {&role-cashier} then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input {&role-cashier}
                                              ,input get-chkc_context.db-num
                                              ,input p-num
                                              ,input p-date
                                              )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_cashier no-lock where
                      buf_cashier.obj-type = {&prs}
                  and buf_cashier.obj-code = v-psn-code no-error.
        if available buf_cashier then do:
          display
          buf_cashier.obj-name @ f-cashier
          with frame {&frame-name}.
          find first cashier no-lock where
                    cashier.psn-code = v-psn-code.
        end.
        else do:
          release cashier.
          display
          {&question-mark} @ F-cashier
          with frame {&frame-name}.
        end.
      end.
      else do:
        release buf_cashier.
        release cashier.
        display
        {&question-mark} @ F-cashier
        with frame {&frame-name}.
      end.
    end.
    when {&role-seller} then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input {&role-seller}
                                               ,input get-chkc_context.db-num
                                               ,input (p-num - 10000)
                                               ,input p-date
                                               )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_sales-man no-lock where
                      buf_sales-man.obj-type = {&prs}
                  and buf_sales-man.obj-code = v-psn-code no-error.
        if available buf_sales-man then do:
          display
          buf_sales-man.obj-name @ f-salesman
          with frame {&frame-name}.
          find first sales-man no-lock where
                    sales-man.psn-code = v-psn-code.
        end.
        else do:
          release sales-man.
          display
          {&question-mark} @ F-salesman
          with frame {&frame-name}.
        end.
      end.
      else do:
        release buf_sales-man.
        release sales-man.
        display
        {&question-mark} @ F-salesman
        with frame {&frame-name}.
      end.
    end. /*when sales-man*/
  END CASE.
end.
else do:
CASE p-role:
    when {&role-cashier} then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input {&role-cashier}
                                             ,input get-chkc_context.db-num
                                             ,input p-num
                                             ,input p-date
                                             )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_cashier no-lock where
                      buf_cashier.obj-type = {&prs}
                  and buf_cashier.obj-code = v-psn-code no-error.
        if available buf_cashier then do:
            display
            buf_cashier.obj-name @ f-cashier
            with frame {&frame-name}.
        end.
        else do:

            display
            {&question-mark} @ F-cashier
            with frame {&frame-name}.
        end.
      end.
      else do:
        release buf_cashier.
        display
        {&question-mark} @ F-cashier
        with frame {&frame-name}.
      end.
    end.
    when {&role-seller} then do:
      assign
      v-psn-code = gbclcode-is-this-db-role ( input {&role-seller}
                                               ,input get-chkc_context.db-num
                                               ,input p-num
                                               ,input p-date
                                               )
      no-error .
      if v-psn-code > 0 then do:
        find first buf_sales-man no-lock where
                      buf_sales-man.obj-type = {&prs}
                  and buf_sales-man.obj-code = v-psn-code no-error.
        if available buf_sales-man then do:
          display
          buf_sales-man.obj-name @ f-salesman
          with frame {&frame-name}.
        end.
        else do:
          display
          {&question-mark} @ F-salesman
          with frame {&frame-name}.
        end.
        end.
        else do:
          release buf_sales-man.
          display
          {&question-mark} @ F-salesman
          with frame {&frame-name}.
        end.

    end.
  END CASE.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GET-SUMS Dialog-Frame 
PROCEDURE GET-SUMS :
define variable v-is-petrol-check            as logical                 no-undo .
define variable v-is-inventory as logical no-undo .
DEFINE BUFFER BUF_TT-CHK-GDS FOR TT-CHK-GDS.
DEFINE VARIABLE var-for-src-d-pcnt as decimal no-undo .
assign
tt-chk-doc.tot-doc = 0
tt-chk-doc.discnt = 0
tt-chk-doc.netto = 0
.
if lookup(string(tt-chk-doc.chk-type) , {&petrol-receipt-codes}) > 0 then do:
  v-is-petrol-check = yes.
end.
if tt-chk-doc.chk-type = integer({&rcpt-inventory}) then do:
  assign
  v-is-inventory = yes.
end.
if not v-is-petrol-check
and not v-is-inventory
then do:
  for each buf_tt-chk-gds no-lock:
    assign
    tt-chk-doc.tot-doc = tt-chk-doc.tot-doc +   (if (tt-chk-doc.chk-type = integer({&rcpt-sale})
                                                or tt-chk-doc.chk-type = integer({&rcpt-write-off}))

                                                and buf_tt-chk-gds.write-off-code > 0 then 0
                                                else buf_tt-chk-gds.price-base * buf_tt-chk-gds.doc-qnty
                                                )
    tt-chk-doc.discnt = tt-chk-doc.discnt + (if buf_tt-chk-gds.write-off-code <> ?
                                           and buf_tt-chk-gds.write-off-code > 0
                                           then 0
                                           else  buf_tt-chk-gds.discnt * buf_tt-chk-gds.doc-qnty)
    tt-chk-doc.netto = tt-chk-doc.tot-doc - tt-chk-doc.discnt
    .
  end.
  assign
  tt-chk-doc.discnt = tt-chk-doc.discnt + (if par-mode = {&add-def} then tt-chk-doc.real-subdiscnt else 0)
  tt-chk-doc.netto = tt-chk-doc.tot-doc - tt-chk-doc.discnt
  .
  if tt-chk-doc.src-d-pcnt <> 0 and not v-is-sub-d then do:
    assign
    var-for-src-d-pcnt = tt-chk-doc.netto * tt-chk-doc.src-d-pcnt / 100
    tt-chk-doc.netto  = tt-chk-doc.netto - var-for-src-d-pcnt
    tt-chk-doc.discnt = tt-chk-doc.discnt + var-for-src-d-pcnt
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE llb as character no-undo .
DEFINE VARIABLE v-h AS handle NO-UNDO.
ASSIGN
v-h = br-discnt:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label_templ-rl-root} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_receipt_input_teh':U
  {&cntxt-object}
  v-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  false
  actn#log
}

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_receipt_input_bonus':U
  {&cntxt-object}
  v-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  false
  actn#log_bonus
}
if actn#log or par-mode = {&lookup} or par-mode = "susp-type" then do:
assign
cb-chk-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  {&receipt-codes-combo} +


                                                      (if par-mode <> {&add-def} 
                                                      then ({&comma-char} + "Ошибка" + {&comma-char} + string(0))
                                                      else "":U)

.  
end.
else do:
assign
cb-chk-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  '{&bef-rcpt-sale-full},{&bef-rcpt-sale},{&bef-rcpt-return-full},{&bef-rcpt-return}':U +


                                                      (if par-mode <> {&add-def}
                                                      then ({&comma-char} + "Ошибка" + {&comma-char} + string(0))
                                                      else "":U)
.
end.  
if (par-mode = {&update}
or par-mode = {&lookup} 
or par-mode = "susp-type" )
and lookup(string(tt-chk-doc.chk-type), {&annu-receipt-codes}) > 0
and tt-chk-doc.prev-chk-type <> 0
and tt-chk-doc.prev-chk-type <> ?
then do:
  &scop receipt-code string(tt-chk-doc.prev-chk-type)
  cb-chk-type:LIST-ITEM-PAIRS in frame {&frame-name} = substitute("Анн.&1", {&receipt-name}) + {&comma-char} + string(tt-chk-doc.chk-type).
end.

if par-mode = {&add-def} then do:
  cb-chk-type = {&rcpt-sale}.
end.
assign
tt-chk-gds.src-code:resizable IN BROWSE br-gds = YES
tt-gds-info.gds-name:resizable IN BROWSE br-gds = YES
tt-gds-info.prt-name:resizable IN BROWSE br-gds = YES
.

run tax-name in this-procedure ( input  {&road-tax}, output llb).
tt-chk-gds.road-tax:label IN browse br-gds =  llb.
ASSIGN
frame {&frame-name}:title = if par-mode = {&add-def}
                            then substitute("ЧЕК № &1"
                                      ,tt-chk-doc.doc-code)
                          else (substitute("ЧЕК № &1 Время : &2"
                                       ,tt-chk-doc.doc-code
                                       ,string (tt-chk-doc.chk-time, "HH:MM")) +
                            if (get-chkc_context.cas-shft OR get-chkc_context.T-SHFT <> 0)
                            then substitute(" Смена от &1 N смены &2&3"
                                            ,string(tt-chk-doc.src-shift-date, "99/99/9999")
                                            ,tt-chk-doc.shift-name
                                            , (if integer(tt-chk-doc.shift-name) = tt-chk-doc.shift-num
                                               then '':U
                                               else string(tt-chk-doc.shift-num, "(>9)"))
                                            )
                            else substitute("Дата учета &1", string(tt-chk-doc.shift-date))).
if dflt-cd <> {&cd-type-ncr-gm}
and dflt-cd <> {&cd-type-ncr-as-r}
then do:
    assign
    menu-item m_without:sensitive in menu MENU-B-adddiscnt = no
    menu-item m_gds-abs:sensitive in menu MENU-B-adddiscnt = no
    .
end.
if dflt-cd <> {&cd-type-magia-XML}
and dflt-cd <> {&cd-type-IBM-XML} then do:
    assign
    menu-item m-sales-man:sensitive in menu m-prt = no
    .
end.

if par-l-mask and tt-chk-doc.src-d-card <> "" then v-src-d-card = substring(tt-chk-doc.src-d-card,1,6) + "XXXXXX" + substring (tt-chk-doc.src-d-card,13,4).
else v-src-d-card = tt-chk-doc.src-d-card .

  DISPLAY cb-chk-type fhour fmin fsec F-cashier F-salesman f-cli-name
  WITH FRAME {&frame-name} .
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man
          tt-chk-doc.obj-code tt-chk-doc.d-card v-src-d-card tt-chk-doc.pay-desk
          tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
          tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cash-scale
          tt-chk-doc.cash-rate tt-chk-doc.shift-num tt-chk-doc.shift-name tt-chk-doc.PS
          tt-chk-doc.tot-doc tt-chk-doc.discnt tt-chk-doc.sub-discnt
          tt-chk-doc.netto tt-chk-doc.d-pcnt tt-chk-doc.doc-num tt-chk-doc.doc-num2
          tt-chk-doc.src-tot-doc
      WITH FRAME {&frame-name}.
case PAR-MODE:
  WHEN {&ADD-DEF} THEN DO:
    ENABLE
    B-quit
    B-exit
    br-attr
    b-func
    cb-chk-type
    B-help
    B-card
    tt-chk-doc.chk-date
    tt-chk-doc.cashier
    fhour
    fmin
    v-doc-osnov
    BUTTON-1
    f-cause-corr 
    f-num-corr 
    corr-date
    Btn_sht-from
    fsec
    tt-chk-doc.sales-man
    tt-chk-doc.d-card
    v-src-d-card
    b-choose-date
    b-cd tt-chk-doc.chk-num tt-chk-doc.z-number
    tt-chk-doc.doc-num
    tt-chk-doc.doc-num2
    tt-chk-doc.src-d-pcnt
    tt-chk-doc.cash-scale when get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code <> 0
    tt-chk-doc.cash-rate when get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code <> 0
    tt-chk-doc.src-shift-DATE WHEN (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.shift-name WHEN (get-chkc_context.CAS-SHFT AND NOT get-chkc_context.SHiFT-ON)
    B-adddiscnt  b-addbonus B-addgds br-discnt BR-gds BR-pay tt-chk-doc.PS B-addpay tt-chk-doc.doc-num tt-chk-doc.doc-num2
    WITH FRAME {&frame-name}.
    assign
    tt-chk-gds.b-code:read-only in browse br-gds = yes
    tt-chk-gds.depart-code:read-only in browse br-gds = yes
    tt-chk-gds.doc-qnty:read-only in browse br-gds = yes
    tt-chk-pay.doc-qnty:read-only in browse br-pay = yes
    tt-chk-pay.par-val:read-only in browse br-pay = yes
    tt-chk-pay.doc-qnty:visible in browse br-pay = no
    tt-chk-pay.par-val:visible in browse br-pay = no
    .
    if dflt-cd = {&cd-type-ncr-gm}
    or  dflt-cd = {&cd-type-ncr-as-r}
    then do:
      assign
      tt-chk-gds.src-discnt:read-only in browse br-gds = yes
      .
      disable
      tt-chk-doc.src-d-pcnt
      with frame {&frame-name}.
    end.
    hide
    b-hist
    text-4
    button-susp
    v-susp-chk
    v-link-chk
    in frame {&frame-name}.
    /*переставить колонки*/
  END.
  WHEN {&lookup} or when "susp-type" THEN DO:
    ENABLE
    B-quit
    B-exit
    br-attr
    B-prev
    B-next
    B-print
    B-help
    /*b-addgds */
    b-adddiscnt
    b-addbonus
    b-slip-chk
    br-gds br-discnt br-pay
    b-hist
    b-cf WHEN tt-chk-doc.chk-type = INTEGER({&rcpt-z-rep})
    WITH FRAME {&frame-name}.
    assign
    tt-chk-gds.b-code:read-only in browse br-gds = yes
    tt-chk-gds.src-code:read-only in browse br-gds = yes
    tt-chk-gds.pump:read-only in browse br-gds = yes
    tt-chk-gds.nozzle-code:read-only in browse br-gds = yes
    tt-chk-gds.pl-code:read-only in browse br-gds = yes
    tt-chk-gds.loc1:read-only in browse br-gds = yes
    tt-chk-gds.src-price:read-only in browse br-gds = yes
    tt-chk-gds.src-discnt:read-only in browse br-gds = yes
    tt-chk-gds.src-qnty:read-only in browse br-gds = yes
    tt-chk-gds.road-tax:read-only in browse br-gds = yes
    tt-chk-gds.depart-id:read-only in browse br-gds = yes
    tt-chk-gds.depart-code:read-only in browse br-gds = yes
    tt-chk-pay.pay-code:read-only in browse br-pay = yes
    tt-chk-pay.curr-code:read-only in browse br-pay = yes
    tt-chk-pay.tot-sum:read-only in browse br-pay = yes
    tt-chk-pay.pay-card:read-only in browse br-pay = yes
    tt-chk-pay.cash-rate:read-only in browse br-pay = yes
    tt-chk-pay.src-qnty:read-only in browse br-pay = yes
    tt-chk-pay.src-val:read-only in browse br-pay = yes
    tt-chk-pay.doc-qnty:read-only in browse br-pay = yes
    tt-chk-pay.par-val:read-only in browse br-pay = yes
    tt-chk-discnt.real-value-abs:read-only in browse br-discnt = yes
    tt-chk-discnt.real-value-pcnt:read-only in browse br-discnt = yes
    tt-chk-gds.doc-qnty:read-only in browse br-gds = yes
    b-addgds:label = "Товар"
    Br-gds:POPUP-MENU IN FRAME Dialog-Frame       = ?
    Br-pay:POPUP-MENU IN FRAME Dialog-Frame       = ?
    .
    hide
    b-exit 
    text-4
    button-susp
    v-susp-chk
    v-link-chk
    in frame {&frame-name}.
    if par-mode = {&lookup} then
    b-quit:label = "&Выход". 

  END.
  WHEN {&update} THEN DO:
    ENABLE
    B-quit
    B-exit
    br-attr
    B-help
    b-hist
    b-cf WHEN tt-chk-doc.chk-type = INTEGER({&rcpt-z-rep})
    b-card
    b-func
    v-doc-osnov
    BUTTON-1
    f-cause-corr 
    f-num-corr 
    corr-date
    tt-chk-doc.src-d-card when (tt-chk-doc.src-d-card = "-0":U
                                and
                                (index(tt-chk-doc.d-card, "*" ) > 0
                                or
                                index(tt-chk-doc.d-card, "!" ) > 0)
                               )
    b-addgds b-adddiscnt b-addbonus
    b-slip-chk
    tt-chk-doc.chk-date  when not get-chkc_context.shift-on
    tt-chk-doc.cashier
    tt-chk-doc.d-card
    tt-chk-doc.z-number
    tt-chk-doc.src-shift-DATE WHEN (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.shift-name WHEN (get-chkc_context.CAS-SHFT AND NOT get-chkc_context.SHiFT-ON)
    br-discnt BR-gds BR-pay tt-chk-doc.PS
    tt-chk-doc.d-card when dc-change
    tt-chk-doc.doc-num 
    tt-chk-doc.doc-num2
    WITH FRAME Dialog-Frame.
    hide 
    text-4
    button-susp
    v-susp-chk
    v-link-chk
    in frame Dialog-Frame .
    assign
    tt-chk-gds.src-code:read-only in browse br-gds = yes
    tt-chk-gds.b-code:read-only in browse br-gds = yes 
    tt-chk-gds.pump:read-only in browse br-gds = yes
    /*
    tt-chk-gds.nozzle-code:read-only in browse br-gds = yes
    tt-chk-gds.loc1:read-only in browse br-gds = yes
    */
    tt-chk-gds.src-price:read-only in browse br-gds = yes
    tt-chk-gds.src-discnt:read-only in browse br-gds = yes
    tt-chk-gds.src-qnty:read-only in browse br-gds = yes
    tt-chk-gds.road-tax:read-only in browse br-gds = yes
    tt-chk-gds.depart-id:read-only in browse br-gds = yes
    tt-chk-pay.tot-sum:read-only in browse br-pay = (if tt-chk-doc.chk-type = integer({&rcpt-z-rep})
                                                     then no
                                                     else yes)
    tt-chk-pay.pay-card:read-only in browse br-pay = yes
    tt-chk-pay.src-qnty:read-only in browse br-pay = yes
    tt-chk-pay.src-val:read-only in browse br-pay= yes
    tt-chk-discnt.real-value-abs:read-only in browse br-discnt = yes
    tt-chk-discnt.real-value-pcnt:read-only in browse br-discnt = yes
    b-addgds:label = "Товар"
    .
    if dflt-cd = {&cd-type-ncr-gm}
    or dflt-cd = {&cd-type-ncr-as-r}
    then do:
      assign
      tt-chk-gds.src-discnt:read-only in browse br-gds = yes
      .
    end.
  END.
end case.
IF par-mode <> {&ADD-DEF}
or not get-chkc_context.is-catering
THEN DO:
    menu-item m-write-off:sensitive in menu M-prt = no.
    menu-item m-modificator:sensitive in menu M-prt = no.
END.
if par-mode <> {&add-def}
then do:
  menu-item m-sales-man:sensitive in menu m-prt = no.
end.
if not cas-shft then do:
    hide
    tt-chk-doc.src-shift-date
    tt-chk-doc.shift-num
    tt-chk-doc.shift-name
    in frame {&frame-name}.
end.
if not actn#log_bonus then do:
  disable  tt-chk-doc.d-card v-src-d-card B-card with frame {&frame-name} .
end.  
b-adddiscnt:POPUP-MENU IN FRAME {&frame-name} = ?.
b-addbonus:POPUP-MENU IN FRAME {&frame-name} = ?.
VIEW FRAME {&FRAME-NAME}.
{&OPEN-QUERY-BR-gds}
{&OPEN-QUERY-BR-pay}
{&OPEN-QUERY-BR-discnt}
hide br-discnt in frame {&frame-name}.
IF b-cf:SENSITIVE IN FRAME {&FRAME-NAME} = NO THEN HIDE
b-cf IN FRAME {&FRAME-NAME}.
hide BR-corr in frame {&frame-name}.
hide v-corr-osnov v-corr-type in frame {&frame-name}.

if tt-chk-doc.chk-type = integer({&income-corr})
or tt-chk-doc.chk-type = integer({&expense-corr})
then do :
  v-corr-osnov = tt-chk-doc.doc-num .
  if num-entries(tt-chk-doc.doc-num2, ":") = 2
  then do :
    if entry(1, tt-chk-doc.doc-num2, ":") = "0"
    then v-corr-type = "самостоятельно" .
    else
    if entry(1, tt-chk-doc.doc-num2, ":") = "1"
    then v-corr-type = "по предписанию" .
    else
    v-corr-type = "неизвестн." .
  end.
  else
  v-corr-type = "неизвестн." .
  hide BR-gds in frame {&frame-name}.
  open query br-corr for each tt-chk-gds WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code .
  display BR-corr v-corr-osnov v-corr-type with frame {&frame-name}.
  enable BR-corr with frame {&frame-name}.
  
  hide tt-chk-doc.doc-num2 tt-chk-doc.doc-num in frame {&frame-name}.
end.
    if par-mode <> "susp-type" then 
    do:
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code 
            and buf_chk-doc-attr.attr-code = "corr-osnov":
            v-corr-osnov1 = integer(buf_chk-doc-attr.attr-value).
            v-doc-osnov = OsnovCorr(v-corr-osnov1) .
        end.   
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code 
            and buf_chk-doc-attr.attr-code = "corr-date":
            corr-date = date(buf_chk-doc-attr.attr-value) .
        end.   
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code 
            and buf_chk-doc-attr.attr-code = "corr-num":
            f-num-corr = buf_chk-doc-attr.attr-value .
        end.   
        for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code 
            and buf_chk-doc-attr.attr-code = "corr-cause":
            f-cause-corr = buf_chk-doc-attr.attr-value .
        end.   
        display 
            text-1
            v-doc-osnov
            corr-date
            f-cause-corr
            f-num-corr
            with frame {&frame-name} . 
        hide 
            text-4
            button-susp
            v-susp-chk
            v-link-chk
            in frame Dialog-Frame .
    end.
    else 
    do:
        for first ub.susp-chk no-lock where ub.susp-chk.doc-code = tt-chk-doc.doc-code:
            v-susp-chk = ub.susp-chk.reason-name .
            v-link-chk = ub.susp-chk.link-chk .
        end.   
        hide 
            text-1
            v-doc-osnov
            corr-date
            f-cause-corr
            f-num-corr
            button-1
            b-choose-date
            in frame {&frame-name} . 

        display text-4 v-susp-chk v-link-chk with frame {&frame-name} .
        enable 
            button-susp
            v-susp-chk
            v-link-chk
            b-exit
            with frame Dialog-Frame .  
            v-susp-chk:read-only = true .   
    end.   
for each tt-gds-info no-lock:


EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(tt-chk-doc.obj-type, tt-chk-doc.obj-code) no-error.
      RUN gds-attr-value (
                          INPUT tt-gds-info.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-gds-attr-value,
                          OUTPUT v-gds-attr-type
                          ).
      if v-gds-attr-value > ""
      and EDOParSec:GetIsMarkingForType(v-gds-attr-value)
      then do : /* нужна марка */
      enable 
      B_mark
      with frame {&frame-name} .
      leave .
      end.
      
end.      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pays-display Dialog-Frame 
PROCEDURE pays-display :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-change-curr as logical no-undo.
DEFINE VARIABLE curr-rate                  like ub.curr-shop.exch-rate   no-undo .
DEFINE VARIABLE curr-scale                 like ub.curr-shop.exch-scale  no-undo .

FIND FIRST ub.cash-pay WHERE
          ub.cash-pay.cdpay-code = tt-chk-pay.pay-code AND
          ub.cash-pay.curr-code = tt-chk-pay.curr-code NO-LOCK NO-ERROR.
if NOT available ub.cash-pay
AND tt-chk-doc.chk-type <> INTEGER({&rcpt-z-rep}) then do:
  assign
  tt-chk-pay.is-error = yes
  .
end.
CASE ABS(tt-chk-pay.curr-code):
  when 0 then do:
    assign
    tt-chk-pay.tot-rubl = tt-chk-pay.tot-sum
    .
    if get-chkc_context.cas-curs then do:
      assign
      tt-chk-pay.tot-base = tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
      .
      run find-curs in this-procedure
                        (
                         input tt-chk-doc.chk-date
                        ,input tt-chk-doc.chk-time
                        ,input get-chkc_context.base-code
                        ,output tt-pay-info.exch-rate
                        ,output tt-pay-info.exch-scale
                        ,output tt-pay-info.exch-date
                        ,output tt-pay-info.exch-time
                        )  no-error.
    end.
    else do:
      run find-curs in this-procedure
                        (
                         input tt-chk-doc.chk-date
                        ,input tt-chk-doc.chk-time
                        ,input get-chkc_context.base-code
                        ,output cash-rate_
                        ,output cash-scale_
                        ,output tt-pay-info.exch-date
                        ,output tt-pay-info.exch-time

                        )  no-error.

      assign
      tt-chk-pay.is-error = error-status:error
      tt-chk-pay.tot-base = tt-chk-pay.tot-sum / cash-rate_ * cash-scale_
      tt-pay-info.exch-rate = cash-rate_
      tt-pay-info.exch-scale = cash-scale_
      .
    end. /* NOT cas-curs*/
  end. /*when tt-chk-pay.curr-code = 0*/
  when get-chkc_context.base-code then do:
    assign
    tt-chk-pay.tot-base = tt-chk-pay.tot-sum
    .
    if cas-curs then do:
      assign
      tt-chk-pay.tot-rubl = if get-chkc_context.r-b = {&r-b-base}
                          then tt-chk-pay.tot-sum * tt-chk-doc.cash-rate
                          else tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
      .
      run find-curs in this-procedure
                        (
                         input tt-chk-doc.chk-date
                        ,input tt-chk-doc.chk-time
                        ,input get-chkc_context.base-code
                        ,output tt-pay-info.exch-rate
                        ,output tt-pay-info.exch-scale
                        ,output tt-pay-info.exch-date
                        ,output tt-pay-info.exch-time
                        )  no-error.
    end.
    else do:
            run find-curs in this-procedure
                              (
                               input tt-chk-doc.chk-date
                              ,input tt-chk-doc.chk-time
                              ,input get-chkc_context.base-code
                              ,output cash-rate_
                              ,output cash-scale_
                              ,output exch-date_
                              ,output exch-time_
                              )  no-error.
        assign
        tt-chk-pay.is-error = error-status:error
        tt-chk-pay.tot-rubl = tt-chk-pay.tot-sum * cash-rate_ / cash-scale_
        tt-pay-info.exch-rate = cash-rate_
        tt-pay-info.exch-scale = cash-scale_

        .
    end. /*NOT cas-curs*/
  end. /*when base-code*/
  otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
    if cas-curs then do:
      assign
      tt-chk-pay.tot-base = if get-chkc_context.r-b = {&r-b-base}
                         then tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
                         else tt-chk-pay.tot-base
                          tt-chk-pay.tot-rubl = if get-chkc_context.r-b = {&r-b-base}
                         then tt-chk-pay.tot-sum / cass-rate * tt-chk-doc.cash-rate
                         else tt-chk-pay.tot-sum / tt-chk-pay.cash-rate
      .
      if not get-chkc_context.r-b = {&r-b-base} then do:
                run find-curs in this-procedure
                          (
                           input tt-chk-doc.chk-date
                          ,input tt-chk-doc.chk-time
                          ,input get-chkc_context.base-code
                          ,output cash-rate_
                          ,output cash-scale_
                          ,output exch-date_
                          ,output exch-time_
                          )  no-error.

          assign
          tt-chk-pay.is-error = error-status:error
          tt-chk-pay.tot-base = tt-chk-pay.tot-sum * cash-rate_ / cash-scale_
          .

      end. /*if not get-chkc_context.r-b = {&r-b-base} then do:*/
      run find-curs in this-procedure
                          (
                          input tt-chk-doc.chk-date
                          ,input tt-chk-doc.chk-time
                          ,input tt-chk-pay.curr-code
                          ,output tt-pay-info.exch-rate
                          ,output tt-pay-info.exch-scale
                          ,output tt-pay-info.exch-date
                          ,output tt-pay-info.exch-time
                          )  no-error.


    end. /*if cas-curs then do:*/
    else do:
        run find-curs in this-procedure
              (
               input tt-chk-doc.chk-date
              ,input tt-chk-doc.chk-time
              ,input tt-chk-pay.curr-code
              ,output cash-rate_
              ,output cash-scale_
              ,output tt-pay-info.exch-date
              ,output tt-pay-info.exch-time

              )  no-error.


        assign
        tt-chk-pay.is-error = error-status:error
        tt-chk-pay.tot-rubl = tt-chk-pay.tot-sum * cash-rate_ / cash-scale_
        tt-pay-info.exch-rate = cash-rate_
        tt-pay-info.exch-scale = cash-scale_

        curr-rate = cash-rate_
        curr-scale = cash-scale_
        .
                    run find-curs in this-procedure
                          (
                           input tt-chk-doc.chk-date
                          ,input tt-chk-doc.chk-time
                          ,input get-chkc_context.base-code
                          ,output cash-rate_
                          ,output cash-scale_
                          ,output exch-date_
                          ,output exch-time_
                          )  no-error.
          assign
          tt-chk-pay.is-error = error-status:error
          tt-chk-pay.tot-base = tt-chk-pay.tot-sum * (curr-rate / curr-scale)  /
                             cash-rate_ * cash-scale_
          .
    end.  /*NOT cas-curs*/
  end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
END CASE.
assign
tt-pay-info.calc-rate = tt-chk-pay.tot-rubl / tt-chk-pay.tot-sum
tt-pay-info.exch-time-str = string(tt-pay-info.exch-time, "hh:mm:ss").
.

display
tt-chk-pay.tot-sum
tt-chk-pay.tot-base
tt-chk-pay.tot-rubl
tt-chk-pay.cash-rate
tt-pay-info.calc-rate
tt-pay-info.exch-date
tt-pay-info.exch-time-str
tt-pay-info.exch-rate
tt-pay-info.exch-scale
with browse br-pay.
glog = br-pay:refresh() in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-addbonus Dialog-Frame 
PROCEDURE proc-b-addbonus :
define variable v-line-num AS integer NO-UNDO.
define variable v-src-d-card AS character NO-UNDO.
define variable v-discnt-type as integer no-undo .
define variable v-discnt-id AS integer NO-UNDO.
define variable v-kateg AS integer NO-UNDO.
define variable v-updated AS LOGICAL NO-UNDO.

define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer buf_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not actn#log_bonus then do:
  message "Отсутствует право: Редактирование бонусов, скидок и ДК в чеках"
  view-as alert-box.
  return.
end.  
if v-br-discnt-current-type = 4 then do:
  if available tt-chk-discnt THEN DO:
     RUN proc-leave-discnt-abs in THIS-PROCEDURE ( input integer({&discnt-v-abs})).
  END.
end.
if not br-discnt:visible in frame {&frame-name}
OR v-br-discnt-current-type = 0
then do:
    ASSIGN
    v-br-discnt-current-type = 4.
    hide br-gds in frame {&frame-name}.
    display br-discnt with frame {&frame-name}.
    ASSIGN
    b-addgds:label = "Товары"
    b-adddiscnt:label = "Скидки"
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = YES
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = YES
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = YES
    v-br-discnt-current-type = 4
    .

    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-discnt :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .

    {&OPEN-QUERY-BR-discnt}
     if par-mode = {&add-def} then do:
        assign
        b-addbonus:POPUP-MENU IN FRAME {&frame-name} = menu MENU-b-addbonus:handle
        b-addbonus:MENU-MOUSE = 1
        b-addbonus:label = "Добавить Бoнус"
        b-adddiscnt:popup-menu = ?
        .
    end.
    if par-mode = {&lookup} or par-mode = "susp-type" then do:
      ENABLE
      b-addgds
      b-adddiscnt
      with frame {&frame-name}.
      DISABLE
      b-addbonus
      with frame {&frame-name}.
    end.
    return.
end.
if not par-mode = {&add-def} then return.
/*run proc-save-doc No-ERROR.             */
/*if error-status:error then return error.*/
if discnt-option = "":U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.

if par-mode = {&add-def} then do:
  run str/add-bon.w ( input parparentproc
                 ,input par-mode
                 ,input-output v-line-num
                 ,input-output v-src-d-card
                 ,input-output v-discnt-type
                 ,input-output v-discnt-id
                 ,input-output v-kateg
                 ,output v-updated ) no-error.
            
 if not v-updated then return error.
  find first buf_tt-chk-discnt no-lock where
            buf_tt-chk-discnt.doc-code = tt-chk-doc.doc-code
        and buf_tt-chk-discnt.record-type = 4
        and buf_tt-chk-discnt.discnt-id = v-discnt-id
        and buf_tt-chk-discnt.line-num = v-line-num 
        no-error.
  if available buf_tt-chk-discnt then do:
    message
    "В данном чеке уже есть строка начисления бонуса с таким номером внешней транзакции"
    view-as alert-box error .
    undo, return error.
  end.
end.

if integer(entry(1, discnt-option)) = integer({&discnt-sub-total})
and v-line-num = 0 then do:
  message "Нельзя начислять бонус на подитог сразу после шапки чека"
  view-as alert-box ERROR.
  return error.
end.


find last tt-chk-discnt where
                   tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
          tt-chk-discnt.record-type = 4 no-error.
assign
var-discnt-id = if avail tt-chk-discnt
                      then tt-chk-discnt.discnt-id
                      else 0

.

find first last-tt-chk-gds where
             last-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
             last-tt-chk-gds.line-num = v-line-num no-error.

if not avail last-tt-chk-gds then do:
    message "В чеке нет строчки с номером" v-line-num
    view-as alert-box ERROR.
    return error.
end.
create tt-chk-discnt.
assign
tt-chk-discnt.doc-code = tt-chk-doc.doc-code
tt-chk-discnt.line-num = v-line-num
tt-chk-discnt.record-type = 4
tt-chk-discnt.discnt-id = v-discnt-id
tt-chk-discnt.line-type = integer(entry(1, discnt-option))
tt-chk-discnt.pass-discnt = integer({&discnt-p-manual})
tt-chk-discnt.value-type = integer(entry(2, discnt-option))
tt-chk-discnt.discnt-type = v-discnt-type
tt-chk-discnt.src-d-card = v-src-d-card
tt-chk-discnt.d-card = v-src-d-card
tt-chk-discnt.kateg = v-kateg
tt-chk-discnt.discnt-value-abs = 0
tt-chk-discnt.discnt-value-pcnt  = 0
tt-chk-discnt.object-line-num = tt-chk-discnt.line-num
var-discnt-id = var-discnt-id + 1
.
create locked_chk-discnt.
buffer-copy tt-chk-discnt to locked_chk-discnt.


discnt-option = "":U.
{&OPEN-QUERY-BR-discnt}
    find first loc_tt-chk-discnt WHERE
               loc_tt-chk-discnt.doc-code = tt-chk-doc.doc-code
           AND loc_tt-chk-discnt.discnt-id = v-discnt-id
           AND loc_tt-chk-discnt.record-type = 4 NO-LOCK NO-ERROR.
    IF avail loc_tt-chk-discnt then do:
      reposition br-discnt to recid recid(loc_tt-chk-discnt).
    end.
  apply "entry" to br-discnt in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-adddiscnt Dialog-Frame 
PROCEDURE proc-b-adddiscnt :
define variable var-line-num as character no-undo.
define variable v-wro-code as integer no-undo .

define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not actn#log_bonus then do:
  message "Отсутствует право: Редактирование бонусов, скидок и ДК в чеках"
  view-as alert-box.
  return.
end. 
if v-br-discnt-current-type = 0 then do:
  if available tt-chk-discnt THEN DO:
     RUN proc-leave-discnt-abs in THIS-PROCEDURE (input (if tt-chk-discnt.value-type = integer({&discnt-v-abs})
                                                        then integer({&discnt-v-abs})
                                                        else integer({&discnt-v-pcnt}))).

  END.
end.
if not br-discnt:visible in frame {&frame-name}
OR v-br-discnt-current-type = 4
then do:
    ASSIGN
    v-br-discnt-current-type = 0.
    hide br-gds in frame {&frame-name}.
    display br-discnt with frame {&frame-name}.
    ASSIGN
    b-addgds:label = "Товары"
    b-addbonus:LABEL = "Бонусы"
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = NO
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = NO
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = NO
    v-br-discnt-current-type = 0
    .
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-discnt :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .

    {&OPEN-QUERY-BR-discnt}
     if par-mode = {&add-def} then do:
        assign
        b-adddiscnt:POPUP-MENU IN FRAME {&frame-name} = menu MENU-B-adddiscnt:handle
        b-adddiscnt:MENU-MOUSE = 1
        b-adddiscnt:label = "Добавить скидку"
        b-addbonus:popup-menu = ?
        .
    end.
    if par-mode = {&lookup} or par-mode = "susp-type" then do:
      ENABLE
      b-addgds
      b-addbonus
      with frame {&frame-name}.
      DISABLE
      b-adddiscnt
      with frame {&frame-name}.
      b-addbonus:popup-menu = ?.
    end.
    return.
end.
if not par-mode = {&add-def} then return.
/*run proc-save-doc No-ERROR.             */
/*if error-status:error then return error.*/
if discnt-option = "":U then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.

if tt-chk-doc.src-d-pcnt <> 0 then do:
  if lookup({&discnt-sub-total}, discnt-option) > 0 then do:
    message
    "В данном чеке будут одновременно выставлены:" SKIp
    "% скидка на товары клиента и абсолютная скидка на итог" skip
    "По правилам разбора чека до тех пор, пока в чеке есть абсолютная скидка на итог,"
    "% скидка на товары будет иметь только информационное значение " skip
    "и не будет применяться к товарам чека"
    view-as alert-box WARNING.
  end.
end.

run gbl/d-prompt.w (
    ('title=':u + "Введите номер строки, после которой была начислена скидка" + '\':u
  + 'text1=':u + "Номер строки" + '\':u
  + 'format=' + ">9" + '\':u
  + 'type=int\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=4\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u
  + 'readonly=no\':u)

  ,input-output var-line-num
  ).
if return-value = 'false':u then do:
  return error.
end.

if integer(entry(1, discnt-option)) = integer({&discnt-sub-total})
and integer(var-line-num) = 0 then do:
  message "Нельзя начислять скидку на подитог сразу после шапки чека"
  view-as alert-box ERROR.
  return error.
end.


find last tt-chk-discnt where
                   tt-chk-discnt.doc-code = tt-chk-doc.doc-code and
          tt-chk-discnt.record-type = 0 no-error.
assign
var-discnt-id = if avail tt-chk-discnt
                      then tt-chk-discnt.discnt-id
                      else 0

.


find first last-tt-chk-gds where
             last-tt-chk-gds.doc-code = tt-chk-doc.doc-code and
             last-tt-chk-gds.line-num = integer(var-line-num) no-error.

if not avail last-tt-chk-gds then do:
    message "В чеке нет строчки с номером" var-line-num
    view-as alert-box ERROR.
    return error.
end.
create tt-chk-discnt.
assign
tt-chk-discnt.doc-code = tt-chk-doc.doc-code
tt-chk-discnt.line-num = integer(var-line-num)
tt-chk-discnt.record-type = 0
tt-chk-discnt.discnt-id = var-discnt-id + 1
tt-chk-discnt.line-type = integer(entry(1, discnt-option))
tt-chk-discnt.pass-discnt = integer({&discnt-p-manual})
tt-chk-discnt.value-type = integer(entry(2, discnt-option))
tt-chk-discnt.discnt-type = integer({&discnt-t-unknown})
tt-chk-discnt.d-card = "":U
tt-chk-discnt.discnt-value-abs = 0
tt-chk-discnt.discnt-value-pcnt  = 0
tt-chk-discnt.object-line-num = (if tt-chk-discnt.line-type = integer({&discnt-gds})
                                 then  tt-chk-discnt.line-num
                                 else 0)
var-discnt-id = var-discnt-id + 1
.
if tt-chk-discnt.line-type = integer({&discnt-sub-total})  then do:
  assign
  v-is-sub-d = yes
  .
end.
create locked_chk-discnt.
buffer-copy tt-chk-discnt to locked_chk-discnt.


discnt-option = "":U.
{&OPEN-QUERY-BR-discnt}
    find first loc_tt-chk-discnt WHERE
               loc_tt-chk-discnt.doc-code = tt-chk-doc.doc-code
           AND loc_tt-chk-discnt.discnt-value-abs = 0
           AND loc_tt-chk-discnt.record-type = 0
    NO-LOCK NO-ERROR.
    IF avail loc_tt-chk-discnt then do:
      reposition br-discnt to recid recid(loc_tt-chk-discnt).
    end.
  apply "entry" to br-discnt in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-addgds Dialog-Frame 
PROCEDURE proc-b-addgds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varrid-list as character no-undo.
define variable ii as integer no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define variable v-wro-code as integer no-undo .
define variable v-mark as character no-undo .
define variable v-ok as logical no-undo .
define variable v-b-code like ub.bar-code.b-code no-undo .
define buffer lng_chk-gds for ub.chk-gds.
define buffer loc_tt-chk-gds for tt-chk-gds.
define buffer loc_bar-code for ub.bar-code.
define buffer loc_goods for ub.goods.

if not br-gds:visible in frame {&frame-name}
then do:

    hide br-discnt in frame {&frame-name}.
    display
    br-gds with frame {&frame-name}.

    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse br-gds :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse BR-pay :handle
      ) .
    run diasize_restore-current-size in this-procedure .

    assign
    b-adddiscnt:POPUP-MENU IN FRAME {&frame-name} = ?
    b-addbonus:POPUP-MENU IN FRAME {&frame-name} = ?
    b-addgds:label = if par-mode = {&add-def} then "Добавить товар" else b-addgds:label
    b-adddiscnt:label = "Скидки"
    b-addbonus:LABEL = "Бонусы"
    .
    if par-mode = {&lookup} or par-mode = "susp-type" then do:
      ENABLE
      b-adddiscnt
      b-addbonus
      with frame {&frame-name}.
      DISABLE
      b-addgds
      with frame {&frame-name}.
    end.


    {&OPEN-QUERY-BR-gds}
    return.
end.
if not par-mode = {&add-def} then return.
/*run proc-save-doc No-ERROR.             */
/*if error-status:error then return error.*/
varrid-list = "" .
run ref/gds-ref.p (
                 input parparentproc
                ,input "b-sel,b-mark"
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input tt-chk-doc.obj-type
                ,input tt-chk-doc.obj-code
                ,input ?
              , output varrid-list ).
if varrid-list = "" then return error.
ii = 1.
FIND LAST lng_chk-gds No-LOCK WHERE
          lng_chk-gds.doc-code = TT-CHK-doc.doc-code
          USE-INDEX ln NO-ERROR.
 if avail lng_chk-gds then lng = lng_chk-gds.line-num.
 else lng = 0.
 _ii:
 DO WHILE (ii <= num-entries(varrid-list) )
 on error undo _ii, next _ii
 :
      FIND FIRST loc_goods WHERE
                 recid( loc_goods ) = integer( entry(ii,varrid-list) ) NO-LOCK .
      FIND FIRST ub.gds-prt WHERE
                 ub.gds-prt.upper-code = loc_goods.prt-root NO-LOCK .
      FIND FIRST loc_bar-code WHERE
                 loc_bar-code.node-code = ub.gds-prt.node-code AND
                loc_bar-code.gds-code = loc_goods.gds-code AND
                loc_bar-code.in-code = "" AND
                loc_bar-code.part-code = ""  AND
                loc_bar-code.unit-cli = loc_goods.unit-base NO-LOCK .
      run get-price1 in this-procedure ( input loc_goods.gds-code, input loc_bar-code.node-code) No-ERROR.
      if error-status:error then return no-apply.
      assign
      lng = lng + 1
      .
      CASE tt-chk-doc.chk-type:
        when INTEGER({&rcpt-return-write-off}) then do:
          v-wro-code = INTEGER({&wro-cancell-all}).
        end.
        when INTEGER({&rcpt-write-off})  then do:
          v-wro-code = INTEGER({&wro-without-payment}).
        end.
        when INTEGER({&rcpt-tech-refuell})  then do:
          v-wro-code = INTEGER({&wro-r-tech-refuell}).
        end.
      END CASE.
      create tt-chk-gds.
      assign
      tt-chk-gds.doc-code = tt-chk-doc.doc-code
      tt-chk-gds.line-num = lng
      tt-chk-gds.src-code = string(loc_bar-code.b-code)
      tt-chk-gds.src-price = ( if gp-price-sale <> ? then gp-price-sale else 0)
      tt-chk-gds.src-discnt = 0
      tt-chk-gds.src-qnty = 0
      tt-chk-gds.src-sum = 0
      tt-chk-gds.price-base = 0
      tt-chk-gds.doc-qnty = 0
      tt-chk-gds.discnt = 0
      tt-chk-gds.sum-base = 0
      tt-chk-gds.is-error = no
      tt-chk-gds.b-code = loc_bar-code.b-code
      tt-chk-gds.pass-gds = integer({&gds-manual})
      tt-chk-gds.write-off-code = v-wro-code
      tt-chk-gds.nozzle-code = 0
      tt-chk-gds.src-pl-code = 0
      tt-chk-gds.pl-code = 0
      tt-chk-gds.density = 0
      tt-chk-gds.pump = 0
      tt-chk-gds.loc1 = '':U
      .

    { gbl/pftxvalg.i loc_goods.gds-code {&vat-tax-code} ? v-host-code p-obj-type p-obj-code tt-chk-gds.VAT-pc no-error }
    
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(tt-chk-doc.obj-type, tt-chk-doc.obj-code).
      RUN gds-attr-value (
                          INPUT loc_goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-gds-attr-value,
                          OUTPUT v-gds-attr-type
                          ).
      if v-gds-attr-value > ""
      and EDOParSec:GetIsMarkingForType(v-gds-attr-value)
      then do : /* нужна марка */
        run str/enter-mark.w (input loc_goods.gds-code,
                              output v-mark,
                              output v-ok,
                              output v-b-code) .
        if v-ok
        then do :
          find first buf_marking-chk exclusive-lock where buf_marking-chk.doc-code = tt-chk-gds.doc-code
                                                      and buf_marking-chk.line-num = tt-chk-gds.line-num
                                                      and buf_marking-chk.mark     = v-mark
                                                      no-error .
          if not available buf_marking-chk
          then do :                                            
            create buf_marking-chk .
            assign 
              buf_marking-chk.doc-code = tt-chk-gds.doc-code
              buf_marking-chk.line-num = tt-chk-gds.line-num
              buf_marking-chk.mark     = v-mark
            .
          end .
          assign
            buf_marking-chk.date-modify = today
            buf_marking-chk.time-modify = time
          . 
          assign
            tt-chk-gds.src-qnty = 1
            tt-chk-gds.doc-qnty = 1
            tt-chk-gds.b-code = v-b-code 
            tt-chk-gds.src-code = string(v-b-code)
          .
          for first ub.marking no-lock where ub.marking.mark = buf_marking-chk.mark :
            assign buf_marking-chk.unit = ub.marking.unit-ext .
            if buf_marking-chk.unit = "LEVEL1"
            then
            assign
              tt-chk-gds.doc-qnty = tt-chk-gds.src-qnty * 10
              tt-chk-gds.src-price  = tt-chk-gds.src-price * 10
              tt-chk-gds.src-sum    = tt-chk-gds.src-sum * 10
              tt-chk-gds.src-discnt = tt-chk-gds.src-discnt * 10
            .
          end .
          enable 
          B_mark
          with frame {&frame-name} .
        end .
        else do :
          delete tt-chk-gds .
          ii = ii + 1 .
          undo _ii, next _ii.
        end .
      end .
      
      create locked_chk-gds.
      buffer-copy tt-chk-gds to locked_chk-gds.
      create tt-gds-info.
      buffer-copy tt-chk-gds to tt-gds-info
      assign
      tt-gds-info.artic = loc_goods.artic
      tt-gds-info.gds-name = loc_goods.gds-name
      tt-gds-info.prt-name = "-":U
      ii = ii + 1
      varline-rid = recid(tt-chk-gds)
      .
      {&OPEN-QUERY-BR-gds}
      REPOSITION Br-gds to recid varline-rid no-error.
      if error-status:error then do:
        undo _ii, next _ii.
      end.
      if get-chkc_context.doc-prt and gds-prt.node-name <> {&empty-scale} then do:
          run setprts in this-procedure ( input recid(loc_goods), input recid(loc_bar-code), input loc_goods.prt-root, input yes) no-error.
          if error-status:error then do:
            undo _ii, next _ii.
          end.
      end.

    end.
    {&OPEN-QUERY-BR-gds}
    find first loc_tt-chk-gds WHERE
               loc_tt-chk-gds.doc-code = tt-chk-doc.doc-code AND
               loc_tt-chk-gds.src-qnty = 0 NO-LOCK NO-ERROR.
    IF avail loc_tt-chk-gds then do:
      reposition br-gds to recid recid(loc_tt-chk-gds).
    end.
apply "entry" to br-gds in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-addpay Dialog-Frame 
PROCEDURE proc-b-addpay :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varrid-list as character no-undo.
DEFine VARiable trid as recid no-undo.
define variable base-rate_   as decimal                 no-undo .
define variable base-scale_  like ub.chk-doc.cash-scale no-undo .

define buffer lnp_chk-pay for ub.chk-pay.
define buffer loc_tt-chk-pay for tt-chk-pay.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.

if par-mode = {&add-def} then do:
run proc-save-doc in this-procedure No-ERROR.
if error-status:error then return error.
end .

varrid-list = "" .
run ref/cashpays.w (
              input parparentproc
             ,input "b-sel"
             ,input {&all}
             ,input get-chkc_context.host-code
             ,input locked_chk-doc.obj-type
             ,input locked_chk-doc.obj-code
             ,output varrid-list ) .
if varrid-list = "" then return error.
FIND LAST lnp_chk-pay No-LOCK WHERE
          lnp_chk-pay.doc-code = TT-chk-doc.doc-code
          USE-INDEX ln NO-ERROR.
if avail lnp_chk-pay then lnp = lnp_chk-pay.line-num.
else lnp = 0.
FIND FIRST loc_cash-pay WHERE
                        recid( loc_cash-pay ) = integer( varrid-list ) NO-LOCK .
run find-bank-curs in this-procedure (
                                      input tt-chk-doc.chk-date
                                      ,input loc_cash-pay.curr-code
                                      ,output bank-rate_
                                      ,output bank-scale_
                                      ) no-error.
run find-curs in this-procedure (
                                input tt-chk-doc.chk-date
                                ,input tt-chk-doc.chk-time
                                ,input loc_cash-pay.curr-code
                                ,output cash-rate_
                                ,output cash-scale_
                                ,output exch-date_
                                ,output exch-time_
                                ) no-error.
if get-chkc_context.r-b = {&r-b-base} and
get-chkc_context.base-code <> 0 then do:
  run find-curs in this-procedure (
                                  input tt-chk-doc.chk-date
                                  ,input tt-chk-doc.chk-time
                                  ,input get-chkc_context.base-code
                                  ,output base-rate_
                                  ,output base-scale_
                                  ,output exch-date_
                                  ,output exch-time_
                                  ) no-error.
end.
else do:
  assign
  base-rate_ = 1
  base-scale_ = 1
  .
end.
create tt-chk-pay.
assign
lnp = lnp + 1
tt-chk-pay.doc-code = tt-chk-doc.doc-code
tt-chk-pay.line-num = lnp
tt-chk-pay.chk-date = tt-chk-doc.chk-date
tt-chk-pay.pay-code = loc_cash-pay.cdpay-code
tt-chk-pay.curr-code = loc_cash-pay.curr-code
tt-chk-pay.obj-code = tt-chk-doc.obj-code
tt-chk-pay.obj-type = tt-chk-doc.obj-type
tt-chk-pay.bank-rate = bank-rate_
tt-chk-pay.bank-scale = bank-scale_
tt-chk-pay.cash-rate = cash-rate_ / cash-scale_ * (if get-chkc_context.r-b = {&r-b-base} and get-chkc_context.base-code <> 0 then base-rate_ / base-scale_ else 1)
tt-chk-pay.tot-base = 0
tt-chk-pay.tot-sum = 0
tt-chk-pay.tot-rubl = 0
tt-chk-pay.pay-card = "":U
tt-chk-pay.is-error = no
tt-chk-pay.pass-pay = integer({&pay-manual})
.
create tt-pay-info.
buffer-copy tt-chk-pay to tt-pay-info
assign
tt-pay-info.exch-rate = cash-rate_
tt-pay-info.exch-scale = cash-scale_
tt-pay-info.exch-date = exch-date_
tt-pay-info.exch-time = exch-time_
tt-pay-info.exch-time-str = string(exch-time_, "hh:mm:ss")
tt-pay-info.calc-rate = cash-rate_ / cash-scale_
.


CREATE locked_chk-pay .
buffer-copy tt-chk-pay to locked_chk-pay.
  trid = recid(tt-chk-pay).
{&OPEN-QUERY-br-pay}
REPOSITION br-pay to recid trid NO-ERROR.
glog = BR-pay:SET-REPOSITIONED-ROW(1, "CONDITIONAL") in frame {&frame-name}.
apply "entry" to br-pay in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-slip Dialog-Frame 
PROCEDURE proc-b-slip :
define input parameter p-slip-type as character no-undo .
  
  define buffer buf_chk-doc-attr for ub.chk-doc-attr .
  define buffer buf_chk-pay-attr for ub.chk-pay-attr .
  
  find first buf_chk-doc-attr no-lock where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code
                                        and buf_chk-doc-attr.attr-code = "CheckId"
                                        no-error .
  if not available buf_chk-doc-attr 
  or (available buf_chk-doc-attr and trim(buf_chk-doc-attr.attr-value) = "")
  then do :
    message "Слипы не найдены!" view-as alert-box .
    return .
  end .
    
  if p-slip-type = "chk"
  then do :
    
    run str/chk-slips.w (input v-cntxt-db-num-obj,
                         input trim(buf_chk-doc-attr.attr-value),
                         input ?)
                        .                               
  end .
  
  if p-slip-type = "pay"
  then do :
    find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.doc-code = tt-chk-doc.doc-code
                                          and buf_chk-pay-attr.attr-code = "RRN"
                                          and buf_chk-pay-attr.line-num = tt-chk-pay.line-num
                                          no-error .
    if not available buf_chk-pay-attr 
    or (available buf_chk-pay-attr and trim(buf_chk-pay-attr.attr-value) = "")
    then do :
      find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.doc-code = tt-chk-doc.doc-code
                                            and buf_chk-pay-attr.attr-code = "CPDOC"
                                            and buf_chk-pay-attr.line-num = tt-chk-pay.line-num
                                            no-error .
      if not available buf_chk-pay-attr 
      or (available buf_chk-pay-attr and trim(buf_chk-pay-attr.attr-value) = "")
      then do :                                      
        message "В чеке нет атрибута 'RRN/CPDOC' для поиска слипов по оплате!" view-as alert-box error .
        return .
      end .
    end .
    
    run str/chk-slips.w (input v-cntxt-db-num-obj,
                         input trim(buf_chk-doc-attr.attr-value),
                         input trim(buf_chk-pay-attr.attr-value))
                        .
  end .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg-gds Dialog-Frame 
PROCEDURE proc-chg-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varrid-list as character no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define buffer lng_chk-gds for ub.chk-gds.
define buffer loc_chk-gds for ub.chk-gds.
define buffer loc_bar-code for ub.bar-code.
define buffer loc_goods for ub.goods.
if not (par-mode = {&update} or par-mode = {&add-def}) then return.

if par-mode = {&add-def} then do:
  run proc-save-doc in this-procedure No-ERROR.
  if error-status:error then return error.
end.

if not available tt-gds-info
then do :
  find first tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num .
end .

varrid-list = "" .
run ref/gds-ref.p (
                input parparentproc
              ,input "b-sel,b-mark"
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input tt-chk-doc.obj-type
              ,input tt-chk-doc.obj-code
              ,input ?
             , output varrid-list ).
 
if varrid-list <> "" then do:
  ii = 1.
      FIND FIRST loc_goods WHERE
                 recid( loc_goods ) = integer( entry(1,varrid-list) ) NO-LOCK .
      FIND FIRST ub.gds-prt WHERE
                 ub.gds-prt.upper-code = loc_goods.prt-root NO-LOCK .
      FIND FIRST loc_bar-code WHERE
                 loc_bar-code.node-code = ub.gds-prt.node-code AND
                loc_bar-code.gds-code = loc_goods.gds-code AND
                loc_bar-code.in-code = "" AND
                loc_bar-code.part-code = ""  AND
                loc_bar-code.unit-cli = loc_goods.unit-base NO-LOCK .
      run get-price1 in this-procedure ( input loc_goods.gds-code, input loc_bar-code.node-code) No-ERROR.
      if error-status:error then undo, return error.
      RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
      if error-status:error then undo, return error.
      assign
      tt-chk-gds.doc-code = tt-chk-doc.doc-code
      tt-chk-gds.src-code = string(loc_bar-code.b-code)
      tt-chk-gds.is-error = no
      tt-chk-gds.src-code = string(loc_bar-code.b-code)
      tt-chk-gds.b-code = loc_bar-code.b-code
      tt-gds-info.artic = loc_goods.artic
      tt-gds-info.gds-code = loc_goods.gds-code
      tt-gds-info.gds-name = loc_goods.gds-name
      tt-gds-info.prt-name = "-":U.
       .
      if get-chkc_context.doc-prt and gds-prt.node-name <> {&empty-scale} then do:
          run setprts in this-procedure ( input recid(loc_goods), input recid(loc_bar-code), input loc_goods.prt-root, input no).
      end.
    end.
    display
    tt-chk-gds.b-code
    tt-chk-gds.src-code
    tt-gds-info.artic
    tt-gds-info.gds-name
    tt-gds-info.prt-name
    tt-chk-gds.is-error
    with browse br-gds.
  apply "entry" to br-gds in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg-pay Dialog-Frame 
PROCEDURE proc-chg-pay :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-reference as logical no-undo.
define input parameter p-old-curr-code like ub.chk-pay.curr-code no-undo.
define variable varrid-list as character no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define buffer loc_cash-pay for ub.cash-pay.
define buffer loc_currency for ub.currency.
if not (par-mode = {&update} or par-mode = {&add-def}) then return.

if par-mode = {&add-def} then do:
  run proc-save-doc in this-procedure No-ERROR.
  if error-status:error then return error.
end .

varrid-list = "" .
if p-reference then do:
    run ref/cashpays.w (
                input parparentproc
              ,input "b-sel"
              ,input {&all}
              ,input get-chkc_context.host-code
              ,input locked_chk-doc.obj-type
              ,input locked_chk-doc.obj-code
              ,output varrid-list ) .
    if varrid-list = "":U then return error.
    FIND FIRST loc_cash-pay WHERE
                           recid( loc_cash-pay ) = integer( varrid-list ) NO-LOCK .
  assign
    tt-chk-pay.pay-code = loc_cash-pay.cdpay-code
    tt-chk-pay.curr-code = loc_cash-pay.curr-code
    .
end.
    run find-bank-curs in this-procedure (
                                          input tt-chk-doc.chk-date
                                          ,input (if p-reference
                                                  then loc_cash-pay.curr-code
                                                  else tt-chk-pay.curr-code)
                                          ,output bank-rate_
                                          ,output bank-scale_
                                          ) no-error.
    run find-curs in this-procedure (
                                     input tt-chk-doc.chk-date
                                    ,input tt-chk-doc.chk-time
                                    ,input (if p-reference
                                            then loc_cash-pay.curr-code
                                            else tt-chk-pay.curr-code)
                                    ,output cash-rate_
                                    ,output cash-scale_
                                    ,output exch-date_
                                    ,output exch-time_
                                    ) no-error.
    assign
    tt-chk-pay.bank-rate = (if p-old-curr-code <> tt-chk-pay.curr-code
                                          then bank-rate_
                                          else tt-chk-pay.bank-rate)
    tt-chk-pay.bank-scale = (if p-old-curr-code <> tt-chk-pay.curr-code
                                        then bank-scale_
                                        else tt-chk-pay.bank-scale)
    tt-chk-pay.cash-rate = if not get-chkc_context.cas-curs AND p-old-curr-code <> tt-chk-pay.curr-code
                                        then cash-rate_ / cash-scale_
                                       else tt-chk-pay.cash-rate
    tt-chk-pay.is-error = no
    tt-pay-info.calc-rate = cash-rate_ / cash-scale_
    tt-pay-info.exch-rate = cash-rate_
    tt-pay-info.exch-scale = cash-scale_
    tt-pay-info.exch-date = exch-date_
    tt-pay-info.exch-time = exch-time_
    tt-pay-info.exch-time-str = string(exch-time_, "hh:mm:ss")
   .
run get-pay-sums in this-procedure ( buffer tt-chk-pay).
display
tt-chk-pay.pay-code
tt-chk-pay.curr-code
tt-chk-pay.is-error
tt-chk-pay.bank-rate
tt-chk-pay.bank-scale
tt-chk-pay.cash-rate
tt-chk-pay.tot-rubl
tt-chk-pay.tot-base
get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name
varcurr-name
tt-pay-info.calc-rate
tt-pay-info.exch-rate
tt-pay-info.exch-scale
tt-pay-info.exch-date
tt-pay-info.exch-time-str
with browse br-pay.
apply "entry" to br-pay in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-leave-discnt-abs Dialog-Frame 
PROCEDURE proc-leave-discnt-abs :
define input parameter p-type as integer no-undo .
DEFINE VARIABLE v-old-discnt-value like ub.chk-discnt.discnt-value-abs  no-undo .
if par-mode = {&lookup} or par-mode = "susp-type" then return.
IF NOT AVAILABLE TT-CHK-DISCNT THEN RETURN NO-APPLY.
if p-type = integer({&discnt-v-abs}) then do:
  assign
  v-old-discnt-value = tt-chk-discnt.discnt-value-abs
  .
end.
else do:
  assign
  v-old-discnt-value = tt-chk-discnt.discnt-value-pcnt
  .
end.
if dflt-cd <> {&cd-type-ncr-gm} and
  dflt-cd <> {&cd-type-ncr-as-r} and
  tt-chk-discnt.object-line-num <> 0
  and tt-chk-discnt.record-type = 0
  then do:
  message
  "Нельзя менять значение скидки для скидки по товарной строке"
  view-as alert-box .
  assign  
  tt-chk-discnt.real-value-abs:screen-value in browse br-discnt = string(v-old-discnt-value)
  .
  if p-type = integer({&discnt-v-abs}) then  do:
    assign
    tt-chk-discnt.real-value-abs:screen-value in browse br-discnt = string(v-old-discnt-value)
    .
  end.
  else do:
    assign
    tt-chk-discnt.real-value-pcnt:screen-value in browse br-discnt = string(v-old-discnt-value)
    .
  end.
end.
else do:
  find first locked_chk-discnt where
        locked_chk-discnt.doc-code = tt-chk-doc.doc-code
    AND locked_chk-discnt.line-num = tt-chk-discnt.line-num
    AND locked_chk-discnt.object-line-num = tt-chk-discnt.object-line-num
    AND locked_chk-discnt.discnt-id = tt-chk-discnt.discnt-id.
  IF LOCKED_chk-discnt.value-type = INTEGER({&discnt-v-abs}) or LOCKED_chk-discnt.value-type = INTEGER({&discnt-v-bonus})  THEN DO:
      assign
      locked_chk-discnt.discnt-value-abs = decimal(tt-chk-discnt.real-value-abs:screen-value in browse br-discnt    )
      tt-chk-discnt.discnt-value-abs = locked_chk-discnt.discnt-value-abs
      .
  END.
  ELSE DO:
      assign
      locked_chk-discnt.discnt-value-pcnt = decimal(tt-chk-discnt.real-value-pcnt:screen-value in browse br-discnt    )
      tt-chk-discnt.discnt-value-pcnt = locked_chk-discnt.discnt-value-pcnt
      locked_chk-discnt.discnt-value-abs = tt-chk-discnt.discnt-value-pcnt * tt-chk-discnt.object-sum / 100
      tt-chk-discnt.discnt-value-abs = locked_chk-discnt.discnt-value-abs
      .
  END.
  if tt-chk-discnt.record-type < 4 then do:
    run get-discnt in this-procedure(
                                            input tt-chk-discnt.line-num
                                            ,input tt-chk-discnt.value-type
                                          ,input tt-chk-discnt.line-type
                                          ,input tt-chk-discnt.discnt-type
                                            ).
    run get-sums in this-procedure no-error.
    display
    tt-chk-doc.tot-doc
    tt-chk-doc.discnt
    tt-chk-doc.netto
    tt-chk-doc.src-tot-doc
    with frame {&frame-name}.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-blocked-marks Dialog-Frame 
PROCEDURE add-blocked-marks :
  define buffer buf_marking for ub.marking .
  define buffer lng_chk-gds for chk-gds.
  define buffer loc_tt-chk-gds for tt-chk-gds.
  define buffer loc_bar-code for bar-code.
  define buffer loc_goods for goods.
  define buffer buf_prod-bc for ub.prod-bc .
  
  define variable v-GTIN as character no-undo .
  define variable v-wro-code as integer no-undo .
  define variable v-mark as character no-undo .
  DEFINE VARIABLE varline-rid as recid  no-undo.
  define variable ii as integer no-undo .
  
  FIND LAST lng_chk-gds No-LOCK WHERE
            lng_chk-gds.doc-code = TT-CHK-doc.doc-code
            USE-INDEX ln NO-ERROR.
  if avail lng_chk-gds then lng = lng_chk-gds.line-num.
  else lng = 0.
  
  
  ii = 0 .
  _ii:
  for each buf_marking no-lock where buf_marking.obj-type = v-cntxt-obj-type
                                 and buf_marking.obj-code = v-cntxt-obj-code
                                 and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
/*                                 and (   buf_marking.sts = objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB    */
/*                                      or buf_marking.sts = objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB*/
/*                                      or buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB      */
/*                                      or buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB  */
/*                                      )                                                                       */
                                 :
    FIND FIRST loc_goods WHERE
               loc_goods.gds-code = buf_marking.gds-code NO-LOCK .
    FIND FIRST gds-prt WHERE
               gds-prt.upper-code = loc_goods.prt-root NO-LOCK .
               
    v-GTIN = getGtinByDM(buf_marking.mark) .           
    for each loc_bar-code no-lock WHERE
              loc_bar-code.gds-code = loc_goods.gds-code AND
              loc_bar-code.in-code = "" AND
              loc_bar-code.part-code = "",
    each buf_prod-bc no-lock where buf_prod-bc.b-code = loc_bar-code.b-code
                               and buf_prod-bc.b-str  = v-GTIN :
      leave .                      
    end . 
    if not available loc_bar-code
    then do :
      FIND FIRST loc_bar-code WHERE
               loc_bar-code.node-code = gds-prt.node-code AND
              loc_bar-code.gds-code = loc_goods.gds-code AND
              loc_bar-code.in-code = "" AND
              loc_bar-code.part-code = ""  AND
              loc_bar-code.unit-cli = loc_goods.unit-base no-lock .
    end .          
    run get-price1 in this-procedure ( input loc_goods.gds-code, input loc_bar-code.node-code) No-ERROR.
    if error-status:error then return no-apply.
    assign
    lng = lng + 1
    .
    CASE tt-chk-doc.chk-type:
      when INTEGER({&rcpt-return-write-off}) then do:
        v-wro-code = INTEGER({&wro-cancell-all}).
      end.
      when INTEGER({&rcpt-write-off})  then do:
        v-wro-code = INTEGER({&wro-without-payment}).
      end.
      when INTEGER({&rcpt-tech-refuell})  then do:
        v-wro-code = INTEGER({&wro-r-tech-refuell}).
      end.
    END CASE.
    create tt-chk-gds.
    assign
    tt-chk-gds.doc-code = tt-chk-doc.doc-code
    tt-chk-gds.line-num = lng
    tt-chk-gds.src-code = string(loc_bar-code.b-code)
    tt-chk-gds.src-price = ( if gp-price-sale <> ? then gp-price-sale else 0)
    tt-chk-gds.src-discnt = 0
    tt-chk-gds.src-qnty = 0
    tt-chk-gds.src-sum = 0
    tt-chk-gds.price-base = 0
    tt-chk-gds.doc-qnty = 0
    tt-chk-gds.discnt = 0
    tt-chk-gds.sum-base = 0
    tt-chk-gds.is-error = no
    tt-chk-gds.b-code = loc_bar-code.b-code
    tt-chk-gds.pass-gds = integer({&gds-manual})
    tt-chk-gds.write-off-code = v-wro-code
    tt-chk-gds.nozzle-code = 0
    tt-chk-gds.src-pl-code = 0
    tt-chk-gds.pl-code = 0
    tt-chk-gds.density = 0
    tt-chk-gds.pump = 0
    tt-chk-gds.loc1 = '':U
    .
    
    v-mark = buf_marking.mark .
    find first buf_marking-chk exclusive-lock where buf_marking-chk.doc-code = tt-chk-gds.doc-code
                                                and buf_marking-chk.line-num = tt-chk-gds.line-num
                                                and buf_marking-chk.mark     = v-mark
                                                no-error .
    if not available buf_marking-chk
    then do :                                            
      create buf_marking-chk .
      assign 
        buf_marking-chk.doc-code = tt-chk-gds.doc-code
        buf_marking-chk.line-num = tt-chk-gds.line-num
        buf_marking-chk.mark     = v-mark
      .
    end .
    assign
      buf_marking-chk.date-modify = today
      buf_marking-chk.time-modify = time
    . 
    assign
      tt-chk-gds.src-qnty = 1
      tt-chk-gds.doc-qnty = 1
    .
    
    assign buf_marking-chk.unit = buf_marking.unit-ext .
    if buf_marking-chk.unit = "LEVEL1"
    then
    assign
      tt-chk-gds.doc-qnty = tt-chk-gds.src-qnty * 10
      tt-chk-gds.src-price  = tt-chk-gds.src-price * 10
      tt-chk-gds.src-sum    = tt-chk-gds.src-sum * 10
      tt-chk-gds.src-discnt = tt-chk-gds.src-discnt * 10
    .
    
    create locked_chk-gds.
    buffer-copy tt-chk-gds to locked_chk-gds.
    create tt-gds-info.
    buffer-copy tt-chk-gds to tt-gds-info
    assign
    tt-gds-info.artic = loc_goods.artic
    tt-gds-info.gds-name = loc_goods.gds-name
    tt-gds-info.prt-name = "-":U
    ii = ii + 1
    varline-rid = recid(tt-chk-gds)
    .
    
    {&OPEN-QUERY-BR-gds}
    REPOSITION Br-gds to recid varline-rid no-error.
    if error-status:error then do:
      undo _ii, next _ii.
    end.
    if shop.doc-prt and gds-prt.node-name <> {&empty-scale} then do:
        run setprts in this-procedure ( input recid(loc_goods), input recid(loc_bar-code), input loc_goods.prt-root, input yes) no-error.
        if error-status:error then do:
          undo _ii, next _ii.
        end.
    end.                               
  end .
  
  if ii = 0
  then do :
    message "Нет заблокированных марок на объекте" view-as alert-box .
  end .
  else do :
    message "Добавлены товары по " string(ii) " заблокированным маркам" view-as alert-box .
    enable 
    B_mark
    with frame {&frame-name} .
  end .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-pcnt-discnt Dialog-Frame 
PROCEDURE proc-pcnt-discnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-src-d-pcnt like ub.chk-doc.src-d-pcnt no-undo.
if v-is-sub-d then do:
  message
  "В данном чеке будут одновременно выставлены:" SKIp
  "% скидка на товары клиента и абсолютная скидка на итог" skip
  "По правилам разбора чека до тех пор, пока в чеке есть абсолютная скидка на итог,"
  "% скидка на товары будет иметь только информационное значение " skip
  "и не будет применяться к товарам чека"
  view-as alert-box WARNING.
  return.
end.
run get-sums in this-procedure no-error .
display
tt-chk-doc.tot-doc
tt-chk-doc.discnt
tt-chk-doc.netto
tt-chk-doc.src-tot-doc
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-doc Dialog-Frame 
PROCEDURE proc-save-doc :
DEFINE VARIABLE var-rid as recid no-undo.
define variable var-chk-type as character no-undo.
DEFINE VARIABLE varline-rid as recid no-undo .
define variable v-is-petrol-check            as logical                 no-undo .
define buffer buf-tt-chk-gds for tt-chk-gds .
define buffer buf-tt-gds-info for tt-gds-info .
define buffer loc-chk-gds for ub.chk-gds.
define buffer buf-tt-chk-pay for tt-chk-pay .
define buffer loc-chk-pay for ub.chk-pay.
define buffer buf-tt-chk-discnt for tt-chk-discnt .
define buffer loc-chk-discnt for ub.chk-discnt.
define buffer buf_c-chk-doc for ub.c-chk-doc.


assign
frame {&frame-name} fhour
frame {&frame-name} fmin
frame {&frame-name} fsec
frame {&frame-name} cb-chk-type
.
/*пишем в историю*/
if par-mode = {&update} then
run trg/chk-doch.p (
                 buffer locked_chk-doc
              , input no
              , input no /*p-add*/
              , input no /*p-del*/
              , input-output v-chip-num
              , output v-is-update).
assign
tt-chk-doc.cashier
tt-chk-doc.chk-date
tt-chk-doc.chk-num
tt-chk-doc.chk-time = fhour * 3600 + fmin * 60 + fsec
tt-chk-doc.chk-type = if cb-chk-type = {&rcpt-sale}
                      or
                      cb-chk-type = {&rcpt-return}
                      or
                      cb-chk-type = {&rcpt-return-write-off}
                      or
                      cb-chk-type = {&rcpt-write-off}
                      or
                      cb-chk-type = {&rcpt-trans-cancell}
                      or
                      cb-chk-type = {&rcpt-overflow}
                      or
                      cb-chk-type = {&rcpt-trans-transfer}
                      or
                      cb-chk-type = {&rcpt-tech-refuell}
                      or
                      cb-chk-type = {&rcpt-annu}
                      or
                      cb-chk-type = {&rcpt-inventory}
                      or
                      cb-chk-type = {&rcpt-Z-REP}
                      or
                      cb-chk-type = {&rcpt-unlock-trans}
                      or
                      cb-chk-type = {&rcpt-ord-sale-closed}
                      or
                      cb-chk-type = {&rcpt-ord-return-closed}
                      or
                      cb-chk-type = {&rcpt-ord-sale}
                      or
                      cb-chk-type = {&rcpt-ord-return}
                      or
                      cb-chk-type = {&rcpt-ord-annu}
                      then integer(cb-chk-type)
                      else 0
tt-chk-doc.obj-code
tt-chk-doc.pay-desk
tt-chk-doc.ps
tt-chk-doc.src-shift-date
tt-chk-doc.shift-num
tt-chk-doc.shift-name
tt-chk-doc.d-card
tt-chk-doc.src-d-card
tt-chk-doc.src-d-pcnt
tt-chk-doc.sales-man
tt-chk-doc.cash-rate
tt-chk-doc.cash-scale
tt-chk-doc.z-number
tt-chk-doc.doc-num
tt-chk-doc.doc-num2
.
buffer-copy tt-chk-doc
except
d-pcnt
tot-doc
netto
discnt
sub-discnt
office
correct
cashier-psn-code
salesman-psn-code
out-code
to locked_chk-doc
assign
locked_chk-doc.correct = yes
.
display tt-chk-doc.ps
with frame {&frame-name} .
for each buf-tt-chk-gds no-lock where
         buf-tt-chk-gds.doc-code = tt-chk-doc.doc-code,
    first loc-chk-gds where
          loc-chk-gds.doc-code = buf-tt-chk-gds.doc-code
     AND  loc-chk-gds.line-num = buf-tt-chk-gds.line-num,
    first buf-tt-gds-info no-lock where
          buf-tt-gds-info.line-num = buf-tt-chk-gds.line-num:
  assign
  loc-chk-gds.src-code = buf-tt-chk-gds.src-code
  loc-chk-gds.b-code = buf-tt-chk-gds.b-code
  loc-chk-gds.src-qnty = buf-tt-chk-gds.src-qnty
  loc-chk-gds.src-price = buf-tt-chk-gds.src-price
  loc-chk-gds.src-discnt = buf-tt-chk-gds.src-discnt
  loc-chk-gds.src-sum = buf-tt-chk-gds.src-sum
  loc-chk-gds.road-tax = buf-tt-chk-gds.road-tax
  loc-chk-gds.pump = buf-tt-chk-gds.pump
  loc-chk-gds.nozzle-code  = buf-tt-chk-gds.nozzle-code
  loc-chk-gds.loc1 = buf-tt-chk-gds.loc1
  loc-chk-gds.pl-code = buf-tt-chk-gds.pl-code
  loc-chk-gds.src-pl-code = buf-tt-chk-gds.src-pl-code
  loc-chk-gds.sales-man = buf-tt-chk-gds.sales-man
  loc-chk-gds.depart-id = (if buf-tt-chk-gds.depart-id = ? then 0 else buf-tt-chk-gds.depart-id )
  loc-chk-gds.depart-code = (if buf-tt-chk-gds.depart-code = ? then 0 else buf-tt-chk-gds.depart-code)
  loc-chk-gds.depart-type = {&shop}
  loc-chk-gds.doc-qnty = (if par-mode = {&add-def} then buf-tt-chk-gds.doc-qnty else loc-chk-gds.doc-qnty)
  loc-chk-gds.write-off-code = (if par-mode = {&add-def} then buf-tt-chk-gds.write-off-code else loc-chk-gds.write-off-code)

  .
END.
for each buf-tt-chk-pay no-lock where
         buf-tt-chk-pay.doc-code = tt-chk-doc.doc-code,
    first loc-chk-pay where
          loc-chk-pay.doc-code = buf-tt-chk-pay.doc-code
     AND  loc-chk-pay.line-num = buf-tt-chk-pay.line-num:
  assign
  loc-chk-pay.pay-code = buf-tt-chk-pay.pay-code
  loc-chk-pay.curr-code = buf-tt-chk-pay.curr-code
  loc-chk-pay.pay-card = buf-tt-chk-pay.pay-card
  loc-chk-pay.cash-rate = buf-tt-chk-pay.cash-rate
  loc-chk-pay.tot-sum = buf-tt-chk-pay.tot-sum
  .
END.
for each buf-tt-chk-discnt no-lock where
         buf-tt-chk-discnt.doc-code = tt-chk-doc.doc-code
     and buf-tt-chk-discnt.record-type = 4,
    first loc-chk-discnt where
          loc-chk-discnt.doc-code = buf-tt-chk-discnt.doc-code
      and loc-chk-discnt.record-type = buf-tt-chk-discnt.record-type
      AND loc-chk-discnt.line-num = buf-tt-chk-discnt.line-num
      and loc-chk-discnt.object-line-num = buf-tt-chk-discnt.object-line-num
      and loc-chk-discnt.discnt-id = buf-tt-chk-discnt.discnt-id
      :
  buffer-copy buf-tt-chk-discnt to loc-chk-discnt.
  if buf-tt-chk-discnt.line-type = integer({&discnt-gds}) then do:
    find first loc-chk-gds no-lock where
              loc-chk-gds.doc-code = buf-tt-chk-discnt.doc-code
          and loc-chk-gds.line-num = buf-tt-chk-discnt.object-line-num no-error.
    if not available loc-chk-gds then do:
      delete buf-tt-chk-discnt.
      delete loc-chk-discnt.
    end.
    else do:
        /*
        assign
        buf-tt-chk-discnt.discnt-value-pcnt = (decimal(entry(1, loc-chk-gds.src-code, {&delim-par} ))) / 100 
        loc-chk-discnt.discnt-value-pcnt =  buf-tt-chk-discnt.discnt-value-pcnt / 100
        .
        */
    end.
  end.
END.

if lookup(string(tt-chk-doc.chk-type) , {&petrol-receipt-codes}) > 0 then do:
  v-is-petrol-check = yes.
end.
if v-is-petrol-check then do:
  assign
  tt-chk-doc.tot-doc = 0
  tt-chk-doc.discnt = 0
  tt-chk-doc.netto = 0
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame 
PROCEDURE reposition-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-chk-doc-recid as recid no-undo .
define buffer buf_chk-doc for ub.chk-doc .

do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-chk-doc-recid
      ).

    if v-new-chk-doc-recid <> ?
    then do:
      find first buf_chk-doc no-lock
        where recid(buf_chk-doc) = v-new-chk-doc-recid
        no-error .
      if lookup(string(buf_chk-doc.chk-type), {&wth-receipt-codes}) > 0 then do:
      end.
      assign
      p-doc-rec = v-new-chk-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список чеков не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-goods Dialog-Frame 
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
/* перемещение на первую, последнюю, предыдущую, следующую */
define buffer buf_goods for ub.goods.
case p-direction :
  when "first":U
  then do:
    get first br-gds.
  end.
  when "last":U
  then do:
    get last br-gds.
  end.
  when "prev":U
  then do:
    get prev br-gds.
    if not available tt-gds-info then do:
      message
      "Это первый товар чека"
      view-as alert-box.
    end.
  end.
  when "next":U
  then do:
    get next br-gds.
    if not available tt-gds-info then do:
      message
      "Это последний товар чека"
      view-as alert-box.
    end.
  end.
end case . /* p-direction */
if available tt-gds-info then do:
  IF tt-gds-info.gds-code = 0 THEN DO:
    MESSAGE
    "Нет товара для данной строки чека!"
    VIEW-AS ALERT-BOX WARNING.
  END.
  ELSE DO:
    find first buf_goods no-lock where
        buf_goods.gds-code = tt-gds-info.gds-code no-error.
    if available tt-gds-info then do:
      assign
      p-recid = recid(buf_goods)
      .
    end.
  END.
end.
run reposition-query-br-gds in this-procedure
  (input recid(tt-chk-gds)
  ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query-br-gds Dialog-Frame 
PROCEDURE reposition-query-br-gds :
define input parameter p-recid as recid no-undo .

if p-recid <> ?
then do:
  reposition br-gds to recid p-recid no-error.
end.

do with frame {&frame-name}:
  apply "entry":u to browse {&browse-name} .
  apply "VALUE-CHANGED":u to browse {&browse-name} .
end. /* do with frame */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-cd Dialog-Frame 
PROCEDURE sel-cd :
define variable ri-list as character no-undo .
define buffer loc_cash-desk  for ub.cash-desk.
run ref/cashlist.w
    (input  parparentproc
    ,input  'b-sel':U
    ,input  {&g___object}
    ,input  get-chkc_context.db-num
    ,input  get-chkc_context.host-code
    ,input  {&shop}
    ,input  shop-code
    ,input  ?
    ,output ri-list
    ) no-error.
if ri-list = '' then do:
  undo, return error .
end.
FIND FIRST loc_cash-desk No-LOCK WHERE
          recid(loc_cash-desk) = integer(ri-list) no-error.
if not available loc_cash-desk then do:
  undo, return error .
end.
if loc_cash-desk.autonomy = integer({&cd-manager}) then do:
  message
  "Нельзя создать чек для КАССОВОГО МЕНЕДЖЕРА!"
  view-as alert-box error.
  undo, return error .
end.
if loc_cash-desk.pos-type <> dflt-cd then do:
  message
  substitute("На &1&2 установлен тип кассы по умолчанию - &3&4" +
            "Вы уверены, что хотите создать чек для кассы с типом &5?"
            , {&shop}
            , shop-code
            , dflt-cd
            , {&new-line}
            , loc_cash-desk.pos-type)
  view-as alert-box question buttons yes-no update glog.
  if not glog then undo, return error .
end.
find first buf_cash-desk no-lock where
          recid(buf_cash-desk) = recid(loc_cash-desk).
get-chkc_context.pos-type = buf_cash-desk.pos-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setparts Dialog-Frame 
PROCEDURE setparts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-gds-code as integer   no-undo .
define input  parameter parunit-cli like ub.bar-code.unit-cli no-undo.
define input  parameter parnode-code like ub.bar-code.node-code no-undo.

define variable v-prt-rec as recid no-undo .
DEFine BUFFER loc-goods for ub.goods.
define buffer loc-parts for ub.parts.
define buffer loc-bar-code for ub.bar-code.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_archive_cost':U
  {&cntxt-object}
  v-host-code
  tt-chk-doc.obj-type
  tt-chk-doc.obj-code
  0
  0
  0
  true
  glog
}

if NOT glog then
return ERROR .
run str/parts-l.w
  (input parparentproc
  ,input tt-chk-doc.obj-type                /* v-obj-type   */
  ,input tt-chk-doc.obj-code                /* v-obj-code   */
  ,input p-gds-code                 /* p-gds-code   */
  ,input ""                        /* p-doc-code   */
  ,input {&lookup}                 /* p-edit-mode  */
  ,input {&parts-l_parts-rest}     /* p-r-parts    */
  ,input {&parts-l_object-current} /* p-one-all    */
  ,input {&parts-l_call-choose}    /* p-call-point */
  ,output v-prt-rec                  /* part-recid   */
  ) .
if v-prt-rec <> ? then do:
  FIND FIRST loc-parts No-LOCK WHERE recid(loc-parts) = v-prt-rec No-ERROR.
  IF NOT avail loc-parts then return no-apply.

  FIND FIRST loc-goods No-LOCK where
              loc-goods.artic = loc-parts.artic AND
              loc-goods.prod-type = loc-parts.prod-type AND
              loc-goods.prod-code = loc-parts.prod-code No-ERROR.

  FIND FIRST loc-bar-code NO-LOCK WHERE
            loc-bar-code.gds-code = loc-goods.gds-code AND
            loc-bar-code.unit-cli = parunit-cli AND
            loc-bar-code.in-code   = loc-parts.in-code AND
            loc-bar-code.part-code = loc-parts.part-code AND
            loc-bar-code.node-code  = parnode-code NO-ERROR.
  IF AVAIl loc-bar-code then do:
      assign
      tt-chk-gds.b-code = loc-bar-code.b-code
      tt-chk-gds.src-code = (if par-mode = {&update}
                             then tt-chk-gds.src-code else
                             string(loc-bar-code.b-code))
      .
      DISPLAY
      tt-chk-gds.b-code
      tt-chk-gds.src-code
      tt-chk-gds.is-error
      with browse br-gds.
  end.
  else do:
    return error.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setprts Dialog-Frame 
PROCEDURE setprts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF INPUT PARAMETER rcg as recid no-undo.
DEF INPUT PARAMETER rcb as recid no-undo.
DEF INPUT PARAMETER p-goods-prt-root like ub.goods.prt-root no-undo.
DEF INPUT PARAMETER ff as logical no-undo.
DEFINE VARIABLE varline-rid as recid no-undo.
DEFINE buffer loc_bar-code for ub.bar-code.
DEFINE buffer root_bar-code for ub.bar-code.
define buffer loc_gds-prt for ub.gds-prt.

    define buffer buf_goods  for ub.goods .
    find first buf_goods no-lock
      where recid(buf_goods) = rcg
      .
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (input parparentproc
      ,input  buf_goods.gds-code /* p-gds-code      */
      ,input  {&choose}          /* p-mode          */
      ,input  tt-chk-doc.obj-type         /* p-obj-type      */
      ,input  tt-chk-doc.obj-code         /* p-obj-code      */
      ,input  ""                 /* p-doc-code      */
      ,input  ""                 /* p-search-code   */
      ,output v-sel-node-code    /* p-sel-node-code */
      ) .

    if v-sel-node-code <> ? then do:
        FIND FIRST loc_gds-prt No-LOCK
          WHERE loc_gds-prt.node-code = v-sel-node-code
          No-ERROR.
        IF NOT avail loc_gds-prt then return error.
        if NOT loc_gds-prt.is-term then do:
          message
          "Признак" loc_gds-prt.f-name "нетерминальный" skip
          view-as alert-box Warning.
        end.

        FIND FIRST loc_bar-code No-LOCK WHERE
                   recid(loc_bar-code) = rcb No-ERROR.
        FIND FIRST root_bar-code No-LOCK WHERE
                    root_bar-code.gds-code = loc_bar-code.gds-code AND
                    root_bar-code.unit-cli = loc_bar-code.unit-cli AND
                    root_bar-code.in-code   = "" AND
                    root_bar-code.part-code = "" AND
                    root_bar-code.node-code  = loc_gds-prt.node-code NO-ERROR.
        IF AVAIl root_bar-code then do:
          assign
          tt-chk-gds.src-code = (if par-mode = {&update}
                                 then tt-chk-gds.src-code
                                 else string(root_bar-code.b-code))
          tt-chk-gds.b-code = root_bar-code.b-code.
          DISPLAY
          tt-chk-gds.b-code
          tt-chk-gds.src-code
          tt-chk-gds.is-error
          with browse br-gds.
          run get-price1 in this-procedure ( input loc_bar-code.gds-code, input root_bar-code.node-code) No-ERROR.
          if error-status:error then undo, return error.
          RUN check-ch-bc-ck in this-procedure ( input gp-price-sale, input tt-chk-gds.price-base) no-error.
          if error-status:error then undo, return error.

          if gp-price-sale <> ? then do:
            if ff then do:
              assign
              tt-chk-gds.src-price = gp-price-sale
              .
              DISPLAY
              tt-chk-gds.src-price
              with browse br-gds.
            end.
          end.
          assign
          tt-gds-info.prt-name = ( if loc_gds-prt.node-name = {&empty-scale}
                                  then "-":U
                                  else ( if loc_gds-prt.upper-code = p-goods-prt-root
                                          then "-------------------":U
                                          else loc_gds-prt.f-name ) )
          .
          display
            tt-gds-info.prt-name
            tt-chk-gds.is-error
            with browse br-gds.
        end.
        else do:
          message
            "Отсутствует бар-код для признака" loc_gds-prt.f-name
            view-as alert-box WARNING.
          return.
        end.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file Dialog-Frame 
PROCEDURE write-log-and-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-tab-position   as integer      no-undo.
DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.

message
p-log-string
view-as alert-box error .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-good Dialog-Frame 
FUNCTION get-good RETURNS CHARACTER
  (
    input  parb-code as integer
  , output pargds-code AS integer
  , output pargds-name as character
  , output parprt-name as character
  , output paris-error as logical) :
define variable var-artic like ub.goods.artic No-undo.
run get-good-proc in this-procedure (
input parb-code
,output pargds-code
,output pargds-name
,output parprt-name
,output paris-error
,output var-artic) no-error.
RETURN var-artic.  /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-pay Dialog-Frame 
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable varpay-name like ub.cash-pay.obj-name no-undo.

run get-pay-proc in this-procedure (
input  parpay-code
,input  parcurr-code
,output parcurr-name
,output varpay-name ) no-error.



RETURN varpay-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-salesman Dialog-Frame 
FUNCTION get-salesman RETURNS CHARACTER
  ( input  p-salesman as integer, input p-date as date, output p-psn-code as integer) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-psn-code like ub.clients.obj-code No-undo.
define buffer buf_clients for ub.clients.
if p-salesman = 0
or p-salesman = ? then DO:
  P-PSN-CODE = 0.
  return '':U.
END.
assign
v-psn-code = gbclcode-is-this-db-role  ( input {&role-seller}
                                          ,input get-chkc_context.db-num
                                          ,input p-salesman - (if dflt-cd = {&cd-type-magia-XML}
                                                              then 10000
                                                              else 0)
                                          ,input p-date
                                                              )
no-error .

if v-psn-code = ? then do:
  p-psn-code = 0.
  return {&question-mark}.
end.
else do:
  assign
  p-psn-code = v-psn-code
  .
  find first buf_clients no-lock where
            buf_clients.obj-type = {&prs}
        AND buf_clients.obj-code = p-psn-code no-error .
  if not available buf_clients then return {&question-mark}.
  return buf_Clients.obj-name.
end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-templ-rl-name Dialog-Frame 
FUNCTION get-templ-rl-name RETURNS CHARACTER
  ( INPUT p-templ-rl-root AS INTEGER ) :
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
if p-templ-rl-root = 0 then return "".
FIND FIRST buf_dis-rule NO-LOCK WHERE buf_dis-rule.rule-num = p-templ-rl-root NO-ERROR.
IF AVAILABLE buf_dis-rule THEN RETURN buf_dis-rule.des.
RETURN "!!!Неизвестный шаблон скидки".   /* Function return value. */

END FUNCTION.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsName Dialog-Frame 
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  define variable v-gds-name as character no-undo .
  define buffer buf_goods for ub.goods .
  
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

