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
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Управление расписанием сообщений" .
{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/str-glbl.i }


define buffer buf_clients for ub.clients .
define buffer buf2_clients for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok b-cancel f-water f-level rs-obj 
&Scoped-Define DISPLAYED-OBJECTS f-water f-level rs-obj 

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

DEFINE VARIABLE f-level AS integer FORMAT ">>9":U 
     LABEL "Сообщения по превышению уровня повторять каждые" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-water AS integer FORMAT ">>9":U 
     LABEL "Сообщения по воде повторять каждые" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE rs-obj AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Текущий объект", 1,
"По фирме", 2
     SIZE 36 BY 1.1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 3
     b-cancel AT ROW 1.24 COL 17.8
     f-water AT ROW 3.14 COL 58 COLON-ALIGNED WIDGET-ID 2
     f-level AT ROW 4.57 COL 58 COLON-ALIGNED WIDGET-ID 6
     rs-obj AT ROW 6.48 COL 35 NO-LABEL WIDGET-ID 10
     "Установить на:" VIEW-AS TEXT
          SIZE 17 BY .62 AT ROW 6.67 COL 15.8 WIDGET-ID 14
     "мин." VIEW-AS TEXT
          SIZE 6 BY .62 AT ROW 3.33 COL 70.6 WIDGET-ID 4
     "мин." VIEW-AS TEXT
          SIZE 6 BY .62 AT ROW 4.81 COL 70.6 WIDGET-ID 8
     SPACE(1.39) SKIP(2.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Управление расписанием сообщений"
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
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Управление расписанием сообщений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame 
DO:
  assign
    f-water
    f-level
    rs-obj
  .
  case rs-obj :
    when 1
    then do :
      run save-obj (input p-obj-type,
                    input p-obj-code)
                    .
      run trg/userlog.p (
              input 'atd-alarm-sched'
            , input ("Период алармов с АТД на объекте " + 
                    buf_clients.obj-type + string(buf_clients.obj-code) + 
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) +
                    {&delim-key} + 
                    buf_clients.obj-type + string(buf_clients.obj-code) + 
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.              
    end .
    when 2
    then do :
      for each buf2_clients no-lock where buf2_clients.host-code = buf_clients.host-code :
        run save-obj (input buf2_clients.obj-type,
                      input buf2_clients.obj-code)
                      .
      end .
      run trg/userlog.p (
              input 'atd-alarm-sched'
            , input ("Период алармов с АТД по фирме орг" + 
                    string(buf_clients.host-code) + 
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) +
                    {&delim-key} + 
                    "орг" + string(buf_clients.host-code) + 
                    substitute("; вода: &1мин; уровень: &2мин", f-water, f-level) )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
    end .
  end case .
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
  find first buf_clients no-lock where buf_clients.obj-type = p-obj-type
                                   and buf_clients.obj-code = p-obj-code
                                   .
  for first buf_clients-attr no-lock where buf_clients-attr.obj-type = buf_clients.obj-type
                                       and buf_clients-attr.obj-code = buf_clients.obj-code
                                       and buf_clients-attr.attr-code = {&attr-atd-alarm-schedule}
                                       and buf_clients-attr.attr-value > ""
                                       :
    if num-entries(buf_clients-attr.attr-value) = 2
    then do :
      f-water = integer(entry(1, buf_clients-attr.attr-value)) .
      f-level = integer(entry(2, buf_clients-attr.attr-value)) .
    end .                                     
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure save-obj :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  
  find first buf_clients-attr exclusive-lock where buf_clients-attr.obj-type = p-obj-type
                                               and buf_clients-attr.obj-code = p-obj-code
                                               and buf_clients-attr.attr-code = {&attr-atd-alarm-schedule}
                                               no-error .
  if not available buf_clients-attr
  then do :
    create buf_clients-attr .
    assign
      buf_clients-attr.obj-type = p-obj-type                 
      buf_clients-attr.obj-code = p-obj-code                 
      buf_clients-attr.attr-code = {&attr-atd-alarm-schedule}
    .
  end.
  assign
    buf_clients-attr.attr-value = string(f-water) + "," + string(f-level)
  .
end procedure .

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
  DISPLAY f-water f-level rs-obj 
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel f-water f-level rs-obj 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

