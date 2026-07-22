&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_fin-statement FOR ub.fin-statement.
DEFINE BUFFER locked_fin-statement-line FOR ub.fin-statement-line.
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt-fin-statement NO-UNDO LIKE ub.fin-statement.
DEFINE TEMP-TABLE tt0-fin-statement-attr NO-UNDO LIKE ub.fin-statement-attr.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_sysconf FOR ub.sysconf.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование и просмотр банковский выписки


Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/29/05
Author: Bakhtadze Natalya
Creation date: 08/29/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-mode           AS character NO-UNDO.
/*может быть update add-def lookup*/
DEFINE INPUT PARAMETER p-host-code LIKE ub.fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-sttm-code LIKE ub.fin-statement.sttm-code NO-UNDO.
DEFINE INPUT PARAMETER p-fins-ext-doc-type LIKE ub.fin-statement.fins-ext-doc-type NO-UNDO.
DEFINE INPUT PARAMETER p-code-bank  LIKE ub.fin-statement.code-bank NO-UNDO.
DEFINE INPUT PARAMETER p-code-schet LIKE ub.fin-statement.code-schet NO-UNDO.
DEFINE INPUT PARAMETER p-other           AS character NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
define input-output parameter p-line-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование и просмотр банковский выписки".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ ref/fnstmip.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-cli-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-mark AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-first AS LOGICAL NO-UNDO init yes.
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-limit-access as integer no-undo .

&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_1 mark-string(recid(locked_fin-statement-line), v-rid-list)
&scoped-define label-clmn_5 'Контрагент'
&SCOPED-DEFINE sort-clmn_5 get-cli-name(buffer locked_fin-statement-line)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_fin-statement-line

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines mark-string(recid(locked_fin-statement-line), v-rid-list) locked_fin-statement-line.line-num locked_fin-statement-line.prn-doc-code locked_fin-statement-line.fin-doc-code locked_fin-statement-line.fin-ext-doc-type locked_fin-statement-line.sum-doc get-cli-name(BUFFER locked_fin-statement-line) @ v-cli-name /*locked_fin-statement-line.sum-rubl locked_fin-statement-line.sum-base */
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines locked_fin-statement-line.prn-doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines locked_fin-statement-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines locked_fin-statement-line
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH locked_fin-statement-line NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH locked_fin-statement-line NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-lines locked_fin-statement-line
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines locked_fin-statement-line


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fin-statement.prn-doc-code ~
tt-fin-statement.num-docs tt-fin-statement.num-docs-th ~
tt-fin-statement.doc-date tt-fin-statement.start-sum-doc ~
tt-fin-statement.start-sum-doc-th tt-fin-statement.bank-date ~
tt-fin-statement.in-sum-doc tt-fin-statement.in-sum-doc-th ~
tt-fin-statement.out-sum-doc tt-fin-statement.out-sum-doc-th ~
tt-fin-statement.start-date tt-fin-statement.end-date ~
tt-fin-statement.end-sum-doc tt-fin-statement.end-sum-doc-th ~
tt-fin-statement.PS tt-fin-statement.curr-code tt-fin-statement.r-schet ~
tt-fin-statement.bank-name tt-fin-statement.bik tt-fin-statement.bank-city
&Scoped-define ENABLED-TABLES tt-fin-statement
&Scoped-define FIRST-ENABLED-TABLE tt-fin-statement
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-mark B-add B-lookup B-del ~
B-print B-hist B-Help B-schet BR-lines e-line-ps mark-num
&Scoped-Define DISPLAYED-FIELDS tt-fin-statement.prn-doc-code ~
tt-fin-statement.num-docs tt-fin-statement.num-docs-th ~
tt-fin-statement.sttm-code tt-fin-statement.doc-date ~
tt-fin-statement.start-sum-doc tt-fin-statement.start-sum-doc-th ~
tt-fin-statement.bank-date tt-fin-statement.in-sum-doc ~
tt-fin-statement.in-sum-doc-th tt-fin-statement.fact-date ~
tt-fin-statement.out-sum-doc tt-fin-statement.out-sum-doc-th ~
tt-fin-statement.start-date tt-fin-statement.end-date ~
tt-fin-statement.end-sum-doc tt-fin-statement.end-sum-doc-th ~
tt-fin-statement.PS tt-fin-statement.curr-code tt-fin-statement.r-schet ~
tt-fin-statement.bank-name tt-fin-statement.bik tt-fin-statement.bank-city
&Scoped-define DISPLAYED-TABLES tt-fin-statement
&Scoped-define FIRST-DISPLAYED-TABLE tt-fin-statement
&Scoped-Define DISPLAYED-OBJECTS e-line-ps mark-num f-bank-data f-th-data ~
F-curr-abbr f-bank

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_fin-statement-line FOR ub.fin-statement-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_no-th        LABEL "Неучтенный в TH платеж"
       MENU-ITEM m_income       LABEL "Приход"
       MENU-ITEM m_expense      LABEL "Расход"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "&История"
     SIZE 10 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-schet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE VARIABLE e-line-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 49 BY 4 NO-UNDO.

DEFINE VARIABLE f-bank AS CHARACTER FORMAT "X(256)":U INITIAL "Счет"
      VIEW-AS TEXT
     SIZE 4.4 BY .77
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-bank-data AS CHARACTER FORMAT "X(256)":U INITIAL "Данные банка"
      VIEW-AS TEXT
     SIZE 12.5 BY .77
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE F-curr-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-th-data AS CHARACTER FORMAT "X(256)":U INITIAL "Док-ты TH"
      VIEW-AS TEXT
     SIZE 11 BY .77
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-lines FOR
      locked_fin-statement-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines NO-LOCK DISPLAY
      mark-string(recid(locked_fin-statement-line), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U WIDTH 1
locked_fin-statement-line.line-num COLUMN-LABEL "Строка" FORMAT ">,>>9":U
locked_fin-statement-line.prn-doc-code FORMAT "X(16)":U
locked_fin-statement-line.fin-doc-code COLUMN-LABEL "Внутр.№" FORMAT "999999999":U
locked_fin-statement-line.fin-ext-doc-type COLUMN-LABEL "Тип" FORMAT "X(8)":U
    WIDTH 8
locked_fin-statement-line.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
get-cli-name(BUFFER locked_fin-statement-line) @ v-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(20)":U WIDTH 21
/*locked_fin-statement-line.sum-rubl FORMAT ">,>>>,>>>,>>>,>>9.99":U
locked_fin-statement-line.sum-base FORMAT ">,>>>,>>>,>>>,>>9.99":U
*/
ENABLE
locked_fin-statement-line.prn-doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.27 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-mark AT ROW 1 COL 29
     B-add AT ROW 1 COL 39
     B-lookup AT ROW 1 COL 49
     B-del AT ROW 1 COL 59
     B-print AT ROW 1 COL 69
     B-hist AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     tt-fin-statement.prn-doc-code AT ROW 2 COL 1
          LABEL "№" FORMAT "X(22)"
          VIEW-AS FILL-IN
          SIZE 25.5 BY 1
          FGCOLOR 4
     tt-fin-statement.num-docs AT ROW 2 COL 67 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-fin-statement.num-docs-th AT ROW 2 COL 88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-fin-statement.sttm-code AT ROW 3 COL 8 COLON-ALIGNED
          LABEL "Внутр.№" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-fin-statement.doc-date AT ROW 3 COL 21.5
          LABEL "Дата сост." FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.start-sum-doc AT ROW 3 COL 54.5 COLON-ALIGNED
          LABEL "Вход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.start-sum-doc-th AT ROW 3 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-fin-statement.bank-date AT ROW 4 COL 31.5 COLON-ALIGNED
          LABEL "Дата банк" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-fin-statement.in-sum-doc AT ROW 4 COL 54.5 COLON-ALIGNED
          LABEL "Приход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.in-sum-doc-th AT ROW 4 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-fin-statement.fact-date AT ROW 5 COL 31.5 COLON-ALIGNED
          LABEL "Дата факт" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.out-sum-doc AT ROW 5 COL 54.5 COLON-ALIGNED
          LABEL "Расход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.out-sum-doc-th AT ROW 5 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-fin-statement.start-date AT ROW 6 COL 15 COLON-ALIGNED
          LABEL "С" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.end-date AT ROW 6 COL 31.5 COLON-ALIGNED
          LABEL "по" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.end-sum-doc AT ROW 6 COL 54.5 COLON-ALIGNED
          LABEL "Исход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.end-sum-doc-th AT ROW 6 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     B-schet AT ROW 7 COL 6
     BR-lines AT ROW 9 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     e-line-ps AT ROW 18 COL 1 NO-LABEL
     tt-fin-statement.PS AT ROW 18 COL 50 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 49 BY 4 TOOLTIP "Дополнительная информация"
     mark-num AT ROW 1 COL 30.5 COLON-ALIGNED NO-LABEL
     f-bank-data AT ROW 2 COL 56.5 NO-LABEL
     f-th-data AT ROW 2 COL 78 NO-LABEL
     tt-fin-statement.curr-code AT ROW 5 COL 1
          LABEL "Вал" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 4 BY .67
     F-curr-abbr AT ROW 5 COL 6 COLON-ALIGNED NO-LABEL
     f-bank AT ROW 7 COL 1 NO-LABEL
     tt-fin-statement.r-schet AT ROW 7 COL 8 COLON-ALIGNED NO-LABEL FORMAT "X(20)"
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     tt-fin-statement.bank-name AT ROW 7 COL 30 COLON-ALIGNED NO-LABEL FORMAT "X(100)"
           VIEW-AS TEXT
          SIZE 50 BY .67
     tt-fin-statement.bik AT ROW 8.2 COL 8 COLON-ALIGNED
          LABEL "БИК" FORMAT "X(9)"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-fin-statement.bank-city AT ROW 8.2 COL 29 COLON-ALIGNED
          LABEL "Город"
           VIEW-AS TEXT
          SIZE 25.5 BY .67
     "Примечания к выписке" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 17.33 COL 50
          FGCOLOR 4 FONT 4
     "Примечания к строке выписки" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 17.33 COL 1.5
          FONT 4
     SPACE(67.99) SKIP(4.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выписка №"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_fin-statement B "?" ? ub fin-statement
      TABLE: locked_fin-statement-line B "?" ? ub fin-statement-line
      TABLE: tt-fin-doc T "?" NO-UNDO ub fin-doc
      TABLE: tt-fin-statement T "?" NO-UNDO ub fin-statement
      TABLE: tt0-fin-statement-attr T "?" NO-UNDO ub fin-statement-attr
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr_sysconf B "?" ? ub sysconf
      TABLE: X_fin-bank B "?" ? ub fin-bank
      TABLE: X_fin-schet B "?" ? ub fin-schet
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines B-schet Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

/* SETTINGS FOR FILL-IN tt-fin-statement.bank-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-statement.bank-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.bank-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.bik IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.curr-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-fin-statement.doc-date IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-fin-statement.end-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.end-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.end-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN f-bank IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-bank-data IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN F-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-th-data IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN tt-fin-statement.fact-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-fin-statement.in-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.in-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.num-docs IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-statement.num-docs-th IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-statement.out-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.out-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.prn-doc-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-fin-statement.r-schet IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.start-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.start-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.start-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-statement.sttm-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH locked_fin-statement-line NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-lines */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выписка № */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-option = '':U then do:
    run gbl/pop-up.p ( input self:handle, no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure ( input add-option) no-error.
  add-option = '':U.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE loc#log AS LOGICAL NO-UNDO.
  DEFINE VARIABLE v-loc-rid-list AS character NO-UNDO.

  IF NOT AVAILABLE LOCKED_fin-statement-line AND v-rid-list = '':U THEN RETURN NO-APPLY.
  CASE v-rid-list:
      WHEN '':U THEN DO:
          MESSAGE
          substitute("Вы действительно хотите удалить из выписки платеж &1 (внутр. №&2)"
                     , LOCKED_fin-statement-line.prn-doc-code
                     , LOCKED_fin-statement-line.fin-doc-code)
          VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
          IF NOT loc#log THEN  RETURN no-apply.
          v-loc-rid-list = string(RECID(LOCKED_fin-statement-line)).
      END.
      OTHERWISE DO:
          MESSAGE
          substitute("Вы действительно хотите удалить из выписки отмеченные платежи")
          VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
          IF NOT loc#log THEN  RETURN no-apply.
         v-loc-rid-list = v-rid-list.
     END.
  END CASE.
  RUN proc-b-del IN THIS-PROCEDURE( input v-loc-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  IF p-mode = {&LOOKUP} THEN DO:
      RETURN NO-APPLY.
  END.
  RUN proc-save IN THIS-PROCEDURE ( INPUT lock-doc) no-error.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
  p-doc-rec = v-doc-rec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF NOT AVAILABLE LOCKED_fin-statement-line THEN RETURN NO-APPLY.
  IF locked_fin-statement-line.fin-doc-code = 0 THEN DO:
      MESSAGE
      "К данной строке платеж в системе не привязан!" SKIP
      "Просмотр невозможен!"
      VIEW-AS ALERT-BOX.
  END.
  run ref/showfind.p
                  (INPUT  parParentProc
                   /*текущая фирма*/
                   ,input p-curr-host-code
                   ,input p-host-code
                   ,input locked_fin-statement-line.fin-doc-code) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available locked_fin-statement then do:
    { gbl/markstrn.i locked_fin-statement v-rid-list }
    loc#log = br-lines:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-lines:select-next-row ().
        apply "VALUE-CHANGED" to br-lines in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-lines in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-format as integer no-undo .
define variable v-cmp as character no-undo .
define variable v-log as logical no-undo .
buffer-compare tt-fin-statement to locked_fin-statement
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
   run proc-save in this-procedure ( input v-log) no-error.
end.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  case p-mode:
    when {&add-def} then do:
      if available locked_fin-statement
      AND locked_fin-statement.status_ = {&fin-new} THEN DO:
        RUN control-line IN THIS-PROCEDURE ( OUTPUT lock-doc).
        IF lock-doc = NO THEN DO:
            MESSAGE
            "Вы уверены, что не хотите сохранить выписку?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
            IF glog THEN DO:
              DELETE LOCKED_fin-statement.
              p-doc-rec = ?.
            END.
        END.
        else do:
          p-doc-rec = v-doc-rec.
        end.
      END.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-schet Dialog-Frame
ON CHOOSE OF B-schet IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
define buffer buf_fin-schet for ub.fin-schet .
{ gbl/stdbtn.i }
if available X_fin-schet then
assign
v-rid-list = string(recid(X_fin-schet))
v-status_ = X_fin-schet.status_
.

  run ref/finschts.w (
               INPUT parParentProc
              ,INPUT p-curr-host-code
              ,input "b-sel":U
              ,input "company-host":U
              ,input {&cmp} /*p-cli-type*/
              ,input p-host-code /*p-cli-code*/
              ,input ? /*p-curr-code*/
              ,input tt-fin-statement.host-code
              ,input 0 /* p-code-bank */
              ,input-output v-status_
              ,input-output v-rid-list
) no-error.
if v-rid-list = "" then   do:
  apply "entry" to b-schet in frame {&frame-name}.
  return no-apply.
end.
 ref-rec = integer( v-rid-list ).
FIND FIRST buf_fin-schet WHERE
      recid (buf_fin-schet) = ref-rec NO-LOCK  .
if buf_fin-schet.status_ <> {&current-status} then do:
  message
  "Статус выбранного Вами счета" buf_fin-schet.status_ " - нельзя работать с таким счетом"
  view-as alert-box error .
  return no-apply.
end.
FIND FIRST X_fin-schet WHERE
      recid (X_fin-schet) = ref-rec NO-LOCK  .
find first X_fin-bank no-lock where
          X_fin-bank.host-code = tt-fin-statement.host-code
      AND X_fin-bank.code-bank = X_fin-schet.code-bank .
  assign
  tt-fin-statement.bank-name = X_fin-bank.bank-name
  tt-fin-statement.bank-city = X_fin-bank.bank-city
  tt-fin-statement.dop1      =  X_fin-schet.dop1
  tt-fin-statement.dop2      =  X_fin-schet.dop2
  tt-fin-statement.bik       =  X_fin-bank.bik
  /*tt-fin-statement.c-schet   =  X_fin-schet.c-schet*/
  tt-fin-statement.r-schet   =  X_fin-schet.r-schet
  tt-fin-statement.c-schet   =  X_fin-schet.c-schet
  tt-fin-statement.code-schet = X_fin-schet.code-schet
  tt-fin-statement.curr-code = X_fin-schet.curr-code
  tt-fin-statement.code-bank = X_fin-schet.code-bank
  .
  display
  tt-fin-statement.bank-name
  tt-fin-statement.bank-city
  tt-fin-statement.bik
  tt-fin-statement.r-schet
  tt-fin-statement.curr-code
  with frame {&frame-name}.
  run control-line in this-procedure ( output lock-doc).
  run lock-proc in this-procedure ( input lock-doc).
  APPLY "Value-changed" TO tt-fin-statement.curr-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-lines
&Scoped-define SELF-NAME BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-lines Dialog-Frame
ON VALUE-CHANGED OF BR-lines IN FRAME Dialog-Frame
DO:
  IF AVAILABLE locked_fin-statement-line THEN DO:
    ASSIGN e-line-ps:SCREEN-VALUE = locked_fin-statement-line.PS.
  END.
  ELSE DO:
    ASSIGN e-line-ps:SCREEN-VALUE = '':U.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fin-statement.curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fin-statement.curr-code Dialog-Frame
ON VALUE-CHANGED OF tt-fin-statement.curr-code IN FRAME Dialog-Frame /* Вал */
DO:
  DEFINE BUFFER buf_currency FOR ub.currency.
  FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = tt-fin-statement.curr-code NO-ERROR.
  IF  AVAILABLE buf_currency THEN DO:
      DISPLAY
      buf_currency.curr-abbr @ f-curr-abbr
      WITH FRAME {&FRAME-NAME}.

  END.
  ELSE DO:
      DISPLAY
       ? @ f-curr-abbr
       WITH FRAME {&FRAME-NAME}.

  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_expense
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_expense Dialog-Frame
ON CHOOSE OF MENU-ITEM m_expense /* Расход */
DO:
    assign
  add-option = {&FDEDT_expense_cashless}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_income
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_income Dialog-Frame
ON CHOOSE OF MENU-ITEM m_income /* Приход */
DO:
    assign
  add-option = {&FDEDT_income_cashless}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_no-th
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_no-th Dialog-Frame
ON CHOOSE OF MENU-ITEM m_no-th /* Неучтенный в TH платеж */
DO:
  assign
  add-option = "no-th".
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.

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
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1   = "{&sort-clmn_1}"
  &label-clmn_1  = "{&label-clmn_1}"
  &sort-clmn_2   = "locked_fin-statement-line.line-num"
  &sort-clmn_3    = "locked_fin-statement-line.prn-doc-code"
  &sort-clmn_4    = "locked_fin-statement-line.fin-doc-code"
  &sort-clmn_5    = "{&sort-clmn_5}"
  &label-clmn_5   = "{&label-clmn_5}"
  &sort-clmn_6    = "locked_fin-statement-line.sum-doc"
  &open-query     = "run OpenBr in this-procedure ( yes, no, no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( yes, no, no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(locked_fin-statement-line). run OpenBr in this-procedure ( yes, no, '':U). reposition br-lines to recid v-doc-rec no-error. v-doc-rec = ?. " }

{ gbl/ed_date.i tt-fin-statement.doc-date }
{ gbl/ed_date.i tt-fin-statement.bank-date }
{ gbl/ed_date.i tt-fin-statement.fact-date }
{ gbl/ed_date.i tt-fin-statement.start-date }
{ gbl/ed_date.i tt-fin-statement.end-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN check-parameters IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN Myenable in this-procedure .
  run control-line in this-procedure ( output lock-doc).
  run lock-proc in this-procedure ( input lock-doc).
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  APPLY "Value-changed" TO br-lines.
  HIDE mark-num in frame {&frame-name} .
  if p-line-rec <> ? then
  REPOSITION br-lines to recid p-line-rec No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-lines"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 2
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
    &prev-order-column-condition_1 = " yes "
    }
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-parameters Dialog-Frame
PROCEDURE check-parameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ gbl/curdbnum.i v-db-num }
{ gbl/basecode.i p-host-code v-base-code }
find first X_curr_sysconf no-lock where
              X_curr_sysconf.host-code = p-curr-host-code.
find first X_sysconf no-lock where
            X_sysconf.host-code = p-host-code.

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
FIND FIRST X_curr_sysconf NO-LOCK WHERE
        X_curr_sysconf.host-code = p-curr-host-code NO-ERROR.
IF NOT AVAILABLE X_curr_sysconf THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-curr-host-code"  p-curr-host-code
    view-as alert-box ERROR.
    undo, return error.
END.
find first X_clients no-lock where
        X_clients.obj-type = {&cmp}
    and X_clients.obj-code = p-curr-host-code.
if p-mode <> {&lookup} then do:
if p-curr-host-code <> p-host-code
or (v-db-num <> X_sysconf.firm-db-num)
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code
  view-as alert-box ERROR.
  undo, return error.
end.
end.
FIND FIRST X_sysconf NO-LOCK WHERE
        X_sysconf.host-code = p-host-code NO-ERROR.
IF NOT AVAILABLE X_sysconf THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-host-code"  p-curr-host-code
    view-as alert-box ERROR.
    undo, return error.
END.
IF p-code-bank <> 0 THEN DO:
  FIND FIRST X_fin-bank NO-LOCK WHERE
            X_fin-bank.host-code = p-host-code
       AND  X_fin-bank.code-bank = p-code-bank NO-ERROR.
    IF NOT AVAILABLE X_fin-bank THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-code-bank"  p-code-bank
        view-as alert-box ERROR.
        undo, return error.
    END.
END.
IF p-code-schet <> 0 THEN DO:
  FIND FIRST X_fin-schet NO-LOCK WHERE
            X_fin-schet.host-code = p-host-code
       AND  X_fin-schet.code-schet = p-code-schet NO-ERROR.
    IF NOT AVAILABLE X_fin-schet THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-code-schet"  p-code-schet
        view-as alert-box ERROR.
        undo, return error.
    END.
    IF p-code-bank <> 0 THEN do:
      IF X_fin-schet.code-bank <>  p-code-bank THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-code-schet и/или p-code-bank"  p-code-schet p-code-bank
        view-as alert-box ERROR.
        undo, return error.
      END.
      FIND FIRST X_fin-bank NO-LOCK WHERE
                X_fin-bank.host-code = X_fin-schet.host-code
           AND  X_fin-bank.code-bank = X_fin-schet.code-bank.
   END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-line Dialog-Frame
PROCEDURE control-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-lock-doc as logical no-undo.
IF CAN-FIND(FIRST ub.fin-statement-line No-LOCK WHERE
                  ub.fin-statement-line.host-code = tt-fin-statement.host-code
             AND  ub.fin-statement-line.sttm-code = tt-fin-statement.sttm-code) then
p-lock-doc = yes.
else p-lock-doc = no.

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
  DISPLAY e-line-ps mark-num f-bank-data f-th-data F-curr-abbr f-bank
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-statement THEN
    DISPLAY tt-fin-statement.prn-doc-code tt-fin-statement.num-docs
          tt-fin-statement.num-docs-th tt-fin-statement.sttm-code
          tt-fin-statement.doc-date tt-fin-statement.start-sum-doc
          tt-fin-statement.start-sum-doc-th tt-fin-statement.bank-date
          tt-fin-statement.in-sum-doc tt-fin-statement.in-sum-doc-th
          tt-fin-statement.fact-date tt-fin-statement.out-sum-doc
          tt-fin-statement.out-sum-doc-th tt-fin-statement.start-date
          tt-fin-statement.end-date tt-fin-statement.end-sum-doc
          tt-fin-statement.end-sum-doc-th tt-fin-statement.PS
          tt-fin-statement.curr-code tt-fin-statement.r-schet
          tt-fin-statement.bank-name tt-fin-statement.bik
          tt-fin-statement.bank-city
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-mark B-add B-lookup B-del B-print B-hist B-Help
         tt-fin-statement.prn-doc-code tt-fin-statement.num-docs
         tt-fin-statement.num-docs-th tt-fin-statement.doc-date
         tt-fin-statement.start-sum-doc tt-fin-statement.start-sum-doc-th
         tt-fin-statement.bank-date tt-fin-statement.in-sum-doc
         tt-fin-statement.in-sum-doc-th tt-fin-statement.out-sum-doc
         tt-fin-statement.out-sum-doc-th tt-fin-statement.start-date
         tt-fin-statement.end-date tt-fin-statement.end-sum-doc
         tt-fin-statement.end-sum-doc-th B-schet BR-lines e-line-ps
         tt-fin-statement.PS mark-num tt-fin-statement.curr-code
         tt-fin-statement.r-schet tt-fin-statement.bank-name
         tt-fin-statement.bik tt-fin-statement.bank-city
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
for each tt-fin-statement:
  delete tt-fin-statement.
end.
for each tt0-fin-statement-attr:
  delete tt0-fin-statement-attr.
end.


if p-mode = {&update}
or p-mode = {&lookup}
then do:
if p-mode = {&update} then do:
  find first locked_fin-statement EXclusive-lock where
                recid(locked_fin-statement) = p-doc-rec no-wait no-error.
  if locked locked_fin-statement then do:
    message
    vss-workfile vss-revision vss-description skip
    "Запись БАНКОВСКАЯ ВЫПИСКА занята"
    view-as alert-box error .
    undo, return error.
  end.
end.
else do:
  find first locked_fin-statement no-lock where
              recid(locked_fin-statement) = p-doc-rec no-error .
   if not available locked_fin-statement then do:
      find first locked_fin-statement no-lock where
                 locked_fin-statement.host-code = p-host-code
             AND locked_fin-statement.sttm-code = p-sttm-code no-error .
   end.
end.
if not available locked_fin-statement then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найдена запись БАНКОВСКОЙ ВЫПИСКИР"
  view-as alert-box error .
  undo, return error.
end.
if p-mode = {&update}
    AND not (locked_fin-statement.status_ = {&fin-new}
          or locked_fin-statement.status_ = {&fin-bank}
             )
    then do:
      message
      "ВЫПИСКА находится в статусе" locked_fin-statement.status_ skip
      "Изменение невозможно"
      view-as alert-box error .
      undo, return error.
    end.
    if locked_fin-statement.status_ = {&fin-bank}  then do:
      assign
      v-limit-access = 1
      .
    end.
    create tt-fin-statement.
    buffer-copy locked_fin-statement to tt-fin-statement.
  end.
  else do:
    run cur-time in this-procedure ( output v-today, output v-time).
    create tt-fin-statement.
    assign
    tt-fin-statement.host-code = p-host-code
    tt-fin-statement.sttm-code  = next-value(s-fin-sttm, {&db-name_schema})
    tt-fin-statement.curr-code = (IF AVAILABLE X_fin-schet THEN X_fin-schet.curr-code ELSE 0)
    tt-fin-statement.code-schet = (IF AVAILABLE X_fin-schet THEN X_fin-schet.code-schet ELSE 0)
    tt-fin-statement.code-bank = (IF AVAILABLE X_fin-bank THEN X_fin-bank.code-bank ELSE 0)
    tt-fin-statement.c-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.c-schet ELSE '':u)
    tt-fin-statement.r-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.r-schet ELSE '':u)
    tt-fin-statement.bik  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bik ELSE '':u)
    tt-fin-statement.cl-bank  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.cl-bank ELSE '':u)
    tt-fin-statement.bank-name = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-name ELSE '':u)
    tt-fin-statement.bank-city = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-city ELSE '':u)
    tt-fin-statement.cli-name  = X_CLIENTS.obj-NAME
    tt-fin-statement.PS  = '':U
    tt-fin-statement.prn-doc-code  = '':U
    tt-fin-statement.num-docs  = 0
    tt-fin-statement.fins-ext-doc-type = '':U
    tt-fin-statement.fins-doc-type = '':U
    tt-fin-statement.start-date  = v-today
    tt-fin-statement.end-date  = v-TODAY
    tt-fin-statement.doc-date      = v-today
    tt-fin-statement.fins-doc-type  = {&standard-sttm}
    tt-fin-statement.fins-ext-doc-type  = {&FSEDT_standard-sttm}
    tt-fin-statement.prn-doc-code  = "":U /*todo*/
    tt-fin-statement.status_       = {&fin-new}
    .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-proc Dialog-Frame
PROCEDURE lock-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-loc-doc AS LOGICAL NO-UNDO.
if p-mode = {&lookup} then return.
if p-loc-doc then do:
    DISABLE
    b-schet
    tt-fin-statement.start-date
    tt-fin-statement.end-date
    tt-fin-statement.start-sum-doc-th
    with frame {&frame-name}
    .
end.
else do:
    ENABLE
    b-schet WHEN tt-fin-statement.STATUS_ = {&fin-new}
    tt-fin-statement.start-sum-doc-th WHEN tt-fin-statement.STATUS_ = {&fin-new}
    tt-fin-statement.start-date WHEN tt-fin-statement.STATUS_ = {&fin-new}
    tt-fin-statement.end-date WHEN tt-fin-statement.STATUS_ = {&fin-new}
    with frame {&frame-name}
    .
end.
IF tt-fin-statement.code-schet <> 0 THEN DO:
    ENABLE
    b-add WHEN tt-fin-statement.STATUS_ = {&fin-new}
    b-lookup WHEN tt-fin-statement.STATUS_ = {&fin-new}
    b-del WHEN tt-fin-statement.STATUS_ = {&fin-new}
    with frame {&frame-name} .
END.
ELSE DO:
    DISABLE
    b-add
    b-lookup
    b-del
    with frame {&frame-name} .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
LOCKED_fin-statement-line.prn-doc-code:READ-ONLY  IN BROWSE  br-lines = YES
v-cli-name:resizable IN BROWSE  br-lines  = YES
b-add:MENU-MOUSE in frame {&frame-name} = 1
.
ASSIGN
v-tab-order = "b-exit,b-quit,b-mark,b-add,b-lookup,b-del,b-print,b-hist,b-help," +
              "prn-doc-code,doc-date,bank-date," +
              "start-date,end-date,start-sum-doc,start-sum-doc-th,fact-date,in-sum-doc,out-sum-doc,end-sum-doc,b-schet"
.
DISPLAY
F-curr-abbr
mark-num
f-bank
f-bank-data
f-th-data
WITH FRAME {&frame-name}.
IF AVAILABLE tt-fin-statement THEN
DISPLAY
tt-fin-statement.num-docs
tt-fin-statement.num-docs-th
tt-fin-statement.prn-doc-code
tt-fin-statement.sttm-code
tt-fin-statement.doc-date
tt-fin-statement.bank-date
tt-fin-statement.fact-date
tt-fin-statement.curr-code
tt-fin-statement.start-date
tt-fin-statement.end-date
tt-fin-statement.start-sum-doc tt-fin-statement.start-sum-doc-th
tt-fin-statement.in-sum-doc tt-fin-statement.in-sum-doc-th
tt-fin-statement.out-sum-doc tt-fin-statement.out-sum-doc-th
tt-fin-statement.end-sum-doc tt-fin-statement.end-sum-doc-th
tt-fin-statement.r-schet
tt-fin-statement.bank-name
tt-fin-statement.bank-city
tt-fin-statement.bik
tt-fin-statement.PS
WITH FRAME {&frame-name}.
e-line-ps:READ-ONLY IN FRAME {&FRAME-NAME} = YES.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-mark WHEN NOT (p-mode = {&LOOKUP} AND p-line-rec = ?)
B-add   WHEN p-mode <> {&LOOKUP}  and v-limit-access = 0
B-lookup
B-del   WHEN p-mode <> {&LOOKUP}  and v-limit-access = 0
B-print
B-hist WHEN p-mode <> {&add-def}
B-Help
tt-fin-statement.prn-doc-code WHEN p-mode <> {&LOOKUP}
tt-fin-statement.PS
tt-fin-statement.doc-date     WHEN p-mode <> {&LOOKUP}
tt-fin-statement.bank-date    WHEN p-mode <> {&LOOKUP}
B-schet                       WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.num-docs = 0)
BR-lines
e-line-ps
mark-num
tt-fin-statement.start-date    WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new})
tt-fin-statement.end-date      WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new})
tt-fin-statement.num-docs      WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new} AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.start-sum-doc WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new} AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.start-sum-doc-th WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new})
tt-fin-statement.in-sum-doc    WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new} AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.out-sum-doc   WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new} AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.end-sum-doc   WHEN (p-mode <> {&LOOKUP} AND tt-fin-statement.STATUS_ = {&fin-new} AND tt-fin-statement.cl-bank = '':U)
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = '&Выход'
    b-quit:COLUMN = 1
    tt-fin-statement.ps:READ-ONLY IN FRAME {&FRAME-NAME} = YES
    .
END.
APPLY "Value-changed" TO tt-fin-statement.curr-code.
ASSIGN FRAME {&FRAME-NAME}:TITLE = substitute("Выписка &1", tt-fin-statement.prn-doc-code).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

OPEN QUERY br-lines FOR EACH locked_fin-statement-line NO-LOCK where
    locked_fin-statement-line.host-code = tt-fin-statement.host-code
 AND locked_fin-statement-line.sttm-code = tt-fin-statement.sttm-code INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo .
define variable v-rid-list as character no-undo .
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-pay-date LIKE ub.fin-doc.fact-date NO-UNDO.
define variable v-bik like ub.fin-statement-line.rp-bik no-undo .
define variable v-bank-name like ub.fin-statement-line.rp-bank-name no-undo .
define variable v-bank-city like ub.fin-statement-line.rp-bank-city no-undo .
define variable v-c-schet like ub.fin-statement-line.rp-c-schet no-undo .
define variable v-r-schet like ub.fin-statement-line.rp-r-schet no-undo .
define variable v-name like ub.fin-statement-line.rp-name no-undo .
define variable v-inn like ub.fin-statement-line.rp-inn no-undo .
define variable v-kpp like ub.fin-statement-line.rp-kpp no-undo .
DEFINE VARIABLE v-prn-doc-code LIKE ub.fin-doc.prn-doc-code NO-UNDO.
DEFINE VARIABLE v-fin-ext-doc-type LIKE ub.fin-doc.fin-ext-doc-type NO-UNDO.
define variable v-sum-doc as decimal no-undo .
define variable v-ps as character no-undo .
define variable ii as integer no-undo .
define buffer buf_fin-doc for ub.fin-doc.
run proc-save in this-procedure ( input no) No-ERROR.
if error-status:error then do:
   MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
   return error.
END.
assign
v-doc-rec = recid(locked_fin-statement)
v-line-rec = ?
.
IF p-fin-doc-type = 'no-th':U THEN DO:
  run ref/finsttli.w (
                  input tt-fin-statement.start-date
                 ,input tt-fin-statement.end-date
                 ,OUTPUT v-prn-doc-code
                 ,output v-fin-ext-doc-type
                 ,output v-pay-date
                 ,output v-bik
                 ,output v-bank-name
                 ,output v-bank-city
                 ,output v-c-schet
                 ,output v-r-schet
                 ,output v-name
                 ,output v-inn
                 ,output v-kpp
                 ,OUTPUT v-sum-doc
                 ,output v-ps
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR
  OR v-prn-doc-code = '':U THEN DO:
      RETURN .
  END.

    run ref/finsttml.p (
                   INPUT NO /*p-silent*/
                  ,INPUT-OUTPUT v-line-rec
                  ,INPUT {&add-def}
                  ,INPUT tt-fin-statement.host-code
                  ,INPUT tt-fin-statement.sttm-code
                  ,INPUT 0
                  ,INPUT v-pay-date
                  ,INPUT v-prn-doc-code
                  ,INPUT v-fin-ext-doc-type
                  ,input v-bik
                  ,input v-bank-name
                  ,input v-bank-city
                  ,input v-c-schet
                  ,input v-r-schet
                  ,input v-name
                  ,input v-inn
                  ,input v-kpp
                  ,INPUT v-sum-doc
                  ,INPUT '':U
                  ,input v-ps
                    )
        no-error.
    if error-status:error then do:
      run control-line in this-procedure ( output lock-doc).
      run lock-proc in this-procedure ( input lock-doc).
      return error.
    end.
END.
/*выберем документ*/
ELSE DO:
    run ref/findocs.w (
                   input parparentproc
                  ,input p-curr-host-code
                  ,input "b-sel,b-mark":U
                  ,input (IF p-fin-doc-type = {&FDEDT_expense_cashless}
                          THEN "schet-fact-order-expense-cashless":U
                          ELSE "schet-fact-order-income-cashless":U)
                  ,input {&all}  /*p-list*/
                  ,input tt-fin-statement.host-code /*p-host-code*/
                  ,input "":U   /*p-obj-type*/
                  ,input 0      /*p-obj-code*/
                  ,input {&fin-fact}
                  ,input "":U
                  ,input p-fins-ext-doc-type   /*p-fin-ext-doc-type*/
                  ,input tt-fin-statement.start-date      /*p-start-date  */
                  ,input tt-fin-statement.end-date      /*p-end-date  */
                  ,input "":U   /* p-trn-doc-code */
                  ,input "":U   /*p-receiver-type */
                  ,input 0      /* p-receiver-code */
                  ,input "":U   /* p-receiver-r-schet */
                  ,input "":U   /*p-PAYER-type */
                  ,input 0      /* p-PAYER-code */
                  ,input "":U   /* p-PAYER-r-schet */
                  ,input ?      /*p-curr-code*/
                  ,input X_fin-schet.code-schet      /* p-receiver-code-schet */
                  ,input X_fin-schet.code-schet      /* p-payer-code-schet */
                  ,input 0      /*p-contract-code*/
                  ,input 0      /*p-cor-acc  */
                  ,input 0      /*p-cor-acc1 */
                  ,input 0      /*p-an-uchet-code */
                  ,input 0      /*p-cel-nazn-code */
                  ,input-output v-rid-list) NO-ERROR.
    IF v-rid-list <> '':U THEN DO:
        _ii:
        DO ii = 1 TO NUM-ENTRIES(v-rid-list)
        ON ERROR UNDO, NEXT _ii
        ON stop UNDO, NEXT _ii
            :
            FIND FIRST buf_fin-doc EXCLUSIVE-LOCK where
                   recid(buf_fin-doc) = INTEGER(ENTRY(ii, v-rid-list)).

            run ref/finsttml.p
                          (INPUT NO /*p-silent*/
                          ,INPUT-OUTPUT v-line-rec
                          ,INPUT {&add-def}
                          ,INPUT tt-fin-statement.host-code
                          ,INPUT tt-fin-statement.sttm-code
                          ,INPUT buf_fin-doc.fin-doc-code
                          ,INPUT buf_fin-doc.pay-date
                          ,INPUT buf_fin-doc.prn-doc-code
                          ,INPUT buf_fin-doc.fin-ext-doc-type
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-bik
                                else buf_fin-doc.payer-bik)
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-bank-name
                                else buf_fin-doc.payer-bank-name)
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-bank-city
                                else buf_fin-doc.payer-bank-city)
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-c-schet
                                else buf_fin-doc.payer-c-schet )
                                /*корр счет кому заплатили или от кого получили*/
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-r-schet
                                else buf_fin-doc.payer-r-schet )
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-name
                                else buf_fin-doc.payer-name )
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-inn
                                else buf_fin-doc.payer-inn )
                          ,input (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                then buf_fin-doc.receiver-kpp
                                else buf_fin-doc.payer-kpp )
                          ,INPUT buf_fin-doc.sum-doc
                          ,INPUT '':U
                          ,input buf_fin-doc.ps
                            )
                no-error.
            if error-status:error then do:
              run control-line in this-procedure ( output lock-doc).
              run lock-proc in this-procedure ( input lock-doc).
              return error.
            end.
        END.
    END.
END.

BUFFER-COPY LOCKED_fin-statement TO tt-fin-statement.
DISPLAY
tt-fin-statement.start-sum-doc-th
tt-fin-statement.in-sum-doc-th
tt-fin-statement.out-sum-doc-th
tt-fin-statement.end-sum-doc-th
tt-fin-statement.num-docs-th
tt-fin-statement.num-docs
with frame {&frame-name} .
run control-line in this-procedure ( output lock-doc).
run lock-proc in this-procedure ( input lock-doc).
RUN OpenBr IN THIS-PROCEDURE ( input YES, input NO, input NO).
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-line-rec AS RECID NO-UNDO.
DEFINE BUFFER buf_fin-statement-line FOR ub.fin-statement-line.
_ii:
DO ii = 1 TO NUM-ENTRIES(p-rid-list)
ON ERROR UNDO, NEXT _ii
ON stop UNDO, NEXT _ii
    :
    FIND FIRST buf_fin-statement-line EXCLUSIVE-LOCK where
           recid(buf_fin-statement-line) = INTEGER(ENTRY(ii, p-rid-list)).
        v-line-rec = RECID(buf_fin-statement-line).
        run ref/finsttml.p (
                       INPUT NO /*p-silent*/
                      ,INPUT-OUTPUT v-line-rec
                      ,INPUT {&deletion}
                      ,INPUT tt-fin-statement.host-code
                      ,INPUT tt-fin-statement.sttm-code
                      ,INPUT buf_fin-statement-line.fin-doc-code
                      ,INPUT buf_fin-statement-line.pay-date /*p-fact-date*/
                      ,INPUT buf_fin-statement-line.prn-doc-code
                      ,INPUT buf_fin-statement-line.fin-ext-doc-type
                      ,input buf_fin-statement-line.rp-bik
                      ,input buf_fin-statement-line.rp-bank-name
                      ,input buf_fin-statement-line.rp-bank-city
                      ,input buf_fin-statement-line.rp-c-schet
                      ,input buf_fin-statement-line.rp-r-schet
                      ,input buf_fin-statement-line.rp-name
                      ,input buf_fin-statement-line.rp-inn
                      ,input buf_fin-statement-line.rp-kpp
                      ,INPUT buf_fin-statement-line.sum-doc
                      ,INPUT '':U
                      ,input '':U /*p-ps*/
                        )
            no-error.
        if error-status:error then do:
          run control-line in this-procedure ( output lock-doc).
          run lock-proc in this-procedure ( input lock-doc).
          return error.
        end.

END.
BUFFER-COPY LOCKED_fin-statement TO tt-fin-statement.
DISPLAY
tt-fin-statement.start-sum-doc-th
tt-fin-statement.in-sum-doc-th
tt-fin-statement.out-sum-doc-th
tt-fin-statement.end-sum-doc-th
tt-fin-statement.num-docs-th
with frame {&frame-name} .
run control-line in this-procedure ( output lock-doc).
run lock-proc in this-procedure ( input lock-doc).
RUN OpenBr IN THIS-PROCEDURE ( input YES, input NO, input NO).
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define input parameter parlines-exist as logical no-undo .
 IF p-mode = {&lookup} THEN DO:
    RETURN.
 END.
 DO TRANSACTION
     ON ERROR UNDO, RETURN ERROR
     ON stop UNDO, RETURN ERROR:
 assign
 frame {&frame-name}
 tt-fin-statement.prn-doc-code
 tt-fin-statement.doc-date
 tt-fin-statement.start-date
 tt-fin-statement.end-date
 tt-fin-statement.start-sum-doc-th
 tt-fin-statement.start-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.end-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.in-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.out-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.num-docs when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.sum-doc = tt-fin-statement.in-sum-doc - tt-fin-statement.out-sum-doc
 tt-fin-statement.PS
 tt-fin-statement.start-date
 tt-fin-statement.end-date
 .
 v-doc-rec = (IF AVAILABLE locked_fin-statement THEN recid(locked_fin-statement) ELSE ?).
&scop prfx tt-fin-statement.
 run ref/finsttm0.p
                 (input no   /*silent*/
                 ,input-output v-doc-rec
                 ,input       (IF v-first AND p-mode = {&add-def} THEN  {&add-def} ELSE {&UPDATE})
                 ,input        '':U /*p-author*/
                 {&all-fin-statement-params-doc-status-transfer}
                 ,input {&fin-new}
                 ,input parlines-exist
                 ) no-error .
if error-status:error then do:
   { gbl/reterhnd.i error }
  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
end.
else do:
  IF p-mode = {&add-def} THEN DO:
     FIND FIRST LOCKED_fin-statement EXCLUSIVE-LOCK WHERE
               recid(LOCKED_fin-statement) = v-doc-rec.
       v-first = NO.
    hide
    b-quit in frame {&frame-name} .
    assign
    b-exit:label in frame {&frame-name} = "&Выход"
    .
  END.
 end.
END.
p-doc-rec = ?.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_fin-statement-line FOR ub.fin-statement-line ) :
DEFINE BUFFER buf_fin-doc FOR ub.fin-doc.
IF buf_fin-statement-line.fin-doc-code = 0  THEN DO:
    RETURN '':U.
END.
FIND FIRST buf_fin-doc NO-LOCK WHERE
          buf_fin-doc.host-code = buf_fin-statement-line.host-code
     AND  buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code NO-ERROR.
IF NOT AVAILABLE buf_fin-doc THEN DO:
    RETURN "!!!Не найден платеж".
END.
CASE buf_fin-doc.fin-ext-doc-type:
    WHEN {&FDEDT_Income_Cashless} THEN DO:
        RETURN buf_fin-doc.payer-name.
    END.
    WHEN {&FDEDT_Expense_Cashless} THEN DO:
       RETURN buf_fin-doc.receiver-name.
    END.
END CASE.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
