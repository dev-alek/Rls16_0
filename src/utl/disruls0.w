&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список шаблонов правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/06
Author: Bakhtadze Natalya
Creation date: 12/10/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns as character no-undo .
define input-output parameter p-rid-list as character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ШАБЛОНЫ СКИДОК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }
{ gbl/getcntxt.i DEF }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/disrules.i }
define variable glog as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-templ-rl-root as integer no-undo .
DEFINE BUFFER buf_file FOR dictdb._file.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-rule

/* Definitions for BROWSE br-dis-rule                                   */
&Scoped-define FIELDS-IN-QUERY-br-dis-rule X_dis-rule.templ-rl-root X_dis-rule.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-rule
&Scoped-define SELF-NAME br-dis-rule
&Scoped-define QUERY-STRING-br-dis-rule FOR EACH X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num < {&max-num-dr-template}
&Scoped-define OPEN-QUERY-br-dis-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num < {&max-num-dr-template}.
&Scoped-define TABLES-IN-QUERY-br-dis-rule X_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-rule X_dis-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-copy b-chg b-del ~
b-lkp B-Help br-dis-rule mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD rule-name Dialog-Frame
FUNCTION rule-name RETURNS CHARACTER
  ( INPUT p-subject AS character, input p-discnt-role AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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

DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-rule FOR
      X_dis-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-rule Dialog-Frame _FREEFORM
  QUERY br-dis-rule NO-LOCK DISPLAY
      X_dis-rule.templ-rl-root FORMAT ">>>>>>>>9":U COLUMN-LABEL "Код!шаблона"
X_dis-rule.des FORMAT "X(255)":U WIDTH 85
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 21 WIDGET-ID 32
     b-sel AT ROW 1 COL 25 WIDGET-ID 34
     b-add AT ROW 1 COL 35 WIDGET-ID 2
     b-copy AT ROW 1 COL 45 WIDGET-ID 30
     b-chg AT ROW 1 COL 55 WIDGET-ID 4
     b-del AT ROW 1 COL 65 WIDGET-ID 6
     b-lkp AT ROW 1 COL 75 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     br-dis-rule AT ROW 3 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(21.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ШАБЛОНЫ СКИДОК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_dis-rule B "?" ? ub dis-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-rule B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-rule
/* Query rebuild information for BROWSE br-dis-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num < {&max-num-dr-template}.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-dis-rule */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* ШАБЛОНЫ СКИДОК */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* ШАБЛОНЫ СКИДОК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable v-rec as recid no-undo .
  run utl/disruli0.w ( input parparentproc
                      ,INPUT {&add-def}
                      ,INPUT 0 /*templ-rl-root*/
                      ,output v-rec
                      ) no-error .

  RUN openbr IN THIS-PROCEDURE  NO-ERROR.
  reposition br-dis-rule to recid(v-rec) no-error .
  APPLY "ENTRY" to br-dis-rule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-rec   as recid no-undo .
define variable v-rec2  as recid no-undo .

v-rec = recid(X_dis-rule).
  if not available X_dis-rule then return no-apply.
  run utl/disruli0.w ( input parparentproc
                      ,INPUT {&update}
                      ,INPUT X_dis-rule.templ-rl-root
                      ,output v-rec2
                      ) no-error .

  RUN openbr IN THIS-PROCEDURE  NO-ERROR.
  reposition br-dis-rule to recid(v-rec) no-error .
  APPLY "ENTRY" to br-dis-rule.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
define variable v-rec as recid no-undo .
IF NOT AVAILABLE X_dis-rule THEN RETURN NO-APPLY.
  run utl/disruli0.w ( input parparentproc
                      ,INPUT {&add-copy}
                       ,INPUT X_dis-rule.templ-rl-root
                       ,output v-rec
                      ) no-error .

  RUN openbr IN THIS-PROCEDURE  NO-ERROR.
  reposition br-dis-rule to recid(v-rec) no-error .
  APPLY "ENTRY" to br-dis-rule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  message "b-del" VIEW-AS ALERT-BOX.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
 define variable v-rec as recid no-undo .
  if not available X_dis-rule then return no-apply.
  run utl/disruli0.w ( input parparentproc
                      ,INPUT {&lookup}
                      ,INPUT X_dis-rule.templ-rl-root
                      ,output v-rec
                      ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_dis-rule then do:
 { gbl/markstrn.i X_dis-rule v-rid-list }
  glog = br-dis-rule:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-dis-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-rule in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_dis-rule then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_dis-rule ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-rule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }


&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  RUN Myenable IN THIS-PROCEDURE .
  run openbr in this-procedure .
  APPLY "ENTRY" to br-dis-rule.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-copy b-chg b-del b-lkp B-Help br-dis-rule
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
ch = br-dis-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO ii = 1 TO br-dis-rule:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    ASSIGN
    ch:RESIZABLE = YES.
    ch = ch:NEXT-COLUMN.
END.
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-add WHEn (v-cntxt-db-num = 0)
B-copy WHEn (v-cntxt-db-num = 0)
B-chg WHEn (v-cntxt-db-num = 0)
B-del WHEn (v-cntxt-db-num = 0)
B-mark WHEn LOOKUP("b-mark", bttns) > 0
B-sel WHEN LOOKUP("b-sel", bttns) > 0
B-Help
b-lkp
br-dis-rule
mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
HIDE
mark-num
IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
OPEN QUERY br-dis-rule
FOR EACH X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num <= {&max-num-dr-template} INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION rule-name Dialog-Frame
FUNCTION rule-name RETURNS CHARACTER
  ( INPUT p-subject AS character, input p-discnt-role AS character ) :
DEFINE VARIABLE v-rule-name AS CHARACTER NO-UNDO.
&SCOPED-DEFINE dis-gds-rule-code p-discnt-role
&SCOPED-DEFINE dis-thbj-rule-code p-discnt-role
&SCOPED-DEFINE dis-cp-rule-code p-discnt-role
&SCOPED-DEFINE dis-dc-rule-code p-discnt-role
&SCOPED-DEFINE dis-dct-rule-code p-discnt-role
&SCOPED-DEFINE dis-ggr-rule-code p-discnt-role

CASE p-subject :
  WHEN {&TABLE_dis-gds-rule} THEN DO:
    v-rule-name = {&dis-gds-rule-name}.
  END.
  WHEN {&TABLE_dis-thbj-rule} THEN DO:
    v-rule-name = {&dis-thbj-rule-name}.
  END.
  WHEN {&TABLE_dis-cp-rule} THEN DO:
    v-rule-name = {&dis-cp-rule-name}.
  END.
  WHEN {&TABLE_dis-dc-rule} THEN DO:
    v-rule-name = {&dis-dc-rule-name}.
  END.
  WHEN {&TABLE_dis-dct-rule} THEN DO:
    v-rule-name = {&dis-dct-rule-name}.
  END.
  WHEN {&TABLE_dis-grp-rule} THEN DO:
    v-rule-name = {&dis-ggr-rule-name}.
  END.
END CASE.
RETURN v-RULE-name.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
