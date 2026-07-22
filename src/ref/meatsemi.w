&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Классификатор мясных и мясосодержащих полуфабрикатов по ГОСТ Р 52675

Автор: Бахтадзе Наталья Викторовна
Дата создания: 31/07/09
Author: Bakhtadze Natalya
Creation date: 31/07/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-node-code AS INTEGER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Классификатор мясных и мясосодержащих полуфабрикатов по ГОСТ Р 52675".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF}
{ gbl/color.i }
{ ref/meatsemi.i meat-semi-finished ds }
{ ref/meatsemi.i dop-msf }
{ ref/meatsemi.i " " proc }

DEFINE VARIABLE v-max-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
define variable v-edit-mode as logical no-undo .
define buffer buf_clob-bind for ub.clob-bind.
&scoped-define view-dop-msf ~
DISPLAY ~
dop-msf.node-code AT ROW 16 COL 5 COLON-ALIGN  ~
dop-msf.group-name AT ROW 16 COL 17 COLON-ALIGN ~
dop-msf.kind-name AT ROW 16 COL 54 COLON-ALIGN SKIP ~
dop-msf.subkind-name-1 AT ROW 17 COL 17 COLON-ALIGN ~
dop-msf.subkind-name-2 AT ROW 17 COL 54 COLON-ALIGN SKIP ~
dop-msf.subkind-name-3 AT ROW 18 COL 17 colon-align ~
dop-msf.subkind-name-4 AT ROW 18 COL 54 COLON-ALIGN SKIP ~
dop-msf.subkind-name-5 AT ROW 19 COL 17 colon-align ~
dop-msf.subkind-name-6 AT ROW 19 COL 54 COLON-ALIGN SKIP  ~
dop-msf.category-name AT ROW 20 COL 17 COLON-ALIGN ~
dop-msf.termic-condition-name AT ROW 20 COL 54 COLON-ALIGN ~
with FRAME ~{&FRAME-NAME~}



&SCOPED-DEFINE hide-dop-msf ~
disable ~
dop-msf.node-code ~
dop-msf.group-name ~
dop-msf.kind-name ~
dop-msf.subkind-name-1  ~
dop-msf.subkind-name-2  ~
dop-msf.subkind-name-3  ~
dop-msf.subkind-name-4  ~
dop-msf.subkind-name-5  ~
dop-msf.subkind-name-6  ~
dop-msf.category-name   ~
dop-msf.termic-condition-name ~
with FRAME {&FRAME-NAME}. ~
hide ~
dop-msf.node-code ~
in FRAME {&FRAME-NAME} ~
dop-msf.group-name ~
dop-msf.kind-name ~
dop-msf.subkind-name-1  ~
dop-msf.subkind-name-2  ~
dop-msf.subkind-name-3  ~
dop-msf.subkind-name-4  ~
dop-msf.subkind-name-5  ~
dop-msf.subkind-name-6  ~
dop-msf.category-name   ~
dop-msf.termic-condition-name ~
in FRAME {&FRAME-NAME}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-msf

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES meat-semi-finished

