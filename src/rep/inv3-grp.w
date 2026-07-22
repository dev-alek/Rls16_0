&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор групп для печати итогов

Автор: Комаров Иван Сергеевич
Дата создания: 12/30/09
Author: Ivan Komarov
Creation date: 12/30/09

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отчет по покупателям товаров (выкуп)" .
    { cmp/vssrevis.i }
    { cmp/str-glbl.i  }
    { cmp/library.i }
    { cmp/showinf.i }
    { cmp/r-pril.i new }
    { gbl/prn-lib.i }
    { ref/cgrplbfn.i }
    { gbl/getcntxt.i def }

define output parameter p-classify  as character    no-undo .
define output parameter p-tog-level as logical      no-undo .
define output parameter p-var-level as integer      no-undo .
define output parameter p-ok        as logical      no-undo .

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Print Btn_OK Classify
&Scoped-Define DISPLAYED-OBJECTS Classify

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_OK AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Print
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE var-level AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY .75
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Группы 1-го уровня", "no-classify":U,
"Группы с n-уровнeм вложенности", "n-level":U,
"Терминальные группы", "t-level":U
     SIZE 33 BY 3.42
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Tog-level AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 11 BY .75
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     Btn_Print AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     Classify AT ROW 2.75 COL 5 NO-LABEL WIDGET-ID 2
     Tog-level AT ROW 4 COL 38.5 WIDGET-ID 8
     var-level AT ROW 4 COL 48 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     SPACE(3.24) SKIP(1.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Выбор групп товаров":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   FRAME-NAME UNDERLINE                                                 */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".

/* SETTINGS FOR TOGGLE-BOX Tog-level IN FRAME DLGOKCAN
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       Tog-level:HIDDEN IN FRAME DLGOKCAN           = TRUE.

/* SETTINGS FOR FILL-IN var-level IN FRAME DLGOKCAN
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       var-level:HIDDEN IN FRAME DLGOKCAN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DLGOKCAN
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN /* Отмена */
DO:
    return "NO" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Print DLGOKCAN
ON CHOOSE OF Btn_Print IN FRAME DLGOKCAN /* Ввод  */
DO:
  assign
      classify
      tog-level
      var-level
  .
  if Classify = "n-level":U and tog-level = true then do :
      assign
        p-classify  = Classify
        p-tog-level = tog-level
        p-var-level = var-level
        p-ok = true
      .
  end.
  else do :
      assign
        p-classify  = Classify
        p-tog-level = tog-level
        p-var-level = var-level
        p-ok = true
       .
  end.
apply "GO" TO FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify DLGOKCAN
ON VALUE-CHANGED OF Classify IN FRAME DLGOKCAN
DO:
  ASSIGN Classify.

  if classify = "n-level":u
  then do:
    enable  tog-level  var-level with frame {&frame-name} .
    display tog-level  var-level with frame {&frame-name} .
  end.
  else do:
/*    disable tog-level  var-level with frame {&frame-name} .
*/
    hide    tog-level  var-level   in frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-level DLGOKCAN
ON VALUE-CHANGED OF Tog-level IN FRAME DLGOKCAN /* с уровня */
DO:
  assign tog-level.
  if tog-level = true then do:
    display var-level with frame {&frame-name} .
    enable  var-level with frame {&frame-name} .
  end.
  else do:
    display var-level with frame {&frame-name} .
    disable var-level with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/*{ gbl/app_help.i }*/

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN  _DEFAULT-ENABLE
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
  DISPLAY Classify
      WITH FRAME DLGOKCAN.
  ENABLE Btn_Print Btn_OK Classify
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME