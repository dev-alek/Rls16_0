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

/* Parameters Definitions ---                                           */
define input parameter p-db-num as integer no-undo .
define input parameter p-CheckId as character no-undo .
define input parameter p-RRN as character no-undo .
/* Local Variable Definitions ---                                       */

define variable print-type as character no-undo.

define buffer chk-slip-head for ub.chk-slip-head .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

function func-proc-type returns character
(input v-int-type as integer):
  case v-int-type :
    when 1 then return "Банковский" .
    when 2 then return "Лояльность" .
    when 3 then return "Топливный" .
    otherwise return " - " .
  end case .
end function .

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE MENU MENU-B-print
       MENU-ITEM m_one         LABEL "Текущий"
       MENU-ITEM m_all         LABEL "Все"  .

DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .
     
DEFINE BUTTON b-print 
     LABEL "Сохранить в файл" 
     SIZE 17 BY 1.14
     BGCOLOR 8 .     

define query br-chk-slip-head for chk-slip-head scrolling .

define browse br-chk-slip-head
  query br-chk-slip-head display
  chk-slip-head.ID
  func-proc-type(chk-slip-head.proc-type) label "Тип процессинга"
  chk-slip-head.RRN
WITH SEPARATORS SIZE 70 BY 6 FIT-LAST-COLUMN.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.1 COL 2
     b-print AT ROW 1.1 COL 18.8 WIDGET-ID 2
     br-chk-slip-head at row 2.3 col 2
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Слипы"
         CANCEL-BUTTON b-exit WIDGET-ID 100.


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
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 
ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Слипы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-chk-slip-head
&Scoped-define SELF-NAME br-chk-slip-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-chk-slip-head Dialog-Frame
ON RETURN OF br-chk-slip-head IN FRAME Dialog-Frame
OR mouse-select-dblclick of br-chk-slip-head in frame Dialog-Frame
do:
  if not available chk-slip-head
  then do :
    return no-apply .
  end .
  run str/chk-slip.w (input chk-slip-head.db-num,
                      input chk-slip-head.ID,
                      input chk-slip-head.CheckID,
                      input chk-slip-head.RRN)
                      .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not available chk-slip-head
  then do :
    return no-apply .
  end .
  if print-type = "" then do:
    run gbl/pop-up.p ( input b-print:handle, input no) no-error.
    if error-status:error then return no-apply.
  end.
  if print-type = "" then return no-apply.
  run str/chk-slip-print.p (input chk-slip-head.db-num,
                            input chk-slip-head.ID,
                            input chk-slip-head.CheckID,
                            input chk-slip-head.RRN,
                            input print-type)
                            .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Один */
DO:
    print-type = "one":U.
    apply "choose" to b-print in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Все */
DO:
    if p-RRN = ?
    then do :
      print-type = "all":U.
    end .
    else do :
      print-type = "all_pay":U.
    end .
    apply "choose" to b-print in frame {&frame-name}.
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
  b-print:MENU-MOUSE = 1 .
  if p-RRN = ?
  then do :
    find first chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                       and chk-slip-head.CheckID = p-CheckId
                                       and chk-slip-head.is-report = 0
                                       no-error.
    if not available chk-slip-head
    then do :
      message "Слипы не найдены!" view-as alert-box .
      return .
    end .
  end .
  else do :
    find first chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                       and chk-slip-head.CheckID = p-CheckId
                                       and chk-slip-head.RRN = p-RRN
                                       and chk-slip-head.is-report = 0
                                       no-error.
    if not available chk-slip-head
    then do :
      message "Слипы не найдены!" view-as alert-box .
      return .
    end .
  end .   
     
  RUN enable_UI.
  if p-RRN = ?
  then do :
    open query br-chk-slip-head for each chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                                                 and chk-slip-head.CheckID = p-CheckId
                                                                 and chk-slip-head.is-report = 0 .
  end .
  else do :
    open query br-chk-slip-head for each chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                                                 and chk-slip-head.CheckID = p-CheckId
                                                                 and chk-slip-head.RRN = p-RRN
                                                                 and chk-slip-head.is-report = 0
                                                                 .
  end .
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
  ENABLE b-exit b-print br-chk-slip-head
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

