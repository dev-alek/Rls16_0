&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision: $
$Author$
$Date: $
$Workfile$
$Archive$

Утилита пересчета остатков МЦ для одного выбранного объекта

Автор: Гридчина Полина Дмитриевна
Дата создания: 01/11/09
Author: Polina Gridchina
Creation date: 01/11/09


*/
define input parameter parparentproc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита пересчета остатков МЦ для одного выбранного объекта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/library.i  }
def buffer buf_clients for ub.clients.
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

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Help v-obj-type v-obj-code B-cli Btn_OK ~
Btn_Cancel for-object
&Scoped-Define DISPLAYED-OBJECTS v-obj-type v-obj-code for-object

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE v-obj-type AS CHARACTER FORMAT "X(3)"
     LABEL "Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6.38 BY 1.

DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-obj-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1.25 COL 61.5
     v-obj-type AT ROW 2.5 COL 13.5 COLON-ALIGNED WIDGET-ID 8
     v-obj-code AT ROW 2.5 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     B-cli AT ROW 2.5 COL 33 WIDGET-ID 4
     Btn_OK AT ROW 4.25 COL 18
     Btn_Cancel AT ROW 4.25 COL 35.5
     for-object AT ROW 2.5 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     SPACE(9.62) SKIP(2.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита пересчета остатков МЦ"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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
ON GO OF FRAME Dialog-Frame /* Утилита пересчета остатков МЦ */
DO:
  assign frame {&FRAME-NAME} v-obj-type
                           v-obj-code.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = v-obj-type AND
          buf_clients.obj-code = v-obj-code NO-ERROR.

IF AVAIL buf_clients THEN DO:
  run utl/reclcwth.p (buf_clients.obj-type, buf_clients.obj-code) no-error.
    if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете объекта" skip
    buf_clients.obj-type buf_clients.obj-code.
    end.
END.
ELSE DO:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден объект для пересчета" skip.
END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Утилита пересчета остатков МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
 define variable v_rid as character no-undo.
 define variable ref-rec as recid no-undo .

   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = INPUT FRAME {&FRAME-NAME} v-obj-type AND
            buf_clients.obj-code = INPUT FRAME {&FRAME-NAME} v-obj-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                 input parparentproc
               ,input "b-sel":U
               ,input v-obj-type
               ,input {&all}
               ,input {&all}
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).

  END.
  ELSE DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-obj-type
               ,input {&all}
               ,input {&current}
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
    assign
    v-obj-type =  buf_clients.obj-type
    v-obj-code =  buf_clients.obj-code
    for-object =  buf_clients.obj-name
    .
      DISPLAY
      v-obj-type
      v-obj-code
      for-object
      WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.  /*v_rid <> ""*/
  ELSE DO:
    RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-obj-code Dialog-Frame
ON LEAVE OF v-obj-code IN FRAME Dialog-Frame
DO:
  assign frame {&FRAME-NAME} v-obj-type
                           v-obj-code.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = v-obj-type AND
          buf_clients.obj-code = v-obj-code NO-ERROR.



IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ for-object WITH FRAME {&FRAME-NAME}.
END.
ELSE DO:
    DISPLAY
    "":U @ for-object WITH FRAME {&FRAME-NAME}.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-obj-type Dialog-Frame
ON VALUE-CHANGED OF v-obj-type IN FRAME Dialog-Frame /* Объект */
DO:
assign frame {&FRAME-NAME} v-obj-type
                           v-obj-code.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = v-obj-type AND
          buf_clients.obj-code = v-obj-code NO-ERROR.



IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ for-object WITH FRAME {&FRAME-NAME}.
END.
ELSE DO:
    DISPLAY
    "":U @ for-object WITH FRAME {&FRAME-NAME}.
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

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
       v-obj-type:list-items =     {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.

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
  DISPLAY v-obj-type v-obj-code for-object
      WITH FRAME Dialog-Frame.
  ENABLE B-Help v-obj-type v-obj-code B-cli Btn_OK Btn_Cancel for-object
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME