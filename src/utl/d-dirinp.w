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

Запрашивает три директории

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input-output parameter p-dir1 as character no-undo .
define input-output parameter p-dir2 as character no-undo .
define input-output parameter p-dir3 as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запрашивает три директории".
{ cmp/vssrevis.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help fi-dir1 b-sel-dir1 ~
fi-dir2 b-sel-dir2 fi-dir3 b-sel-dir3
&Scoped-Define DISPLAYED-OBJECTS fi-dir1 fi-dir2 fi-dir3

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
     LABEL "Отка&з"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-dir1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b sel dir 1"
     SIZE 3 BY .87.

DEFINE BUTTON b-sel-dir2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b sel dir 2"
     SIZE 3 BY .87.

DEFINE BUTTON b-sel-dir3
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b sel dir 2"
     SIZE 3 BY .87.

DEFINE VARIABLE fi-dir1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Старая"
     VIEW-AS FILL-IN
     SIZE 60.8 BY 1 NO-UNDO.

DEFINE VARIABLE fi-dir2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Новая"
     VIEW-AS FILL-IN
     SIZE 60.9 BY 1 NO-UNDO.

DEFINE VARIABLE fi-dir3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Пакет обновления"
     VIEW-AS FILL-IN
     SIZE 60.8 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     fi-dir1 AT ROW 2.6 COL 15
     b-sel-dir1 AT ROW 2.63 COL 84.8
     fi-dir2 AT ROW 4.13 COL 21 COLON-ALIGNED
     b-sel-dir2 AT ROW 4.17 COL 85
     fi-dir3 AT ROW 5.63 COL 21 COLON-ALIGNED
     b-sel-dir3 AT ROW 5.7 COL 85.1
     SPACE(8.89) SKIP(0.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сравнение директорий *.r кодов"
         CANCEL-BUTTON b-quit.


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

/* SETTINGS FOR FILL-IN fi-dir1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Сравнение директорий *.r кодов */
DO:
  run validate-dir in this-procedure
    (input fi-dir1 :screen-value
    ,input fi-dir2 :screen-value
    ,input fi-dir3 :screen-value
    ) no-error .
  if error-status :error
  then do:
    if return-value <> ""
    then do:
      case return-value :
        when "p-dir1"
        then do:
          apply "entry":u to fi-dir1 .
        end.
        when "p-dir2"
        then do:
          apply "entry":u to fi-dir2 .
        end.
        when "p-dir3"
        then do:
          apply "entry":u to fi-dir3 .
        end.
      end.
    end.
    undo, return no-apply .
  end.
  assign
    p-dir1 = fi-dir1 :screen-value
    p-dir2 = fi-dir2 :screen-value
    p-dir3 = fi-dir3 :screen-value
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сравнение директорий *.r кодов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-dir1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir1 Dialog-Frame
ON CHOOSE OF b-sel-dir1 IN FRAME Dialog-Frame /* b sel dir 1 */
DO:
  { gbl/stdbtn.i }

  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .


  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .

  if v-dir-name <> ""
  then do:
    assign
      fi-dir1 :screen-value = v-dir-name
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-dir2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir2 Dialog-Frame
ON CHOOSE OF b-sel-dir2 IN FRAME Dialog-Frame /* b sel dir 2 */
DO:
  { gbl/stdbtn.i }

  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .


  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .

  if v-dir-name <> ""
  then do:
    assign
      fi-dir2 :screen-value = v-dir-name
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-dir3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir3 Dialog-Frame
ON CHOOSE OF b-sel-dir3 IN FRAME Dialog-Frame /* b sel dir 2 */
DO:
  { gbl/stdbtn.i }

  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .


  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .

  if v-dir-name <> ""
  then do:
    assign
      fi-dir3 :screen-value = v-dir-name
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


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
  RUN enable_UI.
  assign
    fi-dir1 :screen-value = p-dir1
    fi-dir2 :screen-value = p-dir2
    fi-dir3 :screen-value = p-dir3
  .
  assign
    p-dir1 = ""
    p-dir2 = ""
    p-dir3 = ""
  .

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
  DISPLAY fi-dir1 fi-dir2 fi-dir3
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-dir1 b-sel-dir1 fi-dir2 b-sel-dir2 fi-dir3
         b-sel-dir3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-dir Dialog-Frame
PROCEDURE validate-dir :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-dir1 as character no-undo .
  define input  parameter p-dir2 as character no-undo .
  define input  parameter p-dir3 as character no-undo .

  if p-dir1 = ""
  or p-dir1 = ?
  then do:
    message
      "Необходимо ввести имя директории" skip
      view-as alert-box error .
    undo, return error "p-dir1" .
  end.

  if p-dir2 = ""
  or p-dir2 = ?
  then do:
    message
      "Необходимо ввести имя директории" skip
      view-as alert-box error .
    undo, return error "p-dir2" .
  end.

  if p-dir3 = ""
  or p-dir3 = ?
  then do:
    message
      "Необходимо ввести имя директории" skip
      view-as alert-box error .
    undo, return error "p-dir3" .
  end.

  if p-dir1 = p-dir2
  or p-dir2 = p-dir3
  or p-dir1 = p-dir3
  then do:
    message
      "Все директории должны быть различны" skip
      view-as alert-box error .
    undo, return error .
  end.

  assign
    file-info :file-name = p-dir1
  .
  if file-info :file-type = ?
  or index(file-info :file-type, 'D':u) = 0
  then do:
    message
      "Неправильно указана Директория 1" skip
      "" p-dir1 skip
      view-as alert-box error .
    undo, return error "p-dir1" .
  end.

  assign
    file-info :file-name = p-dir2
  .
  if file-info :file-type = ?
  or index(file-info :file-type, 'D':u) = 0
  then do:
    message
      "Неправильно указана Директория 2" skip
      "" p-dir2 skip
      view-as alert-box error .
    undo, return error "p-dir2" .
  end.

  assign
    file-info :file-name = p-dir3
  .
  if file-info :file-type = ?
  or index(file-info :file-type, 'D':u) = 0
  then do:
    message
      "Неправильно указана Директория 3" skip
      "" p-dir3 skip
      view-as alert-box error .
    undo, return error "p-dir3" .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME