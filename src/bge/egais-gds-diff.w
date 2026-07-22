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

define temp-table tt-gds-diff no-undo
    field label_ as character
    field TH-value as character     format "X(100)"
    field EGAIS-value as character  format "X(100)"
    index pi as primary
        label_
.        

/* Parameters Definitions ---                                           */

define input parameter p-rowid as rowid .
define input parameter bh-gds as handle.
define input parameter bh-gds-egais as handle.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-gds-diff

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-diff

/* Definitions for BROWSE br-objs-diff                                      */
&Scoped-define SELF-NAME br-gds-diff
&Scoped-define QUERY-STRING-br-gds-diff FOR EACH tt-gds-diff
&Scoped-define OPEN-QUERY-br-gds-diff OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-diff.
&Scoped-define TABLES-IN-QUERY-br-gds-diff tt-gds-diff
&Scoped-define FIRST-TABLE-IN-QUERY-br-gds-diff tt-gds-diff


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-gds-diff}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok br-objs-diff 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

{ cmp/str-glbl.i }

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-ok AUTO-GO 
     LABEL "OK" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-gds-diff FOR 
      tt-gds-diff SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gds-diff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-objs-diff Dialog-Frame _FREEFORM
  QUERY br-gds-diff DISPLAY
    tt-gds-diff.label_ COLUMN-LABEL "Название поля" FORMAT "X(22)":U 
    tt-gds-diff.TH-value COLUMN-LABEL "Значение в TH" FORMAT "X(100)":U width 39
    tt-gds-diff.EGAIS-value COLUMN-LABEL "Значение ЕГАИС" FORMAT "X(100)":U width 40 
      
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 11.19 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 2
     br-gds-diff AT ROW 2.67 COL 2 WIDGET-ID 200
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
  { gbl/diasize.i &browse-name=br-gds-diff }
  run diasize_init in this-procedure .
  run fill-tt.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure fill-tt :
    def var ii as integer no-undo .
    bh-gds:find-by-rowid (p-rowid, no-lock) no-error.
    if bh-gds:available then do : 
        if bh-gds:buffer-field ("alc-code"):buffer-value <> ? and bh-gds:buffer-field ("alc-code"):buffer-value <> "" then do :
            bh-gds-egais:find-unique (substitute("where tt-gds-EG.alc-code = '&1'", bh-gds:buffer-field ("alc-code"):buffer-value), no-lock) no-error.
        end.
        else do :
            bh-gds-egais:find-unique (substitute("where tt-gds-EG.gds-name = '&1'", bh-gds:buffer-field ("gds-name"):buffer-value), no-lock) no-error.
        end.
        if bh-gds-egais:available then do :
            do ii = 2 to (bh-gds-egais:num-fields - 2) :
                if bh-gds:buffer-field (ii):buffer-value <> bh-gds-egais:buffer-field (ii):buffer-value then do :
                    create tt-gds-diff .
                    assign
                        tt-gds-diff.label_ = bh-gds:buffer-field (ii):label
                        tt-gds-diff.TH-value = string(bh-gds:buffer-field (ii):buffer-value)
                        tt-gds-diff.EGAIS-value = string(bh-gds-egais:buffer-field (ii):buffer-value)
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
  ENABLE b-ok br-gds-diff 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  br-gds-diff:column-resizable in FRAME Dialog-Frame = true .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

