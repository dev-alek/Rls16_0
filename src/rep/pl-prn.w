&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог печати переоценки

Автор: Чернова Светлана Александровна
Дата создания: 04/13/06
Author: Svetlana Chernova
Creation date: 04/13/06

Author: Черных В.Г.

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter DisabledOptions as integer   no-undo .
define input  parameter p-rep-name   as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог печати переоценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }

/* Local Variable Definitions ---                                       */

define variable v-user-action as character no-undo .
define variable v-printed     as logical   no-undo .
define variable stat                as      logical  init no           no-undo.
define variable RepFileFullName     as      character                   no-undo.
define variable BuhRetFlag          as      character init "NO"         no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Exit R-Run PrintTitle B-Help

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help DEFAULT
     LABEL "&Помощь":L
     SIZE 10.5 BY 1.25
     BGCOLOR 8 .

DEFINE BUTTON Exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.25.

DEFINE BUTTON PrintTitle
     LABEL "Печать &оглавления":L
     SIZE 19 BY 1.25.

DEFINE BUTTON R-Run
     LABEL "П&ечать прайс-листа":L
     SIZE 20.5 BY 1.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     Exit AT ROW 1.79 COL 2.13
     R-Run AT ROW 1.79 COL 14.63
     PrintTitle AT ROW 1.79 COL 36.13
     B-Help AT ROW 1.79 COL 58.13
     SPACE(2.61) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE "Выбор отчета   ":L
         DEFAULT-BUTTON R-Run.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   UNDERLINE                                                            */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

ASSIGN
       Exit:PRIVATE-DATA IN FRAME DIALOG-1     =
                "Exit".

ASSIGN
       R-Run:PRIVATE-DATA IN FRAME DIALOG-1     =
                "R-Run".

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */



&Scoped-define SELF-NAME Exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Exit DIALOG-1
ON CHOOSE OF Exit IN FRAME DIALOG-1 /* Выход  */
DO:
    return BuhRetFlag .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME PrintTitle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PrintTitle DIALOG-1
ON CHOOSE OF PrintTitle IN FRAME DIALOG-1 /* Печать оглавления */
DO:
    run gbl/prnfilen.w
      (input  "Печать оглавления"
      ,input  DisabledOptions
      ,input  string( session:temp-directory + {&PLT_Name} + string( p-rep-name ) )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .

    apply "ENTRY" to Exit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-Run
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-Run DIALOG-1
ON CHOOSE OF R-Run IN FRAME DIALOG-1 /* Печать прайс-листа */
DO:
    run gbl/prnfilen.w
      (input  "Печать прайс-листа"
      ,input  DisabledOptions
      ,input  string( session:temp-directory + {&DF_Name} + string( p-rep-name ) )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .

    apply "ENTRY" to Exit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */
/* Restore the current-window if it is an icon.                         */
/* Otherwise the dialog box will be hidden                              */
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
/*    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK */ :

    RUN enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1 _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1 _DEFAULT-ENABLE
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
  ENABLE Exit R-Run PrintTitle B-Help
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME