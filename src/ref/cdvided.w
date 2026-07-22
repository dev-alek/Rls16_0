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

Редактирование связки собятия на кассе с СВ

Автор: Белоусов Илья Александрович
Дата создания: 12/05/08
Author: Ilia Belousov
Creation date: 12/05/08

Input:

Output:


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input         parameter parparentproc as widget-handle  no-undo .
define INPUT-OUTPUT  parameter p-id          as integer        no-undo .
define input-OUTPUT  parameter p-video-id    as character      no-undo .
define input-OUTPUT  parameter p-system-id   as character      no-undo .
define output        parameter p-ok          as logical        no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование связки события на кассе с СВ".

DEFINE BUFFER buf_cd-events FOR ub.cd-events . 
DEFINE BUFFER  buf_cd-video-link FOR ub.cd-video-link .

DEFINE VARIABLE v-message AS CHARACTER NO-UNDO.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-add b-quit b-help cb-system v-event-id ~
b-select-event v-video-id 
&Scoped-Define DISPLAYED-OBJECTS cb-system v-event-id v-video-id 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add AUTO-GO 
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

DEFINE BUTTON b-select-event 
     LABEL "Button 1" 
     SIZE 3 BY 1 TOOLTIP "Выбор события на кассе из справочника".

DEFINE VARIABLE cb-system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Система" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Призма","Интеллект" 
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-event-id AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Событие на кассе" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE v-video-id AS CHARACTER FORMAT "X(256)":U 
     LABEL "Событие в СВ" 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-add AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 52.88
     cb-system AT ROW 2.75 COL 14.88 COLON-ALIGNED WIDGET-ID 4
     v-event-id AT ROW 2.75 COL 49.75 COLON-ALIGNED WIDGET-ID 6
     b-select-event AT ROW 2.75 COL 59.88 WIDGET-ID 8
     v-video-id AT ROW 4.08 COL 14.88 COLON-ALIGNED WIDGET-ID 2
     SPACE(2.24) SKIP(0.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Связь события на кассе с СВ"
         DEFAULT-BUTTON b-add CANCEL-BUTTON b-quit WIDGET-ID 100.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Связь события на кассе с СВ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Ввод */
DO:

   ASSIGN
    v-video-id
    v-event-id
    cb-system
    v-message = "":U
   .
   RUN chk-link IN THIS-PROCEDURE  (  INPUT  cb-system
                                    , INPUT  v-event-id
                                    , INPUT  v-video-id
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
   RUN save-link IN THIS-PROCEDURE (  INPUT  cb-system
                                    , INPUT  v-event-id
                                    , INPUT  v-video-id
                                    , OUTPUT p-ok
                                    ) NO-ERROR.
   IF NOT p-ok
   OR ERROR-STATUS:ERROR
   THEN DO:
      IF p-id = 0 AND p-video-id = "" AND p-system-id = ""
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
         p-video-id = v-video-id
         p-system-id = cb-system
          .
     END.
/*    ASSIGN                           */
/*     v-video-id                      */
/*     v-event-id                      */
/*     cb-system                       */
/*    .                                */
/*    RUN chk-link IN THIS-PROCEDURE.  */
/*    RUN save-link IN THIS-PROCEDURE. */
/*     ASSIGN                          */
/*       p-ok = TRUE                   */
/*    .                                */
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


&Scoped-define SELF-NAME b-select-event
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select-event Dialog-Frame
ON CHOOSE OF b-select-event IN FRAME Dialog-Frame /* Button 1 */
DO:
   define variable v-rid as CHARACTER no-undo .

   run ref/cd-event.w ( INPUT parparentproc
                      , INPUT "b-sel":U
                      , INPUT-OUTPUT v-rid
                      , OUTPUT p-ok
                      ) .
    IF p-ok THEN DO:
    FIND FIRST buf_cd-events WHERE RECID(buf_cd-events) = integer(v-rid)
        NO-ERROR
        .
    ASSIGN
    v-event-id = (buf_cd-events.event-id)
    .
    DISPLAY v-event-id WITH FRAME dialog-frame.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-system Dialog-Frame
ON VALUE-CHANGED OF cb-system IN FRAME Dialog-Frame /* Система */
DO:
ASSIGN
    cb-system
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-event-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-event-id Dialog-Frame
ON LEAVE OF v-event-id IN FRAME Dialog-Frame /* Событие на кассе */
DO:
   ASSIGN
    v-event-id
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-video-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-video-id Dialog-Frame
ON LEAVE OF v-video-id IN FRAME Dialog-Frame /* Событие в СВ */
DO:
   ASSIGN
    v-video-id
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

   { gbl/getcntxt.i get }
   { gbl/app_help.i }

   if p-id <> 0 AND  p-video-id NE "" AND  p-system-id NE ""
   THEN DO:
      assign
         v-message = "":U
      .
      RUN init-link  in THIS-PROCEDURE ( INPUT  p-system-id
                                       , INPUT p-id
                                       , INPUT p-video-id
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
         v-video-id = p-video-id
         p-system-id = p-system-id
      .
   END.
   ELSE DO:
/*         FIND LAST buf_cd-video-link                    */
/*            USE-INDEX PI                                */
/*            NO-LOCK                                     */
/*            .                                           */
/*       ASSIGN                                           */
/*          v-event-id = buf_cd-video-link.event-id       */
/*          v-video-id = buf_cd-video-link.video-event-id */
/*          cb-system = buf_cd-video-link.video-id        */
/*       .                                                */
/*       RELEASE buf_cd-video-link.                       */
    END.                                                

   RUN enable_UI.
/*    IF p-id <> 0                                      */
/*    THEN DISABLE  v-event-id WITH FRAME Dialog-Frame. */

   WAIT-FOR GO OF FRAME {&FRAME-NAME} focus cb-system.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-link Dialog-Frame 
PROCEDURE chk-link :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-s-id      as CHARACTER           no-undo.
define input parameter p-e-id      as integer        no-undo.
define input parameter p-v-id      as CHARACTER       no-undo.
define output parameter p-message  as character        no-undo.

define buffer buf_cd-video-link for ub.cd-video-link .
   IF CAN-FIND (FIRST buf_cd-video-link
                WHERE buf_cd-video-link.video-id = p-s-id
                AND buf_cd-video-link.event-id = p-e-id
                AND buf_cd-video-link.video-event-id = p-v-id
                no-lock
                )
   THEN DO:
      ASSIGN
         p-message = "Уже есть такая связка"
      .
   END.
/* IF cb-system = "" OR v-video-id = "" OR v-event-id = 0 THEN DO: */
/*     MESSAGE "Не все поля заполнены" VIEW-AS alert-box.          */
/* END.                                                            */
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
  DISPLAY cb-system v-event-id v-video-id 
      WITH FRAME Dialog-Frame.
  ENABLE b-add b-quit b-help cb-system v-event-id b-select-event v-video-id 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-link Dialog-Frame 
PROCEDURE init-link :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter p-s-id      as CHARACTER           no-undo.
define input parameter p-e-id      as integer        no-undo.
define input parameter p-v-id      as CHARACTER       no-undo.
define output parameter p-message  as character        no-undo.
do
TRANSACTION
on error undo, return error
:

   FIND FIRST buf_cd-video-link
        WHERE buf_cd-video-link.event-id = p-e-id 
        AND buf_cd-video-link.video-id = p-s-id 
        AND buf_cd-video-link.video-event-id = p-v-id
        EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF LOCKED buf_cd-video-link
   THEN DO:
      ASSIGN
         p-message = "Запись редактируется другим пользователем"
      .
      RETURN .
   END.
   ASSIGN
      cb-system  = buf_cd-video-link.video-id
      v-event-id = buf_cd-video-link.event-id
      v-video-id = buf_cd-video-link.video-event-id
   .            
end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-link Dialog-Frame 
PROCEDURE save-link :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define INPUT  parameter p-s-id  as CHARACTER      no-undo.
define INPUT  parameter p-e-id  as integer        no-undo.
define INPUT  parameter p-v-id  as CHARACTER      no-undo.
define output parameter p-ok    as logical        no-undo.

   IF NOT AVAILABLE buf_cd-video-link
   THEN DO:
      CREATE buf_cd-video-link.
      ASSIGN
          buf_cd-video-link.video-id       = p-s-id
          buf_cd-video-link.event-id       = p-e-id
          buf_cd-video-link.video-event-id = p-v-id
          .
   END.

   ASSIGN
          buf_cd-video-link.video-id       = p-s-id
          buf_cd-video-link.event-id       = p-e-id
          buf_cd-video-link.video-event-id = p-v-id
          p-ok                             = TRUE
   .
   END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

