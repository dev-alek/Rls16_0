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

Директории Импорта НАКЛАДНЫХ

Автор: Чернова Светлана Александровна
Дата создания: 07/16/09
Author: Svetlana Chernova
Creation date: 07/16/09


*/


/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define output parameter p-source-dir as character no-undo .
define output parameter p-archive-dir as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Директории Импорта НАКЛАДНЫХ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
p-source-dir  = ?.
p-archive-dir = ?.

define stream test2.
define variable v-old-source-dir as character no-undo .
define variable v-old-archive-dir as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save B-quit B-Help b-sel-source-dir ~
v-source-dir b-sel-archive-dir v-archive-dir
&Scoped-Define DISPLAYED-OBJECTS v-source-dir v-archive-dir

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-archive-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE-PIXELS 20 BY 26.

DEFINE BUTTON b-sel-source-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE-PIXELS 20 BY 26.

DEFINE VARIABLE v-archive-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория архив"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.

DEFINE VARIABLE v-source-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория источник"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 77
     b-sel-source-dir AT Y 48 X 548
     v-source-dir AT ROW 3.04 COL 9.5
     b-sel-archive-dir AT Y 76 X 548
     v-archive-dir AT ROW 4.25 COL 28.5 COLON-ALIGNED
     SPACE(18.74) SKIP(1.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Директории обмена c import-rash"
         CANCEL-BUTTON B-quit.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-source-dir IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Директории обмена c import-rash */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
          p-source-dir  = ?.
          p-archive-dir = ?.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    v-source-dir
    v-archive-dir
  .
    p-source-dir  =  v-source-dir  .
    p-archive-dir =  v-archive-dir .


  run check-dir ( input-output v-source-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
      p-source-dir  = ?.
      p-archive-dir = ?.
    return no-apply.
  end.
  else do:
    if v-source-dir <> v-old-source-dir then do:
      put-key-value section "import-rash":U key "import-rash-source-dir":U value v-source-dir  no-error.
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.


  run check-dir ( input-output v-archive-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
      p-source-dir  = ?.
      p-archive-dir = ?.

    return no-apply.
  end.
  else do:
    if v-archive-dir <> v-old-archive-dir then do:
      put-key-value section "import-rash":U key "import-rash-archive-dir":U value v-archive-dir .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.


p-source-dir  =  v-source-dir  .
p-archive-dir =  v-archive-dir .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-archive-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-archive-dir Dialog-Frame
ON CHOOSE OF b-sel-archive-dir IN FRAME Dialog-Frame
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
      v-archive-dir = v-dir-name
    .
    display
      v-archive-dir
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-archive-dir IN FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-source-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-source-dir Dialog-Frame
ON CHOOSE OF b-sel-source-dir IN FRAME Dialog-Frame
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
      v-source-dir = v-dir-name
    .
    display
      v-source-dir
      with frame {&frame-name}
    .
  end.

  APPLY "ENTRY" TO v-source-dir IN FRAME {&FRAME-NAME} .

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

get-key-value section "import-rash":U key "import-rash-source-dir":U value v-source-dir .
get-key-value section "import-rash":U key "import-rash-archive-dir":U value v-archive-dir .

if v-source-dir = ? then do:
  assign
    v-source-dir = "":U
  .
end.

if v-archive-dir = ? then do:
  assign
    v-archive-dir = "":U
  .
end.

assign
  v-old-source-dir = v-source-dir
  v-old-archive-dir = v-archive-dir
.

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-dir Dialog-Frame
PROCEDURE check-dir :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
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
    output stream test2 to "test2.tst":U .
    put stream test2 unformatted "test2":U skip.
    output stream test2 close.
    os-copy "test2.tst":U value( p-dir-name ) .
    if os-error <> 0 then do:
      return error string( "Каталог" + {&space-char} + p-dir-name + {&space-char}
                           + "недоступен для чтения и(или) записи!"
                           + {&new-line} + "Сохранение параметров невозможно."
                         ).
    end.
    else do:
      os-delete value( "test2.tst":U ) .
      os-delete value( p-dir-name + {&back-slash-char} + "test2.tst":U ) .
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
  DISPLAY v-source-dir v-archive-dir
      WITH FRAME Dialog-Frame.
  ENABLE b-save B-quit B-Help b-sel-source-dir v-source-dir b-sel-archive-dir
         v-archive-dir
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME