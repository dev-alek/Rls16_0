&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение дисконтных карт по списку-запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/10/04
Author: Bakhtadze Natalya
Creation date: 09/10/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение дисконтных карт по списку-запуск".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
/*настройка - тип карты заводимой по умолчанию*/
define variable defltdc as char no-undo.
/*настройка - процент скидки для карты по умолчанию*/
define variable deflt-d-pcnt like ub.dis-card.d-pcnt no-undo.
/*список всех используемых на фирме типов карт*/
define variable cards as char no-undo.
/*как будут отобраны записи dis-card*/
define variable DCARDMODE as char no-undo init "".
define variable cli-str as char no-undo.
define variable where-phrase as char no-undo.
define variable dc-pfx as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.dis-card

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.dis-card SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.dis-card SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.dis-card
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.dis-card


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit l-category l-cli-message ~
l-credit-card l-d-pcnt l-d-pcnt-method l-dc-status l-dc-type l-debet-card ~
l-issue-code l-issue-date l-lim-kr l-staff-card l-valid-date RECT-1 RECT-3 ~
RECT-5 RECT-6 RECT-7 l-cash-d-pcnt l-valid-from B-quit B-lst B-Help ~
d-pcnt-method n-dc-type dc-type n-cash-d-pcnt n-category n-d-pcnt ~
n-d-pcnt-method n-valid-date n-valid-from n-issue-date n-issue-code ~
n-debet-card n-staff-card n-credit-card n-lim-kr n-dc-status n-cli-message
&Scoped-Define DISPLAYED-OBJECTS cash-d-pcnt category d-pcnt d-pcnt-method ~
valid-date issue-date valid-from issue-code debet-card staff-card ~
credit-card lim-kr dc-status cli-message n-dc-type dc-type n-cash-d-pcnt ~
n-category n-d-pcnt n-d-pcnt-method n-valid-date n-valid-from n-issue-date ~
n-issue-code n-debet-card n-staff-card n-credit-card n-lim-kr n-dc-status ~
n-cli-message

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lst
     LABEL "&Список"
     SIZE 10 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-shop
     IMAGE-UP FILE "adeicon\y-combo":U
     LABEL "Btn 6"
     SIZE 4.3 BY 1.

DEFINE BUTTON B-type
     IMAGE-UP FILE "adeicon\y-combo":U
     LABEL "Btn 6"
     SIZE 4.3 BY 1.

DEFINE VARIABLE cash-d-pcnt AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE category AS INTEGER FORMAT ">9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE cli-message AS CHARACTER FORMAT "X(256)":U INITIAL "0"
     VIEW-AS FILL-IN
     SIZE 52 BY 1 NO-UNDO.

DEFINE VARIABLE d-pcnt AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE dc-type AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 12.8 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE emitent-host-code AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "Код фирмы эмитента"
      VIEW-AS TEXT
     SIZE 7.4 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE issue-code AS INTEGER FORMAT "99999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.4 BY 1 NO-UNDO.

DEFINE VARIABLE issue-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.

DEFINE VARIABLE lim-kr AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.9 BY 1 NO-UNDO.

DEFINE VARIABLE n-cash-d-pcnt AS CHARACTER FORMAT "X(256)":U INITIAL "% скидки на итог:"
      VIEW-AS TEXT
     SIZE 18.1 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-category AS CHARACTER FORMAT "X(256)":U INITIAL "категория:"
      VIEW-AS TEXT
     SIZE 10 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-cli-message AS CHARACTER FORMAT "X(256)":U INITIAL "Сообщ. для клиента"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-credit-card AS CHARACTER FORMAT "X(256)":U INITIAL "Кредитная карта"
      VIEW-AS TEXT
     SIZE 16.1 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-d-pcnt AS CHARACTER FORMAT "X(256)":U INITIAL "% скидки на товар:"
      VIEW-AS TEXT
     SIZE 17.9 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-d-pcnt-method AS CHARACTER FORMAT "X(256)":U INITIAL "Метод исп скидки"
      VIEW-AS TEXT
     SIZE 17.9 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-dc-status AS CHARACTER FORMAT "X(256)":U INITIAL "Статус карты"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-dc-type AS CHARACTER FORMAT "X(256)":U INITIAL "Тип карты:"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-debet-card AS CHARACTER FORMAT "X(256)":U INITIAL "Кредитная карта"
      VIEW-AS TEXT
     SIZE 16.1 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-issue-code AS CHARACTER FORMAT "X(256)":U INITIAL "Выдал магазин"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-issue-date AS CHARACTER FORMAT "X(256)":U INITIAL "Дата выдачи:"
      VIEW-AS TEXT
     SIZE 12.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-lim-kr AS CHARACTER FORMAT "X(256)":U INITIAL "Лимит кредита"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-staff-card AS CHARACTER FORMAT "X(256)":U INITIAL "Кредитная карта"
      VIEW-AS TEXT
     SIZE 16.1 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-valid-date AS CHARACTER FORMAT "X(256)":U INITIAL "По:"
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-valid-from AS CHARACTER FORMAT "X(256)":U INITIAL "Действительна c:"
      VIEW-AS TEXT
     SIZE 16 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE valid-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.

DEFINE VARIABLE valid-from AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.

DEFINE IMAGE l-cash-d-pcnt
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-category
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-cli-message
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-credit-card
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-d-pcnt
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-d-pcnt-method
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-dc-status
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-dc-type
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-debet-card
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-issue-code
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-issue-date
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-lim-kr
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-staff-card
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-valid-date
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-valid-from
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE VARIABLE d-pcnt-method AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 41.1 BY .93 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 3.63.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 2.8.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 3.27.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.6 BY 2.87.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.6 BY 2.87.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 91.5 BY 1.43.

DEFINE VARIABLE dc-status AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "1"
     SIZE 13.9 BY 2.03 NO-UNDO.

DEFINE VARIABLE credit-card AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE debet-card AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE staff-card AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.dis-card SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-lst AT ROW 1 COL 21
     B-Help AT ROW 1 COL 81
     B-type AT ROW 2.57 COL 36.1
     cash-d-pcnt AT ROW 5.67 COL 57.1 COLON-ALIGNED NO-LABEL
     category AT ROW 5.67 COL 80.1 COLON-ALIGNED NO-LABEL
     d-pcnt AT ROW 5.77 COL 25.1 COLON-ALIGNED NO-LABEL
     d-pcnt-method AT ROW 6.97 COL 25.1 NO-LABEL
     valid-date AT ROW 8.47 COL 77.5 COLON-ALIGNED NO-LABEL
     issue-date AT ROW 8.67 COL 19.3 COLON-ALIGNED NO-LABEL
     valid-from AT ROW 8.67 COL 52.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     issue-code AT ROW 10.43 COL 21.1 COLON-ALIGNED NO-LABEL
     B-shop AT ROW 10.47 COL 30.3
     debet-card AT ROW 12.5 COL 32
     staff-card AT ROW 12.5 COL 57.5
     credit-card AT ROW 12.63 COL 7
     lim-kr AT ROW 14 COL 20.5 COLON-ALIGNED NO-LABEL
     dc-status AT ROW 15.77 COL 24.5 NO-LABEL
     cli-message AT ROW 18.27 COL 24.5 COLON-ALIGNED NO-LABEL
     n-dc-type AT ROW 2.53 COL 5.1 COLON-ALIGNED NO-LABEL
     dc-type AT ROW 2.57 COL 20.8 COLON-ALIGNED NO-LABEL
     emitent-host-code AT ROW 4 COL 21.5 COLON-ALIGNED
     n-cash-d-pcnt AT ROW 5.63 COL 40.3 NO-LABEL
     n-category AT ROW 5.63 COL 70.3 NO-LABEL
     n-d-pcnt AT ROW 5.7 COL 6.9 NO-LABEL
     n-d-pcnt-method AT ROW 6.83 COL 7 NO-LABEL
     n-valid-date AT ROW 8.47 COL 75 NO-LABEL
     n-valid-from AT ROW 8.67 COL 38 NO-LABEL WIDGET-ID 4
     n-issue-date AT ROW 8.7 COL 7.8 NO-LABEL
     n-issue-code AT ROW 10.53 COL 5 COLON-ALIGNED NO-LABEL
     n-debet-card AT ROW 12.5 COL 36 NO-LABEL
     n-staff-card AT ROW 12.5 COL 61.5 NO-LABEL
     n-credit-card AT ROW 12.63 COL 11 NO-LABEL
     n-lim-kr AT ROW 14 COL 6.5 NO-LABEL
     n-dc-status AT ROW 15.77 COL 6 COLON-ALIGNED NO-LABEL
     n-cli-message AT ROW 18.27 COL 5.5 COLON-ALIGNED NO-LABEL
     RECT-2 AT ROW 15.27 COL 2
     l-category AT ROW 5.77 COL 67
     l-cli-message AT ROW 18.27 COL 3.5
     l-credit-card AT ROW 12.43 COL 3.1
     l-d-pcnt AT ROW 5.77 COL 3.6
     l-d-pcnt-method AT ROW 7 COL 3.6
     l-dc-status AT ROW 15.77 COL 3
     l-dc-type AT ROW 2.53 COL 3.6
     l-debet-card AT ROW 12.43 COL 28
     l-issue-code AT ROW 10.57 COL 4
     l-issue-date AT ROW 8.87 COL 4
     l-lim-kr AT ROW 14 COL 3
     l-staff-card AT ROW 12.5 COL 53.5
     l-valid-date AT ROW 8.73 COL 72
     RECT-1 AT ROW 8.27 COL 2
     RECT-3 AT ROW 12 COL 2
     RECT-5 AT ROW 5.3 COL 1.9
     RECT-6 AT ROW 2.2 COL 1.9
     RECT-7 AT ROW 18 COL 2
     l-cash-d-pcnt AT ROW 5.77 COL 37
     l-valid-from AT ROW 8.73 COL 34.5 WIDGET-ID 6
     SPACE(56.89) SKIP(9.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение дисконтных карт по списку"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.


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

/* SETTINGS FOR BUTTON B-shop IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cash-d-pcnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN category IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cli-message IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX credit-card IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN d-pcnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR SELECTION-LIST dc-status IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX debet-card IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN emitent-host-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       emitent-host-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN issue-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN issue-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN lim-kr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN n-cash-d-pcnt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-category IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-credit-card IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-d-pcnt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-d-pcnt-method IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-debet-card IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-issue-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-lim-kr IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-staff-card IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-valid-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-valid-from IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR RECTANGLE RECT-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX staff-card IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN valid-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN valid-from IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.dis-card"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение дисконтных карт по списку */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод  */
DO:
    run b-exit-proc in this-procedure no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lst Dialog-Frame
ON CHOOSE OF B-lst IN FRAME Dialog-Frame /* Список */
DO:
    define variable Filter-name as char no-undo.
    run str/dc-list.w ( input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shop Dialog-Frame
ON CHOOSE OF B-shop IN FRAME Dialog-Frame /* Btn 6 */
DO:
    define variable rid-list as char no-undo.
  rid-list = "".
  run adm/shops.w ( input parparentproc, "b-sel", input-output rid-list, input no).
  if rid-list <> "" then do:
    FIND FIRST ub.shop No-LOCK WHERE recid(ub.shop) = integer(rid-list) No-ERROR.
    if ub.shop.host-code <> v-cntxt-host-code-obj then do:
        message "Нельзя выдать дисконтную карту для чужой фирмы!"
        view-as alert-box ERROR.
        return no-apply.
    end.
    assign
    issue-code:screen-value = string(shop.obj-code)
    emitent-host-code:screen-value = string(shop.host-code).
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type Dialog-Frame
ON CHOOSE OF B-type IN FRAME Dialog-Frame /* Btn 6 */
DO:
 run proc-b-type in this-procedure no-error.
 if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type Dialog-Frame
ON RIGHT-MOUSE-CLICK OF B-type IN FRAME Dialog-Frame /* Btn 6 */
DO:

    assign
    n-dc-type:fgcolor = 15
    l-dc-type:visible = true.
    display dc-type with frame {&frame-name}.
    disable b-type with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cash-d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cash-d-pcnt Dialog-Frame
ON RIGHT-MOUSE-CLICK OF cash-d-pcnt IN FRAME Dialog-Frame
DO:
    assign
    n-cash-d-pcnt:fgcolor = 15
    cash-d-pcnt = ?
    l-cash-d-pcnt:visible = true.
    display cash-d-pcnt with frame {&frame-name}.
    disable cash-d-pcnt with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME category
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL category Dialog-Frame
ON RIGHT-MOUSE-CLICK OF category IN FRAME Dialog-Frame
DO:
    assign
    n-category:fgcolor = 15
    category = ?
    l-category:visible = true.
    display category with frame {&frame-name}.
    disable category with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-message
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-message Dialog-Frame
ON RIGHT-MOUSE-CLICK OF cli-message IN FRAME Dialog-Frame
DO:

    assign
    n-cli-message:fgcolor = 15
    cli-message = "":U
    l-cli-message:visible = true.
    display cli-message with frame {&frame-name}.
    disable cli-message with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME credit-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL credit-card Dialog-Frame
ON RIGHT-MOUSE-CLICK OF credit-card IN FRAME Dialog-Frame
DO:
     assign
    n-credit-card:fgcolor = 15
    l-credit-card:visible = true.
    display credit-card with frame {&frame-name}.
    disable credit-card with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-pcnt Dialog-Frame
ON RIGHT-MOUSE-CLICK OF d-pcnt IN FRAME Dialog-Frame
DO:
    assign
    n-d-pcnt:fgcolor = 15
    d-pcnt = ?
    l-d-pcnt:visible = true.
    display d-pcnt with frame {&frame-name}.
    disable d-pcnt with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME d-pcnt-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-pcnt-method Dialog-Frame
ON RIGHT-MOUSE-CLICK OF d-pcnt-method IN FRAME Dialog-Frame
DO:
     assign
    n-d-pcnt-method:fgcolor = 15
    d-pcnt-method = string({&dc-d-pcnt-good})
    l-d-pcnt-method:visible = true.
    display d-pcnt-method with frame {&frame-name}.
    disable d-pcnt-method with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME dc-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dc-status Dialog-Frame
ON RIGHT-MOUSE-CLICK OF dc-status IN FRAME Dialog-Frame
DO:

    assign
    n-dc-status:fgcolor = 15
    l-dc-status:visible = true.
    display dc-status with frame {&frame-name}.
    disable dc-status with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME debet-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL debet-card Dialog-Frame
ON RIGHT-MOUSE-CLICK OF debet-card IN FRAME Dialog-Frame
DO:
     assign
    n-debet-card:fgcolor = 15
    l-debet-card:visible = true.
    display debet-card with frame {&frame-name}.
    disable debet-card with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME issue-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL issue-code Dialog-Frame
ON RIGHT-MOUSE-CLICK OF issue-code IN FRAME Dialog-Frame
DO:

    assign
    n-issue-code:fgcolor = 15
    issue-code = ?
    l-issue-code:visible = true.
    display issue-code with frame {&frame-name}.
    disable issue-code b-shop with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME issue-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL issue-date Dialog-Frame
ON RIGHT-MOUSE-CLICK OF issue-date IN FRAME Dialog-Frame
DO:
    assign
    n-issue-date:fgcolor = 15
    issue-date = ?
    l-issue-date:visible = true.
    display issue-date with frame {&frame-name}.
    disable issue-date with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-cash-d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-cash-d-pcnt Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-cash-d-pcnt IN FRAME Dialog-Frame
DO:
   IF l-cash-d-pcnt:visible then do:
    assign
    n-cash-d-pcnt:fgcolor = ?
    l-cash-d-pcnt:visible = false.
    enable cash-d-pcnt with frame {&frame-name}.
    APPLY "ENTRY" TO cash-d-pcnt.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-category
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-category Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-category IN FRAME Dialog-Frame
DO:
   IF l-category:visible then do:
    assign
    n-category:fgcolor = ?
    l-category:visible = false.
    enable category with frame {&frame-name}.
    APPLY "ENTRY" TO category.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-cli-message
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-cli-message Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-cli-message IN FRAME Dialog-Frame
DO:
   IF l-cli-message:visible then do:
    assign
    n-cli-message:fgcolor = ?
    l-cli-message:visible = false.
    enable cli-message with frame {&frame-name}.
    APPLY "ENTRY" TO cli-message.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-credit-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-credit-card Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-credit-card IN FRAME Dialog-Frame
DO:
   IF l-credit-card:visible then do:
    assign
    n-credit-card:fgcolor = ?
    l-credit-card:visible = false.
    enable credit-card with frame {&frame-name}.
    APPLY "ENTRY" TO credit-card.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-d-pcnt Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-d-pcnt IN FRAME Dialog-Frame
DO:
   IF l-d-pcnt:visible then do:
    assign
    n-d-pcnt:fgcolor = ?
    l-d-pcnt:visible = false.
    enable d-pcnt with frame {&frame-name}.
    APPLY "ENTRY" TO d-pcnt.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-d-pcnt-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-d-pcnt-method Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-d-pcnt-method IN FRAME Dialog-Frame
DO:
   IF l-d-pcnt-method:visible then do:
    assign
    n-d-pcnt-method:fgcolor = ?
    l-d-pcnt-method:visible = false.
    enable d-pcnt-method with frame {&frame-name}.
    APPLY "ENTRY" TO d-pcnt-method.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-dc-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-dc-status Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-dc-status IN FRAME Dialog-Frame
DO:
   IF l-dc-status:visible then do:
    assign
    n-dc-status:fgcolor = ?
    l-dc-status:visible = false.
    enable dc-status with frame {&frame-name}.
    APPLY "ENTRY" TO dc-status.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-dc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-dc-type Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-dc-type IN FRAME Dialog-Frame
DO:
   IF l-dc-type:visible then do:
    assign
    n-dc-type:fgcolor = ?
    l-dc-type:visible = false.
    enable b-type with frame {&frame-name}.
    APPLY "ENTRY" TO dc-type.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-debet-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-debet-card Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-debet-card IN FRAME Dialog-Frame
DO:
   IF l-debet-card:visible then do:
    assign
    n-debet-card:fgcolor = ?
    l-debet-card:visible = false.
    enable debet-card with frame {&frame-name}.
    APPLY "ENTRY" TO debet-card.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-issue-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-issue-code Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-issue-code IN FRAME Dialog-Frame
DO:
   IF l-issue-code:visible then do:
    assign
    n-issue-code:fgcolor = ?
    l-issue-code:visible = false.
    enable
    issue-code
    B-shop
    with frame {&frame-name}.
    APPLY "ENTRY" TO issue-code.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-issue-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-issue-date Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-issue-date IN FRAME Dialog-Frame
DO:
   IF l-issue-date:visible then do:
    assign
    n-issue-date:fgcolor = ?
    l-issue-date:visible = false.
    enable issue-date with frame {&frame-name}.
    APPLY "ENTRY" TO issue-date.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-lim-kr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-lim-kr Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-lim-kr IN FRAME Dialog-Frame
DO:
   IF l-lim-kr:visible then do:
    assign
    n-lim-kr:fgcolor = ?
    l-lim-kr:visible = false.
    enable
    lim-kr
    with frame {&frame-name}.
    APPLY "ENTRY" TO lim-Kr.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-staff-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-staff-card Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-staff-card IN FRAME Dialog-Frame
DO:
   IF l-staff-card:visible then do:
    assign
    n-staff-card:fgcolor = ?
    l-staff-card:visible = false.
    enable staff-card with frame {&frame-name}.
    APPLY "ENTRY" TO staff-card.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-valid-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-valid-date Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-valid-date IN FRAME Dialog-Frame
DO:
   IF l-valid-date:visible then do:
    assign
    n-valid-date:fgcolor = ?
    l-valid-date:visible = false.
    enable valid-date with frame {&frame-name}.
    APPLY "ENTRY" TO valid-date.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-valid-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-valid-from Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-valid-from IN FRAME Dialog-Frame
DO:
   IF l-valid-from:visible then do:
    assign
    n-valid-from:fgcolor = ?
    l-valid-from:visible = false.
    enable valid-from with frame {&frame-name}.
    APPLY "ENTRY" TO valid-from.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME lim-kr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL lim-kr Dialog-Frame
ON RIGHT-MOUSE-CLICK OF lim-kr IN FRAME Dialog-Frame
DO:
   assign
    n-lim-kr:fgcolor = 15
    l-lim-kr:visible = true.
    display lim-kr with frame {&frame-name}.
    disable lim-kr with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME n-dc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL n-dc-type Dialog-Frame
ON RIGHT-MOUSE-CLICK OF n-dc-type IN FRAME Dialog-Frame
DO:
     assign
    n-dc-type:fgcolor = 15
    dc-type = ""
    l-dc-type:visible = true.
    display dc-type with frame {&frame-name}.
    disable b-type with frame {&frame-name}.
    Hide emitent-host-code in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME staff-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL staff-card Dialog-Frame
ON RIGHT-MOUSE-CLICK OF staff-card IN FRAME Dialog-Frame
DO:
     assign
    n-staff-card:fgcolor = 15
    l-staff-card:visible = true.
    display staff-card with frame {&frame-name}.
    disable staff-card with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME valid-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL valid-date Dialog-Frame
ON RIGHT-MOUSE-CLICK OF valid-date IN FRAME Dialog-Frame
DO:
    assign
    n-valid-date:fgcolor = 15
    valid-date = ?
    l-valid-date:visible = true.
    display valid-date with frame {&frame-name}.
    disable valid-date with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME valid-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL valid-from Dialog-Frame
ON RIGHT-MOUSE-CLICK OF valid-from IN FRAME Dialog-Frame
DO:
    assign
    n-valid-from:fgcolor = 15
    valid-from = ?
    l-valid-from:visible = true.
    display valid-from with frame {&frame-name}.
    disable valid-from with frame {&frame-name}.

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

if ( g#db-num > 0 ) then do:
    message "Данная утилита может быть запущена только в ГБД!" view-as alert-box.
    return.
end.
{ gbl/getcntxt.i get }

define variable glog as logical   no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_referense-dis_input-deletion-updating':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  glog
}
if not glog
then do:
  return.
end.



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  dc-status:list-items = {&current-status} + {&comma-char} + {&blocked-status} + {&comma-char} + {&deleted-status}.
  d-pcnt-method:radio-buttons =
       "{&bef-dc-d-pcnt-good-full}" + {&comma-char} + string({&dc-d-pcnt-good}) + {&comma-char} +
     "{&bef-dc-d-pcnt-cash-full}" + {&comma-char} + string({&dc-d-pcnt-cash}) + {&comma-char} +
     "{&bef-dc-d-pcnt-both-full}" + {&comma-char} + string({&dc-d-pcnt-both}).

  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE b-exit-proc Dialog-Frame
PROCEDURE b-exit-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable mystr as char format "X(500)".
define variable glog as logical no-undo .
define variable II AS INTEGER NO-UNDO.
DEFINE VARIABLE var-run-names as character no-undo .
define variable ok-to-restore as logical no-undo .
if not can-find(first dc-list) then do:
  BELL.
  message
  "В списке дисконтных карт нет ни одной карты!"
  view-as alert-box WARNING.
  return error.
end.

assign
frame {&frame-name} dc-status
dc-type
d-pcnt
cash-d-pcnt
category
emitent-host-code
issue-code
issue-date
credit-card
LIM-KR
valid-date
d-pcnt-method
debet-card
staff-card
cli-message
.

if issue-code:sensitive and integer(issue-code:screen-value) = 0 then do:
    message "Укажите код магазина, выдавшего карту!" view-as alert-box WARNING.
    return error .
end.
if issue-date:sensitive and issue-date:screen-value = "  /  /    " then do:
    message "Укажите дату выдачи карты!" view-as alert-box WARNING.
    return error .
end.
if b-type:sensitive and dc-type = "" then do:
    message "Укажите тип карты!" view-as alert-box WARNING.
    return error .
end.
if d-pcnt:sensitive and ((d-pcnt < 0 ) OR ( d-pcnt = ? )) then do:
        message "Вам следует ввести" skip
                        "НЕОТРИЦАТЕЛЬНЫЙ процент скидки (на товары)."
                        view-as alert-box INFORMATION .
        apply "ENTRY":U to d-pcnt IN frame {&frame-name}.
        return error .
end.
if cash-d-pcnt:sensitive and ((cash-d-pcnt < 0 ) OR ( cash-d-pcnt = ? )) then do:
        message "Вам следует ввести" skip
                        "НЕОТРИЦАТЕЛЬНЫЙ процент скидки (на итог)."
                        view-as alert-box INFORMATION .
        apply "ENTRY":U to cash-d-pcnt IN frame {&frame-name}.
        return error .
end.

IF dc-status:sensitive and dc-status = {&current-status} or dc-status = {&blocked-status} then do:
  /*проверим право на изменение статуса*/
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_referense-dis_current-status':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    false
    ok-to-restore
  }
  if not ok-to-restore then do:
    message
    substitute("ВНИМАНИЕ!&1" +
              "У Вас нет прав на восстановление удаленных карт&1" +
              "Для удаленных карт статус карты на &2  изменен не будет!"
              , {&new-line}
              , dc-status  )
    view-as alert-box  WARNING.
  end.
end.
IF credit-card:sensitive
    AND credit-card
    AND debet-card:sensitive
    AND debet-card THEN DO:
   message
  "Карта не может быть одновреенно кредитной и дебетовой"
  view-as ALERT-BOX ERROR.
  RETURN ERROR.
END.
mystr =   (IF dc-status:sensitive then ("СТАТУС="+                   dc-status + {&new-line} ) else "") +
          (IF b-type:sensitive then ("ТИП КАРТЫ=" +                  dc-type + {&new-line} ) else "") +
          (IF b-type:sensitive then ("ЭМИТЕНТ=" +                    string(ub.dis-card-type.emitent-host-code) + {&new-line} ) else "") +
          (IF d-pcnt:sensitive then ("% СКИДКИ НА ТОВАР=" +          string(d-pcnt) + {&new-line} ) else "") +
          (IF cash-d-pcnt:sensitive then ("% СКИДКИ НА ИТОГ=" +      string(cash-d-pcnt) + {&new-line} ) else "") +
          (IF category:sensitive then ("КАТЕГОРИЯ=" +                string(category) + {&new-line} ) else "") +
          (IF issue-date:sensitive then ("ДАТА ВЫДАЧИ=" +            string(issue-date, "99/99/9999") ) else "") +
          (IF issue-code:sensitive then ("ВЫДАЛ МАГАЗИН=" +          string(issue-code, "99999") ) else "") +
          (IF credit-card:sensitive then ("КРЕДИТНАЯ КАРТА=" +       string(credit-card, "да/нет") ) else "") +
          (IF debet-card:sensitive then ("ДЕБЕТОВАЯ КАРТА=" +        string(debet-card, "да/нет") ) else "") +
          (IF staff-card:sensitive then ("КАРТА ПЕРСОНАЛА=" +        string(staff-card, "да/нет") ) else "") +
          (IF lim-kr:sensitive then ("ЛИМИТ КРЕДИТА=" +              string(lim-kr)) else "") +
          (IF valid-date:sensitive then ("ДАТА ДЕЙСТВИЯ ДО=" +       string(valid-date, "99/99/9999") ) else "") +
          (IF d-pcnt-method:sensitive then ("ТИП СКИДКИ=" +          radio-label(d-pcnt-method, d-pcnt-method:radio-buttons) + {&new-line}) else "":U) +
          (IF cli-message:sensitive then ("СООБЩЕНИЕ ДЛЯ КЛИЕНТА=" + string(cli-message, "X(128)" )) else "")
.


if REPLACE(mystr, {&new-line}, "") = "" then do:
  message "Не выбраны поля и значения для внесения изменений" view-as alert-box
  Warning.
  return error .
end.
message
"В выбранных дисконтных картах будут произведены следующие изменения:" skip
mystr skip "Продолжать?"
view-as alert-box QUESTION buttons YES-NO update glog.
IF not glog then return error.
/*пока нельзя перевыпускать карты пакетно - надо прописывать  d c a r d i 0 1.p параметры для логгирования diallog
пока там запускаетяс diallog ядл посылки на кассы перевыщенной и старой карты
*/
run str/diallog.w (
             input parparentproc
            ,input this-procedure
            ,input 'utl/discarun.p':U
            ,input
            (v-cntxt-obj-type + {&delim-par} +
             string(v-cntxt-obj-code) + {&delim-par} +
            (IF dc-status:sensitive     then (dc-status + {&comma-char} + string(ok-to-restore)) else "":U )     + {&delim-par} +
            (IF b-type:sensitive        then dc-type  else "":U )                                               + {&delim-par} +
            (IF b-type:sensitive        then string(dis-card-type.emitent-host-code)  else "":U )               + {&delim-par} +
            (IF d-pcnt:sensitive        then string(d-pcnt) else "")                                            + {&delim-par} +
            (IF cash-d-pcnt:sensitive   then string(cash-d-pcnt)  else "")                                      + {&delim-par} +
            (IF category:sensitive      then string(category)  else "")                                         + {&delim-par} +
            (IF issue-date:sensitive    then string(issue-date, "99/99/9999") else "")                          + {&delim-par} +
            (IF issue-code:sensitive    then string(issue-code)  else "")                                       + {&delim-par} +
            (IF credit-card:sensitive   then string(credit-card)  else "")                                      + {&delim-par} +
            (IF debet-card:sensitive    then string(debet-card) else "")                                        + {&delim-par} +
            (IF staff-card:sensitive    then string(staff-card) else "")                                        + {&delim-par} +
            (IF lim-kr:sensitive        then string(lim-kr) else "")                                            + {&delim-par} +
            (IF valid-from:sensitive    then string(valid-from, "99/99/9999") else "")                          + {&delim-par} +
            (IF valid-date:sensitive    then string(valid-date, "99/99/9999") else "")                          + {&delim-par} +
            (IF d-pcnt-method:sensitive then string(d-pcnt-method) else "":U)                                   + {&delim-par} +
            (IF cli-message:sensitive   then string(cli-message, "X(128)" ) else "") +
            {&delim-nws} +
            (IF dc-status:sensitive     then "yes" else "no":U)                                                 + {&delim-par} +
            (IF b-type:sensitive        then "yes" else "no":U)                                                 + {&delim-par} +
            (IF b-type:sensitive        then "yes" else "no":U)                                                 + {&delim-par} +
            (IF d-pcnt:sensitive        then "yes" else "no":U)                                                 + {&delim-par} +
            (IF cash-d-pcnt:sensitive   then "yes" else "no":U)                                                 + {&delim-par} +
            (IF category:sensitive      then "yes" else "no":U)                                                 + {&delim-par} +
            (IF issue-date:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
            (IF issue-code:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
            (IF credit-card:sensitive   then "yes" else "no":U)                                                 + {&delim-par} +
            (IF debet-card:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
            (IF staff-card:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
            (IF lim-kr:sensitive        then "yes" else "no":U)                                                 + {&delim-par} +
            (IF valid-from:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
            (IF valid-date:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
            (IF d-pcnt-method:sensitive then "yes" else "no":U)                                                 + {&delim-par} +
            (IF cli-message:sensitive   then "yes" else "no":U)
            )
            ,input no /*p-auto-go*/
            ,input "&Стоп"
            ,input 'Изменение ДК по списку') .

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
  DISPLAY cash-d-pcnt category d-pcnt d-pcnt-method valid-date issue-date
          valid-from issue-code debet-card staff-card credit-card lim-kr
          dc-status cli-message n-dc-type dc-type n-cash-d-pcnt n-category
          n-d-pcnt n-d-pcnt-method n-valid-date n-valid-from n-issue-date
          n-issue-code n-debet-card n-staff-card n-credit-card n-lim-kr
          n-dc-status n-cli-message
      WITH FRAME Dialog-Frame.
  ENABLE b-exit l-category l-cli-message l-credit-card l-d-pcnt l-d-pcnt-method
         l-dc-status l-dc-type l-debet-card l-issue-code l-issue-date l-lim-kr
         l-staff-card l-valid-date RECT-1 RECT-3 RECT-5 RECT-6 RECT-7
         l-cash-d-pcnt l-valid-from B-quit B-lst B-Help d-pcnt-method n-dc-type
         dc-type n-cash-d-pcnt n-category n-d-pcnt n-d-pcnt-method n-valid-date
         n-valid-from n-issue-date n-issue-code n-debet-card n-staff-card
         n-credit-card n-lim-kr n-dc-status n-cli-message
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  assign
    d-pcnt = ?
    cash-d-pcnt = ?
    category = ?
    .
  DISPLAY cash-d-pcnt d-pcnt category d-pcnt-method valid-date issue-date issue-code
          credit-card cli-message debet-card staff-card lim-kr dc-status n-dc-type dc-type n-cash-d-pcnt n-d-pcnt
          n-d-pcnt-method n-valid-date n-issue-date n-issue-code n-credit-card n-debet-card n-staff-card
          n-lim-kr n-dc-status n-cli-message
      WITH FRAME Dialog-Frame.
  ENABLE b-exit l-dc-type l-cash-d-pcnt l-category l-credit-card l-debet-card l-staff-card
          l-d-pcnt  l-lim-kr
         l-dc-status l-issue-code l-issue-date l-valid-date
         l-d-pcnt-method l-cli-message B-quit B-lst B-Help n-dc-type
         n-cash-d-pcnt n-d-pcnt n-d-pcnt-method n-valid-date
         n-issue-date n-issue-code n-credit-card n-lim-kr n-dc-status n-debet-card n-staff-card n-cli-message
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-type Dialog-Frame
PROCEDURE proc-b-type :
define variable var-rid-str as character no-undo.
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .

define buffer b_clients for ub.clients.
  run ref/dc-types.w (
                  input parparentproc
                ,input "":U /*p-mode*/
                ,input "b-sel":U
                ,input 0
                ,input 0
                ,input "":U
                ,input 0
                ,input-output  var-rid-str) .
  if var-rid-str = "" then return ERROR.
find first ub.dis-card-type no-lock where
              recid(ub.dis-card-type) = integer(var-rid-str) No-ERROR.
if not avail ub.dis-card-type then return ERROR.
if ub.dis-card-type.emitent-host-code = 0 then do:
end.
else do:
      find first b_clients No-LOCK WHERE
              b_clients.obj-type = {&cmp} and
              b_clients.obj-code = ub.dis-card-type.emitent-host-code No-ERROR.
      if not avail b_clients then return ERROR.
end.
{ gbl/objdpcnt.i
  ub.dis-card-type.type
  ub.dis-card-type.emitent-host-code
  0
  '':U
  0
  {&ddctr-def-pcnt}
  v-d-pcnt
}
{ gbl/objdpcnt.i
  ub.dis-card-type.type
  ub.dis-card-type.emitent-host-code
  0
  '':U
  0
  {&ddctr-def-pcnt}
  v-cash-d-pcnt
}
{ gbl/objdpcnt.i
  ub.dis-card-type.type
  ub.dis-card-type.emitent-host-code
  0
  '':U
  0
  {&ddctr-def-categ}
  v-categ
}
if v-d-pcnt = ? then do:
  v-d-pcnt = 0.
end.
if v-cash-d-pcnt = ? then do:
  v-cash-d-pcnt = 0.
end.
if v-categ = ? then do:
  v-categ = 0.
end.

display
ub.dis-card-type.type @ dc-type
ub.dis-card-type.emitent-host-code @ emitent-host-code
v-d-pcnt @ d-pcnt
v-cash-d-pcnt @ cash-d-pcnt
with frame {&frame-name}
.

if ub.dis-card-type.dflt-credit-card then do:
  APPLY   "mouse-select-click" TO l-credit-card.
  APPLY   "mouse-select-click" TO l-LIM-KR.
  CREDIT-CARD:SCREEN-VALUE = "YES".
  display
  ub.dis-card-type.lim-kr @ lim-kr
  with frame {&frame-name}.
end.
else do:
  APPLY   "right-mouse-click" TO credit-card.
  APPLY   "right-mouse-click" TO LIM-KR.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME