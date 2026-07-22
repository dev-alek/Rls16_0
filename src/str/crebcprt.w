&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Создать бар-код для товара с признаками

Автор: Перваков Михаил Сергеевич
Дата создания: 11/14/03
Author: Mikhail Pervakov
Creation date: 11/14/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-message-on    as logical   no-undo .
define output parameter p-create-b-code as integer   no-undo .
define output parameter p-is-new        as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создать бар-код для товара с признаками".
{ cmp/vssrevis.i "substitute('&1':u,p-gds-code)" }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */
define variable v-upper-code        as integer   no-undo .
define variable v-root-node         as integer   no-undo .

define temp-table temp-prt no-undo
  field prt-level as integer
  field prt-name  as character format "x(16)" label "Уровень"
  field prt-value as character format "x(16)" label "Признак"
  index xpk is primary unique  prt-level
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-level

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-prt gds-prt

/* Definitions for BROWSE BROWSE-level                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-level prt-name prt-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-level
&Scoped-define SELF-NAME BROWSE-level
&Scoped-define QUERY-STRING-BROWSE-level FOR EACH temp-prt
&Scoped-define OPEN-QUERY-BROWSE-level OPEN QUERY {&SELF-NAME} FOR EACH temp-prt .
&Scoped-define TABLES-IN-QUERY-BROWSE-level temp-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-level temp-prt


/* Definitions for BROWSE BROWSE-prt                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-prt node-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-prt
&Scoped-define SELF-NAME BROWSE-prt
&Scoped-define OPEN-QUERY-BROWSE-prt /* OPEN QUERY {&SELF-NAME} FOR EACH gds-prt NO-LOCK. */ run open-query-prt in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-prt gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-prt gds-prt


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-level}~
    ~{&OPEN-QUERY-BROWSE-prt}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help BROWSE-level BROWSE-prt ~
fi-goods fi-scale
&Scoped-Define DISPLAYED-OBJECTS fi-goods fi-scale

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-goods AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 53 BY .67 NO-UNDO.

DEFINE VARIABLE fi-scale AS CHARACTER FORMAT "X(256)":U
     LABEL "Шкала"
      VIEW-AS TEXT
     SIZE 53.13 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-level FOR
      temp-prt SCROLLING.

DEFINE QUERY BROWSE-prt FOR
      gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-level Dialog-Frame _FREEFORM
  QUERY BROWSE-level DISPLAY
      prt-name
      prt-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 36.88 BY 10.08.

DEFINE BROWSE BROWSE-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-prt Dialog-Frame _FREEFORM
  QUERY BROWSE-prt DISPLAY
      node-name format "x(16)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 19.13 BY 9.96.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     BROWSE-level AT ROW 4.83 COL 4
     BROWSE-prt AT ROW 4.88 COL 42.75
     fi-goods AT ROW 2.46 COL 8.63 COLON-ALIGNED
     fi-scale AT ROW 3.58 COL 8.63 COLON-ALIGNED
     SPACE(10.86) SKIP(11.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Создать бар-код"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB BROWSE-level b-help Dialog-Frame */
/* BROWSE-TAB BROWSE-prt BROWSE-level Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-level
/* Query rebuild information for BROWSE BROWSE-level
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-prt .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-level */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-prt
/* Query rebuild information for BROWSE BROWSE-prt
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH gds-prt NO-LOCK. */
run open-query-prt in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-prt */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Создать бар-код */
DO:
  run create-bar-code in this-procedure no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Создать бар-код */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-level
&Scoped-define SELF-NAME BROWSE-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-level Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-level IN FRAME Dialog-Frame
DO:
  /* */


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-level Dialog-Frame
ON VALUE-CHANGED OF BROWSE-level IN FRAME Dialog-Frame
DO:
  run open-query-prt in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-prt
&Scoped-define SELF-NAME BROWSE-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-prt Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-prt IN FRAME Dialog-Frame
DO:
  /* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-prt Dialog-Frame
ON ENTRY OF BROWSE-prt IN FRAME Dialog-Frame
DO:
  run value-changed-prt in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-prt Dialog-Frame
ON VALUE-CHANGED OF BROWSE-prt IN FRAME Dialog-Frame
DO:
  run value-changed-prt in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-level
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/brwrepos.i
  &browse-name=browse-level
  &line-num=5
}

{ gbl/brwrepos.i
  &browse-name=browse-prt
  &line-num=5
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  define variable v-ok as logical   no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_main-barcode_preparation':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }

  if v-ok <> true
  then do:
    undo, return error return-value .
  end.

  run init-dialog in this-procedure no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове init-dialog" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  run fill-temp-table in this-procedure .

  run open-query-level in this-procedure .

  run open-query-prt in this-procedure .


  RUN enable_UI.

  apply 'entry':u to browse {&browse-name} .
  apply 'entry':u to temp-prt.prt-value in browse {&browse-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-bar-code Dialog-Frame
PROCEDURE create-bar-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    define buffer buf_temp-prt for temp-prt .
    define buffer buf_goods for ub.goods .

    define variable v-node-code as integer   no-undo .

    assign
      v-node-code = v-root-node
    .

    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      .

    for each buf_temp-prt
      by buf_temp-prt.prt-level
    :
      if buf_temp-prt.prt-value = ""
      or buf_temp-prt.prt-value = ?
      then do:
        message
          "Не задано значение признака" skip
          "Уровень" buf_temp-prt.prt-name skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define buffer buf_gds-prt for ub.gds-prt .
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = v-node-code
          and buf_gds-prt.node-name  = buf_temp-prt.prt-value
        no-error .
      if not available buf_gds-prt
      then do:
        message
          "Не найден признак" skip
          "Уровень" buf_temp-prt.prt-name skip
          "Признак" buf_temp-prt.prt-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-node-code = buf_gds-prt.node-code
      .
    end.

    define variable v-is-new as logical   no-undo .

    define buffer buf_bar-code for ub.bar-code .

    { gbl/barcodcr.i
      p-gds-code
      v-node-code
      "'':u"
      "'':u"
      buf_goods.unit-base
      1
      v-is-new
      buf_bar-code
    }

    assign
      p-create-b-code = buf_bar-code.b-code
      p-is-new        = v-is-new
    .

    if p-message-on = true
    then do:
      if v-is-new = true
      then do:
        message
          "Создан бар-код" skip
          "Бар-код" buf_bar-code.b-code skip
          view-as alert-box information .
      end.
      else do:
        message
          "Бар-код для данного признака уже существует" skip
          "Бар-код" buf_bar-code.b-code skip
          view-as alert-box information .
      end.
    end.
  end.

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
  DISPLAY fi-goods fi-scale
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help BROWSE-level BROWSE-prt fi-goods fi-scale
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-table Dialog-Frame
PROCEDURE fill-temp-table :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-prt for temp-prt .
  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_lvl-name for ub.lvl-name .

  for each buf_temp-prt
  :
    delete buf_temp-prt .
  end.

  for each buf_lvl-name no-lock
    where buf_lvl-name.upper-code = v-upper-code
  by buf_lvl-name.level
  :
    create buf_temp-prt .
    assign
      buf_temp-prt.prt-level = buf_lvl-name.level
      buf_temp-prt.prt-name  = buf_lvl-name.lvl-name
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-dialog Dialog-Frame
PROCEDURE init-dialog :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_goods for ub.goods .
  define buffer buf_gds-prt for ub.gds-prt .

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Код товара" p-gds-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/rootnode.i
    buf_goods.artic
    buf_goods.prod-type
    buf_goods.prod-code
    v-root-node
  }

  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = v-root-node
    .

  do with frame {&frame-name}:
    assign
      fi-goods = substitute('&1 &2 &3 &4'
                           ,buf_goods.artic
                           ,buf_goods.prod-type
                           ,buf_goods.prod-code
                           ,buf_goods.gds-name
                           )
    .



    assign
      v-upper-code = buf_gds-prt.upper-code
      fi-scale     = buf_gds-prt.node-name
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-level Dialog-Frame
PROCEDURE open-query-level :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-prt for temp-prt .

  define variable v-prt-level as integer   no-undo .
  if available temp-prt
  then do:
    assign
      v-prt-level = temp-prt.prt-level
    .
  end.
  else do:
    assign
      v-prt-level = ?
    .
  end.

  open query {&browse-name} for each temp-prt by temp-prt.prt-level .

  if v-prt-level <> ?
  then do:
    find first buf_temp-prt
      where buf_temp-prt.prt-level = v-prt-level
      no-error .
    if available buf_temp-prt
    then do:
      reposition {&browse-name} to rowid rowid(buf_temp-prt) no-error .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-prt Dialog-Frame
PROCEDURE open-query-prt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  if available temp-prt
  then do:
    define buffer buf_gds-prt for ub.gds-prt .
    define variable v-node-code as integer   no-undo .
    define variable v-ind as integer   no-undo .

    assign
      v-node-code = v-root-node
    .
    do v-ind = 1 to temp-prt.prt-level
    :
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = v-node-code
        .
      assign
        v-node-code = buf_gds-prt.node-code
      .
    end.

    OPEN QUERY browse-prt FOR EACH gds-prt no-lock
      where gds-prt.upper-code = v-node-code
      by gds-prt.prt-num .

    if temp-prt.prt-value <> ''
    then do:
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = v-node-code
          and buf_gds-prt.node-name  = temp-prt.prt-value
        no-error .
      if available buf_gds-prt
      then do:
        reposition browse-prt to rowid rowid(buf_gds-prt) no-error .
      end.
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE value-changed-prt Dialog-Frame
PROCEDURE value-changed-prt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  if  available temp-prt
  and available gds-prt
  then do:
    assign
      temp-prt.prt-value = gds-prt.node-name
    .
    do with frame {&frame-name}:
      display temp-prt.prt-value with browse browse-level .

    end. /* do with frame */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
