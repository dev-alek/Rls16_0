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

Добавление  ТРК-пистолет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/28/07
Author: Dmitry Ukhanov
Creation date: 08/28/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as   handle              no-undo .
define input  parameter parobj-type   like ub.clients.obj-type no-undo.
define input  parameter parobj-code   like ub.clients.obj-code no-undo.
define output parameter parrec-id     as   recid initial ?     no-undo.

&GLOBAL-DEFINE defined_parparentproc yes

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог на добавление пистолета ТРК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ str/pumpnzav.i   }
define variable is-ef-chr as character no-undo .
define variable var-type as character no-undo .
define variable is-ef as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-cancel b-help varpump-code b-pump ~
varnozzle-code b-nozzle varis-meas varef-nid
&Scoped-Define DISPLAYED-OBJECTS varpump-code varnozzle-code varis-meas ~
varef-nid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-nozzle
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-nozzle"
     SIZE 3 BY .87.

DEFINE BUTTON b-pump
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .87.

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varef-nid AS CHARACTER FORMAT "X(256)":U
     LABEL "Идентиф. EasyFuel"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE varnozzle-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер пистолета ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE varpump-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE varis-meas AS LOGICAL INITIAL yes
     LABEL "Измеряется"
     VIEW-AS TOGGLE-BOX
     SIZE 23.9 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varpump-code AT ROW 2.63 COL 22.1 COLON-ALIGNED
     b-pump AT ROW 2.67 COL 27.8
     varnozzle-code AT ROW 4.2 COL 3.1
     b-nozzle AT ROW 4.2 COL 27.8
     varis-meas AT ROW 5.57 COL 3.5
     varef-nid AT ROW 6.87 COL 18 COLON-ALIGNED WIDGET-ID 2
     SPACE(4.29) SKIP(0.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление  ТРК-пистолет"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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

/* SETTINGS FOR FILL-IN varnozzle-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление  ТРК-пистолет */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-nozzle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-nozzle Dialog-Frame
ON CHOOSE OF b-nozzle IN FRAME Dialog-Frame /* b-nozzle */
DO:
  { str/ptrlv.i "refnozzle"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pump
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pump Dialog-Frame
ON CHOOSE OF b-pump IN FRAME Dialog-Frame
DO:
  { str/ptrlv.i "refpump"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
  assign frame {&frame-name} varpump-code varnozzle-code varis-meas.
  if is-ef then do:
  assign
  varef-nid.
  end.
  run pumpnzav in this-procedure ( input parobj-type
                                   ,input parobj-code
                                   ,input varpump-code
                                   ,input varnozzle-code
                                   ,input varis-meas
                                   ,input varef-nid
                      ) no-error.
  if error-status:error then do:
     { str/errmes.i "Ошибка при создании записи ТРК-пистолет"}
     return no-apply.
  end.
  find first ub.pump-nozzle where ub.pump-nozzle.obj-type    = parobj-type    and
                               ub.pump-nozzle.obj-code    = parobj-code    and
                               ub.pump-nozzle.pump-code   = varpump-code   and
                               ub.pump-nozzle.nozzle-code = varnozzle-code no-lock.
  assign parrec-id = recid(ub.pump-nozzle).
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
  /*проверим конф параметр is-ef*/
  { gbl/conf-rd.i
  "'is-ef'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  is-ef-chr
  var-type
  no-error
  }
  if NOT error-status:error
  and logical(is-ef-chr) = yes then do:
    is-ef = YES.
  end.
  RUN enable_UI.
  IF NOT is-ef THEN DO:
    HIDE
    varef-nid IN frame {&FRAME-NAME}.
  END.

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
  DISPLAY varpump-code varnozzle-code varis-meas varef-nid
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help varpump-code b-pump varnozzle-code b-nozzle
         varis-meas varef-nid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME