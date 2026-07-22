&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-time-rule FOR ub.dis-time-rule.
DEFINE TEMP-TABLE temp-drt-prop NO-UNDO LIKE ub.drt-prop
       field upper-prop-label as character
       field prop-label as character


       .
DEFINE TEMP-TABLE tt-dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE TEMP-TABLE tt-drt-prop NO-UNDO LIKE ub.drt-prop
       field full-prop-name as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка нового шаблона расписани

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/28/07
Author: Bakhtadze Natalya
Creation date: 05/28/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка нового шаблона расписания".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

define variable v-is-copy as logical no-undo .
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
DEFINE STREAM instream.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
define buffer locked_dis-cfg-rule for ub.dis-cfg-rule.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-drt-prop

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-drt-prop tt-dis-time-rule

/* Definitions for BROWSE br-drt-prop                                   */
&Scoped-define FIELDS-IN-QUERY-br-drt-prop tt-drt-prop.node-code tt-drt-prop.upper-node-code tt-drt-prop.full-prop-name tt-drt-prop.property-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-drt-prop
&Scoped-define SELF-NAME br-drt-prop
&Scoped-define QUERY-STRING-br-drt-prop FOR EACH tt-drt-prop INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-drt-prop OPEN QUERY drt-prop FOR EACH tt-drt-prop INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-drt-prop tt-drt-prop
&Scoped-define FIRST-TABLE-IN-QUERY-br-drt-prop tt-drt-prop


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-time-rule.templ-rl-root ~
tt-dis-time-rule.des tt-dis-time-rule.other-inf tt-dis-time-rule.uniq-field ~
tt-dis-time-rule.value-type tt-dis-time-rule.sts
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-dis-time-rule.templ-rl-root tt-dis-time-rule.des ~
tt-dis-time-rule.other-inf tt-dis-time-rule.uniq-field ~
tt-dis-time-rule.value-type tt-dis-time-rule.sts
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-dis-time-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-dis-time-rule
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-dis-time-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-dis-time-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-dis-time-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-dis-time-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-dis-time-rule.templ-rl-root ~
tt-dis-time-rule.des tt-dis-time-rule.other-inf tt-dis-time-rule.uniq-field ~
tt-dis-time-rule.value-type tt-dis-time-rule.sts
&Scoped-define ENABLED-TABLES tt-dis-time-rule
&Scoped-define FIRST-ENABLED-TABLE tt-dis-time-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help F-level-1 F-level-2 ~
b-add b-del b-chg br-drt-prop
&Scoped-Define DISPLAYED-FIELDS tt-dis-time-rule.templ-rl-root ~
tt-dis-time-rule.des tt-dis-time-rule.other-inf tt-dis-time-rule.uniq-field ~
tt-dis-time-rule.value-type tt-dis-time-rule.sts
&Scoped-define DISPLAYED-TABLES tt-dis-time-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-time-rule
&Scoped-Define DISPLAYED-OBJECTS F-level-1 F-level-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-level-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень1"
     VIEW-AS FILL-IN
     SIZE 75 BY 1 NO-UNDO.

DEFINE VARIABLE F-level-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень2"
     VIEW-AS FILL-IN
     SIZE 75 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-drt-prop FOR
      tt-drt-prop SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-dis-time-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-drt-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-drt-prop Dialog-Frame _FREEFORM
  QUERY br-drt-prop NO-LOCK DISPLAY
      tt-drt-prop.node-code COLUMN-LABEL "код" FORMAT ">>9"
tt-drt-prop.upper-node-code COLUMN-LABEL "выш.!код" FORMAT ">>9"
tt-drt-prop.full-prop-name COLUMN-LABEL "Свойство" FORMAT "X(255)" WIDTH 40
tt-drt-prop.property-value COLUMN-LABEL "Значение" FORMAT "X(255)" WIDTH 58
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.87 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-dis-time-rule.templ-rl-root AT ROW 1 COL 43 COLON-ALIGNED WIDGET-ID 4
          LABEL "Код шаблона"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-Help AT ROW 1 COL 95
     tt-dis-time-rule.des AT ROW 2 COL 4 WIDGET-ID 6
          LABEL "Описание"
          VIEW-AS FILL-IN
          SIZE 84.5 BY 1
     tt-dis-time-rule.other-inf AT ROW 4 COL 2.6 WIDGET-ID 10
          LABEL "Другая инф" FORMAT "X(90)"
          VIEW-AS FILL-IN
          SIZE 84.5 BY 1
     tt-dis-time-rule.uniq-field AT ROW 5 COL 51 COLON-ALIGNED WIDGET-ID 14
          LABEL "Дерево" FORMAT "X(65)"
          VIEW-AS FILL-IN
          SIZE 46 BY 1
     F-level-1 AT ROW 6.27 COL 14.5 COLON-ALIGNED WIDGET-ID 72
     F-level-2 AT ROW 7.5 COL 14.5 COLON-ALIGNED WIDGET-ID 74
     tt-dis-time-rule.value-type AT ROW 8.73 COL 51 NO-LABEL WIDGET-ID 76
          VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL
          SIZE 23 BY 4.53
     tt-dis-time-rule.sts AT ROW 10 COL 1 NO-LABEL WIDGET-ID 42
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 0,
"Item 2", 1
          SIZE 15.5 BY 1.87
     b-add AT ROW 12.27 COL 1 WIDGET-ID 36
     b-del AT ROW 12.27 COL 11 WIDGET-ID 38
     b-chg AT ROW 12.27 COL 21 WIDGET-ID 40
     br-drt-prop AT ROW 13.27 COL 1 WIDGET-ID 100
     "Статус" VIEW-AS TEXT
          SIZE 9 BY .8 AT ROW 9 COL 1 WIDGET-ID 46
     SPACE(89.13) SKIP(13.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Название  секции"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: temp-drt-prop T "?" NO-UNDO ub drt-prop
      ADDITIONAL-FIELDS:
          field upper-prop-label as character
          field prop-label as character



      END-FIELDS.
      TABLE: tt-dis-time-rule T "?" NO-UNDO ub dis-time-rule
      TABLE: tt-drt-prop T "?" NO-UNDO ub drt-prop
      ADDITIONAL-FIELDS:
          field full-prop-name as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-drt-prop b-chg Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-time-rule.des IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-dis-time-rule.other-inf IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-dis-time-rule.templ-rl-root IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-time-rule.uniq-field IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-drt-prop
/* Query rebuild information for BROWSE br-drt-prop
     _START_FREEFORM
OPEN QUERY drt-prop FOR EACH tt-drt-prop INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-drt-prop */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-dis-time-rule"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Название  секции */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Название  секции */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable v-node-code as integer   no-undo .

  RUN proc-b-add IN THIS-PROCEDURE ( output v-node-code) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  if not available tt-drt-prop or v-node-code = ? then return no-apply.
  run proc-b-chg in this-procedure no-error .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF NOT AVAILABLE tt-drt-prop THEN RETURN NO-APPLY.
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-drt-prop THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-drt-prop
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
      CREATE tt-dis-time-rule.
    END.
    WHEN {&UPDATE} THEN DO:
       FIND FIRST LOCKED_dis-time-rule EXCLUSIVE-LOCK where
               LOCKED_dis-time-rule.time-rule-num = p-templ-rl-root .
      CREATE tt-dis-time-rule.
      BUFFER-COPY LOCKED_dis-time-rule TO tt-dis-time-rule.
      find first locked_dis-cfg-rule exclusive-lock where
                locked_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
            and locked_dis-cfg-rule.table-name = '':U
            and locked_dis-cfg-rule.pos-type = '':U
            and locked_dis-cfg-rule.self-nonunique = '':U
            and locked_dis-cfg-rule.templ-rl-root = 0
            .

    END.
    WHEN {&LOOKUP}
    or when {&add-copy}
    THEN DO:
        FIND FIRST LOCKED_dis-time-rule no-lock where
              LOCKED_dis-time-rule.time-rule-num = p-templ-rl-root.
      CREATE tt-dis-time-rule.
      BUFFER-COPY LOCKED_dis-time-rule
      except templ-rl-root
             time-rule-num
             rl-root
      TO tt-dis-time-rule
      assign
      tt-dis-time-rule.templ-rl-root = (if p-mode = {&add-copy}
                                   then 0
                                   else locked_dis-time-rule.templ-rl-root )
      tt-dis-time-rule.rl-root = (if p-mode = {&add-copy}
                             then 0
                             else locked_dis-time-rule.rl-root)
      tt-dis-time-rule.time-rule-num = (if p-mode = {&add-copy}
                              then 0
                              else locked_dis-time-rule.time-rule-num)
      .
      find first locked_dis-cfg-rule no-lock where
                locked_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
            and locked_dis-cfg-rule.table-name = '':U
            and locked_dis-cfg-rule.pos-type = '':U
            and locked_dis-cfg-rule.self-nonunique = '':U
            and locked_dis-cfg-rule.templ-rl-root = 0
            .

    END.
  END CASE.
  if p-mode = {&add-copy} then do:
    assign
    v-is-copy = yes
    p-mode = {&add-def}
    .
  end.
  RUN fill-temp-drt-prop IN THIS-PROCEDURE.
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
  DISPLAY F-level-1 F-level-2
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-time-rule THEN
    DISPLAY tt-dis-time-rule.templ-rl-root tt-dis-time-rule.des
          tt-dis-time-rule.other-inf tt-dis-time-rule.uniq-field
          tt-dis-time-rule.value-type tt-dis-time-rule.sts
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-dis-time-rule.templ-rl-root B-Help
         tt-dis-time-rule.des tt-dis-time-rule.other-inf
         tt-dis-time-rule.uniq-field F-level-1 F-level-2
         tt-dis-time-rule.value-type tt-dis-time-rule.sts b-add b-del b-chg
         br-drt-prop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-drt-prop Dialog-Frame
PROCEDURE fill-temp-drt-prop :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
DEFINE VARIABLE v-start AS LOGICAL NO-UNDO INIT YES.
DEFINE VARIABLE v-node-code AS integer NO-UNDO.
DEFINE BUFFER buf_drt-prop FOR  ub.drt-prop.
DEFINE BUFFER upper_drt-prop FOR ub.drt-prop.
DEFINE BUFFER buf_tt-drt-prop FOR tt-drt-prop.
_buf_drt-prop:
FOR EACH buf_drt-prop NO-LOCK WHERE
        buf_drt-prop.templ-rl-root = p-templ-rl-root:
  CREATE buf_tt-drt-prop.
  BUFFER-COPY buf_drt-prop TO buf_tt-drt-prop
  .
  if v-is-copy = yes then do:
    assign
    buf_tt-drt-prop.templ-rl-root = -1.
  end.
  v-start = YES.
  FIND FIRST UPPER_drt-prop NO-LOCK WHERE
            UPPER_drt-prop.upper-node-code = buf_drt-prop.upper-node-code
        AND UPPER_drt-prop.node-code = buf_drt-prop.node-code
        AND UPPER_drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root.
  DO WHILE v-start OR buf_drt-prop.upper-node-code <> 0:
    v-start = NO.
    IF AVAILABLE UPPER_drt-prop THEN DO:
      ASSIGN
      buf_tt-drt-prop.full-prop-name = UPPER_drt-prop.prop-code +
                                          {&slash-char} +
                                      buf_tt-drt-prop.full-prop-name.

    END.
    v-node-code = upper_drt-prop.upper-node-code.
    FIND FIRST UPPER_drt-prop NO-LOCK WHERE
               UPPER_drt-prop.node-code = v-node-code
            AND UPPER_drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root NO-ERROR.
    IF NOT AVAILABLE UPPER_drt-prop THEN next _buf_drt-prop.
  END.

END.
CREATE tt-drt-prop.
ASSIGN
tt-drt-prop.prop-code = '':U
tt-drt-prop.node-code = 0
tt-drt-prop.upper-prop-code = '':U
tt-drt-prop.upper-node-code = 0
tt-drt-prop.templ-rl-root = (if v-is-copy then - 1 else p-templ-rl-root)
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-ii AS integer  NO-UNDO.
v-list-items = '':U.
DO v-ii = 1 TO NUM-ENTRIES({&dtr-type-list}):
    ASSIGN
    v-list-items = v-list-items +  (IF v-ii > 1 then {&comma-char} ELSE '':U) +
                   ENTRY(v-ii, {&dtr-type-list-full}) + {&comma-char} +
                   ENTRY(v-ii, {&dtr-type-list}).

END.
ASSIGN
tt-dis-time-rule.value-type:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-list-items.
assign
tt-dis-time-rule.sts:radio-buttons in frame {&frame-name} = "Текущий"   + {&comma-char} + {&current-status-int} +  {&comma-char} +
                                                   "Нетекущий" + {&comma-char} + {&deleted-status-int}
.
ASSIGN
f-level-1 = entry(1, locked_dis-cfg-rule.other-inf, ";":U)
f-level-2 = (if num-entries(locked_dis-cfg-rule.other-inf, ";":U) > 1
             then entry(2, locked_dis-cfg-rule.other-inf, ";":U)
             else '')
.
DISPLAY
f-level-1
f-level-2
WITH FRAME {&frame-name}.
IF AVAILABLE tt-dis-time-rule THEN
DISPLAY
tt-dis-time-rule.templ-rl-root
tt-dis-time-rule.des
tt-dis-time-rule.discnt-type
tt-dis-time-rule.other-inf
tt-dis-time-rule.uniq-field
tt-dis-time-rule.value-type
tt-dis-time-rule.sts
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
tt-dis-time-rule.templ-rl-root WHEN p-mode = {&add-def}
tt-dis-time-rule.des WHEN p-mode <> {&lookup}
tt-dis-time-rule.other-inf WHEN p-mode <> {&lookup}
tt-dis-time-rule.uniq-field WHEN p-mode <> {&lookup}
tt-dis-time-rule.value-type WHEN p-mode <> {&lookup}
tt-dis-time-rule.sts when p-mode <> {&lookup}
f-level-1 when p-mode <> {&lookup}
f-level-2 when p-mode <> {&lookup}
b-add WHEn p-mode <> {&LOOKUP}
b-del WHEn p-mode <> {&LOOKUP}
b-chg WHEn p-mode <> {&LOOKUP}
br-drt-prop
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:column = 1
  b-quit:label = "&Выход"
  .
end.
RUN OPENbr IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
OPEN QUERY br-drt-prop FOR EACH tt-drt-prop by tt-drt-prop.full-prop-name.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define output parameter p-node-code     as integer initial ?  no-undo .

DEFINE VARIABLE v-upper-prop-code       AS CHARACTER NO-UNDO .
define variable v-upper-node-code       as integer   no-undo .
DEFINE VARIABLE v-upper-prop-label      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-full-prop-name        AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-upper-full-prop-name  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-prop-code             AS CHARACTER NO-UNDO .
define variable v-node-code             as integer   no-undo .
DEFINE VARIABLE v-prop-label            AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-property-value        AS CHARACTER NO-UNDO .

DEFINE BUFFER buf_tt-drt-prop FOR tt-drt-prop.

run utl/drtpropi.w (  INPUT parparentproc
                     ,output v-upper-prop-code
                     ,output v-upper-node-code
                     ,OUTPUT v-upper-prop-label
                     ,OUTPUT v-full-prop-name
                     ,OUTPUT v-prop-code
                     ,output v-node-code
                     ,OUTPUT v-prop-label
                     ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN undo, RETURN ERROR.
if v-prop-code = '':u then return.
FIND FIRST buf_tt-drt-prop WHERE
          buf_tt-drt-prop.full-prop-name = v-full-prop-name NO-ERROR.
IF AVAILABLE buf_tt-drt-prop THEN DO:
   MESSAGE
  "Уже есть такой параметр в такой секции" SKIP
   v-full-prop-name
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
ASSIGN
v-UPPER-full-prop-name = v-full-prop-name
.
ASSIGN
v-upper-full-prop-name = RIGHT-TRIM(v-upper-full-prop-name, {&slash-char})
.
ENTRY(NUM-ENTRIES(v-upper-full-prop-name, {&slash-char}), v-upper-full-prop-name, {&slash-char}) = '':U.

FIND FIRST buf_tt-drt-prop WHERE
          buf_tt-drt-prop.full-prop-name = v-upper-full-prop-name NO-ERROR.
IF NOT AVAILABLE buf_tt-drt-prop THEN DO:
   MESSAGE
  "Нет секции с полным именем ="
   v-upper-full-prop-name
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
CREATE buf_tt-drt-prop.
ASSIGN
buf_tt-drt-prop.prop-code       = v-prop-code
buf_tt-drt-prop.node-code       = v-node-code
buf_tt-drt-prop.upper-prop-code = v-upper-prop-code
buf_tt-drt-prop.upper-node-code = v-upper-node-code
buf_tt-drt-prop.property-value  = v-property-value
buf_tt-drt-prop.full-prop-name  = v-full-prop-name
buf_tt-drt-prop.templ-rl-root   = p-templ-rl-root
p-node-code                     = v-node-code
.
release buf_tt-drt-prop.
RUN openbr IN THIS-PROCEDURE .
find first buf_tt-drt-prop no-lock
  where buf_tt-drt-prop.templ-rl-root = p-templ-rl-root
    and buf_tt-drt-prop.node-code     = v-node-code
no-error .
if available buf_tt-drt-prop  then do:
  REPOSITION  br-drt-prop TO RECID RECID(buf_tt-drt-prop) NO-ERROR.
end.
APPLY "ENTRY" TO BROWSE br-drt-prop.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
v-value = tt-drt-prop.property-value.
      run gbl/d-character.w (
             input ? /*callback*/
            ,input (
            'title=':u + substitute("Изменение свойства &1", tt-drt-prop.prop-code) + '\':u
          + 'text1=':u + tt-drt-prop.prop-code + '\':u
          + 'format=' + "X(90)" + '\':u
          + 'fillin_row=3\':u
          + 'fillin_col=4\':u
          + 'fillin_width=90\':u
          + 'fillin_height=1\':u
          + 'max-chars=90\':u     /*- максимальное количество символов для редактора*/
          + 'readonly=no' + '\':u)
          , input-output v-value
          , output v-ok
              ).
          if not v-ok then return error.
assign
tt-drt-prop.property-value = v-value.
br-drt-prop:REFRESH() IN FRAME {&FRAME-NAME}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE VARIABLE glog AS LOGICAL no-undo.
DEFINE BUFFER buf_tt-drt-prop FOR tt-drt-prop.
MESSAGE
SUBSTITUTE("Вы уверены, что хотите удалить свойство?")
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog  THEN RETURN ERROR.
FIND FIRST buf_tt-drt-prop WHERE
          buf_tt-drt-prop.upper-node-code = tt-drt-prop.node-code  NO-ERROR.
IF AVAILABLE buf_tt-drt-prop THEN DO:
  MESSAGE
  "Нельзя удалить свойство, к нему есть привязки"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FIND FIRST buf_tt-drt-prop WHERE
         RECID(buf_tt-drt-prop) = RECID(tt-drt-prop).
DELETE buf_tt-drt-prop.
RUN Openbr IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define buffer buf_tt-drt-prop for tt-drt-prop.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = {&LOOKUP} THEN RETURN .
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME {&FRAME-NAME}
tt-dis-time-rule.templ-rl-root
tt-dis-time-rule.des
tt-dis-time-rule.other-inf
tt-dis-time-rule.uniq-field
tt-dis-time-rule.value-type
tt-dis-time-rule.sts
f-level-1
f-level-2
.
for each buf_tt-drt-prop:
  assign
  buf_tt-drt-prop.templ-rl-root = tt-dis-time-rule.templ-rl-root
  .
end.
run utl/distrul0.p ( INPUT p-mode
                    ,INPUT NO /*p-silent*/
                    ,INPUT-output v-rec
                    ,INPUT tt-dis-time-rule.templ-rl-root
                    ,INPUT tt-dis-time-rule.des
                    ,INPUT tt-dis-time-rule.other-inf
                    ,INPUT tt-dis-time-rule.uniq-field
                    ,INPUT tt-dis-time-rule.value-type
                    ,INPUT tt-dis-time-rule.sts
                    ,input f-level-1
                    ,input f-level-2
                    ,input table tt-drt-prop
                    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  message error-status:get-message(1) view-as alert-box .
 { gbl/reterhnd.i error }
  undo, return error.
END.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