/* Definitions for BROWSE BR-msf                                        */
&Scoped-define FIELDS-IN-QUERY-BR-msf mark-string(meat-semi-finished.node-code) meat-semi-finished.node-code meat-semi-finished.group-name meat-semi-finished.kind-name meat-semi-finished.subkind-name-1 meat-semi-finished.subkind-name-2 meat-semi-finished.subkind-name-3 meat-semi-finished.subkind-name-4 meat-semi-finished.subkind-name-5 meat-semi-finished.subkind-name-6 meat-semi-finished.category-name meat-semi-finished.termic-condition-name meat-semi-finished.node-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-msf
&Scoped-define SELF-NAME BR-msf
&Scoped-define QUERY-STRING-BR-msf FOR EACH meat-semi-finished NO-LOCK WHERE TRUE  BY meat-semi-finished.group-name BY meat-semi-finished.kind-name BY meat-semi-finished.subkind-name BY meat-semi-finished.category-name BY meat-semi-finished.termic-condition-name INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-msf OPEN QUERY {&SELF-NAME} FOR EACH meat-semi-finished NO-LOCK WHERE TRUE  BY meat-semi-finished.group-name BY meat-semi-finished.kind-name BY meat-semi-finished.subkind-name BY meat-semi-finished.category-name BY meat-semi-finished.termic-condition-name INDEXED-REPOSITION     .
&Scoped-define TABLES-IN-QUERY-BR-msf meat-semi-finished
&Scoped-define FIRST-TABLE-IN-QUERY-BR-msf meat-semi-finished


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-sel b-add b-del b-gds-list ~
B-Help BR-msf

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( INPUT p-current-node-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cancel
     LABEL "Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-gds-list
     LABEL "Товары"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "&Выбор"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-msf FOR
      meat-semi-finished SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-msf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-msf Dialog-Frame _FREEFORM
  QUERY BR-msf NO-LOCK DISPLAY
      mark-string(meat-semi-finished.node-code) COLUMN-LABEL "*" FORMAT "(1)"
meat-semi-finished.node-code
meat-semi-finished.group-name
meat-semi-finished.kind-name
meat-semi-finished.subkind-name-1
meat-semi-finished.subkind-name-2
meat-semi-finished.subkind-name-3
meat-semi-finished.subkind-name-4
meat-semi-finished.subkind-name-5
meat-semi-finished.subkind-name-6
meat-semi-finished.category-name
meat-semi-finished.termic-condition-name
meat-semi-finished.node-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11
     b-sel AT ROW 1 COL 25 WIDGET-ID 20
     b-add AT ROW 1 COL 45 WIDGET-ID 4
     b-del AT ROW 1 COL 55 WIDGET-ID 8
     b-gds-list AT ROW 1 COL 65 WIDGET-ID 22
     B-Help AT ROW 1 COL 95
     BR-msf AT ROW 3 COL 1 WIDGET-ID 100
     b-ok AT ROW 16 COL 78 WIDGET-ID 16
     b-cancel AT ROW 16 COL 88 WIDGET-ID 18
     SPACE(1.69) SKIP(5.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Классификатор мясных и мясосодержащих полуфабрикатов по ГОСТ P 52675"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-msf B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-cancel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-cancel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-ok IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-ok:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-msf
/* Query rebuild information for BROWSE BR-msf
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH meat-semi-finished NO-LOCK WHERE TRUE

BY meat-semi-finished.group-name
BY meat-semi-finished.kind-name
BY meat-semi-finished.subkind-name
BY meat-semi-finished.category-name
BY meat-semi-finished.termic-condition-name INDEXED-REPOSITION
    .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-msf */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Классификатор мясных и мясосодержащих полуфабрикатов по ГОСТ P 52675 */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  RUN proc-undo-record IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    enable
    b-add when v-edit-mode
    b-del when v-edit-mode
    b-gds-list
    with frame {&frame-name} .
    RETURN NO-APPLY.
  end.
  enable
  b-add when v-edit-mode
  b-del when v-edit-mode
  with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE meat-semi-finished  THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Сохранить */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  MESSAGE
  "Вы уверены, что хотите сохранить классификатор в таком виде в БД?" SKIP
  "УДАЛЕНИЕ ДОБАВЛЕННЫХ ЗАПИСЕЙ (если Вы их добавляли) ПОСЛЕ ЭТОГО СТАНЕТ НЕВОЗМОЖНЫМ!"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  if not glog then return no-apply.
  RUN proc-save-all IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-list Dialog-Frame
ON CHOOSE OF b-gds-list IN FRAME Dialog-Frame /* Товары */
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 IF NOT AVAILABLE meat-semi-finished THEN RETURN NO-APPLY.
 if meat-semi-finished.node-code >  v-max-node-code then do:
   message
   "Нельзя просмотреть товары по данному коду классификатора" skip
   "Он еще не был сохранен в БД"

   view-as alert-box error .
   undo, return no-apply.
 end.

 run ref/gds-msfs.w ( INPUT parparentproc
                      ,INPUT (if b-add:sensitive in frame {&frame-name}  = yes
                              and v-cntxt-db-num = 0
                              and not transaction
                              and meat-semi-finished.node-code <= v-max-node-code
                              then 'b-add' else '') /*bttns*/
                      ,INPUT "node-code" /*p-list-mode*/
                      ,INPUT meat-semi-finished.node-code
                      ,input '' /*p-uniq-key-reec*/
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save-record IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    enable
    b-add when v-edit-mode
    b-del when v-edit-mode
    with frame {&frame-name} .
    RETURN NO-APPLY.
  end.
  enable
  b-add when v-edit-mode
  b-del when v-edit-mode
  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  IF AVAILABLE meat-semi-finished THEN DO:
      ASSIGN
      p-node-code = meat-semi-finished.node-code.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-msf
&Scoped-define SELF-NAME BR-msf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-msf Dialog-Frame
ON VALUE-CHANGED OF BR-msf IN FRAME Dialog-Frame
DO:
  if b-ok:visible in frame {&frame-name}
  or b-cancel:visible in frame {&frame-name}  then do:
    return no-apply.
  end.
  IF AVAILABLE meat-semi-finished THEN do:
    ASSIGN
    dop-msf.node-code =  meat-semi-finished.node-code
    dop-msf.group-name =  meat-semi-finished.group-name
    dop-msf.kind-name  =  meat-semi-finished.kind-name
    dop-msf.subkind-name-1 = meat-semi-finished.subkind-name-1
    dop-msf.subkind-name-2 = meat-semi-finished.subkind-name-2
    dop-msf.subkind-name-3 = meat-semi-finished.subkind-name-3
    dop-msf.subkind-name-4  = meat-semi-finished.subkind-name-4
    dop-msf.subkind-name-5 = meat-semi-finished.subkind-name-5
    dop-msf.subkind-name-6 = meat-semi-finished.subkind-name-6
    dop-msf.category-name = meat-semi-finished.category-name
    dop-msf.termic-condition-name = meat-semi-finished.termic-condition-name
    .
    {&view-dop-msf}.
  END.
  ELSE DO:
    {&hide-dop-msf}.
  END.
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

on value-changed of dop-msf.kind-name in frame {&frame-name} do:

  if dop-msf.kind-name:screen-value in frame {&frame-name}  <> "кусковые" then do:
    dop-msf.subkind-name-1:screen-value in frame {&frame-name}  = "-".
    dop-msf.subkind-name-2:screen-value in frame {&frame-name}  = "-".

  end.
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i GET }
  IF LOOKUP(p-mode, {&UPDATE} + {&comma-char} + {&LOOKUP}) = 0  THEN DO:
    MESSAGE
    substitute("Неверное значение параметрf p-mode = &1"
    , p-mode)
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  END.
  IF p-mode = {&UPDATE}
  AND LOOKUP("b-sel", bttns) > 0   THEN DO:
    MESSAGE
    substitute("Неверное значение параметров bttns = &1 и/или p-mode = &2"
               , bttns
               , p-mode)
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  END.
  if p-mode = {&update}
  and v-cntxt-db-num > 0 then do:
    MESSAGE
    substitute("Нельзя редактировать классификатор в УБД")
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  end.
  v-node-code = p-node-code.
  RUN fill-tables in THIS-PROCEDURE.
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
  ENABLE B-exit b-quit b-sel b-add b-del b-gds-list B-Help BR-msf
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
run meatsemi_fill-msf in this-procedure ( input p-mode
                                        , buffer buf_clob-bind).

CREATE dop-msf.
RELEASE dop-msf.
FIND LAST meat-semi-finished NO-ERROR.
IF AVAILABLE meat-semi-finished THEN DO:
   ASSIGN
   v-max-node-code = meat-semi-finished.node-code.
END.
ELSE DO:
    ASSIGN
    v-max-node-code = 0.

END.
release meat-semi-finished NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
if (lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION AND p-mode = {&UPDATE}) then do:
  v-edit-mode = yes.
end.
FIND FIRST dop-msf.
enable
br-msf
b-add WHEN v-edit-mode
b-del WHEN v-edit-mode
b-sel WHEN (lookup("b-sel", bttns) > 0)
b-help
b-exit WHEN v-edit-mode
b-quit
b-gds-list
WITH FRAME {&FRAME-NAME}
.
IF p-mode <> {&UPDATE} THEN DO:
  HIDE
  b-exit
  IN FRAME {&FRAME-NAME}.
  b-quit:COLUMN  = 1.
  b-quit:label in frame {&frame-name} = "&Выход".

END.
{&OPEN-QUERY-{&BROWSE-NAME}}
APPLY "value-changed" TO BROWSE br-msf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE BUFFER buf_msf FOR meat-semi-finished.
FIND LAST buf_msf NO-ERROR.
IF AVAILABLE buf_msf  THEN DO:
    ASSIGN
   v-node-code = buf_msf.node-code + 1.
END.
ELSE DO:
   v-node-code = 1.
END.
DISPLAY
b-ok
b-cancel
WITH FRAME {&FRAME-NAME}.
ENABLE
b-ok
b-cancel
WITH FRAME {&FRAME-NAME}.
disable
b-add
b-del
b-gds-list
with frame {&frame-name} .
do transaction:
  delete dop-msf.
  CREATE dop-msf.
  ASSIGN
  dop-msf.node-code = v-node-code
  .
end.
DISPLAY
dop-msf.node-code
dop-msf.group-name
dop-msf.kind-name SKIP
dop-msf.subkind-name-1
dop-msf.subkind-name-2 SKIP
dop-msf.subkind-name-3
dop-msf.subkind-name-4 SKIP
dop-msf.subkind-name-5
dop-msf.subkind-name-6 SKIP
dop-msf.category-name
dop-msf.termic-condition-name
WITH FRAME {&FRAME-NAME}
.
enable
dop-msf.group-name
dop-msf.kind-name
dop-msf.subkind-name-1
dop-msf.subkind-name-2
dop-msf.subkind-name-3
dop-msf.subkind-name-4
dop-msf.subkind-name-5
dop-msf.subkind-name-6
dop-msf.category-name
dop-msf.termic-condition-name
WITH FRAME {&FRAME-NAME}
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE BUFFER buf_msf FOR meat-semi-finished.
IF meat-semi-finished.node-code <= v-max-node-code  THEN DO:
  MESSAGE
  "К сожалению, удалить эту запись уже невозможно!!!" SKIP
  "Она сохранена в БД"
   VIEW-AS ALERT-BOX.
   undo, return error .
END.
FIND FIRST buf_msf WHERE RECID(buf_msf) = RECID(meat-semi-finished) NO-ERROR.
DELETE buf_msf .
{&OPEN-QUERY-{&BROWSE-NAME}}
APPLY "value-changed" TO BROWSE br-msf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-all Dialog-Frame
PROCEDURE proc-save-all :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable v-part-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-clob-mode as character no-undo .
define variable v-clob-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .

DEFINE BUFFER buf_meat-semi-finished FOR meat-semi-finished.
FOR EACH buf_meat-semi-finished WHERE buf_meat-semi-finished.node-code < 0:
    DELETE buf_meat-semi-finished.
END.
find last buf_meat-semi-finished no-error.
if (available buf_meat-semi-finished
and buf_meat-semi-finished.node-code = v-max-node-code )
or (not available buf_meat-semi-finished
and v-max-node-code  = 0)
then do:
  message
  "Классификатор не изменился" skip
  "сохранение не требуется"
  view-as alert-box warning
  .
  return.
end.
run gbl/_tmpfile.p ( input ""
                    ,input "xml"
                    ,output v-file-name) .
output to value(v-file-name).
put 1 skip.
output close.
run gbl/filename.p (
               input v-file-name
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  undo, return error .
end.
glog = DATASET meat-semi-finished-ds:HANDLE:write-XML("FILE"
                                           , v-full-path
                                            , YES /*lformatted*/
                                            , "windows-1251"
                                            , ?
                                            , YES /*write-xml-schema*/
                                             ,NO /*min-schema*/ ) NO-ERROR.

if error-status:error or not glog then do:
  os-delete value(v-full-path) no-error.
  MESSAGE
  ERROR-STATUS:GET-MESSAGE(1) SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
end.
assign
v-part-num = 1.
if not available buf_clob-bind then do:
  v-mode = {&add-def}.
  v-clob-mode = "".
  v-clob-db-num = ?.
  v-int64-id = 0.
end.
else do:
  v-mode = {&update}.
  v-clob-mode = "add-new".
  v-clob-db-num = buf_clob-bind.db-num.
  v-int64-id = buf_clob-bind.int64-id.
end.
run gbl/file2clb.p ( input v-mode
                    ,input v-clob-mode
                    ,input ? /*p-bh*/
                    ,input "meat-semi-finished.xml" /*p-uniq-key-rec*/
                    ,input '' /*p-field-*/
                    ,input frame {&frame-name}:title /*p-descr*/
                    ,input-output v-part-num
                    ,input {&lob-res-ref}
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input v-full-path
                    ,input ? /*p-src-encoding*/
                    ) no-error .
IF ERROR-STATUS:ERROR THEN DO:
  os-delete value(v-full-path) no-error.
  MESSAGE
  ERROR-STATUS:GET-MESSAGE(1) SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
os-delete value(v-full-path) no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-record Dialog-Frame
PROCEDURE proc-save-record :
define variable v-rec as recid no-undo .
DEFINE BUFFER buf_msf FOR meat-semi-finished.
ASSIGN
FRAME {&FRAME-NAME}
dop-msf.group-name
dop-msf.kind-name
dop-msf.subkind-name-1
dop-msf.subkind-name-2
dop-msf.subkind-name-3
dop-msf.subkind-name-4
dop-msf.subkind-name-5
dop-msf.subkind-name-6
dop-msf.category-name
dop-msf.termic-condition-name
.
FIND FIRST buf_msf  WHERE
    buf_msf.node-code = dop-msf.node-code NO-ERROR.
IF AVAILABLE buf_msf THEN DO:
    ASSIGN
    dop-msf.node-code = 0
    .
    MESSAGE
    substitute("Уже есть запись с таким вн. кодом &1", dop-msf.node-code)
    VIEW-AS ALERT-BOX ERROR.
    RUN proc-undo-record IN this-procedure.
   RETURN.
END.
FIND FIRST buf_msf  WHERE
        buf_msf.group-name = dop-msf.group-name
    AND buf_msf.kind-name = dop-msf.kind-name
    AND buf_msf.subkind-name-1 = dop-msf.subkind-name-1
    AND buf_msf.subkind-name-2 = dop-msf.subkind-name-2
    AND buf_msf.subkind-name-3 = dop-msf.subkind-name-3
    AND buf_msf.subkind-name-4 = dop-msf.subkind-name-4
    AND buf_msf.subkind-name-5 = dop-msf.subkind-name-5
    AND buf_msf.subkind-name-6 = dop-msf.subkind-name-6
    AND buf_msf.category-name = dop-msf.category-name
    AND buf_msf.termic-condition = dop-msf.termic-condition
    NO-ERROR.
IF AVAILABLE buf_msf THEN DO:
  MESSAGE
  substitute("Уже есть запись с такими характеристиками")
  VIEW-AS ALERT-BOX ERROR.
  return.
END.
if dop-msf.group-name = ''
or dop-msf.group-name = ? then do:
  MESSAGE
  substitute("Не задана Группа")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.kind-name = ''
or dop-msf.kind-name = ? then do:
  MESSAGE
  substitute("Не задан Вид")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.subkind-name-1 = ''
or dop-msf.subkind-name-1 = ? then do:
  MESSAGE
  substitute("Не задан подвид (Кости-мясо)")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.subkind-name-2 = ''
or dop-msf.subkind-name-2 = ? then do:
  MESSAGE
  substitute("Не задан подвид (Дискретность)")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.subkind-name-3 = ''
or dop-msf.subkind-name-3 = ? then do:
  MESSAGE
  substitute("Не задан подвид (Фаршировка)")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.subkind-name-4 = ''
or dop-msf.subkind-name-4 = ? then do:
  MESSAGE
  substitute("Не задан подвид (Формовка)")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.subkind-name-5 = ''
or dop-msf.subkind-name-5 = ? then do:
  MESSAGE
  substitute("Не задан подвид (Панировка)")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.subkind-name-6 = ''
or dop-msf.subkind-name-6 = ? then do:
  MESSAGE
  substitute("Не задан подвид (Фасовка)")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.category-name = ''
or dop-msf.category-name = ? then do:
  MESSAGE
  substitute("Не задана Категория")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
if dop-msf.termic-condition-name = ''
or dop-msf.termic-condition-name = ? then do:
  MESSAGE
  substitute("Не задано Термическое состояние")
  VIEW-AS ALERT-BOX ERROR.
  return.
end.
IF dop-msf.group-name = "мясосодержащие"
AND (dop-msf.category = "категория А"
     OR
     dop-msf.category = "категория Б")
     THEN DO:
    MESSAGE
    "Не бывает мясосодержащих полуфабрикатов такой категории!"
    VIEW-AS ALERT-BOX ERROR.
    return.
END.
IF dop-msf.kind-name <> "кусковые"
AND dop-msf.subkind-name-1 <> "-" THEN DO:
    MESSAGE
    SUBSTITUTE("Для полуфабрикатов такой группы нельзя задать свойство Кости-мясо = &1!", dop-msf.subkind-name-1)
    VIEW-AS ALERT-BOX ERROR.
    return.
END.
DO TRANSACTION
ON error UNDO, RETURN ERROR :
    CREATE buf_msf.
    BUFFER-COPY dop-msf TO buf_msf
    assign
    buf_msf.subkind-name =
    buf_msf.subkind-name-1 + {&comma-char} +
    buf_msf.subkind-name-2 + {&comma-char} +
    buf_msf.subkind-name-3 + {&comma-char} +
    buf_msf.subkind-name-4 + {&comma-char} +
    buf_msf.subkind-name-5 + {&comma-char} +
    buf_msf.subkind-name-6
    buf_msf.lvl-num = 5
    .
    DELETE dop-msf.
    CREATE dop-msf.
    FIND FIRST dop-msf.
    v-rec = RECID(buf_msf).
    RELEASE buf_msf.
END.
{&hide-dop-msf}.
HIDE b-ok b-cancel IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-{&BROWSE-NAME}}
REPOSITION br-msf TO RECID v-rec.
APPLY "value-changed" TO br-msf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-undo-record Dialog-Frame
PROCEDURE proc-undo-record :
delete dop-msf.
create dop-msf.
RELEASE dop-msf.
FIND FIRST dop-msf.
{&hide-dop-msf}.
HIDE b-ok b-cancel IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" TO br-msf IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( INPUT p-current-node-code AS INTEGER ) :
 RETURN ( IF p-current-node-code = v-node-code THEN '*' ELSE '':U ).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME