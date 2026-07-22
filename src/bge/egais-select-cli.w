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

define input parameter p-inn         as character no-undo .
define input parameter p-kpp         as character no-undo .
define input parameter bh-objs-egais as handle no-undo .

define output parameter p-regID     as character no-undo .


/* Local Variable Definitions ---                                       */

define variable qh-objs-egais as handle no-undo .
define variable br-hndl-objs  as handle no-undo .

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


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-select AT ROW 1.24 COL 2
     b-cancel AT ROW 1.24 COL 18
     SPACE(76) SKIP(10.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Выбор объекта из ЕГАИС для связки"
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
    if not bh-objs-egais:available then return .
    assign 
        p-regID = bh-objs-egais:buffer-field ("regID"):buffer-value
        bh-objs-egais:buffer-field ("connected_"):buffer-value = true
    .
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
  run create-br .
  { gbl/diasize.i &br-hndl=br-hndl-objs }
  run diasize_init in this-procedure .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-br Dialog-Frame  
PROCEDURE create-br :
    if not valid-handle(bh-objs-egais) then do :
        message "Неверная ссылка на буффер ЕГАИС" view-as alert-box .
        return error .
    end.
    
    create query qh-objs-egais .
    qh-objs-egais:set-buffers(bh-objs-egais).
    qh-objs-egais:query-prepare (substitute("for each tt-objs-eg where not tt-objs-EG.connected_ and tt-objs-EG.inn = '&1' and tt-objs-EG.kpp = '&2'", trim(p-inn), trim(p-kpp)) ).
    qh-objs-egais:query-open .
    
    create browse br-hndl-objs
        assign
            frame       = frame {&FRAME-NAME}:handle
            query       = qh-objs-egais
            x           = 10
            y           = 40
            width       = 106
            height      = 10
            visible     = true
            read-only   = false
            sensitive   = true
            separators  = true 
            column-resizable = true
/*            resizable   = true*/
    .
    v-diasize-browse-handle = br-hndl-objs.
    
    br-hndl-objs:add-like-column ("tt-objs-eg.regID") .    
    br-hndl-objs:add-like-column ("tt-objs-eg.obj-name-egais") .
    br-hndl-objs:add-like-column ("tt-objs-eg.inn") .
    br-hndl-objs:add-like-column ("tt-objs-eg.kpp") .
    br-hndl-objs:add-like-column ("tt-objs-eg.country") .
    br-hndl-objs:add-like-column ("tt-objs-eg.regionCode") .
    br-hndl-objs:add-like-column ("tt-objs-eg.description_") .
     
    br-hndl-objs:get-browse-column (1):width-chars = 21.
    br-hndl-objs:get-browse-column (2):width-chars = 50. 
    br-hndl-objs:get-browse-column (3):width-chars = 12.
    br-hndl-objs:get-browse-column (4):width-chars = 9.
    br-hndl-objs:get-browse-column (5):width-chars = 10.
    br-hndl-objs:get-browse-column (6):width-chars = 11.  
    br-hndl-objs:get-browse-column (7):width-chars = 79.
/*    br-hndl-objs:get-browse-column (1):label = "Регистрационный номер".*/
/*    br-hndl-objs:get-browse-column (2):label = "Адрес".                */

    if qh-objs-egais:num-results > 0 then br-hndl-objs:refresh().
    br-hndl-objs:expandable = true.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  ENABLE b-select b-cancel 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
/*  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

