&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка договора

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

*/

/* ***************************  Definitions  ************************** */

def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Карточка договора" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ trg/new-bcod.i }
{ gbl/thbjattr.i}
{ str/cont-ms.i}


/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code as integer   no-undo .
define input  parameter ref-mode    as character no-undo .   /* {&add-def}, {&update}, {&lookup}, "history" */
define input  parameter p-doc-type  as character no-undo .   /*   {&income} {&expense} */
define input-output parameter ri    as recid     no-undo .
/* Local Variable Definitions ---                                       */
define variable agnt-list as character no-undo .
define variable p-contr-type as character no-undo .

define  shared variable br-handle as handle  no-undo .
define  shared variable next-prev as logical no-undo .
DEFINE  SHARED BUFFER buf_contract FOR ub.contract .

define variable v-own-code-schet    as integer   no-undo .
define variable v-cli-code-schet    as integer   no-undo .
define variable v-posr-code-schet   as integer   no-undo .
define variable v-agnt-code-schet   as integer   no-undo .
define variable v-own-code-schet-2  as integer   no-undo .
define variable v-cli-code-schet-2  as integer   no-undo .
define variable v-posr-code-schet-2 as integer   no-undo .
define variable v-agnt-code-schet-2 as integer   no-undo .

define variable v-own-point-code    as integer   no-undo .
define variable v-own-point-db-num  as integer   no-undo .
define variable v-agnt-point-code   as integer   no-undo .
define variable v-agnt-point-db-num as integer   no-undo .
define variable v-cli-point-code    as integer   no-undo .
define variable v-cli-point-db-num  as integer   no-undo .
define variable v-posr-point-code   as integer   no-undo .
define variable v-posr-point-db-num as integer   no-undo .

define variable  v-transport-cli-type   like  ub.contract.transport-cli-type         .
define variable  v-transport-cli-code   like  ub.contract.transport-cli-code         .
define variable  v-transport-host       like  ub.contract.transport-host        .
define variable  v-transport-contract   like  ub.contract.transport-contract    .
define variable  v-transport-uslov      like  ub.contract.transport-uslov       .
define variable  v-transport-value      like  ub.contract.transport-value       .
define variable  v-transport-type       like  ub.contract.transport-type       .

define variable inn-own        as character no-undo .
define variable kpp-own        as character no-undo .
define variable addres-own     as character no-undo .
define variable sign-own       as character no-undo .
define variable sign-post-own  as character no-undo .
define variable inn-cli        as character no-undo .
define variable kpp-cli        as character no-undo .
define variable addres-cli     as character no-undo .
define variable sign-cli       as character no-undo .
define variable sign-post-cli  as character no-undo .
define variable inn-posr       as character no-undo .
define variable kpp-posr       as character no-undo .
define variable addres-posr    as character no-undo .
define variable sign-posr      as character no-undo .
define variable sign-post-posr as character no-undo .
define variable inn-agnt       as character no-undo .
define variable kpp-agnt       as character no-undo .
define variable addres-agnt    as character no-undo .
define variable sign-agnt      as character no-undo .
define variable sign-post-agnt as character no-undo .

define variable a-code-an-uchet as integer extent 6  no-undo .
define variable a-code-cel-nazn as integer extent 6  no-undo .
define variable a-code-cor-acc  as integer extent 6  no-undo .
define variable a-code-cor-acc-2  as integer extent 6  no-undo .

define variable g-log   as logical   no-undo .
define variable ref-rec as recid no-undo .
/*  */
DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-iMcMode     AS INTEGER    NO-UNDO . /* параметр fin-global/fo-mc-mode */
DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
/*  */
DEFINE VARIABLE iTmp-Host-Code     AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE iTmp-Contract-Code AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmp-Mode-W        AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE i-Cont-Ret         AS INTEGER   NO-UNDO INITIAL 0 EXTENT 3.

define buffer b_contract for ub.contract.
define buffer buf_c-contract for ub.c-contract.
define buffer buf_firm for ub.firm.
define buffer buf_clients for ub.clients.
define buffer buf_contract-attr for ub.contract-attr .
define variable v-log as logical no-undo. /* ТН-2356. 2014г. Арн. */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES contract

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH contract SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH contract SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame contract
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame contract


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK b-exit b-spec B-transport b-hist B-Help ~
RECT-8 RECT-9 T-edi T-diadoc T-edi-order contract-prn-code contract-date ~
contract-city contract-name BUTTON-curr contract-date-beg contract-date-end ~
curr-code COMBO-return-type COMBO-type-contr b-bank-own b-bank-cli cli-code ~
cli-type BUTTON-cli b-bank-posr posr-code posr-type BUTTON-posr b-bank-agnt ~
agnt-code agnt-type BUTTON-agnt mngr-code BUTTON-mngr COMBO-usl-opl ~
srok-opl COMBO-auto-pay COMBO-usl-opl-2 srok-opl-2 COMBO-auto-pay-2 ~
kredit-limit kredit-sum balance-fo str-uslov-oplat fin-VAT-pc RADIO-SET-1 ~
b-nal b-cor-acc b-an-uchet b-cel-nazn b-cor-acc-2 contract-code own-code 
&Scoped-Define DISPLAYED-OBJECTS T-edi T-diadoc T-edi-order ~
contract-prn-code contract-date contract-city contract-name ~
contract-date-beg contract-date-end curr-code COMBO-return-type ~
COMBO-type-contr cli-code cli-type posr-code posr-type agnt-code agnt-type ~
mngr-code COMBO-usl-opl srok-opl COMBO-auto-pay COMBO-usl-opl-2 srok-opl-2 ~
COMBO-auto-pay-2 kredit-limit kredit-sum balance-fo str-uslov-oplat ~
fin-VAT-pc RADIO-SET-1 b-nal cor-acc an-uchet cel-nazn cor-acc-2 ~
contract-code curr-name own-code own-name cli-name posr-name agnt-name ~
mngr-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Add-Inf 
     LABEL "Доп.инфо" 
     SIZE 10 BY 1.

DEFINE BUTTON b-an-uchet 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON b-bank-agnt 
     LABEL "&Реквизиты" 
     SIZE 10 BY 1.

DEFINE BUTTON b-bank-cli 
     LABEL "&Реквизиты" 
     SIZE 10 BY 1.

DEFINE BUTTON b-bank-own 
     LABEL "&Реквизиты" 
     SIZE 10 BY 1.

DEFINE BUTTON b-bank-posr 
     LABEL "&Реквизиты" 
     SIZE 10 BY 1.

DEFINE BUTTON b-cel-nazn 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON b-cor-acc 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON b-cor-acc-2 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "&Отмена":L 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist 
     LABEL "Ис&тория":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-next AUTO-GO 
     LABEL "&>>" 
     SIZE 5 BY 1.

DEFINE BUTTON b-OK AUTO-GO 
     LABEL "&Ввод ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-prev AUTO-GO 
     LABEL "&<<" 
     SIZE 5 BY 1.

DEFINE BUTTON b-spec 
     LABEL "Спецификация" 
     SIZE 14 BY 1.

DEFINE BUTTON B-transport 
     LABEL "Т&ранспорт" 
     SIZE 10 BY 1.

DEFINE BUTTON BUTTON-agnt 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-curr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "1" 
     SIZE 3.38 BY 1.13.

DEFINE BUTTON BUTTON-mngr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "3" 
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-posr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE VARIABLE COMBO-auto-pay AS CHARACTER FORMAT "X(256)":U 
     LABEL "Статус" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16 BY 1 TOOLTIP "Конечный статус сгенеренного финансового обязательства" NO-UNDO.

DEFINE VARIABLE COMBO-auto-pay-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Статус" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16 BY 1 TOOLTIP "Конечный статус сгенеренного счета-фактуры" NO-UNDO.

DEFINE VARIABLE COMBO-return-type AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0 
     LABEL "Схема возврата" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "",0,
                     "Обратная продажа",23,
                     "Корректировка поступления",25
     DROP-DOWN-LIST
     SIZE 26.25 BY 1 TOOLTIP "Схема возврата поставщику" NO-UNDO.

DEFINE VARIABLE COMBO-type-contr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип" 
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 40.5 BY 1 NO-UNDO.

DEFINE VARIABLE COMBO-usl-opl AS CHARACTER FORMAT "X(256)":U 
     LABEL "ФО" 
     VIEW-AS COMBO-BOX INNER-LINES 18
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 40.25 BY 1 TOOLTIP "Условие генерации финансового обязательства" NO-UNDO.

DEFINE VARIABLE COMBO-usl-opl-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Счета-фактуры" 
     VIEW-AS COMBO-BOX INNER-LINES 9
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 40.25 BY 1 TOOLTIP "Условие генерации счетов-фактур" NO-UNDO.

DEFINE VARIABLE agnt-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 52 BY 1.

DEFINE VARIABLE agnt-type AS CHARACTER FORMAT "X(3)" 
     VIEW-AS FILL-IN 
     SIZE 4.38 BY 1.

DEFINE VARIABLE an-uchet AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код аналитического учета" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE balance-fo AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Баланс" 
     VIEW-AS FILL-IN 
     SIZE 17.88 BY 1 NO-UNDO.

DEFINE VARIABLE cel-nazn AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код целевого назначения" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 52 BY 1.

DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)" 
     VIEW-AS FILL-IN 
     SIZE 4.38 BY 1.

DEFINE VARIABLE contract-city AS CHARACTER FORMAT "X(20)" 
     LABEL "Город" 
     VIEW-AS FILL-IN 
     SIZE 19.5 BY 1.

DEFINE VARIABLE contract-code AS INTEGER FORMAT ">>>>>>>>>" INITIAL 0 
     LABEL "Вн.№." 
      VIEW-AS TEXT 
     SIZE 11.38 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE contract-date AS DATE FORMAT "99/99/9999" INITIAL 10/13/03 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 11.13 BY 1.

DEFINE VARIABLE contract-date-beg AS DATE FORMAT "99/99/9999" INITIAL 10/13/03 
     LABEL "Действие с" 
     VIEW-AS FILL-IN 
     SIZE 11.13 BY 1 TOOLTIP "Начало действия договора".

DEFINE VARIABLE contract-date-end AS DATE FORMAT "99/99/9999" 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 TOOLTIP "Окончание дейстия договора".

DEFINE VARIABLE contract-name AS CHARACTER FORMAT "X(85)" 
     LABEL "Заголовок" 
     VIEW-AS FILL-IN 
     SIZE 66.5 BY 1.

DEFINE VARIABLE contract-prn-code AS CHARACTER FORMAT "X(48)" 
     LABEL "№" 
     VIEW-AS FILL-IN 
     SIZE 31 BY 1.

DEFINE VARIABLE cor-acc AS CHARACTER FORMAT "X(256)":U 
     LABEL "Корреспондирующий счет" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE cor-acc-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Корресп. счет (касса)" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE curr-code AS INTEGER FORMAT ">>9" INITIAL 0 
     LABEL "Валюта договора" 
     VIEW-AS FILL-IN 
     SIZE 3.75 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE curr-name AS CHARACTER FORMAT "X(5)":U 
      VIEW-AS TEXT 
     SIZE 4.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fin-VAT-pc AS DECIMAL FORMAT ">9.9<%" INITIAL 0 
     LABEL "НДС" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1.

DEFINE VARIABLE kredit-sum AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 18.13 BY 1 NO-UNDO.

DEFINE VARIABLE mngr-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1.

DEFINE VARIABLE mngr-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 52 BY 1 NO-UNDO.

DEFINE VARIABLE own-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0 
      VIEW-AS TEXT 
     SIZE 10 BY 1.

DEFINE VARIABLE own-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 60.5 BY .75 NO-UNDO.

DEFINE VARIABLE posr-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1.

DEFINE VARIABLE posr-name AS CHARACTER FORMAT "X(40)" 
      VIEW-AS TEXT 
     SIZE 52 BY 1.

DEFINE VARIABLE posr-type AS CHARACTER FORMAT "X(3)" 
     VIEW-AS FILL-IN 
     SIZE 4.38 BY 1.

DEFINE VARIABLE srok-opl AS INTEGER FORMAT ">>9" INITIAL 0 
     LABEL "Срок" 
     VIEW-AS FILL-IN 
     SIZE 4.38 BY 1.

DEFINE VARIABLE srok-opl-2 AS INTEGER FORMAT ">>9" INITIAL 0 
     LABEL "Срок" 
     VIEW-AS FILL-IN 
     SIZE 4.38 BY 1.

DEFINE VARIABLE str-uslov-oplat AS CHARACTER FORMAT "X(30)" 
     LABEL "Условия оплаты" 
     VIEW-AS FILL-IN 
     SIZE 46.5 BY 1 TOOLTIP "Условия оплаты".

DEFINE VARIABLE b-nal AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "б/н", 1,
"нал.", 2,
"АПЗ", 3
     SIZE 9 BY 2.08 TOOLTIP "Форма платежа" NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "РПП", 1,
"ППП", 2,
"РКО", 3,
"ПКО", 4,
"Рс.АПЗ", 5,
"Пр.АПЗ", 6
     SIZE 9.5 BY 4.21 TOOLTIP "Тип платежа" NO-UNDO.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.38 BY 2.75.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.38 BY 7.67.

DEFINE VARIABLE kredit-limit AS LOGICAL INITIAL no 
     LABEL "Ограничение кредита" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.25 BY 1 NO-UNDO.

DEFINE VARIABLE T-diadoc AS LOGICAL INITIAL no 
     LABEL "Поставки через Диадок" 
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-edi AS LOGICAL INITIAL no 
     LABEL "Поставки через ЭДО" 
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.

DEFINE VARIABLE T-edi-order AS LOGICAL INITIAL no 
     LABEL "Электронные заказы EDI" 
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      contract SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     b-prev AT ROW 1 COL 21
     b-next AT ROW 1 COL 26
     b-spec AT ROW 1 COL 35
     B-transport AT ROW 1 COL 49
     B-Add-Inf AT ROW 1 COL 59 WIDGET-ID 10
     b-hist AT ROW 1 COL 78
     B-Help AT ROW 1 COL 88
     T-edi AT ROW 1.13 COL 70 WIDGET-ID 12
     T-diadoc AT ROW 1.88 COL 70 WIDGET-ID 14
     T-edi-order AT ROW 2.63 COL 70 WIDGET-ID 16
     contract-prn-code AT ROW 3.58 COL 2.5 COLON-ALIGNED
     contract-date AT ROW 3.58 COL 39.75 COLON-ALIGNED
     contract-city AT ROW 3.58 COL 58.5 COLON-ALIGNED
     contract-name AT ROW 4.67 COL 12 COLON-ALIGNED
     BUTTON-curr AT ROW 5.58 COL 89
     contract-date-beg AT ROW 5.67 COL 12 COLON-ALIGNED
     contract-date-end AT ROW 5.67 COL 27.63 COLON-ALIGNED
     curr-code AT ROW 5.67 COL 83 COLON-ALIGNED
     COMBO-return-type AT ROW 6.58 COL 70 COLON-ALIGNED
     COMBO-type-contr AT ROW 6.67 COL 12 COLON-ALIGNED
     b-bank-own AT ROW 7.58 COL 85.13
     b-bank-cli AT ROW 8.58 COL 85.13
     cli-code AT ROW 8.45 COL 12 COLON-ALIGNED NO-LABEL
     cli-type AT ROW 8.45 COL 22.13 COLON-ALIGNED NO-LABEL
     BUTTON-cli AT ROW 8.45 COL 28.75
     b-bank-posr AT ROW 9.58 COL 85.13
     posr-code AT ROW 9.23 COL 12 COLON-ALIGNED NO-LABEL
     posr-type AT ROW 9.23 COL 22.13 COLON-ALIGNED NO-LABEL
     BUTTON-posr AT ROW 9.23 COL 28.75
     b-bank-agnt AT ROW 10.58 COL 85.13
     agnt-code AT ROW 10.75 COL 12 COLON-ALIGNED NO-LABEL
     agnt-type AT ROW 10.75 COL 22.13 COLON-ALIGNED NO-LABEL
     BUTTON-agnt AT ROW 10.75 COL 28.75
     mngr-code AT ROW 10.03 COL 12 COLON-ALIGNED NO-LABEL
     BUTTON-mngr AT ROW 10.03 COL 28.75
     COMBO-usl-opl AT ROW 13.46 COL 16 COLON-ALIGNED
     srok-opl AT ROW 13.46 COL 65 COLON-ALIGNED
     COMBO-auto-pay AT ROW 13.46 COL 79.5 COLON-ALIGNED
     COMBO-usl-opl-2 AT ROW 14.54 COL 16 COLON-ALIGNED
     srok-opl-2 AT ROW 14.54 COL 65 COLON-ALIGNED
     COMBO-auto-pay-2 AT ROW 14.54 COL 79.5 COLON-ALIGNED
     kredit-limit AT ROW 16.67 COL 2.5
     kredit-sum AT ROW 16.67 COL 23 COLON-ALIGNED NO-LABEL
     balance-fo AT ROW 16.67 COL 77.63 COLON-ALIGNED
     str-uslov-oplat AT ROW 17.71 COL 23 COLON-ALIGNED
     fin-VAT-pc AT ROW 17.71 COL 77.63 COLON-ALIGNED
     RADIO-SET-1 AT ROW 19.33 COL 2.5 NO-LABEL
     b-nal AT ROW 19.33 COL 14 NO-LABEL
     cor-acc AT ROW 19.5 COL 53.5 COLON-ALIGNED
     b-cor-acc AT ROW 19.5 COL 94.88
     an-uchet AT ROW 20.5 COL 53.5 COLON-ALIGNED
     b-an-uchet AT ROW 20.5 COL 94.88
     cel-nazn AT ROW 21.5 COL 53.5 COLON-ALIGNED
     b-cel-nazn AT ROW 21.5 COL 94.88
     cor-acc-2 AT ROW 22.5 COL 53.5 COLON-ALIGNED
     b-cor-acc-2 AT ROW 22.5 COL 94.88
     contract-code AT ROW 3.58 COL 85.63 COLON-ALIGNED
     curr-name AT ROW 5.58 COL 90.5 COLON-ALIGNED NO-LABEL
     own-code AT ROW 7.67 COL 12.25 COLON-ALIGNED NO-LABEL
     own-name AT ROW 7.83 COL 21.5 COLON-ALIGNED NO-LABEL
     cli-name AT ROW 8.45 COL 31.75 NO-LABEL
     posr-name AT ROW 9.23 COL 31.75 NO-LABEL
     agnt-name AT ROW 10.75 COL 31.75 NO-LABEL
     mngr-name AT ROW 10.03 COL 31.75 NO-LABEL
     "ГЕНЕРАЦИЯ" VIEW-AS TEXT
          SIZE 10.5 BY .83 AT ROW 12.0 COL 1.5 WIDGET-ID 2
          FGCOLOR 4 
     "Фирма:" VIEW-AS TEXT
          SIZE 6.13 BY .92 AT ROW 7.67 COL 7
          FGCOLOR 4 
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Контрагент:" VIEW-AS TEXT
          SIZE 11.5 BY 1 AT ROW 8.45 COL 2
          FGCOLOR 4 
     "Посредник:" VIEW-AS TEXT
          SIZE 10.13 BY 1 AT ROW 9.23 COL 2.88
          FGCOLOR 4 
     "Исполнитель:" VIEW-AS TEXT
          SIZE 12 BY 1 AT ROW 9.95 COL 1.13
          FGCOLOR 4 
     "Агент:" VIEW-AS TEXT
          SIZE 6.13 BY 1 AT ROW 10.75 COL 6.88
          FGCOLOR 4 
     "ОПЛАТА" VIEW-AS TEXT
          SIZE 7 BY .83 AT ROW 14.58 COL 1.5
          FGCOLOR 4 
     RECT-8 AT ROW 13.13 COL 1.25 WIDGET-ID 4
     RECT-9 AT ROW 16.13 COL 1.25 WIDGET-ID 6
     SPACE(0.61) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Договор".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN agnt-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN an-uchet IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       an-uchet:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR BUTTON B-Add-Inf IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-Add-Inf:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-next IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-prev IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       balance-fo:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN cel-nazn IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       cel-nazn:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN cli-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       contract-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN cor-acc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       cor-acc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN cor-acc-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       cor-acc-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN curr-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN mngr-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN own-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN posr-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.contract"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Договор */
DO:
  if ref-mode = {&update} or ref-mode = {&add-def} then do:
    message "Отменить сделанные изменения?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
    next-prev = ?.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME agnt-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL agnt-code Dialog-Frame
ON LEAVE OF agnt-code IN FRAME Dialog-Frame
DO:
  if agnt-code = int ( agnt-code:screen-value ) then return.
  assign agnt-code.
  run find-cli in this-procedure (input 3, input agnt-type, input agnt-code) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL agnt-code Dialog-Frame
ON RETURN OF agnt-code IN FRAME Dialog-Frame
DO:
  if agnt-code = int ( agnt-code:screen-value ) then return.
  assign agnt-code.
  run find-cli in this-procedure (input 3, input agnt-type, input agnt-code) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME agnt-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL agnt-type Dialog-Frame
ON LEAVE OF agnt-type IN FRAME Dialog-Frame
DO:
  assign agnt-type.
  run find-cli in this-procedure (input 3, input agnt-type, input agnt-code) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Add-Inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Add-Inf Dialog-Frame
ON CHOOSE OF B-Add-Inf IN FRAME Dialog-Frame /* Доп.инфо */
DO:
   DEF VAR cError AS CHARACTER NO-UNDO INITIAL "". 
   /* */ 
   RUN str/contaddi.w(
           INPUT parParentProc, 
           INPUT THIS-PROCEDURE:HANDLE,
           INPUT ref-mode,
           INPUT p-doc-type,
           INPUT ri,
           OUTPUT cError
          ). 
   IF cError <> ""  THEN DO:
      MESSAGE cError 
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
   END.
   RETURN NO-APPLY. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-an-uchet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-an-uchet Dialog-Frame
ON CHOOSE OF b-an-uchet IN FRAME Dialog-Frame /* 2 */
DO:
  { gbl/stdbtn.i }
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.

  assign p-rec = ? .
  if a-code-an-uchet [RADIO-SET-1] <> ? then do:
    find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.fin-code = a-code-an-uchet [RADIO-SET-1] and ub.fin-code-an-uchet.host-code = p-host-code no-error .
    if available ub.fin-code-an-uchet then assign p-rec = recid (ub.fin-code-an-uchet) .
  end.

  run ref/fwcode-3.w  ( input parParentProc, input "b-sel", input {&company}, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-an-uchet no-lock where RECID(ub.fin-code-an-uchet) = int (rid-list) no-error .
    if available ub.fin-code-an-uchet then
      assign
        an-uchet = ub.fin-code-an-uchet.code-value + "  " + ub.fin-code-an-uchet.descr
        a-code-an-uchet [RADIO-SET-1] = ub.fin-code-an-uchet.fin-code
      .
    else assign a-code-an-uchet [RADIO-SET-1] = ?  an-uchet = "" .
  end.
  else assign a-code-an-uchet [RADIO-SET-1] = ?  an-uchet = "" .
  display an-uchet with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank-agnt Dialog-Frame
ON CHOOSE OF b-bank-agnt IN FRAME Dialog-Frame /* Реквизиты */
DO:
  { gbl/stdbtn.i }
  if agnt-code > 0 and ( agnt-type = {&prs} or agnt-type = {&cmp} ) then do:
    run str/cont-rcw.w (input parParentProc, input p-host-code, input 3, input ref-mode, input agnt-code, input agnt-type,
                  input-output agnt-name, input-output v-agnt-code-schet, input-output v-agnt-code-schet-2, input-output kpp-agnt,
                  input-output inn-agnt, input-output addres-agnt, input-output sign-agnt, input-output sign-post-agnt,
                  input-output v-agnt-point-code,input-output v-agnt-point-db-num
                  ).
    display agnt-name with frame {&frame-name}.
  end.
  else do:
    message "Не выбран агент!"  view-as alert-box.
    apply "ENTRY" to agnt-code in frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank-cli Dialog-Frame
ON CHOOSE OF b-bank-cli IN FRAME Dialog-Frame /* Реквизиты */
DO:
  { gbl/stdbtn.i }
  if cli-code > 0 and ( cli-type = {&prs} or cli-type = {&cmp} ) then do:
    run str/cont-rcw.w (input parParentProc, input p-host-code, input 1, input ref-mode, input cli-code, input cli-type,
                  input-output cli-name, input-output v-cli-code-schet, input-output v-cli-code-schet-2, input-output kpp-cli,
                  input-output inn-cli, input-output addres-cli, input-output sign-cli, input-output sign-post-cli,
                  input-output v-cli-point-code,input-output v-cli-point-db-num
                  ).
    display cli-name with frame {&frame-name}.
  end.
  else do:
    message "Не выбран контрагент!"  view-as alert-box.
    apply "ENTRY" to cli-code in frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank-own
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank-own Dialog-Frame
ON CHOOSE OF b-bank-own IN FRAME Dialog-Frame /* Реквизиты */
DO:
  { gbl/stdbtn.i }
  run str/cont-rcw.w (input parParentProc, input p-host-code, input 0, input ref-mode, input p-host-code, input {&cmp},
                  input-output own-name, input-output v-own-code-schet, input-output v-own-code-schet-2, input-output kpp-own,
                  input-output inn-own, input-output addres-own, input-output sign-own, input-output sign-post-own,
                  input-output v-own-point-code,input-output v-own-point-db-num
                  ).
  display own-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank-posr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank-posr Dialog-Frame
ON CHOOSE OF b-bank-posr IN FRAME Dialog-Frame /* Реквизиты */
DO:
  { gbl/stdbtn.i }
  if posr-code > 0 and ( posr-type = {&prs} or posr-type = {&cmp} ) then do:
    run str/cont-rcw.w (input parParentProc, input p-host-code, input 2, input ref-mode, input posr-code, input posr-type,
                  input-output posr-name, input-output v-posr-code-schet, input-output v-posr-code-schet-2, input-output kpp-posr,
                  input-output inn-posr, input-output addres-posr, input-output sign-posr, input-output sign-post-posr,
                  input-output v-posr-point-code,input-output v-posr-point-db-num
                  ).
    display posr-name with frame {&frame-name}.
  end.
  else do:
    message "Не выбран посредник!"  view-as alert-box.
    apply "ENTRY" to posr-code in frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cel-nazn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cel-nazn Dialog-Frame
ON CHOOSE OF b-cel-nazn IN FRAME Dialog-Frame /* 2 */
DO:
  { gbl/stdbtn.i }
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.

  assign p-rec = ? .
  if a-code-cel-nazn [RADIO-SET-1] <> ? then do:
    find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.fin-code = a-code-cel-nazn [RADIO-SET-1] and ub.fin-code-cel-nazn.host-code = p-host-code no-error .
    if available ub.fin-code-cel-nazn then assign p-rec = recid (ub.fin-code-cel-nazn) .
  end.

  run ref/fwcode-2.w  ( input parParentProc, input "b-sel", input {&company}, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-cel-nazn no-lock where RECID(ub.fin-code-cel-nazn) = int (rid-list) no-error .
    if available ub.fin-code-cel-nazn then
      assign
        cel-nazn = ub.fin-code-cel-nazn.code-value + "  " + ub.fin-code-cel-nazn.descr
        a-code-cel-nazn [RADIO-SET-1] = ub.fin-code-cel-nazn.fin-code
      .
    else assign a-code-cel-nazn [RADIO-SET-1] = ?  cel-nazn = "" .
  end.
  else assign a-code-cel-nazn [RADIO-SET-1] = ?  cel-nazn = "" .
  display cel-nazn with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cor-acc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cor-acc Dialog-Frame
ON CHOOSE OF b-cor-acc IN FRAME Dialog-Frame /* 2 */
DO:
  { gbl/stdbtn.i }
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.

  assign p-rec = ? .
  if a-code-cor-acc [RADIO-SET-1]<> ? then do:
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code = a-code-cor-acc [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
    if available ub.fin-code-cor-acc then assign p-rec = recid (ub.fin-code-cor-acc) .
  end.

  run ref/fwcode-1.w  ( input parParentProc, input "b-sel", input {&company}, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-cor-acc no-lock where RECID(ub.fin-code-cor-acc) = int (rid-list) no-error .
    if available ub.fin-code-cor-acc then
      assign
        cor-acc = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr
        a-code-cor-acc [RADIO-SET-1]= ub.fin-code-cor-acc.fin-code
      .
    else assign a-code-cor-acc [RADIO-SET-1]= ?  cor-acc = "" .
  end.
  else assign a-code-cor-acc [RADIO-SET-1]= ?  cor-acc = "" .
  display cor-acc with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cor-acc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cor-acc-2 Dialog-Frame
ON CHOOSE OF b-cor-acc-2 IN FRAME Dialog-Frame /* 2 */
DO:
  { gbl/stdbtn.i }
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.

  assign p-rec = ? .
  if a-code-cor-acc-2 [RADIO-SET-1]<> ? then do:
    find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code = a-code-cor-acc-2 [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
    if available ub.fin-code-cor-acc then assign p-rec = recid (ub.fin-code-cor-acc) .
  end.

  run ref/fwcode-1.w  ( input parParentProc, input "b-sel", input {&company}, input p-rec, input p-host-code, output rid-list )  .
  if rid-list <> "" then do:
    find first ub.fin-code-cor-acc no-lock where RECID(ub.fin-code-cor-acc) = int (rid-list) no-error .
    if available ub.fin-code-cor-acc then
      assign
        cor-acc-2 = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr
        a-code-cor-acc-2 [RADIO-SET-1]= ub.fin-code-cor-acc.fin-code
      .
    else assign a-code-cor-acc-2 [RADIO-SET-1]= ?  cor-acc-2 = "" .
  end.
  else assign a-code-cor-acc-2 [RADIO-SET-1]= ?  cor-acc-2 = "" .
  display cor-acc-2 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Отмена */
DO:  /* отказ - выход  */
  next-prev = ?.
  if ref-mode = {&update} or ref-mode = {&add-def} then do:
    message "Отменить сделанные изменения?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:  /* отказ - выход  */
  if ref-mode = {&update} or ref-mode = {&lookup} then do:
    define variable v-ri as character initial "" no-undo .
    if available b_contract then run str/contr-c.w (input parparentproc,input p-host-code, input b_contract.contract-code,input "",input-output v-ri) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-nal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-nal Dialog-Frame
ON VALUE-CHANGED OF b-nal IN FRAME Dialog-Frame
DO:
  assign b-nal .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
run step-next.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK Dialog-Frame
ON CHOOSE OF b-OK IN FRAME Dialog-Frame /* Ввод  */
DO:
  next-prev = ? .
  if ref-mode = {&update} or ref-mode = {&add-def} then do:
    { gbl/stdbtn.i }
    assign
      contract-date COMBO-type-contr COMBO-usl-opl srok-opl contract-name contract-prn-code contract-city own-name
      contract-date-beg  contract-date-end  curr-code cli-type cli-code posr-type posr-code  agnt-type
      agnt-code mngr-code str-uslov-oplat COMBO-auto-pay RADIO-SET-1 COMBO-usl-opl-2 COMBO-auto-pay-2 srok-opl-2 T-edi t-diadoc
      COMBO-return-type T-edi-order
    .
    run create-proc in this-procedure no-error .
    if error-status:error then return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
   run step-prev.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spec Dialog-Frame
ON CHOOSE OF b-spec IN FRAME Dialog-Frame /* Спецификация */
DO:
  define variable v-rid-list as char no-undo.
  /* устанавливаем переменные запуска интерфейса спецификации  */
  ASSIGN
     iTmp-Host-Code       = p-host-code
     iTmp-Contract-Code   = buf_contract.contract-code
     cTmp-Mode-W          = ref-mode
     .
  /* Если работаем по схеме с матер договорами, в случае работы с подчиненным договором
     устанавливаем параметры от мастер договора !!!  */
  IF v-iMcMode = 1 OR v-iMcMode = 2 THEN DO:
     /* Проверяем договор !!!  */
     RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
         INPUT  p-Host-Code,
         INPUT  contract-code,
         OUTPUT i-Cont-Ret
         ).
     /* Если у договора есть мастер договор -
        переназначаем Host-code и Contract-code,\
        чтобы спецификация бралась из мастер договора
     */
     IF i-Cont-Ret[1] = 2 THEN DO: /* подчиненный договор  */
        ASSIGN
           iTmp-Host-Code       = i-Cont-Ret[2]
           iTmp-Contract-Code   = i-Cont-Ret[3]
           cTmp-Mode-W          = {&lookup}
           .
     END.
  END.
  /*  */
  RUN str/contspec.w (
      INPUT  parparentproc,
      INPUT  "b-mark",
      INPUT  cTmp-Mode-W,
      INPUT  iTmp-Host-Code,
      INPUT  iTmp-Contract-Code,
      OUTPUT v-rid-list
      ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-transport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-transport Dialog-Frame
ON CHOOSE OF B-transport IN FRAME Dialog-Frame /* Транспорт */
DO:
  run adm/conftran.w ( input if ref-mode = {&add-def} then {&update} else ref-mode ,
                       input "contract",
                       input p-host-code,
                       input parParentProc,
                       input-output v-transport-cli-type ,
                       input-output v-transport-cli-code ,
                       input-output v-transport-host,
                       input-output v-transport-contract,
                       input-output v-transport-uslov,
                       input-output v-transport-value,
                       input-output v-transport-type
                       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-agnt Dialog-Frame
ON CHOOSE OF BUTTON-agnt IN FRAME Dialog-Frame /* 2 */
DO:
  run ref/cli-all.w ( parParentProc, "b-sel", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> {&prs} and ub.clients.obj-type <> {&cmp} then do:
      message
        "Агент может быть только " {&cmp} " или " {&prs}
        view-as alert-box ERROR .
      return no-apply.
    end.
    run find-cli in this-procedure (input 3, input ub.clients.obj-type, input ub.clients.obj-code) .
  end.
  else do:
    assign agnt-name = ""  inn-agnt = ""  addres-agnt = ""  agnt-code = ?  agnt-type = ? .
    display agnt-name   agnt-code    agnt-type  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cli Dialog-Frame
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame /* 2 */
DO:
  run ref/cli-all.w (parParentProc, "b-sel", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> {&prs} and ub.clients.obj-type <> {&cmp} then do:
      message
        "Контрагент может быть только " {&cmp} " или " {&prs}
        view-as alert-box ERROR .
      return no-apply.
    end.
    run find-cli in this-procedure (input 1, input ub.clients.obj-type, input ub.clients.obj-code) .
  end.
  else do:
    assign cli-name = ""  inn-cli = ""  addres-cli = ""  cli-code = ?  cli-type  = ? .
    display cli-name    cli-code     cli-type   with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-curr Dialog-Frame
ON CHOOSE OF BUTTON-curr IN FRAME Dialog-Frame /* 1 */
DO:
  assign
  ref-rec = ?.
  run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
  if ref-rec = ? then return no-apply.
  find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
  assign
    curr-code = ub.currency.curr-code
    curr-name = ub.currency.curr-abbr
  .
  display curr-name curr-code with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-mngr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-mngr Dialog-Frame
ON CHOOSE OF BUTTON-mngr IN FRAME Dialog-Frame /* 3 */
DO:
  run ref/cli-all.w ( parParentProc, "b-sel", {&prs}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> {&prs}  then do:
      message
        "Исполнитель может быть только " {&prs}
        view-as alert-box ERROR .
      return no-apply.
    end.
    if available ub.clients then assign  mngr-name = ub.clients.obj-name   mngr-code = ub.clients.obj-code  .
    else                      assign  mngr-name = ""                 mngr-code = ? .
  end.
  else assign mngr-name = ""  mngr-code = ? .
  display mngr-name  mngr-code with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-posr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-posr Dialog-Frame
ON CHOOSE OF BUTTON-posr IN FRAME Dialog-Frame /* 2 */
DO:
  run ref/cli-all.w ( parParentProc, "b-sel", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first ub.clients no-lock where RECID(ub.clients) = int (agnt-list) no-error.
    if ub.clients.obj-type <> {&prs} and ub.clients.obj-type <> {&cmp} then do:
      message
        "Посредник может быть только " {&cmp} " или " {&prs}
        view-as alert-box ERROR .
      return no-apply.
    end.
    run find-cli in this-procedure (input 2, input ub.clients.obj-type, input ub.clients.obj-code) .
  end.
  else do:
    assign posr-name = ""  inn-posr = ""  addres-posr = ""  posr-code = ?  posr-type = ? .
    display posr-name   posr-code    posr-type  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON LEAVE OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  run find-cli in this-procedure (input 1, input cli-type, input cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON RETURN OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  run find-cli in this-procedure (input 1, input cli-type, input cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type Dialog-Frame
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
/*  if cli-code = int ( cli-code:screen-value ) then return.*/
  assign cli-type.
  run find-cli in this-procedure (input 1, input cli-type, input cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME COMBO-usl-opl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL COMBO-usl-opl Dialog-Frame
ON VALUE-CHANGED OF COMBO-usl-opl IN FRAME Dialog-Frame /* ФО */
DO:
  assign COMBO-usl-opl .
  assign srok-opl = 0 .
  if p-doc-type = {&income} then do: /* договор на покупку с поставщиками */
    if COMBO-usl-opl = {&contr-pay-fact-out-prc} then assign srok-opl:label = "> %" .
       else assign srok-opl:label = "Срок" .

    if   COMBO-usl-opl = {&contr-pay-fact-out-delay}
      or COMBO-usl-opl = {&contr-pay-fact-in-delay}
      or COMBO-usl-opl = {&contr-pay-fact-out-prc}
      or COMBO-usl-opl = {&contr-pay-rcv-delay}
      or COMBO-usl-opl = {&contr-pay-order-delay}
/*      or COMBO-usl-opl = {&contr-pay-fact-in-out-delay}*/
      or COMBO-usl-opl = {&contr-pay-spec-delay}
      then do:
        display srok-opl with frame {&frame-name}.
        enable srok-opl with frame {&frame-name}.
      end.
      else do:
        disable srok-opl with frame {&frame-name}.
      end.

  end.
  else do: /* договор с покупателем */
    if COMBO-usl-opl = {&contr-buyer-ord-prc} then assign srok-opl:label = "> %" .
       else assign srok-opl:label = "Срок" .

    if COMBO-usl-opl = {&contr-buyer-ord-prc} or COMBO-usl-opl:screen-value = {&contr-buyer-in-delay}
      then  do:
         display srok-opl with frame {&frame-name}.
         enable srok-opl with frame {&frame-name}.
      end.
      else do:
         disable srok-opl with frame {&frame-name}.
      end.
  end.
  display srok-opl with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME COMBO-usl-opl-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL COMBO-usl-opl-2 Dialog-Frame
ON VALUE-CHANGED OF COMBO-usl-opl-2 IN FRAME Dialog-Frame /* Счета-фактуры */
DO:
  assign COMBO-usl-opl-2 .
  assign srok-opl-2 = 0 .
  disable srok-opl-2 with frame {&frame-name}.
  display srok-opl-2 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL curr-code Dialog-Frame
ON LEAVE OF curr-code IN FRAME Dialog-Frame /* Валюта договора */
DO:
  assign curr-code .
  find first ub.currency where ub.currency.curr-code = curr-code no-error.
  if not available ub.currency then do:
    assign
    ref-rec = ?.
    run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
    if ref-rec = ? then return no-apply.
    find ub.currency where recid ( ub.currency ) = ref-rec.
  end.
  assign curr-name = ub.currency.curr-abbr .
  display curr-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL curr-code Dialog-Frame
ON RETURN OF curr-code IN FRAME Dialog-Frame /* Валюта договора */
DO:
  assign curr-code .
  find first ub.currency where ub.currency.curr-code = curr-code no-error.
  if not available ub.currency then do:
    assign
    ref-rec = ?.
    run ref/currency.w (input parparentproc, "b-sel", input-output ref-rec ).
    if ref-rec = ? then return no-apply.
    find ub.currency where recid ( ub.currency ) = ref-rec.
  end.
  assign curr-name = ub.currency.curr-abbr .
  display curr-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME kredit-limit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL kredit-limit Dialog-Frame
ON VALUE-CHANGED OF kredit-limit IN FRAME Dialog-Frame /* Ограничение кредита */
DO:
  assign kredit-limit .
  if kredit-limit = no  then  disable kredit-sum with frame {&frame-name}.
  else                        enable  kredit-sum with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mngr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mngr-code Dialog-Frame
ON LEAVE OF mngr-code IN FRAME Dialog-Frame
DO:
  assign mngr-code.
  find first ub.clients no-lock where ub.clients.obj-type = {&prs} and ub.clients.obj-code = mngr-code no-error.
  if not available ub.clients then do:
    if mngr-code = 0 then assign mngr-code = ? .
    if mngr-code = ? then do:
      assign  mngr-name = "" .
      display mngr-name with frame {&frame-name}.
    end.
    else apply "CHOOSE" to BUTTON-mngr IN FRAME Dialog-Frame .
  end.
  else do:
    assign  mngr-name = ub.clients.obj-name .
    display mngr-name with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mngr-code Dialog-Frame
ON RETURN OF mngr-code IN FRAME Dialog-Frame
DO:
  assign mngr-code.
  find first ub.clients no-lock where ub.clients.obj-type = {&prs} and ub.clients.obj-code = mngr-code no-error.
  if not available ub.clients then do:
    if mngr-code = 0 then assign mngr-code = ? .
    if mngr-code = ? then do:
      assign  mngr-name = "" .
      display mngr-name with frame {&frame-name}.
    end.
    else apply "CHOOSE" to BUTTON-mngr IN FRAME Dialog-Frame .
  end.
  else do:
    assign  mngr-name = ub.clients.obj-name .
    display mngr-name with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME posr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL posr-code Dialog-Frame
ON LEAVE OF posr-code IN FRAME Dialog-Frame
DO:
  if posr-code = int ( posr-code:screen-value ) then return.
  assign posr-code.
  run find-cli in this-procedure (input 2, input posr-type, input posr-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL posr-code Dialog-Frame
ON RETURN OF posr-code IN FRAME Dialog-Frame
DO:
  if posr-code = int ( posr-code:screen-value ) then return.
  assign posr-code.
  run find-cli in this-procedure (input 2, input posr-type, input posr-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME posr-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL posr-type Dialog-Frame
ON LEAVE OF posr-type IN FRAME Dialog-Frame
DO:
  assign posr-type.
  run find-cli in this-procedure (input 2, input posr-type, input posr-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-1 .
  find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.fin-code = a-code-an-uchet [RADIO-SET-1] and ub.fin-code-an-uchet.host-code = p-host-code no-error .
  if available ub.fin-code-an-uchet then  assign an-uchet = ub.fin-code-an-uchet.code-value + "  " + ub.fin-code-an-uchet.descr  .
  else assign an-uchet = "" .

  find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.fin-code  = a-code-cel-nazn [RADIO-SET-1] and ub.fin-code-cel-nazn.host-code = p-host-code no-error .
  if available ub.fin-code-cel-nazn then assign cel-nazn = ub.fin-code-cel-nazn.code-value + "  " + ub.fin-code-cel-nazn.descr .
  else assign cel-nazn = "" .

  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc  then assign cor-acc = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr .
  else assign cor-acc = "" .

  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc-2 [RADIO-SET-1]and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc  then assign   cor-acc-2 = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr .
  else assign cor-acc-2 = "" .
  display cor-acc-2 cor-acc cel-nazn an-uchet with frame {&frame-name}.

  if RADIO-SET-1 > 2 then ENABLE  b-cor-acc-2 WITH FRAME Dialog-Frame.
  else  DISABLE  b-cor-acc-2 WITH FRAME Dialog-Frame.
/*  VIEW FRAME Dialog-Frame.*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-diadoc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-diadoc Dialog-Frame
ON VALUE-CHANGED OF T-diadoc IN FRAME Dialog-Frame /* Поставки через Диадок */
DO:
  
  assign t-diadoc .
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-edi Dialog-Frame
ON VALUE-CHANGED OF T-edi IN FRAME Dialog-Frame /* Поставки через ЭДО */
DO:
  
  assign t-edi .
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-edi-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-edi-order Dialog-Frame
ON VALUE-CHANGED OF T-edi-order IN FRAME Dialog-Frame /* Электронные заказы EDI */
DO:
  
  assign T-edi-order .
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
  { gbl/app_help.i }
  { gbl/ed_date.i contract-date }
  { gbl/ed_date.i contract-date-beg }
  { gbl/ed_date.i contract-date-end }

next-prev = yes.
n-p: do while next-prev :

/* Снимаем глобальные настройки fo-mc-mode  */
RUN adm/shattri.p (
      INPUT  "get":U,
      INPUT  "",            /* тип объекта  */
      INPUT  0,             /* код объекта  */
      INPUT  "fin-global",  /* название секции   */
      INPUT  "fo-mc-mode",  /* название параметра   */
      OUTPUT v-Character,
      OUTPUT v-Date,
      OUTPUT v-Decimal,
      OUTPUT v-iMcMode,     /* Здесь возвращается параметр fo-mc-mode 0 - старая схема  */
      OUTPUT v-Logical,
      OUTPUT v-Param-Type,
      INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   MESSAGE
      "Ошибка определения глобалоного параметра fin-global/fo-mc-mode" SKIP
      PROGRAM-NAME(1) ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE
      VIEW-AS ALERT-BOX.
END.


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if p-doc-type begins "contract-type" then
      assign
        p-contr-type = entry(2,p-doc-type,"=")
        p-doc-type   = {&income}
      .
  run enable_ui in this-procedure .
  run go-proc in this-procedure no-error.
  if error-status:error then return no-apply.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-proc Dialog-Frame 
PROCEDURE create-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable  p-sys-date     as date      no-undo .
  define variable  p-sys-time     as character no-undo .
  define variable  p-sys-time-int as integer   no-undo .
  define variable  f-code         as integer   no-undo .
  define variable is-dup as logical no-undo .
  DEFINE VARIABLE v-cError AS CHARACTER NO-UNDO INITIAL "". 
  DEFINE VARIABLE lChoice AS LOGICAL NO-UNDO INITIAL FALSE. 

  if contract-date-beg <> ? and contract-date-end <> ? then do:
    if contract-date-beg > contract-date-end then do:
      message "Дата начала действия позже даты окончания действия!" view-as alert-box ERROR.
      return error.
    end.
  end.
  if (COMBO-usl-opl = {&contr-pay-fact-out-prc} or COMBO-usl-opl = {&contr-buyer-ord-prc} ) and srok-opl = 0 then do:
    message "Процент реализации не может быть 0 !" view-as alert-box ERROR.
    return error.
  end.
  if (COMBO-usl-opl = {&contr-pay-fact-out-prc} or COMBO-usl-opl = {&contr-buyer-ord-prc} ) and srok-opl > 100 then do:
    message "Процент реализации не может быть > 100 !" view-as alert-box ERROR.
    return error.
  end.

  if ( COMBO-usl-opl = {&contr-pay-fact-out-delay}
    or COMBO-usl-opl = {&contr-pay-fact-in-delay}
    or COMBO-usl-opl = {&contr-pay-rcv-delay}
    or COMBO-usl-opl = {&contr-buyer-in-delay}
    or COMBO-usl-opl = {&contr-pay-order-delay}
/*    or COMBO-usl-opl = {&contr-pay-fact-in-out-delay}*/
    or COMBO-usl-opl = {&contr-pay-spec-delay} )
    and srok-opl = 0 then do:
      message "Срок отсрочки не может быть 0 !" view-as alert-box ERROR.
      return error.
  end.
  
  if COMBO-return-type > 0
  then do :
    find first trn-reason no-lock where trn-reason.reason-code = COMBO-return-type no-error .
    if not available trn-reason
    then do :
      message "Указанная схема возврата в системе отсутствует. Для выбора данной схемы в договоре необходимо в справочник оснований добавить основание с кодом " string(COMBO-return-type) view-as alert-box ERROR.
      return error .
    end .
  end .

  if ref-mode = {&add-def} then do:
    if p-doc-type <>  {&income} and  p-doc-type <> {&expense} then do:
      message "Невозможно добавить договор неизвестного вида" view-as alert-box ERROR.
      return error.
    end.
    if cli-code = 0 or cli-code = ? then do:
      message "Не задан контрагент" view-as alert-box ERROR.
      apply "CHOOSE" to cli-code in frame Dialog-Frame .
      return error.
    end.
    /*добавлены проверки по типу договора ответств. хранения */
    if COMBO-type-contr = {&contr-resp-store} then do:
      if    COMBO-usl-opl <> {&contr-pay-nodef}
        and COMBO-usl-opl <> {&contr-pay-fact-out}
        and COMBO-usl-opl <> {&contr-pay-fact-out-delay} then do:
        message
        "Условия генерации для договора ответственного хранения " skip
        "допустимы только <По факту реализации>," skip
        "<Отсрочка платежа (по реализации)> и <Не определено>"
        view-as alert-box error .
        apply "CHOOSE" to COMBO-usl-opl in frame Dialog-Frame .
        return error .
      end.
    end.

    /*добавлены проверки по типу договора между членами ТПСИ - NVB*/
    if COMBO-type-contr = {&contr-tpsi} then do:
      /*договор может быть только между своими фирмам*/
      if cli-type <> {&cmp} or not can-find(first ub.sysconf no-lock where ub.sysconf.host-code = cli-code) then do:
        message
        "Нельзя оформить договор типа <Продажа через ТПСИ>" skip
        "на контрагента, не являющегося СВОЕЙ ФИРМОЙ"
        view-as alert-box error .
        apply "CHOOSE" to cli-code in frame Dialog-Frame .
        return error .
      end.
      /*договор может быть только один*/
      if can-find(first ub.contract no-lock where
                       ub.contract.host-code = p-host-code
                   AND ub.contract.cli-type = cli-type
                   AND ub.contract.cli-code = cli-code
                   and ub.contract.contract-type = {&contr-tpsi}
                   and ub.contract.status_       = {&current-contr}
                   ) then do:
        message
        "Нельзя оформить договор типа <Продажа через ТПСИ>," skip
        "уже есть действующий договор этого типа с фирмой" cli-code
        view-as alert-box error .
        apply "CHOOSE" to cli-code in frame Dialog-Frame .
        return error .
      end.
    end.

    find first ub.contract no-lock
      where ub.contract.contract-date     = contract-date
        and ub.contract.contract-prn-code = contract-prn-code
        and ub.contract.cli-type          = cli-type
        and ub.contract.cli-code          = cli-code
        and ub.contract.host-code         = p-host-code
    no-error .
    if available ub.contract then do:
      message substitute ("Уже есть договор № &1 от &2 с контрагентом &3 ! Продолжать &4 договора?" ,
             contract-prn-code ,
             string(contract-date,"99/99/9999"),
             cli-name ,
             ref-mode )
             view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-dup .
      if is-dup = no then return error.
    end.

    run gen-b-code in this-procedure ( input {&gbl-ct-code}, output f-code) no-error .
    if error-status:error then do:
      message "Ошибка при генерации внутреннего № договора" view-as alert-box ERROR.
      return error.
    end.

    create b_contract .
    ri = recid(b_contract).
    { gbl/curdburt.i  b_contract.user-db-num   b_contract.user-name   p-sys-date   p-sys-time   p-sys-time-int  }
    assign
      b_contract.doc-type      = p-doc-type
      b_contract.contract-code = f-code
      b_contract.host-code     = p-host-code
      b_contract.contract-type = COMBO-type-contr
      b_contract.status_       = {&current-contr}
      b_contract.curr-code     = curr-code
      b_contract.own-name      = own-name
      b_contract.cli-type      = cli-type
      b_contract.cli-code      = cli-code
      b_contract.cli-name      = cli-name
      b_contract.db-num        = b_contract.user-db-num
    .
  end.
  else do:
    find first b_contract exclusive-lock where recid(b_contract) = ri no-error .

    if ref-mode = {&update} then do:
      find first ub.contract no-lock
        where ub.contract.contract-date     = contract-date
          and ub.contract.contract-prn-code = contract-prn-code
          and ub.contract.cli-type          = cli-type
          and ub.contract.cli-code          = cli-code
          and ub.contract.host-code         = p-host-code
          and ub.contract.contract-code     <> b_contract.contract-code
      no-error .
      if available ub.contract then do:
         message substitute ("Уже есть договор № &1 от &2 с контрагентом &3 ! Продолжать &4 договора ?" ,
                  contract-prn-code ,
                  string(contract-date,"99/99/9999"),
                  cli-name ,
                  ref-mode )
                view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-dup .
        if is-dup = no then return error.
      end.
    end.
  end.
  /*  */
  { gbl/curdburt.i
    b_contract.user-db-num
    b_contract.user-name
    p-sys-date
    p-sys-time
    p-sys-time-int
  }
  /*  */



/*
  Убрали в тригер contrw.p 
  define buffer buf_c-contract for ub.c-contract.
  create buf_c-contract .
  BUFFER-COPY b_contract TO buf_c-contract .

  { gbl/curdburt.i  b_contract.user-db-num   b_contract.user-name   p-sys-date   p-sys-time   p-sys-time-int  }

  assign
    buf_c-contract.chip-num         = next-value (s-corr-chip, {&db-name_schema})
    buf_c-contract.corr-user-db-num = b_contract.user-db-num
    buf_c-contract.corr-user-name   = b_contract.user-name
    buf_c-contract.corr-date        = p-sys-date
    buf_c-contract.corr-time        = p-sys-time-int
  .
*/  

  

  if v-own-code-schet-2  = ? or v-own-code-schet-2  = 0 then assign v-own-code-schet-2  = v-own-code-schet  .
  if v-cli-code-schet-2  = ? or v-cli-code-schet-2  = 0 then assign v-cli-code-schet-2  = v-cli-code-schet  .
  if v-posr-code-schet-2 = ? or v-posr-code-schet-2 = 0 then assign v-posr-code-schet-2 = v-posr-code-schet .
  if v-agnt-code-schet-2 = ? or v-agnt-code-schet-2 = 0 then assign v-agnt-code-schet-2 = v-agnt-code-schet .

  assign fin-VAT-pc mngr-code .

  define variable ii as integer   no-undo .
  do ii = 1 to 6 :
    if a-code-an-uchet  [ii] = ? then  a-code-an-uchet  [ii] = 0 .
    if a-code-cel-nazn  [ii] = ? then  a-code-cel-nazn  [ii] = 0 .
    if a-code-cor-acc   [ii] = ? then  a-code-cor-acc   [ii] = 0 .
    if a-code-cor-acc-2 [ii] = ? then  a-code-cor-acc-2 [ii] = 0 .
  end.

  case b-nal :
    when 1 then assign b_contract.pay-nal = no .
    when 2 then assign b_contract.pay-nal = yes .
    when 3 then assign b_contract.pay-nal = ? .
  end.

  case COMBO-usl-opl-2 :
    when {&contr-chf-nodef}     then assign  b_contract.gen-factur = 0 .
    when {&contr-chf-in}        then assign  b_contract.gen-factur = 1 .
    when {&contr-chf-fo}        then assign  b_contract.gen-factur = 2 .
    when {&contr-chf-pay}       then assign  b_contract.gen-factur = 3 .
    when {&contr-chf-type}       then assign  b_contract.gen-factur = 4 .
    when {&contr-chf-out}        then assign  b_contract.gen-factur = 5 .
  end.
  assign b_contract.gen-factur-srok = srok-opl-2 .
  if COMBO-auto-pay-2:screen-value = "факт" and b_contract.gen-factur <> 0 then assign b_contract.gen-factur = b_contract.gen-factur + 100 .

  assign kredit-sum .

  assign
    b_contract.cli-name          = cli-name

    b_contract.str-uslov-oplat   = str-uslov-oplat
    b_contract.usl-opl           = COMBO-usl-opl
    b_contract.srok-opl          = srok-opl
    b_contract.contract-date     = contract-date
    b_contract.contract-name     = contract-name
    b_contract.contract-prn-code = contract-prn-code
    b_contract.contract-city     = contract-city
    b_contract.contract-date-beg = contract-date-beg
    b_contract.contract-date-end = contract-date-end

    b_contract.transport-cli-type  = v-transport-cli-type
    b_contract.transport-cli-code  = v-transport-cli-code
    b_contract.transport-host      = v-transport-host
    b_contract.transport-contract  = v-transport-contract
    b_contract.transport-uslov     = v-transport-uslov
    b_contract.transport-value     = v-transport-value
    b_contract.transport-type      = v-transport-type

    b_contract.kredit-sum        = kredit-sum
    b_contract.kredit-limit      = kredit-limit

    b_contract.posr-type         = posr-type
    b_contract.posr-code         = posr-code
    b_contract.posr-name         = posr-name
    b_contract.agnt-type         = agnt-type
    b_contract.agnt-code         = agnt-code
    b_contract.agnt-name         = agnt-name
    b_contract.mngr-code         = mngr-code

    b_contract.own-name          = own-name
    b_contract.own-sign-post     = sign-post-own
    b_contract.own-sign          = sign-own
    b_contract.own-addres        = addres-own
    b_contract.own-inn           = inn-own
    b_contract.own-kpp           = kpp-own
    b_contract.cli-sign-post     = sign-post-cli
    b_contract.cli-sign          = sign-cli
    b_contract.cli-addres        = addres-cli
    b_contract.cli-inn           = inn-cli
    b_contract.cli-kpp           = kpp-cli
    b_contract.posr-sign-post    = sign-post-posr
    b_contract.posr-sign         = sign-posr
    b_contract.posr-addres       = addres-posr
    b_contract.posr-inn          = inn-posr
    b_contract.posr-kpp          = kpp-posr
    b_contract.agnt-sign-post    = sign-post-agnt
    b_contract.agnt-sign         = sign-agnt
    b_contract.agnt-addres       = addres-agnt
    b_contract.agnt-inn          = inn-agnt
    b_contract.agnt-kpp          = kpp-agnt

    b_contract.own-code-schet        = v-own-code-schet-2
    b_contract.cli-code-schet        = v-cli-code-schet-2
    b_contract.posr-code-schet       = v-posr-code-schet-2
    b_contract.agnt-code-schet       = v-agnt-code-schet-2
    b_contract.own-code-schet-start  = v-own-code-schet
    b_contract.cli-code-schet-start  = v-cli-code-schet
    b_contract.posr-code-schet-start = v-posr-code-schet
    b_contract.agnt-code-schet-start = v-agnt-code-schet

    b_contract.own-point-code        = v-own-point-code
    b_contract.own-point-db-num      = v-own-point-db-num
    b_contract.agnt-point-code       = v-agnt-point-code
    b_contract.agnt-point-db-num     = v-agnt-point-db-num
    b_contract.cli-point-code        = v-cli-point-code
    b_contract.cli-point-db-num      = v-cli-point-db-num
    b_contract.posr-point-code       = v-posr-point-code
    b_contract.posr-point-db-num     = v-posr-point-db-num

    b_contract.spec-check      = COMBO-return-type
    b_contract.fin-VAT-pc      = fin-VAT-pc
    b_contract.own-bank-name  = ""
    b_contract.own-bik        = ""
    b_contract.own-r-schet    = ""
    b_contract.own-c-schet    = ""
    b_contract.cli-bank-name  = ""
    b_contract.cli-bik        = ""
    b_contract.cli-r-schet    = ""
    b_contract.cli-c-schet    = ""
    b_contract.posr-bank-name = ""
    b_contract.posr-bik       = ""
    b_contract.posr-r-schet   = ""
    b_contract.posr-c-schet   = ""
    b_contract.agnt-bank-name = ""
    b_contract.agnt-bik       = ""
    b_contract.agnt-r-schet   = ""
    b_contract.agnt-c-schet   = ""
    b_contract.an-uchet-code-out        = a-code-an-uchet  [1]
    b_contract.cel-nazn-code-out        = a-code-cel-nazn  [1]
    b_contract.cor-acc-out              = a-code-cor-acc   [1]
    b_contract.cor-acc1-out             = a-code-cor-acc-2 [1]
    b_contract.an-uchet-code-in         = a-code-an-uchet  [2]
    b_contract.cel-nazn-code-in         = a-code-cel-nazn  [2]
    b_contract.cor-acc-in               = a-code-cor-acc   [2]
    b_contract.cor-acc1-in              = a-code-cor-acc-2 [2]
    b_contract.an-uchet-code-out-cash   = a-code-an-uchet  [3]
    b_contract.cel-nazn-code-out-cash   = a-code-cel-nazn  [3]
    b_contract.cor-acc-out-cash         = a-code-cor-acc   [3]
    b_contract.cor-acc1-out-cash        = a-code-cor-acc-2 [3]
    b_contract.an-uchet-code-in-cash    = a-code-an-uchet  [4]
    b_contract.cel-nazn-code-in-cash    = a-code-cel-nazn  [4]
    b_contract.cor-acc-in-cash          = a-code-cor-acc   [4]
    b_contract.cor-acc1-in-cash         = a-code-cor-acc-2 [4]
    b_contract.an-uchet-code-out-payoff = a-code-an-uchet  [5]
    b_contract.cel-nazn-code-out-payoff = a-code-cel-nazn  [5]
    b_contract.cor-acc-out-payoff       = a-code-cor-acc   [5]
    b_contract.cor-acc1-out-payoff      = a-code-cor-acc-2 [5]
    b_contract.an-uchet-code-in-payoff  = a-code-an-uchet  [6]
    b_contract.cel-nazn-code-in-payoff  = a-code-cel-nazn  [6]
    b_contract.cor-acc-in-payoff        = a-code-cor-acc   [6]
    b_contract.cor-acc1-in-payoff       = a-code-cor-acc-2 [6]
  .
  if b_contract.usl-opl = {&contr-pay-spec} or b_contract.usl-opl = {&contr-pay-spec-delay}  then do:
    assign b_contract.need-fo = 1 .
  end.

  if v-own-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-own-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.own-bank-name = ub.fin-bank.bank-name
        b_contract.own-bik       = ub.fin-bank.bik
        b_contract.own-r-schet   = ub.fin-schet.r-schet
        b_contract.own-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  if v-cli-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-cli-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.cli-bank-name = ub.fin-bank.bank-name
        b_contract.cli-bik       = ub.fin-bank.bik
        b_contract.cli-r-schet   = ub.fin-schet.r-schet
        b_contract.cli-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  if v-posr-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-posr-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.posr-bank-name = ub.fin-bank.bank-name
        b_contract.posr-bik       = ub.fin-bank.bik
        b_contract.posr-r-schet   = ub.fin-schet.r-schet
        b_contract.posr-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.
  if v-agnt-code-schet <> ? then do:
    find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = v-agnt-code-schet no-error .
    if available ub.fin-schet then do:
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      assign
        b_contract.agnt-bank-name = ub.fin-bank.bank-name
        b_contract.agnt-bik       = ub.fin-bank.bik
        b_contract.agnt-r-schet   = ub.fin-schet.r-schet
        b_contract.agnt-c-schet   = ub.fin-schet.c-schet
      .
    end.
  end.

  case COMBO-auto-pay:screen-value :
    when "фин.об. авто" then b_contract.auto-pay = 0 .
    when "фин.об. факт" then b_contract.auto-pay = 1 .
    when "платеж новый" then b_contract.auto-pay = 2 .
    when "платеж разр"  then b_contract.auto-pay = 3 .
    when "платеж факт"  then b_contract.auto-pay = 4 .
  end.

  find first buf_contract-attr exclusive-lock where buf_contract-attr.contract-code = b_contract.contract-code
  and buf_contract-attr.host-code = b_contract.host-code and buf_contract-attr.attr-code = "contract-edi" no-error .
  if available (buf_contract-attr) then buf_contract-attr.attr-value = string(T-edi) .
  else do:
    create buf_contract-attr .
    assign
    buf_contract-attr.host-code = b_contract.host-code
    buf_contract-attr.contract-code = b_contract.contract-code
    buf_contract-attr.attr-code = "contract-edi"
    buf_contract-attr.attr-value = string (T-edi)
    .
  end.  

  find first buf_contract-attr exclusive-lock where buf_contract-attr.contract-code = b_contract.contract-code
  and buf_contract-attr.host-code = b_contract.host-code and buf_contract-attr.attr-code = "contract-diadoc" no-error .
  if available (buf_contract-attr) then buf_contract-attr.attr-value = string(T-diadoc) .
  else do:
    create buf_contract-attr .
    assign
    buf_contract-attr.host-code = b_contract.host-code
    buf_contract-attr.contract-code = b_contract.contract-code
    buf_contract-attr.attr-code = "contract-diadoc"
    buf_contract-attr.attr-value = string (T-diadoc)
    .
  end.
  
  /* Если производится модификация мастер договора - модифицируем все подчиненные договора  */
  IF ref-mode = {&update} AND Is-MS-Contract-Int (BUFFER b_Contract) = 1
     THEN DO:
     /* */ 
     MESSAGE
     "Распространить изменение шапки мастер договора на " SKIP 
     "подчиненные договора ?"
     VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
     UPDATE lChoice.
     IF lChoice = TRUE THEN DO:
        /* */ 
        RUN Modify-Slave-Contract in THIS-PROCEDURE(
            BUFFER b_Contract,
            OUTPUT v-cError
            ).
        /*  */
        IF v-cError <> "" THEN DO:
           MESSAGE
              v-cError
              VIEW-AS ALERT-BOX INFO BUTTONS OK.
           RETURN ERROR v-cError.
        END.
     END.
  END. 
  /* */  
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
  DISPLAY T-edi T-diadoc T-edi-order contract-prn-code contract-date 
          contract-city contract-name contract-date-beg contract-date-end 
          curr-code COMBO-return-type COMBO-type-contr cli-code cli-type 
          posr-code posr-type agnt-code agnt-type mngr-code COMBO-usl-opl 
          srok-opl COMBO-auto-pay COMBO-usl-opl-2 srok-opl-2 COMBO-auto-pay-2 
          kredit-limit kredit-sum balance-fo str-uslov-oplat fin-VAT-pc 
          RADIO-SET-1 b-nal cor-acc an-uchet cel-nazn cor-acc-2 contract-code 
          curr-name own-code own-name cli-name posr-name agnt-name mngr-name 
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit b-spec B-transport b-hist B-Help RECT-8 RECT-9 T-edi 
         T-diadoc T-edi-order contract-prn-code contract-date contract-city 
         contract-name BUTTON-curr contract-date-beg contract-date-end 
         curr-code COMBO-return-type COMBO-type-contr b-bank-own b-bank-cli 
         cli-code cli-type BUTTON-cli b-bank-posr posr-code posr-type 
         BUTTON-posr b-bank-agnt agnt-code agnt-type BUTTON-agnt mngr-code 
         BUTTON-mngr COMBO-usl-opl srok-opl COMBO-auto-pay COMBO-usl-opl-2 
         srok-opl-2 COMBO-auto-pay-2 kredit-limit kredit-sum balance-fo 
         str-uslov-oplat fin-VAT-pc RADIO-SET-1 b-nal b-cor-acc b-an-uchet 
         b-cel-nazn b-cor-acc-2 contract-code own-code 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-cli Dialog-Frame 
PROCEDURE find-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-type     as integer   no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define variable str  as character initial "" no-undo .
  define variable str1 as character initial "" no-undo .
  define variable str2 as character initial "" no-undo .
  define variable str3 as character initial "" no-undo .

  if p-obj-type <> {&cmp} and p-obj-type <> {&prs} then do:
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = p-obj-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = p-obj-type and buf_clients.obj-code = p-obj-code no-error.

  if not available buf_clients then do:
    if p-obj-code = 0 then assign p-obj-code = ? .
    if p-obj-code = ? then do:
      case p-type :
        when 1 then do:
          assign cli-name = "" kpp-cli = "" inn-cli = ""  addres-cli = ""  cli-code = ?  cli-type  = ? .
          display cli-name    cli-code     cli-type   with frame {&frame-name}.
        end.
        when 2 then do:
          assign posr-name = "" kpp-posr = ""  inn-posr = ""  addres-posr = ""  posr-code = ?  posr-type = ? .
          display posr-name   posr-code    posr-type  with frame {&frame-name}.
        end.
        when 3 then do:
          assign agnt-name = "" kpp-agnt = ""  inn-agnt = ""  addres-agnt = ""  agnt-code = ?  agnt-type = ? .
          display agnt-name   agnt-code    agnt-type  with frame {&frame-name}.
        end.
      end case.
    end.
    else do:
      case p-type :
        when 1 then apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
        when 2 then apply "CHOOSE" to BUTTON-posr IN FRAME Dialog-Frame .
        when 3 then apply "CHOOSE" to BUTTON-agnt IN FRAME Dialog-Frame .
      end case.
    end.
    return.
  end.

  if buf_clients.obj-type = {&cmp} then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then assign str1 = buf_firm.inn   str2 = buf_firm.addres1  str3 = buf_firm.kpp .
  end.
  else do:
    find first ub.person no-lock where ub.person.psn-code = buf_clients.obj-code no-error.
    if available ub.person then assign  str2 = ub.person.address   str3 = ub.person.kpp .
  end.

  case p-type :
    when 1 then do:
      assign cli-name  = buf_clients.obj-name kpp-cli = str3   inn-cli  = str1  addres-cli  = str2  cli-code  = p-obj-code  cli-type  = buf_clients.obj-type.
      display cli-name    cli-code     cli-type   with frame {&frame-name}.
    end.
    when 2 then do:
      assign posr-name = buf_clients.obj-name  kpp-posr = str3  inn-posr = str1  addres-posr = str2  posr-code = p-obj-code  posr-type = buf_clients.obj-type.
      display posr-name   posr-code    posr-type  with frame {&frame-name}.
    end.
    when 3 then do:
      assign agnt-name = buf_clients.obj-name  kpp-agnt = str3 inn-agnt = str1  addres-agnt = str2  agnt-code = p-obj-code  agnt-type = buf_clients.obj-type.
      display agnt-name   agnt-code    agnt-type  with frame {&frame-name}.
    end.
  end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE go-proc Dialog-Frame 
PROCEDURE go-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
on stop undo, return error
:
define variable par-type as character no-undo .
define variable v-is-add as character no-undo .
    { gbl/conf-rd.i
      "'is-addch':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-add
      par-type
      no-error
    }

  enable COMBO-type-contr with frame {&frame-name}.
  if v-is-add = 'yes' then COMBO-type-contr:list-items = {&contract-type-list} .
                      else COMBO-type-contr:list-items = {&contract-type-list-short} .
  COMBO-auto-pay:list-items = "фин.об. авто" + "," + "фин.об. факт" + "," + "платеж новый" /* + "," + "платеж разр" + "," + "платеж факт"*/ .
  COMBO-auto-pay-2:list-items = "новый" + "," + "факт" .

  if p-doc-type = {&income} then do: /* договор на покупку */
/*    COMBO-usl-opl:list-items = '{&bef-contr-pay-nodef},{&bef-contr-pay-order},{&bef-contr-pay-rcv},{&bef-contr-pay-order-delay},{&bef-contr-pay-rcv-delay},{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-in-delay},{&bef-contr-pay-fact-out-delay},{&bef-contr-pay-fact-out-prc},{&bef-contr-pay-fact-in-out},{&bef-contr-pay-fact-in-out-delay},{&bef-contr-pay-spec},{&bef-contr-pay-spec-delay}':U.*/
    COMBO-usl-opl:list-items = '{&bef-contr-pay-nodef},{&bef-contr-pay-order},{&bef-contr-pay-rcv},{&bef-contr-pay-order-delay},{&bef-contr-pay-rcv-delay},{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-in-delay},{&bef-contr-pay-fact-out-delay},{&bef-contr-pay-fact-out-prc},{&bef-contr-pay-spec},{&bef-contr-pay-spec-delay}':U.
    COMBO-usl-opl-2:list-items   = {&contr-chf-nodef} + ","  + {&contr-chf-in} + ","  + {&contr-chf-fo} + ","  + {&contr-chf-pay} + ","  + {&contr-chf-type}  .
  end.
  else do:
    COMBO-usl-opl:list-items = '{&bef-contr-pay-nodef},{&bef-contr-buyer-ord},{&bef-contr-buyer-ord-prc},{&bef-contr-buyer-in},{&bef-contr-buyer-in-delay}':U .
    COMBO-usl-opl-2:list-items   = {&contr-chf-nodef} + ","  + {&contr-chf-out} + ","  + {&contr-chf-fo} + ","  + {&contr-chf-pay} .
  end.
  
  if p-doc-type = {&income}
  then do :
    enable COMBO-return-type WITH FRAME Dialog-Frame.
  end .
  else do :
    hide COMBO-return-type in FRAME Dialog-Frame.
  end .

  case ref-mode :
    when {&add-def} then do:
      /* читаем настройки фирмы по умолчанию */
      define buffer buf_sysconf for ub.sysconf .
      find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code .

      disable srok-opl-2 with frame {&frame-name}.

      B-spec:visible = no .

      assign
        a-code-an-uchet  [1] = buf_sysconf.an-uchet-code-out
        a-code-cel-nazn  [1] = buf_sysconf.cel-nazn-code-out
        a-code-cor-acc   [1] = buf_sysconf.cor-acc-out
        a-code-cor-acc-2 [1] = buf_sysconf.cor-acc1-out
        a-code-an-uchet  [2] = buf_sysconf.an-uchet-code-in
        a-code-cel-nazn  [2] = buf_sysconf.cel-nazn-code-in
        a-code-cor-acc   [2] = buf_sysconf.cor-acc-in
        a-code-cor-acc-2 [2] = buf_sysconf.cor-acc1-in
        a-code-an-uchet  [3] = buf_sysconf.an-uchet-code-out-cash
        a-code-cel-nazn  [3] = buf_sysconf.cel-nazn-code-out-cash
        a-code-cor-acc   [3] = buf_sysconf.cor-acc-out-cash
        a-code-cor-acc-2 [3] = buf_sysconf.cor-acc1-out-cash
        a-code-an-uchet  [4] = buf_sysconf.an-uchet-code-in-cash
        a-code-cel-nazn  [4] = buf_sysconf.cel-nazn-code-in-cash
        a-code-cor-acc   [4] = buf_sysconf.cor-acc-in-cash
        a-code-cor-acc-2 [4] = buf_sysconf.cor-acc1-in-cash
        a-code-an-uchet  [5] = buf_sysconf.an-uchet-code-out-payoff
        a-code-cel-nazn  [5] = buf_sysconf.cel-nazn-code-out-payoff
        a-code-cor-acc   [5] = buf_sysconf.cor-acc-out-payoff
        a-code-cor-acc-2 [5] = buf_sysconf.cor-acc1-out-payoff
        a-code-an-uchet  [6] = buf_sysconf.an-uchet-code-in-payoff
        a-code-cel-nazn  [6] = buf_sysconf.cel-nazn-code-in-payoff
        a-code-cor-acc   [6] = buf_sysconf.cor-acc-in-payoff
        a-code-cor-acc-2 [6] = buf_sysconf.cor-acc1-in-payoff
        v-transport-cli-type = buf_sysconf.transport-cli-type
        v-transport-cli-code = buf_sysconf.transport-cli-code
        v-transport-host     = buf_sysconf.transport-host
        v-transport-contract = buf_sysconf.transport-contract
        v-transport-uslov    = buf_sysconf.transport-uslov
        v-transport-value    = buf_sysconf.transport-value
      .
      if buf_sysconf.pay-code-schet-rubl > 0 then assign v-own-code-schet = buf_sysconf.pay-code-schet-rubl .

      find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = p-host-code no-error .
      assign
        own-name = buf_clients.obj-name
        own-code = p-host-code
      .
      find first buf_firm no-lock where buf_firm.firm-code = p-host-code no-error .
      assign
        kpp-own           = buf_firm.kpp
        inn-own           = buf_firm.inn
        addres-own        = buf_firm.addres1
        contract-city     = buf_sysconf.contract-city
        sign-post-own     = buf_sysconf.pay-sign-post
        sign-own          = buf_sysconf.pay-sign
        contract-date     = today
        contract-date-beg = today
        fin-VAT-pc        = buf_sysconf.fin-VAT-pc
        srok-opl = buf_sysconf.srok-opl
        srok-opl-2 = buf_sysconf.srok-opl-sf
      .

      if buf_sysconf.usl-opl-sf <> "" and   buf_sysconf.usl-opl-sf <> ? then do:
        if lookup ( buf_sysconf.usl-opl-sf, COMBO-usl-opl-2:list-items) = 0 then COMBO-usl-opl-2:screen-value    = {&contr-pay-nodef} .
        else COMBO-usl-opl-2:screen-value =  buf_sysconf.usl-opl-sf .
      end.
      else COMBO-usl-opl-2:screen-value    = {&contr-pay-nodef} .
      case buf_sysconf.auto-pay-sf :
        when 0 then COMBO-auto-pay-2:screen-value = "новый" .
        when 1 then COMBO-auto-pay-2:screen-value = "факт" .
      end.

      if buf_sysconf.contract-type <> "" and buf_sysconf.contract-type <> ?  and buf_sysconf.contract-type <> "Не задан" then do:
        COMBO-type-contr:screen-value = buf_sysconf.contract-type .
      end.
      else COMBO-type-contr:screen-value = {&contr-buy-sale} .

      if buf_sysconf.usl-opl <> "" and   buf_sysconf.usl-opl <> ? then do:
        if lookup ( buf_sysconf.usl-opl, COMBO-usl-opl:list-items) = 0 then COMBO-usl-opl:screen-value    = {&contr-pay-nodef} .
        else COMBO-usl-opl:screen-value =  buf_sysconf.usl-opl .
      end.
      else COMBO-usl-opl:screen-value    = {&contr-pay-nodef} .

      case buf_sysconf.auto-pay :
        when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
        when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
        when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
        when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
        when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
      end.

      if   COMBO-usl-opl:screen-value = {&contr-pay-nodef}
        or COMBO-usl-opl:screen-value = {&contr-buyer-ord}
        or COMBO-usl-opl:screen-value = {&contr-buyer-in}
        or COMBO-usl-opl:screen-value = {&contr-pay-fact-in}
        or COMBO-usl-opl:screen-value = {&contr-pay-fact-out}  then  disable srok-opl with frame {&frame-name}.

      disable b-hist b-cor-acc-2 with frame {&frame-name}.
      if p-contr-type <> "" then do:
         COMBO-type-contr:screen-value = p-contr-type.
         disable COMBO-type-contr with frame {&frame-name} .
      end.
    end.
    when {&update} or when {&lookup} then do:
      find first b_contract no-lock where recid(b_contract) = ri .
      COMBO-type-contr:screen-value = b_contract.contract-type .
      COMBO-usl-opl:screen-value =  b_contract.usl-opl .
      COMBO-return-type = b_contract.spec-check .
      display COMBO-return-type WITH FRAME Dialog-Frame.

      if b_contract.gen-factur > 100 then assign COMBO-auto-pay-2:screen-value = "факт" .
      else                                assign COMBO-auto-pay-2:screen-value = "новый" .
      case b_contract.gen-factur :
        when 0 then               assign COMBO-usl-opl-2:screen-value = {&contr-chf-nodef} .
        when 1  or when 101 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-in} .
        /*when 11 or when 111 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-in-delay} .*/
        when 2  or when 102 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-fo} .
        /*when 12 or when 112 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-fo-delay} .    */
        when 3  or when 103 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-pay} .
        /*when 13 or when 113 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-pay-delay} .    */
        when 4  or when 104 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-type} .
        /*when 14 or when 114 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-type-delay} . */
        when 5  or when 105 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-out} .
        /*when 15 or when 115 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-out-delay} .*/
      end.
      assign srok-opl-2 = b_contract.gen-factur-srok .

      if b_contract.gen-factur < 10 or b_contract.gen-factur > 10 and b_contract.gen-factur < 110 then  disable srok-opl-2 with frame {&frame-name}.
      if   b_contract.usl-opl = {&contr-pay-fact-out-delay}
        or b_contract.usl-opl = {&contr-pay-fact-in-delay}
        or b_contract.usl-opl = {&contr-buyer-ord-prc}
        or b_contract.usl-opl = {&contr-buyer-in-delay}
        or b_contract.usl-opl = {&contr-pay-fact-out-prc}
        or b_contract.usl-opl = {&contr-pay-rcv-delay}
        or b_contract.usl-opl = {&contr-pay-order-delay}
        or b_contract.usl-opl = {&contr-pay-spec-delay}
      then do:
        assign srok-opl = b_contract.srok-opl .
        if b_contract.usl-opl = {&contr-pay-fact-out-prc} or b_contract.usl-opl = {&contr-buyer-ord-prc} then assign srok-opl:label = "> %" .
      end.

      case b_contract.pay-nal :
        when no then  assign b-nal = 1 .
        when yes then assign b-nal = 2 .
        when ? then   assign b-nal = 3 .
      end.
      assign
        contract-code     = b_contract.contract-code
        contract-prn-code = b_contract.contract-prn-code
        contract-date     = b_contract.contract-date
        contract-city     = b_contract.contract-city
        contract-name     = b_contract.contract-name
        contract-date-beg = b_contract.contract-date-beg
        contract-date-end = b_contract.contract-date-end
        curr-code         = b_contract.curr-code
        own-code          = b_contract.host-code
        cli-code          = b_contract.cli-code
        cli-type          = b_contract.cli-type
        agnt-code         = b_contract.agnt-code
        agnt-type         = b_contract.agnt-type
        posr-code         = b_contract.posr-code
        posr-type         = b_contract.posr-type

        v-own-point-code      = b_contract.own-point-code
        v-own-point-db-num    = b_contract.own-point-db-num
        v-agnt-point-code     = b_contract.agnt-point-code
        v-agnt-point-db-num   = b_contract.agnt-point-db-num
        v-cli-point-code      = b_contract.cli-point-code
        v-cli-point-db-num    = b_contract.cli-point-db-num
        v-posr-point-code     = b_contract.posr-point-code
        v-posr-point-db-num   = b_contract.posr-point-db-num

        kredit-sum    = b_contract.kredit-sum
        kredit-limit  = b_contract.kredit-limit.
        if p-doc-type = {&income} then balance-fo    = b_contract.balance-fo-rubl + b_contract.balance-plat-rubl.
        else balance-fo    = b_contract.balance-fo-rubl - b_contract.balance-plat-rubl.
assign 
        own-name      = b_contract.own-name
        inn-own       = b_contract.own-inn
        kpp-own       = b_contract.own-kpp
        addres-own    = b_contract.own-addres
        sign-own      = b_contract.own-sign
        sign-post-own = b_contract.own-sign-post

        v-own-code-schet    = b_contract.own-code-schet-start
        v-cli-code-schet    = b_contract.cli-code-schet-start
        v-posr-code-schet   = b_contract.posr-code-schet-start
        v-agnt-code-schet   = b_contract.agnt-code-schet-start
        v-own-code-schet-2  = b_contract.own-code-schet
        v-cli-code-schet-2  = b_contract.cli-code-schet
        v-posr-code-schet-2 = b_contract.posr-code-schet
        v-agnt-code-schet-2 = b_contract.agnt-code-schet

        cli-name      = b_contract.cli-name
        addres-cli    = b_contract.cli-addres
        inn-cli       = b_contract.cli-inn
        kpp-cli       = b_contract.cli-kpp
        sign-cli      = b_contract.cli-sign
        sign-post-cli = b_contract.cli-sign-post

        posr-name      = b_contract.posr-name
        addres-posr    = b_contract.posr-addres
        inn-posr       = b_contract.posr-inn
        kpp-posr       = b_contract.posr-kpp
        sign-posr      = b_contract.posr-sign
        sign-post-posr = b_contract.posr-sign-post

        agnt-name      = b_contract.agnt-name
        addres-agnt    = b_contract.agnt-addres
        inn-agnt       = b_contract.agnt-inn
        kpp-agnt       = b_contract.agnt-kpp
        sign-agnt      = b_contract.agnt-sign
        sign-post-agnt = b_contract.agnt-sign-post

/*        fin-SLT-pc     = b_contract.fin-SLT-pc*/
        fin-VAT-pc     = b_contract.fin-VAT-pc

        mngr-code       = b_contract.mngr-code
        str-uslov-oplat = b_contract.str-uslov-oplat

        v-transport-cli-type = b_contract.transport-cli-type
        v-transport-cli-code = b_contract.transport-cli-code
        v-transport-host     = b_contract.transport-host
        v-transport-contract = b_contract.transport-contract
        v-transport-uslov    = b_contract.transport-uslov
        v-transport-value    = b_contract.transport-value
        v-transport-type    = b_contract.transport-type

        a-code-an-uchet  [1] = b_contract.an-uchet-code-out
        a-code-cel-nazn  [1] = b_contract.cel-nazn-code-out
        a-code-cor-acc   [1] = b_contract.cor-acc-out
        a-code-cor-acc-2 [1] = b_contract.cor-acc1-out
        a-code-an-uchet  [2] = b_contract.an-uchet-code-in
        a-code-cel-nazn  [2] = b_contract.cel-nazn-code-in
        a-code-cor-acc   [2] = b_contract.cor-acc-in
        a-code-cor-acc-2 [2] = b_contract.cor-acc1-in
        a-code-an-uchet  [3] = b_contract.an-uchet-code-out-cash
        a-code-cel-nazn  [3] = b_contract.cel-nazn-code-out-cash
        a-code-cor-acc   [3] = b_contract.cor-acc-out-cash
        a-code-cor-acc-2 [3] = b_contract.cor-acc1-out-cash
        a-code-an-uchet  [4] = b_contract.an-uchet-code-in-cash
        a-code-cel-nazn  [4] = b_contract.cel-nazn-code-in-cash
        a-code-cor-acc   [4] = b_contract.cor-acc-in-cash
        a-code-cor-acc-2 [4] = b_contract.cor-acc1-in-cash
        a-code-an-uchet  [5] = b_contract.an-uchet-code-out-payoff
        a-code-cel-nazn  [5] = b_contract.cel-nazn-code-out-payoff
        a-code-cor-acc   [5] = b_contract.cor-acc-out-payoff
        a-code-cor-acc-2 [5] = b_contract.cor-acc1-out-payoff
        a-code-an-uchet  [6] = b_contract.an-uchet-code-in-payoff
        a-code-cel-nazn  [6] = b_contract.cel-nazn-code-in-payoff
        a-code-cor-acc   [6] = b_contract.cor-acc-in-payoff
        a-code-cor-acc-2 [6] = b_contract.cor-acc1-in-payoff
      .

 /*     if COMBO-usl-opl:screen-value <> {&contr-pay-nodef}  then disable COMBO-usl-opl with frame {&frame-name}. */
 /*     if COMBO-usl-opl-2:screen-value <> {&contr-chf-nodef}  then disable COMBO-usl-opl-2 with frame {&frame-name}. */
      if   COMBO-usl-opl:screen-value = {&contr-pay-nodef}
        /*or COMBO-usl-opl:screen-value = {&contr-buyer-ord}*/
        or COMBO-usl-opl:screen-value = {&contr-buyer-in}
        or COMBO-usl-opl:screen-value = {&contr-pay-fact-in}
        or COMBO-usl-opl:screen-value = {&contr-pay-fact-out}  then  disable srok-opl with frame {&frame-name}.

      disable COMBO-type-contr curr-code BUTTON-curr cli-code cli-type srok-opl-2 BUTTON-cli b-cor-acc-2 with frame {&frame-name}.
      case b_contract.auto-pay :
        when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
        when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
        when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
        when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
        when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
      end.

      for first buf_contract-attr no-lock where buf_contract-attr.host-code = b_contract.host-code and
      buf_contract-attr.contract-code = b_contract.contract-code and buf_contract-attr.attr-code = "contract-edi":
        T-edi = logical (buf_contract-attr.attr-value) .
      end.
      display t-edi with frame {&frame-name} .

      for first buf_contract-attr no-lock where buf_contract-attr.host-code = b_contract.host-code and
      buf_contract-attr.contract-code = b_contract.contract-code and buf_contract-attr.attr-code = "contract-edi_orders":
        T-edi-order = logical (buf_contract-attr.attr-value) .
      end.
      display t-edi-order with frame {&frame-name} .
            
      for first buf_contract-attr no-lock where buf_contract-attr.host-code = b_contract.host-code and
      buf_contract-attr.contract-code = b_contract.contract-code and buf_contract-attr.attr-code = "contract-diadoc":
        T-diadoc = logical (buf_contract-attr.attr-value) .
      end.
      display t-diadoc with frame {&frame-name} .
      
      if ref-mode = {&lookup} then do:

        disable contract-prn-code contract-date contract-city contract-name contract-date-beg contract-date-end  fin-VAT-pc b-nal
          agnt-code agnt-type BUTTON-agnt BUTTON-mngr posr-code posr-type BUTTON-posr  mngr-code  b-cor-acc b-cor-acc-2 b-an-uchet
          b-cel-nazn COMBO-usl-opl COMBO-usl-opl-2 str-uslov-oplat COMBO-auto-pay COMBO-auto-pay-2 RADIO-SET-1 kredit-sum contract-code kredit-limit
          srok-opl T-edi COMBO-return-type

        with frame {&frame-name}.
        b-OK:label in frame {&frame-name} = "&Выход" .
        b-exit:visible = no .
      end.
      /* Для update и lookup подключаем кнопку Доп.инфо */
      if p-doc-type = {&expense} THEN DO:
         ASSIGN
            b-Add-Inf:VISIBLE   = TRUE
            b-Add-Inf:SENSITIVE = TRUE
            .
      END.

    end.
    when "history" then do:
      find first buf_c-contract no-lock where recid(buf_c-contract) = ri .

      COMBO-type-contr:screen-value = buf_c-contract.contract-type .
      COMBO-usl-opl:list-items = {&contr-usl-opl-list} .
      COMBO-usl-opl:screen-value =  buf_c-contract.usl-opl .

      B-spec:visible = no .

      if   buf_c-contract.usl-opl = {&contr-pay-fact-out-delay}
        or buf_c-contract.usl-opl = {&contr-pay-fact-in-delay}
        or buf_c-contract.usl-opl = {&contr-buyer-ord-prc}
        or buf_c-contract.usl-opl = {&contr-buyer-in-delay}
        or buf_c-contract.usl-opl = {&contr-pay-fact-out-prc}
        or buf_c-contract.usl-opl = {&contr-pay-rcv-delay}
        or buf_c-contract.usl-opl = {&contr-pay-order-delay}
        or buf_c-contract.usl-opl = {&contr-pay-spec-delay}
        then do:
        assign srok-opl = buf_c-contract.srok-opl .
        if buf_c-contract.usl-opl = {&contr-pay-fact-out-prc} or buf_c-contract.usl-opl = {&contr-buyer-ord-prc} then assign srok-opl:label = "> %" .
      end.
      if buf_c-contract.gen-factur > 100 then assign COMBO-auto-pay-2:screen-value = "факт" .
      else                                    assign COMBO-auto-pay-2:screen-value = "новый" .
      case buf_c-contract.gen-factur :
        when 0 then               assign COMBO-usl-opl-2:screen-value = {&contr-chf-nodef} .
        when 1  or when 101 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-in} .
        when 2  or when 102 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-fo} .
        when 3  or when 103 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-pay} .
        when 4  or when 104 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-type} .
        when 5  or when 105 then  assign COMBO-usl-opl-2:screen-value = {&contr-chf-out} .
      end.
      assign srok-opl-2 = buf_c-contract.gen-factur-srok .


      case buf_c-contract.pay-nal :
        when no then  assign b-nal = 1 .
        when yes then assign b-nal = 2 .
        when ? then   assign b-nal = 3 .
      end.
      assign
        contract-code     = buf_c-contract.contract-code
        contract-prn-code = buf_c-contract.contract-prn-code
        contract-date     = buf_c-contract.contract-date
        contract-city     = buf_c-contract.contract-city
        contract-name     = buf_c-contract.contract-name
        contract-date-beg = buf_c-contract.contract-date-beg
        contract-date-end = buf_c-contract.contract-date-end
        curr-code         = buf_c-contract.curr-code
        own-code          = buf_c-contract.host-code
        cli-code          = buf_c-contract.cli-code
        cli-type          = buf_c-contract.cli-type
        agnt-code         = buf_c-contract.agnt-code
        agnt-type         = buf_c-contract.agnt-type
        posr-code         = buf_c-contract.posr-code
        posr-type         = buf_c-contract.posr-type
        kredit-sum        = buf_c-contract.kredit-sum
        kredit-limit      = buf_c-contract.kredit-limit
        balance-fo        = buf_c-contract.balance-fo-rubl - buf_c-contract.balance-plat-rubl

        v-own-point-code      = buf_c-contract.own-point-code
        v-own-point-db-num    = buf_c-contract.own-point-db-num
        v-agnt-point-code     = buf_c-contract.agnt-point-code
        v-agnt-point-db-num   = buf_c-contract.agnt-point-db-num
        v-cli-point-code      = buf_c-contract.cli-point-code
        v-cli-point-db-num    = buf_c-contract.cli-point-db-num
        v-posr-point-code     = buf_c-contract.posr-point-code
        v-posr-point-db-num   = buf_c-contract.posr-point-db-num

        own-name      = buf_c-contract.own-name
        inn-own       = buf_c-contract.own-inn
        kpp-own       = buf_c-contract.own-kpp
        addres-own    = buf_c-contract.own-addres
        sign-own      = buf_c-contract.own-sign
        sign-post-own = buf_c-contract.own-sign-post

        v-own-code-schet    = buf_c-contract.own-code-schet-start
        v-cli-code-schet    = buf_c-contract.cli-code-schet-start
        v-posr-code-schet   = buf_c-contract.posr-code-schet-start
        v-agnt-code-schet   = buf_c-contract.agnt-code-schet-start
        v-own-code-schet-2  = buf_c-contract.own-code-schet
        v-cli-code-schet-2  = buf_c-contract.cli-code-schet
        v-posr-code-schet-2 = buf_c-contract.posr-code-schet
        v-agnt-code-schet-2 = buf_c-contract.agnt-code-schet

        cli-name      = buf_c-contract.cli-name
        addres-cli    = buf_c-contract.cli-addres
        inn-cli       = buf_c-contract.cli-inn
        kpp-cli       = buf_c-contract.cli-kpp
        sign-cli      = buf_c-contract.cli-sign
        sign-post-cli = buf_c-contract.cli-sign-post

        posr-name      = buf_c-contract.posr-name
        addres-posr    = buf_c-contract.posr-addres
        inn-posr       = buf_c-contract.posr-inn
        kpp-posr       = buf_c-contract.posr-kpp
        sign-posr      = buf_c-contract.posr-sign
        sign-post-posr = buf_c-contract.posr-sign-post

        agnt-name      = buf_c-contract.agnt-name
        addres-agnt    = buf_c-contract.agnt-addres
        inn-agnt       = buf_c-contract.agnt-inn
        kpp-agnt       = buf_c-contract.agnt-kpp
        sign-agnt      = buf_c-contract.agnt-sign
        sign-post-agnt = buf_c-contract.agnt-sign-post

        v-transport-cli-type = buf_c-contract.transport-cli-type
        v-transport-cli-code = buf_c-contract.transport-cli-code
        v-transport-host     = buf_c-contract.transport-host
        v-transport-contract = buf_c-contract.transport-contract
        v-transport-uslov    = buf_c-contract.transport-uslov
        v-transport-value    = buf_c-contract.transport-value
        v-transport-type     = buf_c-contract.transport-type

/*        fin-SLT-pc     = b_contract.fin-SLT-pc*/
        fin-VAT-pc     = buf_c-contract.fin-VAT-pc

        mngr-code       = buf_c-contract.mngr-code
        str-uslov-oplat = buf_c-contract.str-uslov-oplat

        a-code-an-uchet  [1] = buf_c-contract.an-uchet-code-out
        a-code-cel-nazn  [1] = buf_c-contract.cel-nazn-code-out
        a-code-cor-acc   [1] = buf_c-contract.cor-acc-out
        a-code-cor-acc-2 [1] = buf_c-contract.cor-acc1-out
        a-code-an-uchet  [2] = buf_c-contract.an-uchet-code-in
        a-code-cel-nazn  [2] = buf_c-contract.cel-nazn-code-in
        a-code-cor-acc   [2] = buf_c-contract.cor-acc-in
        a-code-cor-acc-2 [2] = buf_c-contract.cor-acc1-in
        a-code-an-uchet  [3] = buf_c-contract.an-uchet-code-out-cash
        a-code-cel-nazn  [3] = buf_c-contract.cel-nazn-code-out-cash
        a-code-cor-acc   [3] = buf_c-contract.cor-acc-out-cash
        a-code-cor-acc-2 [3] = buf_c-contract.cor-acc1-out-cash
        a-code-an-uchet  [4] = buf_c-contract.an-uchet-code-in-cash
        a-code-cel-nazn  [4] = buf_c-contract.cel-nazn-code-in-cash
        a-code-cor-acc   [4] = buf_c-contract.cor-acc-in-cash
        a-code-cor-acc-2 [4] = buf_c-contract.cor-acc1-in-cash
        a-code-an-uchet  [5] = buf_c-contract.an-uchet-code-out-payoff
        a-code-cel-nazn  [5] = buf_c-contract.cel-nazn-code-out-payoff
        a-code-cor-acc   [5] = buf_c-contract.cor-acc-out-payoff
        a-code-cor-acc-2 [5] = buf_c-contract.cor-acc1-out-payoff
        a-code-an-uchet  [6] = buf_c-contract.an-uchet-code-in-payoff
        a-code-cel-nazn  [6] = buf_c-contract.cel-nazn-code-in-payoff
        a-code-cor-acc   [6] = buf_c-contract.cor-acc-in-payoff
        a-code-cor-acc-2 [6] = buf_c-contract.cor-acc1-in-payoff
      .
      disable b-hist COMBO-type-contr curr-code BUTTON-curr cli-code cli-type srok-opl BUTTON-cli b-cor-acc-2  contract-prn-code
        contract-date contract-city contract-name contract-date-beg contract-date-end  fin-VAT-pc b-nal srok-opl-2
        agnt-code agnt-type BUTTON-agnt BUTTON-mngr posr-code posr-type BUTTON-posr  mngr-code  b-cor-acc b-cor-acc-2 b-an-uchet
        b-cel-nazn COMBO-usl-opl COMBO-usl-opl-2 str-uslov-oplat COMBO-auto-pay RADIO-SET-1 COMBO-auto-pay-2 kredit-sum contract-code kredit-limit
      with frame {&frame-name}.
      b-OK:label in frame {&frame-name} = "&Выход" .
      b-exit:visible = no .
      case buf_c-contract.auto-pay :
        when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
        when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
        when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
        when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
        when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
      end.
    end.
  end.

  find first ub.fin-code-an-uchet no-lock where ub.fin-code-an-uchet.fin-code = a-code-an-uchet [1] and ub.fin-code-an-uchet.host-code = p-host-code no-error .
  if available ub.fin-code-an-uchet then  assign an-uchet = ub.fin-code-an-uchet.code-value + "  " + ub.fin-code-an-uchet.descr .

  find first ub.fin-code-cel-nazn no-lock where ub.fin-code-cel-nazn.fin-code  = a-code-cel-nazn [1] and ub.fin-code-cel-nazn.host-code = p-host-code no-error .
  if available ub.fin-code-cel-nazn then assign cel-nazn = ub.fin-code-cel-nazn.code-value + "  " + ub.fin-code-cel-nazn.descr .

  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc [1] and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc then assign cor-acc = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr  .

  find first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.fin-code  = a-code-cor-acc-2 [1] and ub.fin-code-cor-acc.host-code = p-host-code no-error .
  if available ub.fin-code-cor-acc then assign cor-acc-2 = ub.fin-code-cor-acc.code-value + "  " + ub.fin-code-cor-acc.descr  .

  display {&DISPLAYED-OBJECTS} with frame {&frame-name}.
  if mngr-code <> 0 and mngr-code <> ? then apply "LEAVE"  to mngr-code  IN FRAME Dialog-Frame .
  apply "entry"  to contract-prn-code IN FRAME Dialog-Frame .
  apply "LEAVE"  to curr-code  IN FRAME Dialog-Frame .
  apply "VALUE-CHANGED"  to b-nal IN FRAME Dialog-Frame .


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE step-next Dialog-Frame 
PROCEDURE step-next :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do on error undo, return error return-value :
    if valid-handle (br-handle) then do:
      g-log = br-handle:select-next-row() no-error .
      if error-status :error then do:
        message "Это режим просмотра одного документа." .
        g-log = false .
      end.
      if not g-log then message "Это последний документ списка.".
    end.

    ri = recid ( buf_contract ).
    next-prev = yes.
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE step-prev Dialog-Frame 
PROCEDURE step-prev :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

if valid-handle (br-handle) then do:
  g-log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g-log = false .
  end.
  if not g-log then do: message "Это первый документ списка.".   end.
end.
ri = recid (buf_contract).
next-prev = yes .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

