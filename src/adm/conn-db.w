&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-get-conn-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-get-conn-par
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

подключение к  БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/16/08
Author: Dmitry Ukhanov
Creation date: 12/16/08


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-title-par as character no-undo .
define input  parameter p-conn-par  as character no-undo .
define input  parameter p-user-name as character no-undo .
define input  parameter p-user-pswd as character no-undo .
define input  parameter p-ld-name   as character no-undo .
define output parameter p-new-conn  as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "создание УБД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ utl/setpwd.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-get-conn-par

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help v-conn-par
&Scoped-Define DISPLAYED-OBJECTS v-conn-par v-title-par

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE VARIABLE v-conn-par AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 86.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-title-par AS CHARACTER FORMAT "X(256)":U INITIAL "Параметры подключения к БД"
      VIEW-AS TEXT
     SIZE 86.5 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-get-conn-par
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 87
     v-conn-par AT ROW 4 COL 3.5 NO-LABEL
     v-title-par AT ROW 2.75 COL 1.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     SPACE(0.87) SKIP(2.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод параметров подключения к БД":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-get-conn-par
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-get-conn-par:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN v-conn-par IN FRAME d-get-conn-par
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-title-par IN FRAME d-get-conn-par
   NO-ENABLE                                                            */
ASSIGN
       v-title-par:READ-ONLY IN FRAME d-get-conn-par        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-get-conn-par
/* Query rebuild information for DIALOG-BOX d-get-conn-par
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-get-conn-par */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-get-conn-par
ON CHOOSE OF b-exit IN FRAME d-get-conn-par /* Ввод */
DO:

  define variable v-user-pswd-enc as character no-undo .
  define variable v-tmp-conn      as character no-undo .

  assign
    v-conn-par
  .
  if v-conn-par = "":U then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Нeобходимо указать параметры соединения с исходной ГБД!" ) skip
      view-as alert-box error
    .
    apply "entry":U to v-conn-par in frame {&frame-name} .
    return no-apply.
  end.

  run proc-conn in this-procedure
    ( input v-conn-par
    , input p-user-name
    , input p-user-pswd
    , input p-ld-name
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    apply "entry":U to v-conn-par in frame {&frame-name} .
    return no-apply .
  end.

  if connected( p-ld-name ) then do:
    assign
      p-new-conn = v-conn-par
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-get-conn-par
ON CHOOSE OF b-quit IN FRAME d-get-conn-par /* Отмена */
DO:
  assign
    p-new-conn = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-get-conn-par


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP       UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if p-ld-name = ?
    or trim( p-ld-name ) = "":U
    or trim( p-ld-name ) = "ub":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute('Ошибка задания входных параметров.') skip
      substitute('Логическое имя БД должно быть не пустым и не "ub".') skip
      substitute('Логическое имя БД &1', p-ld-name ) skip
      view-as alert-box error .
  end.

  if p-user-name = "":U
    or p-user-name = ?
    or p-user-pswd = "":U
    or p-user-pswd = ?
  then do:
    assign
      p-user-name = "sysadm":U
      p-user-pswd = {&paswordcur}
    .
  end.

  assign
    p-new-conn = ?
    v-conn-par = p-conn-par
  .
  if p-title-par <> ?
    or trim( p-title-par ) <> "":U
  then do:
    assign
      v-title-par = p-title-par
    .
  end.


  if connected( p-ld-name ) then do:
    return error substitute( "БД с логическим именем &1 уже подключена", p-ld-name ) .
  end.

  if trim( p-conn-par ) <> "":U
    and p-conn-par <> ?
  then do:
    run proc-conn in this-procedure
      ( input p-conn-par
      , input p-user-name
      , input p-user-pswd
      , input p-ld-name
      ) no-error .
    if not error-status :error then do:
      assign
        p-new-conn = p-conn-par
      .
      return .
    end.
  end.

  RUN enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-get-conn-par  _DEFAULT-DISABLE
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
  HIDE FRAME d-get-conn-par.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-get-conn-par  _DEFAULT-ENABLE
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
  DISPLAY v-conn-par v-title-par
      WITH FRAME d-get-conn-par.
  ENABLE b-exit b-quit b-help v-conn-par
      WITH FRAME d-get-conn-par.
  {&OPEN-BROWSERS-IN-QUERY-d-get-conn-par}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-conn d-get-conn-par
PROCEDURE proc-conn :
define input  parameter par-conn-par  as character no-undo .
  define input  parameter par-user-name as character no-undo .
  define input  parameter par-user-pswd as character no-undo .
  define input  parameter par-ld-name   as character no-undo .

  connect value( par-conn-par ) -ld value( par-ld-name ) -U value( par-user-name ) -P value( par-user-pswd ) no-error.
  if not connected( par-ld-name ) then do:
    connect value( par-conn-par ) -ld test-conn -U odbc -P odbc no-error.
    if connected( "test-conn":U ) then do:
      disconnect test-conn .
      return error substitute( "Не удалось подключиться к БД с пользователем &1", par-user-name ).
    end.
    else do:
      return error substitute( "Не удалось подключиться к БД с параметрами &2!&1&3", {&new-line}, par-conn-par, error-status :get-message ( 1 ) ).
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME