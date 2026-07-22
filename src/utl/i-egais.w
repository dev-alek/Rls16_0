&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Интерфейс импорта классификатора ЕГАИС

Автор: Хныкин Павел Андреевич
Дата создания: 12/14/07
Author: Pavel Khnykin
Creation date: 12/14/07

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Интерфейс импорта классификатора ЕГАИС".
{ cmp/vssrevis.i }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as handle no-undo .

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/usr-flt.i }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-imp b-help ~
v-alc-codes-filename b-sel-alc-codes v-sup-codes-filename b-sel-sup-codes
&Scoped-Define DISPLAYED-OBJECTS v-alc-codes-filename v-sup-codes-filename

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp
     LABEL "&Импорт"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-alc-codes DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.

DEFINE BUTTON b-sel-sup-codes DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.

DEFINE VARIABLE v-alc-codes-filename AS CHARACTER FORMAT "X(256)":U
     LABEL "Справочник товаров"
     VIEW-AS FILL-IN
     SIZE 40 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sup-codes-filename AS CHARACTER FORMAT "X(256)":U
     LABEL "Справочник поставщиков"
     VIEW-AS FILL-IN
     SIZE 40 BY 1
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-imp AT ROW 1 COL 11
     b-help AT ROW 1 COL 56
     v-alc-codes-filename AT ROW 3 COL 23 COLON-ALIGNED
     b-sel-alc-codes at row 3 col 66
     v-sup-codes-filename AT ROW 4 COL 23 COLON-ALIGNED
     b-sel-sup-codes at row 4 col 66
     SPACE(2.62) SKIP(1.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт классификатора ЕГАИС"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       v-alc-codes-filename:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       v-sup-codes-filename:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт классификатора ЕГАИС */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp Dialog-Frame
ON CHOOSE OF b-imp IN FRAME Dialog-Frame /* Импорт */
DO:
  assign
    v-alc-codes-filename
    v-sup-codes-filename
  .
  if v-alc-codes-filename = "" or
     v-sup-codes-filename = ""
  then do:
    message
      "Не задан один из файлов. Импорт невозможен."
    view-as alert-box error.
    return no-apply.
  end.
  if ( v-sup-codes-filename = v-alc-codes-filename )
  then do:
    message
      "Имена файлов совпадают, импорт невозможен."
    view-as alert-box error.
    return no-apply.
  end.
  run proc-import in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-alc-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-alc-codes Dialog-Frame
ON CHOOSE OF b-sel-alc-codes IN FRAME Dialog-Frame
DO:
  define variable v-filename as character no-undo .

  run choose-file in this-procedure ( output v-filename ) no-error .
  if error-status :error then do:
    message
      "Ошибка выбора файла."
    view-as alert-box error.
    return no-apply.
  end.
  assign
    v-alc-codes-filename = v-filename
  .
  display
    v-alc-codes-filename
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-sup-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-sup-codes Dialog-Frame
ON CHOOSE OF b-sel-sup-codes IN FRAME Dialog-Frame
DO:
  define variable v-filename as character no-undo .

  run choose-file in this-procedure ( output v-filename ) no-error .
  if error-status :error then do:
    message
      "Ошибка выбора файла."
    view-as alert-box error.
    return no-apply.
  end.
  assign
    v-sup-codes-filename = v-filename
  .
  display
    v-sup-codes-filename
  with frame {&frame-name}.

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
{ gbl/hot-key.i b-exit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-file Dialog-Frame
PROCEDURE choose-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-filename as character no-undo .

define variable v-filename as character no-undo.
define variable v-log as logical no-undo.

  SYSTEM-DIALOG GET-FILE v-filename
                TITLE   "Файл импорта"
                FILTERS "XML файл (*.xml)"   "*.xml",
                        "Все файлы (*.*)"    "*.*"
                MUST-EXIST
                USE-FILENAME
                default-extension ".xml"
                UPDATE v-log.
  if not v-log then do:
    return error.
  end.
  else do:
    assign
      p-filename = v-filename
    .
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
  DISPLAY v-alc-codes-filename v-sup-codes-filename
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-imp b-help v-alc-codes-filename b-sel-alc-codes
         v-sup-codes-filename b-sel-sup-codes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-naim          as character        no-undo.
  define variable v-list          as character        no-undo.
  define variable v-print-graft   as logical          no-undo.
  define variable v-sort-gr       as logical          no-undo.
  define variable v-type-price    as logical          no-undo.
  define variable v-type-val      as logical          no-undo.
  define variable v-found         as logical          no-undo.

  { gbl/getcntxt.i get }
  run uf-get ( input  {&uf-i-egais}
                    , input v-cntxt-userid
                    , output v-list
                    , output v-naim
                    , output v-print-graft
                    , output v-sort-gr
                    , output v-type-price
                    , output v-type-val
                    ).
  if num-entries(v-list) >= 2 then do:
    assign
      v-alc-codes-filename = entry( 1 , v-list )
      v-sup-codes-filename = entry( 2 , v-list )
    .
  end.

  display
    v-alc-codes-filename
    v-sup-codes-filename
  with frame {&frame-name}.
  enable
    b-exit
    b-imp
    b-help
    b-sel-alc-codes
    b-sel-sup-codes
    v-alc-codes-filename
    v-sup-codes-filename
  with frame {&frame-name}.
  view frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import Dialog-Frame
PROCEDURE proc-import :
  define variable v-log as logical   no-undo .
  define variable v-naim          as character        no-undo.
  define variable v-list          as character        no-undo.
  define variable v-print-graft   as logical          no-undo.
  define variable v-sort-gr       as logical          no-undo.
  define variable v-type-price    as logical          no-undo.
  define variable v-type-val      as logical          no-undo.
  define variable v-found         as logical          no-undo.

  message
    "Ипорт классификатора ЕГАИС." skip
    "Начать импорт?"
  view-as alert-box question buttons yes-no update v-log.
  if v-log <> yes then return.
  assign
    v-list = substitute( "&1,&2"
                       , v-alc-codes-filename
                       , v-sup-codes-filename
                       )
  .

  run uf-set ( input {&uf-i-egais}
             , input  v-cntxt-userid
             , input v-list
             , input v-naim
             , input v-print-graft
             , input v-sort-gr
             , input v-type-price
             , input v-type-val
             ) .


  run utl/impegais.p ( input parparentproc
                     , input v-alc-codes-filename
                     , input v-sup-codes-filename
                     ) no-error .
  if error-status :error then do:
    message
      "Ошибка импорта классификатора ЕГАИС." skip
      trim( return-value ) skip
      trim( error-status :get-message(1) ) skip
      trim( error-status :get-message(2) ) skip
      trim( error-status :get-message(3) ) skip
    view-as alert-box error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME