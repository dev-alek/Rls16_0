&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: 3d3ba7fff1ab, 2269, rls $
$Author: ASMorozov $
$Date: Wed Dec 25 15:24:02 2019 +0300 $
$Workfile: d-invAttr.w $
$Archive: gbl/d-invAttr.w $

Универсальный диалог для ввода данных

Автор: Перваков Михаил Сергеевич
Дата создания: 10/17/97
Author: Mikhail Pervakov
Creation date: 10/17/97

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT        PARAMETER pParameters  AS CHARACTER NO-UNDO.
define input        parameter pTech        as logical no-undo .
DEFINE INPUT-OUTPUT PARAMETER pValue       AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER pSecondValue AS CHARACTER NO-UNDO.


define variable vss-revision    as character no-undo init "$Revision: 3d3ba7fff1ab, 2269, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:02 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: d-invAttr.w $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/d-invAttr.w $":U .
define variable vss-description as character no-undo init "Универсальный диалог для ввода данных".
{ cmp/vssrevis.i }
{ gbl/color.i    }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ gbl/sel-date.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */
define variable v-read-only     AS LOGICAL   NO-UNDO INIT False .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS FILL-IN-Character FILL-IN-Character-2 Btn_OK ~
Btn_Cancel 
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-Character FILL-IN-Character-2 ~
FILL-IN-Text-2 FILL-IN-Text-3 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
  LABEL "&Отмена" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
  LABEL "&Ввод " 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-Character   AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS FILL-IN 
  SIZE 88 BY 1.04
  BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE FILL-IN-Character-2 AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS FILL-IN 
  SIZE 88 BY 1
  BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-1      AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS TEXT 
  SIZE 41.25 BY .58
  FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-2      AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS TEXT 
  SIZE 41.25 BY .58
  FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-3      AS CHARACTER FORMAT "X(256)":U 
  VIEW-AS TEXT 
  SIZE 41.25 BY .58
  FONT 4 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  FILL-IN-Character AT ROW 2.96 COL 2 NO-LABEL
  FILL-IN-Character-2 AT ROW 5 COL 2 NO-LABEL WIDGET-ID 2
  Btn_OK AT ROW 7 COL 2.5
  Btn_Cancel AT ROW 7 COL 12.5
  FILL-IN-Text-1 AT ROW 1.13 COL 2.5 NO-LABEL
  FILL-IN-Text-2 AT ROW 2.04 COL 2.5 NO-LABEL
  FILL-IN-Text-3 AT ROW 4.21 COL 2.5 NO-LABEL WIDGET-ID 4
  SPACE(50.12) SKIP(3.58)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Атрибуты инвентаризации"
  CANCEL-BUTTON Btn_Cancel.


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
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Character IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-Character-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-Text-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
  FILL-IN-Text-1:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-Text-3 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Prompter */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON choose OF Btn_OK IN FRAME Dialog-Frame
  DO:
    if not pTech then 
    do:
      if (FiLL-IN-Character = "" and FiLL-IN-Character-2 <> "") or
      (FILL-IN-Character-2 = "" and FiLL-IN-Character <> "") then 
      do:
        message "Не все поля заполнены." 
          view-as alert-box.
        return no-apply .
      end. 
    end.
      pValue = FILL-IN-Character .
      pSecondValue = FILL-IN-Character-2 .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME FILL-IN-Character
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Character Dialog-Frame
ON RETURN OF FILL-IN-Character IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character .
    APPLY "value-changed":U TO FILL-IN-Character-2.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME FILL-IN-Character-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Character-2 Dialog-Frame
ON RETURN OF FILL-IN-Character-2 IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character-2 .
    APPLY "CHOOSE":U TO Btn_OK.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Character Dialog-Frame
ON value-changed OF FILL-IN-Character IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Character-2 Dialog-Frame
ON value-changed OF FILL-IN-Character-2 IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character-2 .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable ind      AS INTEGER   NO-UNDO.
define variable sElement AS CHARACTER NO-UNDO.
define variable sValue   AS CHARACTER NO-UNDO.

DO ind = 1 TO NUM-ENTRIES(pParameters, '\'):
  sElement = ENTRY(ind, pParameters, '\').
  IF NUM-ENTRIES(sElement, '=') = 2
    THEN 
  DO:
    sValue   = ENTRY(2, sElement, '=').
    CASE ENTRY(1, sElement, '='):
      WHEN 'text1'         THEN 
        do: 
          assign 
            FILL-IN-Text-2 = str-decode(sValue, "").             
        end.
      WHEN 'text2'         THEN 
        do: 
          assign 
            FILL-IN-Text-3 = str-decode(sValue, "").             
        end.
      WHEN 'readonly'      THEN 
        do: 
          assign 
            v-read-only = lookup(sValue, 'yes,true':U) > 0 .  
        end.
    END CASE.
  END.
END.
assign 
  FILL-IN-Character   = pValue
  FILL-IN-Character-2 = pSecondValue
  .
define variable hFrameHandle AS WIDGET-HANDLE NO-UNDO.
hFrameHandle = FRAME {&FRAME-NAME}:HANDLE.

define variable hText AS WIDGET-HANDLE NO-UNDO.

DO WITH FRAME {&FRAME-NAME}
  :
  IF FILL-IN-Text-1 <> ''
    THEN 
  DO:
    DISPLAY FILL-IN-Text-1.
  END.

  IF FILL-IN-Text-2 <> ''
    THEN 
  DO:
    DISPLAY FILL-IN-Text-2.
  END.
END.

define variable sText1Label AS CHARACTER NO-UNDO.


define variable sTypeOk     as logical   no-undo .

assign
  sTypeOk = false
  .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run setup-cancel-button .

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
  DISPLAY FILL-IN-Character FILL-IN-Character-2 FILL-IN-Text-2 FILL-IN-Text-3 
    WITH FRAME Dialog-Frame.
  ENABLE FILL-IN-Character FILL-IN-Character-2 Btn_OK Btn_Cancel 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-cancel-button Dialog-Frame 
PROCEDURE setup-cancel-button :
  /* -----------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  -------------------------------------------------------------*/
  do with frame {&frame-name}
    :
    if v-read-only
      then 
    do:
      assign
        Btn_OK :LABEL = "&Выход"
        .
    end.
    
    if v-read-only = false
      then 
    do:
      assign
        Btn_Cancel :visible   = true
        Btn_Cancel :sensitive = true
        .
    end.
    else 
    do:
      assign
        Btn_Cancel :sensitive = false
        Btn_Cancel :visible   = false
        .
    end.
    FILL-IN-Character :SENSITIVE    = True AND NOT v-read-only .
    FILL-IN-Character-2 :SENSITIVE    = True AND NOT v-read-only .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

