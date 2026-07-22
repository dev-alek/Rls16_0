&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_shop FOR ub.shop.
DEFINE NEW SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE NEW SHARED TEMP-TABLE tt-shop NO-UNDO LIKE ub.shop.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование и просмотр записи таблицы магазин

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Author: ? , изменял Черных В.    - но это было давно и неправда!!!

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT        PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input        parameter p-host-code    like ub.sysconf.host-code no-undo.
define input        parameter p-obj-code     like ub.shop.obj-code no-undo.
define input        parameter p-mode         as character no-undo .   /* {&add-def}, {&update}, {&lookup} */
define input-output parameter p-rid          as recid     no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Редактирование и просмотр записи таблицы магазин" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/thbj-def.i }
{ gbl/thbjattr.i }
{ adm/shattrg.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/waitfram.i }


define buffer buf_cli-grp for ub.cli-grp .
define buffer buf_cli-host for ub.clients .

define variable v-db-num like ub.db.db-num no-undo .
define variable all-prt_ like ub.shop.all-prt no-undo.
define variable cd-bc-alt_ like ub.shop.cd-bc-alt no-undo.
define variable cd-bc-base_ like ub.shop.cd-bc-base no-undo.
define variable cd-loc-alt_ like ub.shop.cd-loc-alt no-undo.
define variable cd-loc-base_ like ub.shop.cd-loc-base no-undo.
define variable cd-parts-all_ like ub.shop.cd-parts-all no-undo.
define variable cd-parts-not-blank_ like ub.shop.cd-parts-not-blank no-undo.
define variable cd-parts-ser_ like ub.shop.cd-parts-ser no-undo.
define variable cd-pb-alt_ like ub.shop.cd-pb-alt no-undo.
define variable cd-pb-base_ like ub.shop.cd-pb-base no-undo.
define variable cd-sc-base_ like ub.shop.cd-sc-base no-undo.
define variable ref-list as character no-undo .
define variable new-host-code as integer no-undo .
DEFINE VARIABLE v-envd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-kpp AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-pharm AS CHARACTER NO-UNDO.
define variable var-type as CHARACTER no-undo .
define variable v-shopi-have-holdfirm    as logical      no-undo.

&scoped-define purch-like-firm "по настройкам фирмы"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-shop locked_clients tt-clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-clients.db-num ~
tt-shop.obj-code tt-clients.obj-name tt-shop.director tt-shop.addres1 ~
tt-shop.phone tt-shop.addres2 tt-shop.fax tt-shop.rsrv-time tt-shop.doc-prt ~
tt-shop.price-calc tt-shop.in-pay tt-shop.no-eq tt-shop.out-pay ~
tt-shop.unit-cli-perm tt-shop.ret-pay tt-shop.out-rate tt-shop.in-perm ~
tt-shop.ret-sup-pay tt-shop.out-line-discnt tt-shop.down-pay tt-shop.in-ov ~
tt-shop.inv-pay tt-shop.inout-price tt-shop.chk-pay tt-shop.day-only ~
tt-shop.fbr-pay tt-shop.buy-goods tt-shop.with-serv tt-shop.pr-cash ~
tt-shop.sub-store-type tt-shop.sub-store-code tt-shop.discaloc ~
tt-shop.shift-on tt-shop.kitchen-store-code tt-shop.sub-store-on ~
tt-shop.is-catering tt-shop.is-kitchen tt-shop.is-kitchen-store 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-clients.db-num ~
tt-shop.obj-code tt-clients.obj-name tt-shop.director tt-shop.addres1 ~
tt-shop.phone tt-shop.addres2 tt-shop.fax tt-shop.rsrv-time tt-shop.doc-prt ~
tt-shop.price-calc tt-shop.in-pay tt-shop.no-eq tt-shop.out-pay ~
tt-shop.unit-cli-perm tt-shop.ret-pay tt-shop.out-rate tt-shop.in-perm ~
tt-shop.ret-sup-pay tt-shop.out-line-discnt tt-shop.down-pay tt-shop.in-ov ~
tt-shop.inv-pay tt-shop.inout-price tt-shop.chk-pay tt-shop.day-only ~
tt-shop.fbr-pay tt-shop.buy-goods tt-shop.with-serv tt-shop.pr-cash ~
tt-shop.sub-store-type tt-shop.sub-store-code tt-shop.discaloc ~
tt-shop.shift-on tt-shop.kitchen-store-code tt-shop.sub-store-on ~
tt-shop.is-catering tt-shop.is-kitchen tt-shop.is-kitchen-store 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-clients tt-shop
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-clients
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-shop
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-shop SHARE-LOCK, ~
      EACH locked_clients WHERE TRUE /* Join to ub.shop incomplete */ SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.shop incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-shop SHARE-LOCK, ~
      EACH locked_clients WHERE TRUE /* Join to ub.shop incomplete */ SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.shop incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-shop locked_clients ~
tt-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-shop
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame locked_clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame tt-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-clients.db-num tt-shop.obj-code ~
tt-clients.obj-name tt-shop.director tt-shop.addres1 tt-shop.phone ~
tt-shop.addres2 tt-shop.fax tt-shop.rsrv-time tt-shop.doc-prt ~
tt-shop.price-calc tt-shop.in-pay tt-shop.no-eq tt-shop.out-pay ~
tt-shop.unit-cli-perm tt-shop.ret-pay tt-shop.out-rate tt-shop.in-perm ~
tt-shop.ret-sup-pay tt-shop.out-line-discnt tt-shop.down-pay tt-shop.in-ov ~
tt-shop.inv-pay tt-shop.inout-price tt-shop.chk-pay tt-shop.day-only ~
tt-shop.fbr-pay tt-shop.buy-goods tt-shop.with-serv tt-shop.pr-cash ~
tt-shop.sub-store-type tt-shop.sub-store-code tt-shop.discaloc ~
tt-shop.shift-on tt-shop.kitchen-store-code tt-shop.sub-store-on ~
tt-shop.is-catering tt-shop.is-kitchen tt-shop.is-kitchen-store 
&Scoped-define ENABLED-TABLES tt-clients tt-shop
&Scoped-define FIRST-ENABLED-TABLE tt-clients
&Scoped-define SECOND-ENABLED-TABLE tt-shop
&Scoped-Define ENABLED-OBJECTS B-exit RECT-10 RECT-kitchen-store ~
RECT-sub-store b-quit b-reset CliPS b-tocd b-host b-db B-hist B-Help B-attr ~
Btn_trn-reason b-inpay b-outpay b-retpay b-suppay b-spipay b-invpay ~
b-realpay b-fbrpay b-sub-store b-kitchen-store b-holdfirm ~
varenvd varpharm 
&Scoped-Define DISPLAYED-FIELDS tt-clients.db-num tt-shop.obj-code ~
tt-clients.obj-name tt-shop.director tt-shop.addres1 tt-shop.phone ~
tt-shop.addres2 tt-shop.fax tt-shop.rsrv-time tt-shop.doc-prt ~
tt-shop.price-calc tt-shop.in-pay tt-shop.no-eq tt-shop.out-pay ~
tt-shop.unit-cli-perm tt-shop.ret-pay tt-shop.out-rate tt-shop.in-perm ~
tt-shop.ret-sup-pay tt-shop.out-line-discnt tt-shop.down-pay tt-shop.in-ov ~
tt-shop.inv-pay tt-shop.inout-price tt-shop.chk-pay tt-shop.day-only ~
tt-shop.fbr-pay tt-shop.buy-goods tt-shop.with-serv tt-shop.pr-cash ~
tt-shop.sub-store-type tt-shop.sub-store-code tt-shop.discaloc ~
tt-shop.shift-on tt-shop.kitchen-store-code tt-shop.sub-store-on ~
tt-shop.is-catering tt-shop.is-kitchen tt-shop.is-kitchen-store 
&Scoped-define DISPLAYED-TABLES tt-clients tt-shop
&Scoped-define FIRST-DISPLAYED-TABLE tt-clients
&Scoped-define SECOND-DISPLAYED-TABLE tt-shop
&Scoped-Define DISPLAYED-OBJECTS KPP varpurch-code-name varenvd ~
varpharm fi-holdfirm-code fi-holdfirm-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-obj-code 
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-attr 
     LABEL "&Параметры" 
     SIZE 10 BY 1.

DEFINE BUTTON b-db 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-fbrpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-holdfirm 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-db" 
     SIZE 3 BY .86.

DEFINE BUTTON b-host 
     LABEL "&Фирма" 
     SIZE 10 BY 1.

DEFINE BUTTON b-inpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-invpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-kitchen-store 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-outpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-realpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-reset 
     LABEL "&Уст.Сист.":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-retpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-spipay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-sub-store 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-suppay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-tocd 
     LABEL "&На кассу" 
     SIZE 10 BY 1.

DEFINE BUTTON Btn_trn-reason 
     LABEL "Коды оснований" 
     SIZE 18 BY 1 TOOLTIP "Код оснований (причин) создания документов по умолчанию на складе".

DEFINE BUTTON CliPS 
     LABEL "&Доп. инф." 
     SIZE 10 BY 1.








DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип приобретения" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE fi-holdfirm-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Фирма для накладных" 
      VIEW-AS TEXT 
     SIZE 6.6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-holdfirm-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 18.6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE KPP AS CHARACTER FORMAT "X(25)":U NO-UNDO
          LABEL "КПП"
          VIEW-AS FILL-IN 
          SIZE 19.2 BY .91
          BGCOLOR 15  .

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 31.2 BY 9.33
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-kitchen-store
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.8 BY 1.29.

DEFINE RECTANGLE RECT-sub-store
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.8 BY 1.52.

DEFINE VARIABLE varenvd AS LOGICAL INITIAL no 
     LABEL "Без НДС" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.

