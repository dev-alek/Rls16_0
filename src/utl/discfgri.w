&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE BUFFER Locked_dis-time-rule FOR ub.dis-time-rule.
DEFINE TEMP-TABLE tt-dis-cfg-rule NO-UNDO LIKE ub.dis-cfg-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка конфигурации ПРАВИЛО-СКИДКИ-POS-РАСПИСАНИЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-table-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-pos-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-time-templ-rl-root AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-discnt-role AS character NO-UNDO.
DEFINE INPUT PARAMETER p-self-nonunique AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка конфигурации ПРАВИЛО-СКИДКИ-POS-РАСПИСАНИЕ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/tblfname.i }

define variable v-is-copy as logical no-undo .
DEFINE VARIABLE v-self-nonunique-grp-list-items AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_dis-cfg-rule tt-dis-cfg-rule

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-cfg-rule.templ-rl-root ~
tt-dis-cfg-rule.time-templ-rl-root tt-dis-cfg-rule.pos-type ~
tt-dis-cfg-rule.table-name tt-dis-cfg-rule.self-nonunique ~
tt-dis-cfg-rule.discnt-role tt-dis-cfg-rule.nonunique ~
tt-dis-cfg-rule.link-prop tt-dis-cfg-rule.projection
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-dis-cfg-rule.templ-rl-root tt-dis-cfg-rule.time-templ-rl-root ~
tt-dis-cfg-rule.pos-type tt-dis-cfg-rule.table-name ~
tt-dis-cfg-rule.self-nonunique tt-dis-cfg-rule.discnt-role ~
tt-dis-cfg-rule.nonunique tt-dis-cfg-rule.link-prop ~
tt-dis-cfg-rule.projection
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-dis-cfg-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-dis-cfg-rule
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH locked_dis-cfg-rule SHARE-LOCK, ~
      EACH tt-dis-cfg-rule WHERE TRUE /* Join to locked_dis-cfg-rule incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH locked_dis-cfg-rule SHARE-LOCK, ~
      EACH tt-dis-cfg-rule WHERE TRUE /* Join to locked_dis-cfg-rule incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame locked_dis-cfg-rule ~
tt-dis-cfg-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame locked_dis-cfg-rule
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-dis-cfg-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-dis-cfg-rule.templ-rl-root ~
tt-dis-cfg-rule.time-templ-rl-root tt-dis-cfg-rule.pos-type ~
tt-dis-cfg-rule.table-name tt-dis-cfg-rule.self-nonunique ~
tt-dis-cfg-rule.discnt-role tt-dis-cfg-rule.nonunique ~
tt-dis-cfg-rule.link-prop tt-dis-cfg-rule.projection
&Scoped-define ENABLED-TABLES tt-dis-cfg-rule
&Scoped-define FIRST-ENABLED-TABLE tt-dis-cfg-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-dis-rule-des ~
b-dis-ruls b-dist-rls f-dis-time-rule-des tg-has-global tg-has-host ~
tg-has-object cb-discnt-type cb-subject-type
&Scoped-Define DISPLAYED-FIELDS tt-dis-cfg-rule.templ-rl-root ~
tt-dis-cfg-rule.time-templ-rl-root tt-dis-cfg-rule.pos-type ~
tt-dis-cfg-rule.table-name tt-dis-cfg-rule.self-nonunique ~
tt-dis-cfg-rule.discnt-role tt-dis-cfg-rule.nonunique ~
tt-dis-cfg-rule.link-prop tt-dis-cfg-rule.projection
&Scoped-define DISPLAYED-TABLES tt-dis-cfg-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-cfg-rule
&Scoped-Define DISPLAYED-OBJECTS f-dis-rule-des f-dis-time-rule-des ~
tg-has-global tg-has-host tg-has-object cb-discnt-type cb-subject-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dis-ruls
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.

DEFINE BUTTON b-dist-rls
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-discnt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип Скидки"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 55 BY .93 NO-UNDO.

DEFINE VARIABLE cb-subject-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Воздействие (место расчета)"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 55.5 BY .93 NO-UNDO.

DEFINE VARIABLE f-dis-rule-des AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 83.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-dis-time-rule-des AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 83.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tg-has-global AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.

DEFINE VARIABLE tg-has-host AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.

DEFINE VARIABLE tg-has-object AS LOGICAL INITIAL no
     LABEL "Toggle 3"
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      locked_dis-cfg-rule,
      tt-dis-cfg-rule SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-dis-cfg-rule.templ-rl-root AT ROW 3 COL 5 COLON-ALIGNED NO-LABEL WIDGET-ID 16
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     f-dis-rule-des AT ROW 3 COL 16 NO-LABEL WIDGET-ID 4
     b-dis-ruls AT ROW 3.13 COL 2 WIDGET-ID 2
     b-dist-rls AT ROW 5 COL 2 WIDGET-ID 6
     tt-dis-cfg-rule.time-templ-rl-root AT ROW 5 COL 5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     f-dis-time-rule-des AT ROW 5 COL 16 NO-LABEL WIDGET-ID 8
     tt-dis-cfg-rule.pos-type AT ROW 6.33 COL 28 COLON-ALIGNED WIDGET-ID 38
          LABEL "Место использ."
          VIEW-AS COMBO-BOX INNER-LINES 15
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 23 BY 1
     tt-dis-cfg-rule.table-name AT ROW 6.33 COL 67 COLON-ALIGNED WIDGET-ID 40
          LABEL "Таблица связи" FORMAT "x(40)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-dis-cfg-rule.self-nonunique AT ROW 7.4 COL 67 COLON-ALIGNED WIDGET-ID 58
          LABEL "self-nonunique"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 30 BY 1
     tt-dis-cfg-rule.discnt-role AT ROW 9.53 COL 28 COLON-ALIGNED WIDGET-ID 42
          LABEL "Роль скидки" FORMAT "X(40)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 51 BY 1
     tt-dis-cfg-rule.nonunique AT ROW 10.87 COL 28 COLON-ALIGNED WIDGET-ID 36
          LABEL "nonunique"
          VIEW-AS FILL-IN NATIVE
          SIZE 32.5 BY 1.07
     tt-dis-cfg-rule.link-prop AT ROW 13.8 COL 54 COLON-ALIGNED WIDGET-ID 64
          LABEL "Св-ва связи с объектом"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 34.5 BY 1
     tg-has-global AT ROW 14 COL 21 WIDGET-ID 46
     tg-has-host AT ROW 15 COL 21 WIDGET-ID 48
     tt-dis-cfg-rule.projection AT ROW 15.93 COL 38.5 COLON-ALIGNED HELP
          "" WIDGET-ID 66
          LABEL "Проекция"
          VIEW-AS FILL-IN
          SIZE 55.5 BY 1 TOOLTIP "Проекцич полей первичн.ключа (через запятую)"
     tg-has-object AT ROW 16 COL 21 WIDGET-ID 50
     cb-discnt-type AT ROW 18.07 COL 39 COLON-ALIGNED WIDGET-ID 68
     cb-subject-type AT ROW 20.2 COL 39 COLON-ALIGNED WIDGET-ID 70
     "Бывает фирма:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 15 COL 6 WIDGET-ID 54
     "Бывает объект:" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 16 COL 4.9 WIDGET-ID 56
     "Шаблон расписания" VIEW-AS TEXT
          SIZE 21 BY 1 AT ROW 4 COL 4 WIDGET-ID 22
     "Шаблон правила скидок" VIEW-AS TEXT
          SIZE 21 BY 1 AT ROW 2 COL 4 WIDGET-ID 20
     "Бывает глобальной:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 14 COL 1 WIDGET-ID 52
     SPACE(80.20) SKIP(8.55)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запись конфигурации правил скидок"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-cfg-rule B "?" NO-UNDO ub dis-cfg-rule
      TABLE: locked_dis-rule B "?" ? ub dis-rule
      TABLE: Locked_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: tt-dis-cfg-rule T "?" NO-UNDO ub dis-cfg-rule
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

/* SETTINGS FOR COMBO-BOX tt-dis-cfg-rule.discnt-role IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN f-dis-rule-des IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-dis-rule-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-dis-time-rule-des IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-dis-time-rule-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR COMBO-BOX tt-dis-cfg-rule.link-prop IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-cfg-rule.nonunique IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-dis-cfg-rule.pos-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-cfg-rule.projection IN FRAME Dialog-Frame
   EXP-LABEL EXP-HELP                                                   */
