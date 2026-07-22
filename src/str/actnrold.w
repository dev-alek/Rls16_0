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

Редактирование набора прав (роли)

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/
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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование группы прав".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }


/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo .
DEFINE INPUT        PARAMETER p-edit-mode   AS LOGICAL       NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-recid       AS RECID         NO-UNDO.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE v-context           AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-context-name      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-context-list      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-context-list-name AS CHARACTER NO-UNDO INITIAL "Без привязки,Фирма,Объект" .
DEFINE VARIABLE v-db-num            AS INTEGER   NO-UNDO.

DEFINE BUFFER buf_sys-ctrl          FOR sys-ctrl.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-exit b-help v-name v-description ~
c-context
&Scoped-Define DISPLAYED-OBJECTS v-name v-description c-context

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
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE c-context AS CHARACTER FORMAT "X(12)":U INITIAL "Без привязки"
     LABEL "Привязка"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Без привязки","Фирма","Объект"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE v-description AS CHARACTER FORMAT "X(256)":U
     LABEL "Описание"
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 50.57
     v-name AT ROW 2.88 COL 11 COLON-ALIGNED WIDGET-ID 2
     v-description AT ROW 4.19 COL 11 COLON-ALIGNED WIDGET-ID 4
     c-context AT ROW 5.54 COL 11 COLON-ALIGNED WIDGET-ID 8
     SPACE(31.60) SKIP(2.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
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
      v-name
      v-description
      c-context
   .
   RUN name-to-cntxt IN THIS-PROCEDURE ( INPUT  entry(1, c-context)
                                      , OUTPUT v-context
                                      ) NO-ERROR.
   RUN check-role IN THIS-PROCEDURE ( v-name:SCREEN-VALUE ) NO-ERROR.
   IF p-edit-mode THEN DO:
      RUN update-role IN THIS-PROCEDURE NO-ERROR.
   END.
   ELSE DO:
      RUN create-role IN THIS-PROCEDURE NO-ERROR.
   END.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE SKIP
              ERROR-STATUS:GET-MESSAGE(1)
      VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME c-context
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-context Dialog-Frame
ON VALUE-CHANGED OF c-context IN FRAME Dialog-Frame /* Контекст */
DO:
  RUN name-to-cntxt IN THIS-PROCEDURE ( INPUT  entry(1, c-context)
                                      , OUTPUT v-context
                                      ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE RETURN-VALUE SKIP
             ERROR-STATUS:GET-MESSAGE(1)
     VIEW-AS ALERT-BOX.
     UNDO, RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-name Dialog-Frame
ON LEAVE OF v-name IN FRAME Dialog-Frame /* Название */
DO:
    apply "VALUE-CHANGED" TO c-context.
    IF ERROR-STATUS:ERROR THEN DO:
       MESSAGE RETURN-VALUE SKIP
               ERROR-STATUS:GET-MESSAGE(1)
       VIEW-AS ALERT-BOX.
       UNDO, RETURN NO-APPLY.
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

  { gbl/app_help.i }

  v-context-list = {&cntxt-global} + ',' + {&cntxt-firm} + ',' + {&cntxt-object}.
  FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
  IF NOT AVAILABLE buf_sys-ctrl THEN DO:
     RETURN ERROR ERROR-STATUS:GET-MESSAGE(1).
  END.
  ASSIGN
    v-db-num = buf_sys-ctrl.db-num
  .
  RELEASE buf_sys-ctrl.

  IF p-edit-mode THEN DO:
     FIND FIRST action-role WHERE RECID(action-role) = p-recid
                            NO-ERROR
                            NO-WAIT.
     IF LOCKED action-role THEN DO:
        RETURN ERROR "Группа прав сейчас недоступна для правки, попробуйте позже".
     END.
     IF NOT AVAILABLE action-role THEN DO:
        RETURN ERROR SUBSTITUTE("Не найдена группа прав RECID: &1", p-recid ).
     END.
     ASSIGN
        v-name        = action-role.action-role-name
        v-description = action-role.action-role-description
        v-context     = action-role.action-role-context
     .
     RUN cntxt-to-name ( INPUT  v-context
                       , OUTPUT v-context-name
                       ) .
     ASSIGN
        c-context = v-context-name
        FRAME Dialog-Frame:TITLE = "Редактирование группы прав"
     .

  END.
  ELSE DO:
     ASSIGN
        FRAME Dialog-Frame:TITLE = "Создание группы прав"
     .
  END.

  RUN enable_UI.
  /* !!! пока не даем изменить контекст права */
  IF p-edit-mode THEN DO:
      RUN post_enable_UI.
  END.
  APPLY "ENTRY" TO v-name.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-role Dialog-Frame
PROCEDURE check-role :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-name AS CHARACTER NO-UNDO.

DEFINE BUFFER buf_action-role FOR action-role.

IF p-name = "" THEN DO:
   RETURN ERROR "Заполните имя для группы прав" .
END.
IF NOT p-edit-mode THEN DO:
   IF CAN-FIND( FIRST buf_action-role WHERE buf_action-role.db-num              = v-db-num
                                    AND buf_action-role.action-head-code    = {&action-head-code-main}
                                    AND buf_action-role.action-role-name    = p-name
                                    AND buf_action-role.action-role-context = v-context
                                 NO-LOCK
         ) THEN DO:
   RETURN ERROR "Группа прав с таким именем уже существует".
   END.
END.
else do:
   IF CAN-FIND( FIRST buf_action-role WHERE buf_action-role.db-num              = v-db-num
                                    AND buf_action-role.action-head-code    = {&action-head-code-main}
                                    AND buf_action-role.action-role-name    = p-name
                                    AND buf_action-role.action-role-context = v-context
                                    AND RECID(buf_action-role) <> RECID(action-role)
                                 NO-LOCK
         ) THEN DO:
   RETURN ERROR "Группа прав с таким именем уже существует".
   END.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cntxt-to-name Dialog-Frame
PROCEDURE cntxt-to-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAMETER p-context AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-name    AS CHARACTER NO-UNDO.

DEFINE VARIABLE         v-i       AS INTEGER   NO-UNDO.

    DO
    ON ERROR UNDO, RETURN ERROR return-value
    :
       v-i = lookup( p-context, v-context-list, ",":U ) .
       IF v-i <= 0
       OR v-i > NUM-ENTRIES( v-context-list-name )
       THEN DO:
           RETURN ERROR "Неизвестный контекст" .
       END.
       p-name = ENTRY( v-i, v-context-list-name ) .

    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-role Dialog-Frame
PROCEDURE create-role :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    DEFINE VARIABLE v-action-role-code AS INTEGER NO-UNDO.
    DO TRANSACTION
    ON ERROR UNDO, RETURN ERROR RETURN-VALUE
    :
        RUN check-role IN THIS-PROCEDURE ( INPUT v-name ).
        RUN name-to-cntxt IN THIS-PROCEDURE ( INPUT  entry(1, c-context)
                                            , OUTPUT v-context
                                            ).
        ASSIGN
           v-action-role-code = NEXT-VALUE(s-action-role)
        .
        CREATE action-role.
        ASSIGN
           action-role.db-num                   = v-db-num
           action-role.action-head-code         = {&action-head-code-main}
           action-role.action-role-code         = v-action-role-code
           action-role.action-role-context      = v-context
           action-role.action-role-name         = v-name
           action-role.action-role-description  = v-description
        NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
           UNDO, RETURN ERROR SUBSTITUTE("&1, &2", ERROR-STATUS:GET-MESSAGE(1), RETURN-VALUE).
        END.
        p-recid = RECID(action-role).
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
  DISPLAY v-name v-description c-context
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-exit b-help v-name v-description c-context
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE name-to-cntxt Dialog-Frame
PROCEDURE name-to-cntxt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAMETER p-name    AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-context AS CHARACTER NO-UNDO.

DEFINE VARIABLE         v-i       AS INTEGER   NO-UNDO.

    DO
    ON ERROR UNDO, RETURN ERROR RETURN-VALUE
    :
       v-i = lookup( p-name, v-context-list-name, ",":U ) .
       IF v-i <= 0
       OR v-i > NUM-ENTRIES( v-context-list )
       THEN DO:
           RETURN ERROR "Неизвестный контекст" .
       END.
       p-context = ENTRY( v-i, v-context-list ) .

    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI Dialog-Frame
PROCEDURE post_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DISABLE c-context
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-role Dialog-Frame
PROCEDURE update-role :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    DEFINE VARIABLE v-action-role-code AS INTEGER NO-UNDO.
    DO TRANSACTION
    ON ERROR UNDO, RETURN ERROR RETURN-VALUE
    :
        RUN check-role IN THIS-PROCEDURE ( INPUT v-name ).
        FIND CURRENT action-role EXCLUSIVE-LOCK .
        ASSIGN
           /* !!!
           action-role.action-role-context      = v-context
           */
           action-role.action-role-name         = v-name
           action-role.action-role-description  = v-description
        NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
           UNDO, RETURN ERROR SUBSTITUTE("&1, &2", ERROR-STATUS:GET-MESSAGE(1), RETURN-VALUE).
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME