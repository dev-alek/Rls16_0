&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута объекта TH (thbj-attr) "cd-type-ibs-th"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/08
Author: Bakhtadze Natalya
Creation date: 07/08/08

*/


/*-----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута объекта TH (thbj-attr) cd-type-ibs-th".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
&UNDEFINE thbj-def_i
{ gbl/thbj-def.i __ }
{ gbl/tempwidg.i }
{ str/thpospay.i def }
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO EXTENT 5.
DEFINE VARIABLE v-labels AS CHARACTER NO-UNDO EXTENT 5.
DEFINE VARIABLE v-current-tab-order AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
define variable v-tth_ as handle NO-UNDO .
define variable v-tth_main as handle NO-UNDO .
define variable v-tth_devices as handle NO-UNDO .
define variable v-tth_fisreg as handle NO-UNDO .
define variable v-tth_rec-print as handle NO-UNDO .
define variable v-tth_interface as handle NO-UNDO .
DEFINE VARIABLE v-frpay-name AS CHARACTER NO-UNDO.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle
v-tth_ = buffer thbjattr___thbj-attr:table-handle
.

{ str/thpospay.i proc }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-pay-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-cash-pay-list temp-pay-names

/* Definitions for BROWSE BR-cash-pay-list                              */
&Scoped-define FIELDS-IN-QUERY-BR-cash-pay-list temp-cash-pay-list.cdpay-code temp-cash-pay-list.curr-code getcp-name (INPUT temp-cash-pay-list.cdpay-code, INPUT temp-cash-pay-list.curr-code) temp-cash-pay-list.frpay-code get-frpay-name( INPUT temp-cash-pay-list.frpay-code) @ v-frpay-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-pay-list temp-cash-pay-list.frpay-code   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-cash-pay-list temp-cash-pay-list
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-cash-pay-list temp-cash-pay-list
&Scoped-define SELF-NAME BR-cash-pay-list
&Scoped-define QUERY-STRING-BR-cash-pay-list FOR EACH temp-cash-pay-list
&Scoped-define OPEN-QUERY-BR-cash-pay-list OPEN QUERY {&SELF-NAME} FOR EACH temp-cash-pay-list.
&Scoped-define TABLES-IN-QUERY-BR-cash-pay-list temp-cash-pay-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-pay-list temp-cash-pay-list


/* Definitions for BROWSE BR-pay-names                                  */
&Scoped-define FIELDS-IN-QUERY-BR-pay-names temp-pay-names.frpay-code temp-pay-names.frpay-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pay-names temp-pay-names.frpay-name   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-pay-names temp-pay-names
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-pay-names temp-pay-names
&Scoped-define SELF-NAME BR-pay-names
&Scoped-define QUERY-STRING-BR-pay-names FOR EACH temp-pay-names
&Scoped-define OPEN-QUERY-BR-pay-names OPEN QUERY {&SELF-NAME} FOR EACH temp-pay-names.
&Scoped-define TABLES-IN-QUERY-BR-pay-names temp-pay-names
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pay-names temp-pay-names


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cash-pay-list}~
    ~{&OPEN-QUERY-BR-pay-names}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-cash-shift ~
t-cash-drawer-plug RS-cash-drawer-level f-advert-text1 rs-log-level ~
BR-pay-names t-salesman-mandatory RS-cash-drawer-plug-type CB-screen-type ~
f-advert-text2 t-cutter f-cash-drawer-plug-port t-manual-discnt ~
f-cash-drawer-plug-imp f-advert-text3 b-screen-layout-id f-com-port ~
t-clear-cash-counter f-cash-drawer-limit t-qnty-change t-cash-drawer-open ~
f-cliche-lines1 f-cliche-lines2 b-add-cash-pay b-del-cash-pay ~
BR-cash-pay-list t-customer-display-plug f-cliche-lines3 ~
CB-customer-display-type f-cliche-lines4 f-cliche-lines5 ~
f-customer-display-port f-cliche-lines6 f-customer-display-adv1 ~
t-print-good-code f-customer-display-adv2 f-max-netto CB-keyboard-type ~
rs-rmethod-type b-keyboard-layout-id b-curr f-nalc rs-rmethod-coeff ~
CB-cashless-system t-card-reader-plug t-rcpt-ord-slip-print ~
t-rcpt-ord-alt-print CB-cctv-system f-cctv-system-address b-interface ~
B-devices b-rec-print B-main b-fisreg f-main F-devices f-fisreg f-rec-print ~
f-interface l-cash-drawer-level l-cash-drawer-plug-type for-curr-name 
&Scoped-Define DISPLAYED-OBJECTS t-cash-shift t-cash-drawer-plug ~
RS-cash-drawer-level f-advert-text1 rs-log-level t-salesman-mandatory ~
RS-cash-drawer-plug-type CB-screen-type f-advert-text2 t-cutter ~
f-cash-drawer-plug-port t-manual-discnt f-screen-layout-id ~
f-cash-drawer-plug-imp f-advert-text3 f-com-port t-clear-cash-counter ~
f-cash-drawer-limit t-qnty-change t-cash-drawer-open f-cliche-lines1 ~
f-cliche-lines2 t-customer-display-plug f-cliche-lines3 ~
CB-customer-display-type f-cliche-lines4 f-cliche-lines5 ~
f-customer-display-port f-cliche-lines6 f-customer-display-adv1 ~
t-print-good-code f-customer-display-adv2 f-max-netto l-rmethod ~
CB-keyboard-type rs-rmethod-type f-keyboard-layout-id f-nalc ~
rs-rmethod-coeff CB-cashless-system t-card-reader-plug ~
t-rcpt-ord-slip-print t-rcpt-ord-alt-print CB-cctv-system ~
f-cctv-system-address f-main F-devices f-fisreg f-rec-print f-interface ~
l-log-level f-screen-layout-name for-curr-name f-keyboard-layout-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-frpay-name Dialog-Frame 
FUNCTION get-frpay-name RETURNS CHARACTER
  ( INPUT p-frpay-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getcp-name Dialog-Frame 
FUNCTION getcp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS INTEGER , INPUT p-curr-code AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add-cash-pay 
     LABEL "Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-curr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-del-cash-pay 
     LABEL "Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-devices 
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "" 
     SIZE 14 BY 1.13.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-fisreg 
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "" 
     SIZE 14 BY 1.13.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-interface 
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "" 
     SIZE 14 BY 1.13.

DEFINE BUTTON b-keyboard-layout-id 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY .88.

DEFINE BUTTON B-main 
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "&1.Перемещ." 
     SIZE 14 BY 1.13.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rec-print 
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "" 
     SIZE 14 BY 1.13.

DEFINE BUTTON b-screen-layout-id 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY .88.

DEFINE VARIABLE CB-cashless-system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Система безнал.платежей" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE CB-cctv-system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип сис-мы видеонабл." 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE CB-customer-display-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип дисплея покупателя" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE CB-keyboard-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип клавиатуры" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE CB-screen-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип интерфейса" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-com-port AS CHARACTER FORMAT "X(4)":U 
     LABEL "ФР подключен к" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "COM1","COM2","COM3","COM4" 
     DROP-DOWN-LIST
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-advert-text AS CHARACTER FORMAT "X(255)":U 
     LABEL "Рекламный текст" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 62 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-advert-text1 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Рекламный текст1" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-advert-text2 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Рекламный текст2" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-advert-text3 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Рекламный текст3" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cash-drawer-limit AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0 
     LABEL "Предел наличности ДЯ" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-cash-drawer-plug-imp AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Кол-во имп. включения ДЯ" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-cash-drawer-plug-port AS INTEGER FORMAT "9":U INITIAL 0 
     LABEL "Порт подключения ДЯ" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-cctv-system-address AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес сис-мы видеонаблюд." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-cliche-lines AS CHARACTER FORMAT "X(255)":U 
     LABEL "Строки клише" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 62 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cliche-lines1 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Строки клише1" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cliche-lines2 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Строки клише2" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cliche-lines3 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Строки клише3" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cliche-lines4 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Строки клише4" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cliche-lines5 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Строки клише5" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-cliche-lines6 AS CHARACTER FORMAT "X(40)":U 
     LABEL "Строки клише6" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-customer-display-adv AS CHARACTER FORMAT "X(41)":U 
     LABEL "Текст рекл. на дисплее покупателя" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE f-customer-display-adv1 AS CHARACTER FORMAT "X(20)":U 
     LABEL "Текст рекл. на дисплее покупателя1" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 21 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-customer-display-adv2 AS CHARACTER FORMAT "X(20)":U 
     LABEL "Текст рекл. на дисплее покупателя2" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 21 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE f-customer-display-port AS CHARACTER FORMAT "X(5)":U INITIAL "0" 
     LABEL "Порт подключения  дисплея покупателя" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 8 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-devices AS CHARACTER FORMAT "X(12)":U INITIAL "Устройства" 
      VIEW-AS TEXT 
     SIZE 11 BY .5
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-fisreg AS CHARACTER FORMAT "X(12)":U INITIAL "ФР" 
      VIEW-AS TEXT 
     SIZE 11 BY .5
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-interface AS CHARACTER FORMAT "X(12)":U INITIAL "Интерфейс" 
      VIEW-AS TEXT 
     SIZE 11 BY .5
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-keyboard-layout-id AS CHARACTER FORMAT "X(256)":U 
     LABEL "Раскладка" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE f-keyboard-layout-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-main AS CHARACTER FORMAT "X(12)" INITIAL "Основные" 
      VIEW-AS TEXT 
     SIZE 11 BY .5
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-max-netto AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0 
     LABEL "Макс.сумма чека" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-nalc AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код валюты платежа при оплате НАЛИЧНЫМИ" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 4.63 BY 1 TOOLTIP "код платежа = 1"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-rec-print AS CHARACTER FORMAT "X(12)":U INITIAL "Чеки" 
      VIEW-AS TEXT 
     SIZE 11 BY .5
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-rmethod-coeff AS DECIMAL FORMAT ">>9.99":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-screen-layout-id AS CHARACTER FORMAT "X(256)":U 
     LABEL "Раскладка" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE f-screen-layout-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE for-curr-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-cash-drawer-level AS CHARACTER FORMAT "X(256)":U INITIAL "Логич.уровень датчика ДЯ" 
      VIEW-AS TEXT 
     SIZE 28 BY .67 NO-UNDO.

DEFINE VARIABLE l-cash-drawer-plug-type AS CHARACTER FORMAT "X(256)":U INITIAL "Тип подключения" 
      VIEW-AS TEXT 
     SIZE 16 BY .67 NO-UNDO.

DEFINE VARIABLE l-log-level AS CHARACTER FORMAT "X(256)":U INITIAL "Уровень логирования" 
      VIEW-AS TEXT 
     SIZE 20 BY .67 NO-UNDO.

DEFINE VARIABLE l-rmethod AS CHARACTER FORMAT "X(256)":U INITIAL "Тип и коэфф.округления суммы чека" 
     VIEW-AS FILL-IN 
     SIZE 40 BY .79 NO-UNDO.

DEFINE VARIABLE v-rmethod-coeff AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN NATIVE 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE RS-cash-drawer-level AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "1", 1,
"0", 0
     SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE RS-cash-drawer-plug-type AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "ФР", 0,
"COM-порт", 1
     SIZE 22.63 BY 1 NO-UNDO.

DEFINE VARIABLE rs-log-level AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 0", 0,
"Item 1", 1,
"Item 2", 2,
"Item 3", 3
     SIZE 17.63 BY 3.5 NO-UNDO.

DEFINE VARIABLE rs-rmethod-coeff AS DECIMAL 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 40 BY 3.04 NO-UNDO.

DEFINE VARIABLE rs-rmethod-type AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2"
     SIZE 39 BY 2 NO-UNDO.

DEFINE VARIABLE t-card-reader-plug AS LOGICAL INITIAL no 
     LABEL "Подключать кардридер" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-cash-drawer-open AS LOGICAL INITIAL no 
     LABEL "Работа с открытым ДЯ" 
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE t-cash-drawer-plug AS LOGICAL INITIAL no 
     LABEL "Подключать ДЯ" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-cash-shift AS LOGICAL INITIAL no 
     LABEL "Работа со сменами" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-clear-cash-counter AS LOGICAL INITIAL no 
     LABEL "Обнулять счетчик наличн. при Z-отчете" 
     VIEW-AS TOGGLE-BOX
     SIZE 40.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-customer-display-plug AS LOGICAL INITIAL no 
     LABEL "Подключать дисплей покупателя" 
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-cutter AS LOGICAL INITIAL no 
     LABEL "Отрезка чеков" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-manual-discnt AS LOGICAL INITIAL no 
     LABEL "Разрешена ручная скидка" 
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-print-good-code AS LOGICAL INITIAL no 
     LABEL "Печатать код товара" 
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-qnty-change AS LOGICAL INITIAL no 
     LABEL "Разрешена коррекция кол-ва" 
     VIEW-AS TOGGLE-BOX
     SIZE 40.63 BY 1 NO-UNDO.

DEFINE VARIABLE t-rcpt-ord-alt-print AS LOGICAL INITIAL no 
     LABEL "Печатать отлож.чек на доп принтере" 
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-rcpt-ord-slip-print AS LOGICAL INITIAL no 
     LABEL "Печатать слип отложенного чека" 
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-salesman-mandatory AS LOGICAL INITIAL no 
     LABEL "Обязателен продавец" 
     VIEW-AS TOGGLE-BOX
     SIZE 21.63 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-pay-list FOR 
      temp-cash-pay-list SCROLLING.

DEFINE QUERY BR-pay-names FOR 
      temp-pay-names SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-pay-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-pay-list Dialog-Frame _FREEFORM
  QUERY BR-cash-pay-list DISPLAY
      temp-cash-pay-list.cdpay-code COLUMN-LABEL "Код TH"
temp-cash-pay-list.curr-code COLUMN-LABEL "Код вал"
getcp-name (INPUT temp-cash-pay-list.cdpay-code, INPUT temp-cash-pay-list.curr-code) COLUMN-LABEL "Название типа касс.платежа TH" FORMAT "X(40)"
temp-cash-pay-list.frpay-code COLUMN-LABEL "Код ФР"
get-frpay-name( INPUT temp-cash-pay-list.frpay-code) @ v-frpay-name COLUMN-LABEL "Наим. кода оплаты на ФР" FORMAT "X(40)"
ENABLE
temp-cash-pay-list.frpay-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12
         TITLE "Типы кассовых платежей<->коды оплаты ФР" ROW-HEIGHT-CHARS .7 FIT-LAST-COLUMN.

DEFINE BROWSE BR-pay-names
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pay-names Dialog-Frame _FREEFORM
  QUERY BR-pay-names DISPLAY
      temp-pay-names.frpay-code COLUMN-LABEL  "Код в ФР"   FORMAT "9"
temp-pay-names.frpay-name COLUMN-LABEL  "Наименование" FORMAT "X(40)"
ENABLE
temp-pay-names.frpay-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.63 BY 4.5
         TITLE "Наименования типов оплат ФР" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-cash-shift AT ROW 4 COL 15 WIDGET-ID 46
     t-cash-drawer-plug AT ROW 4 COL 18 WIDGET-ID 76
     RS-cash-drawer-level AT ROW 4 COL 32.63 NO-LABEL WIDGET-ID 96
     f-advert-text1 AT ROW 4 COL 36.63 COLON-ALIGNED WIDGET-ID 102
     rs-log-level AT ROW 4 COL 79.63 NO-LABEL WIDGET-ID 178
     BR-pay-names AT ROW 5 COL 1 WIDGET-ID 200
     t-salesman-mandatory AT ROW 5 COL 15 WIDGET-ID 156
     RS-cash-drawer-plug-type AT ROW 5 COL 17.63 NO-LABEL WIDGET-ID 78
     CB-screen-type AT ROW 5 COL 23 COLON-ALIGNED WIDGET-ID 166
     f-advert-text2 AT ROW 5 COL 36.63 COLON-ALIGNED WIDGET-ID 104
     t-cutter AT ROW 5 COL 55 WIDGET-ID 90
     f-cash-drawer-plug-port AT ROW 5 COL 58 COLON-ALIGNED WIDGET-ID 84
     t-manual-discnt AT ROW 6 COL 15 WIDGET-ID 158
     f-screen-layout-id AT ROW 6 COL 23 COLON-ALIGNED WIDGET-ID 174
     f-cash-drawer-plug-imp AT ROW 6 COL 27.75 COLON-ALIGNED WIDGET-ID 86
     f-advert-text3 AT ROW 6 COL 36.63 COLON-ALIGNED WIDGET-ID 106
     b-screen-layout-id AT ROW 6 COL 40 WIDGET-ID 168
     f-com-port AT ROW 6 COL 66 COLON-ALIGNED WIDGET-ID 4
     t-clear-cash-counter AT ROW 7 COL 15 WIDGET-ID 184
     f-cash-drawer-limit AT ROW 7 COL 24 COLON-ALIGNED WIDGET-ID 50
     t-qnty-change AT ROW 8 COL 15 WIDGET-ID 186
     t-cash-drawer-open AT ROW 8 COL 18 WIDGET-ID 48
     f-cliche-lines1 AT ROW 8 COL 36.63 COLON-ALIGNED WIDGET-ID 112
     f-cliche-lines2 AT ROW 9 COL 36.63 COLON-ALIGNED WIDGET-ID 114
     b-add-cash-pay AT ROW 9 COL 77 WIDGET-ID 128
     b-del-cash-pay AT ROW 9 COL 87 WIDGET-ID 130
     BR-cash-pay-list AT ROW 10 COL 1 WIDGET-ID 100
     t-customer-display-plug AT ROW 10 COL 18 WIDGET-ID 92
     f-cliche-lines3 AT ROW 10 COL 36.63 COLON-ALIGNED WIDGET-ID 116
     CB-customer-display-type AT ROW 11 COL 25.25 COLON-ALIGNED WIDGET-ID 188
     f-cliche-lines4 AT ROW 11 COL 36.63 COLON-ALIGNED WIDGET-ID 118
     f-cliche-lines5 AT ROW 12 COL 36.63 COLON-ALIGNED WIDGET-ID 120
     f-customer-display-port AT ROW 12 COL 43.63 COLON-ALIGNED WIDGET-ID 190
     f-cliche-lines6 AT ROW 13 COL 36.63 COLON-ALIGNED WIDGET-ID 124
     f-customer-display-adv1 AT ROW 13 COL 37.63 COLON-ALIGNED WIDGET-ID 52
     t-print-good-code AT ROW 14 COL 18 WIDGET-ID 126
     f-customer-display-adv2 AT ROW 14 COL 37.63 COLON-ALIGNED WIDGET-ID 54
     f-max-netto AT ROW 15 COL 18 COLON-ALIGNED WIDGET-ID 44
     l-rmethod AT ROW 16 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 150
     CB-keyboard-type AT ROW 16 COL 23 COLON-ALIGNED WIDGET-ID 160
     rs-rmethod-type AT ROW 17 COL 15.63 NO-LABEL WIDGET-ID 146
     f-keyboard-layout-id AT ROW 17 COL 23 COLON-ALIGNED WIDGET-ID 172
     f-customer-display-adv AT ROW 17 COL 36.38 COLON-ALIGNED WIDGET-ID 74
     b-keyboard-layout-id AT ROW 17 COL 40 WIDGET-ID 162
     b-curr AT ROW 17 COL 47 WIDGET-ID 134
     f-nalc AT ROW 17 COL 48.75 COLON-ALIGNED WIDGET-ID 132
     f-rmethod-coeff AT ROW 17 COL 52.63 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     rs-rmethod-coeff AT ROW 17 COL 55 NO-LABEL WIDGET-ID 140
     v-rmethod-coeff AT ROW 18.21 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     CB-cashless-system AT ROW 19 COL 27.25 COLON-ALIGNED WIDGET-ID 176
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-advert-text AT ROW 19.67 COL 32.63 COLON-ALIGNED WIDGET-ID 108
     f-cliche-lines AT ROW 19.67 COL 32.63 COLON-ALIGNED WIDGET-ID 110
     t-card-reader-plug AT ROW 20 COL 18 WIDGET-ID 88
     t-rcpt-ord-slip-print AT ROW 20 COL 18 WIDGET-ID 198
     t-rcpt-ord-alt-print AT ROW 21 COL 18 WIDGET-ID 200
     CB-cctv-system AT ROW 21 COL 24 COLON-ALIGNED WIDGET-ID 192
     f-cctv-system-address AT ROW 21 COL 73 COLON-ALIGNED WIDGET-ID 196
     b-interface AT ROW 2.58 COL 57 WIDGET-ID 40
     B-devices AT ROW 2.58 COL 15 WIDGET-ID 16
     b-rec-print AT ROW 2.58 COL 43 WIDGET-ID 34
     B-main AT ROW 2.58 COL 1 WIDGET-ID 14
     b-fisreg AT ROW 2.58 COL 29 WIDGET-ID 28
     f-main AT ROW 2.96 COL 2.63 NO-LABEL WIDGET-ID 18
     F-devices AT ROW 2.96 COL 16.63 NO-LABEL WIDGET-ID 20
     f-fisreg AT ROW 2.96 COL 30.63 NO-LABEL WIDGET-ID 26
     f-rec-print AT ROW 2.96 COL 44.63 NO-LABEL WIDGET-ID 36
     f-interface AT ROW 2.96 COL 58.63 NO-LABEL WIDGET-ID 42
     l-cash-drawer-level AT ROW 4 COL 1 NO-LABEL WIDGET-ID 100
     l-log-level AT ROW 4 COL 56 COLON-ALIGNED NO-LABEL WIDGET-ID 182
     l-cash-drawer-plug-type AT ROW 5 COL 1 NO-LABEL WIDGET-ID 82
     f-screen-layout-name AT ROW 6 COL 55 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     for-curr-name AT ROW 17 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 136
     f-keyboard-layout-name AT ROW 17 COL 55 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     SPACE(13.39) SKIP(4.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки по умолчанию и опции работы POS IBS TH"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-pay-names rs-log-level Dialog-Frame */
/* BROWSE-TAB BR-cash-pay-list b-del-cash-pay Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-advert-text IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-advert-text:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-cliche-lines IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-cliche-lines:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-customer-display-adv IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-customer-display-adv:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-devices IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-fisreg IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-interface IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-keyboard-layout-id IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-keyboard-layout-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-main IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-rec-print IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-rmethod-coeff IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-rmethod-coeff:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-screen-layout-id IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-screen-layout-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-cash-drawer-level IN FRAME Dialog-Frame
   NO-DISPLAY ALIGN-L                                                   */
/* SETTINGS FOR FILL-IN l-cash-drawer-plug-type IN FRAME Dialog-Frame
   NO-DISPLAY ALIGN-L                                                   */
/* SETTINGS FOR FILL-IN l-log-level IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-rmethod IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-rmethod-coeff IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       v-rmethod-coeff:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-pay-list
/* Query rebuild information for BROWSE BR-cash-pay-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-cash-pay-list.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-cash-pay-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pay-names
/* Query rebuild information for BROWSE BR-pay-names
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-pay-names.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-pay-names */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки по умолчанию и опции работы POS IBS TH */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-cash-pay Dialog-Frame
ON CHOOSE OF b-add-cash-pay IN FRAME Dialog-Frame /* Добавить */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid AS recid NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_temp-cash-pay-list FOR temp-cash-pay-list.
  run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input {&all}
              ,input (if p-obj-type = "" then 0 else v-host-code)
              ,input (if p-obj-type = '' then '':U else p-obj-type)
              ,input (if p-obj-type = '' then 0 else p-obj-code)
              ,OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN no-apply.
FIND FIRST buf_cash-pay NO-LOCK WHERE
        RECID(buf_cash-pay) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
IF NOT AVAILABLE buf_cash-pay  THEN RETURN NO-APPLY.
if buf_cash-pay.cdpay-code = 1 then do:
  message
  "Для платежа типа НАЛИЧНЫЕ (тип касс. платежа = 1) соответствие с типами оплат ФР определять НЕ НАДО!"
  view-as alert-box error .
  undo, return no-apply.
end.
FIND FIRST buf_temp-cash-pay-list WHERE
            buf_temp-cash-pay-list.cdpay-code = buf_cash-pay.cdpay-code
    AND     buf_temp-cash-pay-list.curr-code = buf_cash-pay.curr-code NO-ERROR.
IF AVAILABLE buf_temp-cash-pay-list THEN DO:
    MESSAGE
    SUBSTITUTE("Вы уже добавили соответствие между типом кассового платежа в IBS TH с кодом &1 и валютой &2"
              , buf_cash-pay.cdpay-code
              , buf_cash-pay.curr-code)
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CREATE buf_temp-cash-pay-list.
ASSIGN
buf_temp-cash-pay-list.cdpay-code = buf_cash-pay.cdpay-code
buf_temp-cash-pay-list.curr-code = buf_cash-pay.curr-code
buf_temp-cash-pay-list.frpay-code = 0
.
v-rid = RECID(buf_temp-cash-pay-list).
OPEN QUERY br-cash-pay-list FOR EACH temp-cash-pay-list.
REPOSITION br-cash-pay-list TO RECID v-rid NO-ERROR.
APPLY "ENTRY" TO br-cash-pay-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-curr Dialog-Frame
ON CHOOSE OF b-curr IN FRAME Dialog-Frame
DO:
    define variable rr as recid no-undo.
    DEFINE BUFFER buf_currency FOR ub.currency.
    rr = ? .
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
                recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ f-nalc
      buf_currency.curr-abbr @ for-curr-name
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-cash-pay Dialog-Frame
ON CHOOSE OF b-del-cash-pay IN FRAME Dialog-Frame /* Удалить */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
MESSAGE
"Вы действительно хотите удалить это соответствие?"
 VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
 IF NOT glog  THEN RETURN NO-APPLY.
  IF NOT AVAILABLE temp-cash-pay-list THEN RETURN NO-APPLY.
  DELETE temp-cash-pay-list.
  OPEN QUERY br-cash-pay-list FOR EACH temp-cash-pay-list.
  REPOSITION br-cash-pay-list TO ROW 1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-devices
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-devices Dialog-Frame
ON CHOOSE OF B-devices IN FRAME Dialog-Frame
DO:
run proc-init-devices in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fisreg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fisreg Dialog-Frame
ON CHOOSE OF b-fisreg IN FRAME Dialog-Frame
DO:
run proc-init-fisreg in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-interface
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-interface Dialog-Frame
ON CHOOSE OF b-interface IN FRAME Dialog-Frame
DO:
run proc-init-interface in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-keyboard-layout-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-keyboard-layout-id Dialog-Frame
ON CHOOSE OF b-keyboard-layout-id IN FRAME Dialog-Frame /* Btn 1 */
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_layout FOR ub.layout.
  IF f-keyboard-layout-id <> '' THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                buf_layout.layout-id = f-keyboard-layout-id NO-ERROR.
  END.
      run adm/layoutss.w (
                           INPUT parparentproc
                         ,input "b-sel"
                         ,INPUT "layout-type" /*p-list-mode*/
                          ,INPUT {&th-pos-keyboard}
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
    IF v-rid-list <> ''
    AND v-rid-list <> STRING(RECID(buf_layout)) THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                recid(buf_layout) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_layout THEN DO:
          ASSIGN
          f-keyboard-layout-id = ''
          f-keyboard-layout-name = ?
          .

      END.
      ELSE DO:
          ASSIGN
          f-keyboard-layout-id = buf_layout.layout-id
          f-keyboard-layout-name = buf_layout.layout-name
          .
      END.
      DISPLAY
      f-keyboard-layout-id
      f-keyboard-layout-name
      WITH FRAME {&FRAME-NAME}.

    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-main Dialog-Frame
ON CHOOSE OF B-main IN FRAME Dialog-Frame /* 1.Перемещ. */
DO:
   run proc-init-main in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rec-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rec-print Dialog-Frame
ON CHOOSE OF b-rec-print IN FRAME Dialog-Frame
DO:
run proc-init-rec-print in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-screen-layout-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-screen-layout-id Dialog-Frame
ON CHOOSE OF b-screen-layout-id IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_layout FOR ub.layout.
  IF f-screen-layout-id <> '' THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                buf_layout.layout-id = f-screen-layout-id NO-ERROR.
  END.
      run adm/layoutss.w (
                           INPUT parparentproc
                         ,input "b-sel"
                         ,INPUT "layout-type" /*p-list-mode*/
                          ,INPUT {&th-pos-screen}
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
    IF v-rid-list <> ''
    AND v-rid-list <> STRING(RECID(buf_layout)) THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                recid(buf_layout) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_layout THEN DO:
          ASSIGN
          f-screen-layout-id = ''
          f-screen-layout-name = ?
          .

      END.
      ELSE DO:
          ASSIGN
          f-screen-layout-id = buf_layout.layout-id
          f-screen-layout-name = buf_layout.layout-name
          .
      END.
      DISPLAY
      f-screen-layout-id
      f-screen-layout-name
      WITH FRAME {&FRAME-NAME}.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-cashless-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-cashless-system Dialog-Frame
ON VALUE-CHANGED OF CB-cashless-system IN FRAME Dialog-Frame /* Система безнал.платежей */
DO:
  ASSIGN
  cb-cashless-system.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-cctv-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-cctv-system Dialog-Frame
ON VALUE-CHANGED OF CB-cctv-system IN FRAME Dialog-Frame /* Тип сис-мы видеонабл. */
DO:
  ASSIGN
  cb-cctv-system.
  case cb-cctv-system:
    when '' then do:
      f-cctv-system-address = ''.
      display
      f-cctv-system-address
      with frame {&frame-name} .
      disable
      f-cctv-system-address
      with frame {&frame-name} .
    end.
    otherwise do:
      if p-mode <> {&lookup} then do:
        enable
        f-cctv-system-address
        with frame {&frame-name} .
      end.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-keyboard-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-keyboard-type Dialog-Frame
ON VALUE-CHANGED OF CB-keyboard-type IN FRAME Dialog-Frame /* Тип клавиатуры */
DO:
  ASSIGN
  cb-keyboard-type.
  CASE cb-keyboard-type:
      WHEN '' THEN DO:
        ASSIGN
        f-keyboard-layout-id = ''
        f-keyboard-layout-name = ''
        .
        DISPLAY
        f-keyboard-layout-id
        f-keyboard-layout-name
        WITH FRAME {&FRAME-NAME}.
        DISABLE
        b-keyboard-layout-id
        WITH FRAME {&FRAME-NAME}.
      END.
      OTHERWISE DO:
          Enable
          b-keyboard-layout-id
          WITH FRAME {&FRAME-NAME}.

         APPLY "CHOOSE" TO b-keyboard-layout-id .
      END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-screen-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-screen-type Dialog-Frame
ON VALUE-CHANGED OF CB-screen-type IN FRAME Dialog-Frame /* Тип интерфейса */
DO:
    ASSIGN
  cb-screen-type.
  APPLY "CHOOSE" TO b-screen-layout-id .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-advert-text1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-advert-text1 Dialog-Frame
ON LEAVE OF f-advert-text1 IN FRAME Dialog-Frame /* Рекламный текст1 */
DO:
  ASSIGN
  f-advert-text1
  f-advert-text = f-advert-text1 + {&delim-par} +
                  f-advert-text2 + {&delim-par} +
                  f-advert-text3
  f-advert-text:screen-value = f-advert-text
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-advert-text2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-advert-text2 Dialog-Frame
ON LEAVE OF f-advert-text2 IN FRAME Dialog-Frame /* Рекламный текст2 */
DO:
  ASSIGN
  f-advert-text2
  f-advert-text = f-advert-text1 + {&delim-par} +
                  f-advert-text2 + {&delim-par} +
                  f-advert-text3
  f-advert-text:screen-value = f-advert-text
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-advert-text3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-advert-text3 Dialog-Frame
ON LEAVE OF f-advert-text3 IN FRAME Dialog-Frame /* Рекламный текст3 */
DO:
  ASSIGN
  f-advert-text3
  f-advert-text = f-advert-text1 + {&delim-par} +
                  f-advert-text2 + {&delim-par} +
                  f-advert-text3
 f-advert-text:SCREEN-VALUE = f-advert-text
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cliche-lines1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cliche-lines1 Dialog-Frame
ON LEAVE OF f-cliche-lines1 IN FRAME Dialog-Frame /* Строки клише1 */
DO:
  ASSIGN
  f-cliche-lines1
  f-cliche-lines = f-cliche-lines1 + {&delim-par} +
                   f-cliche-lines2 + {&delim-par} +
                   f-cliche-lines3 + {&delim-par} +
                   f-cliche-lines4 + {&delim-par} +
                   f-cliche-lines5 + {&delim-par} +
                   f-cliche-lines6
  f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cliche-lines2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cliche-lines2 Dialog-Frame
ON LEAVE OF f-cliche-lines2 IN FRAME Dialog-Frame /* Строки клише2 */
DO:
  ASSIGN
   f-cliche-lines2
  f-cliche-lines = f-cliche-lines1 + {&delim-par} +
                   f-cliche-lines2 + {&delim-par} +
                   f-cliche-lines3 + {&delim-par} +
                   f-cliche-lines4 + {&delim-par} +
                   f-cliche-lines5 + {&delim-par} +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cliche-lines3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cliche-lines3 Dialog-Frame
ON LEAVE OF f-cliche-lines3 IN FRAME Dialog-Frame /* Строки клише3 */
DO:
  ASSIGN
  f-cliche-lines3
  f-cliche-lines = f-cliche-lines1 + {&delim-par} +
                   f-cliche-lines2 + {&delim-par} +
                   f-cliche-lines3 + {&delim-par} +
                   f-cliche-lines4 + {&delim-par} +
                   f-cliche-lines5 + {&delim-par} +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cliche-lines4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cliche-lines4 Dialog-Frame
ON LEAVE OF f-cliche-lines4 IN FRAME Dialog-Frame /* Строки клише4 */
DO:
  ASSIGN
    f-cliche-lines4
  f-cliche-lines = f-cliche-lines1 + {&delim-par} +
                   f-cliche-lines2 + {&delim-par} +
                   f-cliche-lines3 + {&delim-par} +
                   f-cliche-lines4 + {&delim-par} +
                   f-cliche-lines5 + {&delim-par} +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cliche-lines5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cliche-lines5 Dialog-Frame
ON LEAVE OF f-cliche-lines5 IN FRAME Dialog-Frame /* Строки клише5 */
DO:
  ASSIGN
    f-cliche-lines5
  f-cliche-lines = f-cliche-lines1 + {&delim-par} +
                   f-cliche-lines2 + {&delim-par} +
                   f-cliche-lines3 + {&delim-par} +
                   f-cliche-lines4 + {&delim-par} +
                   f-cliche-lines5 + {&delim-par} +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines

  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-cliche-lines6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-cliche-lines6 Dialog-Frame
ON LEAVE OF f-cliche-lines6 IN FRAME Dialog-Frame /* Строки клише6 */
DO:
  ASSIGN
    f-cliche-lines6
  f-cliche-lines = f-cliche-lines1 + {&delim-par} +
                   f-cliche-lines2 + {&delim-par} +
                   f-cliche-lines3 + {&delim-par} +
                   f-cliche-lines4 + {&delim-par} +
                   f-cliche-lines5 + {&delim-par} +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-com-port
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-com-port Dialog-Frame
ON VALUE-CHANGED OF f-com-port IN FRAME Dialog-Frame /* ФР подключен к */
DO:
  assign f-com-port.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-customer-display-adv1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-customer-display-adv1 Dialog-Frame
ON LEAVE OF f-customer-display-adv1 IN FRAME Dialog-Frame /* Текст рекл. на дисплее покупателя1 */
DO:
  ASSIGN
  f-customer-display-adv1
  f-customer-display-adv = f-customer-display-adv1 + {&delim-par} + f-customer-display-adv2
  f-customer-display-adv:SCREEN-VALUE = f-customer-display-adv
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-customer-display-adv2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-customer-display-adv2 Dialog-Frame
ON LEAVE OF f-customer-display-adv2 IN FRAME Dialog-Frame /* Текст рекл. на дисплее покупателя2 */
DO:
    ASSIGN
    f-customer-display-adv2
    f-customer-display-adv = f-customer-display-adv1 + {&delim-par} + f-customer-display-adv2
    f-customer-display-adv:SCREEN-VALUE = f-customer-display-adv
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-rmethod-coeff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-rmethod-coeff Dialog-Frame
ON LEAVE OF f-rmethod-coeff IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
  IF rs-rmethod-type = "NO-COINS" THEN DO:
    ASSIGN
    f-rmethod-coeff
    v-rmethod-coeff = f-rmethod-coeff
    v-rmethod-coeff:screen-value = string(v-rmethod-coeff)
    .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cash-drawer-plug-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cash-drawer-plug-type Dialog-Frame
ON VALUE-CHANGED OF RS-cash-drawer-plug-type IN FRAME Dialog-Frame
DO:
    ASSIGN
  rs-cash-drawer-plug-type.
  CASE rs-cash-drawer-plug-type:
    WHEN 1 THEN DO:
       DISPLAY
       f-cash-drawer-plug-port
       WITH FRAME {&FRAME-NAME}.

    END.
    WHEN 0 THEN DO:
        hide
        f-cash-drawer-plug-port
        IN FRAME {&FRAME-NAME}.

    END.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-rmethod-coeff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-rmethod-coeff Dialog-Frame
ON VALUE-CHANGED OF rs-rmethod-coeff IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }
  IF rs-rmethod-type = "MROUND" THEN DO:
    ASSIGN
    rs-rmethod-coeff
    v-rmethod-coeff = rs-rmethod-coeff
    v-rmethod-coeff:screen-value = string(v-rmethod-coeff)
    .
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-rmethod-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-rmethod-type Dialog-Frame
ON VALUE-CHANGED OF rs-rmethod-type IN FRAME Dialog-Frame
DO:
 ASSIGN
 rs-rmethod-type.
 disable
 f-rmethod-coeff
 with frame {&frame-name} .
 DISPLAY
 l-rmethod
 WITH FRAME {&FRAME-NAME}.
 CASE rs-rmethod-type:
   WHEN "MROUND" THEN DO:
     ASSIGN
     rs-rmethod-coeff:VISIBLE IN FRAME {&FRAME-NAME} = YES
     f-rmethod-coeff:VISIBLE IN FRAME {&FRAME-NAME} = NO
     .
   END.
   WHEN "NO-COINS" THEN DO:
       ASSIGN
       rs-rmethod-coeff:VISIBLE IN FRAME {&FRAME-NAME} = NO
       f-rmethod-coeff:VISIBLE IN FRAME {&FRAME-NAME} = YES
       f-rmethod-coeff:sensitive IN FRAME {&FRAME-NAME} = (p-mode <> {&lookup})
       .

   END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cash-drawer-plug
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cash-drawer-plug Dialog-Frame
ON VALUE-CHANGED OF t-cash-drawer-plug IN FRAME Dialog-Frame /* Подключать ДЯ */
DO:
  ASSIGN
  t-cash-drawer-plug.
  CASE t-cash-drawer-plug:
    WHEN no THEN DO:
      IF p-mode <> {&lookup} THEN DO:
        ASSIGN
        t-cash-drawer-open = NO
        rs-cash-drawer-plug-type = 0
        f-cash-drawer-plug-imp = 1
        f-cash-drawer-plug-port = 0
        rs-cash-drawer-level = 1
        f-cash-drawer-limit = 1000000.00
        .
        DISPLAY
        rs-cash-drawer-plug-type
        f-cash-drawer-plug-port
        f-cash-drawer-plug-imp
        f-cash-drawer-limit
        WITH FRAME {&FRAME-NAME}.
        disable
        f-cash-drawer-plug-imp
        f-cash-drawer-plug-port
        RS-cash-drawer-level
        rs-cash-drawer-plug-type
        t-cash-drawer-open
        f-cash-drawer-limit
        with FRAME {&FRAME-NAME}.
      END.
    END.
    WHEN YES THEN DO:
        IF p-mode <> {&lookup} THEN DO:
          enable
          f-cash-drawer-plug-imp
          f-cash-drawer-plug-port
          RS-cash-drawer-level
          rs-cash-drawer-plug-type
          t-cash-drawer-open
          f-cash-drawer-limit
          WITH FRAME {&FRAME-NAME}.
        END.
        ASSIGN
        RS-cash-drawer-level:VISIBLE IN FRAME {&FRAME-NAME} = no
        t-cash-drawer-open:VISIBLE IN FRAME {&FRAME-NAME} = yes
        .

    END.
  END CASE.
  APPLY "VALUE-CHANGED" TO rs-cash-drawer-plug-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-customer-display-plug
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-customer-display-plug Dialog-Frame
ON VALUE-CHANGED OF t-customer-display-plug IN FRAME Dialog-Frame /* Подключать дисплей покупателя */
DO:
  ASSIGN
  t-customer-display-plug.
  CASE t-customer-display-plug:
    WHEN no THEN DO:
      IF p-mode <> {&lookup} THEN DO:
        ASSIGN
        cb-customer-display-type = ''
        f-customer-display-port = ''
        f-customer-display-adv1 = fill('_', 20)
        f-customer-display-adv2 = fill('_', 20)
        .
        DISPLAY
        cb-customer-display-type
        f-customer-display-port
        f-customer-display-adv1
        f-customer-display-adv2
        WITH FRAME {&FRAME-NAME}.
        disable
        f-customer-display-port
        CB-customer-display-type
        f-customer-display-adv1
        f-customer-display-adv2
        with FRAME {&FRAME-NAME}.
      END.
    END.
    WHEN YES THEN DO:
        IF p-mode <> {&lookup} THEN DO:
          enable
          f-customer-display-port
          cb-customer-display-type
          f-customer-display-adv1
          f-customer-display-adv2
          WITH FRAME {&FRAME-NAME}.
        END.
        ASSIGN
        CB-customer-display-type:VISIBLE IN FRAME {&FRAME-NAME} = yes
        f-customer-display-port:VISIBLE IN FRAME {&FRAME-NAME} = yes
        f-customer-display-adv1:VISIBLE IN FRAME {&FRAME-NAME} = yes
        f-customer-display-adv2:VISIBLE IN FRAME {&FRAME-NAME} = yes
        .

    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-pay-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

ON LEAVE OF temp-cash-pay-list.frpay-code IN BROWSE br-cash-pay-list do:

define variable old-frpay-code    AS integer no-undo .

if not avail temp-cash-pay-list then return no-apply.
ASSIGN
OLD-frpay-code = temp-cash-pay-list.frpay-code
.
IF NOT (INTEGER(temp-cash-pay-list.frpay-code) >= 2
        OR
        INTEGER(temp-cash-pay-list.frpay-code) <= 4
        )
        THEN DO:
  MESSAGE
  "Неверный код вида оплаты ФР"
  VIEW-AS ALERT-BOX ERROR.
  ASSIGN
  temp-cash-pay-list.frpay-code = old-frpay-code
  .
  DISPLAY
  temp-cash-pay-list.frpay-code
  with BROWSE br-cash-pay-list.
  RETURN NO-APPLY.
END.
ASSIGN
temp-cash-pay-list.frpay-code = INTEGER(temp-cash-pay-list.frpay-code:SCREEN-VALUE IN BROWSE br-cash-pay-list)
.
DISPLAY
get-frpay-name (temp-cash-pay-list.frpay-code) @ v-frpay-name
WITH BROWSE br-cash-pay-list.
br-cash-pay-list:REFRESH() IN FRAME {&FRAME-NAME}.
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-current-tab-order underline-tb }
{ gbl/rethndmv.i v-current-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ibs-th}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ibs-th}
    and   locked_thbj-attr.prop-code = '':U
    NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY t-cash-shift t-cash-drawer-plug RS-cash-drawer-level f-advert-text1 
          rs-log-level t-salesman-mandatory RS-cash-drawer-plug-type 
          CB-screen-type f-advert-text2 t-cutter f-cash-drawer-plug-port 
          t-manual-discnt f-screen-layout-id f-cash-drawer-plug-imp 
          f-advert-text3 f-com-port t-clear-cash-counter f-cash-drawer-limit 
          t-qnty-change t-cash-drawer-open f-cliche-lines1 f-cliche-lines2 
          t-customer-display-plug f-cliche-lines3 CB-customer-display-type 
          f-cliche-lines4 f-cliche-lines5 f-customer-display-port 
          f-cliche-lines6 f-customer-display-adv1 t-print-good-code 
          f-customer-display-adv2 f-max-netto l-rmethod CB-keyboard-type 
          rs-rmethod-type f-keyboard-layout-id f-nalc rs-rmethod-coeff 
          CB-cashless-system t-card-reader-plug t-rcpt-ord-slip-print 
          t-rcpt-ord-alt-print CB-cctv-system f-cctv-system-address f-main 
          F-devices f-fisreg f-rec-print f-interface l-log-level 
          f-screen-layout-name for-curr-name f-keyboard-layout-name 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-cash-shift t-cash-drawer-plug 
         RS-cash-drawer-level f-advert-text1 rs-log-level BR-pay-names 
         t-salesman-mandatory RS-cash-drawer-plug-type CB-screen-type 
         f-advert-text2 t-cutter f-cash-drawer-plug-port t-manual-discnt 
         f-cash-drawer-plug-imp f-advert-text3 b-screen-layout-id f-com-port 
         t-clear-cash-counter f-cash-drawer-limit t-qnty-change 
         t-cash-drawer-open f-cliche-lines1 f-cliche-lines2 b-add-cash-pay 
         b-del-cash-pay BR-cash-pay-list t-customer-display-plug 
         f-cliche-lines3 CB-customer-display-type f-cliche-lines4 
         f-cliche-lines5 f-customer-display-port f-cliche-lines6 
         f-customer-display-adv1 t-print-good-code f-customer-display-adv2 
         f-max-netto CB-keyboard-type rs-rmethod-type b-keyboard-layout-id 
         b-curr f-nalc rs-rmethod-coeff CB-cashless-system t-card-reader-plug 
         t-rcpt-ord-slip-print t-rcpt-ord-alt-print CB-cctv-system 
         f-cctv-system-address b-interface B-devices b-rec-print B-main 
         b-fisreg f-main F-devices f-fisreg f-rec-print f-interface 
         l-cash-drawer-level l-cash-drawer-plug-type for-curr-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE v-dop1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fr-code AS integer NO-UNDO.
DEFINE VARIABLE v-cp-list AS character NO-UNDO.
DEFINE VARIABLE v-name AS character NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-jj AS integer NO-UNDO.
DEFINE BUFFER buf_currency FOR ub.currency.
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-ibs-th}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
         
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  CASE thbjattr_thbj-attr.upper-prop-code :
    WHEN {&attr-cd-type-ibs-th_ibs-th_main} THEN DO:
      CASE v-entry:
        WHEN {&attr-cd-type-ibs-th_ibs-th_main_cash-shift} THEN DO:
          ASSIGN
          t-cash-shift = logical(thbjattr_thbj-attr.property-value-integer)
          t-cash-shift:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_main_nalc} THEN DO:
          ASSIGN
          f-nalc = thbjattr_thbj-attr.property-value-integer
          f-nalc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
          FIND FIRST buf_currency NO-LOCK WHERE
                    buf_currency.curr-code = f-nalc NO-ERROR.
          IF AVAILABLE buf_currency THEN DO:
              ASSIGN
              for-curr-name = buf_currency.curr-abbr.

          END.
        END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_main_salesman-mandatory} THEN DO:
          ASSIGN
          t-salesman-mandatory = logical(thbjattr_thbj-attr.property-value-integer)
          t-salesman-mandatory:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN {&attr-cd-type-ibs-th_ibs-th_main_manual-discnt} THEN DO:
          ASSIGN
          t-manual-discnt = logical(thbjattr_thbj-attr.property-value-integer)
          t-manual-discnt:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN {&attr-cd-type-ibs-th_ibs-th_main_log-level} THEN DO:
          ASSIGN
          rs-log-level = thbjattr_thbj-attr.property-value-integer
          rs-log-level:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN {&attr-cd-type-ibs-th_ibs-th_main_clear-cash-counter} THEN DO:
          ASSIGN
          t-clear-cash-counter = logical(thbjattr_thbj-attr.property-value-integer)
          t-clear-cash-counter:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN {&attr-cd-type-ibs-th_ibs-th_main_qnty-change} THEN DO:
          ASSIGN
          t-qnty-change = logical(thbjattr_thbj-attr.property-value-integer)
          t-qnty-change:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.

     END CASE.
   END.
   WHEN {&attr-cd-type-ibs-th_ibs-th_devices} THEN DO:
     CASE v-entry:
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-plug} THEN DO:
         ASSIGN
         t-cash-drawer-plug = logical(thbjattr_thbj-attr.property-value-integer)
         t-cash-drawer-plug:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-plug-type} THEN DO:
         ASSIGN
         rs-cash-drawer-plug-type = thbjattr_thbj-attr.property-value-integer
         rs-cash-drawer-plug-type:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
           .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-plug-port} THEN DO:
         ASSIGN
         f-cash-drawer-plug-port = thbjattr_thbj-attr.property-value-integer
         f-cash-drawer-plug-port:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-plug-imp} THEN DO:
         ASSIGN
         f-cash-drawer-plug-imp = thbjattr_thbj-attr.property-value-integer
         f-cash-drawer-plug-imp:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
      WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-open} THEN DO:
        ASSIGN
        t-cash-drawer-open = logical(thbjattr_thbj-attr.property-value-integer)
        t-cash-drawer-open:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      END.
      WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-limit} THEN DO:
        ASSIGN
        f-cash-drawer-limit = thbjattr_thbj-attr.property-value-decimal
        f-cash-drawer-limit:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_card-reader-plug} THEN DO:
         ASSIGN
         t-card-reader-plug = logical(thbjattr_thbj-attr.property-value-integer)
         t-card-reader-plug:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_customer-display-plug} THEN DO:
         ASSIGN
         t-customer-display-plug = logical(thbjattr_thbj-attr.property-value-integer)
         t-customer-display-plug:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
        WHEN {&attr-cd-type-ibs-th_ibs-th_devices_customer-display-adv} THEN DO:
          ASSIGN
          f-customer-display-adv = thbjattr_thbj-attr.property-value-character
          f-customer-display-adv1 = entry(1, thbjattr_thbj-attr.property-value-character, {&delim-par})
          f-customer-display-adv2 = entry(2, thbjattr_thbj-attr.property-value-character, {&delim-par})
          NO-ERROR
          .
          f-customer-display-adv:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr)).
        END.

       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_keyboard-type} THEN DO:
         ASSIGN
         cb-keyboard-type = thbjattr_thbj-attr.property-value-character
         cb-keyboard-type:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_keyboard-layout-id} THEN DO:
         ASSIGN
         f-keyboard-layout-id = thbjattr_thbj-attr.property-value-character
         f-keyboard-layout-id:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cashless-system} THEN DO:
         ASSIGN
         cb-cashless-system = thbjattr_thbj-attr.property-value-character
         cb-cashless-system:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_customer-display-type} THEN DO:
         ASSIGN
         cb-customer-display-type = thbjattr_thbj-attr.property-value-character
         cb-customer-display-type:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_customer-display-port} THEN DO:
         ASSIGN
         f-customer-display-port = thbjattr_thbj-attr.property-value-character
         f-customer-display-port:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cctv-system} THEN DO:
         ASSIGN
         cb-cctv-system = thbjattr_thbj-attr.property-value-character
         cb-cctv-system:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN {&attr-cd-type-ibs-th_ibs-th_devices_cctv-system-address} THEN DO:
         ASSIGN
         f-cctv-system-address = thbjattr_thbj-attr.property-value-character
         f-cctv-system-address:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
      END CASE.
    END.
    WHEN {&attr-cd-type-ibs-th_ibs-th_fisreg} THEN DO:
      CASE v-entry:
        WHEN {&attr-cd-type-ibs-th_ibs-th_fisreg_cash-drawer-level} THEN DO:
         ASSIGN
         rs-cash-drawer-level = thbjattr_thbj-attr.property-value-integer
         rs-cash-drawer-level:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
           .
        END.
         WHEN {&attr-cd-type-ibs-th_ibs-th_fisreg_cash-pay-list} THEN DO:
            run get-cash-pay-list in this-procedure ( input thbjattr_thbj-attr.property-value-character).
         END.
         WHEN {&attr-cd-type-ibs-th_ibs-th_fisreg_pay-names} THEN DO:
           run get-pay-names in this-procedure ( input thbjattr_thbj-attr.property-value-character).
         END.
         WHEN {&attr-cd-type-ibs-th_ibs-th_fisreg_cutter} THEN DO:
          ASSIGN
          t-cutter = logical(thbjattr_thbj-attr.property-value-integer)
          t-cutter:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
         END.
         WHEN {&cda-ibs-th_fisreg_com-port} THEN DO:
            ASSIGN
            f-com-port = thbjattr_thbj-attr.property-value-character
            f-com-port:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          END.
        
      end case.
    END.
    WHEN {&attr-cd-type-ibs-th_ibs-th_rec-print} THEN DO:
      CASE v-entry:
        WHEN {&attr-cd-type-ibs-th_ibs-th_rec-print_max-netto} THEN DO:
          ASSIGN
          f-max-netto = thbjattr_thbj-attr.property-value-decimal
          f-max-netto:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN {&attr-cd-type-IBS-TH_ibs-th_rec-print_advert-text} THEN DO:

         ASSIGN
         f-advert-text = thbjattr_thbj-attr.property-value-character
         f-advert-text:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         f-advert-text1 = ENTRY(1, f-advert-text, {&delim-par})
         f-advert-text2 = ENTRY(2, f-advert-text, {&delim-par})
         f-advert-text3 = ENTRY(3, f-advert-text, {&delim-par})
         .
        END.
        WHEN {&attr-cd-type-IBS-TH_ibs-th_rec-print_cliche-lines} THEN DO:
          ASSIGN
          f-cliche-lines = thbjattr_thbj-attr.property-value-character
          f-cliche-lines:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          f-cliche-lines1 = ENTRY(1, f-cliche-lines, {&delim-par})
          f-cliche-lines2 = ENTRY(2, f-cliche-lines, {&delim-par})
          f-cliche-lines3 = ENTRY(3, f-cliche-lines, {&delim-par})
          f-cliche-lines4 = ENTRY(4, f-cliche-lines, {&delim-par})
          f-cliche-lines5 = ENTRY(5, f-cliche-lines, {&delim-par})
          f-cliche-lines6 = ENTRY(6, f-cliche-lines, {&delim-par})
          .
        END.
        WHEN {&attr-cd-type-IBS-TH_ibs-th_rec-print_print-good-code} THEN DO:
             ASSIGN
             t-print-good-code = logical(thbjattr_thbj-attr.property-value-integer)
             t-print-good-code:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
             .
        END.
        when {&attr-cd-type-ibs-th_ibs-th_rec-print_rmethod-type} then do:
         ASSIGN
         rs-rmethod-type = thbjattr_thbj-attr.property-value-character
         rs-rmethod-type:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
        end.
        when {&attr-cd-type-ibs-th_ibs-th_rec-print_rmethod-coeff} then do:
         ASSIGN
         v-rmethod-coeff = thbjattr_thbj-attr.property-value-decimal
         v-rmethod-coeff:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       when {&attr-cd-type-ibs-th_ibs-th_rec-print_rcpt-ord-slip-print} then do:
         ASSIGN
         t-rcpt-ord-slip-print = logical(thbjattr_thbj-attr.property-value-integer)
         t-rcpt-ord-slip-print:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       when {&attr-cd-type-ibs-th_ibs-th_rec-print_rcpt-ord-alt-print} then do:
         ASSIGN
         t-rcpt-ord-alt-print = logical(thbjattr_thbj-attr.property-value-integer)
         t-rcpt-ord-alt-print:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.

      END CASE.
    END.
    WHEN {&attr-cd-type-ibs-th_ibs-th_interface} THEN DO:
      CASE v-entry:
        WHEN {&attr-cd-type-ibs-th_ibs-th_interface_screen-type} THEN DO:
          ASSIGN
          cb-screen-type = thbjattr_thbj-attr.property-value-character
          cb-screen-type:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN {&attr-cd-type-ibs-th_ibs-th_interface_screen-layout-id} THEN DO:
          ASSIGN
          f-screen-layout-id = thbjattr_thbj-attr.property-value-character
          f-screen-layout-id:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
      end CASE.
    END.
  END CASE.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
if rs-rmethod-type = "MROUND" then do:
  ASSIGN
  rs-rmethod-coeff = v-rmethod-coeff
  f-rmethod-coeff = 0
  .
end.
else do:
  assign
  f-rmethod-coeff = v-rmethod-coeff
  rs-rmethod-coeff = 2
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS HANDLE NO-UNDO.
DEFINE VARIABLE v-h1 AS HANDLE NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-jj AS integer NO-UNDO.
define variable v-list-items as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
DEFINE BUFFER buf_layout FOR ub.layout.
v-list-items = {&comma-char}.
do v-ii = 1 to num-entries({&cd-cd-types}):
  v-list-items = v-list-items + {&comma-char} +
                 entry(v-ii, {&cd-cd-types-full}) + {&comma-char} + entry(v-ii, {&cd-cd-types})
  .
end.
assign
cb-customer-display-type:list-item-pairs in frame {&frame-name} = v-list-items
.
v-list-items = ''.


do v-ii = 1 to num-entries({&cd-log-level-list}):
  v-list-items = v-list-items + (if v-ii = 1 then '' else {&comma-char}) +
                 entry(v-ii, {&cd-log-level-list-full}) + {&comma-char} + entry(v-ii, {&cd-log-level-list})
  .
end.
assign
rs-log-level:radio-buttons in frame {&frame-name} = v-list-items
.
v-list-items = ''.
assign
rs-rmethod-type:radio-buttons in frame {&frame-name} = "Отсечение до n-знака после зап." + {&comma-char} + "MROUND" + {&comma-char} +
                                                        "Нет номиналов меньше чем" + {&comma-char} + "NO-COINS"
.

rs-rmethod-coeff:radio-buttons in frame {&frame-name} = "Сотни" + {&comma-char} +  "-2" + {&comma-char} +
                                                      "Десятки" + {&comma-char} + "-1"  + {&comma-char} +
                                                      "{&abbr_rubli_firstshift}" + {&comma-char} + "0" + {&comma-char}  +
                                                      "Десятки {&abbr_kopeek}" + {&comma-char} + "1"  + {&comma-char} +
                                                      "{&abbr_kopeyki}" + {&comma-char} + "2"
                                                      .

assign
cb-keyboard-type:list-items in frame {&frame-name}  = {&comma-char} + {&th-pos-device-keyboard-list}.
cb-screen-type:list-items in frame {&frame-name}  =  {&th-pos-device-screen-list}.
v-list-items = {&comma-char}.
&scop cd-cashless-system-code entry(v-ii, ~{&cd-cashless-systems~})
do v-ii = 1 to  num-entries({&cd-cashless-systems}):
  assign
  v-list-items = v-list-items + {&comma-char} + {&cd-cashless-system-name} + {&comma-char} + {&cd-cashless-system-code}.
end.
assign
cb-cashless-system:list-item-pairs in frame {&frame-name} =  v-list-items
.
&scop cd-cctv-system-code entry(v-ii, ~{&cd-cctv-systems~})
v-list-items = {&comma-char}.
do v-ii = 1 to  num-entries({&cd-cctv-systems}):
  assign
  v-list-items = v-list-items + {&comma-char} + {&cd-cctv-system-name} + {&comma-char} + {&cd-cctv-system-code}.
end.
assign
cb-cctv-system:list-item-pairs in frame {&frame-name} =  v-list-items
.
if rs-rmethod-type = "MROUND" then do:
  ASSIGN
  rs-rmethod-coeff = v-rmethod-coeff
  f-rmethod-coeff = 0
  rs-rmethod-coeff:screen-value in frame {&frame-name} = string(v-rmethod-coeff) no-error
  .
end.
else do:
  assign
  f-rmethod-coeff = v-rmethod-coeff
  rs-rmethod-coeff = 2
  rs-rmethod-coeff:screen-value in frame {&frame-name} = string(2)
  .
end.
ASSIGN
l-rmethod = "Тип и коэфф.округления суммы чека".
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2&3"
                                       ,FRAME {&FRAME-NAME}:TITLE
                                       ,(if p-obj-type = ""
                                         then ""
                                         else {&shop})
                                       ,(IF p-obj-type = "" THEN "" ELSE string(p-obj-code)))
v-tab-order[1] = "t-cash-shift,t-salesman-mandatory,t-manual-discnt,t-clear-cash-counter,t-qnty-change,b-curr,rs-log-level"
v-labels[1] = 'f-nalc,for-curr-name,l-log-level'
v-tab-order[2] = "t-cash-drawer-plug,rs-cash-drawer-plug-type,f-cash-drawer-plug-port,f-cash-drawer-plug-imp,f-cash-drawer-limit,t-cash-drawer-open," +
                 "t-customer-display-plug,cb-customer-display-type,f-customer-display-port,f-customer-display-adv1,f-customer-display-adv2," +
                 "cb-keyboard-type,b-keyboard-layout-id,cb-cashless-system,t-card-reader-plug,cb-cctv-system,f-cctv-system-address"
v-labels[2] = 'l-cash-drawer-plug-type,f-keyboard-layout-id,f-keyboard-layout-name'
v-tab-order[3] = "rs-cash-drawer-level,br-cash-pay-list,b-add-cash-pay,b-del-cash-pay,br-pay-names,t-cutter,f-com-port"
v-labels[3] = "l-cash-drawer-level"
v-tab-order[4] = "f-advert-text1,f-advert-text2,f-advert-text3," +
                   "f-cliche-lines1,f-cliche-lines2,f-cliche-lines3,f-cliche-lines4," +
                  "t-print-good-code,f-max-netto,rs-rmethod-type,rs-rmethod-coeff,f-rmethod-coeff,t-rcpt-ord-slip-print,t-rcpt-ord-alt-print"
v-labels[4] = "l-rmethod"
v-tab-order[5] = "cb-screen-type,b-screen-layout-id"
v-labels[5] = "f-screen-layout-id,f-screen-layout-name"

.
v-h = FRAME {&FRAME-NAME}:FIRST-CHILD.
DO WHILE valid-handle(v-h).
  IF v-h:TYPE = "field-group"  THEN DO:
     v-h1 = v-h:FIRST-CHILD.
     DO WHILE valid-handle(v-h1).
      RUN tempwidg_create-record IN THIS-PROCEDURE ( INPUT v-h1).
      ASSIGN
      v-h1 = v-h1:NEXT-sibling.
    END.
  END.
  v-h = v-h:NEXT-SIBLING.
END.
DO v-ii = 1 TO 5:
  IF v-tab-order[v-ii] > '' THEN do:
    DO v-jj = 1 TO NUM-ENTRIES(v-tab-order[v-ii]):
     FIND FIRST temp-widget WHERE
                temp-widget.name_ = ENTRY(v-jj,v-tab-order[v-ii]) NO-ERROR.
     IF AVAILABLE temp-widget THEN DO:
         temp-widget.section_ = STRING(v-ii).
     END.
    END.
  END.
  IF v-labels[v-ii] > '' THEN do:
    DO v-jj = 1 TO NUM-ENTRIES(v-labels[v-ii]):
     FIND FIRST temp-widget WHERE
                temp-widget.name_ = ENTRY(v-jj,v-labels[v-ii]) NO-ERROR.
     IF AVAILABLE temp-widget THEN DO:
        temp-widget.section_ = STRING(v-ii).
      END.
    END.
  END.
END.
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines1", f-cliche-lines1).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines2", f-cliche-lines2).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines3", f-cliche-lines3).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines4", f-cliche-lines4).
/*
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines5", f-cliche-lines5).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines6", f-cliche-lines6).
*/
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-advert-text1", f-advert-text1).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-advert-text2", f-advert-text2).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-advert-text3", f-advert-text3).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-customer-display-adv1", f-customer-display-adv1).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-customer-display-adv2", f-customer-display-adv2).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-rmethod-coeff", f-rmethod-coeff).
FIND FIRST buf_layout NO-LOCK WHERE
          buf_layout.layout-id = f-keyboard-layout-id NO-ERROR.
IF AVAILABLE buf_layout THEN DO:
    ASSIGN
    f-keyboard-layout-name = buf_layout.layout-name.
END.
ELSE DO:
    ASSIGN
    f-keyboard-layout-name = ?.

END.
FIND FIRST buf_layout NO-LOCK WHERE
          buf_layout.layout-id = f-screen-layout-id NO-ERROR.
IF AVAILABLE buf_layout THEN DO:
    ASSIGN
    f-screen-layout-name = buf_layout.layout-name.
END.
ELSE DO:
    ASSIGN
    f-screen-layout-name = ?.

END.

DISPLAY
f-main
f-devices
f-fisreg
f-rec-print
f-interface
for-curr-name
l-cash-drawer-plug-type
l-cash-drawer-level
l-log-level
f-keyboard-layout-name
f-screen-layout-name
t-clear-cash-counter
t-qnty-change
WITH FRAME {&frame-name}.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
if wh:private-data begins "recid=" then do:
  find first thbjattr_thbj-attr where
            recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
  IF wh:DATA-TYPE = {&abl-datatype-logical}
  AND thbjattr_thbj-attr.prop-value-type = {&abl-datatype-integer} THEN DO:
     wh:screen-value = string(IF thbjattr_thbj-attr.property-value-integer = 1 THEN YES ELSE NO).

  END.
  ELSE DO:
    assign
    wh:screen-value = string(buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value).
  END.
end.
ELSE DO:
   FIND FIRST temp-widget NO-LOCK WHERE
             temp-widget.NAME_ = wh:NAME NO-ERROR.
   IF AVAILABLE temp-widget THEN DO:
      CASE temp-widget.DATA-TYPE_:
        WHEN {&abl-datatype-character} THEN DO:
            ASSIGN
            wh:SCREEN-VALUE = temp-widget.CHARACTER_.
        END.
      END CASE.
   END.
END.
wh = wh:next-sibling.
end.

ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
b-main
b-devices
b-fisreg
b-rec-print
b-interface
f-max-netto WHEN p-mode = {&UPDATE}
t-cash-shift WHEN p-mode = {&UPDATE}
t-salesman-mandatory WHEN p-mode = {&UPDATE}
t-manual-discnt WHEN p-mode = {&UPDATE}
t-cash-drawer-open WHEN p-mode = {&UPDATE}
f-cash-drawer-limit WHEN p-mode = {&UPDATE}
f-customer-display-adv1 WHEN p-mode = {&UPDATE}
f-customer-display-adv2 WHEN p-mode = {&UPDATE}
b-curr WHEN p-mode = {&UPDATE}
rs-rmethod-type WHEN p-mode = {&UPDATE}
rs-rmethod-coeff WHEN p-mode = {&UPDATE}
t-cash-drawer-plug WHEN p-mode = {&UPDATE}
rs-cash-drawer-plug-type WHEN p-mode = {&UPDATE}
f-cash-drawer-plug-port WHEN p-mode = {&UPDATE}
f-cash-drawer-plug-imp WHEN p-mode = {&UPDATE}
t-card-reader-plug WHEN p-mode = {&UPDATE}
t-cutter WHEN p-mode = {&UPDATE}
f-com-port WHEN p-mode = {&UPDATE}
t-customer-display-plug  WHEN p-mode = {&UPDATE}
cb-keyboard-type WHEN p-mode = {&UPDATE}
b-keyboard-layout-id WHEN p-mode = {&UPDATE}
cb-cashless-system WHEN p-mode = {&UPDATE}
cb-customer-display-type WHEN p-mode = {&UPDATE}
f-customer-display-port WHEN p-mode = {&UPDATE}
cb-screen-type WHEN p-mode = {&UPDATE}
b-screen-layout-id WHEN p-mode = {&UPDATE}
cb-cctv-system WHEN p-mode = {&UPDATE}
f-cctv-system-address WHEN p-mode = {&UPDATE}
rs-cash-drawer-level WHEN p-mode = {&UPDATE}
rs-log-level WHEN p-mode = {&UPDATE}
t-clear-cash-counter when p-mode = {&update}
t-qnty-change when p-mode = {&update}
br-cash-pay-list
br-pay-names
t-print-good-code WHEN p-mode = {&UPDATE}
t-rcpt-ord-slip-print WHEN p-mode = {&UPDATE}
t-rcpt-ord-alt-print WHEN p-mode = {&UPDATE}
f-advert-text1 WHEN p-mode = {&UPDATE}
f-advert-text2 WHEN p-mode = {&UPDATE}
f-advert-text3 WHEN p-mode = {&UPDATE}
f-cliche-lines1 WHEN p-mode = {&UPDATE}
f-cliche-lines2 WHEN p-mode = {&UPDATE}
f-cliche-lines3 WHEN p-mode = {&UPDATE}
f-cliche-lines4 WHEN p-mode = {&UPDATE}
/* ну не может ФР напечатать 6 строк!!!!
f-cliche-lines5 WHEN p-mode = {&UPDATE}
f-cliche-lines6 WHEN p-mode = {&UPDATE}
*/
b-add-cash-pay  WHEN p-mode = {&UPDATE}
b-del-cash-pay WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit
  IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COLUMN = 1
  temp-cash-pay-list.frpay-code:read-only IN BROWSE br-cash-pay-list = YES
  .
END.
HIDE
f-cliche-lines5
f-cliche-lines6
IN FRAME {&FRAME-NAME}.
OPEN QUERY br-cash-pay-list FOR EACH temp-cash-pay-list.
OPEN QUERY br-pay-names FOR EACH temp-pay-names.
APPLY "CHOOSE" TO b-main.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-devices Dialog-Frame 
PROCEDURE proc-init-devices :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-devices:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-devices:fgcolor = 1   .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-main:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-interface:fgcolor = ?
 .
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "2":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "2"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[2].
 APPLY "VALUE-CHANGED" TO t-cash-drawer-plug.
 APPLY "VALUE-CHANGED" TO t-customer-display-plug.
 APPLY "VALUE-CHANGED" TO cb-cctv-system.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-fisreg Dialog-Frame 
PROCEDURE proc-init-fisreg :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-fisreg:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-fisreg:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-devices:fgcolor = ?
 f-main:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-interface:fgcolor = ?
 .

 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "3":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.

 END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "3"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[3].
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-interface Dialog-Frame 
PROCEDURE proc-init-interface :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-interface:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-interface:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-main:fgcolor = ?
 .

 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "5":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "5"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[5].
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-main Dialog-Frame 
PROCEDURE proc-init-main :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-main:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-main:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-interface:fgcolor = ?
 .

 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "1":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "1"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[1].
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-rec-print Dialog-Frame 
PROCEDURE proc-init-rec-print :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-rec-print:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-rec-print:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-main:fgcolor = ?
 f-interface:fgcolor = ?
 .

 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "4":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.

END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "4"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[4].

 APPLY "VALUE-CHANGED" TO rs-rmethod-type.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
define variable v-loc-same as logical no-undo .
define variable v-cash-pay-list as character no-undo .
define variable v-pay-names as character no-undo .
define variable l-write-cd as logical no-undo .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.
MESSAGE
substitute( "Применить сделанные Вами изменения ко всем POS IBS TH&1&2?"
           ,{&NEW-LINE}
           ,(IF p-obj-type <> '' THEN substitute("&1&2", p-obj-type, p-obj-code) ELSE "")
           )
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-CANCEL UPDATE l-write-cd.
IF l-write-cd = ? THEN UNDO, RETURN ERROR.

run  set-cash-pay-list in this-procedure ( output v-cash-pay-list) no-error.
if error-status:error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
run set-pay-names in this-procedure ( output v-pay-names) no-error.
if error-status:error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  undo, return error .
end.

assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
 if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).

    IF wh:DATA-TYPE = {&abl-datatype-logical}
    AND thbjattr_thbj-attr.prop-value-type = {&abl-datatype-integer} THEN DO:
      assign
      thbjattr_thbj-attr.property-value-integer = (IF wh:INPUT-VALUE = YES THEN 1 ELSE 0).

    END.
    ELSE DO:
      assign
      buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.

    END.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where
          thbjattr_thbj-attr.upper-prop-code = {&attr-cd-type-IBS-TH_ibs-th_fisreg}
      and thbjattr_thbj-attr.prop-code = {&attr-cd-type-IBS-TH_ibs-th_fisreg_cash-pay-list}
      and thbjattr_thbj-attr.obj-type = p-obj-type
      and thbjattr_thbj-attr.obj-code = p-obj-code  .
assign
thbjattr_thbj-attr.property-value-character = v-cash-pay-list.
find first thbjattr_thbj-attr where
          thbjattr_thbj-attr.upper-prop-code = {&attr-cd-type-IBS-TH_ibs-th_fisreg}
      and thbjattr_thbj-attr.prop-code = {&attr-cd-type-IBS-TH_ibs-th_fisreg_pay-names}
      and thbjattr_thbj-attr.obj-type = p-obj-type
      and thbjattr_thbj-attr.obj-code = p-obj-code  .
assign
thbjattr_thbj-attr.property-value-character = v-pay-names.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code
break
by thbjattr_thbj-attr.upper-prop-code :
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-loc-same.
   if v-loc-same = no then do:
     v-same = v-loc-same.
     if l-write-cd = yes
     and thbjattr_thbj-attr.upper-prop-code <> {&attr-cd-type-IBS-TH}
     then do:
       run update-cda in this-procedure ( buffer thbjattr_thbj-attr).
     end.
     else do:
       leave.
    end.
   end.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.

for each thbjattr_thbj-attr
break by thbjattr_thbj-attr.upper-prop-code
:
  if first-of(thbjattr_thbj-attr.upper-prop-code) then do:
    empty temp-table thbjattr___thbj-attr.
  end.
  create thbjattr___thbj-attr.
  buffer-copy
  thbjattr_thbj-attr
  to
  thbjattr___thbj-attr.
  if last-of(thbjattr_thbj-attr.upper-prop-code) then do:
    run adm/shattri.p (
                  input "check":U
                , input p-obj-type
                , input p-obj-code
                , input thbjattr_thbj-attr.upper-prop-code
                , input '':U
                , output v-value-character
                , output v-value-date
                , output v-value-decimal
                , output v-value-integer
                , output v-value-logical
                , output v-param-type
                , input-output TABLE-handle v-tth_
                ) no-error .

    if error-status:error then do:
      message
      "Некорректное значение ПАРАМЕТРОВ" skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
    empty temp-table thbjattr___thbj-attr.
  end.
end.
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input {&attr-cd-type-ibs-th}
    ,input table thbjattr_thbj-attr
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1)  SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cda Dialog-Frame 
PROCEDURE update-cda :
DEFINE PARAMETER BUFFER buf_thbjattr_thbj-attr FOR thbjattr_thbj-attr.
define variable v-obj-db-num as integer no-undo .
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
case p-obj-type:
  when '':U then do:
    main-block:
    for each buf_Cash-desk no-lock where
            buf_cash-desk.pos-type = {&cd-type-ibs-th}
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       find first   buf_cash-desk-attr share-lock where
             buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         and buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         and buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
        and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
        no-error.
       if not available buf_Cash-desk-attr then do:
         create buf_cash-desk-attr.
         assign
         buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
         buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
         .
       end.
       assign
       buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
       buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
       buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
       buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
       buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
       buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
       .
    end.
  end.
  when {&shop} then do:
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-obj-db-num }
    main-block:
    for each buf_Cash-desk no-lock where
            buf_cash-desk.pos-type = {&cd-type-ibs-th}
        and buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.db-num = v-obj-db-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       find first   buf_cash-desk-attr share-lock where
             buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         and buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         and buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         and buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
        and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
        no-error.
       if not available buf_Cash-desk-attr then do:
         create buf_cash-desk-attr.
         assign
         buf_cash-desk-attr.db-num = buf_Cash-desk.db-num
         buf_cash-desk-attr.obj-code = buf_Cash-desk.obj-code
         buf_cash-desk-attr.pos-type = buf_Cash-desk.pos-type
         buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num
         buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
         buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
         .
       end.
       assign
       buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
       buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
       buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
       buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
       buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
       buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
       .
    end.
  end. /*when shop*/
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-frpay-name Dialog-Frame 
FUNCTION get-frpay-name RETURNS CHARACTER
  ( INPUT p-frpay-code AS INTEGER ) :
DEFINE BUFFER buf_temp-pay-names FOR temp-pay-names.
FIND first buf_temp-pay-names WHERE
        buf_temp-pay-names.frpay-code = p-frpay-code NO-ERROR.
IF NOT AVAILABLE buf_temp-pay-names THEN RETURN "".
RETURN buf_temp-pay-names.frpay-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getcp-name Dialog-Frame 
FUNCTION getcp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS INTEGER , INPUT p-curr-code AS INTEGER) :
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
FIND first buf_cash-pay NO-LOCK  WHERE
        buf_cash-pay.cdpay-code = p-cdpay-code
    AND buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF NOT AVAILABLE buf_cash-pay THEN RETURN "!!!НЕИЗВЕСТНЫЙ ТИП КАСС.ПЛАТЕЖА".
RETURN buf_cash-pay.obj-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

