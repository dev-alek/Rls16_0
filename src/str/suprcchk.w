&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_cashier FOR ub.clients.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_sales-man FOR ub.clients.
DEFINE BUFFER cashier FOR ub.person.
DEFINE BUFFER gds_bar-code FOR ub.bar-code.
DEFINE BUFFER gds_goods FOR ub.goods.
DEFINE BUFFER gds_parts FOR ub.parts.
DEFINE BUFFER gds_prod-bc FOR ub.prod-bc.
DEFINE BUFFER locked_c-chk-discnt FOR ub.c-chk-discnt.
DEFINE BUFFER locked_c-chk-doc FOR ub.c-chk-doc.
DEFINE BUFFER locked_c-chk-doc-attr FOR ub.c-chk-doc-attr.
DEFINE BUFFER locked_c-chk-gds FOR ub.c-chk-gds.
DEFINE BUFFER locked_c-chk-pay FOR ub.c-chk-pay.
DEFINE BUFFER pay_cash-pay FOR ub.cash-pay.
DEFINE BUFFER pay_currency FOR ub.currency.
DEFINE BUFFER sales-man FOR ub.person.
DEFINE NEW SHARED TEMP-TABLE tt-chk-discnt NO-UNDO LIKE ub.chk-discnt.
DEFINE BUFFER buf_chk-doc-attr FOR ub.chk-doc-attr .
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE ub.chk-doc
       field real-subdiscnt as decimal.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE ub.chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-gds NO-UNDO LIKE ub.chk-gds.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE ub.chk-pay.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа Истории ручного создания/редактирования чека

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
define input-output parameter p-next-prev as character no-undo .

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
{ gbl/thbj-def.i }
{ ref/extclass.i }
{ str/is-corr.i }
DEFINE VARIABLE var-mode as character no-undo.
/*настройка - разрешено ли менять на бар-код с другой текущей прейскурантной ценой*/
DEFINE VARIABLE ch-bc-ck as logical no-undo init no.
DEFINE VARIABLE is-prt as logical no-undo init no.
/*настройка - откуда брать номер магазина при чтении чеков из спула - из спула- yes или
по умолчанию номер магазина в котором принимается почта*/
define variable hnum as logical no-undo init no.
/*юти переменные просто должны быть определены*/
define variable ibmgroup as logical no-undo init yes.
define variable L as int no-undo initial 0. /*счетчик принятых чеков*/
define variable v-is-top as logical no-undo . /*есть ли бензоколонки*/
define variable v-is-catering as logical no-undo .
define variable v-src-d-card  like ub.chk-doc.src-d-card no-undo .
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
DEFINE VARIABLE new-opened as logical no-undo init yes.
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

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .

define variable p-view-log as logical no-undo.
{ str/get-chkc.i def  update }
{ gbl/gbclcode.i }
{ str/paycardv.i }


&SCOP discnt-v-code string(tt-chk-discnt.value-type)
&scop discnt-target-code string(tt-chk-discnt.line-type)
&scop discnt-type-code string(tt-chk-discnt.discnt-type)
DEFINE NEW SHARED TEMp-TABLE tt-gds-info no-undo
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
line-num
.

DEFINE NEW SHARED TEMp-TABLE tt-pay-info no-undo
FIELD line-num like ub.chk-pay.line-num
field calc-rate like ub.curr-shop.exch-rate
field exch-date like ub.curr-shop.exch-date
field exch-time like ub.curr-shop.exch-time
field exch-time-str as character
field exch-rate like ub.curr-shop.exch-rate
field exch-scale like ub.curr-shop.exch-scale
index pi is unique PRIMARY
line-num
.

&scop  fatal-errs message ~
    "В этом чеке имеются фатальные ошибки, которые возможно исправить не удастся!!!!!" skip ~
    "В этом случае постарайтесь пересоздать его руками" skip ~
    "или обратитесь к администратору Вашей системы" ~
    view-as alert-box WARNING.

&GLOBAL-DEFINE wro-code STRING(if tt-chk-gds.write-off-code = ? then 0 else tt-chk-gds.write-off-code)

DEFINE VARIABLE v-br-discnt-current-type AS INTEGER NO-UNDO.

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
&Scoped-define FIELDS-IN-QUERY-BR-discnt tt-chk-discnt.line-num {&discnt-v-name} tt-chk-discnt.object-line-num {&discnt-target-name} (IF tt-chk-discnt.record-type < 4 THEN {&discnt-type-name} ELSE STRING(tt-chk-discnt.discnt-type)) tt-chk-discnt.discnt-value-abs tt-chk-discnt.src-d-card tt-chk-discnt.discnt-id tt-chk-discnt.kateg
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-discnt tt-chk-discnt.discnt-value-abs
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-discnt tt-chk-discnt
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-discnt tt-chk-discnt
&Scoped-define SELF-NAME BR-discnt
&Scoped-define OPEN-QUERY-BR-discnt CASE par-mode:   WHEN {&add-def}   OR   WHEN {&UPDATE} THEN DO:     OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code     AND tt-chk-discnt.record-type = v-br-discnt-current-type     by tt-chk-discnt.line-num.   END.   WHEN {&LOOKUP} THEN DO:         OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt              WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND                                tt-chk-discnt.record-type = v-br-discnt-current-type no-LOCK            by tt-chk-discnt.line-num.   END. END CASE.
&Scoped-define TABLES-IN-QUERY-BR-discnt tt-chk-discnt
&Scoped-define FIRST-TABLE-IN-QUERY-BR-discnt tt-chk-discnt


/* Definitions for BROWSE BR-gds                                        */
&Scoped-define FIELDS-IN-QUERY-BR-gds tt-chk-gds.line-num tt-chk-gds.src-code tt-chk-gds.is-error tt-chk-gds.b-code tt-gds-info.artic tt-gds-info.gds-name tt-chk-gds.src-qnty tt-chk-gds.src-price tt-chk-gds.src-discnt tt-gds-info.src-d-pcnt tt-gds-info.src-price-netto tt-gds-info.src-sum-netto tt-gds-info.prt-name tt-chk-gds.doc-qnty tt-chk-gds.price-base tt-chk-gds.discnt tt-gds-info.d-pcnt tt-gds-info.price-netto tt-gds-info.sum-netto tt-chk-gds.pump tt-chk-gds.nozzle-code tt-chk-gds.loc1 {&wro-name} tt-chk-gds.depart-id tt-chk-gds.depart-code tt-chk-gds.sales-man tt-gds-info.salesman-name tt-chk-gds.road-tax tt-chk-gds.price-service
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds tt-chk-gds.src-code ~
tt-chk-gds.b-code ~
tt-chk-gds.doc-qnty ~
tt-chk-gds.pump ~
tt-chk-gds.nozzle-code ~
tt-chk-gds.loc1 ~
tt-chk-gds.depart-id ~
tt-chk-gds.depart-code ~
tt-chk-gds.src-qnty ~
tt-chk-gds.src-price ~
tt-chk-gds.src-discnt ~
tt-chk-gds.road-tax ~
tt-chk-gds.price-service
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gds tt-chk-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gds tt-chk-gds
&Scoped-define SELF-NAME BR-gds
&Scoped-define OPEN-QUERY-BR-gds            IF dflt-cd = {&cd-type-magia-xml} THEN         OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds NO-LOCK             WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code , ~
                     FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num             by abs(tt-chk-gds.line-num).          ELSE             OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-gds NO-LOCK                 WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code , ~
                         FIRST tt-gds-info where tt-gds-info.line-num = tt-chk-gds.line-num                 by tt-chk-gds.line-num.
&Scoped-define TABLES-IN-QUERY-BR-gds tt-chk-gds tt-gds-info
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds tt-chk-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-gds tt-gds-info


/* Definitions for BROWSE BR-pay                                        */
&Scoped-define FIELDS-IN-QUERY-BR-pay tt-chk-pay.line-num tt-chk-pay.pay-code tt-chk-pay.curr-code tt-chk-pay.is-error get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) @ v-pay-name varcurr-name tt-chk-pay.tot-sum tt-chk-pay.tot-base tt-chk-pay.tot-rubl tt-chk-pay.pay-card tt-pay-info.calc-rate tt-pay-info.exch-date tt-pay-info.exch-time-str tt-pay-info.exch-rate tt-pay-info.exch-scale tt-chk-pay.cash-rate tt-chk-pay.bank-rate tt-chk-pay.bank-scale
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pay tt-chk-pay.pay-code ~
tt-chk-pay.curr-code ~
tt-chk-pay.tot-sum ~
tt-chk-pay.pay-card ~
tt-chk-pay.cash-rate
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-pay tt-chk-pay
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-pay tt-chk-pay
&Scoped-define SELF-NAME BR-pay
&Scoped-define QUERY-STRING-BR-pay FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code , ~
           first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num
&Scoped-define OPEN-QUERY-BR-pay OPEN QUERY {&SELF-NAME} FOR EACH  tt-chk-pay          WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code , ~
           first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num          by tt-chk-pay.line-num.
&Scoped-define TABLES-IN-QUERY-BR-pay tt-chk-pay tt-pay-info
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pay tt-chk-pay
&Scoped-define SECOND-TABLE-IN-QUERY-BR-pay tt-pay-info


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-chk-doc.chk-date ~
tt-chk-doc.cashier tt-chk-doc.sales-man tt-chk-doc.obj-code ~
tt-chk-doc.d-card tt-chk-doc.pay-desk tt-chk-doc.chk-num ~
tt-chk-doc.z-number tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date ~
tt-chk-doc.cash-scale tt-chk-doc.cash-rate tt-chk-doc.shift-name ~
tt-chk-doc.shift-num tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc ~
tt-chk-doc.discnt tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-chk-doc.chk-date ~
tt-chk-doc.cashier tt-chk-doc.sales-man tt-chk-doc.obj-code ~
tt-chk-doc.d-card tt-chk-doc.pay-desk tt-chk-doc.chk-num ~
tt-chk-doc.z-number tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date ~
tt-chk-doc.cash-scale tt-chk-doc.cash-rate tt-chk-doc.shift-name ~
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
&Scoped-Define ENABLED-FIELDS tt-chk-doc.chk-date tt-chk-doc.cashier ~
tt-chk-doc.sales-man tt-chk-doc.obj-code tt-chk-doc.d-card ~
tt-chk-doc.pay-desk tt-chk-doc.chk-num tt-chk-doc.z-number ~
tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date tt-chk-doc.cash-scale ~
tt-chk-doc.cash-rate tt-chk-doc.shift-name tt-chk-doc.shift-num ~
tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc tt-chk-doc.discnt ~
tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date
&Scoped-define ENABLED-TABLES tt-chk-doc
&Scoped-define FIRST-ENABLED-TABLE tt-chk-doc
&Scoped-Define ENABLED-OBJECTS B-quit B-prev B-next Cb-chk-type B-help ~
RECT-1 fhour fmin fsec v-corr-osnov v-corr-type v-doc-osnov corr-date ~
f-num-corr f-cause-corr B-bonus B-discnt B-gds BR-discnt BR-gds BR-pay ~
F-cashier F-salesman f-cli-name 
&Scoped-Define DISPLAYED-FIELDS tt-chk-doc.chk-date tt-chk-doc.cashier ~
tt-chk-doc.sales-man tt-chk-doc.obj-code tt-chk-doc.d-card ~
tt-chk-doc.pay-desk tt-chk-doc.chk-num tt-chk-doc.z-number ~
tt-chk-doc.src-d-pcnt tt-chk-doc.src-shift-date tt-chk-doc.cash-scale ~
tt-chk-doc.cash-rate tt-chk-doc.shift-name tt-chk-doc.shift-num ~
tt-chk-doc.src-d-card tt-chk-doc.PS tt-chk-doc.tot-doc tt-chk-doc.discnt ~
tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt ~
tt-chk-doc.shift-date
&Scoped-define DISPLAYED-TABLES tt-chk-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-chk-doc
&Scoped-Define DISPLAYED-OBJECTS Cb-chk-type fhour fmin fsec v-corr-osnov ~
v-corr-type v-doc-osnov corr-date f-num-corr f-cause-corr F-cashier ~
F-salesman f-cli-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-good Dialog-Frame
FUNCTION get-good RETURNS CHARACTER
  ( input  parb-code as integer, output pargds-name as character, output parprt-name as character, output paris-error as logical)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-pay Dialog-Frame
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-salesman Dialog-Frame
FUNCTION get-salesman RETURNS CHARACTER
  ( input  p-salesman as integer, input p-date as date, output p-psn-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-bonus
     LABEL "Бонусы"
     SIZE 14 BY 1.

DEFINE BUTTON B-discnt
     LABEL "Скидки"
     SIZE 14 BY 1.

DEFINE BUTTON B-gds
     LABEL "Товары"
     SIZE 15 BY 1.

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 27 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE corr-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-cashier AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 19.63 BY .67 NO-UNDO.

DEFINE VARIABLE f-cause-corr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Описание корректировки" 
     VIEW-AS FILL-IN 
     SIZE 64 BY 1 TOOLTIP "Краткое описание причины проведения корректировки" NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Клиент" 
      VIEW-AS TEXT 
     SIZE 20.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-corr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер" 
     VIEW-AS FILL-IN 
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE F-salesman AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 19.63 BY .67 NO-UNDO.

DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 2.88 BY 1 NO-UNDO.

DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 2.88 BY 1 NO-UNDO.

DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 2.88 BY 1 NO-UNDO.

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
      {&discnt-v-name} COLUMN-LABEL "Тип знач"
tt-chk-discnt.object-line-num COLUMN-LABEL "N строки товара!-объекта"
{&discnt-target-name} COLUMN-LABEL "Объект скидки/бонуса" FORMAT "X(20)"
(IF tt-chk-discnt.record-type < 4
       THEN {&discnt-type-name}
       ELSE STRING(tt-chk-discnt.discnt-type)) COLUMN-LABEL "Тип скидки/!код схемы" FORMAT "X(20)"
tt-chk-discnt.discnt-value-abs COLUMN-LABEL "Знач. скидки/!бонуса"
tt-chk-discnt.src-d-card COLUMN-LABEL "№ Карты!для начисления"
tt-chk-discnt.discnt-id COLUMN-LABEL "ID транзакц" FORMAT ">>>>>>>>9"
tt-chk-discnt.kateg COLUMN-LABEL "Код !валюты" FORMAT "->>>9"
  ENABLE
  tt-chk-discnt.discnt-value-abs
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.67.

DEFINE BROWSE BR-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds Dialog-Frame _FREEFORM
  QUERY BR-gds SHARE-LOCK NO-WAIT DISPLAY
      tt-chk-gds.line-num COLUMN-LABEL "NN"  FORMAT "->>>>9"
      tt-chk-gds.src-code COLUMN-LABEL "Исходный код" format "X(19)" width 14
      tt-chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/"
      tt-chk-gds.b-code
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
      tt-chk-gds.loc1 COLUMN-LABEL  "Рез." FORMAT ">>9"
      {&wro-name} COLUMN-LABEL "Код спис" FORMAT "X(20)"
      tt-chk-gds.depart-id COLUMN-LABEL "Объект!кухни!в чеке"
      tt-chk-gds.depart-code COLUMN-LABEL "Объект!кухни!в БД"
      tt-chk-gds.sales-man COLUMN-LABEL "Код!продавца"
      tt-gds-info.salesman-name COLUMN-LABEL "Продавец" FORMAT "X(16)"
      tt-chk-gds.road-tax COLUMN-LABEL "Дор. налог/! или тара"
      tt-chk-gds.price-service COLUMN-LABEL "Цена сервиса"
  ENABLE
      tt-chk-gds.src-code
      tt-chk-gds.b-code
      tt-chk-gds.doc-qnty
      tt-chk-gds.pump
      tt-chk-gds.nozzle-code
      tt-chk-gds.loc1
      tt-chk-gds.depart-id
      tt-chk-gds.depart-code
      tt-chk-gds.src-qnty
      tt-chk-gds.src-price
      tt-chk-gds.src-discnt
      tt-chk-gds.road-tax
      tt-chk-gds.price-service
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.67 ROW-HEIGHT-CHARS .67.

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
      tt-chk-pay.pay-card COLUMN-LABEL "Номер платежной!карты"
      tt-pay-info.calc-rate COLUMN-LABEL "Рассчит.курс!вал.пл-жа в БД"
      tt-pay-info.exch-date COLUMN-LABEL "Дата курса!маг-на" format "99/99/9999"
      tt-pay-info.exch-time-str COLUMN-LABEL "Время курса!маг-на" format "X(8)"
      tt-pay-info.exch-rate COLUMn-LABEL "Курс маг-на!вал.пл-жа"
      tt-pay-info.exch-scale COLUMn-LABEL "Масштаб маг-на!вал. пл-жа"
      tt-chk-pay.cash-rate COLUMN-LABEL "Курс вал. пл-жа!/к б.в.кассы"
      tt-chk-pay.bank-rate
      tt-chk-pay.bank-scale
  ENABLE
      tt-chk-pay.pay-code
      tt-chk-pay.curr-code
      tt-chk-pay.tot-sum
      tt-chk-pay.pay-card
      tt-chk-pay.cash-rate
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101 BY 4.21 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 23
     B-next AT ROW 1 COL 27
     Cb-chk-type AT ROW 1 COL 39 COLON-ALIGNED NO-LABEL
     B-help AT ROW 1 COL 95
     tt-chk-doc.chk-date AT ROW 2.08 COL 11.5 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     tt-chk-doc.cashier AT ROW 2.08 COL 33.63 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     fhour AT ROW 3.33 COL 11.5 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.33 COL 14.88 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.33 COL 19 COLON-ALIGNED NO-LABEL
     tt-chk-doc.sales-man AT ROW 3.33 COL 33.63 COLON-ALIGNED
          LABEL "Продавец"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.obj-code AT ROW 4.46 COL 11.5 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN 
          SIZE 6.75 BY 1
     tt-chk-doc.d-card AT ROW 4.46 COL 33.63 COLON-ALIGNED
          LABEL "Диск. карта"
          VIEW-AS FILL-IN 
          SIZE 20.88 BY 1
     tt-chk-doc.pay-desk AT ROW 5.58 COL 11.5 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     v-corr-osnov AT ROW 6.75 COL 11.5 COLON-ALIGNED WIDGET-ID 58
     v-corr-type AT ROW 6.75 COL 80.13 COLON-ALIGNED WIDGET-ID 60
     v-doc-osnov AT ROW 8.75 COL 11.5 COLON-ALIGNED WIDGET-ID 56
     corr-date AT ROW 8.75 COL 55.13 COLON-ALIGNED WIDGET-ID 24
     f-num-corr AT ROW 8.75 COL 100.13 RIGHT-ALIGNED WIDGET-ID 30
     f-cause-corr AT ROW 10.25 COL 100.13 RIGHT-ALIGNED WIDGET-ID 32
     tt-chk-doc.chk-num AT ROW 11.5 COL 11.5 COLON-ALIGNED
          LABEL "N по кассе" FORMAT "->>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 8.38 BY 1
     tt-chk-doc.z-number AT ROW 11.5 COL 34.75 COLON-ALIGNED
          LABEL "Z-отчет"
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1
     tt-chk-doc.src-d-pcnt AT ROW 11.5 COL 63.63 COLON-ALIGNED
          LABEL "Скидка клиен.(%)"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.src-shift-date AT ROW 12.67 COL 11.25 COLON-ALIGNED
          LABEL "&Дата смены" FORMAT "99/99/9999"
          VIEW-AS FILL-IN 
          SIZE 12.75 BY 1
     tt-chk-doc.cash-rate AT ROW 12.67 COL 63.5 COLON-ALIGNED
          LABEL "Курс нац вал."
          VIEW-AS FILL-IN 
          SIZE 19.88 BY 1
     tt-chk-doc.cash-scale AT ROW 12.67 COL 93.13 COLON-ALIGNED
          LABEL "Масштаб"
          VIEW-AS FILL-IN 
          SIZE 6.88 BY 1
     tt-chk-doc.shift-name AT ROW 13.75 COL 11.25 COLON-ALIGNED
          LABEL "№ смены"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-chk-doc.shift-num AT ROW 13.75 COL 20 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN 
          SIZE 4.13 BY 1
     tt-chk-doc.src-d-card AT ROW 13.75 COL 36.25 COLON-ALIGNED
          LABEL "ДК в чеке"
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     B-bonus AT ROW 13.75 COL 59.38
     B-discnt AT ROW 13.75 COL 73.38
     B-gds AT ROW 13.75 COL 87.38
     BR-discnt AT ROW 14.75 COL 1
     BR-gds AT ROW 14.83 COL 1
     BR-pay AT ROW 21.54 COL 1
     tt-chk-doc.PS AT ROW 25.79 COL 1.25 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 100.75 BY 2
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         CANCEL-BUTTON B-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     F-cashier AT ROW 2 COL 42 COLON-ALIGNED NO-LABEL
     tt-chk-doc.tot-doc AT ROW 2.08 COL 76.5 COLON-ALIGNED
          LABEL "Сумма брутто"
           VIEW-AS TEXT 
          SIZE 20 BY 1
     F-salesman AT ROW 3 COL 42 COLON-ALIGNED NO-LABEL
     tt-chk-doc.discnt AT ROW 3.33 COL 76.5 COLON-ALIGNED
          LABEL "Скидка общ."
           VIEW-AS TEXT 
          SIZE 20 BY 1
     tt-chk-doc.sub-discnt AT ROW 4.46 COL 76.5 COLON-ALIGNED
          LABEL "Сумма списаний"
           VIEW-AS TEXT 
          SIZE 20 BY 1
     f-cli-name AT ROW 5.58 COL 33.75 COLON-ALIGNED
     tt-chk-doc.netto AT ROW 5.58 COL 76.5 COLON-ALIGNED
          LABEL "Сумма оплат(нетто)"
           VIEW-AS TEXT 
          SIZE 20 BY 1
     tt-chk-doc.d-pcnt AT ROW 11.5 COL 93.25 COLON-ALIGNED
          LABEL "Скидка итоговая(%)"
           VIEW-AS TEXT 
          SIZE 6.25 BY 1
     tt-chk-doc.shift-date AT ROW 12.67 COL 36.25 COLON-ALIGNED
          LABEL "Дата учета" FORMAT "99/99/9999"
           VIEW-AS TEXT 
          SIZE 10.5 BY 1
          FGCOLOR 12 
     "Основание корректировки" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 7.83 COL 41.13 WIDGET-ID 28
     "Время:" VIEW-AS TEXT
          SIZE 6.5 BY 1 AT ROW 3 COL 11 RIGHT-ALIGNED
     "Тип чека" VIEW-AS TEXT
          SIZE 8.63 BY 1.04 AT ROW 1 COL 31
          FGCOLOR 4 
     RECT-1 AT ROW 8 COL 1.63 WIDGET-ID 26
     SPACE(0.74) SKIP(16.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>"
         CANCEL-BUTTON B-quit.


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
      TABLE: locked_c-chk-discnt B "?" ? ub c-chk-discnt
      TABLE: locked_c-chk-doc B "?" ? ub c-chk-doc
      TABLE: locked_c-chk-doc-attr B "?" ? ub c-chk-doc-attr
      TABLE: locked_c-chk-gds B "?" ? ub c-chk-gds
      TABLE: locked_c-chk-pay B "?" ? ub c-chk-pay
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
/* BROWSE-TAB BR-gds B-gds Dialog-Frame */
/* BROWSE-TAB BR-discnt BR-gds Dialog-Frame */
/* BROWSE-TAB BR-pay BR-discnt Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

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
/* SETTINGS FOR FILL-IN tt-chk-doc.src-d-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.src-d-pcnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.src-shift-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-chk-doc.sub-discnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.tot-doc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.z-number IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TEXT-LITERAL "Время:"
          SIZE 6.5 BY 1 AT ROW 3 COL 11 RIGHT-ALIGNED                   */

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-discnt
/* Query rebuild information for BROWSE BR-discnt
     _START_FREEFORM
CASE par-mode:
  WHEN {&add-def}
  OR
  WHEN {&UPDATE} THEN DO:
    OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code
    AND tt-chk-discnt.record-type = v-br-discnt-current-type
    by tt-chk-discnt.line-num.
  END.
  WHEN {&LOOKUP} THEN DO:
        OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-discnt
             WHERE tt-chk-discnt.doc-code = tt-chk-doc.doc-code AND
                               tt-chk-discnt.record-type = v-br-discnt-current-type no-LOCK
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
     OPEN QUERY {&SELF-NAME} FOR EACH  tt-chk-pay
         WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code ,
    first tt-pay-info no-lock where tt-pay-info.line-num = tt-chk-pay.line-num
         by tt-chk-pay.line-num.
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


&Scoped-define SELF-NAME B-bonus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-bonus Dialog-Frame
ON CHOOSE OF B-bonus IN FRAME Dialog-Frame /* Бонусы */
DO:
  { gbl/stdbtn.i }
  run proc-b-bonus in this-procedure  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-discnt Dialog-Frame
ON CHOOSE OF B-discnt IN FRAME Dialog-Frame /* Скидки */
DO:
  { gbl/stdbtn.i }
  run proc-b-discnt in this-procedure  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Товары */
DO:
{ gbl/stdbtn.i }
  run proc-b-gds in this-procedure  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
{ gbl/stdbtn.i }
    run reposition-c-chk-doc in this-procedure
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
    run reposition-c-chk-doc in this-procedure
  (input 'prev':U
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Выход */
DO:
{ gbl/stdbtn.i }
  p-next-prev = "quit":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-chk-type Dialog-Frame
ON VALUE-CHANGED OF Cb-chk-type IN FRAME Dialog-Frame
DO:
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
    if not ub.shop.is-catering then do:
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
  tt-chk-doc.chk-type = integer(CB-chk-type)
  locked_c-chk-doc.chk-type = integer(CB-chk-type).
  case CB-chk-type:
    when {&rcpt-return-write-off}
    or when {&rcpt-write-off}
    then do:
      ASSIGN
      b-discnt:SENSITIVE IN FRAME {&FRAME-NAME} = YES
      .
    end.
    WHEN  {&rcpt-trans-cancell}
    OR
    WHEN  {&rcpt-trans-transfer}
    OR
    WHEN  {&rcpt-overflow}
    OR
    WHEN  {&rcpt-tech-refuell} 
    OR
    WHEN  {&rcpt-unlock-trans} THEN DO:
         assign
         b-discnt:SENSITIVE IN FRAME {&FRAME-NAME} = NO
         .
    end.
    otherwise do:
        if v-is-catering then
        ASSIGN
        b-discnt:SENSITIVE IN FRAME {&FRAME-NAME} = YES
        .

    END.
  END CASE.

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


&Scoped-define BROWSE-NAME BR-discnt
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i  &browse-name="br-gds" }

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
                  , input ? /*p-parent-handle*/
                  , input buf_bar-code.gds-code
                  , input {&lookup}) no-error .
if error-status:error then return no-apply.
apply "entry" to br-gds in frame {&frame-name}.
return no-apply.
end.

ON value-changed OF br-gds do:
 { gbl/stdbtn.i }
end.



/*найдем номер БД*/
var-mode = par-mode.
p-next-prev = ''.
n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-obj-type <> {&shop} then DO:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова p-obj-type" p-obj-type
      view-as alert-box ERROR.
      return error.
  end.
  if not par-mode = {&lookup} then
  p-next-prev = "QUIT".

  FIND FIRST locked_c-chk-doc NO-LOCK WHERE
              recid(locked_c-chk-doc) = p-doc-rec.
  assign
  shop-type = locked_c-chk-doc.obj-type
  shop-code = locked_c-chk-doc.obj-code
  .
  { str/get-chkc.i run shop-type shop-code }
  RUn get-params in this-procedure ( input shop-type, input shop-code) no-error.
  if error-status:error then return error.
  RUn fill-tables in this-procedure no-error.
  if error-status:error then return error.
  run Myenable in this-procedure .
  /*переставить колонки*/
  br-gds:num-locked-columns = 4.
  if new-opened then do:
    { gbl/mv-clmn.i
    &ext-col = 29
    &frame-name = "{&frame-name}"
    &browse-name = "br-gds"
    &start-column = "1"
    &prev-order-column_1 = "'1,2,3,4,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,20,21,22,23,24,25,26,27,28,29'"
    &prev-order-column-condition_1 = " par-mode = {&lookup} and not v-is-top"
    &prev-order-column_2 = "'1,2,3,4,20,21,22,5,6,13,14,15,16,17,18,19,7,8,9,10,11,12,23,24,25,26,27,28,29'"
    &prev-order-column-condition_2 = " par-mode = {&lookup} and v-is-top"
    &num-group = "4"
    &mem-gr_1 = "1,2,3,4"
    &mem-gr_2 = "5,6"
    &mem-gr_3 = "7,8,9,10,11,12,13"
    &mem-gr_4 = "14,15,16,17,18,19"
    }
    new-opened = no.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY Cb-chk-type fhour fmin fsec v-corr-osnov v-corr-type v-doc-osnov 
          corr-date f-num-corr f-cause-corr F-cashier F-salesman f-cli-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man
          tt-chk-doc.obj-code tt-chk-doc.d-card tt-chk-doc.pay-desk
          tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
          tt-chk-doc.src-shift-date tt-chk-doc.cash-scale tt-chk-doc.cash-rate
          tt-chk-doc.shift-name tt-chk-doc.shift-num v-src-d-card
          tt-chk-doc.PS tt-chk-doc.tot-doc tt-chk-doc.discnt
          tt-chk-doc.sub-discnt tt-chk-doc.netto tt-chk-doc.d-pcnt
          tt-chk-doc.shift-date
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-prev B-next Cb-chk-type B-help RECT-1 tt-chk-doc.chk-date 
         tt-chk-doc.cashier fhour fmin fsec tt-chk-doc.sales-man 
         tt-chk-doc.obj-code tt-chk-doc.d-card tt-chk-doc.pay-desk v-corr-osnov 
         v-corr-type v-doc-osnov corr-date f-num-corr f-cause-corr 
         tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt 
         tt-chk-doc.src-shift-date tt-chk-doc.cash-rate tt-chk-doc.cash-scale 
         tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.src-d-card 
         B-bonus B-discnt B-gds BR-discnt BR-gds BR-pay tt-chk-doc.PS F-cashier 
         tt-chk-doc.tot-doc F-salesman tt-chk-doc.discnt tt-chk-doc.sub-discnt 
         f-cli-name tt-chk-doc.netto tt-chk-doc.d-pcnt tt-chk-doc.shift-date 
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

  FIND FIRST locked_c-chk-doc NO-LOCK WHERE
              recid(locked_c-chk-doc) = p-doc-rec.
IF NOT AVAIL locked_c-chk-doc then
return error.
create tt-chk-doc.
buffer-copy locked_c-chk-doc to tt-chk-doc.
  FIND FIRST buf_obj No-LOCK WHERe
              buf_obj.obj-type = tt-chk-doc.obj-type AND
              buf_obj.obj-code = tt-chk-doc.obj-code No-ERROR.
  if not avail buf_obj then do:
    message "Чек" locked_c-chk-doc.doc-code  skip
            "Неверный объект" locked_c-chk-doc.obj-type locked_c-chk-doc.obj-code
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
for each locked_c-chk-gds no-lock where
          locked_c-chk-gds.doc-code = tt-chk-doc.doc-code
       and locked_c-chk-gds.chip-num = locked_c-chk-doc.chip-num :
      create tt-chk-gds.
      buffer-copy locked_c-chk-gds to tt-chk-gds.
      create tt-gds-info.
      buffer-copy locked_c-chk-gds to tt-gds-info
      assign
      tt-gds-info.artic = get-good(input tt-chk-gds.b-code, output tt-gds-info.gds-name, output tt-gds-info.prt-name, output var-is-error)
      tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
      tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
      tt-gds-info.src-sum-netto = (tt-chk-gds.src-price - tt-chk-gds.src-discnt) * tt-chk-gds.src-qnty
      tt-gds-info.src-d-pcnt = (tt-chk-gds.src-discnt / tt-chk-gds.src-price * 100)
      tt-gds-info.src-price-netto = tt-chk-gds.src-price - tt-chk-gds.src-discnt
      tt-gds-info.sum-netto = (tt-chk-gds.price-base - tt-chk-gds.discnt) * tt-chk-gds.doc-qnty
      tt-gds-info.d-pcnt = (tt-chk-gds.discnt / tt-chk-gds.price-base * 100)
      tt-gds-info.price-netto = tt-chk-gds.price-base - tt-chk-gds.discnt
      .
      tt-gds-info.salesman-name = get-salesman(input tt-chk-gds.sales-man, input tt-chk-doc.chk-date, output tt-chk-gds.salesman-psn-code).
      assign
      v-is-top = locked_c-chk-gds.pump > 0
      tt-chk-gds.is-error = (if var-is-error then yes else tt-chk-gds.is-error)
      .
  end.
  for each locked_c-chk-pay no-lock where
            locked_c-chk-pay.doc-code = tt-chk-doc.doc-code
        and locked_c-chk-pay.chip-num = locked_c-chk-doc.chip-num :
      create tt-chk-pay.
      buffer-copy locked_c-chk-pay to tt-chk-pay
      .
      assign tt-chk-pay.pay-card = f-paycardv(tt-chk-pay.pay-card, tt-chk-pay.pay-code, tt-chk-pay.curr-code)
      .
      create tt-pay-info.
      buffer-copy locked_c-chk-pay to tt-pay-info
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
for each locked_c-chk-doc-attr no-lock where
         locked_c-chk-doc-attr.doc-code = tt-chk-doc.doc-code
     and locked_c-chk-doc-attr.chip-num = locked_c-chk-doc.chip-num :
      create tt-chk-doc-attr.
      buffer-copy locked_c-chk-doc-attr to tt-chk-doc-attr.
end.
for each locked_c-chk-discnt no-lock where
         locked_c-chk-discnt.doc-code = tt-chk-doc.doc-code
     AND (locked_c-chk-discnt.record-type = 0
         or
         locked_c-chk-discnt.record-type = 4)
     and locked_c-chk-discnt.chip-num = locked_c-chk-doc.chip-num :
  /*отсечем % скидку для IBM и т.д.*/
      if locked_c-chk-discnt.line-num = 0
        AND locked_c-chk-discnt.line-type = integer({&discnt-receipt}) then NEXT.
      /*
      if not dflt-cd = "ncr-gm" and locked_c-chk-discnt.line-type = integer({&discnt-gds})  then next.
      */
      create tt-chk-discnt.
      buffer-copy locked_c-chk-discnt to tt-chk-discnt.
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tt-chk-doc.src-shift-date = if (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
                            then tt-chk-doc.src-shift-date
                                                        else tt-chk-doc.chk-date
tt-chk-doc.shift-date = if get-chkc_context.t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
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
    run get-price1 in this-procedure (buf_goods.gds-code, bar-code.node-code) No-ERROR.
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
    units-rate = tt-chk-gds.doc-qnty / tt-chk-gds.src-qnty
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
      tt-gds-info.artic = get-good(input tt-chk-gds.b-code, output tt-gds-info.gds-name, output tt-gds-info.prt-name, output var-is-error)
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
      loc-tt-chk-discnt.value-type = integer({&discnt-v-unknown})
      loc-tt-chk-discnt.discnt-type = integer({&discnt-t-unknown})
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
    loc-tt-chk-discnt.discnt-value-abs = tt-chk-gds.src-discnt * tt-chk-gds.src-qnty
    loc_chk-discnt.discnt-value-abs = tt-chk-gds.src-discnt * tt-chk-gds.src-qnty
    .
  end.
end.
else if tt-chk-gds.src-discnt = 0 then do:
      find first loc_chk-discnt where
                 loc_chk-discnt.doc-code = tt-chk-doc.doc-code
             AND loc_chk-discnt.record-type = 0
             AND loc_chk-discnt.line-num = tt-chk-gds.line-num
             AND loc_chk-discnt.object-line-num = tt-chk-gds.line-num no-error.
      if avail loc_chk-discnt then do:
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

if tt-chk-gds.src-qnty <> 0 then /* ненулевое кол-во */ do:
  price-from-check = /* действие, почти обратное ibm-gds.i */
  ( tt-chk-gds.SRC-PRICE / ( 1 - units-dpcnt / 100 ) ) * abs( tt-chk-gds.src-qnty ) .
  assign
  tt-chk-gds.b-code = ( if b-c <> ? then b-c else 0)
  tt-chk-gds.is-error = (b-c = ?)
    tt-chk-gds.doc-qnty =  tt-chk-gds.doc-qnty
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
  with frame {&frame-name}.
  glog = br-gds:refresh() in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-discnt Dialog-Frame
PROCEDURE get-discnt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-line-num like ub.chk-discnt.line-num.
DEFINE INPUT PARAMETER p-discnt-v-type like ub.chk-discnt.value-type no-undo.
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
    run get-b-code in this-procedure .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-good-proc Dialog-Frame
PROCEDURE get-good-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter parb-code as integer no-undo.
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

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
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
  "Внимание! На текущем объекте требуется использование смен" skip
  "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
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

FIND FIRST loc_cash-pay No-LOCK WHERE
                  loc_cash-pay.cdpay-code = parpay-code AND
                  loc_cash-pay.curr-code = parcurr-code No-ERROR.
if avail loc_cash-pay then do:
    varpay-name = loc_cash-pay.obj-name.
end.
else do:
  if tt-chk-doc.chk-type = integer({&rcpt-z-rep})
  and parpay-code = 0
  and parcurr-code = 0 then do:
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-is-petrol-check            as logical                 no-undo .
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
if not v-is-petrol-check then do:
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
  tt-chk-doc.discnt = tt-chk-doc.discnt + tt-chk-doc.real-subdiscnt
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
assign
cb-chk-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  {&receipt-codes-combo} +
                                                      (if par-mode <> {&add-def}
                                                      then ({&comma-char} + "Ошибка" + {&comma-char} + string(0))
                                                      else "":U)
.
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
frame {&frame-name}:title = substitute("ЧЕК № &1 Время : &2"
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
                            else substitute("Дата учета &1", string(tt-chk-doc.shift-date)).
 if par-l-mask then v-src-d-card = substring(tt-chk-doc.src-d-card,1,6) + "XXXXXX" + substring (tt-chk-doc.src-d-card,13,4).
else v-src-d-card = tt-chk-doc.src-d-card .
 DISPLAY
 cb-chk-type
 fhour
 fmin
 fsec
 F-cashier
 F-salesman
 f-cli-name
 WITH FRAME {&frame-name} .
 IF AVAILABLE tt-chk-doc THEN
DISPLAY tt-chk-doc.chk-date tt-chk-doc.cashier tt-chk-doc.sales-man
      tt-chk-doc.obj-code tt-chk-doc.d-card v-src-d-card tt-chk-doc.pay-desk
      tt-chk-doc.chk-num tt-chk-doc.z-number tt-chk-doc.src-d-pcnt
      tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cash-scale
      tt-chk-doc.cash-rate tt-chk-doc.shift-num tt-chk-doc.shift-name tt-chk-doc.PS
      tt-chk-doc.tot-doc tt-chk-doc.discnt tt-chk-doc.sub-discnt
      tt-chk-doc.netto tt-chk-doc.d-pcnt
  WITH FRAME {&frame-name} .
ENABLE
B-quit
B-prev
B-next
B-help
br-gds
br-discnt
br-pay
b-discnt
b-bonus
b-gds
WITH FRAME {&frame-name}.
assign
tt-chk-gds.b-code:read-only in browse br-gds = yes
tt-chk-gds.src-code:read-only in browse br-gds = yes
tt-chk-gds.pump:read-only in browse br-gds = yes
tt-chk-gds.nozzle-code:read-only in browse br-gds = yes
tt-chk-gds.loc1:read-only in browse br-gds = yes
tt-chk-gds.src-price:read-only in browse br-gds = yes
tt-chk-gds.src-discnt:read-only in browse br-gds = yes
tt-chk-gds.src-qnty:read-only in browse br-gds = yes
tt-chk-gds.road-tax:read-only in browse br-gds = yes
tt-chk-gds.price-service:read-only in browse br-gds = yes
tt-chk-gds.depart-id:read-only in browse br-gds = yes
tt-chk-gds.depart-code:read-only in browse br-gds = yes
tt-chk-pay.pay-code:read-only in browse br-pay = yes
tt-chk-pay.curr-code:read-only in browse br-pay = yes
tt-chk-pay.tot-sum:read-only in browse br-pay = yes
tt-chk-pay.pay-card:read-only in browse br-pay = yes
tt-chk-pay.cash-rate:read-only in browse br-pay = yes
tt-chk-discnt.discnt-value-abs:read-only in browse br-discnt = yes
tt-chk-gds.doc-qnty:read-only in browse br-gds = yes
.
if tt-chk-doc.chk-type = integer({&rcpt-z-rep}) then do:
  assign
  tt-chk-pay.pay-code:visible in browse br-pay = no
  tt-chk-pay.curr-code:visible in browse br-pay = no
  tt-chk-pay.pay-card:visible in browse br-pay = no
  tt-chk-pay.tot-sum:label in browse br-pay = "Сумма"
  .
end.
else do:
  assign
  tt-chk-pay.pay-code:visible in browse br-pay = yes
  tt-chk-pay.curr-code:visible in browse br-pay = yes
  tt-chk-pay.pay-card:visible in browse br-pay = yes
  tt-chk-pay.tot-sum:label in browse br-pay = "Сумма платежа"
  .
end.
if not cas-shft then do:
  hide
  tt-chk-doc.src-shift-date
  tt-chk-doc.shift-num
  tt-chk-doc.shift-name
  in frame {&frame-name}.
end.
VIEW FRAME {&frame-name}.
{&OPEN-QUERY-BR-gds}
{&OPEN-QUERY-BR-pay}
{&OPEN-QUERY-BR-discnt}
hide br-discnt in frame {&frame-name}.

for first buf_chk-doc-attr where buf_chk-doc-attr.doc-code = tt-chk-doc.doc-code 
and buf_chk-doc-attr.attr-code = "corr-osnov":
  v-doc-osnov = OsnovCorr(integer(buf_chk-doc-attr.attr-value)) .
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
v-doc-osnov
corr-date
f-cause-corr
f-num-corr
with frame {&frame-name} . 
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
if NOT available ub.cash-pay then do:
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-bonus Dialog-Frame
PROCEDURE proc-b-bonus :
define variable var-line-num as character no-undo.
define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not br-discnt:visible in frame {&frame-name}
or v-br-discnt-current-type = 0
then do:
    hide br-gds in frame {&frame-name}.
    assign
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = yes
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = yes
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = yes
    v-br-discnt-current-type = 4
    .
    display br-discnt with frame {&frame-name}.

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
      ENABLE
      b-gds
      b-discnt
      with frame {&frame-name}.
      DISABLE
      b-bonus
      with frame {&frame-name}.
   return.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-discnt Dialog-Frame
PROCEDURE proc-b-discnt :
define variable var-line-num as character no-undo.
define variable v-wro-code as integer no-undo .

define buffer loc_tt-chk-discnt for tt-chk-discnt.
define buffer last-tt-chk-gds for tt-chk-gds.
if not br-discnt:visible in frame {&frame-name}
or v-br-discnt-current-type = 4
then do:
    hide br-gds in frame {&frame-name}.
    assign
    tt-chk-discnt.src-d-card:VISIBLE IN BROWSE br-discnt = NO
    tt-chk-discnt.discnt-id:VISIBLE IN BROWSE br-discnt = no
    tt-chk-discnt.kateg:VISIBLE IN BROWSE br-discnt = no
    v-br-discnt-current-type = 0
    .
    display br-discnt with frame {&frame-name}.

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
  ENABLE
  b-gds
  b-bonus
  with frame {&frame-name}.
  DISABLE
  b-discnt
  with frame {&frame-name}.
   return.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-gds Dialog-Frame
PROCEDURE proc-b-gds :
define variable varrid-list as character no-undo.
define variable ii as integer no-undo.
DEFINE VARIABLE varline-rid as recid  no-undo.
define variable v-wro-code as integer no-undo .
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
    ENABLE
    b-discnt
    with frame {&frame-name}.
    DISABLE
    b-gds
    with frame {&frame-name}.
    {&OPEN-QUERY-BR-gds}
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-c-chk-doc Dialog-Frame
PROCEDURE reposition-c-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-c-chk-doc-recid as recid no-undo .


do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-c-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-chk-doc-recid
      ).

    if v-new-c-chk-doc-recid <> ?
    then do:
      define buffer buf_c-chk-doc for ub.c-chk-doc .
      find first buf_c-chk-doc no-lock
        where recid(buf_c-chk-doc) = v-new-c-chk-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-c-chk-doc-recid
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file Dialog-Frame
PROCEDURE write-log-and-file :
define input parameter p-tab-position   as integer   no-undo.
define input parameter p-file-name      as character no-undo .
define input parameter p-log-level      as integer no-undo .
define input parameter p-log-string     as character no-undo .
message
p-log-string
view-as alert-box error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-good Dialog-Frame
FUNCTION get-good RETURNS CHARACTER
  ( input  parb-code as integer, output pargds-name as character, output parprt-name as character, output paris-error as logical) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-artic like ub.goods.artic No-undo.
run get-good-proc in this-procedure (
input parb-code
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
return varpay-name.

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