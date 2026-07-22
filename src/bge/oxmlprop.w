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

Настройки OpenXML (SmartObject)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08


no app_help
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
define variable vss-description as character no-undo init "Настройки OpenXML (SmartObject))".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define stream test.
define variable v-old-exch-dir as character no-undo .
define variable v-old-heap-dir as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-sel-exch-dir v-exch-dir ~
b-sel-heap-dir v-heap-dir
&Scoped-Define DISPLAYED-OBJECTS v-exch-dir v-heap-dir

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

DEFINE BUTTON b-sel-exch-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE BUTTON b-sel-heap-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.

DEFINE VARIABLE v-exch-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "каталог exch"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-heap-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "каталог heap"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     b-save AT ROW 1.13 COL 1
     b-sel-exch-dir AT ROW 2.5 COL 55
     v-exch-dir AT ROW 2.54 COL 14 COLON-ALIGNED
     b-sel-heap-dir AT ROW 3.67 COL 55
     v-heap-dir AT ROW 3.75 COL 14 COLON-ALIGNED
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 58.25 BY 4.5.


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
         HEIGHT             = 7.54
         WIDTH              = 65.63.
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
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save F-Frame-Win
ON CHOOSE OF b-save IN FRAME F-Main /* Сохранить */
DO:
  define variable v-err-message as character no-undo .

  assign
    v-exch-dir
    v-heap-dir
  .
  if v-exch-dir = v-heap-dir then do:
    message
    "Каталог EXCH и каталог HEAP должны различаться." skip(1)
    "папкой обмена EXCH для системы OXML указан каталог" skip
    v-exch-dir skip(1)
    "папкой разбора HEAP для системы OXML указан каталог" skip
    v-heap-dir
    view-as alert-box error .
    return no-apply.
  end.
  run check-dir ( input-output v-exch-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
    return no-apply.
  end.
  else do:
    if v-exch-dir <> v-old-exch-dir then do:
      v-err-message = ibs.th.gbl.gbl-inipar:PutKeyValue("OXML":U, "oxml-exch-dir":U, v-exch-dir) .
      if v-err-message > "" then do:
        message
          vss-workfile vss-revision vss-description skip
          v-err-message skip(1)
          "Возможно, файл настроек progress доступен только для чтения." skip
          "Сохранение параметра отклонено."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.

  run check-dir ( input-output v-heap-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
    return no-apply.
  end.
  else do:
    if v-heap-dir <> v-old-heap-dir then do:
      v-err-message = ibs.th.gbl.gbl-inipar:PutKeyValue("OXML":U, "oxml-dir":U, v-heap-dir) .
      if v-err-message > "" then do:
        message
          vss-workfile vss-revision vss-description skip
          v-err-message skip(1)
          "Возможно, файл настроек progress доступен только для чтения." skip
          "Сохранение параметра отклонено."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.

  message
    "Настройки OpenXML сохранены"
    view-as alert-box information.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-exch-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-exch-dir F-Frame-Win
ON CHOOSE OF b-sel-exch-dir IN FRAME F-Main
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
      v-exch-dir = v-dir-name
    .
    display
      v-exch-dir
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-exch-dir IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-heap-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-heap-dir F-Frame-Win
ON CHOOSE OF b-sel-heap-dir IN FRAME F-Main
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
      v-heap-dir = v-dir-name
    .
    display
      v-heap-dir
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-heap-dir IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

assign
  v-exch-dir = ibs.th.gbl.gbl-inipar:oxmlExchDir
  v-heap-dir = ibs.th.gbl.gbl-inipar:oxmlDir
.
assign
  v-exch-dir = "":U when v-exch-dir = ?
  v-heap-dir = "":U when v-heap-dir = ?
.
assign
  v-old-exch-dir = v-exch-dir
  v-old-heap-dir = v-heap-dir
.

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
  if file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0
  then do:
    output stream test to "test.tst":U .
    put stream test unformatted "test":U skip.
    output stream test close.
    os-copy "test.tst":U value( p-dir-name ) .
    if os-error <> 0 then do:
      return error string( "Каталог" + {&space-char} + p-dir-name + {&space-char}
                           + "недоступен для чтения и(или) записи!"
                           + {&new-line} + "Сохранение параметров невозможно."
                         ).
    end.
    else do:
      os-delete value( "test.tst":U ) .
      os-delete value( p-dir-name + {&back-slash-char} + "test.tst":U ) .
    end.
  end.
  else do:
    message
      "Каталог" p-dir-name "не существует!" skip
      "Cоздать его?"
      view-as alert-box information buttons yes-no update v-log.
    if v-log = false then do:
      return error substitute( "Отказ от создания каталога!" ).
    end.
    else do:
      run gbl/dir-cre.p ( input p-dir-name ) no-error .
      if error-status:error then do:
        return error substitute( "Ошибка при создании каталога &1&2&3", p-dir-name, {&new-line}, return-value ).
      end.
    end.
  end.
  assign
    file-info:file-name = p-dir-name
  .
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
  HIDE FRAME F-Main.
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
  DISPLAY v-exch-dir v-heap-dir
      WITH FRAME F-Main.
  ENABLE b-save b-sel-exch-dir v-exch-dir b-sel-heap-dir v-heap-dir
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
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