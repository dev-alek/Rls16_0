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
DEFINE BUFFER buf_deliver FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_operator FOR ub.clients.
DEFINE BUFFER buf_receiver FOR ub.clients.
DEFINE BUFFER buf_wth FOR ub.wealth.
DEFINE BUFFER current-place FOR ub.wth-place.
DEFINE BUFFER first_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER out-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-c-wth-doc NO-UNDO LIKE ub.c-wth-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История документа движения материальных ценностей

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
define input parameter par-type AS CHARACTER NO-UNDO.
define input parameter parauto-fill like ub.c-wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec     as recid no-undo .
define input parameter p-call-prog  as handle no-undo .
define input-output parameter p-next-prev as character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/usrfulnf.i }
/*DEFINE SHARED QUERY BR-docs FOR c-wth-doc SCROLLING.*/
define buffer bf_c-wth-doc for ub.c-wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE locked-out as logical no-undo .
DEFINE VARIABLE locked-current as logical no-undo .
DEFINE VARIABLE locked-inter_ as logical no-undo .
DEFINE VARIABLE locked-cli as logical no-undo .
define buffer auto-c-wth-doc-lock_batchprocess for ub.batchprocess .

&SCOP type-list "{&bef-income},{&bef-expense},{&bef-write-off}"
define buffer bind_c-wth-doc for ub.c-wth-doc.
define buffer bind_inkas for ub.inkas.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.

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
&Scoped-define INTERNAL-TABLES buf_c-wth-line buf_wth tt-c-wth-doc buf_obj ~
buf_clients first_c-wth-line out-place buf_operator buf_deliver ~
buf_receiver

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines buf_c-wth-line.wth-code buf_wth.wth-name buf_c-wth-line.doc-sum buf_c-wth-line.fact-sum buf_c-wth-line.sum-gds-rubl buf_c-wth-line.sum-gds-base buf_c-wth-line.credate buf_c-wth-line.creid
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines buf_c-wth-line.creid
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines buf_c-wth-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines buf_c-wth-line
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH buf_c-wth-line WHERE         buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code     AND buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num     AND buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num NO-LOCK, ~
           first buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH buf_c-wth-line WHERE         buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code     AND buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num     AND buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num NO-LOCK, ~
           first buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-lines buf_c-wth-line buf_wth
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines buf_c-wth-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-lines buf_wth


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-c-wth-doc SHARE-LOCK, ~
             EACH buf_obj WHERE buf_obj.obj-type = tt-c-wth-doc.obj-type   AND buf_obj.obj-code = tt-c-wth-doc.obj-code SHARE-LOCK, ~
             EACH buf_clients WHERE buf_clients.obj-type = tt-c-wth-doc.cli-type   AND buf_clients.obj-code = tt-c-wth-doc.cli-code SHARE-LOCK, ~
             EACH first_c-wth-line WHERE first_c-wth-line.doc-code = tt-c-wth-doc.doc-code   AND first_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num   AND first_c-wth-line.chip-num = tt-c-wth-doc.chip-num SHARE-LOCK, ~
             EACH out-place WHERE out-place.w-p-code = first_c-wth-line.out-code SHARE-LOCK, ~
             EACH buf_operator WHERE buf_operator.obj-code = tt-c-wth-doc.operator   AND buf_operator.obj-type = {&prs} SHARE-LOCK, ~
             EACH buf_deliver WHERE buf_deliver.obj-code = tt-c-wth-doc.deliver   AND buf_deliver.obj-type = {&prs} SHARE-LOCK, ~
             EACH buf_receiver WHERE buf_receiver.obj-code = tt-c-wth-doc.receiver   AND buf_receiver.obj-type = {&prs} SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-c-wth-doc SHARE-LOCK, ~
             EACH buf_obj WHERE buf_obj.obj-type = tt-c-wth-doc.obj-type   AND buf_obj.obj-code = tt-c-wth-doc.obj-code SHARE-LOCK, ~
             EACH buf_clients WHERE buf_clients.obj-type = tt-c-wth-doc.cli-type   AND buf_clients.obj-code = tt-c-wth-doc.cli-code SHARE-LOCK, ~
             EACH first_c-wth-line WHERE first_c-wth-line.doc-code = tt-c-wth-doc.doc-code   AND first_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num   AND first_c-wth-line.chip-num = tt-c-wth-doc.chip-num SHARE-LOCK, ~
             EACH out-place WHERE out-place.w-p-code = first_c-wth-line.out-code SHARE-LOCK, ~
             EACH buf_operator WHERE buf_operator.obj-code = tt-c-wth-doc.operator   AND buf_operator.obj-type = {&prs} SHARE-LOCK, ~
             EACH buf_deliver WHERE buf_deliver.obj-code = tt-c-wth-doc.deliver   AND buf_deliver.obj-type = {&prs} SHARE-LOCK, ~
             EACH buf_receiver WHERE buf_receiver.obj-code = tt-c-wth-doc.receiver   AND buf_receiver.obj-type = {&prs} SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-c-wth-doc buf_obj ~
buf_clients first_c-wth-line out-place buf_operator buf_deliver ~
buf_receiver
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-c-wth-doc
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_obj
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame buf_clients
&Scoped-define FOURTH-TABLE-IN-QUERY-Dialog-Frame first_c-wth-line
&Scoped-define FIFTH-TABLE-IN-QUERY-Dialog-Frame out-place
&Scoped-define SIXTH-TABLE-IN-QUERY-Dialog-Frame buf_operator
&Scoped-define SEVENTH-TABLE-IN-QUERY-Dialog-Frame buf_deliver
&Scoped-define EIGHTH-TABLE-IN-QUERY-Dialog-Frame buf_receiver


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-wth-doc.corr-user-name ~
tt-c-wth-doc.corr-date tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date ~
tt-c-wth-doc.shift-date tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num ~
tt-c-wth-doc.obj-code tt-c-wth-doc.cli-name tt-c-wth-doc.cli-code ~
tt-c-wth-doc.fact-sum tt-c-wth-doc.doc-sum tt-c-wth-doc.sum-gds-rubl ~
tt-c-wth-doc.sum-gds-base tt-c-wth-doc.operator tt-c-wth-doc.deliver ~
tt-c-wth-doc.receiver
&Scoped-define ENABLED-TABLES tt-c-wth-doc
&Scoped-define FIRST-ENABLED-TABLE tt-c-wth-doc
&Scoped-Define ENABLED-OBJECTS b-quit B-prev B-next B-Help BR-lines ~
B-lookup B-chk for-object for-current-w-p-code for-current-w-p-name ~
for-out-w-p-code for-out-w-p-name for-operator for-deliver for-receiver
&Scoped-Define DISPLAYED-FIELDS tt-c-wth-doc.obj-type tt-c-wth-doc.cli-type ~
tt-c-wth-doc.corr-user-name tt-c-wth-doc.corr-date tt-c-wth-doc.doc-code ~
tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date ~
tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code ~
tt-c-wth-doc.cli-name tt-c-wth-doc.cli-code tt-c-wth-doc.fact-sum ~
tt-c-wth-doc.doc-sum tt-c-wth-doc.sum-gds-rubl tt-c-wth-doc.sum-gds-base ~
tt-c-wth-doc.operator tt-c-wth-doc.deliver tt-c-wth-doc.receiver
&Scoped-define DISPLAYED-TABLES tt-c-wth-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-wth-doc
&Scoped-Define DISPLAYED-OBJECTS for-object for-current-w-p-code ~
for-current-w-p-name for-out-w-p-code for-out-w-p-name for-operator ~
for-deliver for-receiver

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

DEFINE VARIABLE for-current-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Место"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.

DEFINE VARIABLE for-current-w-p-name AS CHARACTER FORMAT "X(20)"
      VIEW-AS TEXT
     SIZE 21.1 BY 1 NO-UNDO.

DEFINE VARIABLE for-deliver AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-operator AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-out-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Место"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.

DEFINE VARIABLE for-out-w-p-name AS CHARACTER FORMAT "X(20)"
      VIEW-AS TEXT
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE for-receiver AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-lines FOR
      buf_c-wth-line,
      buf_wth SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-c-wth-doc,
      buf_obj,
      buf_clients,
      first_c-wth-line,
      out-place,
      buf_operator,
      buf_deliver,
      buf_receiver SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines NO-LOCK DISPLAY
      buf_c-wth-line.wth-code FORMAT ">>>>>>>>9":U
      buf_wth.wth-name FORMAT "X(40)":U
      buf_c-wth-line.doc-sum FORMAT "->,>>>,>>>,>>9.99":U
      buf_c-wth-line.fact-sum FORMAT "->,>>>,>>>,>>9.99":U
      buf_c-wth-line.sum-gds-rubl FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (rub.)'
      buf_c-wth-line.sum-gds-base FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (б.в.)'
      buf_c-wth-line.credate FORMAT "99/99/99":U
      buf_c-wth-line.creid FORMAT "X(16)":U
  ENABLE
      buf_c-wth-line.creid
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.1 BY 7.27.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 40
     B-next AT ROW 1 COL 44.1
     B-Help AT ROW 1 COL 95
     tt-c-wth-doc.obj-type AT ROW 3.77 COL 14 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6 BY 1
     tt-c-wth-doc.cli-type AT ROW 5.27 COL 14 COLON-ALIGNED
          LABEL "Контрагент"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6 BY 1
     BR-lines AT ROW 12.87 COL 1
     B-lookup AT ROW 20.27 COL 1
     B-chk AT ROW 20.27 COL 11
     tt-c-wth-doc.corr-user-name AT ROW 1 COL 65.5 COLON-ALIGNED
          LABEL "Корр."
           VIEW-AS TEXT
          SIZE 12 BY .67
          FGCOLOR 12
     tt-c-wth-doc.corr-date AT ROW 1.03 COL 82 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 12
     tt-c-wth-doc.doc-code AT ROW 2.5 COL 7.3 COLON-ALIGNED
          LABEL "Номер"
           VIEW-AS TEXT
          SIZE 16.1 BY .67
          FGCOLOR 4
     tt-c-wth-doc.doc-date AT ROW 2.5 COL 29 COLON-ALIGNED
          LABEL "Дата"
           VIEW-AS TEXT
          SIZE 10 BY .67
     tt-c-wth-doc.fact-date AT ROW 2.5 COL 48.4 COLON-ALIGNED
          LABEL "Факт"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-date AT ROW 2.5 COL 65.5 COLON-ALIGNED
          LABEL "Смена"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-name AT ROW 2.5 COL 82 COLON-ALIGNED
          LABEL "№"
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-num AT ROW 2.5 COL 92 COLON-ALIGNED
          LABEL "П."
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.obj-code AT ROW 3.77 COL 21 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 7.5 BY .67
     for-object AT ROW 3.77 COL 29 COLON-ALIGNED NO-LABEL
     for-current-w-p-code AT ROW 3.77 COL 65.5 COLON-ALIGNED
     for-current-w-p-name AT ROW 3.77 COL 76 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.cli-name AT ROW 5.07 COL 29 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 24.5 BY 1
     for-out-w-p-code AT ROW 5.07 COL 65.5 COLON-ALIGNED
     for-out-w-p-name AT ROW 5.07 COL 76 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.cli-code AT ROW 5.27 COL 21 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.8 BY .67
     tt-c-wth-doc.fact-sum AT ROW 6.5 COL 65.5 COLON-ALIGNED
          LABEL "Кол-во факт"
           VIEW-AS TEXT
          SIZE 24.1 BY .67
     tt-c-wth-doc.doc-sum AT ROW 6.77 COL 21 COLON-ALIGNED
          LABEL "Кол-во по документу"
           VIEW-AS TEXT
          SIZE 18.4 BY .67
     tt-c-wth-doc.sum-gds-rubl AT ROW 8 COL 27 COLON-ALIGNED WIDGET-ID 4
          LABEL "Сумма по тов. (abbr_rubl.)"
           VIEW-AS TEXT
          SIZE 14 BY .67
     tt-c-wth-doc.sum-gds-base AT ROW 8 COL 65.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Сумма по тов.(баз. вал)" FORMAT "->>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 14 BY .67
     tt-c-wth-doc.operator AT ROW 9.27 COL 14 COLON-ALIGNED
          LABEL "Составил"
           VIEW-AS TEXT
          SIZE 12.3 BY .67
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     for-operator AT ROW 9.27 COL 29 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.deliver AT ROW 10.43 COL 14 COLON-ALIGNED
          LABEL "Передал"
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-deliver AT ROW 10.5 COL 29 COLON-ALIGNED NO-LABEL
     for-receiver AT ROW 11.5 COL 29 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.receiver AT ROW 11.57 COL 14 COLON-ALIGNED
          LABEL "Получил"
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     SPACE(71.57) SKIP(9.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ движения материальных ценностей: история"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_c-wth-line B "?" ? ub c-wth-line
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_deliver B "?" ? ub clients
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_operator B "?" ? ub clients
      TABLE: buf_receiver B "?" ? ub clients
      TABLE: buf_wth B "?" ? ub wealth
      TABLE: current-place B "?" ? ub wth-place
      TABLE: first_c-wth-line B "?" ? ub c-wth-line
      TABLE: out-place B "?" ? ub wth-place
      TABLE: tt-c-wth-doc T "?" NO-UNDO ub c-wth-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines cli-type Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-wth-doc.cli-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.cli-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-c-wth-doc.cli-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.corr-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.corr-user-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.deliver IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.doc-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.fact-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-c-wth-doc.obj-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.operator IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.receiver IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.sum-gds-base IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-wth-doc.sum-gds-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH buf_c-wth-line WHERE
        buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code
    AND buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
    AND buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num NO-LOCK,
    first buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _JoinCode[1]      = "buf_c-wth-line.doc-code = Temp-Tables.tt-c-wth-doc.doc-code AND buf_c-wth-line.corr-user-db-num = Temp-Tables.tt-c-wth-doc.corr-user-db-num AND buf_c-wth-line.chip-num = Temp-Tables.tt-c-wth-doc.chip-num"
     _JoinCode[2]      = "buf_wth.wth-code = buf_c-wth-line.wth-code"
     _Query            is NOT OPENED
*/  /* BROWSE BR-lines */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-c-wth-doc SHARE-LOCK,
      EACH buf_obj WHERE buf_obj.obj-type = tt-c-wth-doc.obj-type
  AND buf_obj.obj-code = tt-c-wth-doc.obj-code SHARE-LOCK,
      EACH buf_clients WHERE buf_clients.obj-type = tt-c-wth-doc.cli-type
  AND buf_clients.obj-code = tt-c-wth-doc.cli-code SHARE-LOCK,
      EACH first_c-wth-line WHERE first_c-wth-line.doc-code = tt-c-wth-doc.doc-code
  AND first_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
  AND first_c-wth-line.chip-num = tt-c-wth-doc.chip-num SHARE-LOCK,
      EACH out-place WHERE out-place.w-p-code = first_c-wth-line.out-code SHARE-LOCK,
      EACH buf_operator WHERE buf_operator.obj-code = tt-c-wth-doc.operator
  AND buf_operator.obj-type = {&prs} SHARE-LOCK,
      EACH buf_deliver WHERE buf_deliver.obj-code = tt-c-wth-doc.deliver
  AND buf_deliver.obj-type = {&prs} SHARE-LOCK,
      EACH buf_receiver WHERE buf_receiver.obj-code = tt-c-wth-doc.receiver
  AND buf_receiver.obj-type = {&prs} SHARE-LOCK.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _JoinCode[2]      = "Temp-Tables.buf_obj.obj-type = Temp-Tables.tt-c-wth-doc.obj-type
  AND Temp-Tables.buf_obj.obj-code = Temp-Tables.tt-c-wth-doc.obj-code"
     _JoinCode[3]      = "Temp-Tables.buf_clients.obj-type = Temp-Tables.tt-c-wth-doc.cli-type
  AND Temp-Tables.buf_clients.obj-code = Temp-Tables.tt-c-wth-doc.cli-code"
     _JoinCode[4]      = "first_c-wth-line.doc-code = Temp-Tables.tt-c-wth-doc.doc-code AND first_c-wth-line.corr-user-db-num = Temp-Tables.tt-c-wth-doc.corr-user-db-num AND first_c-wth-line.chip-num = Temp-Tables.tt-c-wth-doc.chip-num"
     _JoinCode[5]      = "out-place.w-p-code = first_c-wth-line.out-code"
     _JoinCode[6]      = "Temp-Tables.buf_operator.obj-code = Temp-Tables.tt-c-wth-doc.operator
  AND Temp-Tables.buf_operator.obj-type = {&prs}"
     _JoinCode[7]      = "Temp-Tables.buf_deliver.obj-code = Temp-Tables.tt-c-wth-doc.deliver
  AND Temp-Tables.buf_deliver.obj-type = {&prs}"
     _JoinCode[8]      = "Temp-Tables.buf_receiver.obj-code = Temp-Tables.tt-c-wth-doc.receiver
  AND Temp-Tables.buf_receiver.obj-type = {&prs}"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ движения материальных ценностей: история */
DO:
  p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чеки */
DO:
  DEFINE VARIABLE loc-ref-list as character no-undo.
  DEFINE VARIABLE var-doc-code like ub.c-wth-doc.doc-code no-undo .
  if tt-c-wth-doc.borned then do:
    assign
    var-doc-code = tt-c-wth-doc.source-ref.
  end.
  else do:
    var-doc-code = tt-c-wth-doc.doc-code.
  end.
  run str/chk-docs.w (
                 input parparentproc
                ,input '':U
                ,input 'out-code':U
                ,input ?
                ,input parobj-type
                ,input parobj-code
                ,input var-doc-code
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
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
  run str/wthcinca.w (input parparentproc,
                  INPUT {&lookup},
                  input v-doc-rec,
                  input for-current-w-p-code,
                  input for-out-w-p-code,
                  input-output v-LINE-REC,
                  INPUT tt-c-wth-doc.doc-type ) no-error.
  apply "entry" to br-lines.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
     run reposition-c-wth-doc in this-procedure
  (input 'next':U
  ) no-error .

  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
   run reposition-c-wth-doc in this-procedure
  (input 'prev':U
  ) no-error .
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


&Scoped-define SELF-NAME tt-c-wth-doc.cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.cli-type Dialog-Frame
ON VALUE-CHANGED OF tt-c-wth-doc.cli-type IN FRAME Dialog-Frame /* Контрагент */
DO:
 run control-out in this-procedure.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.cli-type AND
          buf_clients.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.cli-code NO-ERROR.
 /*
 if buf_clients.obj-type = {&cmp} and
    buf_Clients.obj-code = parhost-code then do:
        release buf_clients.
        display
        0 @ tt-c-wth-doc.cli-code
        '':U @ tt-c-wth-doc.cli-name WITH FRAME {&FRAME-NAME}.

 end.
 */
IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ tt-c-wth-doc.cli-name WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.deliver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.deliver Dialog-Frame
ON LEAVE OF tt-c-wth-doc.deliver IN FRAME Dialog-Frame /* Передал */
DO:
      FIND FIRST buf_deliver NO-LOCK WHERE
            buf_deliver.obj-type = {&prs} AND
            buf_deliver.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.deliver NO-ERROR.
  IF AVAIL buf_deliver THEN DO:
    DISPLAY
    buf_deliver.obj-name @ for-deliver
        WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME for-current-w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL for-current-w-p-code Dialog-Frame
ON LEAVE OF for-current-w-p-code IN FRAME Dialog-Frame /* Место */
DO:
    FIND FIRST current-place NO-LOCK WHERE
            current-place.host-code = tt-c-wth-doc.host-code AND
            current-place.obj-type = tt-c-wth-doc.obj-type      AND
            current-place.obj-code = tt-c-wth-doc.obj-code      AND
            current-place.w-p-code = INPUT FRAME {&FRAME-NAME} for-current-w-p-code NO-ERROR.
  IF AVAIL current-place THEN DO:
    DISPLAY
    current-place.w-p-name @ for-current-w-p-name
    WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME for-out-w-p-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL for-out-w-p-code Dialog-Frame
ON LEAVE OF for-out-w-p-code IN FRAME Dialog-Frame /* Место */
DO:
    FIND FIRST out-place NO-LOCK WHERE
            out-place.host-code = tt-c-wth-doc.host-code AND
            out-place.obj-type = tt-c-wth-doc.obj-type AND
            out-place.obj-code = tt-c-wth-doc.obj-code AND
            out-place.w-p-code = INPUT FRAME {&FRAME-NAME} for-out-w-p-code NO-ERROR.
  IF AVAIL out-place THEN DO:
    DISPLAY
    out-place.w-p-name @ for-out-w-p-name
        WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.operator Dialog-Frame
ON LEAVE OF tt-c-wth-doc.operator IN FRAME Dialog-Frame /* Составил */
DO:
    FIND FIRST buf_operator NO-LOCK WHERE
            buf_operator.obj-type = {&prs} AND
            buf_operator.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.operator NO-ERROR.
  IF AVAIL buf_operator THEN DO:
    DISPLAY
    buf_operator.obj-name @ for-operator
    WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-c-wth-doc.receiver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-c-wth-doc.receiver Dialog-Frame
ON LEAVE OF tt-c-wth-doc.receiver IN FRAME Dialog-Frame /* Получил */
DO:
    FIND FIRST buf_receiver NO-LOCK WHERE
            buf_receiver.obj-type = {&prs} AND
            buf_receiver.obj-code = INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.receiver NO-ERROR.
  IF AVAIL buf_receiver THEN DO:
    DISPLAY
    buf_receiver.obj-name @ for-receiver
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
p-next-prev = "":U.
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
    if LOOKUP(par-type, {&type-list}) = 0 then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова par-type"
                view-as alert-box ERROR.
                return error.
    end.
    tt-c-wth-doc.cli-type:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char} +
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.
    tt-c-wth-doc.obj-type:list-items = {&cmp} + {&comma-char} +
                                    {&prs} + {&comma-char} +
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.
  Run fill-tables no-error.
  if error-status:error then return error.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-line Dialog-Frame
PROCEDURE control-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER lock-doc as logical no-undo.
IF CAN-FIND(FIRST ub.c-wth-line No-LOCK WHERE
                  ub.c-wth-line.doc-code = tt-c-wth-doc.doc-code
              AND ub.c-wth-line.chip-num = tt-c-wth-doc.chip-num
              AND ub.c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
              ) then
lock-doc = yes.
else lock-doc = no.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-out Dialog-Frame
PROCEDURE control-out :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 IF INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.cli-type = {&prs}   OR
    INPUT FRAME {&FRAME-NAME} tt-c-wth-doc.cli-type = {&cmp} THEN DO:
    DISABLE
    for-out-w-p-code
    WITH FRAME {&FRAME-NAME}.
    HIDE
    for-out-w-p-code IN FRAME {&FRAME-NAME}
    for-out-w-p-name IN FRAME {&FRAME-NAME}
    .
    locked-out = yes.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY for-object for-current-w-p-code for-current-w-p-name for-out-w-p-code
          for-out-w-p-name for-operator for-deliver for-receiver
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY tt-c-wth-doc.obj-type tt-c-wth-doc.cli-type
          tt-c-wth-doc.corr-user-name tt-c-wth-doc.corr-date
          tt-c-wth-doc.doc-code tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date
          tt-c-wth-doc.shift-date tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num
          tt-c-wth-doc.obj-code tt-c-wth-doc.cli-name tt-c-wth-doc.cli-code
          tt-c-wth-doc.fact-sum tt-c-wth-doc.doc-sum tt-c-wth-doc.sum-gds-rubl
          tt-c-wth-doc.sum-gds-base tt-c-wth-doc.operator tt-c-wth-doc.deliver
          tt-c-wth-doc.receiver
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-prev B-next B-Help BR-lines B-lookup B-chk
         tt-c-wth-doc.corr-user-name tt-c-wth-doc.corr-date
         tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date
         tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code
         for-object for-current-w-p-code for-current-w-p-name
         tt-c-wth-doc.cli-name for-out-w-p-code for-out-w-p-name
         tt-c-wth-doc.cli-code tt-c-wth-doc.fact-sum tt-c-wth-doc.doc-sum
         tt-c-wth-doc.sum-gds-rubl tt-c-wth-doc.sum-gds-base
         tt-c-wth-doc.operator for-operator tt-c-wth-doc.deliver for-deliver
         for-receiver tt-c-wth-doc.receiver
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
    if not avail buf_clients then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный контрагент" bf_c-wth-doc.cli-type bf_c-wth-doc.cli-code
      view-as alert-box ERROR.
      return error.
    end.
    FIND FIRST buf_operator No-LOCK WHERe
                        buf_operator.obj-type = {&prs} AND
                        buf_operator.obj-code = tt-c-wth-doc.operator No-ERROR.
    FIND FIRST buf_deliver No-LOCK WHERe
                        buf_deliver.obj-type = {&prs} AND
                        buf_deliver.obj-code = tt-c-wth-doc.deliver No-ERROR.
    FIND FIRST buf_receiver No-LOCK WHERe
                        buf_receiver.obj-type = {&prs} AND
                        buf_receiver.obj-code = tt-c-wth-doc.receiver No-ERROR.
    FIND FIRST buf_c-wth-line No-LOCK where
               BUF_c-wth-line.DOC-CODE = TT-c-wth-doc.doc-code
          AND buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
          AND buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num
               nO-ERROR.
    if avail buf_c-wth-line then do:
      find first current-place No-LOCK WHERE
                    current-place.w-p-code = buf_c-wth-line.w-p-code NO-ERROR.
      if avail current-place then
      assign
      for-current-w-p-code = current-place.w-p-code
      for-current-w-p-name = current-place.w-p-name
      .
      find first out-place No-LOCK WHERE
                    out-place.w-p-code = buf_c-wth-line.out-code NO-ERROR.
      if avail out-place then
      assign
      for-out-w-p-code = out-place.w-p-code
      for-out-w-p-name = out-place.w-p-name
      .
    end.
    CASE tt-c-wth-doc.source-type:
      when {&wthd-wth-doc} then do:
        FIND FIRST bind_c-wth-doc NO-LOCK WHERE
                   bind_c-wth-doc.doc-code = tt-c-wth-doc.source-ref NO-ERROR.
      end.
      when {&wthd-cash-desk} then do:
        FIND FIRST bind_inkas NO-LOCK WHERE
                   bind_inkas.inkas-code = tt-c-wth-doc.source-ref NO-ERROR.

      end.
    END CASE.
/*
if tt-c-wth-doc.auto-fill = yes then do:
  { str/lockawth.i }
end.
*/

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
DEFINE INPUT PARAMETER lock-doc as logical no-undo.
if lock-doc then do:
    DISABLE
    tt-c-wth-doc.cli-type
    tt-c-wth-doc.cli-code
    for-current-w-p-code
    for-out-w-p-code
    with frame {&frame-name}
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
buf_c-wth-line.sum-gds-rubl:label in browse br-lines = "Сумма по связ. тов. ({&abbr_rubl}.)".
 buf_c-wth-line.creid:READ-ONLY IN BROWSE BR-lines = YES.
 IF AVAILABLE buf_clients and par-mode = {&add-def} THEN dO:
    DISPLAY buf_clients.obj-name @ tt-c-wth-doc.cli-name
      WITH FRAME Dialog-Frame.
  end.
  else
  display
  tt-c-wth-doc.cli-name
  with frame {&frame-name}.
  IF AVAILABLE buf_deliver THEN
    DISPLAY buf_deliver.obj-name @ for-deliver
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_obj THEN
    DISPLAY buf_obj.obj-name @ for-object
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_operator THEN
    DISPLAY buf_operator.obj-name @ for-operator
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_receiver THEN
    DISPLAY buf_receiver.obj-name @ for-receiver
      WITH FRAME Dialog-Frame.
  IF AVAILABLE current-place THEN
    DISPLAY
    current-place.w-p-code @ for-current-w-p-code
    current-place.w-p-name @ for-current-w-p-name
  WITH FRAME {&frame-name} .
  IF AVAILABLE out-place THEN
    DISPLAY
    out-place.w-p-code @ for-out-w-p-code
    out-place.w-p-name @ for-out-w-p-name
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
    tt-c-wth-doc.cli-code
    tt-c-wth-doc.cli-type
    tt-c-wth-doc.fact-sum
    tt-c-wth-doc.doc-sum
    tt-c-wth-doc.operator
    tt-c-wth-doc.deliver
    tt-c-wth-doc.receiver
    tt-c-wth-doc.sum-gds-base
    tt-c-wth-doc.sum-gds-rubl
    usrfulnf(tt-c-wth-doc.corr-user-name) @ tt-c-wth-doc.corr-user-name
    tt-c-wth-doc.corr-date
    WITH FRAME Dialog-Frame.
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
      assign
      locked-out = yes
      locked-current = yes
      .
    END.
    if not tt-c-wth-doc.inter_ then do:
      HIDE
      for-out-w-p-code
      for-out-w-p-name
      in frame {&frame-name}.
    end.
    ENABLE
    b-help
    br-lines
    b-lookup
    /*b-chk when tt-c-wth-doc.auto-fill*/
    WITH FRAME {&FRAME-NAME}.
    Hide b-chk
    in frame {&frame-name}.
    {&OPEN-QUERY-BR-lines}
    IF ERROR-STATUS:ERROR THEN DO:
        REPOSITION br-lines TO ROW 1 NO-ERROR.
    END.
    APPLY "ENTRY":U TO br-lines IN FRAME {&FRAME-NAME}.
    APPLY "VALUE-CHANGED":U TO br-lines IN FRAME {&FRAME-NAME}.
    IF par-mode <> {&lookup} THEN DO:
      APPLY "VALUE-CHANGED":U TO tt-c-wth-doc.cli-type IN FRAME {&FRAME-NAME}.
    END.
   run control-line in this-procedure ( output lock-doc).
   run lock-proc in this-procedure ( input  lock-doc).
   ASSIGN
   FRAME {&FRAME-NAME} :TITLE = substitute("Удаленный документ № &1 движения материальных ценностей (&2  - &3)"
                                            ,tt-c-wth-doc.doc-code
                                            ,ENTRY(LOOKUP(tt-c-wth-doc.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full})
                                            ,CAPS( par-mode )).
  .
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