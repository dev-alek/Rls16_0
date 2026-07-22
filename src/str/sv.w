&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Документ сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ сверки".
{ cmp/vssrevis.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 RECT-2 ~
partemp-layer1 partemperature partemp-layer2 partemp-layer3
&Scoped-Define DISPLAYED-OBJECTS varbrutto-qnty parmeasure-qnty ~
parsystem-qnty vardensity parbrutto-cli-qnty-2 parmeasure-cli-qnty ~
parsystem-cli-qnty-2 partemp-layer1 parlevel-petrol parlevel-total ~
partemperature partemp-layer2 parlevel-water partemp-layer3 ~
parlevel-petrol-4

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
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE parbrutto-cli-qnty-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Вес жидк."
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1.08 NO-UNDO.

DEFINE VARIABLE parlevel-petrol AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень топлива"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE parlevel-petrol-4 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень водоэмульсионной жидкости"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE parlevel-total AS CHARACTER FORMAT "X(256)":U
     LABEL "Общий уровень в танке"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE parlevel-water AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень воды"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE parmeasure-cli-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "Вес топл."
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1.08 NO-UNDO.

DEFINE VARIABLE parmeasure-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "V топлива"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE parsystem-cli-qnty-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Вес топл.(книж.)"
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1.08 NO-UNDO.

DEFINE VARIABLE parsystem-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "V топлива(книж.)"
     VIEW-AS FILL-IN
     SIZE 19.75 BY 1 NO-UNDO.

DEFINE VARIABLE partemp-layer1 AS CHARACTER FORMAT "X(256)":U
     LABEL "T1"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE partemp-layer2 AS CHARACTER FORMAT "X(256)":U
     LABEL "T2"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE partemp-layer3 AS CHARACTER FORMAT "X(256)":U
     LABEL "T3"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE partemperature AS CHARACTER FORMAT "X(256)":U
     LABEL "T"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varbrutto-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "V танка"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE vardensity AS CHARACTER FORMAT "X(256)":U
     LABEL "Плотность"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.75 BY 6.13.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.13 BY 6.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varbrutto-qnty AT ROW 2.88 COL 9.5 COLON-ALIGNED
     parmeasure-qnty AT ROW 2.92 COL 31.38
     parsystem-qnty AT ROW 2.96 COL 78.13 COLON-ALIGNED
     vardensity AT ROW 4.33 COL 40.5 COLON-ALIGNED
     parbrutto-cli-qnty-2 AT ROW 5.54 COL 10 COLON-ALIGNED
     parmeasure-cli-qnty AT ROW 5.67 COL 40.38 COLON-ALIGNED
     parsystem-cli-qnty-2 AT ROW 5.75 COL 78.88 COLON-ALIGNED
     partemp-layer1 AT ROW 7.67 COL 16.63
     parlevel-petrol AT ROW 7.71 COL 71.13 COLON-ALIGNED
     parlevel-total AT ROW 9.25 COL 71 COLON-ALIGNED
     partemperature AT ROW 9.58 COL 3.13
     partemp-layer2 AT ROW 9.58 COL 16.63
     parlevel-water AT ROW 10.67 COL 70.88 COLON-ALIGNED
     partemp-layer3 AT ROW 11.63 COL 16.88
     parlevel-petrol-4 AT ROW 12.08 COL 70.88 COLON-ALIGNED
     RECT-1 AT ROW 7.17 COL 1.5
     RECT-2 AT ROW 7.21 COL 32.63
     SPACE(0.36) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ сверки".


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN parbrutto-cli-qnty-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parlevel-petrol IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parlevel-petrol-4 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parlevel-total IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parlevel-water IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parmeasure-cli-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parmeasure-qnty IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN parsystem-cli-qnty-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN parsystem-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN partemp-layer1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN partemp-layer2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN partemp-layer3 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN partemperature IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varbrutto-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vardensity IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ сверки */
DO:
  APPLY "END-ERROR":U TO SELF.
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
  RUN enable_UI.
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
  DISPLAY varbrutto-qnty parmeasure-qnty parsystem-qnty vardensity
          parbrutto-cli-qnty-2 parmeasure-cli-qnty parsystem-cli-qnty-2
          partemp-layer1 parlevel-petrol parlevel-total partemperature
          partemp-layer2 parlevel-water partemp-layer3 parlevel-petrol-4
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 RECT-2 partemp-layer1 partemperature
         partemp-layer2 partemp-layer3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
