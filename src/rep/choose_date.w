&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{ rep/tt-date.i }
{ gbl/sel-date.i }
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input-output  PARAMETER TABLE FOR tt-dateZakaz.


/* Local Variable Definitions ---                                       */
define buffer buf_dateZakaz for tt-dateZakaz .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel RECT-8 Date-Start ~
b-date-Start Date-End b-date-End 
&Scoped-Define DISPLAYED-OBJECTS Date-Start Date-End 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-6 Date-Start Date-End 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-date-End 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "" 
  SIZE 3 BY .88.

DEFINE BUTTON b-date-Start 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "" 
  SIZE 3 BY .88.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
  LABEL "Отмена" 
  SIZE 15 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
  LABEL "Ввод" 
  SIZE 15 BY 1.13
  BGCOLOR 8 .

DEFINE VARIABLE Date-End   AS DATE FORMAT "99/99/9999":U 
  LABEL "по" 
  VIEW-AS FILL-IN NATIVE 
  SIZE 13 BY 1
  BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE Date-Start AS DATE FORMAT "99/99/9999":U 
  LABEL "С" 
  VIEW-AS FILL-IN NATIVE 
  SIZE 13 BY 1
  BGCOLOR 15 NO-UNDO.

DEFINE RECTANGLE RECT-8
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 47 BY 2.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  Btn_OK AT ROW 1 COL 1
  Btn_Cancel AT ROW 1 COL 16
  Date-Start AT ROW 3.5 COL 6 COLON-ALIGNED WIDGET-ID 34
  b-date-Start AT ROW 3.5 COL 23 RIGHT-ALIGNED WIDGET-ID 374
  Date-End AT ROW 3.5 COL 42 RIGHT-ALIGNED WIDGET-ID 32
  b-date-End AT ROW 3.5 COL 45 RIGHT-ALIGNED WIDGET-ID 376
  RECT-8 AT ROW 2.75 COL 3 WIDGET-ID 378
  SPACE(1.24) SKIP(0.66)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Задайте период"
  DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON b-date-End IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
  b-date-End:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-date-Start IN FRAME Dialog-Frame
   ALIGN-R                                                              */
ASSIGN 
  b-date-Start:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN Date-End IN FRAME Dialog-Frame
   ALIGN-R 6                                                            */
/* SETTINGS FOR FILL-IN Date-Start IN FRAME Dialog-Frame
   6                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Задайте период */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btn_ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_ok Dialog-Frame
ON CHOOSE OF btn_ok IN FRAME Dialog-Frame
  DO:
  find first tt-dateZakaz no-error .
  if not available (tt-dateZakaz) then do:
    create tt-dateZakaz .
    assign
    tt-dateZakaz.id = 1
    tt-dateZakaz.dateStart = Date-Start
    tt-dateZakaz.dateEnd = Date-End .
  end.
  else do:
    find first tt-dateZakaz no-lock where (Date-Start >= tt-dateZakaz.dateStart and Date-Start <= tt-dateZakaz.dateEnd) or
    (Date-End >= tt-dateZakaz.dateStart and Date-End <= tt-dateZakaz.dateEnd) no-error .
    if available (tt-dateZakaz) then do:
      message "Выбранный интервал пересекается с предыдущим"
      view-as alert-box.
      return no-apply .
    end.
    find last tt-dateZakaz no-error .
    if available (tt-dateZakaz) then do:
      create buf_dateZakaz .
      assign 
      buf_dateZakaz.id = tt-dateZakaz.id + 1
      buf_dateZakaz.dateEnd = Date-End
      buf_dateZakaz.dateStart = Date-Start
      .
    end.
  end.  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date-End Dialog-Frame
ON CHOOSE OF b-date-End IN FRAME Dialog-Frame
  DO:
    run sel-date in this-procedure
      (input Date-End :handle
      ,input ""
      ) .

    if date(Date-End:screen-value) < Date-Start then 
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      display Date-End with frame Dialog-Frame .    
    end.
    
    if date(Date-End:screen-value) >= today then 
    do:
      message "Дата окончания периода продаж должна быть меньше текущей"
        view-as alert-box.
      display Date-End with frame Dialog-Frame .
    end.   
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-date-Start Dialog-Frame
ON CHOOSE OF b-date-Start IN FRAME Dialog-Frame
  DO:
    run sel-date in this-procedure
      (input Date-Start :handle
      ,input ""
      ) .
      
    if Date-End < date(Date-Start:screen-value) then 
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      display Date-Start with frame Dialog-Frame .       
    end.
    
    if date(Date-Start:screen-value) >= today then 
    do:
      message "Дата начала периода продаж должна быть меньше текущей"
        view-as alert-box.
      display Date-Start with frame Dialog-Frame .
    end.   
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON LEAVE OF Date-End IN FRAME Dialog-Frame /* по */
  DO:
    apply "TAB":U to self .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON LEAVE OF Date-Start IN FRAME Dialog-Frame /* С */
  DO:
    apply "TAB":U to self .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON RETURN OF Date-End IN FRAME Dialog-Frame
  DO:
    apply "TAB":U to self .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End Dialog-Frame
ON TAB OF Date-End IN FRAME Dialog-Frame
  DO:
    if string(Date-End) <> Date-End:screen-value then 
    do:
      if date(Date-End:screen-value) < Date-Start then 
      do:
        message "Дата начала не может быть больше конечной даты"
          view-as alert-box.
        return no-apply .       
      end.
      if date(Date-End:screen-value) >= today then 
      do:
        message "Дата окончания периода продаж должна быть меньше текущей"
          view-as alert-box.
        display Date-End with frame Dialog-Frame .
        return .
      end. 
      assign Date-End .
      display Date-End with frame Dialog-Frame .
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON RETURN OF Date-Start IN FRAME Dialog-Frame
  DO:
    apply "TAB":U to self .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start Dialog-Frame
ON TAB OF Date-Start IN FRAME Dialog-Frame
  DO:
    if string(Date-Start) <> Date-Start:screen-value then 
    do:
      if Date-End < date(Date-Start:screen-value) then 
      do:
        message "Дата начала не может быть больше конечной даты"
          view-as alert-box.
        return no-apply .       
      end.
      if date(Date-Start:screen-value) >= today then 
      do:
        message "Дата начала периода продаж должна быть меньше текущей"
          view-as alert-box.
        display Date-Start with frame Dialog-Frame .
        return .
      end. 
      assign Date-Start .
      display Date-Start with frame Dialog-Frame .
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/ed_date.i Date-Start }  
  { gbl/ed_date.i Date-End }     
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
  DISPLAY Date-Start Date-End 
    WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel RECT-8 Date-Start b-date-Start Date-End b-date-End 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

