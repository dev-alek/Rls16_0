&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма ввода Грузопоотправител

Автор: Чернова Светлана Александровна
Дата создания: 05/04/12
Author: Svetlana Chernova
Creation date: 05/04/12

Создано UIB

*/
define input  parameter  ParParentProc as handle no-undo .
define input  parameter  P-Parent as handle no-undo .
define input-output parameter  p-value     as character no-undo .
define input-output parameter  p-full-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-mode as character no-undo .
define variable ref-rec   as recid no-undo .
define variable rep-rec2 as recid no-undo .
v-mode = {&update} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-clear B-Help cli-type r-cli ~
cli cli-name 
&Scoped-Define DISPLAYED-OBJECTS cli-type cli cli-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-clear 
     LABEL "&Очистить" 
     SIZE 10 BY 1 TOOLTIP "Очистить значение"
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 6 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli" 
     SIZE 3 BY 1.

DEFINE VARIABLE cli AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10.5 BY 1 NO-UNDO.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 37 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)":U 
     LABEL "Грузоотправитель" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-clear AT ROW 1 COL 21 WIDGET-ID 10
     B-Help AT ROW 1 COL 74
     cli-type AT ROW 3.75 COL 22 COLON-ALIGNED WIDGET-ID 4
     r-cli AT ROW 3.75 COL 28.5 WIDGET-ID 6
     cli AT ROW 3.75 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     cli-name AT ROW 3.92 COL 41 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(0.37) SKIP(4.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-clear Dialog-Frame
ON CHOOSE OF B-clear IN FRAME Dialog-Frame /* Очистить */
DO:
  if v-mode = {&lookup} then return.
  assign
    cli = 0
    cli-type = ""
  .
    p-value      = "" .
    p-full-name  = "" .
    cli-name     = "" .
    display  cli  cli-type cli-name  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Ввод */
DO:
define buffer buf_clients for ub.clients  .
  if v-mode = {&lookup} then return.
  assign
    cli
    cli-type
  .
   find first buf_clients no-lock where
        buf_clients.obj-code = cli and
        buf_clients.obj-type = cli-type no-error .
        if not available buf_clients and  not(
           cli = 0 and cli-type = "" )
        then do:
           message "Не верно введен Грузопоотправитель!" view-as alert-box error .
           return no-apply.
        end.

    if cli = 0 and cli-type = "" then do:
        p-value      = "" .
        p-full-name  = "" .
    end.
    else do:
      p-value      = trim(cli-type) + string(cli)  .
      p-full-name  = buf_clients.obj-name          .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ str/grzp.i cli ref-rec }
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  frame {&frame-name}:title = "Определение грузопоотправитель" .
  assign
    cli = integer(substring(p-value,4,10))
    cli-type = substring(p-value,1,3)
    no-error .
  if error-status :error then do:
      assign
        cli = 0
        cli-type = ""
        .
   end.
   else do:
    apply "LEAVE"  to cli  in frame {&frame-name} .
   end.

  RUN enable_UI.
  if v-mode <> {&update} then do:
     disable cli cli-type r-cli cli-name  b-clear  with frame {&frame-name}.
     B-ok:label = "Вы&ход"  .
     hide B-cancel in frame {&frame-name} .
  END.

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
  DISPLAY cli-type cli cli-name 
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-clear B-Help cli-type r-cli cli cli-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

