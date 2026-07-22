&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-add-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-add-db
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 27/10/99
Author: Dmitry Ukhanov
Creation date: 27/10/99

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-db-num      as integer   no-undo.
define output parameter p-type-unload as character no-undo .

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
{ cmp/trg-def.i  }
{ adm/unloaddb.i }
{ utl/setpwd.i }

define buffer buf_sys-ctrl for ub.sys-ctrl .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-add-db

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-1 b-exit b-quit b-help ~
v-sel-src-db v-db-src v-db-dst
&Scoped-Define DISPLAYED-OBJECTS v-sel-src-db v-db-src v-db-dst

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
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE VARIABLE v-db-dst AS CHARACTER FORMAT "X(256)":U
     LABEL "Целевая БД"
     VIEW-AS FILL-IN
     SIZE 30.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-db-src AS CHARACTER FORMAT "X(256)":U
     LABEL "Исходная БД"
     VIEW-AS FILL-IN
     SIZE 30.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-sel-src-db AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Выгрузка online", "unload-online":U,
"Выгрузка из копии БД", "unload-copy":U
     SIZE 24.13 BY 1.83 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 3.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-add-db
     b-exit AT ROW 1.17 COL 2
     b-quit AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 39
     v-sel-src-db AT ROW 3.92 COL 4.25 NO-LABEL
     v-db-src AT ROW 6 COL 14.5 COLON-ALIGNED
     v-db-dst AT ROW 9 COL 14.5 COLON-ALIGNED
     RECT-2 AT ROW 7.42 COL 2
     "Целевая база данных" VIEW-AS TEXT
          SIZE 21.38 BY .75 AT ROW 7.63 COL 3
     "База данных источник" VIEW-AS TEXT
          SIZE 21.38 BY .75 AT ROW 2.63 COL 3
     RECT-1 AT ROW 2.42 COL 2
     SPACE(0.99) SKIP(3.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите параметры подсоединения к БД":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-add-db
                                                                        */
ASSIGN
       FRAME d-add-db:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-add-db
/* Query rebuild information for DIALOG-BOX d-add-db
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-add-db */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-add-db
ON CHOOSE OF b-exit IN FRAME d-add-db /* Ввод */
DO:

  define buffer buf_user-login      for ub.user-login .

  define variable v-user-pswd-enc as character no-undo .
  define variable v-create-adm    as logical      no-undo.

  assign
    v-db-src
    v-db-dst
    v-sel-src-db
  .

  run adm/unloaddc.p no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не удалось отключить БД" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return no-apply .
  end.

  case v-sel-src-db :
    when {&unload-online} then do:
      create alias src for database ub no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при создании вымышленного имени src" ) skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return no-apply.
      end.
    end.
    when {&unload-copy} then do:
      if v-db-src = "":U then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Нeобходимо указать параметры соединения с исходной ГБД!" ) skip
          view-as alert-box error
        .
        apply "entry":U to v-db-src in frame {&frame-name} .
        return no-apply.
      end.

      run adm/pswd-enc.p (input encode(g#passwd), output v-user-pswd-enc) no-error.
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка кодировки." ) skip
          error-status :get-message ( error-status :num-messages ) skip
          return-value
          view-as alert-box error
        .
        return no-apply.
      end.

      connect value( v-db-src ) -ld src -U value( g#userid ) -P value( v-user-pswd-enc ) no-error.
      if not connected ("src":U) then do:

        connect value( v-db-src ) -ld src -U odbc - P odbc no-error.
        if not connected ("src":U) then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Не могу соединиться с исходной ГБД!" ) skip
            error-status :get-message ( error-status :num-messages )
            view-as alert-box error
          .
          apply "entry":U to v-db-src in frame {&frame-name} .
          return no-apply.
        end.
        else do:
          disconnect src.
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Не могу соединиться с исходной ГБД!" ) skip
            substitute( "В исходной ГБД нет пользователя &1 или", g#userid ) skip
            substitute( "он имеет пароль отличный от пароля в копии ГБД" ) skip
            view-as alert-box error
          .
          return no-apply.
        end.
      end.

      { adm/chk-c-db.i "'check'":U p-db-num  "'src'":U "'ub'":U no-apply }

    end.
  end case.

  /* Соединение и начальная инициализация целевай БД */
  if v-db-dst = "":U then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Нeобходимо указать параметры соединения с целевой базой!" ) skip
      view-as alert-box error
    .
    apply "entry" to v-db-dst in frame {&frame-name} .
    return no-apply.
  end.

  FIND FIRST buf_user-login
       WHERE buf_user-login.db-num     = p-db-num
         AND buf_user-login.user-login = "адм"
         and buf_user-login.status_    = {&uls-normal}
       no-lock
       no-error
       .
  IF NOT AVAILABLE buf_user-login
  THEN DO:
     ASSIGN
        v-create-adm = TRUE
     .
  END.
  define variable vConect as character no-undo.
  vConect = SUBSTITUTE("&1 -ld dst -U sysadm -P &2", v-db-dst,"{&paswordold}") .
  connect value(vConect) no-error.
  if not connected ("dst") then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не могу соединиться с проинициированой целевой базой!" ) skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    apply "entry" to v-db-dst in frame {&frame-name} .
    return no-apply.
  end.

  run adm/init-db.p
    ( input p-db-num
     ,input "dst":U
     ,input buf_sys-ctrl.language
     ,input buf_sys-ctrl.r-b
     ,input buf_sys-ctrl.sys-key
     ,input no
     ,input v-create-adm
     ,input 0
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при инициализации целевой базой!" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return no-apply.
  end.

  assign
    p-type-unload = v-sel-src-db
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-add-db
ON CHOOSE OF b-quit IN FRAME d-add-db /* Отмена */
DO:
  assign
    p-type-unload = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-sel-src-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sel-src-db d-add-db
ON VALUE-CHANGED OF v-sel-src-db IN FRAME d-add-db
DO:
  assign
    v-sel-src-db
  .
  disable v-db-src with frame {&frame-name}.
  case v-sel-src-db :
    when {&unload-online} then do:
    end.
    when {&unload-copy} then do:
      enable v-db-src with frame {&frame-name}.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( 'Отсутствует обработка выгрузки "&1"', v-sel-src-db:screen-value ) skip
        view-as alert-box error
      .
      return no-apply.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-add-db


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

  define variable v-log as logical no-undo .

  session:data-entry-return = yes .

  find first buf_sys-ctrl no-lock .

  assign
    p-type-unload = ?
  .

  RUN enable_UI.

  if buf_sys-ctrl.status_ = {&sttsDB-copy} then do:
    assign
      v-sel-src-db = {&unload-copy}
      v-log = v-sel-src-db:disable( "Выгрузка online" )
    .
  end.
  else do:
    assign
      v-sel-src-db = {&unload-online}
      v-log = v-sel-src-db:disable( "Выгрузка из копии БД" )
    .
  end.

  display v-sel-src-db with frame {&frame-name} .
  apply "value-changed" to v-sel-src-db in frame {&frame-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.
session:data-entry-return = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-add-db _DEFAULT-DISABLE
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
  HIDE FRAME d-add-db.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-add-db _DEFAULT-ENABLE
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
  DISPLAY v-sel-src-db v-db-src v-db-dst
      WITH FRAME d-add-db.
  ENABLE RECT-2 RECT-1 b-exit b-quit b-help v-sel-src-db v-db-src v-db-dst
      WITH FRAME d-add-db.
  {&OPEN-BROWSERS-IN-QUERY-d-add-db}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME