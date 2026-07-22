&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Глобальные параметры для включения прав

Автор: Белоусов Илья Александрович
Дата создания: 03/28/08
Author: Ilia Belousov
Creation date: 03/28/08

Input:

Output:

*/


/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE BUFFER buf_global-state      FOR ub.global-state .
DEFINE BUFFER buf_global-state-attr FOR ub.global-state-attr .

/* Parameters Definitions ---                                           */
/*define input  parameter parparentproc     as widget-handle no-undo .*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры для включения прав".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help tg-action-gds-groups ~
tg-action-gbl 
&Scoped-Define DISPLAYED-OBJECTS tg-action-gds-groups tg-action-gbl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE tg-action-gbl AS LOGICAL INITIAL no 
     LABEL "Глобальная настройка прав" 
     VIEW-AS TOGGLE-BOX
     SIZE 59 BY .79 NO-UNDO.

DEFINE VARIABLE tg-action-gds-groups AS LOGICAL INITIAL no 
     LABEL "Включить права на работу с группами товаров" 
     VIEW-AS TOGGLE-BOX
     SIZE 59 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     tg-action-gds-groups AT ROW 4.08 COL 4 WIDGET-ID 4
     tg-action-gbl AT ROW 5.5 COL 4 WIDGET-ID 6
     SPACE(2.24) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Включение прав на работу"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Включение прав на работу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
/*    tg-action-goods*/
    tg-action-gds-groups
    tg-action-gbl
  .
  RUN global-save IN THIS-PROCEDURE .
    if tg-action-gbl then do:
    /*Если поставили галку, тогда удаляем все привязки на УБД*/
/*    for each ub.user-login-action-role exclusive-lock where ub.user-login-action-role.db-num <> 0 :*/
/*      delete ub.user-login-action-role .                                                           */
/*    end.                                                                                           */
  end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-action-gbl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-action-gbl Dialog-Frame
ON VALUE-CHANGED OF tg-action-gbl IN FRAME Dialog-Frame /* Глобальная настройка прав */
DO:
  assign tg-action-gbl.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
   RUN global-read IN THIS-PROCEDURE .
   RUN enable_UI.
   run ui-enable in this-procedure.

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
  DISPLAY tg-action-gds-groups tg-action-gbl 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help tg-action-gds-groups tg-action-gbl 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE global-read Dialog-Frame 
PROCEDURE global-read :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   FIND FIRST buf_global-state
        NO-LOCK
        .
/*   FIND FIRST buf_global-state-attr*/
/*      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id*/
/*         AND buf_global-state-attr.attr-code = "action-goods"*/ /* !!! str-glbl */
/*      NO-LOCK*/
/*      NO-error*/
/*      .*/
/*   IF AVAILABLE buf_global-state-attr*/
/*   THEN DO:*/
/*      assign*/
/*         tg-action-goods = LOGICAL(buf_global-state-attr.attr-value)*/
/*      .*/
/*      RELEASE buf_global-state-attr .*/
/*   END.*/

   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gds-groups" /* !!! str-glbl */
      NO-LOCK
      NO-error
      .
   IF AVAILABLE buf_global-state-attr
   THEN DO:
      assign
         tg-action-gds-groups = LOGICAL(buf_global-state-attr.attr-value)
      .
      RELEASE buf_global-state-attr .
   END.

   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gbl"
      NO-LOCK
      NO-error
      .
   IF AVAILABLE buf_global-state-attr
   THEN DO:
      assign
         tg-action-gbl = LOGICAL(buf_global-state-attr.attr-value)
      .
      RELEASE buf_global-state-attr .
   END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE global-save Dialog-Frame 
PROCEDURE global-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

   define variable v-on-gbl as logical no-undo.

/*   FIND FIRST buf_global-state-attr*/
/*      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id*/
/*         AND buf_global-state-attr.attr-code = "action-goods"*/ /* !!! str-glbl */
/*      EXCLUSIVE-LOCK*/
/*      NO-error*/
/*      .*/

/*   IF NOT AVAILABLE buf_global-state-attr*/
/*   THEN DO:*/
/*      create buf_global-state-attr.*/
/*      assign*/
/*         buf_global-state-attr.gls-id = buf_global-state.gls-id*/
/*         buf_global-state-attr.attr-code = "action-goods"*/ /* !!! str-glbl */
/*      .*/
/*   END.*/
/*   assign*/
/*      buf_global-state-attr.attr-value = STRING(tg-action-goods)*/
/*   .*/
/*   RELEASE buf_global-state-attr .*/


   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gds-groups" /* !!! str-glbl */
      EXCLUSIVE-LOCK
      NO-error
      .
   IF NOT AVAILABLE buf_global-state-attr
   THEN DO:
      create buf_global-state-attr.
      assign
         buf_global-state-attr.gls-id = buf_global-state.gls-id
         buf_global-state-attr.attr-code = "action-gds-groups" /* !!! str-glbl */
      .
   END.
   assign
      buf_global-state-attr.attr-value = STRING(tg-action-gds-groups)
   .

   FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gbl"
      EXCLUSIVE-LOCK
      NO-error
      .
   IF NOT AVAILABLE buf_global-state-attr
   THEN DO:
      create buf_global-state-attr.
      assign
         buf_global-state-attr.gls-id = buf_global-state.gls-id
         buf_global-state-attr.attr-code = "action-gbl"
         v-on-gbl = tg-action-gbl
      .
   END.
   ELSE
      v-on-gbl = (not logical(buf_global-state-attr.attr-value)) and tg-action-gbl.

   assign
      buf_global-state-attr.attr-value = STRING(tg-action-gbl)
   .

   if v-on-gbl then
   do:
     for each action-role no-lock
       where action-role.db-num = 0
     :
       run str/callnews.p
         (input {&table_action-role}
         ,input (buffer action-role :handle)
         ).
     end.

     for each action-role-attr no-lock
       where action-role-attr.db-num = 0
     :
       run str/callnews.p
         (input {&table_action-role-attr}
         ,input (buffer action-role-attr :handle)
         ).
     end.

     for each action-role-item no-lock
       where action-role-item.db-num = 0
     :
       run str/callnews.p
         (input {&table_action-role-item}
         ,input (buffer action-role-item :handle)
         ).
     end.

     for each action-role-item-attr no-lock
       where action-role-item-attr.db-num = 0
     :
       run str/callnews.p
         (input {&table_action-role-item-attr}
         ,input (buffer action-role-item-attr :handle)
         ).
     end.
   end.

   RELEASE buf_global-state-attr .
    /* Должен сработать тригер и все уйдет в новости */
   FIND FIRST buf_global-state
        exclusive-LOCK
        .
   if buf_global-state.whole-send-news = 0 then buf_global-state.whole-send-news = 1.
                                            else buf_global-state.whole-send-news = 0.
   RELEASE buf_global-state .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable Dialog-Frame 
PROCEDURE ui-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
  if g#db-num <> 0 then do:
    assign
      tg-action-gbl:sensitive = false
    .
  end.
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