/* SETTINGS FOR COMBO-BOX tt-dis-cfg-rule.self-nonunique IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-dis-cfg-rule.table-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-dis-cfg-rule.templ-rl-root IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-cfg-rule.time-templ-rl-root IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.locked_dis-cfg-rule,Temp-Tables.tt-dis-cfg-rule WHERE Temp-Tables.locked_dis-cfg-rule ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Запись конфигурации правил скидок */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Запись конфигурации правил скидок */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-ruls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-ruls Dialog-Frame
ON CHOOSE OF b-dis-ruls IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
run utl/disruls0.w (
                    input parparentproc
                    ,input "b-sel":U
                    ,input-output v-rid-list ) no-error .

IF v-rid-list <> '':U THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE recid(buf_dis-rule) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_dis-rule THEN RETURN NO-APPLY.
  ASSIGN
  tt-dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
  f-dis-rule-des = buf_dis-rule.des
  .
END.
ELSE DO:
  ASSIGN
  tt-dis-cfg-rule.templ-rl-root = 0
  f-dis-rule-des = '':U
  .
END.
DISPLAY
f-dis-rule-des
tt-dis-cfg-rule.templ-rl-root
WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dist-rls
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dist-rls Dialog-Frame
ON CHOOSE OF b-dist-rls IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
    run ref/dist-rls.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input "template"
                  ,input 0
                  ,input 0
                  ,input ''
                  ,input-output v-sts
                  ,input-output v-rid-list) no-error .
IF v-rid-list <> '':U THEN DO:
  FIND FIRST buf_dis-time-rule NO-LOCK WHERE recid(buf_dis-time-rule) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_dis-time-rule THEN RETURN NO-APPLY.
  ASSIGN
  tt-dis-cfg-rule.time-templ-rl-root = buf_dis-time-rule.templ-rl-root
  f-dis-time-rule-des = buf_dis-time-rule.des
  .
END.
ELSE DO:
  ASSIGN
  tt-dis-cfg-rule.time-templ-rl-root = 0
  f-dis-time-rule-des = '':U
  .
END.
DISPLAY
f-dis-time-rule-des
tt-dis-cfg-rule.time-templ-rl-root
WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-cfg-rule.table-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-cfg-rule.table-name Dialog-Frame
ON VALUE-CHANGED OF tt-dis-cfg-rule.table-name IN FRAME Dialog-Frame /* Таблица связи */
DO:
  ASSIGN
  tt-dis-cfg-rule.table-name.
  RUN refresh-discnt-role IN this-procedure .
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> {&add-def}
  AND p-mode <> {&UPDATE}
  AND p-mode <> {&LOOKUP}
  AND p-mode <> {&add-copy}
  THEN DO:
    MESSAGE
    "Неверное значение параметра p-mode=" p-mode
     VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  CASE p-mode:
    WHEN {&add-def} THEN DO:
      CREATE tt-dis-cfg-rule.
    END.
    WHEN {&UPDATE} THEN DO:
       FIND FIRST LOCKED_dis-cfg-rule EXCLUSIVE-LOCK where
               LOCKED_dis-cfg-rule.TABLE-name = p-table-name
           AND LOCKED_dis-cfg-rule.pos-type = p-pos-type
           AND LOCKED_dis-cfg-rule.templ-rl-root = p-templ-rl-root
           AND LOCKED_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
           AND LOCKED_dis-cfg-rule.discnt-role = p-discnt-role
           AND LOCKED_dis-cfg-rule.self-nonunique = p-self-nonunique.
      CREATE tt-dis-cfg-rule.
      BUFFER-COPY LOCKED_dis-cfg-rule TO tt-dis-cfg-rule.
    END.
    WHEN {&LOOKUP}
    or when {&add-copy}
    THEN DO:
        FIND FIRST LOCKED_dis-cfg-rule no-lock where
                LOCKED_dis-cfg-rule.TABLE-name = p-table-name
            AND LOCKED_dis-cfg-rule.pos-type = p-pos-type
            AND LOCKED_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            AND LOCKED_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
            AND LOCKED_dis-cfg-rule.discnt-role = p-discnt-role
            AND LOCKED_dis-cfg-rule.self-nonunique = p-self-nonunique.
      CREATE tt-dis-cfg-rule.
      BUFFER-COPY LOCKED_dis-cfg-rule TO tt-dis-cfg-rule.
    END.
  END CASE.
  if p-mode = {&add-copy} then do:
    assign
    v-is-copy = yes
    p-mode = {&add-def}
    .
  end.
  RUN Myenable.
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
  DISPLAY f-dis-rule-des f-dis-time-rule-des tg-has-global tg-has-host
          tg-has-object cb-discnt-type cb-subject-type
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-cfg-rule THEN
    DISPLAY tt-dis-cfg-rule.templ-rl-root tt-dis-cfg-rule.time-templ-rl-root
          tt-dis-cfg-rule.pos-type tt-dis-cfg-rule.table-name
          tt-dis-cfg-rule.self-nonunique tt-dis-cfg-rule.discnt-role
          tt-dis-cfg-rule.nonunique tt-dis-cfg-rule.link-prop
          tt-dis-cfg-rule.projection
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-dis-cfg-rule.templ-rl-root f-dis-rule-des
         b-dis-ruls b-dist-rls tt-dis-cfg-rule.time-templ-rl-root
         f-dis-time-rule-des tt-dis-cfg-rule.pos-type
         tt-dis-cfg-rule.table-name tt-dis-cfg-rule.self-nonunique
         tt-dis-cfg-rule.discnt-role tt-dis-cfg-rule.nonunique
         tt-dis-cfg-rule.link-prop tg-has-global tg-has-host
         tt-dis-cfg-rule.projection tg-has-object cb-discnt-type
         cb-subject-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&dis-grp-classif-list}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&dis-grp-classif-list-full}) + {&comma-char} +
                   ENTRY(v-ii, {&dis-grp-classif-list}).
END.
ASSIGN
v-self-nonunique-grp-list-items = v-list-items.
v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt}).
END.

assign
tt-dis-cfg-rule.pos-type:list-item-pairs in frame {&frame-name} = v-list-items.
v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&dr-link-codes}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&dr-link-codes-full}) + {&comma-char} +
                   ENTRY(v-ii, {&dr-link-codes}).
END.
ASSIGN
tt-dis-cfg-rule.link-prop:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-list-items.

assign
v-list-items = ''.
do v-ii = 1 to num-entries({&discnt-type-list}):
  v-list-items = v-list-items + entry(v-ii, {&discnt-type-list-full}) + {&comma-char} + entry(v-ii, {&discnt-type-list}) + {&comma-char}.
end.
v-list-items = trim(v-list-items, {&comma-char}).
assign
cb-discnt-type:list-item-pairs = v-list-items.

assign
v-list-items = ''.
do v-ii = 1 to num-entries({&discnt-target-list}):
  v-list-items = v-list-items + entry(v-ii, {&discnt-target-list-full}) + {&comma-char} + entry(v-ii, {&discnt-target-list}) + {&comma-char}.
end.
v-list-items = trim(v-list-items, {&comma-char}).
assign
cb-subject-type:list-item-pairs = v-list-items.


assign
tt-dis-cfg-rule.table-name:list-item-pairs in frame {&frame-name} =
{&table_dis-gds-rule-full} + {&comma-char} +
{&table_dis-gds-rule} + {&comma-char} +
{&table_dis-thbj-rule-full} + {&comma-char} +
{&table_dis-thbj-rule} + {&comma-char} +
{&table_dis-cp-rule-full} + {&comma-char} +
{&table_dis-cp-rule} + {&comma-char} +
{&table_dis-dc-rule-full} + {&comma-char} +
{&table_dis-dc-rule} + {&comma-char} +
{&table_dis-dct-rule-full} + {&comma-char} +
{&table_dis-dct-rule} + {&comma-char} +
{&table_dis-grp-rule-full} + {&comma-char} +
{&table_dis-grp-rule}
.
if available tt-dis-cfg-rule
and not (p-mode = {&add-def}
         and
         v-is-copy = no)
then do:
  RUN refresh-discnt-role IN this-procedure .
END.
IF tt-dis-cfg-rule.templ-rl-root > 0 THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE
            buf_dis-rule.rule-num = p-templ-rl-root NO-ERROR.
  IF available buf_dis-rule THEN DO:
     ASSIGN
     f-dis-rule-des = buf_dis-rule.des.
  END.
END.
IF tt-dis-cfg-rule.time-templ-rl-root > 0 THEN DO:
    FIND FIRST buf_dis-time-rule NO-LOCK WHERE
              buf_dis-time-rule.time-rule-num = p-time-templ-rl-root NO-ERROR.
    IF available buf_dis-time-rule THEN DO:
       ASSIGN
       f-dis-time-rule-des = buf_dis-time-rule.des.
    END.
END.
DISPLAY f-dis-rule-des f-dis-time-rule-des
WITH FRAME {&frame-name}.
IF AVAILABLE tt-dis-cfg-rule THEN DO:
    assign
        tg-has-global   = ( tt-dis-cfg-rule.has-global <> 0 )
        tg-has-host     = ( tt-dis-cfg-rule.has-host   <> 0 )
        tg-has-object   = ( tt-dis-cfg-rule.has-obj    <> 0 )
        cb-discnt-type = string(tt-dis-cfg-rule.discnt-type)
        cb-subject-type = string(tt-dis-cfg-rule.subject-type)
    .
    DISPLAY
        tt-dis-cfg-rule.templ-rl-root
        tt-dis-cfg-rule.time-templ-rl-root
        tt-dis-cfg-rule.pos-type
        tt-dis-cfg-rule.table-name
        tt-dis-cfg-rule.discnt-role
        tt-dis-cfg-rule.nonunique
        tt-dis-cfg-rule.link-prop
        tg-has-global
        tg-has-host
        tg-has-object
        tt-dis-cfg-rule.projection
        cb-discnt-type
        cb-subject-type
    WITH FRAME {&frame-name}.
END.
ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Help
b-dis-ruls when p-mode = {&add-def}
b-dist-rls when p-mode = {&add-def}
tt-dis-cfg-rule.pos-type  when p-mode = {&add-def}
tt-dis-cfg-rule.table-name  when p-mode = {&add-def}
tt-dis-cfg-rule.discnt-role when p-mode <> {&lookup}
tt-dis-cfg-rule.nonunique   when p-mode <> {&lookup}
tt-dis-cfg-rule.link-prop  when p-mode <> {&lookup}
tt-dis-cfg-rule.projection when p-mode <> {&lookup}
tg-has-global  when p-mode <> {&lookup}
tg-has-host    when p-mode <> {&lookup}
tg-has-object  when p-mode <> {&lookup}
cb-discnt-type when p-mode <> {&lookup}
cb-subject-type when p-mode <> {&lookup}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = {&LOOKUP} THEN RETURN .
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.

ASSIGN
FRAME {&FRAME-NAME}
tg-has-global
tg-has-host
tg-has-object
cb-discnt-type
cb-subject-type
tt-dis-cfg-rule.templ-rl-root
tt-dis-cfg-rule.time-templ-rl-root
tt-dis-cfg-rule.pos-type
tt-dis-cfg-rule.discnt-role
tt-dis-cfg-rule.has-glob = integer( tg-has-global )
tt-dis-cfg-rule.has-host = integer( tg-has-host   )
tt-dis-cfg-rule.has-obj  = integer( tg-has-object )
tt-dis-cfg-rule.table-name
tt-dis-cfg-rule.nonunique
tt-dis-cfg-rule.link-prop
tt-dis-cfg-rule.projection
tt-dis-cfg-rule.discnt-type = integer(cb-discnt-type)
tt-dis-cfg-rule.subject-type = integer(cb-subject-type)
.
IF  tt-dis-cfg-rule.self-nonunique:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
   ASSIGN tt-dis-cfg-rule.self-nonunique.
END.
ELSE DO:
   ASSIGN tt-dis-cfg-rule.self-nonunique = '':U.
END.
run utl/discfgr1.p ( INPUT p-mode
                    ,INPUT NO /*p-silent*/
                    ,INPUT-output v-rec
                    ,INPUT tt-dis-cfg-rule.table-name
                    ,INPUT tt-dis-cfg-rule.pos-type
                    ,INPUT tt-dis-cfg-rule.templ-rl-root
                    ,INPUT tt-dis-cfg-rule.discnt-role
                    ,INPUT tt-dis-cfg-rule.time-templ-rl-root
                    ,INPUT tt-dis-cfg-rule.self-nonunique
                    ,INPUT tt-dis-cfg-rule.nonunique
                    ,INPUT tt-dis-cfg-rule.has-glob
                    ,INPUT tt-dis-cfg-rule.has-host
                    ,INPUT tt-dis-cfg-rule.has-obj
                    ,INPUT tt-dis-cfg-rule.link-prop
                    ,input tt-dis-cfg-rule.projection
                    ,input tt-dis-cfg-rule.discnt-type
                    ,input tt-dis-cfg-rule.subject-type
                    ) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
 { gbl/reterhnd.i error }
  undo, return error.

END.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-discnt-role Dialog-Frame
PROCEDURE refresh-discnt-role :
define variable v-discnt-role-list as character no-undo .
define variable v-discnt-role-list-full as character no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
CASE tt-dis-cfg-rule.table-name:
    when {&table_dis-gds-rule} then do:
       assign
       v-discnt-role-list = {&disgdsru-list}
       v-discnt-role-list-full = {&disgdsru-list-full}
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME {&FRAME-NAME}.

    end.
    when {&table_dis-cp-rule} then do:
       assign
       v-discnt-role-list = {&dcpr-list}
       v-discnt-role-list-full = {&dcpr-list-full}
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME {&FRAME-NAME}.

    end.
    when {&table_dis-dc-rule} then do:
       assign
       v-discnt-role-list = {&ddcr-list}
       v-discnt-role-list-full = {&ddcr-list-full}
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME {&FRAME-NAME}.

    end.
    when {&table_dis-dct-rule} then do:
       assign
       v-discnt-role-list = {&ddctr-list}
       v-discnt-role-list-full = {&ddctr-list-full}
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME {&FRAME-NAME}.

    end.
    when {&table_dis-grp-rule} then do:
       assign
       v-discnt-role-list = {&dggrr-list} + {&comma-char} + {&dclgr-list}
       v-discnt-role-list-full = {&dggrr-list-full} + {&comma-char} + {&dclgr-list-full}
       tt-dis-cfg-rule.self-nonunique:LIST-ITEM-PAIRS = v-self-nonunique-grp-list-items
       .
       DISPLAY
       tt-dis-cfg-rule.self-nonunique
       WITH FRAME {&FRAME-NAME}.
       if p-mode <> {&lookup} then do:
        enable
        tt-dis-cfg-rule.self-nonunique
        with frame {&frame-name} .
      end.
    end.
    when {&table_dis-some-rule} then do:
        hide
        tt-dis-cfg-rule.self-nonunique
        in FRAME {&FRAME-NAME}.

    end.
    when {&table_dis-thbj-rule} then do:
       assign
       v-discnt-role-list = {&dthbjr-list}
       v-discnt-role-list-full = {&dthbjr-list-full}
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME {&FRAME-NAME}.

    end.
  END CASE.

DO v-ii = 1 TO NUM-ENTRIES(v-discnt-role-list):
    ASSIGN
    v-list-items = v-list-items +  (IF v-ii > 1 THEN {&comma-char} ELSE '':U) +
                   ENTRY(v-ii, v-discnt-role-list-full) + {&comma-char} +
                   ENTRY(v-ii, v-discnt-role-list).
END.
assign
tt-dis-cfg-rule.discnt-role:list-item-pairs in frame {&frame-name} = v-list-items.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
