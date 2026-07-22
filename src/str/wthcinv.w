&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_person1 FOR ub.clients.
DEFINE BUFFER buf_person2 FOR ub.clients.
DEFINE BUFFER buf_person3 FOR ub.clients.
DEFINE BUFFER buf_person4 FOR ub.clients.
DEFINE BUFFER buf_person5 FOR ub.clients.
DEFINE BUFFER buf_wth FOR ub.wealth.
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-c-wth-doc NO-UNDO LIKE ub.c-wth-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История инвентаризационная ведомость движения материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

Author: Bulgakov

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
define input parameter parauto-fill like ub.c-wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec     as recid no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр инвентаризации":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/usrfulnf.i }
/*DEFINE SHARED QUERY BR-docs FOR wth-doc SCROLLING.*/
define buffer bf_c-wth-doc for ub.c-wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE var-peresort as logical no-undo.
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .

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
&Scoped-define INTERNAL-TABLES buf_c-wth-line buf_wth buf_wth-place ~
tt-c-wth-doc

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines buf_c-wth-line.wth-code buf_wth.wth-name buf_wth-place.w-p-name buf_c-wth-line.bef-sum buf_c-wth-line.aft-sum buf_c-wth-line.fact-sum
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines buf_c-wth-line.fact-sum
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines buf_c-wth-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines buf_c-wth-line
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH buf_c-wth-line WHERE buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code     and buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num     and buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num  NO-LOCK, ~
             EACH buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK, ~
             EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_c-wth-line.obj-type AND buf_wth-place.obj-code = buf_c-wth-line.obj-code AND buf_wth-place.w-p-code = buf_c-wth-line.w-p-code  NO-LOCK
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH buf_c-wth-line WHERE buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code     and buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num     and buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num  NO-LOCK, ~
             EACH buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK, ~
             EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_c-wth-line.obj-type AND buf_wth-place.obj-code = buf_c-wth-line.obj-code AND buf_wth-place.w-p-code = buf_c-wth-line.w-p-code  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-lines buf_c-wth-line buf_wth ~
buf_wth-place
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines buf_c-wth-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-lines buf_wth
&Scoped-define THIRD-TABLE-IN-QUERY-BR-lines buf_wth-place


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-c-wth-doc.obj-type ~
tt-c-wth-doc.corr-date tt-c-wth-doc.corr-user-name tt-c-wth-doc.doc-code ~
tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date ~
tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code ~
tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum tt-c-wth-doc.fact-sum ~
tt-c-wth-doc.operator tt-c-wth-doc.deliver tt-c-wth-doc.receiver ~
tt-c-wth-doc.inv-prs4 tt-c-wth-doc.inv-prs5
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-c-wth-doc.corr-date ~
tt-c-wth-doc.corr-user-name tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date ~
tt-c-wth-doc.shift-date tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num ~
tt-c-wth-doc.obj-code tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum ~
tt-c-wth-doc.fact-sum tt-c-wth-doc.operator tt-c-wth-doc.deliver ~
tt-c-wth-doc.receiver tt-c-wth-doc.inv-prs4 tt-c-wth-doc.inv-prs5
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-c-wth-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-c-wth-doc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-c-wth-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-c-wth-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-c-wth-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-c-wth-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-wth-doc.corr-date ~
tt-c-wth-doc.corr-user-name tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date ~
tt-c-wth-doc.shift-date tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num ~
tt-c-wth-doc.obj-code tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum ~
tt-c-wth-doc.fact-sum tt-c-wth-doc.operator tt-c-wth-doc.deliver ~
tt-c-wth-doc.receiver tt-c-wth-doc.inv-prs4 tt-c-wth-doc.inv-prs5
&Scoped-define ENABLED-TABLES tt-c-wth-doc
&Scoped-define FIRST-ENABLED-TABLE tt-c-wth-doc
&Scoped-Define ENABLED-OBJECTS b-quit B-prev B-next B-Help BR-lines ~
B-lookup B-chk for-object for-person1 for-person2 for-person3 for-person4 ~
for-person5
&Scoped-Define DISPLAYED-FIELDS tt-c-wth-doc.obj-type ~
tt-c-wth-doc.corr-date tt-c-wth-doc.corr-user-name tt-c-wth-doc.doc-code ~
tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date ~
tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code ~
tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum tt-c-wth-doc.fact-sum ~
tt-c-wth-doc.operator tt-c-wth-doc.deliver tt-c-wth-doc.receiver ~
tt-c-wth-doc.inv-prs4 tt-c-wth-doc.inv-prs5
&Scoped-define DISPLAYED-TABLES tt-c-wth-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-wth-doc
&Scoped-Define DISPLAYED-OBJECTS for-object for-person1 for-person2 ~
for-person3 for-person4 for-person5

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-person1 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-person2 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-person3 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-person4 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-person5 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-lines FOR
      buf_c-wth-line,
      buf_wth,
      buf_wth-place SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-c-wth-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines NO-LOCK DISPLAY
      buf_c-wth-line.wth-code FORMAT ">>>>>>>>9":U
buf_wth.wth-name FORMAT "X(20)":U
buf_wth-place.w-p-name FORMAT "X(20)":U
buf_c-wth-line.bef-sum COLUMN-LABEL "Сумма план" FORMAT "->,>>>,>>>,>>9.99":U
buf_c-wth-line.aft-sum COLUMN-LABEL "Сумма факт" FORMAT "->,>>>,>>>,>>9.99":U
buf_c-wth-line.fact-sum COLUMN-LABEL "Расхождение" FORMAT "->,>>>,>>>,>>9.99":U
ENABLE
buf_c-wth-line.fact-sum
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.1 BY 7.8.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 40
     B-next AT ROW 1 COL 44
     B-Help AT ROW 1 COL 95
     tt-c-wth-doc.obj-type AT ROW 3.33 COL 11 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.1 BY 1
     BR-lines AT ROW 5.93 COL 1.1
     B-lookup AT ROW 13.83 COL 11
     B-chk AT ROW 13.83 COL 41
     tt-c-wth-doc.corr-date AT ROW 1 COL 82 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 12
     tt-c-wth-doc.corr-user-name AT ROW 1.03 COL 65 COLON-ALIGNED
          LABEL "Корр."
           VIEW-AS TEXT
          SIZE 12 BY .67
          FGCOLOR 12
     tt-c-wth-doc.doc-code AT ROW 2.13 COL 7.3 COLON-ALIGNED
          LABEL "Номер"
           VIEW-AS TEXT
          SIZE 16.1 BY .67
          FGCOLOR 4
     tt-c-wth-doc.doc-date AT ROW 2.13 COL 29.8 COLON-ALIGNED
          LABEL "Дата"
           VIEW-AS TEXT
          SIZE 10 BY .67
     tt-c-wth-doc.fact-date AT ROW 2.13 COL 47.6 COLON-ALIGNED
          LABEL "Факт"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-date AT ROW 2.13 COL 67 COLON-ALIGNED
          LABEL "Смена"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-name AT ROW 2.13 COL 82 COLON-ALIGNED
          LABEL "№"
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-num AT ROW 2.13 COL 92 COLON-ALIGNED
          LABEL "П."
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.obj-code AT ROW 3.33 COL 18.3 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.5 BY .67
     for-object AT ROW 3.33 COL 29.8 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.bef-sum AT ROW 4.7 COL 11.6 COLON-ALIGNED
          LABEL "Сумма план"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt-c-wth-doc.aft-sum AT ROW 4.7 COL 42.9 COLON-ALIGNED
          LABEL "Сумма факт"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt-c-wth-doc.fact-sum AT ROW 4.77 COL 74.5 COLON-ALIGNED
          LABEL "Расхождение"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt-c-wth-doc.operator AT ROW 16 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person1 AT ROW 16 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.deliver AT ROW 17.2 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person2 AT ROW 17.2 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.receiver AT ROW 18.43 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person3 AT ROW 18.43 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.inv-prs4 AT ROW 19.57 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person4 AT ROW 19.57 COL 17.1 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.inv-prs5 AT ROW 20.8 COL 1.8 NO-LABEL
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-person5 AT ROW 20.8 COL 17.1 COLON-ALIGNED NO-LABEL
     "ЧЛЕНЫ ИНВЕНТАРИЗАЦИОННОЙ КОМИССИИ" VIEW-AS TEXT
          SIZE 34.1 BY 1 AT ROW 14.97 COL 19.4
          BGCOLOR 3 FGCOLOR 15
     SPACE(45.76) SKIP(5.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Инвентаризационная ведомость движения материальных ценностей: история"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_c-wth-line B "?" ? ub c-wth-line
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_person1 B "?" ? ub clients
      TABLE: buf_person2 B "?" ? ub clients
      TABLE: buf_person3 B "?" ? ub clients
      TABLE: buf_person4 B "?" ? ub clients
      TABLE: buf_person5 B "?" ? ub clients
      TABLE: buf_wth B "?" ? ub wealth
      TABLE: buf_wth-place B "?" ? ub wth-place
      TABLE: tt-c-wth-doc T "?" NO-UNDO ub c-wth-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines obj-type Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-wth-doc.aft-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.bef-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.corr-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.corr-user-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.deliver IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.inv-prs4 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.inv-prs5 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-c-wth-doc.obj-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.operator IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.receiver IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH buf_c-wth-line WHERE buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code
    and buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
    and buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num  NO-LOCK,
      EACH buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK,
      EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_c-wth-line.obj-type AND
buf_wth-place.obj-code = buf_c-wth-line.obj-code AND
buf_wth-place.w-p-code = buf_c-wth-line.w-p-code
 NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _JoinCode[1]      = "buf_c-wth-line.doc-code = Temp-Tables.tt-c-wth-doc.doc-code and buf_c-wth-line.corr-user-db-num = Temp-Tables.tt-c-wth-doc.corr-user-db-num  and buf_c-wth-line.chip-num = Temp-Tables.tt-c-wth-doc.chip-num "
     _JoinCode[2]      = "buf_wth.wth-code = buf_c-wth-line.wth-code"
     _JoinCode[3]      = "buf_wth-place.obj-type = buf_c-wth-line.obj-type AND
buf_wth-place.obj-code = buf_c-wth-line.obj-code AND
buf_wth-place.w-p-code = buf_c-wth-line.w-p-code
"
     _Query            is NOT OPENED
*/  /* BROWSE BR-lines */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-c-wth-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Инвентаризационная ведомость движения материальных ценностей: история */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чеки */
DO:
  DEFINE VARIABLE loc-ref-list as character no-undo.
  run str/chk-docs.w (
                 input parparentproc
                ,input '':U
                ,input 'out-code':U
                ,input ?
                ,input parobj-type
                ,input parobj-code
                ,input tt-c-wth-doc.doc-code
                ,input ''
                ,input 0 /*p-pay-desk*/
                ,input ?
                ,input ?
                ,input 0
                ,output loc-ref-list) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-doc-rec as recid no-undo .
define variable v-line-rec as recid no-undo .
 if not avail buf_c-wth-line then return no-apply.

  ASSIGN
  v-line-rec = RECID( buf_c-wth-line )
  v-doc-rec = recid(bf_c-wth-doc)
  .
  run str/wthcinva.w (input parparentproc,
                  INPUT {&lookup},
                  input v-doc-rec,
                  input-output v-LINE-REC
                  ) no-error.
  apply "entry" to br-lines.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
      run reposition-c-wth-doc in this-procedure  (input 'next':U) no-error .

  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
      run reposition-c-wth-doc in this-procedure (input 'prev':U ) no-error .

  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
    p-next-prev = "QUIT".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.deliver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.deliver Dialog-Frame
ON LEAVE OF tt-c-wth-doc.deliver IN FRAME Dialog-Frame /* deliver */
DO:
    FIND FIRST buf_person2 NO-LOCK WHERE
            buf_person2.obj-type = {&prs} AND
            buf_person2.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.deliver NO-ERROR.
  IF AVAIL buf_person2 THEN DO:
    DISPLAY
    buf_person2.obj-name @ for-person2
    WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.inv-prs4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.inv-prs4 Dialog-Frame
ON LEAVE OF tt-c-wth-doc.inv-prs4 IN FRAME Dialog-Frame /* inv-prs4 */
DO:
     FIND FIRST buf_person4 NO-LOCK WHERE
            buf_person4.obj-type = {&prs} AND
            buf_person4.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.inv-prs4 NO-ERROR.
  IF AVAIL buf_person4 THEN DO:
    DISPLAY
    buf_person4.obj-name @ for-person4
    WITH FRAME {&FRAME-NAME}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.inv-prs5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.inv-prs5 Dialog-Frame
ON LEAVE OF tt-c-wth-doc.inv-prs5 IN FRAME Dialog-Frame /* inv-prs5 */
DO:
   FIND FIRST buf_person5 NO-LOCK WHERE
            buf_person5.obj-type = {&prs} AND
            buf_person5.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.inv-prs5 NO-ERROR.
  IF AVAIL buf_person5 THEN DO:
    DISPLAY
    buf_person5.obj-name @ for-person5
    WITH FRAME {&FRAME-NAME}.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.operator Dialog-Frame
ON LEAVE OF tt-c-wth-doc.operator IN FRAME Dialog-Frame /* operator */
DO:
    FIND FIRST buf_person1 NO-LOCK WHERE
            buf_person1.obj-type = {&prs} AND
            buf_person1.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.operator NO-ERROR.
  IF AVAIL buf_person1 THEN DO:
    DISPLAY
    buf_person1.obj-name @ for-person1
    WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.receiver Dialog-Frame
ON LEAVE OF tt-c-wth-doc.receiver IN FRAME Dialog-Frame /* receiver */
DO:
   FIND FIRST buf_person3 NO-LOCK WHERE
            buf_person3.obj-type = {&prs} AND
            buf_person3.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.receiver NO-ERROR.
  IF AVAIL buf_person3 THEN DO:
    DISPLAY
    buf_person3.obj-name @ for-person3
    WITH FRAME {&FRAME-NAME}.
  END.

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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

/* зацикливание формы */
p-next-prev = '':U.
n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if par-mode <> {&lookup} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if not par-mode = {&lookup} then
    p-next-prev = "QUIT".
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
      message vss-workfile vss-revision vss-description skip
              "Неверный параметр вызова parobj-type/parobj-code"
      view-as alert-box ERROR.
      return error.
    end.
    if parcli-type <> '':U or parcli-code <> 0 then do:
      find first ub.clients No-LOCK WHERE
                  ub.clients.obj-type = parcli-type AND
                  ub.clients.obj-code = parcli-code No-ERROR.
      if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова parcli-type/parcli-code"
        view-as alert-box ERROR.
        return error.
      end.
    end.
    tt-c-wth-doc.obj-type:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char} +
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.

  Run fill-tables no-error.
  if error-status:error then return error.
  RUN Myenable.
  { gbl/mv-clmn.i
  &ext-col = 18
  &frame-name = "{&frame-name}"
  &browse-name = "br-lines"
  &start-column = "1"
  &prev-order-column_1 = "'1,2,3,4,5,6'"
  &prev-order-column-condition_1 = " var-peresort = no "
  &prev-order-column_2 = "'1,2,3,6,4,5'"
  &prev-order-column-condition_2 = " var-peresort = yes "
  }
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-peresort Dialog-Frame
PROCEDURE control-peresort :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT parameter par-peresort as logical no-undo.
if tt-c-wth-doc.auto-fill = yes and
can-find(first ub.chk-doc No-LOCK WHERE
                   ub.chk-doc.obj-type = tt-c-wth-doc.obj-type AND
                    ub.chk-doc.obj-code = tt-c-wth-doc.obj-code AND
                    ub.chk-doc.out-code = tt-c-wth-doc.doc-code AND
                    ub.chk-doc.chk-type = integer({&pay-transfer})) then do:
                    par-peresort = yes.

end.
else par-peresort = no.
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
  DISPLAY for-object for-person1 for-person2 for-person3 for-person4 for-person5
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY tt-c-wth-doc.obj-type tt-c-wth-doc.corr-date
          tt-c-wth-doc.corr-user-name tt-c-wth-doc.doc-code
          tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date
          tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code
          tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum tt-c-wth-doc.fact-sum
          tt-c-wth-doc.operator tt-c-wth-doc.deliver tt-c-wth-doc.receiver
          tt-c-wth-doc.inv-prs4 tt-c-wth-doc.inv-prs5
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-prev B-next B-Help BR-lines B-lookup B-chk
         tt-c-wth-doc.corr-date tt-c-wth-doc.corr-user-name
         tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date
         tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code
         for-object tt-c-wth-doc.bef-sum tt-c-wth-doc.aft-sum
         tt-c-wth-doc.fact-sum tt-c-wth-doc.operator for-person1
         tt-c-wth-doc.deliver for-person2 tt-c-wth-doc.receiver for-person3
         tt-c-wth-doc.inv-prs4 for-person4 tt-c-wth-doc.inv-prs5 for-person5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
for each tt-c-wth-doc:
    delete tt-c-wth-doc.
end.
  if par-mode = {&lookup} then do:
    FIND FIRST bf_c-wth-doc NO-LOCK WHERE
                recid(bf_c-wth-doc) = p-doc-rec.
  end.
  IF NOT AVAIL bf_c-wth-doc then
  return error.
  if bf_c-wth-doc.status_ = {&fact} and par-mode <> {&lookup} then do:
     message "Документ движения МЦ с N" bf_c-wth-doc.doc-code  "имеет статус" bf_c-wth-doc.status_ SKIP
             "Изменения не допускаются"
     view-as alert-box error.
     return error.
    end.
  create tt-c-wth-doc.
  buffer-copy bf_c-wth-doc to tt-c-wth-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-c-wth-doc.obj-type AND
                buf_obj.obj-code = tt-c-wth-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный объект" bf_c-wth-doc.obj-type bf_c-wth-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.

    FIND FIRST buf_clients No-LOCK WHERe
                buf_clients.obj-type = tt-c-wth-doc.cli-type AND
                buf_clients.obj-code = tt-c-wth-doc.cli-code No-ERROR.
   if not avail buf_clients
      or NOT (buf_clients.obj-type = {&cmp} AND buf_clients.obj-code = parhost-code) then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный контрагент" bf_c-wth-doc.cli-type bf_c-wth-doc.cli-code
      view-as alert-box ERROR.
      return error.
   end.

    FIND FIRST buf_person1 No-LOCK WHERe
                        buf_person1.obj-type = {&prs} AND
                        buf_person1.obj-code = tt-c-wth-doc.operator No-ERROR.
    FIND FIRST buf_person2 No-LOCK WHERe
                        buf_person2.obj-type = {&prs} AND
                        buf_person2.obj-code = tt-c-wth-doc.deliver No-ERROR.
    FIND FIRST buf_person3 No-LOCK WHERe
                        buf_person3.obj-type = {&prs} AND
                        buf_person3.obj-code = tt-c-wth-doc.receiver No-ERROR.
    FIND FIRST buf_person4 No-LOCK WHERe
                        buf_person4.obj-type = {&prs} AND
                        buf_person4.obj-code = tt-c-wth-doc.inv-prs4 No-ERROR.
    FIND FIRST buf_person5 No-LOCK WHERe
                        buf_person5.obj-type = {&prs} AND
                        buf_person5.obj-code = tt-c-wth-doc.inv-prs5 No-ERROR.

