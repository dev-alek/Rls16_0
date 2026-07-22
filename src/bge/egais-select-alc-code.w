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

define shared temp-table tt-exts
    field ext-rec as recid
    field gds-code as integer
    index pi as primary unique
        ext-rec gds-code
.

/* Parameters Definitions ---                                           */

define input parameter p-gds-code as integer no-undo .
define output parameter p-rec   as recid no-undo .

/* Local Variable Definitions ---                                       */
define buffer x_ext-classif     for ub.ext-classif .
define buffer x_ext-classif-attr     for ub.ext-classif-attr .

define variable qh-gds-egais as handle no-undo .
define variable br-hndl-gds  as handle no-undo .

define variable ii as integer no-undo .

{ cmp/str-glbl.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-select b-cancel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */
function f-name returns character (buffer loc-exts for X_ext-classif-attr) :
    if num-entries(loc-exts.attr-value, CHR(4)) = 3 then return entry(3, loc-exts.attr-value, CHR(4)) .
    else return "" .        
end function .

function f-prod returns character (buffer loc-exts for X_ext-classif-attr) :
    if num-entries(loc-exts.attr-value, CHR(4)) = 3 then do :
        if num-entries(entry(1, loc-exts.attr-value, CHR(4)), CHR(5)) = 6 then
            return entry(4, entry(1, loc-exts.attr-value, CHR(4)), CHR(5)).
        else return "" .
    end.
    else return "" .        
end function .

function f-imp returns character (buffer loc-exts for X_ext-classif-attr) :
    if num-entries(loc-exts.attr-value, CHR(4)) = 3 then do :
        if num-entries(entry(2, loc-exts.attr-value, CHR(4)), CHR(5)) = 6 then
            return entry(4, entry(2, loc-exts.attr-value, CHR(4)), CHR(5)).
        else return "" .
    end.
    else return "" .        
end function .
/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-select AUTO-GO 
     LABEL "Выбор" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

define query br-exts for
    tt-exts, x_ext-classif, x_ext-classif-attr   scrolling . 
    
define browse br-exts
    query br-exts display
        X_ext-classif.charkey_one      COLUMN-LABEL "Алкогольный код"           format "X(25)":U width 25
        f-name(BUFFER x_ext-classif-attr)   COLUMN-LABEL "Наименование товара ЕГАИС" format "X(50)":U width 28
        f-prod(BUFFER x_ext-classif-attr)   COLUMN-LABEL "Производитель"             format "X(150)":U width 27
        f-imp(BUFFER x_ext-classif-attr)    COLUMN-LABEL "Импортёр"                  format "X(150)":U width 27
WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 20.2 FIT-LAST-COLUMN.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-select AT ROW 1.24 COL 2
     b-cancel AT ROW 1.24 COL 18
     br-exts  at row 2.5 col 2
     SPACE(0.5) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выбор алкогольного кода из ЕГАИС"
         DEFAULT-BUTTON b-select CANCEL-BUTTON b-cancel WIDGET-ID 100.


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

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор объекта из ЕГАИС для связки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select Dialog-Frame
ON CHOOSE OF b-select IN FRAME Dialog-Frame /* * */
DO:
    if not available tt-exts then return .
    assign 
        p-rec = tt-exts.ext-rec
    .
END.



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
  { gbl/diasize.i &browse-name=br-exts }
  run diasize_init in this-procedure .
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
  ENABLE b-select b-cancel br-exts 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  br-exts:column-resizable in FRAME Dialog-Frame = true .
  open query br-exts for each tt-exts no-lock where tt-exts.gds-code = p-gds-code,
                         first x_ext-classif no-lock where recid(x_ext-classif) = tt-exts.ext-rec,
                         first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                           and X_ext-classif-attr.attr-code = 'egais-info' .
/*  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

