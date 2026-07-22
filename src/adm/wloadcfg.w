&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-cnf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-cnf
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Загрузка конфигурационных параметров

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input-output parameter par-fname    as character format "x(80)" no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт конфигурационных параметров".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-cnf

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-file b-quit b-help FName
&Scoped-Define DISPLAYED-OBJECTS FName loc-db-key

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL "b-file"
     SIZE 2.88 BY .92.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 9 BY 1.

DEFINE VARIABLE FName AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя файла"
     VIEW-AS FILL-IN NATIVE
     SIZE 51 BY 1 TOOLTIP "Имя файла конфигурации" NO-UNDO.

DEFINE VARIABLE loc-db-key AS CHARACTER FORMAT "X(256)":U
     LABEL "Ключ базы"
      VIEW-AS TEXT
     SIZE 51 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-cnf
     b-exit AT ROW 1 COL 2
     b-file AT ROW 3.54 COL 64
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 60
     FName AT ROW 3.5 COL 11 COLON-ALIGNED
     loc-db-key AT ROW 2.5 COL 11 COLON-ALIGNED
     SPACE(6.37) SKIP(2.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Загрузка конфигурационных параметров":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-cnf
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-cnf:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN loc-db-key IN FRAME d-cnf
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-cnf
ON CHOOSE OF b-exit IN FRAME d-cnf /* Ввод  */
DO:
  apply "leave" to FName in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file d-cnf
ON CHOOSE OF b-file IN FRAME d-cnf /* b-file */
DO:
define variable is-choosen as logical no-undo.
    SYSTEM-DIALOG GET-FILE Fname
    FILTERS "Файлы конфигурации *.cfg" "*.cfg",
            "Все файлы"  "*.*"
    must-exist
    TITLE "Выберите файл для импорта конфигурации"
    USE-FILENAME
    UPDATE is-choosen.

    if is-choosen then do:
       display fname with frame {&frame-name}.
       par-fname = fname.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-cnf
ON CHOOSE OF b-quit IN FRAME d-cnf /* Отмена */
DO:
  par-fname = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FName
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FName d-cnf
ON LEAVE OF FName IN FRAME d-cnf /* Имя файла */
DO:
  assign fname.
  par-fname = fname.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-cnf


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable cur-der as logical no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db       for ub.db .

cur-der = session:data-entry-return.
session:data-entry-return = yes.

fname = search (par-fname).
if fname <> ? then par-fname = fname.

find first buf_sys-ctrl no-lock.
find buf_db no-lock
  where buf_db.db-num = buf_sys-ctrl.db-num
.
assign
  loc-db-key = buf_db.db-key
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
session:data-entry-return = cur-der .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-cnf  _DEFAULT-DISABLE
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
  HIDE FRAME d-cnf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-cnf  _DEFAULT-ENABLE
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
  DISPLAY FName loc-db-key
      WITH FRAME d-cnf.
  ENABLE b-exit b-file b-quit b-help FName
      WITH FRAME d-cnf.
  {&OPEN-BROWSERS-IN-QUERY-d-cnf}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
