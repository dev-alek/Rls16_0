&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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

define temp-table tt-objs-diff no-undo
    field label_ as character
    field TH-value as character     format "X(100)"
    field EGAIS-value as character  format "X(100)"
    index pi as primary
        label_
.        

/* Parameters Definitions ---                                           */

define input parameter p-rowid as rowid .
define input parameter bh-objs as handle.
define input parameter bh-objs-egais as handle.

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-objs-diff

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-objs-diff

/* Definitions for BROWSE br-objs-diff                                      */
&Scoped-define SELF-NAME br-objs-diff
&Scoped-define QUERY-STRING-br-objs-diff FOR EACH tt-objs-diff
&Scoped-define OPEN-QUERY-br-objs-diff OPEN QUERY {&SELF-NAME} FOR EACH tt-objs-diff.
&Scoped-define TABLES-IN-QUERY-br-objs-diff tt-objs-diff
&Scoped-define FIRST-TABLE-IN-QUERY-br-objs-diff tt-objs-diff


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-objs-diff}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok br-objs-diff 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-ok AUTO-GO 
     LABEL "OK" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-objs-diff FOR 
      tt-objs-diff SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-objs-diff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-objs-diff Dialog-Frame _FREEFORM
  QUERY br-objs-diff DISPLAY
    tt-objs-diff.label_ COLUMN-LABEL "Название поля" FORMAT "X(22)":U 
    tt-objs-diff.TH-value COLUMN-LABEL "Значение в TH" FORMAT "X(35)":U
    tt-objs-diff.EGAIS-value COLUMN-LABEL "Значение ЕГАИС" FORMAT "X(35)":U  
      
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 11.19 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 2
     br-objs-diff AT ROW 2.67 COL 2 WIDGET-ID 200
     SPACE(0.39) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Различия по строке"
         DEFAULT-BUTTON b-ok WIDGET-ID 100.


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
/* BROWSE-TAB br-objs-diff b-ok Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-objs-diff
/* Query rebuild information for BROWSE br-objs-diff
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-objs-diff.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-objs-diff */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Различия по строке */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-objs-diff
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
  run fill-tt.
  { gbl/diasize.i &browse-name=br-objs-diff }
  run diasize_init in this-procedure .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure fill-tt :
    def var ii as integer no-undo .
    bh-objs:find-by-rowid (p-rowid, no-lock) no-error.
    if bh-objs:available then do :
        if bh-objs:buffer-field ("connected_"):buffer-value then do :
            bh-objs-egais:find-unique (substitute("where tt-objs-EG.regID = '&1'", bh-objs:buffer-field ("regID"):buffer-value), no-lock) no-error.
        end.
        else do :
            bh-objs-egais:find-unique (substitute("where tt-objs-EG.inn = '&1' and tt-objs-EG.kpp = '&2'", bh-objs:buffer-field ("inn"):buffer-value, bh-objs:buffer-field ("kpp"):buffer-value), no-lock) no-error.  
        end.
        if bh-objs-egais:available then do :
            do ii = 4 to (bh-objs:num-fields - 2) :
                if bh-objs:buffer-field (ii):buffer-value <> bh-objs-egais:buffer-field (ii):buffer-value then do :
                    create tt-objs-diff .
                    assign
                        tt-objs-diff.label_ = bh-objs:buffer-field (ii):label
                        tt-objs-diff.TH-value = bh-objs:buffer-field (ii):buffer-value
                        tt-objs-diff.EGAIS-value = bh-objs-egais:buffer-field (ii):buffer-value
                    .
                end. 
            end.           
        end.
    end.  
end procedure.    

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
  ENABLE b-ok br-objs-diff 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  br-objs-diff:resizable = true .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

