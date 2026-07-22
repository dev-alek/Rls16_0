&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-statement FOR ub.c-fin-statement.
DEFINE BUFFER locked_c-fin-statement-line FOR ub.c-fin-statement-line.
DEFINE TEMP-TABLE tt-c-fin-statement NO-UNDO LIKE ub.c-fin-statement.
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-c-fin-statement-attr NO-UNDO LIKE ub.c-fin-statement-attr.
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

Просмотр истории банковский выписки


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
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.c-fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-mode           AS character NO-UNDO.
/*может быть  lookup*/
DEFINE INPUT PARAMETER p-host-code LIKE ub.c-fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-sttm-code LIKE ub.c-fin-statement.sttm-code NO-UNDO.
DEFINE INPUT PARAMETER p-fins-ext-doc-type LIKE ub.c-fin-statement.fins-ext-doc-type NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
define input-output parameter p-line-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр истории банковский выписки".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
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
&SCOPED-DEFINE sort-clmn_1 mark-string(recid(locked_c-fin-statement-line), v-rid-list)
&scoped-define label-clmn_5 'Контрагент'
&SCOPED-DEFINE sort-clmn_5 get-cli-name(buffer locked_c-fin-statement-line)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_c-fin-statement-line

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines mark-string(recid(locked_c-fin-statement-line), v-rid-list) locked_c-fin-statement-line.line-num locked_c-fin-statement-line.prn-doc-code locked_c-fin-statement-line.fin-doc-code locked_c-fin-statement-line.fin-ext-doc-type locked_c-fin-statement-line.sum-doc get-cli-name(BUFFER locked_c-fin-statement-line) @ v-cli-name /*locked_c-fin-statement-line.sum-rubl locked_c-fin-statement-line.sum-base */
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines locked_c-fin-statement-line.prn-doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines locked_c-fin-statement-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines locked_c-fin-statement-line
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH locked_c-fin-statement-line NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH locked_c-fin-statement-line NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-lines locked_c-fin-statement-line
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines locked_c-fin-statement-line


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-fin-statement.prn-doc-code ~
tt-c-fin-statement.num-docs tt-c-fin-statement.num-docs-th ~
tt-c-fin-statement.doc-date tt-c-fin-statement.start-sum-doc ~
tt-c-fin-statement.start-sum-doc-th tt-c-fin-statement.bank-date ~
tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th ~
tt-c-fin-statement.out-sum-doc tt-c-fin-statement.out-sum-doc-th ~
tt-c-fin-statement.start-date tt-c-fin-statement.end-date ~
tt-c-fin-statement.end-sum-doc tt-c-fin-statement.end-sum-doc-th ~
tt-c-fin-statement.PS tt-c-fin-statement.curr-code ~
tt-c-fin-statement.r-schet tt-c-fin-statement.bank-name ~
tt-c-fin-statement.bik
&Scoped-define ENABLED-TABLES tt-c-fin-statement
&Scoped-define FIRST-ENABLED-TABLE tt-c-fin-statement
&Scoped-Define ENABLED-OBJECTS B-quit B-mark B-lookup B-Help BR-lines ~
mark-num
&Scoped-Define DISPLAYED-FIELDS tt-c-fin-statement.prn-doc-code ~
tt-c-fin-statement.num-docs tt-c-fin-statement.num-docs-th ~
tt-c-fin-statement.sttm-code tt-c-fin-statement.doc-date ~
tt-c-fin-statement.start-sum-doc tt-c-fin-statement.start-sum-doc-th ~
tt-c-fin-statement.bank-date tt-c-fin-statement.in-sum-doc ~
tt-c-fin-statement.in-sum-doc-th tt-c-fin-statement.fact-date ~
tt-c-fin-statement.out-sum-doc tt-c-fin-statement.out-sum-doc-th ~
tt-c-fin-statement.start-date tt-c-fin-statement.end-date ~
tt-c-fin-statement.end-sum-doc tt-c-fin-statement.end-sum-doc-th ~
tt-c-fin-statement.PS tt-c-fin-statement.curr-code ~
tt-c-fin-statement.r-schet tt-c-fin-statement.bank-name ~
tt-c-fin-statement.bik
&Scoped-define DISPLAYED-TABLES tt-c-fin-statement
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-fin-statement
&Scoped-Define DISPLAYED-OBJECTS mark-num f-bank-data f-th-data F-curr-abbr ~
f-bank

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_c-fin-statement-line FOR ub.c-fin-statement-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

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
      locked_c-fin-statement-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines NO-LOCK DISPLAY
      mark-string(recid(locked_c-fin-statement-line), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U WIDTH 1
locked_c-fin-statement-line.line-num COLUMN-LABEL "Строка" FORMAT ">,>>9":U
locked_c-fin-statement-line.prn-doc-code FORMAT "X(16)":U
locked_c-fin-statement-line.fin-doc-code COLUMN-LABEL "Внутр.№" FORMAT "999999999":U
locked_c-fin-statement-line.fin-ext-doc-type COLUMN-LABEL "Тип" FORMAT "X(8)":U
    WIDTH 8
locked_c-fin-statement-line.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
get-cli-name(BUFFER locked_c-fin-statement-line) @ v-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(20)":U WIDTH 21
/*locked_c-fin-statement-line.sum-rubl FORMAT ">,>>>,>>>,>>>,>>9.99":U
locked_c-fin-statement-line.sum-base FORMAT ">,>>>,>>>,>>>,>>9.99":U
*/
ENABLE
locked_c-fin-statement-line.prn-doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.77 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 29
     B-lookup AT ROW 1 COL 49
     B-Help AT ROW 1 COL 89
     tt-c-fin-statement.prn-doc-code AT ROW 2 COL 1
          LABEL "№" FORMAT "X(22)"
          VIEW-AS FILL-IN
          SIZE 25.5 BY 1
          FGCOLOR 4
     tt-c-fin-statement.num-docs AT ROW 2 COL 67 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-c-fin-statement.num-docs-th AT ROW 2 COL 88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-c-fin-statement.sttm-code AT ROW 3 COL 8 COLON-ALIGNED
          LABEL "Внутр.№" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-c-fin-statement.doc-date AT ROW 3 COL 21.5
          LABEL "Дата сост." FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-statement.start-sum-doc AT ROW 3 COL 54.5 COLON-ALIGNED
          LABEL "Вход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.start-sum-doc-th AT ROW 3 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-c-fin-statement.bank-date AT ROW 4 COL 31.5 COLON-ALIGNED
          LABEL "Дата банк" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-statement.in-sum-doc AT ROW 4 COL 54.5 COLON-ALIGNED
          LABEL "Приход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.in-sum-doc-th AT ROW 4 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-c-fin-statement.fact-date AT ROW 5 COL 31.5 COLON-ALIGNED
          LABEL "Дата факт" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-statement.out-sum-doc AT ROW 5 COL 54.5 COLON-ALIGNED
          LABEL "Расход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.out-sum-doc-th AT ROW 5 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-c-fin-statement.start-date AT ROW 6 COL 15 COLON-ALIGNED
          LABEL "С" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-statement.end-date AT ROW 6 COL 31.5 COLON-ALIGNED
          LABEL "по" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-statement.end-sum-doc AT ROW 6 COL 54.5 COLON-ALIGNED
          LABEL "Исход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.end-sum-doc-th AT ROW 6 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     BR-lines AT ROW 8 COL 1
     tt-c-fin-statement.PS AT ROW 20 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2 TOOLTIP "Дополнительная информация"
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON B-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     mark-num AT ROW 1 COL 30.5 COLON-ALIGNED NO-LABEL
     f-bank-data AT ROW 2 COL 56.5 NO-LABEL
     f-th-data AT ROW 2 COL 78 NO-LABEL
     tt-c-fin-statement.curr-code AT ROW 5 COL 1
          LABEL "Вал" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 4 BY .67
     F-curr-abbr AT ROW 5 COL 6 COLON-ALIGNED NO-LABEL
     f-bank AT ROW 7 COL 1 NO-LABEL
     tt-c-fin-statement.r-schet AT ROW 7 COL 8 COLON-ALIGNED NO-LABEL FORMAT "X(20)"
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     tt-c-fin-statement.bank-name AT ROW 7 COL 30 COLON-ALIGNED NO-LABEL FORMAT "X(100)"
           VIEW-AS TEXT
          SIZE 50 BY .67
     tt-c-fin-statement.bik AT ROW 7 COL 87 COLON-ALIGNED
          LABEL "БИК" FORMAT "X(9)"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     SPACE(0.24) SKIP(14.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выписка №"
         CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-statement B "?" ? ub c-fin-statement
      TABLE: locked_c-fin-statement-line B "?" ? ub c-fin-statement-line
      TABLE: tt-c-fin-statement T "?" NO-UNDO ub c-fin-statement
      TABLE: tt-fin-doc T "?" NO-UNDO ub fin-doc
      TABLE: tt0-c-fin-statement-attr T "?" NO-UNDO ub c-fin-statement-attr
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
                                                                        */
/* BROWSE-TAB BR-lines end-sum-doc-th Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-fin-statement.bank-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.bank-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.bik IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.curr-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.doc-date IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.end-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.end-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.end-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN f-bank IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-bank-data IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN F-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-th-data IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.fact-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.in-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.in-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.num-docs IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.num-docs-th IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.out-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.out-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.prn-doc-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.r-schet IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.start-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.start-sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.start-sum-doc-th IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-statement.sttm-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH locked_c-fin-statement-line NO-LOCK INDEXED-REPOSITION.
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


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define buffer buf_fin-doc for ub.fin-doc.
  IF NOT AVAILABLE LOCKED_c-fin-statement-line THEN RETURN NO-APPLY.
  IF locked_c-fin-statement-line.fin-doc-code = 0 THEN DO:
      MESSAGE
      "К данной строке платеж в системе не привязан!" SKIP
      "Просмотр невозможен!"
      VIEW-AS ALERT-BOX.
  END.
  find first buf_fin-doc no-lock where
            buf_fin-doc.host-code = locked_c-fin-statement.host-code
       and buf_fin-doc.fin-doc-code = locked_c-fin-statement-line.fin-doc-code no-error.
  if not available buf_Fin-doc then do:

  end.
  else do:
    run ref/shwcfind.p (
                        input parParentProc
                      ,input p-curr-host-code
                      ,input locked_c-fin-statement-line.host-code /*p-host-code*/
                      ,input locked_c-fin-statement-line.fin-doc-code
                      ,input locked_c-fin-statement-line.corr-user-db-num
                      ,input locked_c-fin-statement-line.chip-num).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available locked_c-fin-statement then do:
    { gbl/markstrn.i locked_c-fin-statement v-rid-list }
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


&Scoped-define BROWSE-NAME BR-lines
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ ref/tabhndmv.i v-tab-order underline-tb }


{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1   = "{&sort-clmn_1}"
  &label-clmn_1  = "{&label-clmn_1}"
  &sort-clmn_2   = "locked_c-fin-statement-line.line-num"
  &sort-clmn_3    = "locked_c-fin-statement-line.prn-doc-code"
  &sort-clmn_4    = "locked_c-fin-statement-line.fin-doc-code"
  &sort-clmn_5    = "{&sort-clmn_5}"
  &label-clmn_5   = "{&label-clmn_5}"
  &sort-clmn_6    = "locked_c-fin-statement-line.sum-doc"
  &open-query     = "run OpenBr in this-procedure ( yes, no, no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( yes, no, no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(locked_c-fin-statement-line). run OpenBr in this-procedure ( yes, no, '':U). reposition br-lines to recid v-doc-rec no-error. v-doc-rec = ?. " }

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
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
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

if p-mode <> {&lookup}
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
FIND FIRST X_sysconf NO-LOCK WHERE
        X_sysconf.host-code = p-host-code NO-ERROR.
IF NOT AVAILABLE X_sysconf THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-host-code"  p-curr-host-code
    view-as alert-box ERROR.
    undo, return error.
END.
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
  DISPLAY mark-num f-bank-data f-th-data F-curr-abbr f-bank
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-fin-statement THEN
    DISPLAY tt-c-fin-statement.prn-doc-code tt-c-fin-statement.num-docs
          tt-c-fin-statement.num-docs-th tt-c-fin-statement.sttm-code
          tt-c-fin-statement.doc-date tt-c-fin-statement.start-sum-doc
          tt-c-fin-statement.start-sum-doc-th tt-c-fin-statement.bank-date
          tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th
          tt-c-fin-statement.fact-date tt-c-fin-statement.out-sum-doc
          tt-c-fin-statement.out-sum-doc-th tt-c-fin-statement.start-date
          tt-c-fin-statement.end-date tt-c-fin-statement.end-sum-doc
          tt-c-fin-statement.end-sum-doc-th tt-c-fin-statement.PS
          tt-c-fin-statement.curr-code tt-c-fin-statement.r-schet
          tt-c-fin-statement.bank-name tt-c-fin-statement.bik
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-mark B-lookup B-Help tt-c-fin-statement.prn-doc-code
         tt-c-fin-statement.num-docs tt-c-fin-statement.num-docs-th
         tt-c-fin-statement.doc-date tt-c-fin-statement.start-sum-doc
         tt-c-fin-statement.start-sum-doc-th tt-c-fin-statement.bank-date
         tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th
         tt-c-fin-statement.out-sum-doc tt-c-fin-statement.out-sum-doc-th
         tt-c-fin-statement.start-date tt-c-fin-statement.end-date
         tt-c-fin-statement.end-sum-doc tt-c-fin-statement.end-sum-doc-th
         BR-lines tt-c-fin-statement.PS mark-num tt-c-fin-statement.curr-code
         tt-c-fin-statement.r-schet tt-c-fin-statement.bank-name
         tt-c-fin-statement.bik
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
for each tt-c-fin-statement:
  delete tt-c-fin-statement.
end.
for each tt0-c-fin-statement-attr:
  delete tt0-c-fin-statement-attr.
end.


find first locked_c-fin-statement no-lock where
          recid(locked_c-fin-statement) = p-doc-rec no-error .
if not available locked_c-fin-statement then do:
  find first locked_c-fin-statement no-lock where
              locked_c-fin-statement.host-code = p-host-code
          AND locked_c-fin-statement.sttm-code = p-sttm-code no-error .
end.
if not available locked_c-fin-statement then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найдена запись БАНКОВСКОЙ ВЫПИСКИР"
  view-as alert-box error .
  undo, return error.
end.
run cur-time in this-procedure ( output v-today, output v-time).
create tt-c-fin-statement.
assign
tt-c-fin-statement.host-code = p-host-code
tt-c-fin-statement.sttm-code  = next-value(s-fin-sttm, {&db-name_schema})
tt-c-fin-statement.curr-code = (IF AVAILABLE X_fin-schet THEN X_fin-schet.curr-code ELSE 0)
tt-c-fin-statement.code-schet = (IF AVAILABLE X_fin-schet THEN X_fin-schet.code-schet ELSE 0)
tt-c-fin-statement.code-bank = (IF AVAILABLE X_fin-bank THEN X_fin-bank.code-bank ELSE 0)
tt-c-fin-statement.c-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.c-schet ELSE '':u)
tt-c-fin-statement.r-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.r-schet ELSE '':u)
tt-c-fin-statement.bik  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bik ELSE '':u)
tt-c-fin-statement.cl-bank  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.cl-bank ELSE '':u)
tt-c-fin-statement.bank-name = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-name ELSE '':u)
tt-c-fin-statement.bank-city = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-city ELSE '':u)
tt-c-fin-statement.cli-name  = X_CLIENTS.obj-NAME
tt-c-fin-statement.PS  = '':U
tt-c-fin-statement.prn-doc-code  = '':U
tt-c-fin-statement.num-docs  = 0
tt-c-fin-statement.fins-ext-doc-type = '':U
tt-c-fin-statement.fins-doc-type = '':U
tt-c-fin-statement.start-date  = v-today
tt-c-fin-statement.end-date  = v-TODAY
tt-c-fin-statement.doc-date      = v-today
tt-c-fin-statement.fins-doc-type  = {&standard-sttm}
tt-c-fin-statement.fins-ext-doc-type  = {&FSEDT_standard-sttm}
tt-c-fin-statement.prn-doc-code  = "":U /*todo*/
tt-c-fin-statement.status_       = {&fin-new}
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
LOCKED_c-fin-statement-line.prn-doc-code:READ-ONLY  IN BROWSE  br-lines = YES
v-cli-name:resizable IN BROWSE  br-lines  = YES
.
ASSIGN
v-tab-order = "b-quit,b-mark,b-lookup,b-help,"
.
DISPLAY
F-curr-abbr
mark-num
f-bank
f-bank-data
f-th-data
WITH FRAME {&frame-name}.
IF AVAILABLE tt-c-fin-statement THEN
DISPLAY
tt-c-fin-statement.num-docs
tt-c-fin-statement.num-docs-th
tt-c-fin-statement.prn-doc-code
tt-c-fin-statement.sttm-code
tt-c-fin-statement.doc-date
tt-c-fin-statement.bank-date
tt-c-fin-statement.fact-date
tt-c-fin-statement.curr-code
tt-c-fin-statement.start-date
tt-c-fin-statement.end-date
tt-c-fin-statement.start-sum-doc tt-c-fin-statement.start-sum-doc-th
tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th
tt-c-fin-statement.out-sum-doc tt-c-fin-statement.out-sum-doc-th
tt-c-fin-statement.end-sum-doc tt-c-fin-statement.end-sum-doc-th
tt-c-fin-statement.r-schet
tt-c-fin-statement.bank-name
tt-c-fin-statement.bik
tt-c-fin-statement.PS
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark WHEN NOT (p-mode = {&LOOKUP} AND p-line-rec = ?)
B-lookup
B-Help
BR-lines
mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
assign
frame {&frame-name}:title = substitute("&1 Срез &2", frame {&frame-name}:title, tt-c-fin-statement.chip-num).
APPLY "Value-changed" TO tt-c-fin-statement.curr-code.
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

OPEN QUERY br-lines FOR EACH locked_c-fin-statement-line NO-LOCK where
    locked_c-fin-statement-line.host-code = tt-c-fin-statement.host-code
 AND locked_c-fin-statement-line.sttm-code = tt-c-fin-statement.sttm-code INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_c-fin-statement-line FOR ub.c-fin-statement-line ) :
DEFINE BUFFER buf_fin-doc FOR ub.fin-doc.
IF buf_c-fin-statement-line.fin-doc-code = 0  THEN DO:
    RETURN '':U.
END.
FIND FIRST buf_fin-doc NO-LOCK WHERE
          buf_fin-doc.host-code = buf_c-fin-statement-line.host-code
     AND  buf_fin-doc.fin-doc-code = buf_c-fin-statement-line.fin-doc-code NO-ERROR.
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
