&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

 Атрибуты чека

Автор: Шаланин Сергей Владимирович
Дата создания: 04/02/15
Author: Shalanin Sergey
Creation date: 04/02/15

*/

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-code like ub.chk-doc.doc-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты чека".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }


/* Local Variable Definitions ---                                       */
define  temp-table tt-chk-attr no-undo 
field attr-type as char
field attr-code as char
field attr-value as char 
field attr-num as integer.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-chk-attr

/* Definitions for BROWSE br-attr                                       */
&Scoped-define FIELDS-IN-QUERY-br-attr tt-chk-attr.attr-num tt-chk-attr.attr-code tt-chk-attr.attr-value tt-chk-attr.attr-type   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attr   
&Scoped-define SELF-NAME br-attr
&Scoped-define QUERY-STRING-br-attr FOR EACH tt-chk-attr
&Scoped-define OPEN-QUERY-br-attr OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-attr .
&Scoped-define TABLES-IN-QUERY-br-attr tt-chk-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-attr tt-chk-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit br-attr 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-quit AUTO-GO 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-attr FOR 
      tt-chk-attr SCROLLING.
&ANALYZE-RESUME
/* Browse definitions                                                   */
DEFINE BROWSE br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attr Dialog-Frame _FREEFORM
    QUERY br-attr DISPLAY
    tt-chk-attr.attr-num COLUMN-LABEL "Номер" width 5 FORMAT "999":U
    tt-chk-attr.attr-code COLUMN-LABEL "Код" width 10 FORMAT "X(20)":U
    tt-chk-attr.attr-value COLUMN-LABEL "Значение атрибута" WIDTH 70 FORMAT "X(220)":U    
    tt-chk-attr.attr-type COLUMN-LABEL "Тип" FORMAT "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 102.5 BY 15.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     br-attr AT ROW 2.75 COL 1 WIDGET-ID 200
     SPACE(0.74) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Атрибуты чека"
         DEFAULT-BUTTON b-quit WIDGET-ID 100.


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
/* BROWSE-TAB br-attr b-quit Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-attr:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-attr
/* Query rebuild information for BROWSE br-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-chk-attr .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-attr */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты чека */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  apply "go".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-attr
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
  
  for each chk-gds-attr
        where chk-gds-attr.doc-code = p-code no-lock:
   
        create tt-chk-attr.
       assign
        tt-chk-attr.attr-value = chk-gds-attr.attr-value
        tt-chk-attr.attr-code = chk-gds-attr.attr-code     
        tt-chk-attr.attr-num = chk-gds-attr.line-num         
        tt-chk-attr.attr-type = "Товар".
   end.
  
            for each chk-pay-attr
                where chk-pay-attr.doc-code = p-code no-lock:
  
                create tt-chk-attr.
                assign
                tt-chk-attr.attr-value = chk-pay-attr.attr-value
                tt-chk-attr.attr-code = chk-pay-attr.attr-code      
                tt-chk-attr.attr-num = chk-pay-attr.line-num        
                tt-chk-attr.attr-type = "Оплата".
            end.
            
        for each chk-doc-attr
                where chk-doc-attr.doc-code = p-code no-lock:
        if chk-doc-attr.attr-code begins "corr-" then next.          
                create tt-chk-attr.
                assign
                tt-chk-attr.attr-value = chk-doc-attr.attr-value
                tt-chk-attr.attr-code = chk-doc-attr.attr-code    
                tt-chk-attr.attr-type = "Чек".
                
        end.
  
    for each chk-discnt-attr where chk-discnt-attr.doc-code = p-code no-lock:
    if chk-discnt-attr.attr-code = "promo-id" and chk-discnt-attr.line-num = 0 then next .
                create tt-chk-attr.
                assign
                tt-chk-attr.attr-value = chk-discnt-attr.attr-value
                tt-chk-attr.attr-code = chk-discnt-attr.attr-code    
                tt-chk-attr.attr-num = chk-discnt-attr.line-num   
                tt-chk-attr.attr-type = "Скидка".

      end.
    
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cd-attr Dialog-Frame 
PROCEDURE cd-attr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
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
  ENABLE b-quit br-attr 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

