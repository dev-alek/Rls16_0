&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME copyprep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS copyprep
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подготовка копии БД для выгрузки УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc        as widget-handle no-undo .
define output parameter p-ok as logical no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Подготовка копии БД для выгрузки УБД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ utl/setpwd.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME copyprep

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 b-exit b-quit b-help v-db-copy
&Scoped-Define DISPLAYED-OBJECTS v-db-copy

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

DEFINE VARIABLE v-db-copy AS CHARACTER FORMAT "X(256)":U
     LABEL "Копия БД"
     VIEW-AS FILL-IN
     SIZE 46.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 3.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME copyprep
     b-exit AT ROW 1.17 COL 2
     b-quit AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 52
     v-db-copy AT ROW 4 COL 12 COLON-ALIGNED
     "Параметры соединения:" VIEW-AS TEXT
          SIZE 22 BY .88 AT ROW 2.75 COL 2.88
     RECT-1 AT ROW 2.38 COL 2
     SPACE(0.87) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Подготовка копии БД для выгрузки УБД"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX copyprep
                                                                        */
ASSIGN
       FRAME copyprep:SCROLLABLE       = FALSE
       FRAME copyprep:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME copyprep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL copyprep copyprep
ON WINDOW-CLOSE OF FRAME copyprep /* Подготовка копии БД для выгрузки УБД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit copyprep
ON CHOOSE OF b-exit IN FRAME copyprep /* Ввод */
DO:
  define variable v-pswrd as character no-undo .
  define buffer buf_user-login      for ub.user-login .

  assign
    v-db-copy
  .
  if v-db-copy = "":U then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Нeобходимо указать параметры соединения с копией ГБД!" ) skip
      view-as alert-box error
    .
    apply "entry":U to v-db-copy in frame {&frame-name} .
    return no-apply.
  end.

  if connected( "db-copy":U ) then do:
    disconnect db-copy .
  end.
  define variable vConect as character no-undo.
  vConect = SUBSTITUTE("&1 -ld db-copy -U sysadm -P &2", v-db-copy,"{&paswordold}") .
  connect value(vConect) no-error.

  if not connected ("db-copy":U) then do:
    connect value(v-db-copy) -U odbc -P odbc -ld db-copy no-error.
    if not connected ("db-copy":U) then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не могу соединиться с копией ГБД с параметрами:" ) skip
        substitute( "&1", v-db-copy ) skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не могу соединиться с копией ГБД!" ) skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
    end.
    apply "entry" to v-db-copy in frame {&frame-name} .
    return no-apply.
  end.

  { adm/chk-c-db.i "'prep'":U ? "'ub'" "'db-copy'" no-apply }
  if connected( "db-copy":U ) then do:
    disconnect db-copy .
  end.

  assign
    p-ok = true
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit copyprep
ON CHOOSE OF b-quit IN FRAME copyprep /* Отказ */
DO:
  assign
    p-ok = false
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK copyprep


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  RUN enable_UI.
  assign
    p-ok = false
  .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

if connected( "db-copy":U ) then do:
  disconnect db-copy .
end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI copyprep _DEFAULT-DISABLE
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
  HIDE FRAME copyprep.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI copyprep _DEFAULT-ENABLE
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
  DISPLAY v-db-copy
      WITH FRAME copyprep.
  ENABLE RECT-1 b-exit b-quit b-help v-db-copy
      WITH FRAME copyprep.
  VIEW FRAME copyprep.
  {&OPEN-BROWSERS-IN-QUERY-copyprep}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME