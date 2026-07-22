&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-fin-doc FOR ub.c-fin-doc.
DEFINE BUFFER X_c-fin-doc FOR ub.c-fin-doc.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_fin-doc FOR ub.fin-doc.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/03
Author: Bakhtadze Natalya
Creation date: 11/02/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .
/*{&all}
"one":U
{&deletion}
{&g___object}
*/

define input parameter p-host-code like ub.c-fin-doc.host-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-fin-doc-code like ub.c-fin-doc.fin-doc-code no-undo .

/*банки в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории платежей":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ gbl/movewidg.i }
{ str/lib-trn.i }
define variable filter-point as character no-undo init "fincdocs" .
define variable filter-point0 as character no-undo init "fincdocs" .
define variable filter-label as character no-undo init "Список истории платажей" .
define variable filter-label0 as character no-undo init "Список истории платежей" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable client-option as character no-undo.
define variable schet-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable is-cash-mode as logical no-undo init ?.
DEFINE VARIABLE v-fin-doc-shift-name-num AS CHARACTER NO-UNDO.
/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

DEFINE BUFFER X_cli-fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_obj FOR ub.clients.
DEFINE BUFFER X_contract FOR ub.contract.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
define buffer X_curr_sysconf for ub.sysconf.

{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-fin-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-fin-doc temp-changes

/* Definitions for BROWSE br-c-fin-doc                                  */
&Scoped-define FIELDS-IN-QUERY-br-c-fin-doc mark-string(recid(X_c-fin-doc), v-rid-list) X_c-fin-doc.host-code X_c-fin-doc.prn-doc-code X_c-fin-doc.doc-date get-shift(BUFFER X_c-fin-doc, OUTPUT v-fin-doc-shift-name-num) v-fin-doc-shift-name-num usrfulnf(X_c-fin-doc.user-name-doc) X_c-fin-doc.fin-doc-type X_c-fin-doc.status_ X_c-fin-doc.sum-doc get-currency(buffer X_c-fin-doc) usrfulnf(X_c-fin-doc.corr-user-name) X_c-fin-doc.corr-date string(X_c-fin-doc.corr-time, "hh:mm") X_c-fin-doc.fin-ext-doc-type X_c-fin-doc.perm-date usrfulnf(X_c-fin-doc.user-name-perm) X_c-fin-doc.pay-date usrfulnf(X_c-fin-doc.user-name-pl) X_c-fin-doc.fact-date usrfulnf(X_c-fin-doc.user-name-fact) if X_c-fin-doc.obj-code <> 0 then (X_c-fin-doc.obj-type + string(X_c-fin-doc.obj-code)) else "":U X_c-fin-doc.receiver-type + string(X_c-fin-doc.receiver-code) X_c-fin-doc.payer-type + string(X_c-fin-doc.payer-code) get-contract(buffer X_c-fin-doc) X_c-fin-doc.fin-doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-fin-doc X_c-fin-doc.prn-doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-br-c-fin-doc X_c-fin-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-c-fin-doc X_c-fin-doc
&Scoped-define SELF-NAME br-c-fin-doc
&Scoped-define QUERY-STRING-br-c-fin-doc FOR EACH X_c-fin-doc NO-LOCK
&Scoped-define OPEN-QUERY-br-c-fin-doc OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-c-fin-doc X_c-fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-fin-doc X_c-fin-doc


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-lookup B-client ~
B-schet B-print B-sch B-Help br-c-fin-doc ED-notes sch-prn-doc-code ~
sch-curr-code B-curr sch-doc-date sch-fact-date sch-pay-date sch-c-schet ~
RS-receiver-payer sch-r-schet sch-BIK sch-cli-code RS-cli-type sch-name ~
B-cli BR-changes mark-num f-poisk
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-prn-doc-code sch-curr-code ~
sch-doc-date sch-fact-date sch-pay-date sch-c-schet RS-receiver-payer ~
sch-r-schet sch-BIK sch-cli-code RS-cli-type sch-name mark-num f-poisk

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-contract Dialog-Frame
FUNCTION get-contract RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cashbookname Dialog-Frame
FUNCTION get-cashbookname RETURNS CHARACTER
  ( input icashbookid as int64 )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-shift Dialog-Frame
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_c-fin-doc FOR ub.c-fin-doc, OUTPUT p-shift-name-num AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-client
       MENU-ITEM receiver       LABEL "Получатель"
       MENU-ITEM payer          LABEL "Плательщик"    .

DEFINE MENU MENU-B-schet
       MENU-ITEM receiver-schet LABEL "Получатель"
       MENU-ITEM payer-schet    LABEL "Плательщик"    .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-client
     LABEL "&Контраг."
     SIZE 10 BY 1.

DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-schet
     LABEL "&Счета"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-poisk AS CHARACTER FORMAT "X(256)":U INITIAL "ПОИСК ПО:"
      VIEW-AS TEXT
     SIZE 9.6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-c-schet AS CHARACTER FORMAT "X(9)":U
     LABEL "Корр.счет"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "код"
     VIEW-AS FILL-IN
     SIZE 11 BY .93 NO-UNDO.

DEFINE VARIABLE sch-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "коду вал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE sch-doc-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате док-та"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-fact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате факт."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(35)":U
     LABEL "нач.назв."
     VIEW-AS FILL-IN
     SIZE 31 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-pay-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате плат."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-prn-doc-code AS CHARACTER FORMAT "X(16)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(35)":U
     LABEL "Расч.счет"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RS-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 14.1 BY 1.03 NO-UNDO.

DEFINE VARIABLE RS-receiver-payer AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 26.8 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-fin-doc FOR
      X_c-fin-doc SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-fin-doc Dialog-Frame _FREEFORM
  QUERY br-c-fin-doc DISPLAY
      mark-string(recid(X_c-fin-doc), v-rid-list) FORMAT "X(1)":U
      X_c-fin-doc.host-code COLUMN-LABEL "Код!фирмы" FORMAT "999999999":U
      X_c-fin-doc.prn-doc-code FORMAT "X(16)":U
      X_c-fin-doc.doc-date FORMAT "99/99/9999":U
      get-shift(BUFFER X_c-fin-doc, OUTPUT v-fin-doc-shift-name-num) COLUMN-LABEL "Дата!смены"
      v-fin-doc-shift-name-num COLUMN-LABEL "Смена" format "X(6)"
      usrfulnf(X_c-fin-doc.user-name-doc) COLUMN-LABEL "Создал" FORMAT "X(8)":U
      X_c-fin-doc.fin-doc-type FORMAT "X(8)":U
      X_c-fin-doc.status_ FORMAT "X(8)":U
      X_c-fin-doc.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
      get-currency(buffer X_c-fin-doc) COLUMN-LABEL "Вал" FORMAT "X(3)":U
      usrfulnf(X_c-fin-doc.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(8)":U
      X_c-fin-doc.corr-date FORMAT "99/99/9999":U
      string(X_c-fin-doc.corr-time, "hh:mm") COLUMN-LABEL "Время коррекц"
      X_c-fin-doc.fin-ext-doc-type COLUMN-LABEL "Расш.тип" FORMAT "X(8)":U
      X_c-fin-doc.perm-date FORMAT "99/99/9999":U
      usrfulnf(X_c-fin-doc.user-name-perm) COLUMN-LABEL "Закрыл!на разр" FORMAT "X(8)":U
      X_c-fin-doc.pay-date COLUMN-LABEL "Дата платежа!(пост.в банк)" FORMAT "99/99/9999":U
      usrfulnf(X_c-fin-doc.user-name-pl) COLUMN-LABEL "Закрыл!на опл" FORMAT "X(8)":U
      X_c-fin-doc.fact-date FORMAT "99/99/9999":U
      usrfulnf(X_c-fin-doc.user-name-fact) COLUMN-LABEL "Закрыл!на факт" FORMAT "X(8)":U
      if X_c-fin-doc.obj-code <> 0 then (X_c-fin-doc.obj-type + string(X_c-fin-doc.obj-code)) else "":U COLUMN-LABEL "Объект" FORMAT "X(8)":U
      X_c-fin-doc.receiver-type + string(X_c-fin-doc.receiver-code) COLUMN-LABEL "Получатель" FORMAT "X(12)":U
      X_c-fin-doc.payer-type + string(X_c-fin-doc.payer-code) COLUMN-LABEL "Плательщик" FORMAT "X(12)":U
      get-contract(buffer X_c-fin-doc) COLUMN-LABEL "Договор" FORMAT "X(16)":U
      X_c-fin-doc.fin-doc-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
      get-CashbookName(X_c-fin-doc.cashbookid) COLUMN-LABEL "Кассовая книга" FORMAT "x(30)":U
  ENABLE
      X_c-fin-doc.prn-doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7.37.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 41
     B-client AT ROW 1 COL 51
     B-schet AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-c-fin-doc AT ROW 2 COL 1.4
     ED-notes AT ROW 9.5 COL 1 NO-LABEL
     sch-prn-doc-code AT ROW 11.57 COL 88.6 COLON-ALIGNED
     sch-curr-code AT ROW 12.57 COL 9 COLON-ALIGNED
     B-curr AT ROW 12.57 COL 15.5
     sch-doc-date AT ROW 12.57 COL 38.1 COLON-ALIGNED
     sch-fact-date AT ROW 12.57 COL 62 COLON-ALIGNED
     sch-pay-date AT ROW 12.57 COL 86 COLON-ALIGNED
     sch-c-schet AT ROW 13.77 COL 40.9 COLON-ALIGNED
     RS-receiver-payer AT ROW 13.8 COL 1.6 NO-LABEL
     sch-r-schet AT ROW 13.8 COL 75.3 COLON-ALIGNED
     sch-BIK AT ROW 14.93 COL 7.5 COLON-ALIGNED
     sch-cli-code AT ROW 14.93 COL 26 COLON-ALIGNED
     RS-cli-type AT ROW 14.93 COL 39.6 NO-LABEL
     sch-name AT ROW 14.93 COL 66.3 COLON-ALIGNED
     B-cli AT ROW 14.97 COL 54.5
     BR-changes AT ROW 16.03 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     f-poisk AT ROW 11.77 COL 70.9 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     SPACE(16.80) SKIP(9.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список истории платежей"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-fin-doc B "?" ? ub c-fin-doc
      TABLE: X_c-fin-doc B "?" ? ub c-fin-doc
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_fin-doc B "?" ? ub fin-doc
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-fin-doc B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes B-cli Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-client:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-client:HANDLE.

ASSIGN
       B-schet:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-schet:HANDLE.

ASSIGN
       br-c-fin-doc:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-fin-doc
/* Query rebuild information for BROWSE br-c-fin-doc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-doc NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-c-fin-doc FOR
                X_c-fin-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE br-c-fin-doc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Список истории платежей */
DO:
    run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список истории платежей */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w ( parParentProc
                  , "b-sel"
                  , RS-cli-type
                  , ?
                  , ?
                  , ?
                  , ?
                  , "without-obj":U
                  , output ref-list) .
    if ref-list = "" then   do:
      apply "entry" to b-cli in frame {&frame-name}.
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
    if NOT (buf_clients.obj-type = {&cmp}
            or
            buf_clients.obj-type = {&prs} ) then do:
      message
      "Выберите контрагента типа" {&cmp} "или" {&prs}
      view-as alert-box error .
      return no-apply.
    end.
    assign
    RS-cli-type =  buf_clients.obj-type
    sch-cli-code = buf_clients.obj-code
    .
    display
    RS-cli-type
    sch-cli-code
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-client Dialog-Frame
ON CHOOSE OF B-client IN FRAME Dialog-Frame /* Контраг. */
DO:
define variable v-rid-list as character no-undo.
if not available X_c-fin-doc then return no-apply.

if client-option = '':U then do:
        run gbl/pop-up.p (self:handle, no) no-error.
end.
if client-option = '':U then return no-apply.

  run ref/showcli.p (input parParentProc
               ,(if client-option = "receiver" then X_c-fin-doc.receiver-type else X_c-fin-doc.payer-type)
               , (if client-option = "receiver" then X_c-fin-doc.receiver-code else X_c-fin-doc.payer-code)
                                ) no-error.
 client-option = '':U.
 APPLY "ENTRY" to br-c-fin-doc.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-curr Dialog-Frame
ON CHOOSE OF B-curr IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable rr as recid no-undo.
define buffer buf_currency for ub.currency.
    rr = ? .
    run ref/currency.w (parparentproc, "b-sel", input-output rr ).
    if rr <> ? then do:
        FIND FIRST buf_currency WHERE
             recid( buf_currency ) = rr NO-LOCK .
        DISPLAY
        buf_currency.curr-code @ sch-curr-code
        with frame {&frame-name} .
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
if not available X_c-fin-doc then return no-apply.
run proc-b-lookup in this-procedure no-error.
if error-status:error then do:
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-fin-doc then do:
    { gbl/markstrn.i X_c-fin-doc v-rid-list }
    loc#log = br-c-fin-doc:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-fin-doc:select-next-row ().
        apply "VALUE-CHANGED" to br-c-fin-doc in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-fin-doc in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-c-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-schet Dialog-Frame
ON CHOOSE OF B-schet IN FRAME Dialog-Frame /* Счета */
DO:
define variable loc-doc-rec as recid no-undo.
if not available X_c-fin-doc then return no-apply.

if schet-option = '':U then do:
  run gbl/pop-up.p (self:handle, no) no-error.
end.
if schet-option = '':U then return no-apply.
&scop fin-doc-type-code X_c-fin-doc.fin-doc-type
if X_c-fin-doc.fin-doc-type = {&income-cash}
or X_c-fin-doc.fin-doc-type = {&expense-cash}
or X_c-fin-doc.fin-doc-type = {&income-payoff}
or X_c-fin-doc.fin-doc-type = {&expense-payoff}
then do:
  message
  "Нельзя посмотреть счет по платежу" skip
  "платеж имеет тип" {&fin-doc-type-name}
  view-as alert-box.
  return no-apply.
end.
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code /*p-curr-host-code*/
                ,input {&lookup}
                ,input X_c-fin-doc.host-code
                ,input (if schet-option = "payer-schet":U
                        then X_c-fin-doc.payer-code-schet
                        else X_c-fin-doc.receiver-code-schet )
                ,input 0 /*p-code-bank*/
                ,input (if schet-option = "payer-schet":U
                       then X_c-fin-doc.payer-type
                       else X_c-fin-doc.receiver-type)
                ,input (if schet-option = "payer-schet":U
                       then X_c-fin-doc.payer-code
                       else X_c-fin-doc.receiver-code)
                ,input X_fin-doc.curr-code
                ,input-output loc-doc-rec
                            )
.
 schet-option = '':U.
 APPLY "ENTRY" to br-c-fin-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-fin-doc ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_c-fin-doc ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-fin-doc
&Scoped-define SELF-NAME br-c-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-fin-doc Dialog-Frame
ON RETURN OF br-c-fin-doc IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-fin-doc IN FRAME Dialog-Frame
DO:
  run proc-br-c-fin-doc no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-fin-doc Dialog-Frame
ON VALUE-CHANGED OF br-c-fin-doc IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-fin-doc then X_c-fin-doc.ps else '':U.
  ED-notes:screen-value = dops.
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-doc for ub.fin-doc.
  if not available X_c-fin-doc then return no-apply.

   DO on stop undo, return no-apply:
      FIND PS_fin-doc where
           recid (ps_fin-doc) = recid(X_c-fin-doc) exclusive.
      if ps_fin-doc.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_fin-doc.PS = input frame {&frame-name} ed-notes
      .
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME payer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL payer Dialog-Frame
ON CHOOSE OF MENU-ITEM payer /* Плательщик */
DO:
    assign
  client-option = "payer":U.
  APPLY "CHOOSE" to b-client in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME payer-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL payer-schet Dialog-Frame
ON CHOOSE OF MENU-ITEM payer-schet /* Плательщик */
DO:
    assign
  schet-option = "payer":U.
  APPLY "CHOOSE" to b-schet in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL receiver Dialog-Frame
ON CHOOSE OF MENU-ITEM receiver /* Получатель */
DO:
  assign
  client-option = "receiver":U.
  APPLY "CHOOSE" to b-client in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME receiver-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL receiver-schet Dialog-Frame
ON CHOOSE OF MENU-ITEM receiver-schet /* Получатель */
DO:
  assign
  schet-option = "receiver":U.
  APPLY "CHOOSE" to b-schet in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli-type Dialog-Frame
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-receiver-payer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-receiver-payer Dialog-Frame
ON VALUE-CHANGED OF RS-receiver-payer IN FRAME Dialog-Frame
DO:
  assign
  Rs-receiver-payer.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-BIK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure(yes, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON RETURN OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure(no, input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-c-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON CTRL-J OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счет */
DO:
  run proc-find-c-schet in this-procedure(yes, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON RETURN OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счет */
DO:
  run proc-find-c-schet in this-procedure(no, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame /* код */
DO:
  run proc-find-cli-code in this-procedure(yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame /* код */
DO:
  run proc-find-cli-code in this-procedure(yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-curr-code Dialog-Frame
ON CTRL-J OF sch-curr-code IN FRAME Dialog-Frame /* коду вал */
DO:
  run proc-find-curr-code in this-procedure(yes, input frame {&frame-name} sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-curr-code Dialog-Frame
ON RETURN OF sch-curr-code IN FRAME Dialog-Frame /* коду вал */
DO:
   run proc-find-curr-code in this-procedure(no, input frame {&frame-name} sch-curr-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-doc-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-doc-date Dialog-Frame
ON CTRL-J OF sch-doc-date IN FRAME Dialog-Frame /* Дате док-та */
DO:
   run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-doc-date Dialog-Frame
ON RETURN OF sch-doc-date IN FRAME Dialog-Frame /* Дате док-та */
DO:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact-date Dialog-Frame
ON CTRL-J OF sch-fact-date IN FRAME Dialog-Frame /* Дате факт. */
DO:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-fact-date, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact-date Dialog-Frame
ON RETURN OF sch-fact-date IN FRAME Dialog-Frame /* Дате факт. */
DO:
    run proc-find-date in this-procedure(no, input frame {&frame-name} sch-fact-date, "fact-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame /* нач.назв. */
DO:
  run proc-find-name in this-procedure(yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame /* нач.назв. */
DO:
  run proc-find-name in this-procedure(no, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-pay-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-pay-date Dialog-Frame
ON RETURN OF sch-pay-date IN FRAME Dialog-Frame /* Дате плат. */
DO:
    run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-pay-date, "pay-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-prn-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-prn-doc-code Dialog-Frame
ON CTRL-J OF sch-prn-doc-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-prn-doc-code in this-procedure(yes, input frame {&frame-name} sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-prn-doc-code Dialog-Frame
ON RETURN OF sch-prn-doc-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-prn-doc-code in this-procedure(no, input frame {&frame-name} sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-r-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счет */
DO:
  run proc-find-r-schet in this-procedure(yes, input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счет */
DO:
  run proc-find-r-schet in this-procedure(no, input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-c-fin-doc" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-fin-doc). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-c-fin-doc to recid v-doc-rec no-error. v-doc-rec = ?. " }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name = "br-c-fin-doc"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-fin-doc.prn-doc-code"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/brwrepos.i
  &browse-name = "br-c-fin-doc"
  &line-num=5
}

{ gbl/ed_date.i sch-doc-date }
{ gbl/ed_date.i sch-pay-date }
{ gbl/ed_date.i sch-fact-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  find first X_curr_sysconf no-lock where
                  X_curr_sysconf.host-code = p-curr-host-code no-error.
  if not available X_curr_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return.
  end.

 if LOOKUP(p-mode, ({&all} + {&delim-par} +
                    "One":U + {&delim-par} +
                    {&deletion} + {&delim-par} +
                    {&g___object}),
          {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.

find first X_clients-host no-lock where
            X_clients-host.obj-type = {&cmp}
        and X_clients-host.obj-code = p-host-code no-error.
if not available X_clients-host then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code"
    p-host-code
    view-as alert-box ERROR.
    return.
end.
if LOOKUP({&all}, p-mode, {&delim-par}) > 0
or LOOKUP({&g___object}, p-mode, {&delim-par}) > 0
or LOOKUP({&deleted}, p-mode, {&delim-par}) > 0
then do:
  assign is-cash-mode = no.
end.
if lookup({&g___object}, p-mode, {&delim-par} ) > 0 then do:
  find first X_obj no-lock where
          X_obj.obj-type = p-obj-type
      and X_obj.obj-code = p-obj-code no-error.
  if not available x_OBJ then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-obj-type/p-obj-code"
    p-obj-type p-obj-code
    view-as alert-box ERROR.
    return.
  end.
end.
if LOOKUP("one":U, p-mode, {&delim-par}) > 0 then do:
  find first X_fin-doc no-lock where
              X_fin-doc.host-code = p-host-code
          AND X_fin-doc.fin-doc-code = p-fin-doc-code no-error .
  if not available X_fin-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code и/или p-fin-doc-code"
    p-host-code p-fin-doc-code
    view-as alert-box ERROR.
    return.
  end.
  assign
  is-cash-mode =  (X_fin-doc.fin-doc-type = {&income-cash}
                    OR X_fin-doc.fin-doc-type = {&expense-cash})
  .

  find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code no-error.
  if not available X_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code"
    p-host-code
    view-as alert-box ERROR.
    return.
  end.
end.
v-rid-list = p-rid-list.
if v-rid-list <> "" then do:
    FIND FIRST find_c-fin-doc No-LOCK where
                recid(find_c-fin-doc) = integer(entry(1, v-rid-list)) No-ERROR.
    if not avail find_c-fin-doc then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова v-rid-list" v-rid-list
      view-as alert-box error .
      return error.
    end.
    v-doc-rec = integer(entry(1, v-rid-list)).
  end.
{ gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-c-fin-doc to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-c-fin-doc"
    &frame-name = "{&frame-name}"
    &ext-col = 26
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 =  "'1,12,13,14,3,4,5,6,7,10,11,15,16,17,18,19,20,21,22,23,24,25,26,2,8,9'"
    &prev-order-column-condition_2 = " p-mode = 'one':U "
    &prev-order-column_3 = "'1,2,3,4,5,6,7,12,13,14,8,9,10,11,15,16,17,18,19,20,21,22,23,24,25,26'"
    &prev-order-column-condition_3 = " p-mode = ~{&deletion~} or p-mode = ~{&g___object~} "

    }
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
  run diasize_init in this-procedure .
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
  DISPLAY ED-notes sch-prn-doc-code sch-curr-code sch-doc-date sch-fact-date
          sch-pay-date sch-c-schet RS-receiver-payer sch-r-schet sch-BIK
          sch-cli-code RS-cli-type sch-name mark-num f-poisk
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lookup B-client B-schet B-print B-sch B-Help
         br-c-fin-doc ED-notes sch-prn-doc-code sch-curr-code B-curr
         sch-doc-date sch-fact-date sch-pay-date sch-c-schet RS-receiver-payer
         sch-r-schet sch-BIK sch-cli-code RS-cli-type sch-name B-cli BR-changes
         mark-num f-poisk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
  b-print:MENU-MOUSE in frame {&frame-name} = 1
  b-client:MENU-MOUSE in frame {&frame-name} = 1
  b-schet:MENU-MOUSE in frame {&frame-name} = 1
  br-c-fin-doc:num-locked-columns = 1
  X_c-fin-doc.prn-doc-code:read-only in browse br-c-fin-doc = yes
  RS-cli-type:radio-buttons = {&CMp} + {&comma-char} + {&cmp} + {&comma-char} + {&prs} + {&comma-char} + {&prs}
  RS-receiver-payer:radio-buttons = "Получатель" + {&comma-char} + "receiver":U + {&comma-char} + "Плательщик" + {&comma-char} + "payer":U
  temp-changes.l_name:resizable in browse br-changes = true
  temp-changes.v_old:resizable in browse br-changes = true
  temp-changes.v_new:resizable in browse br-changes = true
  temp-changes.l_name:width in browse br-changes = 30
  temp-changes.v_old:width in browse br-changes = 40
  temp-changes.v_new:width in browse br-changes = 40
  .
  DISPLAY
  ED-notes
  sch-prn-doc-code
  sch-cli-code
  sch-c-schet when not is-cash-mode
  sch-curr-code
  sch-doc-date
  sch-fact-date
  sch-pay-date
  sch-r-schet when not is-cash-mode
  sch-BIK when not is-cash-mode
  sch-name
  mark-num
  RS-cli-type
  RS-receiver-payer
  WITH FRAME {&frame-name}.
  ENABLE
  b-quit
  B-lookup
  b-sel when lookup("b-sel":U, bttns) > 0
  B-mark when lookup("b-mark":U, bttns) > 0
  B-sch
  B-print
  B-client
  B-schet
  B-Help
  br-c-fin-doc
  br-changes when p-mode <> {&deletion}
  b-curr
  b-cli
  ED-notes
  sch-prn-doc-code
  sch-cli-code
  sch-c-schet  when not is-cash-mode
  sch-curr-code
  sch-doc-date
  sch-fact-date
  sch-pay-date
  sch-r-schet  when not is-cash-mode
  sch-BIK when not is-cash-mode
  sch-name
  mark-num
  RS-cli-type
  RS-receiver-payer
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  if is-cash-mode then do:
    hide
    sch-bik
    sch-r-schet
    sch-c-schet
    in frame {&frame-name} .
  end.
  if p-mode = {&deletion} then do:
     define variable v-height as decimal no-undo .
     assign
     v-height = br-changes:height
     browse br-c-fin-doc:height = browse br-c-fin-doc:height + v-height
     .
     run movewidg_up-down ( input frame {&frame-name}:handle
                           ,input "b-schet,b-curr,b-client,b-cli,ED-notes,sch-prn-doc-code,sch-cli-code,sch-c-schet,sch-curr-code,sch-doc-date,sch-fact-date,sch-pay-date,sch-r-schet,sch-BIK,sch-name,RS-cli-type,RS-receiver-payer,f-poisk"
                           ,input v-height
                           )
     .
     hide
     br-changes in frame {&frame-name} .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable title0 as character no-undo.
define variable v-filter-name as character no-undo .
title0 = "Список истории платежей" + {&space-char}.
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query OPEN QUERY br-c-fin-doc FOR EACH X_c-fin-doc

&scop flt-open-dyn_open-query FOR EACH X_c-fin-doc

&scop flt-open-query-handle QUERY br-c-fin-doc:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-fin-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer X_c-fin-doc for c-fin-doc.

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + p-mode.

CASE p-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-label = substitute("&1", filter-label0).
    { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }
  END.
  WHEN "one":U        THEN DO:
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Фирма: (&1) &2 Платеж &3 &4",
                                        p-host-code, X_clients-host.obj-name,  X_fin-doc.fin-doc-type, X_fin-doc.prn-doc-code)
      .
    end.
    filter-label = substitute("&1 Одна фирма", filter-label0)
    .

    { gbl/fltopend.i
        &where-cond = " X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.fin-doc-code  = p-fin-doc-code "
        &dyn_where-cond = " substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.fin-doc-code  = &2 ', p-host-code, p-fin-doc-code)"
        &use-ind    = "  "
        &by         = "  " }
  END.
  WHEN {&deletion}        THEN DO:
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Фирма: (&1) &2 - платежи, удаленные в статусе &3",
                                        p-host-code, X_clients-host.obj-name,  {&fact}).
    end.
    filter-label = substitute("&1 Удаленные в статусе ФАКТ", filter-label0)
                                      .
    { gbl/fltopend.i
      &where-cond = " X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes "
      &dyn_where-cond = " substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes ', p-host-code)"
      &use-ind    = "  "
      &by         = "  " }
  END.
  WHEN {&g___object}        THEN DO:
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Фирма: (&1) &2 &3&4 - платежи, удаленные в статусе &5",
                                        p-host-code, X_clients-host.obj-name,  X_obj.obj-type, x_obj.obj-code, {&fact}).
    end.
    filter-label = substitute("&1 Удаленные в статусе ФАКТ", filter-label0)
                                      .
    { gbl/fltopend.i
      &where-cond = " X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes ~
                     and X_c-fin-doc.obj-type = p-obj-type  and X_c-fin-doc.obj-code = p-obj-code "
      &dyn_where-cond = " substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes ~
                                     and X_c-fin-doc.obj-type = &2&3&2 ~
                                     and X_c-fin-doc.obj-code = &4', p-host-code, ~{&double-quote~}, p-obj-type, p-obj-code )"
      &use-ind    = "  "
      &by         = "  " }
  END.

END CASE.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-c-fin-doc to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-fin-doc:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-c-fin-doc in frame {&frame-name}.
APPLY "ENTRY" TO br-c-fin-doc.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lookup Dialog-Frame
PROCEDURE proc-b-lookup :
run ref/shwcfind.p (
                    input parParentProc
                   ,input p-curr-host-code
                   ,input X_c-fin-doc.host-code /*p-host-code*/
                   ,input X_c-fin-doc.fin-doc-code
                   ,input X_c-fin-doc.corr-user-db-num
                   ,input X_c-fin-doc.chip-num).
apply "entry" to br-c-fin-doc in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run proc-print-list no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'c-fin-doc'
  join-tbl = 'X_c-fin-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('fin-doc-code', 'Вн.№ платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Вн.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Закрыл на факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('perm-date', 'Дата разр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-perm', 'Закрыл на разр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-pl', 'Закрыл на опл', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure('fin-doc-type', 'Тип документа', 'fin-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fin-ext-doc-type', 'Расширен. тип документа', 'fin-ext-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', 'fin-doc-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-doc', 'Сумма в валюте платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-base', 'Сумма в баз.вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-rubl', 'Сумма в {&abbr_rublyah}', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc', 'Внутр. код корреспонд.счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc-value', 'Корреспонд.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc1', 'Внутр. код корреспонд.счета2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc1-value', 'Корреспонд.счет2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('an-uchet-code', 'Внутр код анал.учета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('an-uchet-value', 'Код анал.учета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cel-nazn-code', 'Внутр. код целевого назначения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cel-nazn-value', 'Код целевого назначения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('vid-plat', 'Вид платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('stat-pl', 'Статус плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('vid-opl', 'Вид операции', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nazn-pl', 'Назначение платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nazn-pl', 'Срок платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ocher-pl', 'Очередность платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('receiver-type{&delim-flt}receiver-code', 'Получатель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-name', 'Название получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bik', 'БИК получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-inn', '{&abbr_inn_allshift} получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-kpp', '{&abbr_kpp_allshift} получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bank-name', 'Банк получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bank-city', 'Город банка получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-r-schet', 'Расч.счет получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-c-schet', 'Корр.счет получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-code-schet', 'Код счета получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-type{&delim-flt}payer-code', 'Плательщик', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-name', 'Название плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bik', 'БИК плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-inn', '{&abbr_inn_allshift} плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-kpp', '{&abbr_kpp_allshift} плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bank-name', 'Банк плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bank-city', 'Город банка плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-r-schet', 'Расч.счет плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-c-schet', 'Корр.счет плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-code-schet', 'Код счета плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-c-fin-doc Dialog-Frame
PROCEDURE proc-br-c-fin-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { ref/brwsretr.i }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-bik Dialog-Frame
PROCEDURE proc-find-bik :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.fin-doc.receiver-bik no-undo.
assign
frame {&frame-name} Rs-receiver-payer.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame {&frame-name}.
if not is-cash-mode then
display
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame {&frame-name} .
assign
p-bik = replace(p-bik, {&double-quote}, "":U)
p-bik = replace(p-bik, {&single-quote}, {&single-quote} + {&single-quote})
p-bik = {&double-quote} + p-bik + {&double-quote}.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.receiver-bik   begins &1 "
      , p-bik)
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.payer-bik   begins &1 "
      , p-bik)
    ).
end.
apply "entry":u to sch-bik in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-c-schet Dialog-Frame
PROCEDURE proc-find-c-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-c-schet like ub.fin-schet.c-schet no-undo.
assign
frame {&frame-name} RS-receiver-payer .
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame {&frame-name}.
if not is-cash-mode then
display
"":U @ sch-BIK
"":U @ sch-r-schet
with frame {&frame-name}.
assign
p-c-schet = replace(p-c-schet, {&double-quote}, "":U)
p-c-schet = replace(p-c-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-c-schet = {&double-quote} + p-c-schet + {&double-quote}.
if rs-receiver-payer = "receiver":U then do:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_c-fin-doc.receiver-c-schet   begins &1 "
          , p-c-schet)
        ).
end.
if Rs-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.payer-c-schet   begins &1 "
      , p-c-schet)
    ).
end.

apply "entry":u to sch-c-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-cli-code Dialog-Frame
PROCEDURE proc-find-cli-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo.
define variable v-cli-code as character no-undo.
assign
frame {&frame-name} RS-cli-type .
assign
frame {&frame-name} Rs-receiver-payer.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
"":U @ sch-bik
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame {&frame-name}.
assign
v-cli-code = string(p-cli-code)
.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.receiver-type = '&1' and X_c-fin-doc.receiver-code = &2"
      , RS-cli-type, v-cli-code )
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.payer-type = '&1' and X_c-fin-doc.payer-code = &2"
      , RS-cli-type, v-cli-code )
    ).
end.

apply "entry":u to sch-cli-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-curr-code Dialog-Frame
PROCEDURE proc-find-curr-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo.
define variable v-curr-code-chr as character no-undo.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
with frame {&frame-name}.
assign
v-curr-code-chr = string(p-curr-code)
.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.curr-code = &1 "
      , v-curr-code-chr)
    ).
apply "entry":u to sch-curr-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
0 @ sch-curr-code
"":U @ sch-prn-doc-code
"":U @ sch-r-schet
with frame {&frame-name}.

CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-pay-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-pay-date
      with frame {&frame-name}.
    end.
    when "fact-date":U then do:
      assign
      sch-doc-date = ?
      sch-pay-date = ?
      .
      display
      sch-doc-date
      sch-pay-date
      with frame {&frame-name}.
    end.
    when "pay-date":U then do:
      assign
      sch-doc-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-doc-date
      with frame {&frame-name}.
    end.
END CASE.

assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

CASE p-what-date:
    when "doc-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-fin-doc.doc-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-doc-date in frame {&frame-name}.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-fin-doc.fact-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-fact-date in frame {&frame-name}.
    end.
        when "pay-date":U then do:
       run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input true  /* p-find-next  */
        ,input substitute("and X_c-fin-doc.pay-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-pay-date in frame {&frame-name}.
    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame
PROCEDURE proc-find-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-name as character no-undo.
assign
frame {&frame-name} Rs-receiver-payer.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
0 @ sch-cli-code
"":U @ sch-bik
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame {&frame-name}.
assign
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.receiver-name   begins &1 "
      , p-name)
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.payer-name   begins &1 "
      , p-name)
    ).
end.


apply "entry":u to sch-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-prn-doc-code Dialog-Frame
PROCEDURE proc-find-prn-doc-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-prn-doc-code like ub.fin-doc.prn-doc-code no-undo.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
with frame {&frame-name}.
assign
  p-prn-doc-code = replace(p-prn-doc-code, {&single-quote}, {&single-quote} + {&single-quote})
.

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.prn-doc-code = '&1' "
      , p-prn-doc-code)
    ).
apply "entry":u to sch-prn-doc-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-r-schet Dialog-Frame
PROCEDURE proc-find-r-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-r-schet like ub.fin-schet.r-schet no-undo.
assign
frame {&frame-name} RS-receiver-payer .
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame {&frame-name}.
display
"":U @ sch-BIK
"":U @ sch-c-schet
with frame {&frame-name}.
assign
p-r-schet = replace(p-r-schet, {&double-quote}, "":U)
p-r-schet = replace(p-r-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-r-schet = {&double-quote} + p-r-schet + {&double-quote}.
if rs-receiver-payer = "receiver":U then do:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_c-fin-doc.receiver-r-schet   begins &1 "
          , p-r-schet)
        ).
end.
if Rs-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-doc.payer-r-schet   begins &1 "
      , p-r-schet)
    ).
end.

apply "entry":u to sch-r-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame
PROCEDURE proc-print-list :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-receiver as character no-undo.
define variable v-payer as character no-undo.
define variable v-contract as character no-undo.
define variable v-curr-abbr as character no-undo.
define variable v-obj as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.

run rep/g-fin-doc-list.p (parParentProc) no-error.

/*
DEFINE FRAME c-fin-doc-list
X_c-fin-doc.host-code COLUMN-LABEL "Код!фирмы"
X_c-fin-doc.prn-doc-code FORMAT "X(16)"
v-receiver /*   X_c-fin-doc.receiver-type + string(X_c-fin-doc.receiver-code) */ COLUMN-LABEL "Получатель" FORMAT "X(12)"
X_c-fin-doc.receiver-name COLUMN-LABEL "Назв.!получателя" FORMAT "X(17)"
v-contract /*  get-contract(buffer X_c-fin-doc) */ COLUMN-LABEL "Договор" FORMAT "X(16)"
X_c-fin-doc.fin-doc-type format "X(3)"
X_c-fin-doc.doc-date
X_c-fin-doc.fin-ext-doc-type COLUMN-LABEL "Расш.!тип" format "X(3)"
X_c-fin-doc.perm-date COLUMn-LABEL "Дата разр"
X_c-fin-doc.pay-date  COLUMn-LABEL "Дата прин!банком"
X_c-fin-doc.fact-date COLUMn-LABEL "Дата факт"
X_c-fin-doc.status_
X_c-fin-doc.sum-doc
v-payer /*X_c-fin-doc.payer-type + string(X_c-fin-doc.payer-code) */ COLUMN-LABEL "Плательщик" FORMAT "X(12)"
X_c-fin-doc.payer-name COLUMN-LABEL "Назв.!плательщика" FORMAT "X(16)"
v-curr-abbr /*get-currency(buffer X_c-fin-doc) */ COLUMN-LABEL "Вал" FORMAT "X(3)"
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME c-fin-doc-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(X_c-fin-doc).
DO WHILE available X_c-fin-doc :
  GET prev br-c-fin-doc.
END.
GET next br-c-fin-doc.
DO WHILE available X_c-fin-doc :
  Display STREAM PrnLibStream
X_c-fin-doc.host-code
X_c-fin-doc.prn-doc-code
string( X_c-fin-doc.receiver-type + string(X_c-fin-doc.receiver-code)) @ v-receiver
X_c-fin-doc.receiver-name
get-contract(buffer X_c-fin-doc) @ v-contract
X_c-fin-doc.fin-doc-type
X_c-fin-doc.doc-date
X_c-fin-doc.fin-ext-doc-type
X_c-fin-doc.perm-date
X_c-fin-doc.fact-date
X_c-fin-doc.pay-date
X_c-fin-doc.status_
X_c-fin-doc.sum-doc
string(X_c-fin-doc.payer-type + string(X_c-fin-doc.payer-code)) @ v-payer
X_c-fin-doc.payer-name
get-currency(buffer X_c-fin-doc) @ v-curr-abbr
(if X_c-fin-doc.obj-code > 0 then (X_c-fin-doc.obj-type + string(X_c-fin-doc.obj-code)) else "":U) @ v-obj
  with FRAME c-fin-doc-list .
  DOWN STREAM PrnLibStream 1
  with FRAME c-fin-doc-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-c-fin-doc.
END.
UNDERLINE  STREAM PrnLibStream
X_c-fin-doc.host-code
X_c-fin-doc.prn-doc-code
v-receiver
X_c-fin-doc.receiver-name
v-contract
X_c-fin-doc.fin-doc-type
X_c-fin-doc.doc-date
X_c-fin-doc.fin-ext-doc-type
X_c-fin-doc.fact-date
X_c-fin-doc.pay-date
X_c-fin-doc.status_
X_c-fin-doc.sum-doc
v-payer
X_c-fin-doc.payer-name
v-curr-abbr
v-obj
with FRAME c-fin-doc-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_c-fin-doc.host-code
accum-count @ X_c-fin-doc.prn-doc-code
with frame c-fin-doc-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME c-fin-doc-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-c-fin-doc to recid v-doc-rec no-error.
APPLY "entry" to br-c-fin-doc.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
*/                                          
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-fin-doc then do:
  Open QUery br-changes for each temp-changes.
  return.
end.


&scop fields-name-list ~
"actual-base-rate,actual-base-scale,actual-exch-rate,actual-exch-scale,an-uchet-code," + ~
"base-rate,base-scale,cel-nazn-code,contract-curr,contract-code," + ~
"contract-rate,contract-scale,con-stat,con-sum-base,con-sum-rubl," +  ~
"cor-acc,cor-acc1,curr-code,doc-date,enclosure,exch-rate,exch-scale," + ~
"f104,f105,f106,f107,f108,f109,f110," + ~
"f22,f23,fact-date,fin-doc-code,fin-doc-type,fin-ext-doc-type,host-code,in-doc-code,in-host-code,including,is-back-date," + ~
"is-corr,is-del,nazn-pl,naznach-plat,obj-type,obj-code,ocher-pl,out-doc-code,out-host-code," + ~
"pay-date,payer-bank-name,payer-bank-city,payer-bik,payer-c-schet,payer-code," + ~
"payer-code-schet,payer-dop1,payer-dop2,payer-dop3,payer-dop4,payer-inn," + ~
"payer-kpp,payer-name,payer-okpo,payer-passport,payer-r-schet,payer-type,perm-date," + ~
"prn-doc-code,PS,receiver-bank-name,receiver-bank-city,receiver-bik,receiver-c-schet,receiver-code,receiver-code-schet," + ~
"receiver-dop1,receiver-dop2,receiver-dop3,receiver-dop4,receiver-inn,receiver-kpp,receiver-name," + ~
"receiver-okpo,receiver-passport,receiver-r-schet,receiver-type,receiver-sign1,receiver-sign2,receiver-sign3,receiver-sign4," + ~
"payer-sign1,payer-sign2,payer-sign3,payer-sign4,srok-pl,stat-pl,status_," + ~
"shift-date,shift-name,shift-num," + ~
"str-podr-code,str-podr-name,str-podr-type,sum-base,sum-contr,sum-doc,sum-rubl,trn-doc-code," + ~
"user-db-num-doc,user-db-num-fact,user-db-num-perm,user-db-num-pl,user-name-doc,user-name-fact,user-name-perm,user-name-pl," + ~
"vid-opl,vid-plat"

define variable v-label-param as character no-undo .

v-label-param =
  "actual-base-rate" + {&delim-par} + "Текущий курс баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "actual-base-scale" + {&delim-par} + "Текущий масштаб курса баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "actual-exch-rate" + {&delim-par} + "Текущий курс вал.платежа" + {&delim-par} + "" + {&delim-flf}
 + "actual-exch-scale" + {&delim-par} + "Текущий масштаб курса вал.платежа" + {&delim-par} + "" + {&delim-flf}
 + "an-uchet-code" + {&delim-par} + "Внутр. код аналит. учета" + {&delim-par} + "" + {&delim-flf}
 + "base-rate" + {&delim-par} + "Курс баз.вал. на дату док-та" + {&delim-par} + "" + {&delim-flf}
 + "base-scale" + {&delim-par} + "Масшаб курса баз.вал. на дату док-та" + {&delim-par} + "" + {&delim-flf}
 + "cel-nazn-code" + {&delim-par} + "Внутр код. целев. назн." + {&delim-par} + "" + {&delim-flf}
 + "contract-curr" + {&delim-par} + "Код валюты контракта" + {&delim-par} + "" + {&delim-flf}
 + "contract-code" + {&delim-par} + "Вн. № контракта" + {&delim-par} + "" + {&delim-flf}
 + "contract-rate" + {&delim-par} + "Курс вал.дог-ра на дату док-та" + {&delim-par} + "" + {&delim-flf}
 + "contract-scale" + {&delim-par} + "Масшаб курса вал.дог-ра на дату док-та" + {&delim-par} + "" + {&delim-flf}
 + "con-stat" + {&delim-par} + "Статус связи с ФО" + {&delim-par} + "" + {&delim-flf}
 + "con-sum-base" + {&delim-par} + "Сумма связанной в ФО части баз вал" + {&delim-par} + "" + {&delim-flf}
 + "con-sum-rubl" + {&delim-par} + "Сумма связанной в ФО части нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "cor-acc" + {&delim-par} + "Внутр. код корр. счета" + {&delim-par} + "" + {&delim-flf}
 + "cor-acc1" + {&delim-par} + "Внутр. код корр. счета2" + {&delim-par} + "" + {&delim-flf}.
v-label-param = v-label-param
 + "curr-code" + {&delim-par} + "Код валюты" + {&delim-par} + "" + {&delim-flf}
 + "doc-date" + {&delim-par} + "Дата док-та" + {&delim-par} + "" + {&delim-flf}
 + "enclosure" + {&delim-par} + "Приложение" + {&delim-par} + "" + {&delim-flf}
 + "exch-rate" + {&delim-par} + "Курс вал. платежа на дату док-та" + {&delim-par} + "" + {&delim-flf}
 + "exch-scale" + {&delim-par} + "Масшаб курса вал. платежа на дату док-та" + {&delim-par} + "" + {&delim-flf}
 + "f104" + {&delim-par} + "КБК" + {&delim-par} + "" + {&delim-flf}
 + "f105" + {&delim-par} + "ОКАТО" + {&delim-par} + "" + {&delim-flf}
 + "f106" + {&delim-par} + "Основание налогового платежа" + {&delim-par} + "" + {&delim-flf}
 + "f107" + {&delim-par} + "Налоговый период" + {&delim-par} + "" + {&delim-flf}
 + "f108" + {&delim-par} + "Номер налогового документа" + {&delim-par} + "" + {&delim-flf}
 + "f109" + {&delim-par} + "Дата налогового документа" + {&delim-par} + "" + {&delim-flf}
 + "f110" + {&delim-par} + "Тип налогового платежа" + {&delim-par} + "" + {&delim-flf}
 + "f22" + {&delim-par} + "Код" + {&delim-par} + "" + {&delim-flf}
 + "f23" + {&delim-par} + "Резервное поле" + {&delim-par} + "" + {&delim-flf}
 + "fact-date" + {&delim-par} + "Дата факт" + {&delim-par} + "" + {&delim-flf}
 + "fin-doc-code" + {&delim-par} + "Вн. №" + {&delim-par} + "" + {&delim-flf}
 + "fin-doc-type" + {&delim-par} + "Тип платежа" + {&delim-par} + "" + {&delim-flf}
 + "fin-ext-doc-type" + {&delim-par} + "Расш.тип платежа" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "in-doc-code" + {&delim-par} + "Номер" + {&delim-par} + "" + {&delim-flf}
 + "in-host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 + "including" + {&delim-par} + "В том числе" + {&delim-par} + "" + {&delim-flf}
 + "is-back-date" + {&delim-par} + "Платеж закрыт <задним числом>" + {&delim-par} + "" + {&delim-flf}
 + "is-corr" + {&delim-par} + "Платеж корректировался в стат. <факт>" + {&delim-par} + "" + {&delim-flf}
 + "is-del" + {&delim-par} + "Платеж удален в статусе <факт>" + {&delim-par} + "" + {&delim-flf}
 + "nazn-pl" + {&delim-par} + "Наз пл" + {&delim-par} + "" + {&delim-flf}
 + "naznach-plat" + {&delim-par} + "Назначение платежа" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "ocher-pl" + {&delim-par} + "Очередность платежа" + {&delim-par} + "" + {&delim-flf}
 + "out-doc-code" + {&delim-par} + "Номер" + {&delim-par} + "" + {&delim-flf}
 + "out-host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 .
v-label-param = v-label-param
 + "pay-date" + {&delim-par} + "Дата платежа(поступило в банк)" + {&delim-par} + "" + {&delim-flf}
 + "payer-bank-name" + {&delim-par} + "Наим. банка ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-bank-city" + {&delim-par} + "Город банка ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-bik" + {&delim-par} + "БИК ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-c-schet" + {&delim-par} + "Кор.счет ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-code" + {&delim-par} + "Код ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-code-schet" + {&delim-par} + "Код счета ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-dop1" + {&delim-par} + "ПЛАТЕЛЬЩИК допинф1" + {&delim-par} + "" + {&delim-flf}
 + "payer-dop2" + {&delim-par} + "ПЛАТЕЛЬЩИК допинф2" + {&delim-par} + "" + {&delim-flf}
 + "payer-dop3" + {&delim-par} + "ПЛАТЕЛЬЩИК допинф3" + {&delim-par} + "" + {&delim-flf}
 + "payer-dop4" + {&delim-par} + "ПЛАТЕЛЬЩИК допинф4" + {&delim-par} + "" + {&delim-flf}
 + "payer-inn" + {&delim-par} + "{&abbr_inn_allshift} ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-kpp" + {&delim-par} + "{&abbr_kpp_allshift} ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-name" + {&delim-par} + "ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-okpo" + {&delim-par} + "ОКПО ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-passport" + {&delim-par} + "Паспорт ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-r-schet" + {&delim-par} + "Рас.счет ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "payer-type" + {&delim-par} + "Тип ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "perm-date" + {&delim-par} + "Дата разр" + {&delim-par} + "" + {&delim-flf}
 + "prn-doc-code" + {&delim-par} + "Номер платежа" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Доп. инфо" + {&delim-par} + "" + {&delim-flf}
 .
v-label-param = v-label-param
 + "receiver-bank-name" + {&delim-par} + "Наим. банка ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-bank-city" + {&delim-par} + "Город банка ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-bik" + {&delim-par} + "БИК ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-c-schet" + {&delim-par} + "Кор.счет ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-code" + {&delim-par} + "Код ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-code-schet" + {&delim-par} + "Код счета ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-dop1" + {&delim-par} + "ПОЛУЧАТЕЛЬ допинф1" + {&delim-par} + "" + {&delim-flf}
 + "receiver-dop2" + {&delim-par} + "ПОЛУЧАТЕЛЬ допинф2" + {&delim-par} + "" + {&delim-flf}
 + "receiver-dop3" + {&delim-par} + "ПОЛУЧАТЕЛЬ допинф3" + {&delim-par} + "" + {&delim-flf}
 + "receiver-dop4" + {&delim-par} + "ПОЛУЧАТЕЛЬ допинф4" + {&delim-par} + "" + {&delim-flf}
 + "receiver-inn" + {&delim-par} + "{&abbr_inn_allshift} ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-kpp" + {&delim-par} + "{&abbr_kpp_allshift} ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-name" + {&delim-par} + "ПОЛУЧАТЕЛЬ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-okpo" + {&delim-par} + "ОКПО ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-passport" + {&delim-par} + "Паспорт ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-r-schet" + {&delim-par} + "Рас.счет ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-type" + {&delim-par} + "Тип ПОЛУЧАТЕЛЯ" + {&delim-par} + "" + {&delim-flf}
 + "receiver-sign1" + {&delim-par} + "Подпись ПОЛУЧАТЕЛЯ1" + {&delim-par} + "" + {&delim-flf}
 + "receiver-sign2" + {&delim-par} + "Подпись ПОЛУЧАТЕЛЯ2" + {&delim-par} + "" + {&delim-flf}
 + "receiver-sign3" + {&delim-par} + "Подпись ПОЛУЧАТЕЛЯ3" + {&delim-par} + "" + {&delim-flf}
 + "receiver-sign4" + {&delim-par} + "Подпись ПОЛУЧАТЕЛЯ4" + {&delim-par} + "" + {&delim-flf}
 + "payer-sign1" + {&delim-par} + "Подпись ПЛАТЕЛЬЩИКА1" + {&delim-par} + "" + {&delim-flf}
 + "payer-sign2" + {&delim-par} + "Подпись ПЛАТЕЛЬЩИКА2" + {&delim-par} + "" + {&delim-flf}
 + "payer-sign3" + {&delim-par} + "Подпись ПЛАТЕЛЬЩИКА3" + {&delim-par} + "" + {&delim-flf}
 + "payer-sign4" + {&delim-par} + "Подпись ПЛАТЕЛЬЩИКА4" + {&delim-par} + "" + {&delim-flf}
 .
v-label-param = v-label-param
 + "shift-date" + {&delim-par} + "Дата смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-name" + {&delim-par} + "Номер смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-num" + {&delim-par} + "Пор. смены" + {&delim-par} + "" + {&delim-flf}
 + "srok-pl" + {&delim-par} + "Срок платежа" + {&delim-par} + "" + {&delim-flf}
 + "stat-pl" + {&delim-par} + "Налоговый статус ПЛАТЕЛЬЩИКА" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "str-podr-code" + {&delim-par} + "Код структурного подразд." + {&delim-par} + "" + {&delim-flf}
 + "str-podr-name" + {&delim-par} + "Назв.структ.подразд." + {&delim-par} + "" + {&delim-flf}
 + "str-podr-type" + {&delim-par} + "Тип структ.подразд." + {&delim-par} + "" + {&delim-flf}
 + "sum-base" + {&delim-par} + "Сумма в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-contr" + {&delim-par} + "Сумма в вал. договора" + {&delim-par} + "" + {&delim-flf}
 + "sum-doc" + {&delim-par} + "Сумма в вал. платежа" + {&delim-par} + "" + {&delim-flf}
 + "sum-rubl" + {&delim-par} + "Сумма в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "trn-doc-code" + {&delim-par} + "Оп.касса" + {&delim-par} + "" + {&delim-flf}
 + "user-db-num-doc" + {&delim-par} + "БД составления платежа" + {&delim-par} + "" + {&delim-flf}
 + "user-db-num-fact" + {&delim-par} + "БД перевода на <факт>" + {&delim-par} + "" + {&delim-flf}
 + "user-db-num-perm" + {&delim-par} + "БД перевода на <разр>" + {&delim-par} + "" + {&delim-flf}
 + "user-db-num-pl" + {&delim-par} + "БД перевода в <банк>" + {&delim-par} + "" + {&delim-flf}
 + "user-name-doc" + {&delim-par} + "Cоставил" + {&delim-par} + "" + {&delim-flf}
 + "user-name-fact" + {&delim-par} + "Закрыл до <факт>" + {&delim-par} + "" + {&delim-flf}
 + "user-name-perm" + {&delim-par} + "Разрешил" + {&delim-par} + "" + {&delim-flf}
 + "user-name-pl" + {&delim-par} + "Отметка об оплате (принято банком)" + {&delim-par} + "" + {&delim-flf}
 + "vid-opl" + {&delim-par} + "Вид оплаты" + {&delim-par} + "" + {&delim-flf}
 + "vid-plat" + {&delim-par} + "Вид платежа" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-fin-doc:handle
                                            ,input  {&table_fin-doc}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-contract Dialog-Frame
FUNCTION get-contract RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_contract for ub.contract.
  find first buf_contract no-lock where
                buf_contract.host-code = loc-c-fin-doc.host-code
            AND buf_contract.contract-code = loc-c-fin-doc.contract-code no-error.
    if available buf_contract then return buf_contract.contract-prn-code.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cashbookname Dialog-Frame
FUNCTION get-cashbookname RETURNS CHARACTER
  ( input iCashbookID as int64) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_cashbook for ub.cashbook.
  find first buf_cashbook no-lock where
                buf_cashbook.id = iCashbookID
     no-error.
  if available buf_cashbook 
  then return buf_cashbook.CashBookName.
  else return string(iCashbookID).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

 define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
                buf_currency.curr-code = loc-c-fin-doc.curr-code no-error.
    if available buf_currency then return buf_currency.curr-abbr.

  RETURN string(loc-c-fin-doc.curr-code).   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-shift Dialog-Frame
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_c-fin-doc FOR ub.c-fin-doc, OUTPUT p-shift-name-num AS CHARACTER ) :
define variable v-fin-doc-shift-name-num as character no-undo.
define variable v-fin-doc-shift-name as character no-undo .
IF buf_c-fin-doc.shift-date = ? THEN DO:
   RETURN ?.
END.
 { str/shiftnam.i
     buf_c-fin-doc.obj-type
     buf_c-fin-doc.obj-code
     buf_c-fin-doc.shift-date
     buf_c-fin-doc.shift-num
     v-fin-doc-shift-name
     v-fin-doc-shift-name-num
     no-error
  }

ASSIGN
p-shift-name-num = v-fin-doc-shift-name-num
 .
RETURN buf_c-fin-doc.shift-date.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME