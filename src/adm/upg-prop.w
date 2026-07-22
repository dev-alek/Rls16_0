&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройка Upgrade

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/13/03
Author: Dmitry Ukhanov
Creation date: 09/13/03

no_app_help

*/

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
define variable vss-description as character no-undo init "Настройка Upgrade".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME upg-prop

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save RECT-3 RECT-4 f-prev-ver f-src-path ~
b-get-dir-src b-get-dir-trg f-target-path
&Scoped-Define DISPLAYED-OBJECTS f-ini-path f-prev-ver f-src-path ~
f-target-path

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-get-dir-src DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-get-dir-trg DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save DEFAULT
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-prev-ver AS CHARACTER FORMAT "X(5)":U INITIAL "14_0"
     LABEL "Номер версии"
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "14_0"
     DROP-DOWN-LIST
     SIZE 8.63 BY 1 NO-UNDO.

DEFINE VARIABLE f-ini-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь к progress.ini"
     VIEW-AS FILL-IN
     SIZE 33.38 BY 1 NO-UNDO.

DEFINE VARIABLE f-src-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь к пакету upgrade"
     VIEW-AS FILL-IN
     SIZE 31.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-target-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь к новой версии"
     VIEW-AS FILL-IN
     SIZE 31.88 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 3.13.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 3.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME upg-prop
     b-save AT ROW 1.13 COL 1
     f-ini-path AT ROW 3 COL 27 COLON-ALIGNED
     f-prev-ver AT ROW 4.13 COL 27 COLON-ALIGNED
     f-src-path AT ROW 6.08 COL 27 COLON-ALIGNED
     b-get-dir-src AT ROW 6.08 COL 61.5
     b-get-dir-trg AT ROW 7.25 COL 61.5
     f-target-path AT ROW 7.29 COL 27 COLON-ALIGNED
     RECT-3 AT ROW 2.5 COL 2
     RECT-4 AT ROW 5.67 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 71 BY 8.17.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 8.25
         WIDTH              = 71.5.
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
/* SETTINGS FOR FRAME upg-prop
   NOT-VISIBLE                                                          */
/* SETTINGS FOR FILL-IN f-ini-path IN FRAME upg-prop
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME upg-prop
/* Query rebuild information for FRAME upg-prop
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME upg-prop */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-get-dir-src
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-get-dir-src F-Frame-Win
ON CHOOSE OF b-get-dir-src IN FRAME upg-prop
DO:
    define variable s-path        as character no-undo .
    define variable dir-type      as character no-undo .
    define variable dir-can-write as logical   no-undo .

    run gbl/dir-sel.p ( output s-path,
                    output dir-type,
                    output dir-can-write
                  ).

    if trim( s-path ) <> "" then do:
      assign
        f-src-path = s-path
      .
      disp f-src-path with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-get-dir-trg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-get-dir-trg F-Frame-Win
ON CHOOSE OF b-get-dir-trg IN FRAME upg-prop
DO:
    define variable t-path        as character no-undo .
    define variable dir-type      as character no-undo .
    define variable dir-can-write as logical   no-undo .

    run gbl/dir-sel.p ( output t-path,
                    output dir-type,
                    output dir-can-write
                  ).

    if trim( t-path ) <> "" then do:
      if dir-can-write then do:
        assign
          f-target-path = t-path
          .
        disp f-target-path with frame {&frame-name}.
      end.
      else do:
        message "В дир." t-path "невозможна запись." skip
                "Выберете другую, доступную для записи."
                view-as alert-box error.
      end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save F-Frame-Win
ON CHOOSE OF b-save IN FRAME upg-prop /* Сохранить */
DO:

  assign
    f-prev-ver
    f-src-path
    f-target-path
  .
/*
  os-command silent value( 'attrib -r':U + {&space-char} + f-ini-path ).
*/

  put-key-value section "upgrade" key "ini-path" value f-ini-path.
  put-key-value section "upgrade" key "prev-ver" value f-prev-ver.
  put-key-value section "upgrade" key "upg-path"  value f-src-path.
  put-key-value section "upgrade" key "dir-ver"  value f-target-path.
/*
  if trim( ini-path ) = "":U
     or ini-path = "?":U
     or ini-path = ?
  then do:
    message 'Не задан параметр "Путь к progress.ini"' view-as alert-box error.
    apply "entry" to ini-path in frame {&frame-name}.
    return no-apply.
  end.
  else do:
    assign
      file-info:file-name = ini-path
    .
    if file-info:full-pathname = ? then do:
      message 'Указанный ini файл не найден!' view-as alert-box error.
      apply "entry" to ini-path in frame {&frame-name}.
      return no-apply.
    end.
  end.
*/
  if trim( f-src-path ) = "":U
     or f-src-path = "?":U
     or f-src-path = ?
  then do:
    message 'Не задан параметр "Путь к пакету upgrade"' view-as alert-box error.
    apply "entry" to f-src-path in frame {&frame-name}.
    return no-apply.
  end.
  if trim( f-target-path ) = "":U
     or f-target-path = "?":U
     or f-target-path = ?
  then do:
    message 'Не задан параметр "Путь к новой версии"' view-as alert-box error.
    apply "entry" to f-target-path in frame {&frame-name}.
    return no-apply.
  end.
  else do:
    assign
      file-info:file-name = f-target-path
    .
    if file-info:full-pathname = ? then do:
      os-create-dir value( f-target-path ) .
      if os-error <> 0 then do:
        message 'Невозможно создать каталог для новой версии!' view-as alert-box error.
        apply "entry" to f-target-path in frame {&frame-name}.
        return no-apply.
      end.
    end.

    os-copy
      value( search( 'cmp/str-glbl.i':U ) )
      value( f-target-path )
      .
    if os-error <> 0 then do:
      message 'Невозможно записать в каталог для новой версии!' view-as alert-box error.
      apply "entry" to f-target-path in frame {&frame-name}.
      return no-apply.
    end.
    os-command silent value( 'attrib -r':U + {&space-char} + f-target-path + {&slash-char} + 'cmp/str-glbl.i':U ).
    os-delete value( f-target-path + {&slash-char} + 'cmp/str-glbl.i':U ) .
  end.

  message
     vss-workfile vss-revision vss-description skip
    "Настройки Upgrade сохранены"
    view-as alert-box information.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

define variable v-exe-file as character no-undo .
define variable v-prev-ver as character no-undo .

run gbl/getexini.p ( OUTPUT v-exe-file, OUTPUT f-ini-path ) no-error .
if error-status :error then do:
  return error.
end.

get-key-value section "upgrade" key "prev-ver" value v-prev-ver.
if lookup( v-prev-ver, f-prev-ver:list-items ) > 0 then do:
  assign
    f-prev-ver = v-prev-ver
  .
end.
get-key-value section "upgrade" key "upg-path" value f-src-path.
get-key-value section "upgrade" key "dir-ver"  value f-target-path.

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
  HIDE FRAME upg-prop.
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
  DISPLAY f-ini-path f-prev-ver f-src-path f-target-path
      WITH FRAME upg-prop.
  ENABLE b-save RECT-3 RECT-4 f-prev-ver f-src-path b-get-dir-src b-get-dir-trg
         f-target-path
      WITH FRAME upg-prop.
  {&OPEN-BROWSERS-IN-QUERY-upg-prop}
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