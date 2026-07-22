&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Задание параметров отчета о ГТД

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define output parameter parcst-code like parts.cst-code no-undo.
define output parameter pardate     as date no-undo.
define output parameter parcst-unit as char no-undo.
define output parameter is-ok as logical no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание параметров отчета о ГТД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-ok b-help varcst-code varDate ~
varcst-unit
&Scoped-Define DISPLAYED-OBJECTS varcst-code varDate varcst-unit

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-GO
     LABEL "Вы&бор "
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varcst-code AS CHARACTER FORMAT "X(256)":U
     LABEL "ГТД"
     VIEW-AS FILL-IN
     SIZE 32 BY 1.13 NO-UNDO.

DEFINE VARIABLE varDate AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1.13 NO-UNDO.

DEFINE VARIABLE varcst-unit AS CHARACTER INITIAL "Таможенная"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Таможенная", "Таможенная",
"Ба&зовая", "Базовая"
     SIZE 22.25 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-cancel AT ROW 1.21 COL 2
     b-ok AT ROW 1.21 COL 12.13
     b-help AT ROW 1.21 COL 22.25
     varcst-code AT ROW 2.54 COL 4.88 COLON-ALIGNED
     varDate AT ROW 2.54 COL 25.75 COLON-ALIGNED
     varcst-unit AT ROW 4.04 COL 19.38 NO-LABEL
     "Единица измерения" VIEW-AS TEXT
          SIZE 17.13 BY 1.04 AT ROW 4.08 COL 1.5
     SPACE(23.61) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры отчета о ГТД"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры отчета о ГТД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отказ */
DO:
  assign is-ok = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame /* Выбор */
DO:
  if input frame {&frame-name} varcst-code = "" or
     input frame {&frame-name} varcst-code = ? then do:
        message "Введите номер ГТД." view-as alert-box error.
        apply "entry" to varcst-code in frame {&frame-name}.
        return no-apply.
  end.
  if input frame {&frame-name} varDate = ? THEN do:
     message "Введите дату на которую будем снимать отчет." view-as alert-box error.
     apply "entry" to vardate in frame {&frame-name}.
     return no-apply.
  end.
  assign pardate     = input frame {&frame-name} vardate
         parcst-code = input frame {&frame-name} varcst-code
         parcst-unit = input frame {&frame-name} varcst-unit
         is-ok = yes NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcst-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcst-code Dialog-Frame
ON return OF varcst-code IN FRAME Dialog-Frame /* ГТД */
DO:
  if input frame {&frame-name} varcst-code <> "" and
     input frame {&frame-name} varcst-code <> ? then apply "entry" to varDate in frame {&frame-name}.
  else message "Введите номер ГТД." view-as alert-box error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcst-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcst-unit Dialog-Frame
ON return OF varcst-unit IN FRAME Dialog-Frame
DO:
  apply "entry" to b-ok in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varDate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varDate Dialog-Frame
ON return OF varDate IN FRAME Dialog-Frame /* Дата */
DO:
  if input frame {&frame-name} varDate <> ? THEN apply "entry" to varcst-unit in frame {&frame-name}.
  else message "Введите дату на которую будем снимать отчет." view-as alert-box error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
{ gbl/app_help.i }

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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS varcst-code.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY varcst-code varDate varcst-unit
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-ok b-help varcst-code varDate varcst-unit
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME