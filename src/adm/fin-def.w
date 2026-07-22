&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_sysconf FOR ub.sysconf.
DEFINE TEMP-TABLE tt-sysconf NO-UNDO LIKE ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки записей финблока по умолчанию

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-mode      as character no-undo .
define input  parameter p-host-code    as integer   no-undo .
define input  parameter is-fin   as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Настройки записей финблока по умолчанию" .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i DEF }

/* Local Variable Definitions ---                                       */
define variable p-code-an-uchet as integer   no-undo .
define variable p-code-cel-nazn as integer   no-undo .
define variable p-code-cor-acc  as integer   no-undo .
define variable p-code-cor-acc-2  as integer   no-undo .
define variable a-code-an-uchet as integer extent 6  no-undo .
define variable a-code-cel-nazn as integer extent 6  no-undo .
define variable a-code-cor-acc  as integer extent 6  no-undo .
define variable a-code-cor-acc-2  as integer extent 6  no-undo .
define variable p-bank          as integer   no-undo .
define variable p-schet         as integer   no-undo .
define variable p-bank1         as integer   no-undo .
define variable p-schet1        as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-sysconf

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-sysconf.contract-type ~
tt-sysconf.contract-city tt-sysconf.usl-opl tt-sysconf.srok-opl ~
tt-sysconf.usl-opl-sf tt-sysconf.srok-opl-sf tt-sysconf.pay-sign-post ~
tt-sysconf.pay-sign tt-sysconf.is-an-uchet tt-sysconf.is-code-cel-nazn ~
tt-sysconf.is-corr-acc tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc ~
tt-sysconf.fin-calc
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-sysconf.contract-type tt-sysconf.contract-city tt-sysconf.usl-opl ~
tt-sysconf.srok-opl tt-sysconf.usl-opl-sf tt-sysconf.srok-opl-sf ~
tt-sysconf.pay-sign-post tt-sysconf.pay-sign tt-sysconf.is-an-uchet ~
tt-sysconf.is-code-cel-nazn tt-sysconf.is-corr-acc tt-sysconf.is-cassa-acc ~
tt-sysconf.fin-VAT-pc tt-sysconf.fin-calc
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-sysconf
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-sysconf
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-sysconf SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-sysconf SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-sysconf
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-sysconf


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-sysconf.contract-type ~
tt-sysconf.contract-city tt-sysconf.usl-opl tt-sysconf.srok-opl ~
tt-sysconf.usl-opl-sf tt-sysconf.srok-opl-sf tt-sysconf.pay-sign-post ~
tt-sysconf.pay-sign tt-sysconf.is-an-uchet tt-sysconf.is-code-cel-nazn ~
tt-sysconf.is-corr-acc tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc ~
tt-sysconf.fin-calc
&Scoped-define ENABLED-TABLES tt-sysconf
&Scoped-define FIRST-ENABLED-TABLE tt-sysconf
&Scoped-Define ENABLED-OBJECTS b-exit B-quit b-help RECT-2 RECT-4 RECT-6 ~
RECT-5 RECT-7 COMBO-auto-pay COMBO-auto-pay-2 RADIO-SET-1 b-cor-acc ~
b-an-uchet b-cel-nazn b-cor-acc-2 b-bank-rub Is-fin-copy COMBO-fin-firm
&Scoped-Define DISPLAYED-FIELDS tt-sysconf.contract-type ~
tt-sysconf.contract-city tt-sysconf.usl-opl tt-sysconf.srok-opl ~
tt-sysconf.usl-opl-sf tt-sysconf.srok-opl-sf tt-sysconf.pay-sign-post ~
tt-sysconf.pay-sign tt-sysconf.is-an-uchet tt-sysconf.is-code-cel-nazn ~
tt-sysconf.is-corr-acc tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc ~
tt-sysconf.fin-calc
&Scoped-define DISPLAYED-TABLES tt-sysconf
&Scoped-define FIRST-DISPLAYED-TABLE tt-sysconf
&Scoped-Define DISPLAYED-OBJECTS COMBO-auto-pay COMBO-auto-pay-2 ~
RADIO-SET-1 Is-fin-copy COMBO-fin-firm cor-acc-name an-uchet-name ~
cel-nazn-name cor-acc-2-name bank-schet bank-bik bank-rub

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-an-uchet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.

DEFINE BUTTON b-bank-rub
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.

DEFINE BUTTON b-cel-nazn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.

DEFINE BUTTON b-cor-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.

DEFINE BUTTON b-cor-acc-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE COMBO-auto-pay AS CHARACTER FORMAT "X(256)":U
     LABEL "стат."
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16.3 BY 1 NO-UNDO.

DEFINE VARIABLE COMBO-auto-pay-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "стат."
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16.3 BY 1 NO-UNDO.

DEFINE VARIABLE COMBO-fin-firm AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 31.8 BY 1 NO-UNDO.

DEFINE VARIABLE an-uchet-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Код аналитического учета"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.

DEFINE VARIABLE bank-bik AS CHARACTER FORMAT "X(256)":U
     LABEL "БИК"
      VIEW-AS TEXT
     SIZE 26.9 BY .93 NO-UNDO.

DEFINE VARIABLE bank-rub AS CHARACTER FORMAT "X(256)":U
     LABEL "Банк"
      VIEW-AS TEXT
     SIZE 60.5 BY .93 NO-UNDO.

DEFINE VARIABLE bank-schet AS CHARACTER FORMAT "X(256)":U
     LABEL "Р/С"
      VIEW-AS TEXT
     SIZE 35.5 BY .93 NO-UNDO.

DEFINE VARIABLE cel-nazn-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Код целевого назначения"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.

DEFINE VARIABLE cor-acc-2-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Корресп. счет (касса)"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.

DEFINE VARIABLE cor-acc-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Корреспондирующий счет"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "РПП", 1,
"ППП", 2,
"РКО", 3,
"ПКО", 4,
"Рс.АПЗ", 5,
"Пр.АПЗ", 6
     SIZE 12 BY 4.2 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93.5 BY 11.47.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 5.07.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.9 BY 9.1.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 1.37.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.5 BY 1.37.

DEFINE VARIABLE Is-fin-copy AS LOGICAL INITIAL no
     LABEL "Копировать настройки из фирмы:"
     VIEW-AS TOGGLE-BOX
     SIZE 33.8 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-sysconf SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 95
     tt-sysconf.contract-type AT ROW 2 COL 6 COLON-ALIGNED
          LABEL "Тип" FORMAT "X(256)"
          VIEW-AS COMBO-BOX INNER-LINES 6
          DROP-DOWN-LIST
          SIZE 22.8 BY 1
     tt-sysconf.contract-city AT ROW 2 COL 36.6 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 44.4 BY 1
     tt-sysconf.usl-opl AT ROW 3 COL 18.1 COLON-ALIGNED
          LABEL "Услов.генер. ФО" FORMAT "X(256)"
          VIEW-AS COMBO-BOX INNER-LINES 7
          DROP-DOWN-LIST
          SIZE 27.9 BY 1
     tt-sysconf.srok-opl AT ROW 3 COL 53 COLON-ALIGNED
          LABEL "Срок" FORMAT ">>9"
          VIEW-AS FILL-IN
          SIZE 4.4 BY 1
     COMBO-auto-pay AT ROW 3 COL 65 COLON-ALIGNED
     tt-sysconf.usl-opl-sf AT ROW 4 COL 18.1 COLON-ALIGNED WIDGET-ID 4
          LABEL "Услов. генер. СФ" FORMAT "X(256)"
          VIEW-AS COMBO-BOX INNER-LINES 7
          DROP-DOWN-LIST
          SIZE 27.9 BY 1
     tt-sysconf.srok-opl-sf AT ROW 4 COL 53 COLON-ALIGNED WIDGET-ID 6
          LABEL "Срок" FORMAT ">>9"
          VIEW-AS FILL-IN
          SIZE 4.4 BY 1
     COMBO-auto-pay-2 AT ROW 4 COL 65 COLON-ALIGNED WIDGET-ID 2
     tt-sysconf.pay-sign-post AT ROW 6 COL 11.8 COLON-ALIGNED
          LABEL "Должность" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 21.3 BY 1
     tt-sysconf.pay-sign AT ROW 6 COL 39.1 COLON-ALIGNED
          LABEL "ФИО" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 21.3 BY 1
     RADIO-SET-1 AT ROW 8 COL 4.5 NO-LABEL
     b-cor-acc AT ROW 8 COL 80.6
     b-an-uchet AT ROW 9 COL 80.6
     b-cel-nazn AT ROW 10 COL 80.6
     b-cor-acc-2 AT ROW 11 COL 80.6
     tt-sysconf.is-an-uchet AT ROW 14 COL 69.9 WIDGET-ID 12
          LABEL "Заполняется код ан. учета"
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     b-bank-rub AT ROW 14.7 COL 3.5
     tt-sysconf.is-code-cel-nazn AT ROW 15 COL 69.9 WIDGET-ID 16
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     tt-sysconf.is-corr-acc AT ROW 16 COL 69.9 WIDGET-ID 18
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     tt-sysconf.is-cassa-acc AT ROW 17 COL 69.9 WIDGET-ID 14
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     tt-sysconf.fin-VAT-pc AT ROW 17.73 COL 16.7 COLON-ALIGNED
          LABEL "НДС" FORMAT ">9.99%"
          VIEW-AS FILL-IN
          SIZE 7.8 BY 1
     tt-sysconf.fin-calc AT ROW 19 COL 69.9 NO-LABEL WIDGET-ID 8
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Учет документов по фирме", 0,
"Учет документов по объекту", 1
          SIZE 28.9 BY 1.5
     Is-fin-copy AT ROW 20.5 COL 1.5 WIDGET-ID 26
     COMBO-fin-firm AT ROW 20.5 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     cor-acc-name AT ROW 8 COL 41 COLON-ALIGNED
     an-uchet-name AT ROW 9 COL 41 COLON-ALIGNED
     cel-nazn-name AT ROW 10 COL 41 COLON-ALIGNED
     cor-acc-2-name AT ROW 11 COL 41 COLON-ALIGNED
     bank-schet AT ROW 13.67 COL 7 COLON-ALIGNED
     bank-bik AT ROW 14.6 COL 10.5 COLON-ALIGNED
     bank-rub AT ROW 15.7 COL 6 COLON-ALIGNED
     "Договоры" VIEW-AS TEXT
          SIZE 14.6 BY .67 AT ROW 1.27 COL 42
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Представитель фирмы (для подписания) :" VIEW-AS TEXT
          SIZE 41.4 BY .87 AT ROW 5 COL 3.1
     "Коды для док-ов" VIEW-AS TEXT
          SIZE 16.8 BY 1 AT ROW 7 COL 24.9
          FGCOLOR 4
     "Банковские счета" VIEW-AS TEXT
          SIZE 25.9 BY 1 AT ROW 12.57 COL 23.3
          FGCOLOR 4
     "Налоги:" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 17.53 COL 2.5
          FGCOLOR 4
     RECT-2 AT ROW 1 COL 1
     RECT-4 AT ROW 12.47 COL 1
     RECT-6 AT ROW 17.53 COL 1
     RECT-5 AT ROW 12.47 COL 69.1 WIDGET-ID 20
     RECT-7 AT ROW 20.2 COL 1 WIDGET-ID 28
     SPACE(30.79) SKIP(0.06)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Значения по умолчанию в блоке 'Взаиморасчеты' и для Финансовых документов"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_sysconf B "?" ? ub sysconf
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

/* SETTINGS FOR FILL-IN an-uchet-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN bank-bik IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN bank-rub IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN bank-schet IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cel-nazn-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.contract-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-sysconf.contract-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN cor-acc-2-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cor-acc-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.fin-VAT-pc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR TOGGLE-BOX tt-sysconf.is-an-uchet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-sysconf.pay-sign IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-sysconf.pay-sign-post IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-sysconf.srok-opl IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-sysconf.srok-opl-sf IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-sysconf.usl-opl IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-sysconf.usl-opl-sf IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-sysconf"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Значения по умолчанию в блоке 'Взаиморасчеты' */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-an-uchet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-an-uchet Dialog-Frame
ON CHOOSE OF b-an-uchet IN FRAME Dialog-Frame /* 2 */
DO:
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-an-uchet for ub.fin-code-An-uchet.

  assign p-rec = ? .
  if p-code-an-uchet <> ? then do:
    find first buf_fin-code-an-uchet no-lock where
              buf_fin-code-an-uchet.fin-code = p-code-an-uchet
          and buf_fin-code-an-uchet.host-code = p-host-code no-error .
    if available buf_fin-code-an-uchet then assign p-rec = recid (buf_fin-code-an-uchet) .
  end.

  run ref/fwcode-3.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input {&company}
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-an-uchet no-lock where
           RECID(buf_fin-code-an-uchet) = int (rid-list) no-error .
    if available buf_fin-code-an-uchet then do:
      assign
        an-uchet-name = buf_fin-code-an-uchet.code-value + "  " + buf_fin-code-an-uchet.descr
        p-code-an-uchet = buf_fin-code-an-uchet.fin-code
      .
      if buf_fin-code-an-uchet.status_ <> integer({&current-status-int}) then do:
        message
        "Вы выбрали удаленный код!"  view-as alert-box.
      end.
    end.
    else assign p-code-an-uchet = 0  an-uchet-name = "" .
  end.
  else assign p-code-an-uchet = 0  an-uchet-name = "" .
  display
  an-uchet-name
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank-rub
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank-rub Dialog-Frame
ON CHOOSE OF b-bank-rub IN FRAME Dialog-Frame /* 2 */
DO:
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
  define buffer buf_fin-schet for ub.fin-schet.
  define buffer buf_fin-bank for ub.fin-bank.
  if p-schet <> ? then do:
    find first buf_fin-schet no-lock where buf_fin-schet.code-schet = p-schet
           and buf_fin-schet.host-code = p-host-code no-error .
    if available buf_fin-schet then
    assign
    rid-list = string( recid (buf_fin-schet))
    v-status_ = buf_fin-schet.status_
    .
  end.

  run ref/finschts.w ( input parParentProc
                     , input p-host-code
                     , input "b-sel"
                     , input "cmp-host"
                     , input {&cmp}
                     , input p-host-code
                     , input 0
                     , input p-host-code
                     , input p-bank
                     , input-output v-status_
                     , input-output rid-list).

  if rid-list <> "" then do:
    find first buf_fin-schet no-lock where RECID(buf_fin-schet) = int (rid-list) no-error .
    if available buf_fin-schet then do:
      if buf_fin-schet.status_ = {&deleted-status} then do:
        message "Вы выбрали удаленный счет!"  view-as alert-box.
      end.
      assign
      bank-schet = buf_fin-schet.r-schet
      p-schet    = buf_fin-schet.code-schet
      p-bank     = buf_fin-schet.code-bank
      .
      find first buf_fin-bank no-lock where
                buf_fin-bank.code-bank = p-bank
            and buf_fin-bank.host-code = p-host-code  no-error .
        assign
        bank-bik = buf_fin-bank.bik
        bank-rub = buf_fin-bank.short-name
        .
    end.
  end.
  else assign  p-bank = ?    p-schet = ? .
  display
  bank-rub
  bank-bik
  bank-schet
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cel-nazn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cel-nazn Dialog-Frame
ON CHOOSE OF b-cel-nazn IN FRAME Dialog-Frame /* 2 */
DO:
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.

  assign p-rec = ? .
  if p-code-cel-nazn <> ? then do:
    find first buf_fin-code-cel-nazn no-lock where
              buf_fin-code-cel-nazn.fin-code = p-code-cel-nazn
         and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
    if available buf_fin-code-cel-nazn then assign p-rec = recid (buf_fin-code-cel-nazn) .
  end.

  run ref/fwcode-2.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input {&company}
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-cel-nazn no-lock where
              RECID(buf_fin-code-cel-nazn) = int (rid-list) no-error .
    if available buf_fin-code-cel-nazn then do:
      if buf_fin-code-cel-nazn.status_ <> integer({&current-status-int}) then DO:
        message
        "Вы выбрали удаленный код!"
        view-as alert-box.
      END.
      assign
      cel-nazn-name = buf_fin-code-cel-nazn.code-value + "  " + buf_fin-code-cel-nazn.descr
      p-code-cel-nazn = buf_fin-code-cel-nazn.fin-code
      .
    end.
    else assign p-code-cel-nazn = 0  cel-nazn-name = "" .
  end.
  else assign p-code-cel-nazn = 0  cel-nazn-name = "" .
  display
  cel-nazn-name
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cor-acc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cor-acc Dialog-Frame
ON CHOOSE OF b-cor-acc IN FRAME Dialog-Frame /* 2 */
DO:
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.

  assign p-rec = ? .
  if p-code-cor-acc <> ? then do:
    find first buf_fin-code-cor-acc no-lock where
              buf_fin-code-cor-acc.fin-code = p-code-cor-acc
          and buf_fin-code-cor-acc.host-code = p-host-code no-error .
    if available buf_fin-code-cor-acc then assign p-rec = recid (buf_fin-code-cor-acc) .
  end.

  run ref/fwcode-1.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input {&company}
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-cor-acc no-lock where
         RECID(buf_fin-code-cor-acc) = int (rid-list) no-error .
    if available buf_fin-code-cor-acc then do:
      if buf_fin-code-cor-acc.status_ <> integer({&current-status-int}) then do:
        message
        "Вы выбрали удаленный код!"
        view-as alert-box.
      end.
      assign
      cor-acc-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
      p-code-cor-acc = buf_fin-code-cor-acc.fin-code
      .
    end.
    else assign p-code-cor-acc = 0  cor-acc-name = "" .
  end.
  else assign p-code-cor-acc = 0  cor-acc-name = "" .
  display
  cor-acc-name
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cor-acc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cor-acc-2 Dialog-Frame
ON CHOOSE OF b-cor-acc-2 IN FRAME Dialog-Frame /* 2 */
DO:
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.

  assign p-rec = ? .
  if p-code-cor-acc-2 <> ? then do:
    find first buf_fin-code-cor-acc no-lock where
              buf_fin-code-cor-acc.fin-code = p-code-cor-acc-2
          and buf_fin-code-cor-acc.host-code = p-host-code no-error .
    if available buf_fin-code-cor-acc then assign p-rec = recid (buf_fin-code-cor-acc) .
  end.

  run ref/fwcode-1.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input {&company}
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-cor-acc no-lock where
             RECID(buf_fin-code-cor-acc) = int (rid-list) no-error .
    if available buf_fin-code-cor-acc then do:
      if buf_fin-code-cor-acc.status_ <> integer({&current-status-int}) then do:
        message
        "Вы выбрали удаленный код!"
        view-as alert-box.
      end.
      assign
      cor-acc-2-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
      p-code-cor-acc-2 = buf_fin-code-cor-acc.fin-code
      .
    end.
    else assign p-code-cor-acc-2 = 0  cor-acc-2-name = "" .
  end.
  else assign p-code-cor-acc-2 = 0  cor-acc-2-name = "" .
  display
  cor-acc-2-name
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  IF p-mode <> {&UPDATE} THEN RETURN NO-APPLY.
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
  assign
    a-code-an-uchet  [RADIO-SET-1] = p-code-an-uchet
    a-code-cel-nazn  [RADIO-SET-1] = p-code-cel-nazn
    a-code-cor-acc   [RADIO-SET-1] = p-code-cor-acc
    a-code-cor-acc-2 [RADIO-SET-1] = p-code-cor-acc-2
  .
  assign RADIO-SET-1 .
  assign
    p-code-an-uchet  = a-code-an-uchet  [RADIO-SET-1]
    p-code-cel-nazn  = a-code-cel-nazn  [RADIO-SET-1]
    p-code-cor-acc   = a-code-cor-acc   [RADIO-SET-1]
    p-code-cor-acc-2 = a-code-cor-acc-2 [RADIO-SET-1]
  .
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-code-an-uchet
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if available buf_fin-code-an-uchet then   do:
    assign
    an-uchet-name = buf_fin-code-an-uchet.code-value + "  " + buf_fin-code-an-uchet.descr  .
  end.
  else do:
    assign
    an-uchet-name = "" .
  end.

  find first buf_fin-code-cel-nazn no-lock where
            buf_fin-code-cel-nazn.fin-code  = p-code-cel-nazn
        and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if available buf_fin-code-cel-nazn then do:
    assign
    cel-nazn-name = buf_fin-code-cel-nazn.code-value + "  " + buf_fin-code-cel-nazn.descr .
  end.
  else do:
    assign
    cel-nazn-name = "" .
  end.

  find first buf_fin-code-cor-acc no-lock where
           buf_fin-code-cor-acc.fin-code  = p-code-cor-acc
       and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if available buf_fin-code-cor-acc  then do:
    assign
    cor-acc-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr .
  end.
  else do:
    assign
    cor-acc-name = "" .
  end.
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-code-cor-acc-2
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if available buf_fin-code-cor-acc  then do:
    assign
    cor-acc-2-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr .
  end.
  else do:
    assign
    cor-acc-2-name = "" .
  end.
  display
  cor-acc-2-name
  cor-acc-name
  cel-nazn-name
  an-uchet-name
  with frame {&frame-name}.

  if RADIO-SET-1 > 2 then do:
    ENABLE
    b-cor-acc-2
    WITH FRAME {&frame-name} .
   end.
  else do:
    DISABLE
    b-cor-acc-2
    WITH FRAME {&frame-name} .
  end.
/*  VIEW FRAME Dialog-Frame.*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.usl-opl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.usl-opl Dialog-Frame
ON VALUE-CHANGED OF tt-sysconf.usl-opl IN FRAME Dialog-Frame /* Услов.генер. ФО */
DO:
  assign tt-sysconf.usl-opl .
  if tt-sysconf.usl-opl = {&contr-pay-fact-out-delay}
  or tt-sysconf.usl-opl = {&contr-pay-fact-in-delay}
  or tt-sysconf.usl-opl = {&contr-pay-fact-out-prc}
  or tt-sysconf.usl-opl = {&contr-buyer-ord-prc} then enable tt-sysconf.srok-opl with frame {&frame-name}.
  else do:
    assign tt-sysconf.srok-opl = 0 .
    disable tt-sysconf.srok-opl with frame {&frame-name}.
  end.
  if tt-sysconf.usl-opl = {&contr-pay-fact-out-prc}
  or tt-sysconf.usl-opl = {&contr-buyer-ord-prc} then assign tt-sysconf.srok-opl:label = "> %" .
  else assign tt-sysconf.srok-opl:label = "Срок" .
  display
  tt-sysconf.srok-opl
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-sysconf.usl-opl-sf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-sysconf.usl-opl-sf Dialog-Frame
ON VALUE-CHANGED OF tt-sysconf.usl-opl-sf IN FRAME Dialog-Frame /* Услов. генер. СФ */
DO:
  assign
  tt-sysconf.usl-opl-sf
  tt-sysconf.srok-opl-sf = 0
  .
  disable
  tt-sysconf.srok-opl-sf
  with frame {&frame-name}.
  display
  tt-sysconf.srok-opl-sf
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
  { gbl/getcntxt.i get }
  if  p-mode <> {&update}
  and p-mode <> {&lookup}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box error .
    undo, return error.
  end.
  if p-mode <> {&lookup}
  then do:
    if v-cntxt-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять записи ФИРМЫ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-sysconf
  :
    delete tt-sysconf.
  end.
if p-mode = {&update}
then do:
  do transaction:
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
  end.
  end.
  else do:
    find first locked_sysconf no-lock
      where locked_sysconf.host-code = p-host-code .
  end.
  create tt-sysconf.
  buffer-copy Locked_sysconf to tt-sysconf.

  RUN fill-widgets IN THIS-PROCEDURE .
  RUN MyEnable IN this-procedure.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY COMBO-auto-pay COMBO-auto-pay-2 RADIO-SET-1 Is-fin-copy COMBO-fin-firm
          cor-acc-name an-uchet-name cel-nazn-name cor-acc-2-name bank-schet
          bank-bik bank-rub
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-sysconf THEN
    DISPLAY tt-sysconf.contract-type tt-sysconf.contract-city tt-sysconf.usl-opl
          tt-sysconf.srok-opl tt-sysconf.usl-opl-sf tt-sysconf.srok-opl-sf
          tt-sysconf.pay-sign-post tt-sysconf.pay-sign tt-sysconf.is-an-uchet
          tt-sysconf.is-code-cel-nazn tt-sysconf.is-corr-acc
          tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc tt-sysconf.fin-calc
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit b-help RECT-2 RECT-4 RECT-6 RECT-5 RECT-7
         tt-sysconf.contract-type tt-sysconf.contract-city tt-sysconf.usl-opl
         tt-sysconf.srok-opl COMBO-auto-pay tt-sysconf.usl-opl-sf
         tt-sysconf.srok-opl-sf COMBO-auto-pay-2 tt-sysconf.pay-sign-post
         tt-sysconf.pay-sign RADIO-SET-1 b-cor-acc b-an-uchet b-cel-nazn
         b-cor-acc-2 tt-sysconf.is-an-uchet b-bank-rub
         tt-sysconf.is-code-cel-nazn tt-sysconf.is-corr-acc
         tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc tt-sysconf.fin-calc
         Is-fin-copy COMBO-fin-firm
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
DEFINE BUFFER buf_fin-code-an-uchet FOR ub.fin-code-an-uchet.
DEFINE BUFFER buf_fin-code-cel-nazn FOR ub.fin-code-cel-nazn.
DEFINE BUFFER buf_fin-code-cor-acc FOR ub.fin-code-cor-acc.
DEFINE BUFFER buf_fin-schet FOR ub.fin-schet.
DEFINE BUFFER buf_fin-bank FOR ub.fin-bank.

assign
a-code-an-uchet  [2] = tt-sysconf.an-uchet-code-in
a-code-cel-nazn  [2] = tt-sysconf.cel-nazn-code-in
a-code-cor-acc   [2] = tt-sysconf.cor-acc-in
a-code-cor-acc-2 [2] = tt-sysconf.cor-acc1-in
a-code-an-uchet  [3] = tt-sysconf.an-uchet-code-out-cash
a-code-cel-nazn  [3] = tt-sysconf.cel-nazn-code-out-cash
a-code-cor-acc   [3] = tt-sysconf.cor-acc-out-cash
a-code-cor-acc-2 [3] = tt-sysconf.cor-acc1-out-cash
a-code-an-uchet  [4] = tt-sysconf.an-uchet-code-in-cash
a-code-cel-nazn  [4] = tt-sysconf.cel-nazn-code-in-cash
a-code-cor-acc   [4] = tt-sysconf.cor-acc-in-cash
a-code-cor-acc-2 [4] = tt-sysconf.cor-acc1-in-cash
a-code-an-uchet  [5] = tt-sysconf.an-uchet-code-out-payoff
a-code-cel-nazn  [5] = tt-sysconf.cel-nazn-code-out-payoff
a-code-cor-acc   [5] = tt-sysconf.cor-acc-out-payoff
a-code-cor-acc-2 [5] = tt-sysconf.cor-acc1-out-payoff
a-code-an-uchet  [6] = tt-sysconf.an-uchet-code-in-payoff
a-code-cel-nazn  [6] = tt-sysconf.cel-nazn-code-in-payoff
a-code-cor-acc   [6] = tt-sysconf.cor-acc-in-payoff
a-code-cor-acc-2 [6] = tt-sysconf.cor-acc1-in-payoff
.

find first buf_fin-code-an-uchet no-lock where
         buf_fin-code-an-uchet.fin-code = tt-sysconf.an-uchet-code-out
     and buf_fin-code-an-uchet.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-an-uchet then
  assign
  an-uchet-name = buf_fin-code-an-uchet.code-value + "  " + buf_fin-code-an-uchet.descr
  p-code-an-uchet = tt-sysconf.an-uchet-code-out
  .
else do:
  assign p-code-an-uchet = 0 .
end.
assign
a-code-an-uchet [1] = p-code-an-uchet .

find first buf_fin-code-cel-nazn no-lock where
         buf_fin-code-cel-nazn.fin-code  = tt-sysconf.cel-nazn-code-out
     and buf_fin-code-cel-nazn.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-cel-nazn then
  assign
  cel-nazn-name = buf_fin-code-cel-nazn.code-value + "  " + buf_fin-code-cel-nazn.descr
  p-code-cel-nazn = tt-sysconf.cel-nazn-code-out
  .
