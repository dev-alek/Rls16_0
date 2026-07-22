&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки online backup (SmartObject)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/13/03
Author: Dmitry Ukhanov
Creation date: 09/13/03

no_app_help

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки online backup (SmartObject)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define stream test.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-bkp-prop

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save v-run-bkp b-sel-bat-name v-bat-name ~
v-msg-name b-sel-msg-name b-sel-path-dlc v-path-dlc b-sel-path-src-db ~
v-path-src-db b-sel-path-dst-db v-path-dst-db
&Scoped-Define DISPLAYED-OBJECTS v-run-bkp v-bat-name v-msg-name v-path-dlc ~
v-path-src-db v-path-dst-db

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-save DEFAULT
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-bat-name DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE BUTTON b-sel-msg-name DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE BUTTON b-sel-path-dlc DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE BUTTON b-sel-path-dst-db DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE BUTTON b-sel-path-src-db DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE VARIABLE v-bat-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл запуска"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-msg-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл сообщений"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-path-dlc AS CHARACTER FORMAT "X(256)":U
     LABEL "Каталог Progress"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-path-dst-db AS CHARACTER FORMAT "X(256)":U
     LABEL "Каталог для копии БД"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-path-src-db AS CHARACTER FORMAT "X(256)":U
     LABEL "БД для backup"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-run-bkp AS LOGICAL INITIAL no
     LABEL "Проводить online backup в СПН"
     VIEW-AS TOGGLE-BOX
     SIZE 33.13 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-bkp-prop
     b-save AT ROW 1.13 COL 1
     v-run-bkp AT ROW 2.5 COL 2.5
     b-sel-bat-name AT ROW 3.42 COL 63.5
     v-bat-name AT ROW 3.5 COL 23 COLON-ALIGNED
     v-msg-name AT ROW 4.63 COL 23 COLON-ALIGNED
     b-sel-msg-name AT ROW 4.63 COL 63.5
     b-sel-path-dlc AT ROW 5.71 COL 63.5
     v-path-dlc AT ROW 5.79 COL 23 COLON-ALIGNED
     b-sel-path-src-db AT ROW 6.88 COL 63.5
     v-path-src-db AT ROW 6.96 COL 23 COLON-ALIGNED
     b-sel-path-dst-db AT ROW 8 COL 63.5
     v-path-dst-db AT ROW 8.08 COL 23 COLON-ALIGNED
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 66.13 BY 8.13.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
   Design Page: 3
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 8.83
         WIDTH              = 66.5.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME F-bkp-prop
   NOT-VISIBLE                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-bkp-prop
/* Query rebuild information for FRAME F-bkp-prop
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-bkp-prop */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save F-Frame-Win
ON CHOOSE OF b-save IN FRAME F-bkp-prop /* Сохранить */
DO:

  define variable v2-run-bkp-str as character no-undo .
  assign
    v-run-bkp
    v-bat-name
    v-msg-name
    v-path-dlc
    v-path-src-db
    v-path-dst-db
  .

  if v-run-bkp = true then do:
    assign
      v2-run-bkp-str = "YES":U
    .
    if search( v-bat-name ) = ? then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Файл запуска online backup (&1) не найден!", v-bat-name ) skip
        view-as alert-box error.
      return no-apply.
    end.

    put-key-value section "onlinebkp":U key "bat-name":U value v-bat-name  no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Файл настроек progress доступен только для чтения!" skip
        "Сохранение параметров невозможно."
        view-as alert-box error.
      return no-apply.
    end.

    put-key-value section "onlinebkp":U key "msg-name":U value v-msg-name  no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Файл настроек progress доступен только для чтения!" skip
        "Сохранение параметров невозможно."
        view-as alert-box error.
      return no-apply.
    end.

    if v-path-dlc = "":U then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задан каталог Progress!" skip
        view-as alert-box error.
      apply "entry" to v-path-dlc in frame {&frame-name} .
      return no-apply.
    end.

    run check-dir ( input-output v-path-dlc ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        return-value skip
        "Задайте каталог Progress!" skip
        error-status :get-message(0) skip
        error-status :get-message(1)
        view-as alert-box error.
      apply "entry" to v-path-dlc in frame {&frame-name} .
      return no-apply.
    end.
    else do:
      put-key-value section "onlinebkp":U key "path-dlc":U value v-path-dlc  no-error.
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.

    put-key-value section "onlinebkp":U key "path-src-db":U value v-path-src-db .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Файл настроек progress доступен только для чтения!" skip
        "Сохранение параметров невозможно."
        view-as alert-box error.
      return no-apply.
    end.
    put-key-value section "onlinebkp":U key "path-dst-db":U value v-path-dst-db .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Файл настроек progress доступен только для чтения!" skip
        "Сохранение параметров невозможно."
        view-as alert-box error.
      return no-apply.
    end.
  end.
  else do:
    assign
      v2-run-bkp-str = "NO":U
    .
  end.

  put-key-value section "onlinebkp":U key "run-bkp":U value v2-run-bkp-str .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Файл настроек progress доступен только для чтения!" skip
      "Сохранение параметров невозможно."
      view-as alert-box error.
    return no-apply.
  end.

  message
    "Настройки Online backup сохранены"
    view-as alert-box information.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-bat-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-bat-name F-Frame-Win
ON CHOOSE OF b-sel-bat-name IN FRAME F-bkp-prop
DO:

  define variable v-file-name as character no-undo .
  define variable v-ok        as logical no-undo .

  system-dialog get-file v-file-name
    filters "Исполняемые файлы (*.exe,*.bat)" "*.exe,*.bat",
            "Все файлы (*.*)" "*.*"
    title "Выберите имя файла для запуска online backup"
    update v-ok
  .
  if v-ok = true then do:
    assign
      v-bat-name = v-file-name
    .
    display
      v-bat-name
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-bat-name IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-msg-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-msg-name F-Frame-Win
ON CHOOSE OF b-sel-msg-name IN FRAME F-bkp-prop
DO:

  define variable v-file-name as character no-undo .
  define variable v-ok        as logical no-undo .

  system-dialog get-file v-file-name
    filters "Текстовые файлы (*.txt,*.log)" "(*.txt,*.log)",
            "Все файлы (*.*)" "*.*"
    title "Выберите имя файла сообщений"
    update v-ok
  .
  if v-ok = true then do:
    assign
      v-msg-name = v-file-name
    .
    display
      v-msg-name
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-msg-name IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-path-dlc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-path-dlc F-Frame-Win
ON CHOOSE OF b-sel-path-dlc IN FRAME F-bkp-prop
DO:

  define variable v-dir-name  as character no-undo .
  define variable v-type      as character no-undo .
  define variable v-can-write as logical   no-undo .

  run gbl/dir-sel.p ( output v-dir-name
                 ,output v-type
                 ,output v-can-write
                ).
  if v-can-write then do:
    assign
      v-path-dlc = v-dir-name
    .
    display
      v-path-dlc
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-path-dlc IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-path-dst-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-path-dst-db F-Frame-Win
ON CHOOSE OF b-sel-path-dst-db IN FRAME F-bkp-prop
DO:

  define variable v-dir-name  as character no-undo .
  define variable v-type      as character no-undo .
  define variable v-can-write as logical   no-undo .

  run gbl/dir-sel.p ( output v-dir-name
                 ,output v-type
                 ,output v-can-write
                ).
  if v-can-write then do:
    assign
      v-path-dst-db = v-dir-name
    .
    display
      v-path-dst-db
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-path-dst-db IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-path-src-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-path-src-db F-Frame-Win
ON CHOOSE OF b-sel-path-src-db IN FRAME F-bkp-prop
DO:
  define variable v-file-name as character no-undo .
  define variable v-ok        as logical no-undo .

  system-dialog get-file v-file-name
    filters "Файлы баз данных (*.db)" "*.db",
            "Все файлы (*.*)" "*.*"
    title "Укажите БД для online backup"
    update v-ok
  .
  if v-ok = true then do:
    assign
      v-path-src-db = v-file-name
    .
    display
      v-path-src-db
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-path-src-db IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-run-bkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-run-bkp F-Frame-Win
ON VALUE-CHANGED OF v-run-bkp IN FRAME F-bkp-prop /* Проводить online backup в СПН */
DO:
  assign
    v-run-bkp
  .
  if v-run-bkp = true then do:
    enable b-sel-bat-name v-bat-name b-sel-msg-name v-msg-name
           b-sel-path-dlc v-path-dlc b-sel-path-src-db v-path-src-db
           b-sel-path-dst-db v-path-dst-db
        with frame {&frame-name}.
  end.
  else do:
    disable b-sel-bat-name v-bat-name b-sel-msg-name v-msg-name
            b-sel-path-dlc v-path-dlc b-sel-path-src-db v-path-src-db
            b-sel-path-dst-db v-path-dst-db
        with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */

{ gbl/personly.i }

define variable v-run-bkp-str as character no-undo .

get-key-value section "onlinebkp":U key "run-bkp":U value v-run-bkp-str .
get-key-value section "onlinebkp":U key "bat-name":U value v-bat-name .
get-key-value section "onlinebkp":U key "msg-name":U value v-msg-name .
get-key-value section "onlinebkp":U key "path-dlc":U value v-path-dlc .
get-key-value section "onlinebkp":U key "path-src-db":U value v-path-src-db .
get-key-value section "onlinebkp":U key "path-dst-db":U value v-path-dst-db .

if v-run-bkp-str = ?
  or CAPS( v-run-bkp-str ) = "FALSE":U
  or CAPS( v-run-bkp-str ) = "NO":U
then do:
  assign
    v-run-bkp = false
  .
end.
else do:
  assign
    v-run-bkp = true
  .
end.

if v-bat-name = ? then do:
  assign
    v-bat-name = "":U
  .
end.
if v-msg-name = ? then do:
  assign
    v-msg-name = "":U
  .
end.
if v-path-dlc = ? then do:
  assign
    v-path-dlc = "":U
  .
end.
if v-path-src-db = ? then do:
  assign
    v-path-src-db = "":U
  .
end.
if v-path-dst-db = ? then do:
  assign
    v-path-dst-db = "":U
  .
end.


&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-dir F-Frame-Win
PROCEDURE check-dir :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input-output parameter p-dir-name as character no-undo .

do
on error undo, return error
:
  define variable v-log as logical no-undo .

  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type = ?
    or index( file-info:file-type, "D":U ) = 0
  then do:
    return error substitute( "Каталог &1 не существует!", p-dir-name ).
  end.
  if file-info:file-type <> ? then do:
    assign
      p-dir-name = file-info:full-pathname
    .
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-bkp-prop.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY v-run-bkp v-bat-name v-msg-name v-path-dlc v-path-src-db v-path-dst-db
      WITH FRAME F-bkp-prop.
  ENABLE b-save v-run-bkp b-sel-bat-name v-bat-name v-msg-name b-sel-msg-name
         b-sel-path-dlc v-path-dlc b-sel-path-src-db v-path-src-db
         b-sel-path-dst-db v-path-dst-db
      WITH FRAME F-bkp-prop.
  {&OPEN-BROWSERS-IN-QUERY-F-bkp-prop}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

  apply "value-changed" to v-run-bkp in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
