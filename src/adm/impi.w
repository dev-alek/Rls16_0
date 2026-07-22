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

Установка параметров импорта конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input-output parameter par-fname    as character format "x(80)" no-undo.
define       output parameter par-clearcnf as logical   initial false  no-undo.
define       output parameter par-uselast  as logical   initial true   no-undo.

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
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help ClearCnf UseLast FName ~
b-file 
&Scoped-Define DISPLAYED-OBJECTS ClearCnf UseLast FName 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-file 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL "b-file" 
     SIZE 2.88 BY .92.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена":L 
     SIZE 10 BY 1.

DEFINE VARIABLE FName AS CHARACTER FORMAT "X(256)":U 
     LABEL "Имя файла" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 51.13 BY 1 TOOLTIP "Имя файла конфигурации" NO-UNDO.

DEFINE VARIABLE ClearCnf AS LOGICAL INITIAL no 
     LABEL "Удалить существующие" 
     VIEW-AS TOGGLE-BOX
     SIZE 30.25 BY .83 TOOLTIP "Существующий набор параметров будет полностью удален" NO-UNDO.

DEFINE VARIABLE UseLast AS LOGICAL INITIAL yes 
     LABEL "Заменять дублируемые" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.75 BY .83 TOOLTIP "Параметры из импортируемого файла заменят ранее существующие" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-cnf
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 60
     ClearCnf AT ROW 3 COL 14
     UseLast AT ROW 4 COL 14
     FName AT ROW 5 COL 12 COLON-ALIGNED
     b-file AT ROW 5 COL 66
     SPACE(1.49) SKIP(0.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Импорт конфигурации":L.


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

ASSIGN 
       ClearCnf:AUTO-RESIZE IN FRAME d-cnf      = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-cnf
ON CHOOSE OF b-exit IN FRAME d-cnf /* Ввод  */
DO:
  assign 
    UseLast
    ClearCnf
    fname
  .
  assign 
    par-fname = fname
    par-clearcnf = ClearCnf
    par-uselast = UseLast
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file d-cnf
ON CHOOSE OF b-file IN FRAME d-cnf /* b-file */
DO:
    define variable is-choosen as logical no-undo.

    SYSTEM-DIALOG GET-FILE fname
    FILTERS "Файлы конфигурации *.cfg" "*.cfg",
            "Все файлы"  "*.*"
    must-exist
    TITLE "Выберите файл для импорта конфигурации"
    USE-FILENAME
    UPDATE is-choosen.

    if is-choosen then do:
       display 
         fname 
         with frame {&frame-name}.
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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-cnf 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable cur-der as logical no-undo.

  cur-der = session:data-entry-return.
  session:data-entry-return = yes.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

fname = search (par-fname).
if fname <> ? then par-fname = fname.

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
  DISPLAY ClearCnf UseLast FName 
      WITH FRAME d-cnf.
  ENABLE b-exit b-quit b-help ClearCnf UseLast FName b-file 
      WITH FRAME d-cnf.
  {&OPEN-BROWSERS-IN-QUERY-d-cnf}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

