&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование события на кассе

Автор: Комаров Иван Сергеевич
Дата создания: 29/10/09
Author: Ivan Komarov
Creation date: 29/10/09

Input:

Output:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input         parameter parparentproc as widget-handle  no-undo .
define input         parameter p-version     as integer          no-undo.
define input-output  parameter p-id          as integer          no-undo.
define output        parameter p-ok          as logical        no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование события на кассе".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-message    as character    no-undo.
define buffer buf_cd-events      for ub.cd-events .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help v-event-id v-name ~
cb-type v-level ed-description 
&Scoped-Define DISPLAYED-OBJECTS v-event-id v-name cb-type v-level ~
ed-description 

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

DEFINE VARIABLE cb-type AS CHARACTER FORMAT "X(256)":U INITIAL "U" 
     LABEL "Тип" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Запрос пользователя","U",
                     "Реакция системы","S",
                     "Ошибка","E"
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-level AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Уровень" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Низкий",0,
                     "Средний",1,
                     "Высокий",2
     DROP-DOWN-LIST
     SIZE 10.63 BY 1 NO-UNDO.

DEFINE VARIABLE ed-description AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.25 BY 4 TOOLTIP "Описание" NO-UNDO.

DEFINE VARIABLE v-event-id AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Идентификатор" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(30)":U 
     LABEL "Название" 
     VIEW-AS FILL-IN 
     SIZE 42.13 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1.25 COL 49.25
     v-event-id AT ROW 2.5 COL 15.38 COLON-ALIGNED WIDGET-ID 16
     v-name AT ROW 3.92 COL 15.38 COLON-ALIGNED WIDGET-ID 4
     cb-type AT ROW 5.38 COL 32.38 COLON-ALIGNED WIDGET-ID 10
     v-level AT ROW 5.42 COL 15.38 COLON-ALIGNED WIDGET-ID 18
     ed-description AT ROW 6.88 COL 17.25 NO-LABEL WIDGET-ID 12
     "Описание" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7 COL 7.5 WIDGET-ID 14
     SPACE(45.87) SKIP(3.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Событие на кассе"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Событие на кассе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:

   ASSIGN
    v-event-id
    v-name
    v-level
    cb-type
    ed-description
    v-message = "":U
   .
   RUN chk-event IN THIS-PROCEDURE  ( INPUT v-event-id
                                    , OUTPUT v-message
                                    ) .
   IF v-message <> "":U
   THEN DO:
      message
         v-message
         skip
      view-as alert-box information.
      RETURN NO-APPLY .
   END.
   RUN save-event IN THIS-PROCEDURE ( INPUT v-event-id
                                    , INPUT v-name
                                    , INPUT v-level
                                    , INPUT cb-type
                                    , INPUT ed-description
                                    , OUTPUT p-ok
                                    ) NO-ERROR.
   IF NOT p-ok
   OR ERROR-STATUS:ERROR
   THEN DO:
      IF p-id = 0
      THEN DO:
         message
            "Ошибка создания записи"
            skip RETURN-VALUE
            skip ERROR-STATUS:get-message(1)
         view-as alert-box information.
      END.
      ELSE DO:
         message
            "Ошибка изменения записи"
            skip RETURN-VALUE
            skip ERROR-STATUS:get-message(1)
         view-as alert-box information.
      END.
   END.
   ELSE DO:
      ASSIGN
         p-id = v-event-id
      .
   END.
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


&Scoped-define SELF-NAME v-event-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-event-id Dialog-Frame
ON LEAVE OF v-event-id IN FRAME Dialog-Frame /* Идентификатор */
DO:
   ASSIGN
      v-event-id
      v-message = "":U
   .
   RUN chk-event IN THIS-PROCEDURE  ( INPUT v-event-id
                                    , OUTPUT v-message
                                    ) .
   IF v-message <> "":U
   THEN DO:
      message
         v-message
         skip
      view-as alert-box information.
      RETURN NO-APPLY .
   END.
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
   { gbl/app_help.i }

   if p-id <> 0
   THEN DO:
      assign
         v-message = "":U
      .
      RUN init-event in THIS-PROCEDURE ( INPUT p-id
                                       , OUTPUT v-name
                                       , OUTPUT v-level
                                       , OUTPUT cb-type
                                       , OUTPUT ed-description
                                       , OUTPUT v-message
                                       ) .
      IF v-message <> "":U
      THEN DO:
         message
            v-message
            skip
         view-as alert-box information.
         RETURN.
      END.
      ASSIGN
         v-event-id = p-id
      .
   END.
   ELSE DO:
      define buffer bf_cd-events      for ub.cd-events .
      FIND LAST bf_cd-events
           USE-INDEX PI
           NO-LOCK
           .
      ASSIGN
         v-event-id = bf_cd-events.event-id + 1
      .
      RELEASE bf_cd-events.
   END.

   RUN enable_UI.
   IF p-id <> 0
   THEN DISABLE  v-event-id WITH FRAME Dialog-Frame.

   WAIT-FOR GO OF FRAME {&FRAME-NAME} focus v-name.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-event Dialog-Frame 
PROCEDURE chk-event :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-e-id      as integer          no-undo.
define output parameter p-message as character        no-undo.
define buffer bf_cd-events      for ub.cd-events .
   IF CAN-FIND (FIRST bf_cd-events
                WHERE bf_cd-events.event-id = p-e-id
                no-lock
                )
   THEN DO:
      ASSIGN
         p-message = "Уже есть запись с таким идентификатором"
      .
   END.

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
  DISPLAY v-event-id v-name cb-type v-level ed-description 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help v-event-id v-name cb-type v-level ed-description 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-event Dialog-Frame 
PROCEDURE init-event :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-e-id      as integer          no-undo.
define output parameter p-name   as character        no-undo.
define output parameter p-level  as integer          no-undo.
define output parameter p-type   as character        no-undo.
define output parameter p-desc   as character        no-undo.
define output parameter p-message as character        no-undo.
do
TRANSACTION
on error undo, return error
:

   FIND FIRST buf_cd-events
        WHERE buf_cd-events.event-id = p-e-id
        EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF LOCKED buf_cd-events
   THEN DO:
      ASSIGN
         p-message = "Запись редактируется другим пользователем"
      .
      RETURN .
   END.
   ASSIGN
      p-name  = buf_cd-events.event-name
      p-level = buf_cd-events.event-level
      p-type  = buf_cd-events.event-type
      p-desc  = buf_cd-events.event-description
   .
end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-event Dialog-Frame 
PROCEDURE save-event :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-e-id     as integer          no-undo.
define input parameter p-name   as character        no-undo.
define input parameter p-level  as integer          no-undo.
define input parameter p-type   as character        no-undo.
define input parameter p-desc   as character        no-undo.
define output parameter p-ok    as logical          no-undo.

   IF NOT AVAILABLE buf_cd-events
   THEN DO:
      CREATE buf_cd-events.
      ASSIGN
         buf_cd-events.event-id = p-id
      .
   END.

   ASSIGN
      buf_cd-events.event-id          = p-e-id
      buf_cd-events.event-name        = p-name
      buf_cd-events.event-level       = p-level
      buf_cd-events.event-type        = p-type
      buf_cd-events.event-description = p-desc
      p-ok                            = TRUE
   .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