DEFINE VARIABLE varpharm AS LOGICAL INITIAL no 
     LABEL "Аптека" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-shop, 
      locked_clients, 
      tt-clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-reset AT ROW 1 COL 31
     CliPS AT ROW 1 COL 41
     b-tocd AT ROW 1 COL 51
     b-host AT ROW 1 COL 61
     tt-clients.db-num AT ROW 1 COL 80 COLON-ALIGNED
          LABEL "Номер БД" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-db AT ROW 1 COL 88.6
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-shop.obj-code AT ROW 2 COL 5.2 COLON-ALIGNED
          LABEL " Код" format ">>>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
          BGCOLOR 15 FGCOLOR 0 
     tt-clients.obj-name AT ROW 2 COL 22 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN 
          SIZE 46.6 BY 1
          BGCOLOR 15 
     B-attr AT ROW 2 COL 71
     Btn_trn-reason AT ROW 2 COL 81
     tt-shop.director AT ROW 3.1 COL 7 COLON-ALIGNED
          LABEL "Дир-р" FORMAT "X(50)"
          VIEW-AS FILL-IN 
          SIZE 64 BY 1
          BGCOLOR 15 
     KPP AT ROW 3.29 COL 78 COLON-ALIGNED WIDGET-ID 6
         
     tt-shop.addres1 AT ROW 4.19 COL 7 COLON-ALIGNED
          LABEL "Адрес" FORMAT "X(80)"
          VIEW-AS FILL-IN 
          SIZE 64 BY 1
          BGCOLOR 15 
     tt-shop.phone AT ROW 4.29 COL 78 COLON-ALIGNED
          LABEL "Тел-н"
          VIEW-AS FILL-IN 
          SIZE 19.2 BY .91
          BGCOLOR 15 
     tt-shop.addres2 AT ROW 5.29 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 2 FORMAT "X(80)"
          VIEW-AS FILL-IN 
          SIZE 64 BY 1
          BGCOLOR 15 
     tt-shop.fax AT ROW 5.29 COL 78 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN 
          SIZE 19.2 BY 1
          BGCOLOR 15 
     tt-shop.rsrv-time AT ROW 6.29 COL 38.5 COLON-ALIGNED
          LABEL "Период ре&зерв-ния (дней)"
          VIEW-AS FILL-IN 
          SIZE 4 BY .91
          BGCOLOR 15 
     tt-shop.doc-prt AT ROW 7.29 COL 55
          LABEL "Учет по шкалам"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.price-calc AT ROW 8.1 COL 55
          LABEL "Запрещен приход при неравенстве цен"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.in-pay AT ROW 8.19 COL 18.8 COLON-ALIGNED
          LABEL "Оплата п&рихода"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-inpay AT ROW 8.19 COL 27.6
     tt-shop.no-eq AT ROW 9 COL 55
          LABEL "Запрещен приход при отсутствии цен"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.out-pay AT ROW 9.19 COL 18.8 COLON-ALIGNED
          LABEL "рас&хода"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-outpay AT ROW 9.19 COL 27.6
     tt-shop.unit-cli-perm AT ROW 9.91 COL 55
          LABEL "&Изменение ед. изм. поставщика"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.ret-pay AT ROW 10.19 COL 18.8 COLON-ALIGNED
          LABEL "во&зврата"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-retpay AT ROW 10.19 COL 27.6
     tt-shop.out-rate AT ROW 10.81 COL 55
          LABEL "Изменение &курса РН"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.in-perm AT ROW 10.91 COL 55
          LABEL "Переме&щение по цене магазина"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-shop.ret-sup-pay AT ROW 11.19 COL 18.8 COLON-ALIGNED
          LABEL "возвра&та пост."
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-suppay AT ROW 11.19 COL 27.6
     tt-shop.out-line-discnt AT ROW 11.71 COL 55
          LABEL "&Скидка по строке РН"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.down-pay AT ROW 12.19 COL 18.8 COLON-ALIGNED
          LABEL "списани&я"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-spipay AT ROW 12.19 COL 27.6
     tt-shop.in-ov AT ROW 12.57 COL 55
          LABEL "Запрет движения без переоценки после ПН"
          VIEW-AS TOGGLE-BOX
          SIZE 42 BY .81
     tt-shop.inv-pay AT ROW 13.19 COL 18.8 COLON-ALIGNED
          LABEL "и&нвентаризации"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-invpay AT ROW 13.19 COL 27.6
     tt-shop.inout-price AT ROW 13.52 COL 55
          LABEL "Изменение налогов в ПН"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.chk-pay AT ROW 14.19 COL 18.8 COLON-ALIGNED
          LABEL "прода&жи"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-realpay AT ROW 14.19 COL 27.6
     tt-shop.day-only AT ROW 14.43 COL 55
          LABEL "В кассовом отчете чеки смены одного дня"
          VIEW-AS TOGGLE-BOX
          SIZE 42.6 BY .81
     tt-shop.fbr-pay AT ROW 15.19 COL 18.8 COLON-ALIGNED
          LABEL "производства"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
     b-fbrpay AT ROW 15.19 COL 27.6
     tt-shop.buy-goods AT ROW 15.29 COL 55
          LABEL "Приоритетная продажа выкупного товара"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.with-serv AT ROW 16.19 COL 55
          LABEL "Магазин реализует услуги"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.pr-cash AT ROW 17.19 COL 55
          LABEL "Разрешить переоценку без блокировки"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.sub-store-type AT ROW 17.95 COL 2.4 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 7.6 BY 1
     tt-shop.sub-store-code AT ROW 17.95 COL 15 COLON-ALIGNED
          LABEL " Код"
          VIEW-AS FILL-IN 
          SIZE 9.2 BY 1
     b-sub-store AT ROW 17.95 COL 28.6
     tt-shop.discaloc AT ROW 18.1 COL 55
          LABEL "~"Размазывать~" скидку на итог"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.shift-on AT ROW 19 COL 55
          LABEL "Включены смены"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.kitchen-store-code AT ROW 19.71 COL 17.4 COLON-ALIGNED
          LABEL "Склад кухни"
          VIEW-AS FILL-IN 
          SIZE 9.2 BY 1
     b-kitchen-store AT ROW 19.76 COL 28.8
     tt-shop.sub-store-on AT ROW 19.81 COL 55
          LABEL "Склад-подсобка"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     tt-shop.is-catering AT ROW 20.52 COL 55
          LABEL "Ресторан"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     varpurch-code-name AT ROW 21 COL 18.8 COLON-ALIGNED
     tt-shop.is-kitchen AT ROW 21.29 COL 55
          LABEL "Кухня(объект производства)"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .81
     b-holdfirm AT ROW 22.5 COL 30.5
     tt-shop.is-kitchen-store AT ROW 22.05 COL 55
          LABEL "Склад для кухни"
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .79
     
     varenvd AT ROW 23.5 COL 55
     varpharm AT ROW 23.5 COL 65.5 WIDGET-ID 4
     fi-holdfirm-code AT ROW 22.5 COL 22 COLON-ALIGNED
     fi-holdfirm-name AT ROW 22.5 COL 32 COLON-ALIGNED NO-LABEL
     "Склад-подсобка" VIEW-AS TEXT
          SIZE 31.38 BY .67 AT ROW 17 COL 1
     "Оплаты :" VIEW-AS TEXT
          SIZE 8.5 BY .92 AT ROW 7.21 COL 3.38
          FGCOLOR 4 
     RECT-10 AT ROW 7.42 COL 1.25
     RECT-kitchen-store AT ROW 19.5 COL 1
     RECT-sub-store AT ROW 17.75 COL 1
     SPACE(66.57) SKIP(5.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки магазина"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_clients B "?" ? ub clients
      TABLE: locked_shop B "?" ? ub shop
      TABLE: tt-clients T "NEW SHARED" NO-UNDO ub clients
      TABLE: tt-shop T "NEW SHARED" NO-UNDO ub shop
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-shop.addres1 IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-shop.addres2 IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR TOGGLE-BOX tt-shop.buy-goods IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.chk-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.day-only IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-clients.db-num IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-shop.director IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR TOGGLE-BOX tt-shop.discaloc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.doc-prt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.down-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.fax IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.fbr-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fi-holdfirm-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-holdfirm-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.in-ov IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.in-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.in-perm IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.inout-price IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.inv-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.is-catering IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.is-kitchen IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.is-kitchen-store IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.kitchen-store-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.no-eq IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN 
       tt-shop.obj-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-obj-code:HANDLE.

/* SETTINGS FOR FILL-IN tt-clients.obj-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.out-line-discnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.out-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.out-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.phone IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.pr-cash IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.price-calc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.ret-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.ret-sup-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.rsrv-time IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.shift-on IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.sub-store-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.sub-store-on IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-shop.sub-store-type IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX tt-shop.unit-cli-perm IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX varpurch-code-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-shop.with-serv IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-shop,Temp-Tables.locked_clients WHERE ub.shop ...,Temp-Tables.tt-clients WHERE ub.shop ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки магазина */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Параметры */
DO:
   RUN proc-b-attr IN THIS-PROCEDURE ({&lookup}, {&shop}, locked_shop.obj-code) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-db Dialog-Frame
ON CHOOSE OF b-db IN FRAME Dialog-Frame
DO:
define variable ri as recid no-undo.
define buffer buf_db for ub.db.
  run adm/dbs.w (
                input parparentproc
               ,input {&lookup}
               ,output ri).
  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ tt-clients.db-num
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure(yes) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fbrpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fbrpay Dialog-Frame
ON CHOOSE OF b-fbrpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        tt-shop.fbr-pay = buf_pay-type.obj-code .
        display
        tt-shop.fbr-pay
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo .
     run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , "one":U /*p-mode*/
                    , input {&shop} /*p-obj-type*/
                    , input tt-shop.obj-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-rid-list  ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-holdfirm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-holdfirm Dialog-Frame
ON CHOOSE OF b-holdfirm IN FRAME Dialog-Frame /* b-db */
DO:
    define variable v-ref-list  as character    no-undo.
    define variable v-firm-code as integer    no-undo.

    assign
        fi-holdfirm-code
    .
    run adm/sconfs.w (
          input parParentProc
        , input "b-sel":U
        , input no
        , input fi-holdfirm-code
        , output v-firm-code
        , input-output ref-list
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора фирмы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-firm-code = ?
    or v-firm-code = 0
    then do:
        message "Фирма не выбрана."
        view-as alert-box warning.
        return no-apply.
    end.
    else do:
        define buffer buf_clients for ub.clients.
        find first buf_clients no-lock
             where buf_clients.obj-type = {&cmp}
               and buf_clients.obj-code = v-firm-code
        no-error.
        if available buf_clients
        then do:
            assign
                fi-holdfirm-code = v-firm-code
                fi-holdfirm-name = buf_clients.obj-name
            .
        end.
        else do:
            assign
                fi-holdfirm-code = 0
                fi-holdfirm-name = "":U
            .
        end.
        display
            fi-holdfirm-code
            fi-holdfirm-name
        with frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-host Dialog-Frame
ON CHOOSE OF b-host IN FRAME Dialog-Frame /* Фирма */
DO:
define variable ref-list as char no-undo.
define variable glog as logical no-undo .
IF p-mode = {&add-def} THEN DO:

  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input p-host-code
                ,output new-host-code
                ,input-output ref-list ) .
  .
  if new-host-code = ?
  or new-host-code = 0
  then do:
    message "Фирма не выбрана."
            view-as alert-box error.
    return no-apply.
  end.
  if tt-shop.host-code <> 0 then do:
    /*если не принудительный выбор при входе*/
    message
    "Проставить коды оплат для типов документов, параметры отсылки на кассу и др. согласно настройкам выбранной фирмы?"
    view-as alert-box question buttons yes-no update glog.
  end.
  else do:
    glog = yes.
  end.
  tt-shop.host-code = new-host-code.
  find first buf_cli-host where
            buf_cli-host.obj-type = {&cmp}
        and buf_cli-host.obj-code = tt-shop.host-code no-lock.
  CASE p-mode:
    when {&lookup} then
    frame {&frame-name}:title = "МАГАЗИН  фирмы : " + buf_cli-host.obj-name + "               " + "ПРОСМОТР".
    when {&add-def} then
    frame {&frame-name}:title = "МАГАЗИН  фирмы : " + buf_cli-host.obj-name + "               " + "ДОБАВЛЕНИЕ".
    when {&update} then
    frame {&frame-name}:title = "МАГАЗИН  фирмы : " + buf_cli-host.obj-name + "               " + "ИЗМЕНЕНИЕ".
  END CASE.
  if glog then do:
    run reset-from-sysconf in this-procedure ( input yes
                                              , input tt-shop.host-code
                                                      ).
  end.
END.
ELSE DO:
      run adm/config.w (
                          input parparentproc /*parparentproc*/
                         ,input tt-shop.host-code
                         ,input  {&lookup}
                         ,input no /*p-is-deploy*/
                         ) no-error.
    if error-status:error then return no-apply.

END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-inpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inpay Dialog-Frame
ON CHOOSE OF b-inpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        tt-shop.in-pay = buf_pay-type.obj-code .
        display tt-shop.in-pay with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-invpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-invpay Dialog-Frame
ON CHOOSE OF b-invpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.

    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then  return no-apply.
    else do:
        FIND buf_pay-type WHERE
               recid( buf_pay-type ) = integer(ref-rec) NO-LOCK .
        assign
        tt-shop.inv-pay = buf_pay-type.obj-code .
        display
              tt-shop.inv-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-kitchen-store
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-kitchen-store Dialog-Frame
ON CHOOSE OF b-kitchen-store IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define variable rid-list as character no-undo .

  define buffer buf_clients for ub.clients.

  run ref/cli-all.w (   input parparentproc
                  ,input "b-sel"
                  ,input {&shop}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "lock-cli-type":U
                  ,output rid-list) no-error.
  if rid-list = '':U then return no-apply.
  find first buf_clients where recid (buf_clients) = integer (rid-list) no-lock no-error.
  if available buf_clients
  then do:
    if input frame {&frame-name} tt-clients.db-num <> buf_clients.db-num
    then do:
      message
        "Нельзя в качестве склада объекта КУХНЯ указать объект другой БД!" skip
        view-as alert-box ERROR.
      return no-apply.
    end.
    display
      /*v-obj-type @ tt-shop.kitchen-type*/
      buf_clients.obj-code @ tt-shop.kitchen-store-code
      with frame {&frame-name} .
  end.
  else do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-outpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-outpay Dialog-Frame
ON CHOOSE OF b-outpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.out-pay = buf_pay-type.obj-code .
        display
        tt-shop.out-pay
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-realpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-realpay Dialog-Frame
ON CHOOSE OF b-realpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = ? then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.chk-pay = buf_pay-type.obj-code .
        display
        tt-shop.chk-pay
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-reset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-reset Dialog-Frame
ON CHOOSE OF b-reset IN FRAME Dialog-Frame /* Уст.Сист. */
DO:
  if p-mode = {&add-def} and tt-shop.host-code = 0 then do:
    message
    "Фирма для магазина еще не определена" skip
    "Скопировать настройки с настроек по умолчанию невозможно"
    view-as alert-box error .
    return no-apply.
  end.
  message
  "Скопировать настройки для данного магазина" skip
  "из аналогичных настроек для всей системы?" view-as alert-box question
  buttons yes-no set OK as log .
  if OK then do:
    run reset-from-sysconf in this-procedure ( input yes
                                             , input tt-shop.host-code
                                                      ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-retpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-retpay Dialog-Frame
ON CHOOSE OF b-retpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.ret-pay = buf_pay-type.obj-code .
        display
        tt-shop.ret-pay
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spipay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spipay Dialog-Frame
ON CHOOSE OF b-spipay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.down-pay = buf_pay-type.obj-code .
        display
        tt-shop.down-pay
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sub-store
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sub-store Dialog-Frame
ON CHOOSE OF b-sub-store IN FRAME Dialog-Frame
DO:
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define variable rid-list as character no-undo .

  define buffer buf_clients for ub.clients.
  run ref/cli-all.w (   input parparentproc
                  ,input "b-sel"
                  ,input {&g___object}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "lock-cli-type":U
                  ,output rid-list) no-error.
  if rid-list = '':U then return no-apply.
  find first buf_clients where recid (buf_clients) = integer (rid-list) no-lock no-error.
  if available buf_clients
  then do:
    if input frame {&frame-name} tt-clients.db-num <> buf_clients.db-num
    then do:
        message "Нельзя в качестве склада подсобки указать объект другой БД!"
        view-as alert-box error.
        return no-apply.
    end.
    display
    buf_clients.obj-type @ tt-shop.sub-store-type
    buf_Clients.obj-code @ tt-shop.sub-store-code
    with frame {&frame-name} .
  end.
  else do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-suppay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-suppay Dialog-Frame
ON CHOOSE OF b-suppay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-shop.ret-sup-pay = buf_pay-type.obj-code .
        display
               tt-shop.ret-sup-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-tocd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tocd Dialog-Frame
ON CHOOSE OF b-tocd IN FRAME Dialog-Frame /* На кассу */
DO:
  if  tt-shop.host-code = 0
  or tt-shop.host-code = ?
  then do:
    message "Фирма не выбрана ! "
            view-as alert-box error.
    return no-apply.
  end.

    assign
    all-prt_ = tt-shop.all-prt
    cd-bc-alt_ = tt-shop.cd-bc-alt
    cd-bc-base_ = tt-shop.cd-bc-base
    cd-loc-alt_ = tt-shop.cd-loc-alt
    cd-loc-base_ = tt-shop.cd-loc-base
    cd-parts-all_ = tt-shop.cd-parts-all
    cd-parts-not-blank_ = tt-shop.cd-parts-not-blank
    cd-parts-ser_ = tt-shop.cd-parts-ser
    cd-pb-alt_ = tt-shop.cd-pb-alt
    cd-pb-base_ = tt-shop.cd-pb-base
    cd-sc-base_ = tt-shop.cd-sc-base.
    run adm/to-cd.w (
                   INPUT p-mode
                  ,INPUT tt-shop.host-code
                  ,INPUT {&shop}
                  ,INPUT tt-shop.obj-code
                  ,INPUT ("Параметры отсылки товаров на кассу для магазина " +
                  string(tt-shop.obj-code) + " фирмы " + string(tt-shop.host-code))
                  ,INPUT-OUTPUT all-prt_
                  ,INPUT-OUTPUT cd-bc-alt_
                  ,INPUT-OUTPUT cd-bc-base_
                  ,INPUT-OUTPUT cd-loc-alt_
                  ,INPUT-OUTPUT cd-loc-base_
                  ,INPUT-OUTPUT cd-parts-all_
                  ,INPUT-OUTPUT cd-parts-not-blank_
                  ,INPUT-OUTPUT cd-parts-ser_
                  ,INPUT-OUTPUT cd-pb-alt_
                  ,INPUT-OUTPUT cd-pb-base_
                  ,INPUT-OUTPUT cd-sc-base_) no-error.
    if error-status:error then return no-apply.
    assign
    tt-shop.all-prt             = all-prt_
    tt-shop.cd-bc-alt           = cd-bc-alt_
    tt-shop.cd-bc-base          = cd-bc-base_
    tt-shop.cd-loc-alt          = cd-loc-alt_
    tt-shop.cd-loc-base         = cd-loc-base_
    tt-shop.cd-parts-all        = cd-parts-all_
    tt-shop.cd-parts-not-blank  = cd-parts-not-blank_
    tt-shop.cd-parts-ser        = cd-parts-ser_
    tt-shop.cd-pb-alt           = cd-pb-alt_
    tt-shop.cd-pb-base          = cd-pb-base_
    tt-shop.cd-sc-base          = cd-sc-base_
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_trn-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_trn-reason Dialog-Frame
ON CHOOSE OF Btn_trn-reason IN FRAME Dialog-Frame /* Коды оснований */
DO:
  run str/obj-rsn.w ( input parparentproc
                , input {&shop}
                , input p-obj-code
                , input ( if p-mode = {&lookup} then {&lookup} else {&work} )
                ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CliPS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CliPS Dialog-Frame
ON CHOOSE OF CliPS IN FRAME Dialog-Frame /* Доп. инф. */
DO:
    run proc-save in this-procedure (no).
    if p-mode = {&add-def} then do:
      find first tt-shop.
      find first tt-clients.
    end.
    run adm/shop-ps.w (
                  input parparentproc
                , input p-mode
                , input tt-shop.obj-code
                 ) no-error .
    if error-status:error then do:

      return no-apply.
    end.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME









/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-clients.db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-clients.db-num Dialog-Frame
ON CTRL-enter OF tt-clients.db-num IN FRAME Dialog-Frame /* Номер БД */
DO:
  define variable  ri as recid no-undo.
  define buffer buf_db for ub.db .
  run adm/dbs.w (
                input parparentproc
               ,input {&lookup}
               ,output ri).

  if ri <> ? then  do:
    FIND first buf_db where recid( ub.db ) = ri .
    display
    buf_db.db-num @ tt-clients.db-num
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-clients.db-num Dialog-Frame
ON RETURN OF tt-clients.db-num IN FRAME Dialog-Frame /* Номер БД */
DO:
  RUN chk-db no-error.
  if error-status:error  THEN do:
    apply "ctrl-enter":U to self.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-shop.doc-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-shop.doc-prt Dialog-Frame
ON VALUE-CHANGED OF tt-shop.doc-prt IN FRAME Dialog-Frame /* Учет по шкалам */
DO:
define variable glog as logical no-undo .
  if p-mode <> {&add-def} then do:
    if (tt-shop.doc-prt:checked ) <> tt-shop.doc-prt
    then do:
      run trg/objatchk.p
        (input {&shop}          /* p-obj-type  */
        ,input tt-shop.obj-code /* p-obj-code  */
        ,input "doc-prt":u       /* p-action    */
        ,input tt-shop.doc-prt :checked in frame {&frame-name}  /* p-new-value */
        ) no-error .
      if error-status :error then do:
        assign
        tt-shop.doc-prt :checked in frame {&frame-name} = tt-shop.doc-prt
        .
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-shop.is-kitchen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-shop.is-kitchen Dialog-Frame
ON VALUE-CHANGED OF tt-shop.is-kitchen IN FRAME Dialog-Frame /* Кухня(объект производства) */
DO:
assign tt-shop.is-kitchen.
  run on-off-kitchen in this-procedure(tt-shop.is-kitchen) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-choose Dialog-Frame
ON CHOOSE OF MENU-ITEM m-choose /* Подобрать свободный код */
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w ({&shop}, v-cntxt-db-num, OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-shop.obj-code
    with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-shop.obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-shop.obj-code Dialog-Frame
ON LEAVE OF tt-shop.obj-code IN FRAME Dialog-Frame /*  Код */
DO:
 define variable choice as integer no-undo .
 define variable glog as logical no-undo .
 if input frame {&frame-name} tt-shop.obj-code > 999
 and  p-mode = {&add-def} then do:
  glog = no.
  run gbl/d-askw.w (input "Рекомендация",
                        input  ("Код нового магазина рекомендуется сделать меньшим 1000," + {&new-line}
                                + "иначе у Вас могут возникнуть проблемы при работе с кассой IBM"),
                        input "|",
                        input "Продолжить с выбранным номером магазина|Отменить",
                        input "|",
                        input 1,
                        input 2,
                        output choice).
    if choice = 2
    then do:
        apply "ENTRY":U to tt-shop.obj-code IN frame {&frame-name}.
        return no-apply.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-shop.shift-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-shop.shift-on Dialog-Frame
ON VALUE-CHANGED OF tt-shop.shift-on IN FRAME Dialog-Frame /* Включены смены */
DO:
  if p-mode <> {&add-def} then do:
    if tt-shop.shift-on :checked in frame {&frame-name} <> tt-shop.shift-on
    then do:
      run trg/objatchk.p
        (input {&shop}          /* p-obj-type  */
        ,input tt-shop.obj-code /* p-obj-code  */
        ,input "shift-on":u       /* p-action    */
        ,input tt-shop.shift-on :checked in frame {&frame-name}  /* p-new-value */
        ) no-error .
      if error-status :error
      then do:
        assign
        tt-shop.shift-on :checked in frame {&frame-name} = tt-shop.shift-on
        .
        return no-apply .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-shop.sub-store-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-shop.sub-store-on Dialog-Frame
ON VALUE-CHANGED OF tt-shop.sub-store-on IN FRAME Dialog-Frame /* Склад-подсобка */
DO:
  if input frame {&frame-name} tt-shop.sub-store-on = yes
  then do:
    ENABLE
    b-sub-store
    with frame {&frame-name}.
  end.
  else do:
    DISABLE
    b-sub-store
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varenvd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varenvd Dialog-Frame
ON VALUE-CHANGED OF varenvd IN FRAME Dialog-Frame /* ЕНВД */
DO:
  ASSIGN FRAME {&FRAME-NAME}
    varenvd.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpharm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpharm Dialog-Frame
ON VALUE-CHANGED OF varpharm IN FRAME Dialog-Frame /* Аптека */
DO:
  ASSIGN FRAME {&FRAME-NAME}
    VARpharm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpurch-code-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpurch-code-name Dialog-Frame
ON VALUE-CHANGED OF varpurch-code-name IN FRAME Dialog-Frame /* Тип приобретения */
DO:
  ASSIGN FRAME {&FRAME-NAME} varpurch-code-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
if p-mode <> {&lookup} then do:
  if v-db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи МАГАЗИН в УБД"
    view-as alert-box ERROR.
    undo, return error.
  end.
end.
for each tt-shop:
  delete tt-shop.
end.
for each tt-clients:
  delete tt-clients.
end.

if p-mode = {&add-def}  then do:
    message
    "Вам следует выбрать группу," skip
    "к которой будет относиться магазин."
    view-as alert-box.
    ref-list = "".
    run ref/cli-grps.w ( input parparentproc, "b-sel", input-output ref-list ) .
    if ref-list <> "" then  do:
      FIND buf_cli-grp where
          recid( buf_cli-grp ) = integer( ref-list ) .
      if can-find( FIRST ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code )
      then do:
        message
        "Добавлять можно только в группы," skip
        "у которых нет подгрупп." skip
        "Выбирайте другую группу !".
        return .
      end.
    end.
    else return .
    create tt-clients.
    create tt-shop.
    assign
    tt-clients.grp-code = buf_cli-grp.node-code
    tt-clients.obj-type = {&shop}
    tt-shop.discaloc = yes
    tt-shop.doc-prt = false
    tt-shop.work-hours = if tt-shop.work-hours <> "" then tt-shop.work-hours else "08.00,20.00"
    .
  end.
  else do: /*no add-def*/
    if p-mode = {&update} then do:
      do transaction
      ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

        FIND first locked_clients exclusive-lock where
                recid( locked_clients ) = p-rid no-error .
        if not available locked_clients then do:
          FIND first locked_clients exclusive-lock where
                  locked_clients.obj-type = {&shop}
                AND locked_clients.obj-code = p-obj-code no-wait no-error .
        if locked locked_clients then do:
          message
          vss-workfile vss-revision vss-description skip
          "Запись КЛИЕНТ для МАГАЗИНА" p-obj-code "занята"
          view-as alert-box error .
          undo, return error.
        end.
        end.
        FIND first locked_shop exclusive-lock where
                  locked_shop.obj-code = locked_clients.obj-code .
      end.
    end.
    if p-mode = {&lookup} then do:
      FIND first locked_clients no-lock where
              recid( locked_clients ) = p-rid.
      FIND first locked_shop no-lock where
                locked_shop.obj-code = locked_clients.obj-code .
    end.
    create tt-clients.
    create tt-shop.
    buffer-copy locked_clients to tt-clients.
    buffer-copy locked_shop to tt-shop.
    FIND FIRST buf_cli-host NO-LOCK WHERE
               buf_cli-host.obj-code = locked_shop.host-code AND
               buf_cli-host.obj-type = {&cmp} NO-ERROR.
      if avail buf_cli-host then do:
        assign
        frame {&frame-name}:title =
        "Настройки магазина фирмы ~"" + buf_cli-host.obj-name +
        "~" ("   + string( tt-shop.host-code )   + ").".
      end.
    end.
    assign
    tt-shop.work-hours = if tt-shop.work-hours <> "" then tt-shop.work-hours else "08.00,20.00"
    .
    assign
    all-prt_ = tt-shop.all-prt
    cd-bc-alt_ = tt-shop.cd-bc-alt
    cd-bc-base_ = tt-shop.cd-bc-base
    cd-loc-alt_ = tt-shop.cd-loc-alt
    cd-loc-base_ = tt-shop.cd-loc-base
    cd-parts-all_ = tt-shop.cd-parts-all
    cd-parts-not-blank_ = tt-shop.cd-parts-not-blank
    cd-parts-ser_ = tt-shop.cd-parts-ser
    cd-pb-alt_ = tt-shop.cd-pb-alt
    cd-pb-base_ = tt-shop.cd-pb-base
    cd-sc-base_ = tt-shop.cd-sc-base
    .
 ASSIGN
    varpurch-code-name:LIST-ITEMS = {&purch-like-firm} + "," + {&purchase-codes-full}.
  IF tt-shop.purch-code = ? THEN DO:
    ASSIGN
      varpurch-code-name = {&purch-like-firm}.
  END.
  ELSE DO:
    &scop purchase-code string(tt-shop.purch-code)
    assign
      varpurch-code-name = {&purchase-codes-name}.
  END.

  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT {&shop},
     INPUT tt-shop.obj-code,
     input {&attr-pharm},
     OUTPUT v-pharm,
     OUTPUT var-type).
  IF v-pharm = "yes":u THEN DO:
    ASSIGN
      varpharm = YES.
  END.
  ELSE DO:
    ASSIGN
      varpharm = NO.
  END.

  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT {&shop},
     INPUT tt-shop.obj-code,
     input {&attr-envd},
     OUTPUT v-envd,
     OUTPUT var-type).
  IF v-envd = "yes":u THEN DO:
    ASSIGN
      varenvd = YES.
  END.
  ELSE DO:
    ASSIGN
      varenvd = NO.
  END.
  /* КПП */
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT {&shop},
     INPUT tt-shop.obj-code,
     input {&attr-kpp},
     OUTPUT v-kpp,
     OUTPUT var-type).
   kpp:screen-value = v-kpp.
  
   run init-firmhold in this-procedure.
















  RUN Myenable.
  if p-mode = {&add-def} then
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-shop.obj-code.
  else
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-clients.obj-name .
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-db Dialog-Frame 
PROCEDURE chk-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   if ( not can-find( ub.db where ub.db.db-num = input FRAME {&frame-name} tt-clients.db-num ))
  then do:
      message "Неверный номер. Номер может быть:" skip
                      "    0, 1, ... -- номер существующей БД" skip
                    /*  "    ?  -- объект не принадлежит ни какой БД"  skip*/
                    /* "    - 1 -- объект принадлежит всем БД." skip( 2 )*/
                      " CTRL-ENTER  -- вызов справочника."  view-as alert-box.
      apply "ENTRY":U  to tt-clients.db-num IN FRAME {&frame-name}.
      return error.
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
  DISPLAY KPP varpurch-code-name varenvd varpharm fi-holdfirm-code 
          fi-holdfirm-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN 
    DISPLAY tt-clients.db-num tt-clients.obj-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN 
    DISPLAY tt-shop.obj-code tt-shop.director tt-shop.addres1 tt-shop.phone 
          tt-shop.addres2 tt-shop.fax tt-shop.rsrv-time tt-shop.doc-prt 
          tt-shop.price-calc tt-shop.in-pay tt-shop.no-eq tt-shop.out-pay 
          tt-shop.unit-cli-perm tt-shop.ret-pay tt-shop.out-rate tt-shop.in-perm 
          tt-shop.ret-sup-pay tt-shop.out-line-discnt tt-shop.down-pay 
          tt-shop.in-ov tt-shop.inv-pay tt-shop.inout-price tt-shop.chk-pay 
          tt-shop.day-only tt-shop.fbr-pay tt-shop.buy-goods tt-shop.with-serv 
          tt-shop.pr-cash tt-shop.sub-store-type tt-shop.sub-store-code 
          tt-shop.discaloc tt-shop.shift-on tt-shop.kitchen-store-code 
          tt-shop.sub-store-on tt-shop.is-catering tt-shop.is-kitchen 
          tt-shop.is-kitchen-store 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-10 RECT-kitchen-store RECT-sub-store b-quit b-reset CliPS 
         b-tocd b-host tt-clients.db-num b-db B-hist B-Help tt-shop.obj-code 
         tt-clients.obj-name B-attr Btn_trn-reason tt-shop.director 
         tt-shop.addres1 tt-shop.phone tt-shop.addres2 tt-shop.fax 
         tt-shop.rsrv-time tt-shop.doc-prt tt-shop.price-calc tt-shop.in-pay 
         b-inpay tt-shop.no-eq tt-shop.out-pay b-outpay tt-shop.unit-cli-perm 
         tt-shop.ret-pay b-retpay tt-shop.out-rate tt-shop.in-perm 
         tt-shop.ret-sup-pay b-suppay tt-shop.out-line-discnt tt-shop.down-pay 
         b-spipay tt-shop.in-ov tt-shop.inv-pay b-invpay tt-shop.inout-price 
         tt-shop.chk-pay b-realpay tt-shop.day-only tt-shop.fbr-pay b-fbrpay 
         tt-shop.buy-goods tt-shop.with-serv tt-shop.pr-cash 
         tt-shop.sub-store-type tt-shop.sub-store-code b-sub-store 
         tt-shop.discaloc tt-shop.shift-on tt-shop.kitchen-store-code 
         b-kitchen-store tt-shop.sub-store-on tt-shop.is-catering 
         tt-shop.is-kitchen b-holdfirm tt-shop.is-kitchen-store 
         varenvd varpharm 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-firmhold Dialog-Frame 
PROCEDURE init-firmhold :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-outhold       as character    no-undo.
    define variable v-par-type      as character    no-undo.
    define variable v-firm-code-str as character    no-undo.
    define variable v-firm-code     as integer      no-undo.

    define buffer buf_clients   for ub.clients.
    define buffer buf_shop      for ub.shop.
do
for buf_clients
  , buf_shop
on error undo, return error
:
    if available tt-shop
    and tt-shop.host-code <> 0
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = tt-shop.obj-code
        no-error.
        if available buf_shop
        then do:
            run gbl/conf-rd.p (
                input "outhold":U
                , input tt-shop.host-code
                , input {&shop}            /*p-obj-type*/
                , input tt-shop.obj-code   /*p-obj-code*/
                , input "":U
                , input "":U
                , input "":U
                , input no
                , output v-outhold
                , output v-par-type
            ) no-error.
            if error-status :error
            then do:
                assign
                    v-outhold            = ""
                .
            end.
            if v-outhold <> "":U
            then do:
                assign
                    v-shopi-have-holdfirm                              = yes
                .
                run clntattr-value in this-procedure (
                    input {&shop}
                    , input tt-shop.obj-code
                    , input {&attr-holdfirm-code}
                    , output v-firm-code-str
                    , output v-par-type
                ).
                assign
                    v-firm-code = integer( v-firm-code-str )
                no-error.
                if error-status :error
                then do:
                    assign
                        v-firm-code = 0
                    .
                end.
                else do:
                    if v-firm-code = 0
                    then do:
                        assign
                            fi-holdfirm-code = 0
                            fi-holdfirm-name = "":U
                        .
                    end.
                    else do:
                        find first buf_clients no-lock
                            where buf_clients.obj-type = {&cmp}
                            and buf_clients.obj-code = v-firm-code
                        no-error.
                        if available buf_clients
                        then do:
                            assign
                                fi-holdfirm-code = v-firm-code
                                fi-holdfirm-name = buf_clients.obj-name
                            .
                        end.
                        else do:
                            assign
                                fi-holdfirm-code = 0
                                fi-holdfirm-name = "":U
                            .
                        end.
                    end.
                end.
            end.
            else do:
                assign
                    v-shopi-have-holdfirm                              = no
                .
            end.
        end.        /* if available buf_shop */
    end.        /* if available tt-shop */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame 
PROCEDURE MyENable :
IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name tt-clients.db-num
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN
    DISPLAY
    tt-shop.obj-code
    tt-shop.director
    tt-shop.phone
    tt-shop.addres1
    tt-shop.addres2
    tt-shop.fax
    tt-shop.rsrv-time
    tt-shop.doc-prt
    tt-shop.price-calc
    tt-shop.in-pay
    tt-shop.no-eq
    tt-shop.out-pay
    tt-shop.unit-cli-perm
    tt-shop.in-perm
    tt-shop.ret-pay
    tt-shop.out-rate
    tt-shop.ret-sup-pay
    tt-shop.fbr-pay
    tt-shop.out-line-discnt
    tt-shop.down-pay
    tt-shop.in-ov
    tt-shop.inv-pay
    tt-shop.inout-price
    tt-shop.chk-pay
    tt-shop.day-only
    tt-shop.buy-goods
    tt-shop.with-serv
    tt-shop.pr-cash
    tt-shop.discaloc
    tt-shop.shift-on
    tt-shop.sub-store-on
    tt-shop.sub-store-type
    tt-shop.sub-store-code
    tt-shop.is-catering
    tt-shop.is-kitchen
    tt-shop.is-kitchen-store
    tt-shop.kitchen-store-code when tt-shop.is-kitchen = yes
    varpurch-code-name
    VARenvd
    varpharm
    
    WITH FRAME Dialog-Frame.
  ENABLE
  RECT-sub-store
  RECT-10
  RECT-kitchen-store
  b-quit
  b-tocd
  CliPS
  B-Help
  b-hist WHEN p-mode <> {&add-def}
  b-attr WHEN p-mode <> {&add-def}
  b-host
  Btn_trn-reason WHEN p-mode <> {&add-def}
  WITH FRAME Dialog-Frame.
  if p-mode = {&lookup} then do:
    hide
    b-exit in frame {&frame-name}.
    assign
    b-quit:label = "&Выход".
  end.
  else do:
    ENABLE
    B-exit
    b-reset
    CliPS
    tt-shop.obj-code    when p-mode = {&add-def}
    tt-clients.obj-name
    tt-shop.director
    tt-shop.phone
    tt-shop.addres1
    tt-shop.addres2
    tt-shop.fax
    tt-shop.rsrv-time
    tt-shop.doc-prt
    tt-shop.price-calc
    tt-shop.in-pay
    b-inpay
    tt-shop.no-eq
    tt-shop.out-pay
    b-outpay
    tt-shop.unit-cli-perm
    tt-shop.in-perm
    tt-shop.ret-pay
    b-retpay
    tt-shop.out-rate
    tt-shop.ret-sup-pay
    b-suppay
    tt-shop.fbr-pay
    b-fbrpay
    tt-shop.out-line-discnt
    tt-shop.down-pay
    b-spipay
    tt-shop.in-ov
    tt-shop.inv-pay
    b-invpay
    tt-shop.inout-price
    tt-shop.chk-pay
    b-realpay
    tt-shop.day-only
    tt-clients.db-num when p-mode = {&add-def}
    b-db when p-mode = {&add-def}
    tt-shop.with-serv
    tt-shop.pr-cash
    tt-shop.shift-on
    tt-shop.sub-store-on
    tt-shop.sub-store-type
    tt-shop.sub-store-code
    b-sub-store when tt-shop.sub-store-on
    tt-shop.is-catering
    tt-shop.is-kitchen
    tt-shop.is-kitchen-store
    b-kitchen-store  when tt-shop.is-kitchen
    varpurch-code-name
    varenvd
    varpharm
    
    KPP
    WITH FRAME {&frame-name} .
  end.
  if p-mode <> {&add-def} then  do:
     run reset-from-sysconf in this-procedure ( input  no
                                               ,input p-host-code).
     MENU-ITEM m-choose:SENSITIVE IN MENU MENU-obj-code = NO .
  end.
  VIEW FRAME {&frame-name}.

    if v-shopi-have-holdfirm = yes
    then do:
        assign
            fi-holdfirm-code :visible   in frame {&frame-name}    = yes
            fi-holdfirm-name :visible   in frame {&frame-name}    = yes
            b-holdfirm       :visible   in frame {&frame-name}    = yes
            fi-holdfirm-code :sensitive in frame {&frame-name}    = no
            fi-holdfirm-name :sensitive in frame {&frame-name}    = no
        .
        if p-mode = {&lookup}
        then do:
            assign
                b-holdfirm       :sensitive in frame {&frame-name}    = no
            .
        end.
        else do:
            assign
                b-holdfirm       :sensitive in frame {&frame-name}    = yes
            .
        end.
        display
            fi-holdfirm-code
            fi-holdfirm-name
        with frame {&frame-name}.
    end.
    else do:
        assign
            fi-holdfirm-code :visible in frame {&frame-name}    = no
            fi-holdfirm-name :visible in frame {&frame-name}    = no
            b-holdfirm       :visible in frame {&frame-name}    = no
        .
    end.
  if p-mode = {&add-def} then do:
    message
    "Вам следует выбрать фирму," skip
    "к которой будет относиться магазин"
    view-as alert-box .
    apply "CHOOSE" to b-host in frame {&frame-name} .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE on-off-kitchen Dialog-Frame 
PROCEDURE on-off-kitchen :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-kitchen like ub.shop.is-kitchen no-undo.
case p-is-kitchen :
    when no then do:
        disable
        b-kitchen-store
        tt-shop.kitchen-store-code
        with frame {&frame-name}
        .
        hide
        b-kitchen-store
        tt-shop.kitchen-store-code
        rect-kitchen-store
        in frame {&frame-name}.
        .
    end.
    when yes then do:
            enable
        b-kitchen-store
        tt-shop.kitchen-store-code
        with frame {&frame-name}
        .
        display
        b-kitchen-store
        tt-shop.kitchen-store-code
        rect-kitchen-store
        with frame {&frame-name}.

    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-save as logical no-undo .

    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
if p-mode =  {&add-def}
and (new-host-code = ?
     or
     new-host-code = 0)
then do:
  message "Фирма не выбрана."
  view-as alert-box error.
  return error.
end.
assign
frame {&frame-name}
tt-shop.obj-code
tt-clients.obj-code         = tt-shop.obj-code
tt-clients.obj-type         = {&shop}
tt-clients.db-num
tt-clients.obj-name
/*tt-clients.PS
tt-shop.acct
*/
tt-shop.addres1
tt-shop.addres2
tt-shop.all-prt             = all-prt_
tt-shop.buy-goods
tt-shop.is-catering
tt-shop.is-kitchen
tt-shop.is-kitchen-store
tt-shop.cd-bc-alt           = cd-bc-alt_
tt-shop.cd-bc-base          = cd-bc-base_
tt-shop.cd-loc-alt          = cd-loc-alt_
tt-shop.cd-loc-base         = cd-loc-base_
tt-shop.cd-parts-all        = cd-parts-all_
tt-shop.cd-parts-not-blank  = cd-parts-not-blank_
tt-shop.cd-parts-ser        = cd-parts-ser_
tt-shop.cd-pb-alt           = cd-pb-alt_
tt-shop.cd-pb-base          = cd-pb-base_
tt-shop.cd-sc-base          = cd-sc-base_
tt-shop.chk-pay
tt-shop.day-only
tt-shop.director
tt-shop.discaloc            = yes
tt-shop.doc-prt
tt-shop.down-pay
/*tt-shop.dst-price*/
tt-shop.fax
/*tt-shop.goods-man           */
/*tt-shop.holidays            =*/
tt-shop.host-code           =  if  tt-shop.host-code = 0
                               or tt-shop.host-code = ?
                               then p-host-code
                               else tt-shop.host-code
tt-shop.in-ov
tt-shop.in-pay
tt-shop.in-perm
tt-shop.inout-price
tt-shop.inv-pay
tt-shop.kitchen-store-code
tt-shop.kitchen-store-code                    =  (if tt-shop.is-kitchen then tt-shop.kitchen-store-code else 0)
tt-shop.kitchen-store-type                    = (if tt-shop.is-kitchen then {&shop} else "":U)
/*tt-shop.load-time*/
tt-shop.no-eq
/*tt-shop.no-short-code*/
tt-shop.out-line-discnt
tt-shop.out-pay
tt-shop.out-rate
tt-shop.phone
tt-shop.pr-cash
tt-shop.price-calc
tt-shop.ret-pay
tt-shop.ret-sup-pay
tt-shop.fbr-pay
tt-shop.rsrv-time
tt-shop.shift-on
/*tt-shop.store-boss
tt-shop.store-man           */
tt-shop.sub-store-on
tt-shop.sub-store-code
tt-shop.sub-store-type
tt-shop.unit-cli-perm
tt-shop.with-serv
/*tt-shop.work-hours          */
.
assign
frame {&frame-name}
    
    KPP
.
if not p-save then return.
if tt-shop.all-prt then do:
  message
    "Передача на кассу ВСЕХ признаков товаров" skip
    "может привести к ПЕРЕПОЛНЕНИЮ базы данных КАССЫ." skip
    view-as alert-box information .
end.

if varpharm = true and  tt-shop.doc-prt = true  then do:
   message "Нельзя на объекте вести сразу учет по шкалам и по партиям. Если Вы уверены что нужно использовать режим АПТЕКА, не используйте шкальный товар !"
   view-as alert-box information .
end.

run adm/shop01.p (
              input-output p-rid
             ,input        p-mode
             ,input    tt-shop.obj-code
             ,input    tt-clients.db-num
             ,input    tt-shop.host-code
             ,input    tt-clients.grp-code
             ,input    tt-clients.obj-name
             ,input    tt-clients.PS
             ,input    tt-shop.acct
             ,input    tt-shop.addres1
             ,input    tt-shop.addres2
             ,input    tt-shop.all-prt
             ,input    tt-shop.buy-goods
             ,input    tt-shop.cd-bc-alt
             ,input    tt-shop.cd-bc-base
             ,input    tt-shop.cd-loc-alt
             ,input    tt-shop.cd-loc-base
             ,input    tt-shop.cd-parts-all
             ,input    tt-shop.cd-parts-not-blank
             ,input    tt-shop.cd-parts-ser
             ,input    tt-shop.cd-pb-alt
             ,input    tt-shop.cd-pb-base
             ,input    tt-shop.cd-sc-base
             ,input    tt-shop.chk-pay
             ,input    tt-shop.day-only
             ,input    tt-shop.director
             ,input    tt-shop.discaloc
             ,input    tt-shop.doc-prt
             ,input    tt-shop.down-pay
             /*,input    tt-shop.p.dst-price              */
             ,input    tt-shop.fax
             ,input    tt-shop.goods-man
             /*,input    tt-shop.p.holidays               */
             ,input    tt-shop.in-ov
             ,input    tt-shop.in-pay
             ,input    tt-shop.in-perm
             ,input    tt-shop.inout-price
             ,input    tt-shop.inv-pay
             ,input    tt-shop.is-catering
             ,input    tt-shop.is-kitchen
             ,input    tt-shop.is-kitchen-store
             ,input    tt-shop.kitchen-store-code
             ,input    tt-shop.kitchen-store-type
             /*,input    tt-shop.load-time                */
             ,input    tt-shop.no-eq
             /*,input    tt-shop.no-short-code            */
             ,input    tt-shop.out-line-discnt
             ,input    tt-shop.out-pay
             ,input    tt-shop.out-rate
             ,input    tt-shop.phone
             ,input    tt-shop.pr-cash
             ,input    tt-shop.price-calc
             ,input    tt-shop.ret-pay
             ,input    tt-shop.ret-sup-pay
             ,input    tt-shop.fbr-pay
             ,input    tt-shop.rsrv-time
             ,input    tt-shop.shift-on
             ,input    tt-shop.store-boss
             ,input    tt-shop.store-man
             ,input    tt-shop.sub-store-on
             ,input    tt-shop.sub-store-code
             ,input    tt-shop.sub-store-type
             ,input    tt-shop.unit-cli-perm
             ,input    tt-shop.with-serv
             ,input    tt-shop.work-hours
             ,input    (if varpurch-code-name = {&purch-like-firm} then ? else lookup (varpurch-code-name, {&purchase-codes-full}))
             ,INPUT    varenvd
             ,INPUT    varpharm
             
             ,input    KPP
            )
             no-error .
if error-status:error then do:
  define variable l-ret-widg as character no-undo .
  define variable l-ret-text as character no-undo .
  assign
    l-ret-widg = entry(1, return-value, {&delim-par})
    l-ret-text = entry(2, return-value, {&delim-par})
  .
  message l-ret-text view-as alert-box error .
  /* к этому моменту return-value должно было ещё сохраниться;
     если не сохранится - замените вызов инклюда на  { gbl/reterhnd.i &1 = error &4 = l-ret-widg }
  */   
 { gbl/reterhnd.i error }
  undo, return error.
end.
    assign
        fi-holdfirm-code
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = fi-holdfirm-code
    no-error.
    if available buf_clients
    then do:
        run clntattr-write in this-procedure (
              input {&shop}
            , input tt-shop.obj-code
            , input {&attr-holdfirm-code}
            , input string( fi-holdfirm-code )
        ).
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reset-from-sysconf Dialog-Frame 
PROCEDURE reset-from-sysconf :
define  input parameter p-reset as logical no-undo.
define input parameter p-host-code as integer no-undo .
define buffer buf_sysconf for ub.sysconf.
if p-reset then   do:
    FIND first buf_sysconf where
            buf_sysconf.host-code = p-host-code.
    assign
        tt-shop.unit-cli-perm = buf_sysconf.unit-cli-perm
        tt-shop.in-ov = buf_sysconf.in-ov
        tt-shop.in-perm = buf_sysconf.in-perm
        tt-shop.inout-price = buf_sysconf.inout-price
        tt-shop.no-eq = buf_sysconf.no-eq
        tt-shop.out-line-discnt = buf_sysconf.out-line-discnt
        tt-shop.out-rate = buf_sysconf.out-rate
        tt-shop.price-calc = buf_sysconf.price-calc
        tt-shop.chk-pay = buf_sysconf.chk-pay
        tt-shop.down-pay = buf_sysconf.down-pay
        tt-shop.in-pay  = buf_sysconf.in-pay
        tt-shop.inv-pay  = buf_sysconf.inv-pay
        tt-shop.out-pay  = buf_sysconf.out-pay
        tt-shop.ret-pay = buf_sysconf.ret-pay
        tt-shop.ret-sup-pay = buf_sysconf.ret-sup-pay
        tt-shop.fbr-pay = buf_sysconf.fbr-pay
        tt-shop.rsrv-time  = buf_sysconf.rsrv-time
        tt-shop.cd-bc-alt  = buf_sysconf.cd-bc-alt
        tt-shop.cd-bc-base = buf_sysconf.cd-bc-base
        tt-shop.cd-loc-alt = buf_sysconf.cd-loc-alt
        tt-shop.cd-loc-base = buf_sysconf.cd-loc-base
        tt-shop.cd-parts-all = buf_sysconf.cd-parts-all
        tt-shop.cd-parts-not-blank = buf_sysconf.cd-parts-not-blank
        tt-shop.cd-parts-ser = buf_sysconf.cd-parts-ser
        tt-shop.cd-pb-alt = buf_sysconf.cd-pb-alt
        tt-shop.cd-pb-base = buf_sysconf.cd-pb-base
        tt-shop.cd-sc-base = buf_sysconf.cd-sc-base
        tt-shop.all-prt = buf_sysconf.all-prt
        .
end.
display
tt-shop.unit-cli-perm
tt-shop.in-ov
tt-shop.in-perm
tt-shop.inout-price
tt-shop.no-eq
tt-shop.out-line-discnt
tt-shop.out-rate
tt-shop.price-calc

tt-shop.chk-pay
tt-shop.down-pay
tt-shop.in-pay
tt-shop.out-pay
tt-shop.inv-pay
tt-shop.ret-pay
tt-shop.ret-sup-pay
tt-shop.fbr-pay
tt-shop.rsrv-time

with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

