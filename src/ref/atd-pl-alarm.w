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
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pl-rowid as rowid no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отключение повторных сообщений АТД" .
{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/str-glbl.i }
{ str/placelib.i }
{ gbl/getcntxt.i def }

define variable v-attr-shift-date   as date     no-undo .
define variable v-attr-shift-num    as integer  no-undo .

define buffer buf_clients for ub.clients .
define buffer buf_place for ub.place .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_shift-obj for ub.shift-obj .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok b-cancel t-water t-level 
&Scoped-Define DISPLAYED-OBJECTS t-water t-level 

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

DEFINE BUTTON b-ok AUTO-GO 
     LABEL "Ввод" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE t-level AS LOGICAL INITIAL no 
     LABEL "Отключить сообщения о переполнении" 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .81 NO-UNDO.

DEFINE VARIABLE t-water AS LOGICAL INITIAL no 
     LABEL "Отключить сообщения по воде" 
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.38 COL 2
     b-cancel AT ROW 1.38 COL 16.8
     t-water AT ROW 3.14 COL 2.2 WIDGET-ID 2
     t-level AT ROW 4.38 COL 2.2 WIDGET-ID 4
     SPACE(3.79) SKIP(0.75)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Отключение повторных сообщений"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.


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
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отключение повторных сообщений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame 
DO:
  define variable t-water-chr as character no-undo .
  define variable t-level-chr as character no-undo .
  
  assign
    t-water
    t-level
  .
  
  if t-water
  then t-water-chr = "disable" .
  else t-water-chr = "enable" .
  
  if t-level
  then t-level-chr = "disable" .
  else t-level-chr = "enable" .
  
  find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = {&disable-water-alarm}
                                             and buf_place-attr.obj-code    = buf_place.obj-code
                                             and buf_place-attr.obj-type    = buf_place.obj-type
                                             and buf_place-attr.pl-code     = buf_place.pl-code
                                             no-error .
  if not available buf_place-attr
  then do :
    create buf_place-attr .
    assign
      buf_place-attr.attr-code   = {&disable-water-alarm}
      buf_place-attr.obj-code    = buf_place.obj-code    
      buf_place-attr.obj-type    = buf_place.obj-type    
      buf_place-attr.pl-code     = buf_place.pl-code   
    .  
  end .
  assign
    buf_place-attr.attr-value = t-water-chr + {&delim-par} + string(buf_shift-obj.shift-date) + {&delim-par} + string(buf_shift-obj.shift-num)
  . 
  if v-cntxt-db-num = 0
  then do :
    run nws/cr-route.p ( input {&send-cmd}
                        ,input "command":U + {&delim-nws} +
                               "place-attr":U + {&delim-nws} +
                               buf_place-attr.obj-type + {&delim-nws} + 
                               string(buf_place-attr.obj-code) + {&delim-nws} +
                               string(buf_place-attr.pl-code) + {&delim-nws} +
                               buf_place-attr.attr-code + {&delim-nws} +
                               buf_place-attr.attr-value
                        ,input ?
                        ,input string(buf_clients.db-num)
                       ).
  end .
  
  find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = {&disable-level-alarm}
                                             and buf_place-attr.obj-code    = buf_place.obj-code
                                             and buf_place-attr.obj-type    = buf_place.obj-type
                                             and buf_place-attr.pl-code     = buf_place.pl-code
                                             no-error .
  if not available buf_place-attr
  then do :
    create buf_place-attr .
    assign
      buf_place-attr.attr-code   = {&disable-level-alarm}
      buf_place-attr.obj-code    = buf_place.obj-code    
      buf_place-attr.obj-type    = buf_place.obj-type    
      buf_place-attr.pl-code     = buf_place.pl-code   
    .  
  end .
  assign
    buf_place-attr.attr-value = t-level-chr + {&delim-par} + string(buf_shift-obj.shift-date) + {&delim-par} + string(buf_shift-obj.shift-num)
  .
  if v-cntxt-db-num = 0
  then do :
    run nws/cr-route.p ( input {&send-cmd}
                        ,input "command":U + {&delim-nws} +
                               "place-attr":U + {&delim-nws} +
                               buf_place-attr.obj-type + {&delim-nws} + 
                               string(buf_place-attr.obj-code) + {&delim-nws} +
                               string(buf_place-attr.pl-code) + {&delim-nws} +
                               buf_place-attr.attr-code + {&delim-nws} +
                               buf_place-attr.attr-value
                        ,input ?
                        ,input string(buf_clients.db-num)
                       ).
  end .                         
  
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
  { gbl/getcntxt.i get }
  find first buf_clients no-lock where buf_clients.obj-type = p-obj-type
                                   and buf_clients.obj-code = p-obj-code   
                                   .
  find first buf_shift-obj where buf_shift-obj.obj-type = p-obj-type
                             and buf_shift-obj.obj-code = p-obj-code
                             and buf_shift-obj.status_ = {&sht-current}
                             use-index stts no-lock no-error .
  if not available buf_shift-obj
  then do :
    message "Нет открытой смены на объекте!" view-as alert-box warning .
    return .
  end .
  find first buf_place no-lock where rowid(buf_place) = p-pl-rowid .
  for first buf_place-attr no-lock where buf_place-attr.attr-code   = {&disable-level-alarm}
                                     and buf_place-attr.obj-code    = buf_place.obj-code
                                     and buf_place-attr.obj-type    = buf_place.obj-type
                                     and buf_place-attr.pl-code     = buf_place.pl-code
                                     :
    if num-entries(buf_place-attr.attr-value, {&delim-par}) = 3
    then do :
      v-attr-shift-date = date(entry(2, buf_place-attr.attr-value, {&delim-par})) .
      v-attr-shift-num = integer(entry(3, buf_place-attr.attr-value, {&delim-par})) .
      if v-attr-shift-date = buf_shift-obj.shift-date
      and v-attr-shift-num = buf_shift-obj.shift-num
      and entry(1, buf_place-attr.attr-value, {&delim-par}) = "disable"
      then do :
        t-level = yes .
      end .
    end .                                  
  end .
  for first buf_place-attr no-lock where buf_place-attr.attr-code   = {&disable-water-alarm}
                                     and buf_place-attr.obj-code    = buf_place.obj-code
                                     and buf_place-attr.obj-type    = buf_place.obj-type
                                     and buf_place-attr.pl-code     = buf_place.pl-code
                                     :
    if num-entries(buf_place-attr.attr-value, {&delim-par}) = 3
    then do :
      v-attr-shift-date = date(entry(2, buf_place-attr.attr-value, {&delim-par})) .
      v-attr-shift-num = integer(entry(3, buf_place-attr.attr-value, {&delim-par})) .
      if v-attr-shift-date = buf_shift-obj.shift-date
      and v-attr-shift-num = buf_shift-obj.shift-num
      and entry(1, buf_place-attr.attr-value, {&delim-par}) = "disable"
      then do :
        t-water = yes .
      end .
    end .                                  
  end .
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
  DISPLAY t-water t-level 
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel t-water t-level 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