else do:
  assign p-code-cel-nazn = ? .
end.
assign
a-code-cel-nazn [1] = p-code-cel-nazn .


find first buf_fin-code-cor-acc no-lock where
          buf_fin-code-cor-acc.fin-code  = tt-sysconf.cor-acc-out
      and buf_fin-code-cor-acc.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-cor-acc then
  assign
    cor-acc-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
    p-code-cor-acc = tt-sysconf.cor-acc-out
  .
else do:
  assign
  p-code-cor-acc = ? .
end.
assign
a-code-cor-acc [1] = p-code-cor-acc .

find first buf_fin-code-cor-acc no-lock where
          buf_fin-code-cor-acc.fin-code  = tt-sysconf.cor-acc1-out
      and buf_fin-code-cor-acc.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-cor-acc then
  assign
    cor-acc-2-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
    p-code-cor-acc-2 = tt-sysconf.cor-acc1-out
  .
else do:
  assign p-code-cor-acc-2 = ? .
end.
assign
a-code-cor-acc-2 [1] = p-code-cor-acc-2 .

  find first buf_fin-schet no-lock where
            buf_fin-schet.code-schet = tt-sysconf.pay-code-schet-rubl
        and buf_fin-schet.host-code = tt-sysconf.host-code no-error .
  if available buf_fin-schet then do:
    assign
    bank-schet = buf_fin-schet.r-schet
    p-schet    = buf_fin-schet.code-schet
    p-bank     = buf_fin-schet.code-bank  .
    find first buf_fin-bank no-lock where
              buf_fin-bank.code-bank = p-bank
         and buf_fin-bank.host-code = tt-sysconf.host-code no-error .
    assign
    bank-bik = buf_fin-bank.bik
    bank-rub = buf_fin-bank.short-name  .
  end.
  else assign  p-bank = ?    p-schet = ? .
/*
  find first buf_fin-schet no-lock  where
           buf_fin-schet.code-schet = tt-sysconf.pay-code-schet-base
       and buf_fin-schet.host-code = tt-sysconf.host-code  no-error .
  if available buf_fin-schet then do:
    assign
    bank-schet-2 = buf_fin-schet.r-schet
    p-schet1     = buf_fin-schet.code-schet
    p-bank1      = buf_fin-schet.code-bank .
    find first buf_fin-bank no-lock where
             buf_fin-bank.code-bank = p-bank1
        and buf_fin-bank.host-code = tt-sysconf.host-code no-error .
    assign
    bank-bik-2  = buf_fin-bank.bik
    bank-base   = buf_fin-bank.short-name  .
  end.
  else assign  p-bank1 = ?    p-schet1 = ? .
*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE temp-string AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
DEFINE BUFFER buf_clients FOR ub.clients.
  assign
    temp-string = ""
  .
  for each buf_sysconf no-lock :
    find first buf_clients NO-LOCK where
              buf_clients.obj-code = buf_sysconf.host-code
          and buf_clients.obj-type = {&cmp} no-error .
    if temp-string = ""
    then do:
      assign
      temp-string = string(buf_sysconf.host-code,">>>>>>>>>9") + " " + buf_clients.obj-name  .
    end.
    else do:
      assign
      temp-string = temp-string + "," + string(buf_sysconf.host-code,">>>>>>>>>9") + " " + buf_clients.obj-name
      .
    end.
  end.
  ASSIGN
  COMBO-fin-firm:LIST-ITEMS IN FRAME {&frame-name} = temp-string.


tt-sysconf.contract-type:list-items IN FRAME {&FRAME-NAME} = "Не задан" + "," + {&contract-type-list} .
if tt-sysconf.contract-type <> "" and tt-sysconf.contract-type <> ?
then tt-sysconf.contract-type:screen-value = tt-sysconf.contract-type .
else tt-sysconf.contract-type:screen-value = "Не задан" .

tt-sysconf.usl-opl:list-items   =  {&contr-usl-opl-list} .
if tt-sysconf.usl-opl <> "" and tt-sysconf.usl-opl <> ? then tt-sysconf.usl-opl:screen-value = tt-sysconf.usl-opl .
else tt-sysconf.usl-opl:screen-value = {&contr-pay-nodef} .

tt-sysconf.usl-opl-sf:list-items   = {&contr-chf-nodef} + {&comma-char}  +
                                     {&contr-chf-in} + {&comma-char}  +
                                     {&contr-chf-fo} + {&comma-char}  +
                                     {&contr-chf-pay} + {&comma-char} +
                                     {&contr-chf-type}.
if tt-sysconf.usl-opl-sf <> "" and tt-sysconf.usl-opl-sf <> ?
then tt-sysconf.usl-opl-sf:screen-value = tt-sysconf.usl-opl-sf .

COMBO-auto-pay:list-items = "фин.об. авто" + "," + "фин.об. факт" + "," + "платеж новый" /* + "," + "платеж разр" + "," + "платеж факт"*/ .
COMBO-auto-pay-2:list-items = "новый" + "," + "факт" .
case tt-sysconf.auto-pay :
when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
end.
case tt-sysconf.auto-pay-sf :
when 0 then COMBO-auto-pay-2:screen-value = "новый" .
when 1 then COMBO-auto-pay-2:screen-value = "факт" .
end.
if   tt-sysconf.usl-opl = {&contr-pay-fact-out-delay}
or tt-sysconf.usl-opl = {&contr-pay-fact-in-delay}
or tt-sysconf.usl-opl = {&contr-buyer-ord-prc}
or tt-sysconf.usl-opl = {&contr-pay-fact-out-prc}  then do:
  assign
  tt-sysconf.srok-opl = tt-sysconf.srok-opl .
  if tt-sysconf.usl-opl = {&contr-pay-fact-out-prc} or tt-sysconf.usl-opl = {&contr-buyer-ord-prc}
  then assign tt-sysconf.srok-opl:label = "> %" .
end.
IF NOT is-fin THEN DO:
  ASSIGN
  radio-set-1:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
  {&FDEDT_Expense_cash} + {&comma-char} + "3" + {&comma-char} +
  {&FDEDT_income_cash} + {&comma-char} +  "4"
  .
  radio-set-1 = 3.
END.
else do:
  radio-set-1 = 1.
end.
DISPLAY
COMBO-auto-pay
COMBO-auto-pay-2
RADIO-SET-1
cor-acc-name
an-uchet-name
cel-nazn-name
cor-acc-2-name
bank-schet
bank-bik
bank-rub
WITH FRAME {&FRAME-NAME}.
IF AVAILABLE tt-sysconf THEN
DISPLAY
tt-sysconf.contract-type
tt-sysconf.contract-city
tt-sysconf.usl-opl
tt-sysconf.srok-opl
tt-sysconf.usl-opl-sf
tt-sysconf.srok-opl-sf
tt-sysconf.pay-sign-post
tt-sysconf.pay-sign
tt-sysconf.is-an-uchet
tt-sysconf.is-code-cel-nazn
tt-sysconf.fin-VAT-pc
tt-sysconf.is-corr-acc
tt-sysconf.is-cassa-acc
tt-sysconf.fin-calc
WITH FRAME {&frame-name}.
ENABLE
b-exit WHEN p-mode <> {&LOOKUP}
RECT-2 RECT-4 RECT-6 RECT-5
B-quit
b-help
tt-sysconf.contract-type WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.contract-city WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.usl-opl  WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.srok-opl WHEN p-mode <> {&LOOKUP} AND is-fin
COMBO-auto-pay WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.usl-opl-sf WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.srok-opl-sf WHEN p-mode <> {&LOOKUP} AND is-fin
COMBO-auto-pay-2 WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.pay-sign-post WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.pay-sign WHEN p-mode <> {&LOOKUP} AND is-fin
RADIO-SET-1
b-cor-acc   WHEN p-mode <> {&LOOKUP} AND VALID-HANDLE (parparentproc)
b-an-uchet WHEN p-mode <> {&LOOKUP} AND VALID-HANDLE (parparentproc)
b-cel-nazn WHEN p-mode <> {&LOOKUP} AND VALID-HANDLE (parparentproc)
b-cor-acc-2 WHEN p-mode <> {&LOOKUP} AND VALID-HANDLE (parparentproc)
b-bank-rub WHEN p-mode <> {&LOOKUP} AND VALID-HANDLE (parparentproc) AND is-fin
tt-sysconf.is-an-uchet WHEN p-mode <> {&LOOKUP}
tt-sysconf.is-code-cel-nazn WHEN p-mode <> {&LOOKUP}
tt-sysconf.fin-VAT-pc WHEN p-mode <> {&LOOKUP} AND is-fin
tt-sysconf.is-corr-acc WHEN p-mode <> {&LOOKUP}
tt-sysconf.is-cassa-acc WHEN p-mode <> {&LOOKUP}
tt-sysconf.fin-calc WHEN p-mode <> {&LOOKUP}   AND is-fin
Is-fin-copy WHEN p-mode <> {&LOOKUP} AND is-fin
COMBO-fin-firm WHEN p-mode <> {&LOOKUP} AND is-fin
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
if p-mode = {&lookup} then do:
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:COLUMN = 1
    .
    HIDE
    b-exit
    Is-fin-copy
    COMBO-fin-firm
    IN FRAME {&FRAME-NAME}.
end.
else do:
    if   tt-sysconf.usl-opl = {&contr-pay-nodef}
      or tt-sysconf.usl-opl = {&contr-pay-fact-in}
      or tt-sysconf.usl-opl = {&contr-pay-fact-out}
    then  do:
      disable
      tt-sysconf.srok-opl
      with frame {&frame-name}.
    end.
    disable
    tt-sysconf.srok-opl-sf
    with frame {&frame-name}.
end.
apply "VALUE-CHANGED" to RADIO-SET-1 in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
define variable v-fin-host-copy like ub.sysconf.host-code no-undo .
assign
FRAME {&FRAME-NAME}
RADIO-SET-1
COMBO-auto-pay
COMBO-auto-pay-2
is-fin-copy
COMBO-fin-firm
.
assign
v-fin-host-copy = int(substr(COMBO-fin-firm,1,6))
no-error
.
assign
a-code-an-uchet  [RADIO-SET-1] = p-code-an-uchet
a-code-cel-nazn  [RADIO-SET-1] = p-code-cel-nazn
a-code-cor-acc   [RADIO-SET-1] = p-code-cor-acc
a-code-cor-acc-2 [RADIO-SET-1] = p-code-cor-acc-2
.
case COMBO-auto-pay:screen-value IN FRAME {&FRAME-NAME}:
  when "фин.об. авто" then tt-sysconf.auto-pay = 0 .
  when "фин.об. факт" then tt-sysconf.auto-pay = 1 .
  when "платеж новый" then tt-sysconf.auto-pay = 2 .
  when "платеж разр"  then tt-sysconf.auto-pay = 3 .
  when "платеж факт"  then tt-sysconf.auto-pay = 4 .
end.
case COMBO-auto-pay-2:screen-value :
  when "новый" then tt-sysconf.auto-pay-sf = 0 .
  when "факт" then tt-sysconf.auto-pay-sf = 1 .
end.
ASSIGN
tt-sysconf.contract-city
tt-sysconf.contract-type
tt-sysconf.pay-sign-post
tt-sysconf.pay-sign
tt-sysconf.fin-VAT-pc
tt-sysconf.srok-opl
tt-sysconf.srok-opl-sf
tt-sysconf.usl-opl
tt-sysconf.usl-opl-sf
tt-sysconf.is-an-uchet
tt-sysconf.is-code-cel-nazn
tt-sysconf.is-corr-acc
tt-sysconf.is-cassa-acc
tt-sysconf.fin-calc
tt-sysconf.pay-code-schet-rubl = p-schet
tt-sysconf.pay-code-schet-base = p-schet1
tt-sysconf.an-uchet-code-out        = a-code-an-uchet  [1]
tt-sysconf.cel-nazn-code-out        = a-code-cel-nazn  [1]
tt-sysconf.cor-acc-out              = a-code-cor-acc   [1]
tt-sysconf.cor-acc1-out             = a-code-cor-acc-2 [1]
tt-sysconf.an-uchet-code-in         = a-code-an-uchet  [2]
tt-sysconf.cel-nazn-code-in         = a-code-cel-nazn  [2]
tt-sysconf.cor-acc-in               = a-code-cor-acc   [2]
tt-sysconf.cor-acc1-in              = a-code-cor-acc-2 [2]
tt-sysconf.an-uchet-code-out-cash   = a-code-an-uchet  [3]
tt-sysconf.cel-nazn-code-out-cash   = a-code-cel-nazn  [3]
tt-sysconf.cor-acc-out-cash         = a-code-cor-acc   [3]
tt-sysconf.cor-acc1-out-cash        = a-code-cor-acc-2 [3]
tt-sysconf.an-uchet-code-in-cash    = a-code-an-uchet  [4]
tt-sysconf.cel-nazn-code-in-cash    = a-code-cel-nazn  [4]
tt-sysconf.cor-acc-in-cash          = a-code-cor-acc   [4]
tt-sysconf.cor-acc1-in-cash         = a-code-cor-acc-2 [4]
tt-sysconf.an-uchet-code-out-payoff = a-code-an-uchet  [5]
tt-sysconf.cel-nazn-code-out-payoff = a-code-cel-nazn  [5]
tt-sysconf.cor-acc-out-payoff       = a-code-cor-acc   [5]
tt-sysconf.cor-acc1-out-payoff      = a-code-cor-acc-2 [5]
tt-sysconf.an-uchet-code-in-payoff  = a-code-an-uchet  [6]
tt-sysconf.cel-nazn-code-in-payoff  = a-code-cel-nazn  [6]
tt-sysconf.cor-acc-in-payoff        = a-code-cor-acc   [6]
tt-sysconf.cor-acc1-in-payoff       = a-code-cor-acc-2 [6]
.
if ( tt-sysconf.usl-opl = {&contr-pay-fact-out-prc}
    or tt-sysconf.usl-opl = {&contr-buyer-ord-prc}) and tt-sysconf.srok-opl = 0 then do:
  message
  "Процент реализации не может быть 0 !"
  view-as alert-box ERROR.
  undo, return ERROR.
end.
v-rid = recid(locked_sysconf).
run adm/fin-def1.p (
   input-output v-rid
  ,input p-mode
  ,input no /*silent*/
  ,input  tt-sysconf.host-code
  ,input  is-fin-copy
  ,input  v-fin-host-copy
  ,input  tt-sysconf.contract-city
  ,input  tt-sysconf.contract-type
  ,input  tt-sysconf.pay-sign-post
  ,input  tt-sysconf.pay-sign
  ,input  tt-sysconf.fin-VAT-pc
  ,input  tt-sysconf.srok-opl
  ,input  tt-sysconf.srok-opl-sf
  ,input  tt-sysconf.usl-opl
  ,input  tt-sysconf.usl-opl-sf
  ,input  tt-sysconf.is-an-uchet
  ,input  tt-sysconf.is-code-cel-nazn
  ,input  tt-sysconf.is-corr-acc
  ,input  tt-sysconf.is-cassa-acc
  ,input  tt-sysconf.fin-calc
  ,input  tt-sysconf.pay-code-schet-rubl
  ,input  tt-sysconf.pay-code-schet-base
  ,input  tt-sysconf.an-uchet-code-out
  ,input  tt-sysconf.cel-nazn-code-out
  ,input  tt-sysconf.cor-acc-out
  ,input  tt-sysconf.cor-acc1-out
  ,input  tt-sysconf.an-uchet-code-in
  ,input  tt-sysconf.cel-nazn-code-in
  ,input  tt-sysconf.cor-acc-in
  ,input  tt-sysconf.cor-acc1-in
  ,input  tt-sysconf.an-uchet-code-out-cash
  ,input  tt-sysconf.cel-nazn-code-out-cash
  ,input  tt-sysconf.cor-acc-out-cash
  ,input  tt-sysconf.cor-acc1-out-cash
  ,input  tt-sysconf.an-uchet-code-in-cash
  ,input  tt-sysconf.cel-nazn-code-in-cash
  ,input  tt-sysconf.cor-acc-in-cash
  ,input  tt-sysconf.cor-acc1-in-cash
  ,input  tt-sysconf.an-uchet-code-out-payoff
  ,input  tt-sysconf.cel-nazn-code-out-payoff
  ,input  tt-sysconf.cor-acc-out-payoff
  ,input  tt-sysconf.cor-acc1-out-payoff
  ,input  tt-sysconf.an-uchet-code-in-payoff
  ,input  tt-sysconf.cel-nazn-code-in-payoff
  ,input  tt-sysconf.cor-acc-in-payoff
  ,input  tt-sysconf.cor-acc1-in-payoff
    ) NO-ERROR.
IF ERROR-STATUS:ERROR  THEN DO:
 { gbl/reterhnd.i error }
  undo, return error.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME