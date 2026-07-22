&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_currency FOR ub.currency.
DEFINE BUFFER locked_firm FOR ub.firm.
DEFINE BUFFER locked_sysconf FOR ub.sysconf.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-firm NO-UNDO LIKE ub.firm.
DEFINE TEMP-TABLE tt-sysconf NO-UNDO LIKE ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Исаков Андрей Валерьевич
10/22/94

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc  as   widget-handle        no-undo .
define input parameter p-host-code    like ub.sysconf.host-code no-undo .
define input parameter p-mode         as   character            no-undo .
define input parameter p-is-deploy    as   logical              no-undo . /* режим первоначальной раскрутки */

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Настройки фирмы":U .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/clntattr.i }
{ gbl/thbj-def.i }
{ gbl/thbjattr.i }
{ adm/shattrg.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/waitfram.i }

define variable conf-par as   character    no-undo . /* для чтения параметра конфигурации */
define variable par-type as   character    no-undo . /* тип параметра конфигурации */
define variable v-db-num like ub.db.db-num no-undo .
define variable hold     as   character    no-undo . /* есть ли межфирменные архивы */
define variable ref-list as   character    no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_cli-grp for ub.cli-grp.
DEFINE BUFFER buf_curr-chk FOR ub.currency.
define buffer buf_cp_credit-pay for ub.cash-pay.
define buffer buf_pt_ret-credit-pay for ub.pay-type.
define buffer buf_pt_cash-pay for ub.pay-type.
define buffer buf_cli_sale-code for ub.clients.




{ cmp/titlmode.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-sysconf tt-clients tt-firm

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-sysconf.host-code ~
tt-clients.obj-name tt-sysconf.base-code tt-sysconf.sale-type ~
tt-sysconf.sale-code tt-sysconf.cash-pay tt-sysconf.credit-pay ~
tt-sysconf.cons-vat-pc tt-sysconf.ret-credit-pay tt-sysconf.osn-base ~
tt-sysconf.negative-rest tt-sysconf.avrg-price tt-sysconf.artic-disable ~
tt-sysconf.gen-s-f-office tt-firm.main-obj-code tt-firm.main-obj-type ~
tt-sysconf.head-position tt-sysconf.snr-accnt tt-sysconf.cashier ~
tt-sysconf.branch tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-sysconf.sale-type ~
tt-sysconf.sale-code tt-sysconf.cash-pay tt-sysconf.credit-pay ~
tt-sysconf.cons-vat-pc tt-sysconf.ret-credit-pay tt-sysconf.negative-rest ~
tt-sysconf.avrg-price tt-sysconf.artic-disable tt-sysconf.gen-s-f-office ~
tt-firm.main-obj-code tt-firm.main-obj-type tt-sysconf.head-position ~
tt-sysconf.snr-accnt tt-sysconf.cashier tt-sysconf.branch ~
tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-sysconf tt-firm
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-sysconf
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-firm
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-sysconf SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.clients incomplete */ SHARE-LOCK, ~
      EACH tt-firm WHERE TRUE /* Join to ub.clients incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-sysconf SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.clients incomplete */ SHARE-LOCK, ~
      EACH tt-firm WHERE TRUE /* Join to ub.clients incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-sysconf tt-clients tt-firm
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-sysconf
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame tt-firm


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-sysconf.sale-type tt-sysconf.sale-code ~
tt-sysconf.cash-pay tt-sysconf.credit-pay tt-sysconf.cons-vat-pc ~
tt-sysconf.ret-credit-pay tt-sysconf.negative-rest tt-sysconf.avrg-price ~
tt-sysconf.artic-disable tt-sysconf.gen-s-f-office tt-firm.main-obj-code ~
tt-firm.main-obj-type tt-sysconf.head-position tt-sysconf.snr-accnt ~
tt-sysconf.cashier tt-sysconf.branch tt-sysconf.property tt-sysconf.KOPF ~
tt-sysconf.SOEI
&Scoped-define ENABLED-TABLES tt-sysconf tt-firm
&Scoped-define FIRST-ENABLED-TABLE tt-sysconf
&Scoped-define SECOND-ENABLED-TABLE tt-firm
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-transport Btn_trn-reason ~
B-attr B-hist B-Help RECT-1 RECT-2 b-base-code B-sale-type-code B-cash-pay ~
B-credit-pay B-ret-credit-pay varpurch-name varals-gds fi-egrip-date ~
fi-egrip-num B-hold-obj sale-code-name cash-pay-name credit-pay-name ~
ret-credit-pay-name hold-arh-title main-obj-title main-obj-name
&Scoped-Define DISPLAYED-FIELDS tt-sysconf.host-code tt-clients.obj-name ~
tt-sysconf.base-code tt-sysconf.sale-type tt-sysconf.sale-code ~
tt-sysconf.cash-pay tt-sysconf.credit-pay tt-sysconf.cons-vat-pc ~
tt-sysconf.ret-credit-pay tt-sysconf.osn-base tt-sysconf.negative-rest ~
tt-sysconf.avrg-price tt-sysconf.artic-disable tt-sysconf.gen-s-f-office ~
tt-firm.main-obj-code tt-firm.main-obj-type tt-sysconf.head-position ~
tt-sysconf.snr-accnt tt-sysconf.cashier tt-sysconf.branch ~
tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI
&Scoped-define DISPLAYED-TABLES tt-sysconf tt-clients tt-firm
&Scoped-define FIRST-DISPLAYED-TABLE tt-sysconf
&Scoped-define SECOND-DISPLAYED-TABLE tt-clients
&Scoped-define THIRD-DISPLAYED-TABLE tt-firm
&Scoped-Define DISPLAYED-OBJECTS base-code-name varpurch-name varals-gds ~
fi-egrip-date fi-egrip-num sale-code-name cash-pay-name credit-pay-name ~
ret-credit-pay-name hold-arh-title main-obj-title main-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-host-code
       MENU-ITEM m_choose       LABEL "Подобрать свободный код".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-attr
     LABEL "&Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-base-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-cash-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-credit-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-hold-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-ret-credit-pay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-sale-type-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-transport
     LABEL "Т&ранспорт"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_trn-reason
     LABEL "Коды оснований (причин)"
     SIZE 25 BY 1 TOOLTIP "Код оснований (причин) создания документов по умолчанию на фирме".

DEFINE VARIABLE varpurch-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE base-code-name AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 6.6 BY 1 TOOLTIP "Аббревиатура базовой валюты"
     BGCOLOR 3 FGCOLOR 15 .

DEFINE VARIABLE cash-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE credit-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE fi-egrip-date AS DATE FORMAT "99.99.9999":U
     LABEL "ЕГРИП Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-egrip-num AS CHARACTER FORMAT "X(15)":U
     LABEL "номер"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE hold-arh-title AS CHARACTER FORMAT "X(256)":U INITIAL "Межфирменные архивы"
      VIEW-AS TEXT
     SIZE 20.8 BY .57 NO-UNDO.

DEFINE VARIABLE main-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40.3 BY .87 NO-UNDO.

DEFINE VARIABLE main-obj-title AS CHARACTER FORMAT "X(256)":U INITIAL "Главный объект:"
      VIEW-AS TEXT
     SIZE 19.6 BY .77 NO-UNDO.

DEFINE VARIABLE ret-credit-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE sale-code-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 57 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.8 BY 7.53.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 90.6 BY 1.3.

DEFINE VARIABLE varals-gds AS LOGICAL INITIAL no
     LABEL "Торговля чужим товаром"
     VIEW-AS TOGGLE-BOX
     SIZE 34.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-sysconf,
      tt-clients,
      tt-firm SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-transport AT ROW 1 COL 34
     Btn_trn-reason AT ROW 1 COL 44
     B-attr AT ROW 1 COL 69
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-sysconf.host-code AT ROW 2 COL 7 COLON-ALIGNED
          LABEL "Фирма" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 6 BY 1 TOOLTIP "Код текущей фирмы (доступен только при добавлении)"
          BGCOLOR 3 FGCOLOR 15
     tt-clients.obj-name AT ROW 2 COL 13.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 45.6 BY 1 TOOLTIP "Название фирмы (видно только для текущей фирмы)"
          BGCOLOR 3 FGCOLOR 15
     tt-sysconf.base-code AT ROW 2 COL 76 COLON-ALIGNED
          LABEL "Базовая валюта"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Код базовой валюты для текущей фирмы (доступен при добавлении фирмы)"
          BGCOLOR 3 FGCOLOR 15
     b-base-code AT ROW 2 COL 82.5 WIDGET-ID 4
     base-code-name AT ROW 2 COL 86.5 COLON-ALIGNED NO-LABEL
     tt-sysconf.sale-type AT ROW 3.27 COL 21 COLON-ALIGNED
          LABEL "Тип и код реализации"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Тип контрагента для розничных продаж"
     tt-sysconf.sale-code AT ROW 3.27 COL 26 COLON-ALIGNED NO-LABEL FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Код контрагента для розничных продаж"
     B-sale-type-code AT ROW 3.27 COL 38.5 WIDGET-ID 10
     tt-sysconf.cash-pay AT ROW 4.37 COL 15 COLON-ALIGNED
          LABEL "Опл. наличными"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     B-cash-pay AT ROW 4.37 COL 22.5 WIDGET-ID 8
     tt-sysconf.credit-pay AT ROW 4.37 COL 69 COLON-ALIGNED
          LABEL "Платеж в кредит на кассе"
          VIEW-AS FILL-IN
          SIZE 5 BY 1 TOOLTIP "Код оплаты товаров, продаваемых в кредит в розницу"
     B-credit-pay AT ROW 4.37 COL 76
     tt-sysconf.cons-vat-pc AT ROW 5.5 COL 21 COLON-ALIGNED
          LABEL "Консигнационный НДС"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-sysconf.ret-credit-pay AT ROW 5.5 COL 69 COLON-ALIGNED
          LABEL "Опл. долгов по кредиту" FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     B-ret-credit-pay AT ROW 5.5 COL 76
     tt-sysconf.osn-base AT ROW 6.5 COL 1.8
          LABEL "Учет ОС в баз. вал."
          VIEW-AS TOGGLE-BOX
          SIZE 27.8 BY .83 TOOLTIP "Учет ОС не только в abbr_rublyah, но и в баз. вал."
     tt-sysconf.negative-rest AT ROW 6.5 COL 31.3
          LABEL "Отрицательные остатки"
          VIEW-AS TOGGLE-BOX
          SIZE 24.3 BY .83 TOOLTIP "Начальное значение при добавлении новых товаров"
     varpurch-name AT ROW 6.5 COL 72 COLON-ALIGNED
     tt-sysconf.avrg-price AT ROW 7.5 COL 1.8
          LABEL "Посредник (для отчетов)"
          VIEW-AS TOGGLE-BOX
          SIZE 27.3 BY .83 TOOLTIP "Считать данную фирму посредником для отчетов"
     tt-sysconf.artic-disable AT ROW 7.5 COL 31.3
          LABEL "Автомат. артикул"
          VIEW-AS TOGGLE-BOX
          SIZE 24.8 BY .83 TOOLTIP "Начальное значение при добавлении новых товаров"
     varals-gds AT ROW 7.5 COL 56.6
     tt-sysconf.gen-s-f-office AT ROW 8.47 COL 56.6 WIDGET-ID 2
          VIEW-AS TOGGLE-BOX
          SIZE 41 BY .83
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     fi-egrip-date AT ROW 8.77 COL 12 COLON-ALIGNED
     fi-egrip-num AT ROW 8.77 COL 34 COLON-ALIGNED
     tt-firm.main-obj-code AT ROW 11.2 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11.9 BY 1
     tt-firm.main-obj-type AT ROW 11.2 COL 34.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 7.4 BY 1
     B-hold-obj AT ROW 11.2 COL 45.1
     tt-sysconf.head-position AT ROW 14.43 COL 19.6 COLON-ALIGNED
          LABEL "Должность рук-ля"
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     tt-sysconf.snr-accnt AT ROW 16.7 COL 28 COLON-ALIGNED
          LABEL "Главный бухгалтер"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     tt-sysconf.cashier AT ROW 17.7 COL 28 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     tt-sysconf.branch AT ROW 18.7 COL 28 COLON-ALIGNED
          LABEL "Отрасль (вид деятельности)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1 TOOLTIP "Отрасль (вид деятельности)"
     tt-sysconf.property AT ROW 19.7 COL 28 COLON-ALIGNED
          LABEL "Организ.-правовая форма"
          VIEW-AS FILL-IN
          SIZE 38.1 BY 1
     tt-sysconf.KOPF AT ROW 20.7 COL 28 COLON-ALIGNED
          LABEL "КОПФ"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-sysconf.SOEI AT ROW 21.7 COL 28 COLON-ALIGNED
          LABEL "СОЕИ"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     sale-code-name AT ROW 3.27 COL 39.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cash-pay-name AT ROW 4.37 COL 23.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     credit-pay-name AT ROW 4.37 COL 77.8 COLON-ALIGNED NO-LABEL
     ret-credit-pay-name AT ROW 5.5 COL 77.6 COLON-ALIGNED NO-LABEL
     hold-arh-title AT ROW 10.27 COL 1.5 NO-LABEL
     main-obj-title AT ROW 11.3 COL 2.9 NO-LABEL
     main-obj-name AT ROW 11.3 COL 48 COLON-ALIGNED NO-LABEL
     " Бухгалтерия" VIEW-AS TEXT
          SIZE 13.8 BY 1 AT ROW 15.5 COL 38
     RECT-1 AT ROW 15.77 COL 1
     RECT-2 AT ROW 11.03 COL 1
     SPACE(7.64) SKIP(11.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки фирмы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_clients B "?" ? ub clients
      TABLE: locked_currency B "?" ? ub currency
      TABLE: locked_firm B "?" ? ub firm
      TABLE: locked_sysconf B "?" ? ub sysconf
      TABLE: tt-clients T "?" NO-UNDO ub clients
      TABLE: tt-firm T "?" NO-UNDO ub firm
      TABLE: tt-sysconf T "?" NO-UNDO ub sysconf
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

/* SETTINGS FOR TOGGLE-BOX tt-sysconf.artic-disable IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-sysconf.avrg-price IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.base-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN base-code-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.branch IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.cash-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.cashier IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.cons-vat-pc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.credit-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.head-position IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN hold-arh-title IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-sysconf.host-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
ASSIGN 
       tt-sysconf.host-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-host-code:HANDLE.

/* SETTINGS FOR FILL-IN tt-sysconf.KOPF IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.main-obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN main-obj-title IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-firm.main-obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-sysconf.negative-rest IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-clients.obj-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR TOGGLE-BOX tt-sysconf.osn-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-sysconf.property IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.ret-credit-pay IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-sysconf.sale-code IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt-sysconf.sale-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.snr-accnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.SOEI IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-sysconf,Temp-Tables.tt-clients WHERE ub.clients ...,Temp-Tables.tt-firm WHERE ub.clients ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки фирмы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.avrg-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.avrg-price Dialog-Frame
ON VALUE-CHANGED OF tt-sysconf.avrg-price IN FRAME Dialog-Frame /* Посредник (для отчетов) */
DO:
  assign
    tt-sysconf.avrg-price
  .
  display
    tt-sysconf.avrg-price
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Параметры */
DO:
  run proc-b-attr in this-procedure
    (input {&lookup}
    ,input {&cmp}
    ,input locked_sysconf.host-code
    ) no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-base-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-base-code Dialog-Frame
ON CHOOSE OF b-base-code IN FRAME Dialog-Frame /* B */
DO:
  RUN local-curr-chk in this-procedure ("base-code", "button").
  apply "entry" to tt-sysconf.base-code in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cash-pay Dialog-Frame
ON CHOOSE OF B-cash-pay IN FRAME Dialog-Frame /* B */
DO:
  RUN local-payt-chk in this-procedure ("cash-pay", "button").
  apply "entry" to tt-sysconf.cash-pay in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-credit-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-credit-pay Dialog-Frame
ON CHOOSE OF B-credit-pay IN FRAME Dialog-Frame /* B */
DO:
  RUN local-cp-chk in this-procedure ("credit-pay", "button").
  apply "entry" to tt-sysconf.credit-pay in FRAME {&FRAME-NAME}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo .
  run ref/cclihist.w
    (input parparentproc
    ,input 0                 /* p-curr-host-code   */
    ,input '':U              /* p-curr-obj-type    */
    ,input 0                 /* p-curr-obj-code    */
    ,input '':U              /* bttns              */
    ,input 'one':U           /* p-mode             */
    ,input {&cmp}            /* p-obj-type         */
    ,input tt-firm.firm-code /* p-obj-code         */
    ,input ?                 /* p-host-code        */
    ,input ?                 /* p-corr-user-db-num */
    ,input '':U              /* p-corr-user-name   */
    ,input '':U              /* p-subject          */
    ,input v-cntxt-db-num    /* p-db-num           */
    ,input-output v-rid-list /* p-rid-list         */
    ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hold-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hold-obj Dialog-Frame
ON CHOOSE OF B-hold-obj IN FRAME Dialog-Frame /* B */
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  define buffer   buf_clients for ub.clients.

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    p-host-code
    ''
    0
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
  end.
  else do:
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      .
    assign
      tt-firm.main-obj-code:screen-value = string(buf_clients.obj-code)
      tt-firm.main-obj-code
      main-obj-name:screen-value = buf_clients.obj-name
      main-obj-name
      tt-firm.main-obj-type:screen-value = buf_clients.obj-type
      tt-firm.main-obj-type
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ret-credit-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ret-credit-pay Dialog-Frame
ON CHOOSE OF B-ret-credit-pay IN FRAME Dialog-Frame /* B */
DO:
  RUN local-payt-chk in this-procedure ("ret-credit-pay", "button").
  apply "entry" to tt-sysconf.ret-credit-pay in FRAME {&FRAME-NAME}.
  return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sale-type-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sale-type-code Dialog-Frame
ON CHOOSE OF B-sale-type-code IN FRAME Dialog-Frame /* B */
DO:
  RUN local-cli-chk in this-procedure ("sale-code", "sale-type", "button").
  apply "entry" to tt-sysconf.sale-code in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-transport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-transport Dialog-Frame
ON CHOOSE OF B-transport IN FRAME Dialog-Frame /* Транспорт */
DO:
  define variable v-transport-type as integer   no-undo .
  run adm/conftran.w
    (input  p-mode
    ,input  'sysconf':U
    ,input  p-host-code
    ,input  parParentProc
    ,input-output tt-sysconf.transport-cli-type
    ,input-output tt-sysconf.transport-cli-code
    ,input-output tt-sysconf.transport-host
    ,input-output tt-sysconf.transport-contract
    ,input-output tt-sysconf.transport-uslov
    ,input-output tt-sysconf.transport-value
    ,input-output v-transport-type
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.base-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.base-code Dialog-Frame
ON LEAVE OF tt-sysconf.base-code IN FRAME Dialog-Frame /* Базовая валюта */
DO:
  if input frame {&frame-name} tt-sysconf.base-code <> tt-sysconf.base-code then do:
    run local-curr-chk in this-procedure ("base-code", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.base-code Dialog-Frame
ON RETURN OF tt-sysconf.base-code IN FRAME Dialog-Frame /* Базовая валюта */
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.base-code IN FRAME Dialog-frame
DO:
  run local-curr-chk in this-procedure ("base-code", "ret-mouse").
  apply "entry" to tt-sysconf.base-code in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_trn-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_trn-reason Dialog-Frame
ON CHOOSE OF Btn_trn-reason IN FRAME Dialog-Frame /* Коды оснований (причин) */
DO:
  run str/host-rsn.w (
                   input parparentproc
                 , input p-host-code
                 , input ( if p-mode = {&lookup} then {&lookup} else {&work} )
                 ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.cash-pay Dialog-Frame
ON LEAVE OF tt-sysconf.cash-pay IN FRAME Dialog-Frame /* Опл. наличными */
DO:
   if input frame {&frame-name} tt-sysconf.cash-pay <> tt-sysconf.cash-pay then do:
    /* 31/X-2017  вместе с импортом из 1С сняты проверки на ввод видов оплаты в интерфейсе
    run local-payt-chk in this-procedure ("cash-pay", "leave").
    */
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.cash-pay Dialog-Frame
ON RETURN OF tt-sysconf.cash-pay IN FRAME Dialog-Frame /* Опл. наличными */
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.cash-pay IN FRAME Dialog-frame
DO:
  run local-payt-chk in this-procedure ("cash-pay", "ret-mouse").
  apply "entry" to tt-sysconf.cash-pay in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.credit-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.credit-pay Dialog-Frame
ON LEAVE OF tt-sysconf.credit-pay IN FRAME Dialog-Frame /* Платеж в кредит на кассе */
DO:
if input frame {&frame-name} tt-sysconf.credit-pay <> tt-sysconf.credit-pay then do:
    /* 31/X-2017  вместе с импортом из 1С сняты проверки на ввод видов оплаты в интерфейсе
    run local-cp-chk in this-procedure ("credit-pay", "leave").
    */
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.credit-pay Dialog-Frame
ON RETURN OF tt-sysconf.credit-pay IN FRAME Dialog-Frame /* Платеж в кредит на кассе */
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.credit-pay IN FRAME Dialog-frame
DO:
 run local-cp-chk in this-procedure ("credit-pay", "ret-mouse").
  apply "entry" to tt-sysconf.credit-pay in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.gen-s-f-office
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.gen-s-f-office Dialog-Frame
ON VALUE-CHANGED OF tt-sysconf.gen-s-f-office IN FRAME Dialog-Frame /* Генерация счет-фактур только в офисе */
DO:
  assign tt-sysconf.gen-s-f-office .
  if tt-sysconf.gen-s-f-office = no then message
    "При установке данной настройки не будут формироваться С-Ф по ФО и Платежам на УБД"
    view-as alert-box INFORMATION TITLE "Внимание!" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_choose Dialog-Frame
ON CHOOSE OF MENU-ITEM m_choose /* Подобрать свободный код */
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
   run ref/chs-code.w
     (input  {&cmp}
     ,input  v-cntxt-db-num
     ,output v-obj-code
     ) no-error .
  if not error-status :error
  and v-obj-code <> ?
  then do:
    if v-obj-code > 99999 then do:
      message
      "Кoд фирмы не может быть больше 99999"
      view-as alert-box error .
      return no-apply.
    end.
    display
      v-obj-code @ tt-sysconf.host-code
      with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.ret-credit-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.ret-credit-pay Dialog-Frame
ON LEAVE OF tt-sysconf.ret-credit-pay IN FRAME Dialog-Frame /* Опл. долгов по кредиту */
DO:
 if input frame {&frame-name} tt-sysconf.ret-credit-pay <> tt-sysconf.ret-credit-pay then do:
    /* 31/X-2017  вместе с импортом из 1С сняты проверки на ввод видов оплаты в интерфейсе
    run local-payt-chk in this-procedure ("ret-credit-pay", "leave").
    */
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.ret-credit-pay Dialog-Frame
ON RETURN OF tt-sysconf.ret-credit-pay IN FRAME Dialog-Frame /* Опл. долгов по кредиту */
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.ret-credit-pay IN FRAME Dialog-frame
DO:
run local-payt-chk in this-procedure ("ret-credit-pay", "ret-mouse").
  apply "entry" to tt-sysconf.ret-credit-pay in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.sale-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.sale-code Dialog-Frame
ON LEAVE OF tt-sysconf.sale-code IN FRAME Dialog-Frame /* Код реализации */
DO:
  if input frame {&frame-name} tt-sysconf.sale-code <> tt-sysconf.sale-code then do:
    run local-cli-chk in this-procedure ("sale-code", "sale-type", "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.sale-code Dialog-Frame
ON RETURN OF tt-sysconf.sale-code IN FRAME Dialog-Frame /* Код реализации */
or MOUSE-SELECT-DBLCLICK OF tt-sysconf.sale-code IN FRAME Dialog-frame
DO:
  run local-cli-chk in this-procedure ("sale-code", "sale-type", "ret-mouse").
  apply "entry" to tt-sysconf.sale-code in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varals-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varals-gds Dialog-Frame
ON VALUE-CHANGED OF varals-gds IN FRAME Dialog-Frame /* Торговля чужим товаром */
DO:
  ASSIGN
    FRAME {&FRAME-NAME} varals-gds.
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
{ gbl/ed_date.i fi-egrip-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  { gbl/getcntxt.i get }
  if  p-mode <> {&add-def}
  and p-mode <> {&update}
  and p-mode <> {&lookup}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box error .
    undo, return error.
  end.
  { gbl/curdbnum.i v-db-num }
  if p-mode <> {&lookup}
  then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ФИРМЫ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-sysconf
  :
    delete tt-sysconf.
  end.
  for each tt-clients
  :
    delete tt-clients.
  end.
  for each tt-firm
  :
    delete tt-firm.
  end.
  if p-mode = {&add-def}
  then do:
    create tt-sysconf .
    create tt-clients .
    create tt-firm .
    /* todo - надо рассмотреть подробнее вопрос инициирования первой фирмы */
    if p-host-code = ?
    or p-host-code = 0
    then do:
      /* инициирование 1-й фирмы */
      assign
        p-host-code = tt-sysconf.host-code
      .
    end.
    assign
      tt-sysconf.firm-db-num = 0
      tt-sysconf.ord-prt     = yes
      tt-sysconf.purch-code  = integer({&repayment-code})
      tt-sysconf.sale-type = {&cmp}
    .
    if not p-is-deploy
    then do:
      message
        "Вам следует выбрать группу," skip
        "к которой будет относиться СВОЯ ФИРМА." skip
        view-as alert-box .
      assign
        ref-list = '':U
      .
      run ref/cli-grps.w
        (input  parparentproc
        ,input  "b-sel"
        ,input-output ref-list
        ) .
      if ref-list <> ""
      then do:
        find buf_cli-grp
          where recid( buf_cli-grp ) = integer( ref-list )
          .
        if can-find( first ub.cli-grp where
                          ub.cli-grp.upper-code = buf_cli-grp.node-code )
        then do:
          message
            "Добавлять можно только в группы," skip
            "у которых нет подгрупп." skip
            "Выбирайте другую группу !" skip
            view-as alert-box information .
          return .
        end.
        assign
          tt-clients.grp-code = buf_cli-grp.node-code
        .
      end.
      /*ref-list <= ""*/
      else do:
        return .
      end.
    end.
    else do:
      /* режим раскрутки */
      /* находим первую попавшуюся фирму */
      /* поэтому здесь поиск производится без кода */
      find first locked_clients exclusive-lock
        where locked_clients.obj-type = {&cmp}
        and (p-host-code = 0 or locked_clients.obj-code = p-host-code)
        no-wait
        no-error
        .
      if not available locked_clients
      then do:
        if locked locked_clients
        then do:
          find first locked_clients exclusive-lock
            where locked_clients.obj-type = {&cmp}
            no-error  .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись клиент для свой фирмы" skip
            view-as alert-box error .
        end.
        undo, return error . /* --->>>--- */
      end.
      find first locked_firm exclusive-lock
        where locked_firm.firm-code = locked_clients.obj-code
        no-wait
        no-error
        .
      if not available locked_firm
      then do:
        if locked locked_firm
        then do:
          find first locked_firm exclusive-lock
            where locked_firm.firm-code = locked_clients.obj-code
            no-error
            .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись фирма для свой фирмы" skip
            view-as alert-box error .
        end.
        undo, return error. /* --->>>--- */
      end.
      buffer-copy locked_clients to tt-clients .
      buffer-copy locked_firm to tt-firm .
      tt-sysconf.host-code = tt-clients.obj-code.
    end.
  end.
  else do: /*no add-def*/
    if p-mode = {&update}
    then do:
      find first locked_sysconf exclusive-lock
        where locked_sysconf.host-code = p-host-code
        no-wait
        no-error .
      if not available locked_sysconf
      then do:
        if locked locked_sysconf
        then do:
          find first locked_sysconf exclusive-lock
            where locked_sysconf.host-code = p-host-code
            no-error .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске фирмы" skip
            "Код фирмы" p-host-code skip
            view-as alert-box error .
        end.
        undo, return error. /* --->>>--- */
      end.
      find first locked_clients exclusive-lock
        where locked_clients.obj-code = locked_sysconf.host-code
          and locked_clients.obj-type = {&cmp}
        no-wait
        no-error .
      if not available locked_clients
      then do:
       if locked locked_clients
        then do:
          find first locked_clients exclusive-lock
            where locked_clients.obj-code = locked_sysconf.host-code
              and locked_clients.obj-type = {&cmp}
            no-error .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись КЛИЕНТ для СВОЕЙ ФИРМЫ" p-host-code skip
            view-as alert-box error .
        end.
        undo, return error. /* --->>>--- */
      end.
      find first locked_firm exclusive-lock
        where locked_firm.firm-code = locked_sysconf.host-code
        no-wait
        no-error
        .
      if not available locked_firm
      then do:
        if locked locked_firm
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Запись ФИРМА для СВОЕЙ ФИРМЫ" p-host-code "занята"
            view-as alert-box error .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись ФИРМА для СВОЕЙ ФИРМЫ" p-host-code skip
            view-as alert-box error .
        end.
        undo, return error . /* --->>>--- */
      end.
    end.
    if p-mode = {&lookup}
    then do:
      find first locked_sysconf no-lock
        where locked_sysconf.host-code = p-host-code
        .
      find first locked_clients no-lock
        where locked_clients.obj-code = locked_sysconf.host-code
          and locked_clients.obj-type = {&cmp}
        .
      find first locked_firm no-lock
        where locked_firm.firm-code = locked_sysconf.host-code
        .
    end.
    if not available locked_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Недоступна запись текущей фирмы locked_sysconf" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first locked_currency no-lock
      where locked_currency.curr-code = locked_sysconf.base-code
      no-error .
    if not available locked_currency
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена базовая валюта для фирмы" locked_sysconf.host-code skip
        "Код валюты" locked_sysconf.base-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    create tt-clients.
    create tt-sysconf.
    create tt-firm.
    buffer-copy locked_clients to tt-clients.
    buffer-copy locked_sysconf to tt-sysconf.
    buffer-copy locked_firm to tt-firm.
  end.
  run myenable in this-procedure
    no-error .
  if error-status :error
  then do:
    return error return-value .
  end.
  view frame {&frame-name}.
  wait-for go of frame {&frame-name}.
END. /*doe*/
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY base-code-name varpurch-name varals-gds fi-egrip-date fi-egrip-num 
          sale-code-name cash-pay-name credit-pay-name ret-credit-pay-name 
          hold-arh-title main-obj-title main-obj-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN 
    DISPLAY tt-clients.obj-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-firm THEN 
    DISPLAY tt-firm.main-obj-code tt-firm.main-obj-type 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-sysconf THEN 
    DISPLAY tt-sysconf.host-code tt-sysconf.base-code tt-sysconf.sale-type 
          tt-sysconf.sale-code tt-sysconf.cash-pay tt-sysconf.credit-pay 
          tt-sysconf.cons-vat-pc tt-sysconf.ret-credit-pay tt-sysconf.osn-base 
          tt-sysconf.negative-rest tt-sysconf.avrg-price 
          tt-sysconf.artic-disable tt-sysconf.gen-s-f-office 
          tt-sysconf.head-position tt-sysconf.snr-accnt tt-sysconf.cashier 
          tt-sysconf.branch tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-transport Btn_trn-reason B-attr B-hist B-Help RECT-1 
         RECT-2 b-base-code tt-sysconf.sale-type tt-sysconf.sale-code 
         B-sale-type-code tt-sysconf.cash-pay B-cash-pay tt-sysconf.credit-pay 
         B-credit-pay tt-sysconf.cons-vat-pc tt-sysconf.ret-credit-pay 
         B-ret-credit-pay tt-sysconf.negative-rest varpurch-name 
         tt-sysconf.avrg-price tt-sysconf.artic-disable varals-gds 
         tt-sysconf.gen-s-f-office fi-egrip-date fi-egrip-num 
         tt-firm.main-obj-code tt-firm.main-obj-type B-hold-obj 
         tt-sysconf.head-position tt-sysconf.snr-accnt tt-sysconf.cashier 
         tt-sysconf.branch tt-sysconf.property tt-sysconf.KOPF tt-sysconf.SOEI 
         sale-code-name cash-pay-name credit-pay-name ret-credit-pay-name 
         hold-arh-title main-obj-title main-obj-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gen-code Dialog-Frame 
PROCEDURE gen-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-firm-code like ub.firm.firm-code no-undo.
def variable ii as integer no-undo.
define buffer buf_firm for ub.firm.
do ii = 1 to 99999:
    find first buf_firm no-lock where
                buf_firm.firm-code = ii no-error.
    if not available buf_firm
    then do:
        assign
        p-firm-code = ii.
        return.
    end.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-cli-chk Dialog-Frame 
PROCEDURE local-cli-chk :
define input parameter p-man    as character no-undo.
define input parameter p-man2 as character no-undo .
define input parameter p-action as character no-undo.
if p-man = "sale-code" and p-man2 = "sale-type" and p-action = "ret-mouse" then do:
   { ref/cli-chk.i sale-code sale-type ret-mouse tt-sysconf " " "({&cmp} + {&comma-char} + {&prs})" b-sale-type-code }
end.
if p-man = "sale-code" and p-man2 = "sale-type" and p-action = "button" then do:
   { ref/cli-chk.i sale-code sale-type button tt-sysconf " " "({&cmp} + {&comma-char} + {&prs})" b-sale-type-code }
end.
if p-man = "sale-code" and p-man2 = "sale-type" and p-action = "leave" then do:
   { ref/cli-chk.i sale-code sale-type leave tt-sysconf " " "({&cmp} + {&comma-char} + {&prs})" b-sale-type-code }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-cp-chk Dialog-Frame 
PROCEDURE local-cp-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "credit-pay" and p-action = "ret-mouse" then do:
   { ref/cp-chk.i credit-pay ret-mouse tt-sysconf }
end.
if p-man = "credit-pay" and p-action = "button" then do:
   { ref/cp-chk.i credit-pay button tt-sysconf }
end.
if p-man = "credit-pay" and p-action = "leave" then do:
   { ref/cp-chk.i credit-pay leave tt-sysconf }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-curr-chk Dialog-Frame 
PROCEDURE local-curr-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "base-code" and p-action = "ret-mouse" then do:
   { ref/curr-chk.i base-code ret-mouse tt-sysconf }
end.
if p-man = "base-code" and p-action = "button" then do:
   { ref/curr-chk.i base-code button tt-sysconf }
end.
if p-man = "base-code" and p-action = "leave" then do:
   { ref/curr-chk.i base-code leave tt-sysconf }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-payt-chk Dialog-Frame 
PROCEDURE local-payt-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "ret-credit-pay" and p-action = "ret-mouse" then do:
   { ref/payt-chk.i ret-credit-pay ret-mouse tt-sysconf }
end.
if p-man = "ret-credit-pay" and p-action = "button" then do:
   { ref/payt-chk.i ret-credit-pay button tt-sysconf }
end.
if p-man = "ret-credit-pay" and p-action = "leave" then do:
   { ref/payt-chk.i ret-credit-pay leave tt-sysconf }
end.
if p-man = "cash-pay" and p-action = "ret-mouse" then do:
   { ref/payt-chk.i cash-pay ret-mouse tt-sysconf }
end.
if p-man = "cash-pay" and p-action = "button" then do:
   { ref/payt-chk.i cash-pay button tt-sysconf }
end.
if p-man = "cash-pay" and p-action = "leave" then do:
   { ref/payt-chk.i cash-pay leave tt-sysconf }
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable hold-type as character no-undo.
define variable v-next-firm-code like ub.firm.firm-code.
define variable vartpsi      as character no-undo.
define variable vartpsi-type as character no-undo.
define variable varals-gds-str      as character no-undo.
define variable varals-gds-str-type as character no-undo.
define variable var-type            as character no-undo .
define variable var-tooltip         as character no-undo .
define variable v-egrip-date-str    as character    no-undo.

define buffer buf_sysconf for ub.sysconf.
define buffer buf1_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type.

assign
varpurch-name:LIST-ITEMS in frame {&frame-name} = {&purchase-input-codes-full}
.
/*найден первый своб номер*/
if p-mode = {&add-def} then do:
  run gen-code in this-procedure
    (output v-next-firm-code
    ) no-error .
  if error-status :error
  or v-next-firm-code = 0
  then do:
    message
      "Ошибка при генерации кода новой СВОЕЙ ФИРМЫ" skip
      "или нет свободного кода"
      view-as alert-box error.
      return error.
  end.
end.
/* есть ли межфирменные архивы */
{ gbl/conf-rd.i
"'holding'"
0
"''"
0
"''"
"''"
 "''"
 no
 hold
 hold-type
 no-error
 }
if ( not error-status :error )
and hold = "yes"
then do:
  if p-mode = {&update}
  then do:
    enable
      RECT-2
      B-hold-obj
      tt-firm.main-obj-code
      tt-firm.main-obj-type
      with frame {&frame-name}.
  end.
  display
  hold-arh-title
  main-obj-title
  main-obj-name
  with frame {&frame-name}.
  assign
  B-hold-obj:visible = yes
  RECT-2:visible     = yes
  tt-firm.main-obj-code:visible  = yes
  hold-arh-title:visible  = yes
  main-obj-title:visible  = yes
  main-obj-name:visible  = yes
  tt-firm.main-obj-type:visible  = yes
  .
end.
else do:
  assign
  B-hold-obj:visible = no
  RECT-2:visible     = no
  tt-firm.main-obj-code:visible  = no
  hold-arh-title:visible  = no
  main-obj-title:visible  = no
  main-obj-name:visible  = no
  tt-firm.main-obj-type:visible  = no
  .
end.

if tt-sysconf.base-code <> 0
then do:
  DISPLAY
  tt-sysconf.osn-base with frame {&frame-name}.
  enable
  tt-sysconf.osn-base when (not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
                                and p-mode <> {&lookup})
  with frame {&frame-name}.
end.
else do:
  HIDE
  tt-sysconf.osn-base
  in frame {&frame-name}.
end.
assign
  tt-sysconf.osn-base :tooltip = "Учет ОС не только в {&abbr_rublyah}, но и в баз. вал."
.

&scop purchase-code string(tt-sysconf.purch-code)
assign varpurch-name =  {&purchase-input-codes-name}.
display
varpurch-name
with frame {&frame-name}.
{ gbl/conf-rd.i
  "'tpsi'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  vartpsi
  vartpsi-type
  no-error
}
if ( not error-status :error )
and vartpsi = "yes"
then do:
  run clntattr-value in this-procedure (
                                        input  {&cmp}
                                        ,input  tt-sysconf.host-code
                                        ,input  {&attr-als-gds}
                                        ,output varals-gds-str
                                        ,output varals-gds-str-type).
  if varals-gds-str = "yes"
  then do:
    assign
      varals-gds = yes
    .
  end.
  else do:
    assign
      varals-gds = no
    .
  end.
  display varals-gds with frame {&frame-name}.
  if p-mode <> {&lookup}
  then do:
    enable varals-gds with frame {&frame-name}.
  end.
end.
else do:
  hide varals-gds in frame {&frame-name}.
end.

run clntattr-value in this-procedure (
                                       input  {&cmp}
                                      ,input  tt-sysconf.host-code
                                      ,input  {&attr-egrip-date}
                                      ,output v-egrip-date-str
                                      ,output var-type) no-error .
if not error-status :error
then do:
    assign
        fi-egrip-date = date( v-egrip-date-str )
    no-error.
    if error-status :error
    then do:
        assign
            fi-egrip-date = ?
        .
    end.
end.
run clntattr-tooltip in this-procedure (
    input {&attr-egrip-date}
    ,output var-tooltip
    ,output var-type /*p-label*/).
assign
fi-egrip-date:tooltip = var-tooltip
no-error .
display
fi-egrip-date
with frame {&frame-name}.
if p-mode <> {&lookup}
then do:
  enable
    fi-egrip-date
    with frame {&frame-name}.
end.

run clntattr-value in this-procedure (
                                      input  {&cmp}
                                      ,input  tt-sysconf.host-code
                                      ,input  {&attr-egrip-num}
                                      ,output fi-egrip-num
                                      ,output var-type) no-error .
if error-status :error
then do:
    assign
        fi-egrip-num = "":U
    .
end.
run clntattr-tooltip in this-procedure (
    input {&attr-egrip-num}
    ,output var-tooltip
    ,output var-type /*p-label*/).
assign
fi-egrip-num:tooltip = var-tooltip
no-error .
display
fi-egrip-num
with frame {&frame-name}.
if p-mode <> {&lookup}
then do:
  enable
    fi-egrip-num
    with frame {&frame-name}.
end.

if hold = "yes"
then do:
  find first buf_clients no-lock
    where buf_clients.obj-code = tt-firm.main-obj-code
      and buf_clients.obj-type = tt-firm.main-obj-type
    no-error.
  if available buf_clients
  then do:
    assign
      tt-firm.main-obj-code:screen-value = string( buf_clients.obj-code )
      tt-firm.main-obj-code
      main-obj-name:screen-value = buf_clients.obj-name
      main-obj-name
      tt-firm.main-obj-type:screen-value = buf_clients.obj-type
      tt-firm.main-obj-type
    .
  end.
end.
DISPLAY
tt-clients.obj-name
(if p-mode = {&add-def} and not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
then v-next-firm-code
else tt-sysconf.host-code) @
tt-sysconf.host-code
tt-sysconf.base-code
tt-sysconf.sale-code
tt-sysconf.sale-type
tt-sysconf.avrg-price
tt-sysconf.gen-s-f-office
tt-sysconf.cash-pay
tt-sysconf.credit-pay
tt-sysconf.ret-credit-pay
tt-sysconf.negative-rest
tt-sysconf.artic-disable
tt-sysconf.snr-accnt
tt-sysconf.cashier
tt-sysconf.head-position
tt-sysconf.branch
tt-sysconf.property
tt-sysconf.KOPF
tt-sysconf.SOEI
tt-sysconf.cons-vat-pc
with frame {&frame-name}.

if p-mode <> {&add-def} then do:
  { ref/curr-chk.i base-code on tt-sysconf }
  { ref/cp-chk.i credit-pay on tt-sysconf }
  { ref/payt-chk.i ret-credit-pay on tt-sysconf }
  { ref/payt-chk.i cash-pay on tt-sysconf }
  { ref/cli-chk.i sale-code sale-type on tt-sysconf " " "({&cmp} + {&comma-char} + {&prs})" b-sale-type-code }
end.

if p-mode <> {&lookup}
then do:
  enable
    tt-sysconf.host-code       when p-mode = {&add-def}
    tt-sysconf.base-code       when p-mode = {&add-def}
    b-base-code                when p-mode = {&add-def}
    tt-clients.obj-name
    tt-sysconf.sale-code
    tt-sysconf.sale-type
    b-sale-type-code
    tt-sysconf.gen-s-f-office
    tt-sysconf.avrg-price      when not tt-sysconf.avrg-price
    tt-sysconf.cash-pay        when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    tt-sysconf.credit-pay      when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    tt-sysconf.ret-credit-pay  when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    b-cash-pay                 when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    b-credit-pay               when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
    b-ret-credit-pay           when not (p-is-deploy and parparentproc:get-signature("mainmenu_getcntxt") = "")
  /*  btn-fin-def                when not p-is-deploy*/
    tt-sysconf.negative-rest
    tt-sysconf.artic-disable
    tt-sysconf.snr-accnt
    tt-sysconf.cashier
    tt-sysconf.head-position
    tt-sysconf.branch
    tt-sysconf.property
    tt-sysconf.KOPF
    tt-sysconf.SOEI
    tt-sysconf.cons-vat-pc
    varpurch-name
    b-exit
    b-quit
    b-attr
    Btn_trn-reason
    B-transport
    b-hist WHEN p-mode <> {&add-def}
    b-help with frame {&frame-name}
    .
end.
else do:
  assign
    b-quit:label = "&Выход"
    b-quit:column = 1
  .
  hide
    b-exit
    in frame {&frame-name}.
  enable
    b-quit
    b-attr
    b-hist
    b-help
    Btn_trn-reason
    B-transport
    with frame {&frame-name} .
end.
frame {&frame-name}:title = "Настройки фирмы.             " + title-mode(p-mode).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
do
with frame {&frame-name}
:
    assign
        fi-egrip-date
        fi-egrip-num
    .
end.
assign
  v-rid = (if p-mode = {&add-def}
          then ?
          else recid(locked_sysconf)
          )
  varpurch-name
  tt-clients.obj-name
  tt-sysconf.host-code      frame {&frame-name}
  tt-sysconf.artic-disable
  tt-sysconf.avrg-price
  tt-sysconf.gen-s-f-office
  tt-sysconf.base-code
  tt-sysconf.branch
  tt-sysconf.cash-pay
  tt-sysconf.cashier
  tt-sysconf.cons-vat-pc
  tt-sysconf.credit-pay
  tt-sysconf.head-position
  tt-sysconf.KOPF
  tt-sysconf.negative-rest
  tt-sysconf.osn-base
  tt-sysconf.property
  tt-sysconf.purch-code = integer (lookup (varpurch-name, {&purchase-input-codes-full}))
  tt-sysconf.ret-credit-pay
  tt-sysconf.sale-type
  tt-sysconf.sale-code
  tt-sysconf.snr-accnt
  tt-sysconf.SOEI
  tt-firm.main-obj-type
  tt-firm.main-obj-code
  .
run adm/sysconf1.p
  (input-output v-rid
  ,input p-mode
  ,input no /*silent*/
  ,input p-is-deploy
  ,input tt-sysconf.host-code
  ,input tt-clients.grp-code
  ,input tt-clients.obj-name
  ,input tt-sysconf.avrg-price
  ,input tt-sysconf.artic-disable
  ,input tt-sysconf.base-code
  ,input tt-sysconf.branch
  ,input tt-sysconf.cash-pay
  ,input tt-sysconf.cashier
  ,input tt-sysconf.cons-vat-pc
  ,input tt-sysconf.credit-pay
  ,input tt-sysconf.firm-db-num
  ,input tt-sysconf.head-position
  ,input tt-sysconf.KOPF
  ,input tt-sysconf.negative-rest
  ,input tt-sysconf.ord-prt
  ,input tt-sysconf.osn-base
  ,input tt-sysconf.property
  ,input tt-sysconf.purch-code
  ,input tt-sysconf.ret-credit-pay
  ,input tt-sysconf.sale-type
  ,input tt-sysconf.sale-code
  ,input tt-sysconf.snr-accnt
  ,input tt-sysconf.SOEI
  ,input tt-sysconf.transport-cli-type
  ,input tt-sysconf.transport-cli-code
  ,input tt-sysconf.transport-host
  ,input tt-sysconf.transport-contract
  ,input tt-sysconf.transport-uslov
  ,input tt-sysconf.transport-value
  ,input tt-firm.main-obj-type
  ,input tt-firm.main-obj-code
  ,input varals-gds
  ,input fi-egrip-date
  ,input fi-egrip-num
  ,input tt-sysconf.gen-s-f-office
  ) no-error .

if error-status :error
then do:
message error-status:get-message(1) view-as alert-box .
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

