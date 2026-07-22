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

Список объектов для межфирменного перемещени

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 07/04/03


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parhost-code like ub.clients.obj-code no-undo.
define input parameter pardefobj-type like ub.clients.obj-type no-undo.
define input parameter pardefobj-code like ub.clients.obj-code no-undo.
define output parameter parobj-type like ub.clients.obj-type no-undo.
define output parameter parobj-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define temp-table tt-shst no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field obj-name like ub.clients.obj-name
index pi is unique primary obj-type obj-code.
define buffer bf_tt-shst for tt-shst.
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-shst

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-shst

/* Definitions for BROWSE b-shst                                        */
&Scoped-define FIELDS-IN-QUERY-b-shst tt-shst.obj-code tt-shst.obj-type tt-shst.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-shst
&Scoped-define FIELD-PAIRS-IN-QUERY-b-shst
&Scoped-define SELF-NAME b-shst
&Scoped-define OPEN-QUERY-b-shst OPEN QUERY {&SELF-NAME} FOR EACH tt-shst indexed-reposition.
&Scoped-define TABLES-IN-QUERY-b-shst tt-shst
&Scoped-define FIRST-TABLE-IN-QUERY-b-shst tt-shst


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-shst}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-chs b-cancel b-help b-shst

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chs AUTO-GO
     LABEL "&Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-shst FOR
      tt-shst SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-shst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-shst Dialog-Frame _FREEFORM
  QUERY b-shst DISPLAY
      tt-shst.obj-code
tt-shst.obj-type
tt-shst.obj-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 46.13 BY 9.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-chs AT ROW 1.08 COL 1.63
     b-cancel AT ROW 1.08 COL 12.13
     b-help AT ROW 1.08 COL 22.63
     b-shst AT ROW 2.29 COL 1.38
     SPACE(0.23) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор объекта"
         DEFAULT-BUTTON b-chs CANCEL-BUTTON b-cancel.


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
/* BROWSE-TAB b-shst b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-shst
/* Query rebuild information for BROWSE b-shst
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-shst indexed-reposition.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-shst */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор объекта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chs Dialog-Frame
ON CHOOSE OF b-chs IN FRAME Dialog-Frame /* Выбор */
DO:
  if available tt-shst then do:
    assign
      parobj-type = tt-shst.obj-type
      parobj-code = tt-shst.obj-code.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
DO: /* Call Help Function (or a simple message). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-shst
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
  run load-tt.
  RUN enable_UI.
  find first bf_tt-shst where bf_tt-shst.obj-type = pardefobj-type and
                              bf_tt-shst.obj-code = pardefobj-code no-error.
  if available bf_tt-shst then do:
    reposition b-shst to recid recid(bf_tt-shst).
  end.
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
  ENABLE b-chs b-cancel b-help b-shst
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-tt Dialog-Frame
PROCEDURE load-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if parhost-code = ? then do:
 for each shop no-lock,
   first clients where clients.obj-type = {&shop}       and
                       clients.obj-code = shop.obj-code and
                       clients.stts     = 0
                       no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.obj-type = {&shop}
     tt-shst.obj-code =  shop.obj-code
     tt-shst.obj-name = clients.obj-name.
 end.
 for each store no-lock,
   first clients where clients.obj-type = {&stock}       and
                       clients.obj-code = store.obj-code and
                       clients.stts     = 0              no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.obj-type = {&stock}
     tt-shst.obj-code =  store.obj-code
     tt-shst.obj-name = clients.obj-name.
 end.
end.
else do:
 for each shop where shop.host-code = parhost-code no-lock,
   first clients where clients.obj-type = {&shop}       and
                       clients.obj-code = shop.obj-code and
                       clients.stts     = 0             no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.obj-type = {&shop}
     tt-shst.obj-code =  shop.obj-code
     tt-shst.obj-name = clients.obj-name.
 end.
 for each store where store.host-code = parhost-code no-lock,
   first clients where clients.obj-type = {&stock}       and
                       clients.obj-code = store.obj-code and
                       clients.stts     = 0              no-lock on error undo, return error return-value :
   create tt-shst.
   assign
     tt-shst.obj-type = {&stock}
     tt-shst.obj-code = store.obj-code
     tt-shst.obj-name = clients.obj-name.
 end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

