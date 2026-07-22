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

Показать признаки шкалы

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/15/03


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-root-node as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Показать признаки шкалы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */

define variable v-upper-code as integer   no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-level

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.lvl-name ub.gds-prt

/* Definitions for BROWSE BROWSE-level                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-level ub.lvl-name.lvl-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-level
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-level
&Scoped-define SELF-NAME BROWSE-level
&Scoped-define OPEN-QUERY-BROWSE-level OPEN QUERY {&SELF-NAME} FOR EACH ub.lvl-name no-lock where ub.lvl-name.upper-code = v-upper-code by ub.lvl-name.level .
&Scoped-define TABLES-IN-QUERY-BROWSE-level ub.lvl-name
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-level ub.lvl-name


/* Definitions for BROWSE BROWSE-prt                                    */
&Scoped-define FIELDS-IN-QUERY-BROWSE-prt node-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-prt
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-prt
&Scoped-define SELF-NAME BROWSE-prt
&Scoped-define OPEN-QUERY-BROWSE-prt /* OPEN QUERY {&SELF-NAME} FOR EACH gds-prt . */ run open-query-gds-prt in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-prt gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-prt gds-prt


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-level}~
    ~{&OPEN-QUERY-BROWSE-prt}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help BROWSE-level BROWSE-prt ~
fi-scale-name
&Scoped-Define DISPLAYED-OBJECTS fi-scale-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-scale-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название шкалы"
      VIEW-AS TEXT
     SIZE 68.5 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-level FOR
      ub.lvl-name SCROLLING.

DEFINE QUERY BROWSE-prt FOR
      ub.gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-level Dialog-Frame _FREEFORM
  QUERY BROWSE-level DISPLAY
      ub.lvl-name.lvl-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 21.75 BY 11.92.

DEFINE BROWSE BROWSE-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-prt Dialog-Frame _FREEFORM
  QUERY BROWSE-prt DISPLAY
      node-name format "x(16)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 30 BY 11.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     BROWSE-level AT ROW 4 COL 9.13
     BROWSE-prt AT ROW 4 COL 41.75
     fi-scale-name AT ROW 2.38 COL 16 COLON-ALIGNED
     SPACE(2.74) SKIP(14.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр шкалы"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
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
OPEN QUERY {&SELF-NAME} FOR EACH ub.lvl-name no-lock where ub.lvl-name.upper-code = v-upper-code
by ub.lvl-name.level .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-level */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-prt
/* Query rebuild information for BROWSE BROWSE-prt
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH gds-prt . */ run open-query-gds-prt in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-prt */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр шкалы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-level
&Scoped-define SELF-NAME BROWSE-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-level Dialog-Frame
ON VALUE-CHANGED OF BROWSE-level IN FRAME Dialog-Frame
DO:
  run open-query-gds-prt in this-procedure .
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


define buffer buf_gds-prt for ub.gds-prt .
find first buf_gds-prt no-lock
  where buf_gds-prt.node-code = p-root-node
  .
assign
  v-upper-code  = buf_gds-prt.upper-code
  fi-scale-name = buf_gds-prt.node-name
.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY fi-scale-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help BROWSE-level BROWSE-prt fi-scale-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-gds-prt Dialog-Frame
PROCEDURE open-query-gds-prt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if available ub.lvl-name
  then do:

    define buffer buf_gds-prt for ub.gds-prt .
    define variable v-node-code as integer   no-undo .

    assign
      v-node-code = p-root-node
    .
    define variable v-ind as integer   no-undo .
    do v-ind = 1 to ub.lvl-name.level
    :
      find first buf_gds-prt no-lock
        where buf_gds-prt.upper-code = v-node-code
        .
      assign
        v-node-code = buf_gds-prt.node-code
      .
    end.

    OPEN QUERY browse-prt FOR EACH ub.gds-prt no-lock
      where gds-prt.upper-code = v-node-code
      by gds-prt.prt-num .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
