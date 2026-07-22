&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инвентаризационная опись и сличительная ведомость

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

  define input-output parameter s-pole   as integer   no-undo .
  define output parameter min-sum  as decimal   no-undo .
  define output parameter v-nedost as logical   no-undo .
  define output parameter all-grp  as integer   no-undo .
  define output parameter list-grp as character no-undo .

  def var vss-revision    as character no-undo init "$Revision$":U .
  def var vss-author      as character no-undo init "$Author$":U .
  def var vss-date        as character no-undo init "$Date$":U .
  def var vss-workfile    as character no-undo init "$Workfile$":U .
  def var vss-archive     as character no-undo init "$Archive$":U .
  def var vss-description as character no-undo init "Формы по инвентаризации ".
  { cmp/vssrevis.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS FILL-IN-1 RADIO-SET-1 RADIO-SET-2 ~
RADIO-SET-3 Btn_OK
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 RADIO-SET-1 RADIO-SET-2 ~
RADIO-SET-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-1 AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Ра&зница сумма"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по &наименованию", 1,
"по &артикулу", 2,
"по &разнице сумм", 3
     SIZE 20.88 BY 3 NO-UNDO.

DEFINE VARIABLE RADIO-SET-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Не&достача", 1,
"&Излишки", 2
     SIZE 14.5 BY 1.92 NO-UNDO.

DEFINE VARIABLE RADIO-SET-3 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 14.13 BY 1.75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     FILL-IN-1 AT ROW 1.54 COL 15.75 COLON-ALIGNED
     RADIO-SET-1 AT ROW 2.67 COL 36.88 NO-LABEL
     RADIO-SET-2 AT ROW 3.96 COL 3.25 NO-LABEL
     RADIO-SET-3 AT ROW 4.13 COL 18.5 NO-LABEL
     Btn_OK AT ROW 6.79 COL 20.13
     "Группы:" VIEW-AS TEXT
          SIZE 9.5 BY .67 AT ROW 3.08 COL 18.88
          FGCOLOR 4
     "Сортировка:" VIEW-AS TEXT
          SIZE 13.13 BY .67 AT ROW 1.79 COL 37.88
          FGCOLOR 4
     "Анализ:" VIEW-AS TEXT
          SIZE 9.5 BY .67 AT ROW 3.08 COL 5.13
          FGCOLOR 4
     SPACE(43.13) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Инвентаризация (анализ отклонений)"
         DEFAULT-BUTTON Btn_OK.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Инвентаризация (анализ отклонений) */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:  /*ok*/
  assign FILL-IN-1  RADIO-SET-1  RADIO-SET-2  RADIO-SET-3 .
  assign
    s-pole  = RADIO-SET-1
    min-sum = FILL-IN-1
    all-grp = RADIO-SET-3
  .
  if RADIO-SET-2 = 1 then assign v-nedost = yes .
  else                    assign v-nedost = no .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-3 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-3 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-3 .
  if RADIO-SET-3 = 2 then do:
    run ref/gds-grp.w ( input parparentproc
                 , input "b-sel,b-mark"
                 , input p-obj-type
                 , input p-obj-code
                 , input-output list-grp ).
    if list-grp = "" then assign RADIO-SET-3 = 1 .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/*  no_app_help.i  */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign  RADIO-SET-1 = s-pole .

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
  DISPLAY FILL-IN-1 RADIO-SET-1 RADIO-SET-2 RADIO-SET-3
      WITH FRAME Dialog-Frame.
  ENABLE FILL-IN-1 RADIO-SET-1 RADIO-SET-2 RADIO-SET-3 Btn_OK
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME