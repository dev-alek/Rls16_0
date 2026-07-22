&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter iAreaNumber as integer no-undo.


/* Local Variable Definitions ---                                       */

define temp-table ttObjects no-undo
  field fObjType as integer
  field fObjName as character
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttObjects

/* Definitions for BROWSE br-list                                       */
&Scoped-define FIELDS-IN-QUERY-br-list (if ttObjects.fObjType = 1 then "table" else "index") ttObjects.fObjName   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-list   
&Scoped-define SELF-NAME br-list
&Scoped-define QUERY-STRING-br-list FOR EACH ttObjects   where ttObjects.fObjType <= (if viewIndex then 2 else 1)
&Scoped-define OPEN-QUERY-br-list OPEN QUERY {&SELF-NAME} FOR EACH ttObjects   where ttObjects.fObjType <= (if viewIndex then 2 else 1).
&Scoped-define TABLES-IN-QUERY-br-list ttObjects
&Scoped-define FIRST-TABLE-IN-QUERY-br-list ttObjects


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit viewIndex br-list 
&Scoped-Define DISPLAYED-OBJECTS viewIndex 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE viewIndex AS LOGICAL INITIAL no 
     LABEL "показать индексы" 
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-list FOR 
      ttObjects SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-list Dialog-Frame _FREEFORM
  QUERY br-list DISPLAY
      (if ttObjects.fObjType = 1 then "table" else "index") format "X(6)" 
   column-label "Тип объекта"
 ttObjects.fObjName format "X(25)" column-label "Имя объекта"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.4 BY 10.95 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1.48 COL 3 WIDGET-ID 8
     viewIndex AT ROW 1.48 COL 34 WIDGET-ID 6
     br-list AT ROW 2.91 COL 2.6 WIDGET-ID 200
     SPACE(1.19) SKIP(0.75)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Состав области" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-list viewIndex Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-list
/* Query rebuild information for BROWSE br-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttObjects
  where ttObjects.fObjType <= (if viewIndex then 2 else 1).
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-list */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Состав области */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME viewIndex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL viewIndex Dialog-Frame
ON VALUE-CHANGED OF viewIndex IN FRAME Dialog-Frame /* показать индексы */
DO:
  assign {&self-name}.
  
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
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
  
  run getObjects in this-procedure.
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
  DISPLAY viewIndex 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit viewIndex br-list 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getObjects Dialog-Frame 
PROCEDURE getObjects :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define buffer buf_StorageObject for ub._StorageObject.
define buffer buf_file for ub._File.
define buffer buf_index for ub._Index.

define variable vObjName as character no-undo.

for each buf_StorageObject no-lock where
         buf_StorageObject._Area-number = iAreaNumber
:
  vObjName = "".
  case buf_StorageObject._Object-type:
    when 1 then
    do:
      find first buf_file no-lock where
                 buf_file._file-number = buf_StorageObject._Object-number
      no-error.
      if avail buf_file then
        vObjName = buf_file._file-name.     
    end.
    when 2 then
    do:
      find first buf_index no-lock where
                 buf_index._idx-num = buf_StorageObject._Object-number
      no-error.
      if avail buf_index then
        vObjName = buf_index._index-name.     
    end.
  end case.
  
  if vObjName <> "" then
  do:
    create ttObjects.
    assign
      ttObjects.fObjType = buf_StorageObject._Object-type
      ttObjects.fObjName = vObjName
    .
    
  end.    
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

