&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER LOCKED_dis-card-mask FOR dis-card-mask.
DEFINE BUFFER locked_dis-card-type FOR dis-card-type.
DEFINE TEMP-TABLE tt-dis-card-mask NO-UNDO LIKE dis-card-mask.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_clients_dctype FOR clients.
DEFINE BUFFER X_curr_clients FOR clients.
DEFINE BUFFER X_sysconf FOR sysconf.
define buffer buf_dis-card-mask-attr  for ub.dis-card-mask-attr .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Маска дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/17/04
Author: Bakhtadze Natalya
Creation date: 05/17/04

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-mode           AS CHARACTER             no-undo .
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-type           like ub.dis-card-mask.type no-undo .
define input parameter p-mask-num       like ub.dis-card-mask.mask-num no-undo .
define INPUT-OUTPUT parameter p-doc-rec AS recid no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Маска дисконтной карты":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/color.i }
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-last-code LIKE ub.dis-card-mask.mask-num NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dis-card-mask

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-card-mask.type ~
tt-dis-card-mask.mask-num tt-dis-card-mask.use-on ~
tt-dis-card-mask.emitent-host-code tt-dis-card-mask.mask ~
tt-dis-card-mask.rank tt-dis-card-mask.cli-type tt-dis-card-mask.cli-code ~
tt-dis-card-mask.cli-mask 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-dis-card-mask.use-on ~
tt-dis-card-mask.rank 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-dis-card-mask
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-dis-card-mask
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-dis-card-mask SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-dis-card-mask SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-dis-card-mask
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-dis-card-mask


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-dis-card-mask.use-on tt-dis-card-mask.rank 
&Scoped-define ENABLED-TABLES tt-dis-card-mask
&Scoped-define FIRST-ENABLED-TABLE tt-dis-card-mask
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help B-card-type ~
reg-cash RS-region B-mask B-rank RS-cli-mask B-cli-mask CB-CC-run ~
f-emitent-name l-rs-cli-mask f-cli-name 
&Scoped-Define DISPLAYED-FIELDS tt-dis-card-mask.type ~
tt-dis-card-mask.mask-num tt-dis-card-mask.use-on ~
tt-dis-card-mask.emitent-host-code tt-dis-card-mask.mask ~
tt-dis-card-mask.rank tt-dis-card-mask.cli-type tt-dis-card-mask.cli-code ~
tt-dis-card-mask.cli-mask 
&Scoped-define DISPLAYED-TABLES tt-dis-card-mask
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-card-mask
&Scoped-Define DISPLAYED-OBJECTS reg-cash RS-region RS-cli-mask CB-CC-run ~
f-emitent-name l-rs-cli-mask f-cli-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-card-type 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-cli-mask 
     LABEL "&Изменить" 
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
     LABEL "Ис&тория" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mask 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rank 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE VARIABLE CB-CC-run AS CHARACTER FORMAT "X(256)":U 
     LABEL "Алгоритм КЦ" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 46 BY 1 NO-UNDO.

DEFINE VARIABLE f-emitent-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 63.5 BY 1 NO-UNDO.

DEFINE VARIABLE l-rs-cli-mask AS CHARACTER FORMAT "X(256)":U INITIAL "Метод поиска ДК по маске карты" 
      VIEW-AS TEXT 
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE RS-cli-mask AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Правило из маски", "cli-mask",
"Определенный контрагент", "cli-code",
"Маска и контрагент", "cli-mask-cli-code"
     SIZE 64.5 BY 1 NO-UNDO.

DEFINE VARIABLE RS-region AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Глобально", 0,
"Фирма", 1,
"Объект", 2
     SIZE 63 BY 1 NO-UNDO.

DEFINE VARIABLE reg-cash AS LOGICAL INITIAL no 
     LABEL "Разрешена регистрация на кассе" 
     VIEW-AS TOGGLE-BOX
     SIZE 34.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-dis-card-mask SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.88
     tt-dis-card-mask.type AT ROW 2.58 COL 12 COLON-ALIGNED
          LABEL "Тип карты"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     B-card-type AT ROW 2.58 COL 26.5
     tt-dis-card-mask.mask-num AT ROW 2.58 COL 47.5 COLON-ALIGNED
          LABEL "Номер маски"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-dis-card-mask.use-on AT ROW 2.58 COL 67.5 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "Использовать на кассе и в TH", 0,
"Использовать ТОЛЬКО на кассе", 1,
"Использовать ТОЛЬКО в TH", 2
          SIZE 31.5 BY 2.25
     reg-cash AT ROW 4 COL 3 WIDGET-ID 2
     tt-dis-card-mask.emitent-host-code AT ROW 5.25 COL 3
          LABEL "Эмитент карты"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     RS-region AT ROW 6.5 COL 24.88 NO-LABEL
     tt-dis-card-mask.mask AT ROW 8 COL 3
          LABEL "Маска карты"
          VIEW-AS FILL-IN 
          SIZE 21.5 BY 1
     B-mask AT ROW 8 COL 38.13
     tt-dis-card-mask.rank AT ROW 8 COL 79 COLON-ALIGNED
          LABEL "Ранг(приоритет при поиске)"
          VIEW-AS FILL-IN 
          SIZE 7 BY 1
     B-rank AT ROW 8 COL 89
     RS-cli-mask AT ROW 9.71 COL 34.5 NO-LABEL
     tt-dis-card-mask.cli-type AT ROW 12 COL 16.5 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 14 BY 1
     tt-dis-card-mask.cli-code AT ROW 12 COL 29.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     B-cli AT ROW 12 COL 48.5
     tt-dis-card-mask.cli-mask AT ROW 14.25 COL 3
          LABEL "Маска КОРОТКОГО №" FORMAT "X(19)"
          VIEW-AS FILL-IN 
          SIZE 21.5 BY 1
     B-cli-mask AT ROW 14.25 COL 44
     CB-CC-run AT ROW 14.25 COL 67 COLON-ALIGNED
     f-emitent-name AT ROW 5.25 COL 24 COLON-ALIGNED NO-LABEL
     l-rs-cli-mask AT ROW 9.71 COL 3 NO-LABEL
     f-cli-name AT ROW 12 COL 50.5 COLON-ALIGNED NO-LABEL
     "Область действия" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 6.5 COL 3
     "Контрагент" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 12 COL 3
     SPACE(82.74) SKIP(2.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Маска дисконтной карты"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: LOCKED_dis-card-mask B "?" ? ub dis-card-mask
      TABLE: locked_dis-card-type B "?" ? ub dis-card-type
      TABLE: tt-dis-card-mask T "?" NO-UNDO ub dis-card-mask
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_clients_dctype B "?" ? ub clients
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
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

/* SETTINGS FOR BUTTON B-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.cli-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.cli-mask IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL EXP-FORMAT                               */
/* SETTINGS FOR RADIO-SET tt-dis-card-mask.cli-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.emitent-host-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN l-rs-cli-mask IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.mask IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.mask-num IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.rank IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-card-mask.type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-dis-card-mask"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Маска дисконтной карты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-card-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-card-type Dialog-Frame
ON CHOOSE OF B-card-type IN FRAME Dialog-Frame
DO:
  run proc-b-card-type no-error.
    if error-status:error then return no-apply.
  APPLY "LEAVE" to tt-dis-card-mask.emitent-host-code.
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
{ gbl/stdbtn.i }
  run ref/cli-all.w ( parParentProc
                  ,"b-sel"
                  , tt-dis-card-mask.cli-type
                  , ?
                  , ?
                  , (if available X_clients then recid(X_clients) else ?)
                  , ?
                  , "":U
                  , output ref-list) .
    if ref-list = "" then   do:
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
    find first X_clients no-lock where
              recid(X_clients) = recid(buf_clients).
    assign
    tt-dis-card-mask.cli-type =  buf_clients.obj-type
    tt-dis-card-mask.cli-code = buf_clients.obj-code
    f-cli-name = buf_clients.obj-name
    .
    display
    tt-dis-card-mask.cli-type
    tt-dis-card-mask.cli-code
    f-cli-name
    with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-mask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-mask Dialog-Frame
ON CHOOSE OF B-cli-mask IN FRAME Dialog-Frame /* Изменить */
DO:
 DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
 DEFINE VARIABLE v-mask AS CHARACTER NO-UNDO.
   run ref/fillques.w (INPUT tt-dis-card-mask.cli-mask
                 ,INPUT "Редактирование правила определения номера ДК по маске карты"
                 ,INPUT "Маска"
                 ,INPUT 19
                 ,INPUT  "?0123456789DC":U
                 ,OUTPUT v-mask
                 ,OUTPUT v-ok) NO-ERROR.
 IF NOT ERROR-STATUS:ERROR AND v-ok THEN DO:
     ASSIGN
     tt-dis-card-mask.cli-mask = v-mask.
     DISPLAY
     tt-dis-card-mask.cli-mask
     WITH FRAME {&FRAME-NAME}.
 END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
    define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.

  loc-doc-rec = recid (locked_dis-card-mask).
  .
  run ref/dccmasks.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_dis-card-mask.type
                ,input locked_dis-card-mask.host-code
                ,input locked_dis-card-mask.mask-num
                ,input-output v-rid-list
                              )
.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mask Dialog-Frame
ON CHOOSE OF B-mask IN FRAME Dialog-Frame /* Изменить */
DO:
 DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
 DEFINE VARIABLE v-mask AS CHARACTER NO-UNDO.
  run ref/fillques.w (INPUT tt-dis-card-mask.mask
                 ,INPUT "Редактирование маски карты"
                 ,INPUT "Маска"
                 ,INPUT 19
                 ,INPUT  "?*0123456789":U
                 ,OUTPUT v-mask
                 ,OUTPUT v-ok) NO-ERROR.
 IF NOT ERROR-STATUS:ERROR AND v-ok THEN DO:
     ASSIGN
     tt-dis-card-mask.mask = v-mask.
     DISPLAY
     tt-dis-card-mask.mask
     WITH FRAME {&FRAME-NAME}.
 END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rank Dialog-Frame
ON CHOOSE OF B-rank IN FRAME Dialog-Frame
DO:
    define variable v-rid-list as character no-undo .
  run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT p-curr-host-code
                   ,INPUT p-curr-obj-type
                   ,INPUT p-curr-obj-code
                   ,input "b-chg":U
                   ,INPUT {&all}
                   ,INPUT '':U /*p-type*/
                   ,INPUT 0 /*p-emitent-host-code*/
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
  IF ERROR-STATUS:error  THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-card-mask.cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-card-mask.cli-code Dialog-Frame
ON LEAVE OF tt-dis-card-mask.cli-code IN FRAME Dialog-Frame /* cli-code */
DO:
  if   input frame {&frame-name} tt-dis-card-mask.cli-code <> 0 then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-card-mask.cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-card-mask.cli-type Dialog-Frame
ON VALUE-CHANGED OF tt-dis-card-mask.cli-type IN FRAME Dialog-Frame
DO:
  assign
  tt-dis-card-mask.cli-type.
  if   input frame {&frame-name} tt-dis-card-mask.cli-code <> 0 then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME reg-cash
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL reg-cash Dialog-Frame
ON VALUE-CHANGED OF reg-cash IN FRAME Dialog-Frame /* Разрешена регистрация на кассе */
DO:
  assign
  reg-cash
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli-mask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli-mask Dialog-Frame
ON VALUE-CHANGED OF RS-cli-mask IN FRAME Dialog-Frame
DO:
  ASSIGN
  RS-cli-mask.
  RUN proc-cli-or-mask IN THIS-PROCEDURE (rs-cli-mask) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
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
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }





/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
find first X_sysconf no-lock where
            X_sysconf.host-code = p-curr-host-code no-error.
  if not available X_sysconf OR X_sysconf.host-code <> X_curr_clients.host-code then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return error .
  end.
{ gbl/curdbnum.i v-db-num }
IF v-db-num <> 0
AND (p-mode = {&add-def}
     OR p-mode = {&UPDATE} ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись МАСКИ ДИСКОНТНОЙ КАРТЫ в УБД"
    view-as alert-box ERROR.
    return error .
END.
for each tt-dis-card-mask:
  delete tt-dis-card-mask.
end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:

          find first locked_dis-card-mask EXclusive-lock where
                       recid(locked_dis-card-mask) = p-doc-rec no-wait no-error.
          if locked locked_dis-card-mask then do:
            message
            vss-workfile vss-revision vss-description skip
             "Запись МАСКИ ДИСКОНТНОЙ КАРТЫ занята"
            view-as alert-box error .
            undo, return error.
          end.

    end.
    else do:
      find first locked_dis-card-mask no-lock where
                       recid(locked_dis-card-mask) = p-doc-rec no-error .
      if not avail locked_dis-card-mask then do:
        find first locked_dis-card-mask no-lock where
                   locked_dis-card-mask.mask-num = p-mask-num no-error .
      end.
    end.
    if not available locked_dis-card-mask then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись МАСКИ ДИСКОНТНОЙ КАРТЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-dis-card-mask.
    buffer-copy locked_dis-card-mask to tt-dis-card-mask.
    .
    cb-cc-run = IF tt-dis-card-mask.cc-run > 0
                 THEN STRING(tt-dis-card-mask.cc-run)
                ELSE '':U.

   end.
   else do:
       FIND last locked_dis-card-mask EXCLUSIVE-LOCK USE-INDEX pi NO-ERROR.
       IF AVAILABLE locked_dis-card-mask THEN DO:
           ASSIGN
           v-last-code = locked_dis-card-mask.mask-num
           .
       END.
          create tt-dis-card-mask.
          assign
         tt-dis-card-mask.mask-num = v-last-code + 1
         .
   end.
   IF p-mode <> {&LOOKUP} THEN DO:
       IF tt-dis-card-mask.obj-code <> 0 AND
           NOT (p-curr-obj-code = tt-dis-card-mask.obj-code
               AND
               p-curr-obj-type = tt-dis-card-mask.obj-type) THEN DO:
        MESSAGE
        "Редактирование маски, привязанной к объекту, разрешено только на этом объекте"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN.
       END.
       IF  tt-dis-card-mask.host-code <> 0
       AND NOT p-curr-host-code = tt-dis-card-mask.host-code
               THEN DO:
        MESSAGE
        "Редактирование маски, приязанной к фирме, разрешено только объекте данной фирмы"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN.
       END.
  END.
IF p-mode <> {&add-def}
or (p-mode = {&add-def} and p-type <> "":U)
THEN do:
   IF p-mode = {&UPDATE} THEN DO:
       FIND FIRST locked_dis-card-type  EXCLUSIVE-LOCK WHERE
                  locked_dis-card-type.emitent-host-code = locked_dis-card-mask.emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = LOCKED_dis-card-mask.TYPE NO-WAIT NO-ERROR.


   END.
   IF p-mode = {&lookup} THEN DO:
       FIND FIRST locked_dis-card-type  no-lock WHERE
                  locked_dis-card-type.emitent-host-code = locked_dis-card-mask.emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = LOCKED_dis-card-mask.TYPE NO-ERROR.

   END.
   if p-mode <> {&add-def} then do:
      cb-cc-run = (IF locked_dis-card-mask.cc-run > 0
                   THEN string(locked_dis-card-mask.cc-run)
                   ELSE '':U).
   end.
   IF p-mode = {&add-def} THEN DO:
            FIND FIRST locked_dis-card-type  no-lock WHERE
                  locked_dis-card-type.emitent-host-code = p-emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = p-type no-error .

   END.
   if not available locked_dis-card-type then do:
    message
    "Не определен тип ДК" p-emitent-host-code p-type
    view-as alert-box error .
    UNDO, RETURN error .
   end.
   assign
   tt-dis-card-mask.emitent-host-code = locked_dis-card-type.emitent-host-code
   tt-dis-card-mask.type              = locked_dis-card-type.type
   .
END.
  ASSIGN
  tt-dis-card-mask.mask = entry(1, tt-dis-card-mask.mask)
  tt-dis-card-mask.cli-mask = entry(1, tt-dis-card-mask.cli-mask)
  .
  find first buf_dis-card-mask-attr no-lock where buf_dis-card-mask-attr.mask-num = tt-dis-card-mask.mask-num and buf_dis-card-mask-attr.attr-code = "reg-cash" no-error .
  if available (buf_dis-card-mask-attr) then do:
    if buf_dis-card-mask-attr.attr-value = "yes" then reg-cash:checked = yes .
    else reg-cash:checked = no .
  end.  
  else reg-cash:checked = no .
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-cli Dialog-Frame 
PROCEDURE check-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
              buf_clients.obj-code = input frame {&frame-name} tt-dis-card-mask.cli-code
         and buf_clients.obj-type = input frame {&frame-name} tt-dis-card-mask.cli-type no-error.
if not available buf_clients then do:
  if input frame {&frame-name} tt-dis-card-mask.cli-code <> ?  then
    message "Неправильный код или тип контрагента" VIEW-AS ALERT-BOX ERROR.
  apply "entry" to tt-dis-card-mask.cli-code in frame {&frame-name}.
  return error.
end.
find first X_clients no-lock where recid(X_clients) = recid(buf_clients).
assign
tt-dis-card-mask.cli-type = buf_clients.obj-type
tt-dis-card-mask.cli-code = buf_clients.obj-code
f-cli-name = buf_clients.obj-name
.

display
tt-dis-card-mask.cli-type
tt-dis-card-mask.cli-code
f-cli-name
with frame {&frame-name}.

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
  DISPLAY reg-cash RS-region RS-cli-mask CB-CC-run f-emitent-name l-rs-cli-mask 
          f-cli-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-card-mask THEN 
    DISPLAY tt-dis-card-mask.type tt-dis-card-mask.mask-num 
          tt-dis-card-mask.use-on tt-dis-card-mask.emitent-host-code 
          tt-dis-card-mask.mask tt-dis-card-mask.rank tt-dis-card-mask.cli-type 
          tt-dis-card-mask.cli-code tt-dis-card-mask.cli-mask 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help B-card-type tt-dis-card-mask.use-on 
         reg-cash RS-region B-mask tt-dis-card-mask.rank B-rank RS-cli-mask 
         B-cli-mask CB-CC-run f-emitent-name l-rs-cli-mask f-cli-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
IF p-mode <> {&add-def} THEN do:
   IF tt-dis-card-mask.cli-code <> 0 THEN DO:
       FIND FIRST X_clients  NO-LOCK WHERE
                  X_clients.obj-type = tt-dis-card-mask.cli-type
           AND    X_clients.obj-code = tt-dis-card-mask.cli-code.

   END.
   IF tt-dis-card-mask.emitent-host-code <> 0 THEN DO:
      FIND FIRST X_clients_dctype  NO-LOCK WHERE
                      X_clients_dctype.obj-type = {&cmp}
               AND    X_clients_dctype.obj-code = tt-dis-card-mask.emitent-host-code.

   END.
END.
if p-mode = {&add-def} then  do:
  RS-cli-mask = "cli-code":U .
end.
if tt-dis-card-mask.cli-code > 0 then do:
  if tt-dis-card-mask.cli-mask = '':U then do:
    RS-cli-mask = "cli-code":U .
  end.
  else do:
    RS-cli-mask = "cli-mask-cli-code":U.
  end.
end.
else do:
  RS-cli-mask = "cli-mask":U.
end.


ASSIGN
v-tab-order = "b-exit,b-quit,b-hist,b-help," +
              "b-card-type,mask-num,t-use-on-cd,RS-region,b-mask,rank,b-rank,Rs-cli-mask,cli-type,cli-code,b-cli,b-cli-mask,cb-cc-run"
tt-dis-card-mask.cli-type:RADIO-BUTTONS IN FRAME {&frame-name} = "Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                                                                   "Чел" + {&comma-char} + {&prs}
Rs-region:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
"Глобально" + {&comma-char} + "0":U + {&comma-char} +
("Фирма" + {&space-char} +
 (IF p-mode = {&add-def} OR tt-dis-card-mask.host-code = 0
  THEN STRING(p-curr-host-code)
  ELSE STRING(tt-dis-card-mask.host-code))) + {&comma-char} + "1":U + {&comma-char} +
("Объект" + {&space-char} +
  (IF p-mode = {&add-def} OR tt-dis-card-mask.obj-code = 0
   THEN (p-curr-obj-type + STRING(p-curr-obj-code))
   ELSE (tt-dis-card-mask.obj-type + STRING(tt-dis-card-mask.obj-code))) + {&comma-char} + "2":U)
Rs-region = IF tt-dis-card-mask.host-code = 0
            THEN 0
            ELSE ( IF tt-dis-card-mask.obj-code = 0
                   THEN 1
                   ELSE 2
                  )
f-emitent-name = IF p-mode = {&add-def}
                 THEN "":U
                ELSE (IF tt-dis-card-mask.emitent-host-code = 0
                      THEN "Глобально"
                      ELSE X_clients_dctype.obj-name

                    )
cb-cc-run:LIST-ITEM-PAIRS  in frame {&frame-name} =  "Не используется" + {&comma-char} + {&dcm-cc-algo-no} + {&comma-char} +
                                                     "По методу Luhna" + {&comma-char} + {&dcm-cc-algo-luhn}
.
DISPLAY
RS-region
RS-cli-mask
f-emitent-name
f-cli-name
cb-cc-run
l-rs-cli-mask
WITH FRAME Dialog-Frame.
IF p-mode <> {&LOOKUP} THEN
ASSIGN
tt-dis-card-mask.mask:BGCOLOR = WHITE_COLOR
tt-dis-card-mask.cli-mask:BGCOLOR = WHITE_COLOR.
.
IF AVAILABLE tt-dis-card-mask THEN
DISPLAY
tt-dis-card-mask.type
tt-dis-card-mask.emitent-host-code
tt-dis-card-mask.mask-num
tt-dis-card-mask.rank
tt-dis-card-mask.mask
tt-dis-card-mask.cli-type
tt-dis-card-mask.cli-code
tt-dis-card-mask.cli-mask
tt-dis-card-mask.use-on
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit
b-quit
B-hist WHEN p-mode <> {&add-def}
B-Help
B-card-type WHEN (p-mode <> {&LOOKUP} and not (p-mode = {&add-def} and p-type <> "":U))
cb-cc-run WHEN p-mode <> {&LOOKUP}
b-rank WHEN p-mode <> {&LOOKUP}
b-mask WHEN p-mode <> {&LOOKUP}
RS-region WHEN p-mode <> {&LOOKUP}
tt-dis-card-mask.rank WHEN p-mode <> {&LOOKUP}
/*tt-dis-card-mask.mask WHEN p-mode <> {&LOOKUP}*/
tt-dis-card-mask.use-on WHEN p-mode <> {&LOOKUP}
RS-cli-mask WHEN p-mode <> {&LOOKUP}
reg-cash when p-mode <> {&LOOKUP}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide
  b-exit in frame {&frame-name}.
end.


RUN proc-cli-or-mask IN THIS-PROCEDURE(rs-cli-mask) NO-ERROR.
IF ERROR-STATUS:ERROR  THEN UNDO, RETURN ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-card-type Dialog-Frame 
PROCEDURE proc-b-card-type :
define variable var-rid-str as character no-undo.
define buffer b_clients for ub.clients.
var-rid-str = string(recid(locked_dis-card-type)).

run ref/dc-types.w (
               input parparentproc
              ,input "":U /*все типы карта и глоб и по фирме*/
              ,input "b-sel":U
              ,input 0
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input-output  var-rid-str) .

if var-rid-str = "" then return no-apply.
find first locked_dis-card-type no-lock where
           recid(locked_dis-card-type) = integer(var-rid-str) No-ERROR.
if not avail locked_dis-card-type then return no-apply.
if locked_dis-card-type.emitent-host-code = 0 then do:
  ASSIGN
  f-emitent-name = "Глобальная"
  tt-dis-card-mask.emitent-host-code = LOCKED_dis-card-type.emitent-host-code
  tt-dis-card-mask.TYPE              = LOCKED_dis-card-type.TYPE
  .
  RELEASE X_clients_dctype.
end.
else do:
   find first b_clients No-LOCK WHERE
              b_clients.obj-type = {&cmp} and
              b_clients.obj-code = locked_dis-card-type.emitent-host-code No-ERROR.
   if not avail b_clients then return no-apply.
   ASSIGN
   f-emitent-name = b_clients.obj-name
   tt-dis-card-mask.emitent-host-code = LOCKED_dis-card-type.emitent-host-code
   tt-dis-card-mask.TYPE              = LOCKED_dis-card-type.TYPE
   .
   FIND FIRST X_clients_dctype NO-LOCK WHERE
             recid(X_clients_dctype) = recid(b_clients).

END.
   display
   tt-dis-card-mask.type
   tt-dis-card-mask.emitent-host-code
   f-emitent-name
   with frame {&frame-name}
   .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cli-or-mask Dialog-Frame 
PROCEDURE proc-cli-or-mask :
DEFINE INPUT PARAMETER p-cli-or-mask AS character NO-UNDO.
CASE p-cli-or-mask:
    WHEN "cli-code":U THEN DO:
        ASSIGN
        tt-dis-card-mask.cli-mask = "":U.
        ASSIGN
        cb-cc-run = '':U
        .
        DISPLAY
        tt-dis-card-mask.cli-mask
        cb-cc-run
        WITH FRAME {&FRAME-NAME}.
        DISABLE
        tt-dis-card-mask.cli-mask
        b-cli-mask
        cb-cc-run
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        b-cli      when p-mode <> {&lookup}
        tt-dis-card-mask.cli-code when p-mode <> {&lookup}
        tt-dis-card-mask.cli-type when p-mode <> {&lookup}
        WITH FRAME {&FRAME-NAME}.
    END.
    WHEN "cli-mask":U THEN DO:
        ASSIGN
        tt-dis-card-mask.cli-code = 0
        f-cli-name = "":U
        .
        DISPLAY
        tt-dis-card-mask.cli-code
        f-cli-name
        WITH FRAME {&FRAME-NAME}.
        DISABLE
        tt-dis-card-mask.cli-type
        tt-dis-card-mask.cli-code
        b-cli
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        b-cli-mask when p-mode <> {&lookup}
        cb-cc-run  when p-mode <> {&lookup}
        WITH FRAME {&FRAME-NAME}.
    END.
     WHEN "cli-mask-cli-code":U THEN DO:
        DISPLAY
        tt-dis-card-mask.cli-code
        f-cli-name
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        b-cli-mask when p-mode <> {&lookup}
        cb-cc-run  when p-mode <> {&lookup}
        b-cli      when p-mode <> {&lookup}
        tt-dis-card-mask.cli-code when p-mode <> {&lookup}
        tt-dis-card-mask.cli-type when p-mode <> {&lookup}
        WITH FRAME {&FRAME-NAME}.
    END.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable glog as logical no-undo .
if p-mode = {&lookup} then do:
    return error.
end.

assign
frame {&frame-name}
reg-cash
rs-CLI-MASK
rs-region
cb-cc-run
tt-dis-card-mask.use-on
tt-dis-card-mask.cc-run = INTEGER(cb-cc-run)
tt-dis-card-mask.host-code = (IF rs-region = 0 THEN 0 ELSE p-curr-host-code)
tt-dis-card-mask.obj-type  = (IF rs-region < 2 THEN "":U ELSE p-curr-obj-type)
tt-dis-card-mask.obj-code  = (IF rs-region < 2 THEN 0 ELSE p-curr-obj-code)
tt-dis-card-mask.cli-code
tt-dis-card-mask.cli-code = (IF RS-CLI-MASK = "CLI-CODE":u or RS-CLI-MASK = "cli-mask-cli-code"
                             THEN tt-dis-card-mask.cli-code
                             else 0)
tt-dis-card-mask.cli-type
tt-dis-card-mask.cli-type = (IF RS-CLI-MASK = "CLI-CODE":u or RS-CLI-MASK = "cli-mask-cli-code"
                             THEN tt-dis-card-mask.cli-type
                             else "":U)
tt-dis-card-mask.cli-mask
tt-dis-card-mask.cli-mask  = (IF RS-CLI-MASK = "CLI-MASK":u or RS-CLI-MASK = "cli-mask-cli-code"
                              THEN tt-dis-card-mask.cli-mask
                              ELSE "":U)
tt-dis-card-mask.emitent-host-code
tt-dis-card-mask.mask
tt-dis-card-mask.mask-num
tt-dis-card-mask.rank
tt-dis-card-mask.type
.
if index(tt-dis-card-mask.cli-mask, {&question-mark}) > 0 then do:
  message
  substitute("Если Вы планируете использовать ДАННУЮ маску для передачи на кассы ДЛИННЫХ номеров карт&1" +
             "или определения КОРОТКИХ номеров карт (номеров, хранящихся в TH) по ДЛИННЫМ номерам при приеме чеков с касс&1" +
             "то карта не должна содержать знаки &2&1" +
             "Все равно сохранить маску?"
             , {&new-line}
             , {&question-mark})
  view-as alert-box WARNING buttons  YES-NO update glog.
  if not glog then undo, return error .
end.

 run ref/dc-mask1.p (
input-output p-doc-rec
,input parparentproc
,input p-mode
,INPUT tt-dis-card-mask.use-on
,input tt-dis-card-mask.cli-code
,input tt-dis-card-mask.cli-mask
,input tt-dis-card-mask.cli-type
,input tt-dis-card-mask.emitent-host-code
,input tt-dis-card-mask.host-code
,input tt-dis-card-mask.mask-num
,input tt-dis-card-mask.mask
,input tt-dis-card-mask.obj-code
,input tt-dis-card-mask.obj-type
,input tt-dis-card-mask.rank
,input tt-dis-card-mask.type
,input tt-dis-card-mask.cc-run
,input reg-cash
)
no-error.

if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

