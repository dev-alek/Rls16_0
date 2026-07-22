&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_wth FOR ub.wealth.
DEFINE BUFFER buf_wth-line FOR ub.wth-line.
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-wth-doc NO-UNDO LIKE ub.wth-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Перемещение МЦ: добавление, изменение, просмотр инвентаризации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/05
Author: Bakhtadze Natalya
Creation date: 09/21/05


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
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec as recid no-undo.
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
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }

/*DEFINE SHARED QUERY BR-docs FOR wth-doc SCROLLING.*/
define buffer bf_wth-doc for ub.wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE var-peresort as logical no-undo.
define variable glog as logical no-undo .
define variable ref-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define variable parext-doc-name as character no-undo.
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
define buffer cli-buf for ub.clients.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i inv }.

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
&Scoped-define INTERNAL-TABLES buf_wth-line buf_wth buf_wth-place ~
tt-wth-doc

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines buf_wth-line.wth-code buf_wth.wth-name buf_wth-place.w-p-name buf_wth-line.bef-sum buf_wth-line.aft-sum buf_wth-line.fact-sum
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines buf_wth-line.fact-sum
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines buf_wth-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines buf_wth-line
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK, ~
             EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK, ~
             EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_wth-line.obj-type AND buf_wth-place.obj-code = buf_wth-line.obj-code AND buf_wth-place.w-p-code = buf_wth-line.w-p-code  NO-LOCK
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK, ~
             EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK, ~
             EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_wth-line.obj-type AND buf_wth-place.obj-code = buf_wth-line.obj-code AND buf_wth-place.w-p-code = buf_wth-line.w-p-code  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-lines buf_wth-line buf_wth buf_wth-place
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines buf_wth-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-lines buf_wth
&Scoped-define THIRD-TABLE-IN-QUERY-BR-lines buf_wth-place


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-wth-doc.doc-code ~
tt-wth-doc.doc-date tt-wth-doc.fact-date tt-wth-doc.shift-date ~
tt-wth-doc.shift-name tt-wth-doc.shift-num tt-wth-doc.obj-type ~
tt-wth-doc.obj-code tt-wth-doc.bef-sum tt-wth-doc.aft-sum ~
tt-wth-doc.fact-sum tt-wth-doc.operator tt-wth-doc.deliver ~
tt-wth-doc.receiver tt-wth-doc.inv-prs4 tt-wth-doc.inv-prs5
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-wth-doc.doc-date ~
tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name ~
tt-wth-doc.shift-num tt-wth-doc.obj-code tt-wth-doc.bef-sum ~
tt-wth-doc.aft-sum tt-wth-doc.fact-sum tt-wth-doc.operator ~
tt-wth-doc.deliver tt-wth-doc.receiver tt-wth-doc.inv-prs4 ~
tt-wth-doc.inv-prs5
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-wth-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-wth-doc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-wth-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-wth-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-wth-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-wth-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-doc.doc-date tt-wth-doc.fact-date ~
tt-wth-doc.shift-date tt-wth-doc.shift-name tt-wth-doc.shift-num ~
tt-wth-doc.obj-code tt-wth-doc.bef-sum tt-wth-doc.aft-sum ~
tt-wth-doc.fact-sum tt-wth-doc.operator tt-wth-doc.deliver ~
tt-wth-doc.receiver tt-wth-doc.inv-prs4 tt-wth-doc.inv-prs5
&Scoped-define ENABLED-TABLES tt-wth-doc
&Scoped-define FIRST-ENABLED-TABLE tt-wth-doc
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-prev B-next B-Help BR-lines ~
B-add B-lookup B-chg B-del B-chk B-hist B-person1 B-person2 B-person3 ~
B-person4 B-person5 for-object operator-name deliver-name receiver-name ~
inv-prs4-name inv-prs5-name
&Scoped-Define DISPLAYED-FIELDS tt-wth-doc.doc-code tt-wth-doc.doc-date ~
tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name ~
tt-wth-doc.shift-num tt-wth-doc.obj-type tt-wth-doc.obj-code ~
tt-wth-doc.bef-sum tt-wth-doc.aft-sum tt-wth-doc.fact-sum ~
tt-wth-doc.operator tt-wth-doc.deliver tt-wth-doc.receiver ~
tt-wth-doc.inv-prs4 tt-wth-doc.inv-prs5
&Scoped-define DISPLAYED-TABLES tt-wth-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-doc
&Scoped-Define DISPLAYED-OBJECTS for-object operator-name deliver-name ~
receiver-name inv-prs4-name inv-prs5-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chk
     LABEL "Че&ки"
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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-person1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-person2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-person3
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-person4
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-person5
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE deliver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE inv-prs4-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE inv-prs5-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE operator-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE receiver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-lines FOR
      buf_wth-line,
      buf_wth,
      buf_wth-place SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-wth-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines NO-LOCK DISPLAY
      buf_wth-line.wth-code FORMAT ">>>>>>>>9":U
      buf_wth.wth-name FORMAT "X(20)":U
      buf_wth-place.w-p-name FORMAT "X(20)":U
      buf_wth-line.bef-sum COLUMN-LABEL "Сумма план" FORMAT "->,>>>,>>>,>>9.99":U
      buf_wth-line.aft-sum COLUMN-LABEL "Сумма факт" FORMAT "->,>>>,>>>,>>9.99":U
      buf_wth-line.fact-sum COLUMN-LABEL "Расхождение" FORMAT "->,>>>,>>>,>>9.99":U
  ENABLE
      buf_wth-line.fact-sum
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.8.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-prev AT ROW 1 COL 40
     B-next AT ROW 1 COL 44
     B-Help AT ROW 1 COL 95
     tt-wth-doc.doc-code AT ROW 2.13 COL 7.3 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 16.1 BY 1
          FGCOLOR 4
     tt-wth-doc.doc-date AT ROW 2.13 COL 29.8 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-doc.fact-date AT ROW 2.13 COL 48.4 COLON-ALIGNED
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-date AT ROW 2.13 COL 66.5 COLON-ALIGNED
          LABEL "Смена"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-doc.shift-name AT ROW 2.13 COL 82 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-num AT ROW 2.13 COL 92.5 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-doc.obj-type AT ROW 3.33 COL 11 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.1 BY 1
     tt-wth-doc.obj-code AT ROW 3.33 COL 18.3 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1.13
     tt-wth-doc.bef-sum AT ROW 4.7 COL 11.6 COLON-ALIGNED
          LABEL "Сумма план"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-wth-doc.aft-sum AT ROW 4.7 COL 42.9 COLON-ALIGNED
          LABEL "Сумма факт"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-wth-doc.fact-sum AT ROW 4.77 COL 74.5 COLON-ALIGNED
          LABEL "Расхождение"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     BR-lines AT ROW 5.93 COL 1
     B-add AT ROW 13.83 COL 1
     B-lookup AT ROW 13.83 COL 11
     B-chg AT ROW 13.83 COL 21
     B-del AT ROW 13.83 COL 31
     B-chk AT ROW 13.83 COL 41
     B-hist AT ROW 13.83 COL 71
     tt-wth-doc.operator AT ROW 16 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person1 AT ROW 16 COL 15
     tt-wth-doc.deliver AT ROW 17.2 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person2 AT ROW 17.2 COL 15
     tt-wth-doc.receiver AT ROW 18.43 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person3 AT ROW 18.43 COL 15
     B-person4 AT ROW 19.5 COL 15
     tt-wth-doc.inv-prs4 AT ROW 19.57 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     tt-wth-doc.inv-prs5 AT ROW 20.8 COL 1.8 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.3 BY 1
     B-person5 AT ROW 20.8 COL 15
     for-object AT ROW 3.33 COL 29.8 COLON-ALIGNED NO-LABEL
     operator-name AT ROW 16 COL 17.1 COLON-ALIGNED NO-LABEL
     deliver-name AT ROW 17.2 COL 17.1 COLON-ALIGNED NO-LABEL
     receiver-name AT ROW 18.43 COL 17.1 COLON-ALIGNED NO-LABEL
     inv-prs4-name AT ROW 19.57 COL 17.1 COLON-ALIGNED NO-LABEL
     inv-prs5-name AT ROW 20.8 COL 17.1 COLON-ALIGNED NO-LABEL
     "ЧЛЕНЫ ИНВЕНТАРИЗАЦИОННОЙ КОМИССИИ" VIEW-AS TEXT
          SIZE 34.1 BY 1 AT ROW 14.97 COL 19.4
          BGCOLOR 3 FGCOLOR 15
     SPACE(45.49) SKIP(5.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Инвентаризационная ведомость движения материальных ценностей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_wth B "?" ? ub wealth
      TABLE: buf_wth-line B "?" ? ub wth-line
      TABLE: buf_wth-place B "?" ? ub wth-place
      TABLE: tt-wth-doc T "?" NO-UNDO ub wth-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines fact-sum Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-doc.aft-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.bef-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.deliver IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-wth-doc.doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-wth-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-wth-doc.obj-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-doc.operator IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-wth-doc.receiver IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-wth-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,
      EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK,
      EACH buf_wth-place WHERE buf_wth-place.obj-type = buf_wth-line.obj-type AND
buf_wth-place.obj-code = buf_wth-line.obj-code AND
buf_wth-place.w-p-code = buf_wth-line.w-p-code
 NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _JoinCode[1]      = "buf_wth-line.doc-code = Temp-Tables.tt-wth-doc.doc-code"
     _JoinCode[2]      = "buf_wth.wth-code = buf_wth-line.wth-code"
     _JoinCode[3]      = "buf_wth-place.obj-type = buf_wth-line.obj-type AND
buf_wth-place.obj-code = buf_wth-line.obj-code AND
buf_wth-place.w-p-code = buf_wth-line.w-p-code
"
     _Query            is NOT OPENED
*/  /* BROWSE BR-lines */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-wth-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Инвентаризационная ведомость движения материальных ценностей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  run proc-b-add in this-procedure  no-error.
  if error-status:error
  or return-value = 'error'
  then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
{ gbl/stdbtn.i }
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.
  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  .
  run proc-save-doc(no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return no-apply.
  run str/wth-inva.w ( input parparentproc,
                   INPUT {&update},
                   input v-doc-rec,
                   input-output v-LINE-REC) no-error.
  ASSIGN
  glog = br-lines:REFRESH( ).
  apply "entry" to br-lines.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чеки */
DO:
{ gbl/stdbtn.i }
  DEFINE VARIABLE loc-ref-list as character no-undo.
  run str/chk-docs.w (
                  input parparentproc
                 ,input '':U
                 ,input 'out-code':U
                 ,input ?
                 ,input parobj-type
                 ,input parobj-code
                 ,input tt-wth-doc.doc-code
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


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
 run proc-save-doc(if tt-wth-doc.auto-fill then no else yes) No-ERROR.
 if error-status:error
 or return-value = 'error'
 then return no-apply.
 p-doc-rec = v-doc-rec .
 APPLY "GO":U TO FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
{ gbl/stdbtn.i }
define variable v-rid-list as character no-undo .
    run str/wthcdocs.w
      (
       input  parparentproc
      ,input  'b-add'
      ,input  'one':U /*p-mode*/
      ,input  tt-wth-doc.host-code
      ,input  tt-wth-doc.obj-type
      ,input  tt-wth-doc.obj-code
      ,input  '':U
      ,input  0
      ,input '':U /*p-doc-type*/
      ,input  tt-wth-doc.doc-code
      ,output v-rid-list
      ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
{ gbl/stdbtn.i }
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .

 if not avail buf_wth-line then return no-apply.

  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  .
  run str/wth-inva.w (input parparentproc,
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
{ gbl/stdbtn.i }
       run reposition-wth-doc in this-procedure
  (input 'next':U
  ).



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-person1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-person1 Dialog-Frame
ON CHOOSE OF B-person1 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("operator", "button").
  apply "entry" to tt-wth-doc.operator in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-person2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-person2 Dialog-Frame
ON CHOOSE OF B-person2 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("deliver", "button").
  apply "entry" to tt-wth-doc.deliver in FRAME {&FRAME-NAME}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-person3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-person3 Dialog-Frame
ON CHOOSE OF B-person3 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("receiver", "button").
  apply "entry" to tt-wth-doc.receiver in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-person4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-person4 Dialog-Frame
ON CHOOSE OF B-person4 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("inv-prs4", "button").
  apply "entry" to tt-wth-doc.inv-prs4 in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-person5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-person5 Dialog-Frame
ON CHOOSE OF B-person5 IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk ("inv-prs5", "button").
  apply "entry" to tt-wth-doc.inv-prs5 in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
{ gbl/stdbtn.i }
       run reposition-wth-doc in this-procedure
  (input 'prev':U
  ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
{ gbl/stdbtn.i }
    IF par-mode = {&add-def} THEN DO:
    IF CAN-FIND( FIRST ub.wth-line NO-LOCK WHERE
                       ub.wth-line.doc-code = bf_wth-doc.doc-code ) THEN DO:
      MESSAGE
        "Документ не будет сохранен, а вся введенная Вами информация будет потеряна!" SKIP
        "Для того, чтобы сохранить документ, нужно нажать кнопку ~"" +
        B-exit:LABEL IN FRAME {&FRAME-NAME} + "~"." SKIP( 1 )
        "Вы уверены, что хотите выйти БЕЗ СОХРАНЕНИЯ?" SKIP
        "YES[ДА] - Выйти БЕЗ СОХРАНЕНИЯ;" SKIP
        "NO[НЕТ] - Остаться в документе."
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Выход из документа без сохранения" UPDATE glog.
      IF glog = NO THEN DO:
        RETURN NO-APPLY.
      END.
    END.
    DO TRANSACTION ON ERROR UNDO, LEAVE :
      FIND CURRENT bf_wth-doc EXCLUSIVE-LOCK.
      DELETE bf_wth-doc.
      p-doc-rec = ?.
    END. /* TRANSACTION */
  END.
    p-next-prev = "QUIT".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.deliver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.deliver Dialog-Frame
ON LEAVE OF tt-wth-doc.deliver IN FRAME Dialog-Frame /* deliver */
DO:
  if input frame {&frame-name} tt-wth-doc.deliver <> tt-wth-doc.deliver then do:
    run local-psn-chk ("deliver", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.deliver Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.deliver IN FRAME Dialog-Frame /* deliver */
OR return OF tt-wth-doc.deliver IN FRAME {&frame-name} DO:
  run local-psn-chk ("deliver", "ret-mouse").
  apply "entry" to tt-wth-doc.deliver in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.inv-prs4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.inv-prs4 Dialog-Frame
ON LEAVE OF tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame /* inv-prs4 */
DO:
   if input frame {&frame-name} tt-wth-doc.inv-prs4 <> tt-wth-doc.inv-prs4 then do:
    run local-psn-chk ("inv-prs4", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.inv-prs4 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.inv-prs4 IN FRAME Dialog-Frame /* inv-prs4 */
OR return OF tt-wth-doc.inv-prs4 IN FRAME {&frame-name} DO:
  run local-psn-chk ("inv-prs4", "ret-mouse").
  apply "entry" to tt-wth-doc.inv-prs4 in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.inv-prs5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.inv-prs5 Dialog-Frame
ON LEAVE OF tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame /* inv-prs5 */
DO:
    if input frame {&frame-name} tt-wth-doc.inv-prs5 <> tt-wth-doc.inv-prs5 then do:
     run local-psn-chk ("inv-prs5", "leave").
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.inv-prs5 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.inv-prs5 IN FRAME Dialog-Frame /* inv-prs5 */
OR return OF tt-wth-doc.inv-prs5 IN FRAME {&frame-name} DO:
  run local-psn-chk ("inv-prs5", "ret-mouse").
  apply "entry" to tt-wth-doc.inv-prs5 in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.operator Dialog-Frame
ON LEAVE OF tt-wth-doc.operator IN FRAME Dialog-Frame /* operator */
DO:
  if input frame {&frame-name} tt-wth-doc.operator <> tt-wth-doc.operator then do:
    run local-psn-chk ("operator", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.operator Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.operator IN FRAME Dialog-Frame /* operator */
OR return OF tt-wth-doc.operator IN FRAME {&frame-name} DO:
  run local-psn-chk ("operaror", "ret-mouse").
  apply "entry" to tt-wth-doc.operator in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-doc.receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.receiver Dialog-Frame
ON LEAVE OF tt-wth-doc.receiver IN FRAME Dialog-Frame /* receiver */
DO:
  if input frame {&frame-name} tt-wth-doc.receiver <> tt-wth-doc.receiver then do:
    run local-psn-chk ("receiver", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-doc.receiver Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.receiver IN FRAME Dialog-Frame /* receiver */
OR return OF tt-wth-doc.receiver IN FRAME {&frame-name} DO:
  run local-psn-chk ("receiver", "ret-mouse").
  apply "entry" to tt-wth-doc.receiver in frame {&frame-name}.
  return no-apply.

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

{ gbl/getcntxt.i get }
/* зацикливание формы */
p-next-prev = "".
n-p: do while p-next-prev = "":U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
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
    tt-wth-doc.obj-type:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char} +
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.

  Run fill-tables no-error.
  if error-status:error then return error.
  RUN Myenable in this-procedure .
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
if tt-wth-doc.auto-fill = yes and
can-find(first ub.chk-doc No-LOCK WHERE
                   ub.chk-doc.obj-type = tt-wth-doc.obj-type AND
                    ub.chk-doc.obj-code = tt-wth-doc.obj-code AND
                    ub.chk-doc.out-code = tt-wth-doc.doc-code AND
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
  DISPLAY for-object operator-name deliver-name receiver-name inv-prs4-name
          inv-prs5-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-doc THEN
    DISPLAY tt-wth-doc.doc-code tt-wth-doc.doc-date tt-wth-doc.fact-date
          tt-wth-doc.shift-date tt-wth-doc.shift-name tt-wth-doc.shift-num
          tt-wth-doc.obj-type tt-wth-doc.obj-code tt-wth-doc.bef-sum
          tt-wth-doc.aft-sum tt-wth-doc.fact-sum tt-wth-doc.operator
          tt-wth-doc.deliver tt-wth-doc.receiver tt-wth-doc.inv-prs4
          tt-wth-doc.inv-prs5
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-prev B-next B-Help tt-wth-doc.doc-date
         tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name
         tt-wth-doc.shift-num tt-wth-doc.obj-code tt-wth-doc.bef-sum
         tt-wth-doc.aft-sum tt-wth-doc.fact-sum BR-lines B-add B-lookup B-chg
         B-del B-chk B-hist tt-wth-doc.operator B-person1 tt-wth-doc.deliver
         B-person2 tt-wth-doc.receiver B-person3 B-person4 tt-wth-doc.inv-prs4
         tt-wth-doc.inv-prs5 B-person5 for-object operator-name deliver-name
         receiver-name inv-prs4-name inv-prs5-name
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
for each tt-wth-doc:
    delete tt-wth-doc.
end.
IF par-mode = {&add-def} then do:
   run gbl/factdate.p (
                    INPUT        parobj-type,
                    INPUT        parobj-code,
                    INPUT-OUTPUT f-date,
                    INPUT-OUTPUT f-time,
                    INPUT-OUTPUT s-date,
                    INPUT-OUTPUT s-num,
                    INPUT-OUTPUT s-name,
                    INPUT        YES
                  ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
      { trg/wth-docr.i tt-wth-doc {&inventory} NO NO " " v-cntxt-userid {&WDEDT_Inv} }
      ASSIGN
      tt-wth-doc.shift-date = s-date
      tt-wth-doc.shift-num  = s-num
      tt-wth-doc.shift-name = s-name
      tt-wth-doc.doc-date   = f-date
      tt-wth-doc.operator   = 0
      tt-wth-doc.receiver   = 0
      tt-wth-doc.deliver    = 0
      tt-wth-doc.inv-prs4   = 0
      tt-wth-doc.inv-prs5   = 0
      tt-wth-doc.auto-fill  = parauto-fill
      .
      { trg/wth-docr.i bf_wth-doc {&inventory} NO NO tt-wth-doc.doc-code v-cntxt-userid {&WDEDT_Inv} }
      ASSIGN
      bf_wth-doc.shift-date = s-date
      bf_wth-doc.shift-num  = s-num
      bf_wth-doc.shift-name = s-name
      bf_wth-doc.doc-date   = f-date
      bf_wth-doc.operator   = 0
      bf_wth-doc.receiver   = 0
      bf_wth-doc.deliver    = 0
      bf_wth-doc.inv-prs4    = 0
      bf_wth-doc.inv-prs5    = 0
      bf_wth-doc.auto-fill = parauto-fill
      v-doc-rec = recid(bf_wth-doc)
      .
    END.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = parobj-type AND
                buf_obj.obj-code = parobj-code No-ERROR.
end.
else do:
  if par-mode = {&lookup} then do:
    FIND FIRST bf_wth-doc NO-LOCK WHERE
                recid(bf_wth-doc) = p-doc-rec.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
      FIND FIRST bf_wth-doc EXCLUSIVE-LOCK WHERE
                 recid(bf_wth-doc) = p-doc-rec.
    END.
  END.
  IF NOT AVAIL bf_wth-doc then
  return error.
  v-doc-rec = p-doc-rec.
  if bf_wth-doc.status_ = {&fact} and par-mode <> {&lookup} then do:
     message "Документ движения МЦ с N" bf_wth-doc.doc-code  "имеет статус" bf_wth-doc.status_ SKIP
             "Изменения не допускаются"
     view-as alert-box error.
     return error.
    end.
  create tt-wth-doc.
  buffer-copy bf_wth-doc to tt-wth-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-wth-doc.obj-type AND
                buf_obj.obj-code = tt-wth-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Документ движения МЦ N" bf_wth-doc.doc-code  skip
              "Неверный объект" bf_wth-doc.obj-type bf_wth-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.

    FIND FIRST buf_clients No-LOCK WHERe
                buf_clients.obj-type = tt-wth-doc.cli-type AND
                buf_clients.obj-code = tt-wth-doc.cli-code No-ERROR.
   if not avail buf_clients
      or NOT (buf_clients.obj-type = {&cmp} AND buf_clients.obj-code = parhost-code) then do:
      message "Документ движения МЦ N" bf_wth-doc.doc-code  skip
              "Неверный контрагент" bf_wth-doc.cli-type bf_wth-doc.cli-code
      view-as alert-box ERROR.
      return error.
   end.
end.

if tt-wth-doc.auto-fill = yes then do:
  { str/lockawth.i }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk Dialog-Frame
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "operator" and p-action = "ret-mouse" then do:
   { str/psn-chk.i operator ret-mouse tt-wth-doc ref-rec }
end.
if p-man = "operator" and p-action = "button" then do:
   { str/psn-chk.i operator button tt-wth-doc ref-rec }
end.
if p-man = "operator" and p-action = "leave" then do:
   { str/psn-chk.i operator leave tt-wth-doc ref-rec }
end.
if p-man = "deliver" and p-action = "ret-mouse" then do:
   { str/psn-chk.i deliver ret-mouse tt-wth-doc ref-rec }
end.
if p-man = "deliver" and p-action = "button" then do:
   { str/psn-chk.i deliver button tt-wth-doc ref-rec }
end.
if p-man = "deliver" and p-action = "leave" then do:
   { str/psn-chk.i deliver leave tt-wth-doc ref-rec }
end.
if p-man = "receiver" and p-action = "ret-mouse" then do:
   { str/psn-chk.i receiver ret-mouse tt-wth-doc ref-rec }
end.
if p-man = "receiver" and p-action = "button" then do:
   { str/psn-chk.i receiver button tt-wth-doc ref-rec }
end.
if p-man = "receiver" and p-action = "leave" then do:
   { str/psn-chk.i receiver leave tt-wth-doc ref-rec }
end.
if p-man = "inv-prs4" and p-action = "ret-mouse" then do:
  { str/psn-chk.i inv-prs4 ret-mouse tt-wth-doc ref-rec }
end.
if p-man = "inv-prs4" and p-action = "button" then do:
  { str/psn-chk.i inv-prs4 button tt-wth-doc ref-rec }
end.
if p-man = "inv-prs4" and p-action = "leave" then do:
  { str/psn-chk.i inv-prs4 leave tt-wth-doc ref-rec }
end.
if p-man = "inv-prs5" and p-action = "ret-mouse" then do:
  { str/psn-chk.i inv-prs5 ret-mouse tt-wth-doc ref-rec }
end.
if p-man = "inv-prs5" and p-action = "button" then do:
  { str/psn-chk.i inv-prs5 button tt-wth-doc ref-rec }
end.
if p-man = "inv-prs5" and p-action = "leave" then do:
  { str/psn-chk.i inv-prs5 leave tt-wth-doc ref-rec }
end.

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
        tt-wth-doc.aft-sum in frame {&frame-name}
        tt-wth-doc.bef-sum in frame {&frame-name}.
        DISPLAY tt-wth-doc.fact-sum
        with frame {&frame-name}.
    end.
    when no then do:
        DISPLAY
        tt-wth-doc.bef-sum
        tt-wth-doc.aft-sum when NOT tt-wth-doc.status_ = {&wayb}
        with frame {&frame-name}.
        if tt-wth-doc.status_ = {&wayb} then
        HIDE
        tt-wth-doc.fact-sum
        in frame {&frame-name}.

    end.
END CASE.
/*RUN start-mv-clmnbr-lines.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
buf_wth-line.fact-sum:READ-ONLY IN BROWSE BR-lines = YES.
{ str/psn-chk.i operator on tt-wth-doc ref-rec }
{ str/psn-chk.i deliver on tt-wth-doc ref-rec }
{ str/psn-chk.i receiver on tt-wth-doc ref-rec }
{ str/psn-chk.i inv-prs4 on tt-wth-doc ref-rec }
{ str/psn-chk.i inv-prs5 on tt-wth-doc ref-rec }

  IF AVAILABLE buf_obj THEN
    DISPLAY buf_obj.obj-name @ for-object
      WITH FRAME {&frame-name}.
  IF AVAILABLE tt-wth-doc THEN
    DISPLAY
    tt-wth-doc.fact-date
    tt-wth-doc.doc-code
    tt-wth-doc.doc-date
    tt-wth-doc.shift-num
    tt-wth-doc.shift-name
    tt-wth-doc.shift-date
    tt-wth-doc.obj-code
    tt-wth-doc.obj-type
    tt-wth-doc.bef-sum
    tt-wth-doc.aft-sum
    tt-wth-doc.fact-sum
    tt-wth-doc.operator
    tt-wth-doc.deliver
    tt-wth-doc.receiver
    tt-wth-doc.inv-prs4
    tt-wth-doc.inv-prs5
    WITH FRAME {&frame-name}.
    IF par-mode = {&add-def} OR
        par-mode = {&update} THEN DO:
      IF par-mode = {&add-def} THEN DO:
        ENABLE
        tt-wth-doc.doc-date
        b-add
        b-del
        b-chg when Not tt-wth-doc.auto-fill
        b-quit
        WITH FRAME {&FRAME-NAME}.
        HIDE
        tt-wth-doc.fact-date IN FRAME {&FRAME-NAME}
        tt-wth-doc.aft-sum  IN FRAME {&FRAME-NAME}
        tt-wth-doc.fact-sum  IN FRAME {&FRAME-NAME}
        .
      END.
      ELSE DO:
           b-exit:label = "&Выход".
        IF tt-wth-doc.status_ = {&wayb}      THEN DO:
            ENABLE
            tt-wth-doc.doc-date
            b-add
            b-del
            b-chg when Not tt-wth-doc.auto-fill
            WITH FRAME {&FRAME-NAME}.
            HIDE
            b-quit
            tt-wth-doc.fact-date IN FRAME {&FRAME-NAME}
            tt-wth-doc.fact-sum  IN FRAME {&FRAME-NAME}
                        tt-wth-doc.aft-sum  IN FRAME {&FRAME-NAME}
            .
        END.
        ELSE IF tt-wth-doc.status_ = {&permitted} THEN DO:
          HIDE
          tt-wth-doc.fact-date
          IN FRAME {&FRAME-NAME}.
          ENABLE
          tt-wth-doc.aft-sum
          b-chg when Not tt-wth-doc.auto-fill
          WITH FRAME {&FRAME-NAME}.
        END.
      END. /*update*/
      ENABLE
      tt-wth-doc.operator
      tt-wth-doc.deliver
      tt-wth-doc.receiver
      tt-wth-doc.inv-prs4
      tt-wth-doc.inv-prs5
      b-person1
      b-person2
      b-person3
      b-person4
      b-person5
      B-exit
      b-lookup
      WITH FRAME {&FRAME-NAME}.
      HIDE
      b-prev IN FRAME {&FRAME-NAME}
      B-Next IN FRAME {&FRAME-NAME}
      .

    END. /*update add-def*/
    ELSE IF par-mode = {&lookup}  THEN DO:
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
      b-exit
      B-person1 IN FRAME {&FRAME-NAME}
      B-person2  IN FRAME {&FRAME-NAME}
      B-person3 IN FRAME {&FRAME-NAME}
      B-person4 IN FRAME {&FRAME-NAME}
      B-person5 IN FRAME {&FRAME-NAME}
      tt-wth-doc.fact-date IN FRAME {&FRAME-NAME}
      .
    END.
    ENABLE
    b-help
    br-lines
    b-lookup
    b-hist when par-mode <> {&add-def}
    b-chk when tt-wth-doc.auto-fill
    WITH FRAME {&FRAME-NAME}.
    run control-peresort(output var-peresort) no-error.
    run lock-peresort(input var-peresort) no-error.
    {&OPEN-QUERY-BR-lines}
    REPOSITION br-lines TO ROW 1 NO-ERROR.
    APPLY "ENTRY":U TO br-lines IN FRAME {&FRAME-NAME}.
    APPLY "VALUE-CHANGED":U TO br-lines IN FRAME {&FRAME-NAME}.
    parext-doc-name = ENTRY(LOOKUP(parext-type, {&WDEDT_List}), {&WDEDT_List-full}) no-error.

    assign
    FRAME {&FRAME-NAME} :TITLE = SUBSTITUTE("Инвентаризационная ведомость движения материальных ценностей № &1  - &2"
                                             ,tt-wth-doc.doc-code
                                             ,CAPS( parext-doc-name )).

    VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE valid-chk-type-list as character no-undo .
DEFINE VARIABLE valid-w-p-code like ub.wth-place.w-p-code .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE ii-ok as integer no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-line-rec as recid no-undo .

define buffer what_chk-doc  for ub.chk-doc .
define buffer buf_chk-doc  for ub.chk-doc .
define buffer cash_wth-place for ub.wth-place.
run proc-save-doc(no) No-ERROR.
if error-status:error
or return-value = 'error'
then return error.
CASE tt-wth-doc.auto-fill:
  when no then do:
    assign
    v-doc-rec = recid(bf_wth-doc)
    v-line-rec = ?
    .
    run str/wth-inva.w (input parparentproc,
                    INPUT {&add-def},
                    input v-doc-rec,
                    input-output v-LINE-REC
                    ) no-error.
    if error-status:error then do:
      return 'error'.
    end.
 end.
 when yes then do:
    /*опредлеим какие чеки уже здесь лежат ?*/
    FIND FIRST what_chk-doc No-LOCK WHERE
               what_chk-doc.out-code = tt-wth-doc.doc-code No-ERROR.
    if available what_chk-doc then do:
      assign
      valid-chk-type-list = string(what_chk-doc.chk-type).
      FIND FIRST cash_wth-place No-LOCK WHERE
                 cash_Wth-place.obj-type = parobj-type AND
                 cash_Wth-place.obj-code = parobj-code AND
                 cash_wth-place.cash-desk = what_chk-doc.pay-desk No-ERROR.
      if not avail cash_wth-place then do:
        message
        "Не найдено МХ, соответствующее кассе, пробившей чеки, включенные в документ"
        view-as alert-box error .
        return 'error'.
      end.
      valid-w-p-code = cash_wth-place.w-p-code.
      run str/chk-docs.w (
                      input parparentproc
                     ,input 'b-sel,b-mark':U
                     ,input 'free':U
                     ,input ?
                     ,input parobj-type
                     ,input parobj-code
                     ,input '':U
                     ,input '':U
                     ,input 0 /*p-pay-desk*/
                     ,input ?
                     ,input ?
                     ,input what_chk-doc.chk-type
                     ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    else do:
      assign
      valid-w-p-code = 0
      valid-chk-type-list = {&cd-drawer} + {&comma-char} + {&pay-transfer}.
      run str/chk-docs.w (
                     input parparentproc
                    ,input 'b-sel,b-mark':U
                    ,input 'free':U
                    ,input ?
                    ,input parobj-type
                    ,input parobj-code
                    ,input '':U
                    ,input '':U
                    ,input 0 /*p-pay-desk*/
                    ,input ?
                    ,input ?
                    ,input 0
                     ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    if loc-ref-list = "":U then return.
  _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        LOOKUP(string(buf_chk-doc.chk-type), valid-chk-type-list) = 0 then NEXT _ii.
      if tt-wth-doc.shift-date = ? then do:
        if buf_chk-doc.shift-date <> tt-wth-doc.doc-date then NEXT _ii.
      end.
      else do:
        if NOT (buf_chk-doc.shift-date = tt-wth-doc.shift-date AND
                buf_chk-doc.shift-num = tt-wth-doc.shift-num) then NEXT _ii.
      end.
      if avail(what_chk-doc) and buf_chk-doc.pay-desk <> what_chk-doc.pay-desk then NEXT _ii.
      run str/inc-wth1.p (
       buffer buf_chk-doc
      ,input 1 /*добавить чек*/
      ,input tt-wth-doc.doc-code
      ,input valid-w-p-code
      ,input 0
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1) "чеков"
    "удалось включить в документ" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
FIND current bf_wth-doc EXCLUSIVE-LOCK.
run MyEnable in this-Procedure.
{&OPEN-QUERY-BR-lines}
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-ok as integer no-undo.
define variable v-line-rec as recid no-undo .

DEFINE buffer buf_chk-doc for ub.chk-doc .

if not avail buf_wth-line then return no-apply.
  IF tt-wth-doc.status_ <> {&wayb} THEN DO:
    MESSAGE "Документ закрыт - удалять матценности нельзя!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CASE tt-wth-doc.auto-fill:
  when no then do:
    MESSAGE
    "Вы уверены, что хотите удалить строку?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
      RETURN NO-APPLY.
    END.
    ASSIGN v-line-rec = RECID( buf_wth-line).
    Erase-Block:
    DO ON ERROR UNDO Erase-Block, LEAVE Erase-Block
      ON STOP  UNDO Erase-Block, LEAVE Erase-Block :
      FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
                        RECID( buf_wth-line ) = v-line-rec.
      run str/wth-lnv1.p (
                       input-output v-line-rec
                      ,input  {&deletion}
                      ,input buf_wth-line.doc-code
                      ,input buf_wth-line.wth-code
                      ,input buf_wth-line.w-p-code
                      ,input (- buf_wth-line.bef-sum)
                      ,input (- buf_wth-line.aft-sum)
                      ,input table tt-par-dtl
                      ,input glog
                      ) .

      DELETE buf_wth-line.
    END.
  end.
  when yes then do:
    run str/chk-docs.w (
                   input parparentproc
                  ,input 'b-sel,b-mark':U
                  ,input 'out-code':U
                  ,input ?
                  ,input parobj-type
                  ,input parobj-code
                  ,input tt-wth-doc.doc-code
                  ,input ''
                  ,input 0 /*p-pay-desk*/
                  ,input ?
                  ,input ?
                  ,input 0
                  ,output loc-ref-list) no-error.
    if error-status:error then return error.
    if loc-ref-list = '':U then return.
     _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        buf_chk-doc.out-code <> tt-wth-doc.doc-code then NEXT _ii.
      run str/inc-wth1.p (
        buffer buf_chk-doc
      ,input - 1 /*удалить чек*/
      ,input tt-wth-doc.doc-code
      ,input 0
      ,input 0
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1) "чеков"
    "удалось удалить из документа" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
assign
tt-wth-doc.doc-sum = bf_wth-doc.doc-sum
tt-wth-doc.fact-sum = bf_wth-doc.fact-sum
tt-wth-doc.bef-sum = bf_wth-doc.bef-sum
tt-wth-doc.aft-sum = bf_wth-doc.aft-sum
.
RUN Myenable in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-doc Dialog-Frame
PROCEDURE proc-save-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 define input parameter parlines-exist as logical no-undo .
 define variable v-doc-rec as recid no-undo .
 define variable varcli-name as character no-undo .
 IF par-mode = {&lookup} THEN DO:
    RETURN NO-APPLY.
 END.
 assign
 tt-wth-doc.doc-date frame {&frame-name}
 tt-wth-doc.operator
 tt-wth-doc.deliver
 tt-wth-doc.receiver
 tt-wth-doc.inv-prs4
 tt-wth-doc.inv-prs5
 .
run trg/wth-inv2.p (
                 input no
                ,input tt-wth-doc.doc-code
                ,input tt-wth-doc.host-code
                ,input tt-wth-doc.obj-type
                ,input tt-wth-doc.obj-code
                ,input tt-wth-doc.operator
                ,input tt-wth-doc.deliver
                ,input tt-wth-doc.receiver
                ,input tt-wth-doc.inv-prs4
                ,input tt-wth-doc.inv-prs5
                ,input tt-wth-doc.auto-fill
                ,input parlines-exist
                ,input no
                ,output varcli-name) no-error.
if error-status:error then do:
  { gbl/reterhnd.i 'error' " " no-undo }
end.

 v-doc-rec = recid(bf_wth-doc).
  run str/wth-inv1.p (
                  input no   /*silent*/
                 ,input-output v-doc-rec
                 ,input        {&update}
                 ,input tt-wth-doc.doc-code
                 ,input tt-wth-doc.host-code
                 ,input tt-wth-doc.obj-type
                 ,input tt-wth-doc.obj-code
                 ,input tt-wth-doc.doc-date
                 ,input tt-wth-doc.fact-date
                 ,input tt-wth-doc.shift-date
                 ,input tt-wth-doc.shift-num
                 ,input tt-wth-doc.shift-name
                 ,input tt-wth-doc.operator
                 ,input tt-wth-doc.deliver
                 ,input tt-wth-doc.receiver
                 ,input tt-wth-doc.inv-prs4
                 ,input tt-wth-doc.inv-prs5
                 ,input tt-wth-doc.auto-fill
                 ,input tt-wth-doc.bef-sum
                 ,input tt-wth-doc.aft-sum
                 ,input tt-wth-doc.PS
                 ,input tt-wth-doc.status_
                 ,input parlines-exist
                 ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> '':U then do:
      CASE return-value:
        when "operator":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.operator IN FRAME {&FRAME-NAME}.
        end.
        when "aft-sum":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.aft-sum IN FRAME {&FRAME-NAME}.
        end.
        when "deliver":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.deliver IN FRAME {&FRAME-NAME}.
        end.
        when "receiver":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.receiver IN FRAME {&FRAME-NAME}.
        end.
        when "inv-prs4":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.inv-prs4 IN FRAME {&FRAME-NAME}.
        end.
        when "inv-prs5":U then do:
          APPLY "ENTRY":U TO tt-wth-doc.inv-prs5 IN FRAME {&FRAME-NAME}.
        end.
        when "b-add":U then do:
          APPLY "ENTRY":U TO b-add IN FRAME {&FRAME-NAME}.
        end.
      END CASE.
    end.
    RETURN error.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-wth-doc Dialog-Frame
PROCEDURE reposition-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-wth-doc-recid as recid no-undo .

do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-wth-doc-recid
      ).

    if v-new-wth-doc-recid <> ?
    then do:
      define buffer buf_wth-doc for ub.wth-doc .
      find first buf_wth-doc no-lock
        where recid(buf_wth-doc) = v-new-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-wth-doc-recid
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