/*
if tt-c-wth-doc.auto-fill = yes then do:
  { str/lockawth.i }
end.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-peresort Dialog-Frame
PROCEDURE lock-peresort :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-peresort as logical no-undo.
/*run re-move-clmnbr-lines.*/
CASE par-peresort :
    when yes then do:
        HIDE
        tt-c-wth-doc.aft-sum in frame {&frame-name}
        tt-c-wth-doc.bef-sum in frame {&frame-name}.
        DISPLAY tt-c-wth-doc.fact-sum
        with frame {&frame-name}.
    end.
    when no then do:
        DISPLAY
        tt-c-wth-doc.bef-sum
        tt-c-wth-doc.aft-sum when NOT tt-c-wth-doc.status_ = {&wayb}
        with frame {&frame-name}.
        if tt-c-wth-doc.status_ = {&wayb} then
        HIDE
        tt-c-wth-doc.fact-sum
        in frame {&frame-name}.

    end.
END CASE.
/*RUN start-mv-clmnbr-lines.*/
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
 buf_c-wth-line.fact-sum:READ-ONLY IN BROWSE BR-lines = YES.
  IF AVAILABLE buf_person1 THEN
    DISPLAY buf_person1.obj-name @ for-person1
      WITH FRAME {&frame-name} .
  IF AVAILABLE buf_person2 THEN
    DISPLAY buf_person2.obj-name @ for-person2
      WITH FRAME {&frame-name} .
  IF AVAILABLE buf_person3 THEN
    DISPLAY buf_person3.obj-name @ for-person3
      WITH FRAME {&frame-name} .
  IF AVAILABLE buf_person4 THEN
    DISPLAY buf_person4.obj-name @ for-person4
      WITH FRAME {&frame-name} .
  IF AVAILABLE buf_person5 THEN
    DISPLAY buf_person5.obj-name @ for-person5
      WITH FRAME {&frame-name} .
  IF AVAILABLE buf_obj THEN
    DISPLAY buf_obj.obj-name @ for-object
      WITH FRAME {&frame-name} .
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY
    tt-c-wth-doc.fact-date
    tt-c-wth-doc.doc-code
    tt-c-wth-doc.doc-date
    tt-c-wth-doc.shift-name
    tt-c-wth-doc.shift-num
    tt-c-wth-doc.shift-date
    tt-c-wth-doc.obj-code
    tt-c-wth-doc.obj-type
    tt-c-wth-doc.bef-sum
    tt-c-wth-doc.aft-sum
    tt-c-wth-doc.fact-sum
    tt-c-wth-doc.operator
    tt-c-wth-doc.deliver
    tt-c-wth-doc.receiver
    tt-c-wth-doc.inv-prs4
    tt-c-wth-doc.inv-prs5
    usrfulnf(tt-c-wth-doc.corr-user-name) @ tt-c-wth-doc.corr-user-name
    tt-c-wth-doc.corr-date
    WITH FRAME {&frame-name} .
    IF par-mode = {&lookup}  THEN DO:
      assign
      b-quit:label = "&Выход"
      b-quit:col = 1
      .
      ENABLE
      B-Prev
      B-Next
      b-quit
      WITH FRAME {&FRAME-NAME}.
      HIDE
      tt-c-wth-doc.fact-date IN FRAME {&FRAME-NAME}
      .
    END.
    ENABLE
    b-help
    br-lines
    b-lookup
    /*b-chk when tt-c-wth-doc.auto-fill*/
    WITH FRAME {&FRAME-NAME}.
    Hide b-chk
    in frame {&frame-name}.
    run control-peresort(output var-peresort) no-error.
    run lock-peresort(input var-peresort) no-error.
    {&OPEN-QUERY-BR-lines}
    REPOSITION br-lines TO ROW 1 NO-ERROR.
    APPLY "ENTRY":U TO br-lines IN FRAME {&FRAME-NAME}.
    APPLY "VALUE-CHANGED":U TO br-lines IN FRAME {&FRAME-NAME}.
    ASSIGN
    FRAME {&FRAME-NAME} :TITLE = substitute("Удаленная инвентаризационная ведомость движения материальных ценностей № &1  - &2"
                                            , tt-c-wth-doc.doc-code
                                            , CAPS( par-mode )).
     .
  VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-c-wth-doc Dialog-Frame
PROCEDURE reposition-c-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-c-wth-doc-recid as recid no-undo .

do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-c-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-wth-doc-recid
      ).

    if v-new-c-wth-doc-recid <> ?
    then do:
      define buffer buf_c-wth-doc for ub.c-wth-doc .
      find first buf_c-wth-doc no-lock
        where recid(buf_c-wth-doc) = v-new-c-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-c-wth-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME