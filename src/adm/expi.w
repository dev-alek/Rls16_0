&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-cnf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-cnf 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт конфигурационных параметров

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/10/04
Author: Dmitry Ukhanov
Creation date: 09/10/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input        parameter p-standalone as logical                  no-undo .
define input        parameter p-selected   as logical                  no-undo .
define input-output parameter p-fname      as character format "x(80)" no-undo .
define input        parameter p-db-list    as character                no-undo .
define       output parameter p-sel-dbs    as character                no-undo .
define       output parameter p-exp-type   as character                no-undo .
define       output parameter p-new-db-num as integer                  no-undo .
define       output parameter p-new-db-key as character                no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт конфигурационных параметров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ adm/cnf-inc.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-cnf

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-file b-exit b-quit b-help RECT-1 FName ~
export-type sel-dbs t-for-db 
&Scoped-Define DISPLAYED-OBJECTS FName export-type sel-dbs t-for-db 

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
     SIZE 3 BY .88 TOOLTIP "Вызов окна выбора файла".

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена":L 
     SIZE 9 BY 1.

DEFINE VARIABLE f-new-db-key LIKE ub.db.db-key
     LABEL "Ключ новой БД" 
     FORMAT "X(25)"
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE f-new-db-num LIKE ub.db.db-num
     LABEL "Номер новой БД" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE FName AS CHARACTER FORMAT "X(256)":U 
     LABEL "Имя файла" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 56 BY 1 TOOLTIP "Файл конфигурации" NO-UNDO.

DEFINE VARIABLE export-type AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все включенные", "all",
"Текущий", "curr",
"Отмеченные", "mark",
"Все кодированные", "all-protect",
"Все обязательные", "all-mandatory"
     SIZE 19.63 BY 4 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 71.5 BY 9.5.

DEFINE VARIABLE sel-dbs AS CHARACTER 
     VIEW-AS SELECTION-LIST MULTIPLE SORT SCROLLBAR-VERTICAL 
     SIZE 9.5 BY 7.5 NO-UNDO.

DEFINE VARIABLE t-for-db AS LOGICAL INITIAL no 
     LABEL "Для новой БД" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-cnf
     b-file AT ROW 2.5 COL 70
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 70
     FName AT ROW 2.5 COL 11.5 COLON-ALIGNED
     export-type AT ROW 5 COL 3.5 NO-LABEL
     sel-dbs AT ROW 5.25 COL 34.5 NO-LABEL WIDGET-ID 4
     t-for-db AT ROW 9.5 COL 4 WIDGET-ID 8
     f-new-db-num AT ROW 10.5 COL 19 COLON-ALIGNED HELP
          "" WIDGET-ID 10
          LABEL "Номер новой БД"
     f-new-db-key AT ROW 11.5 COL 19 COLON-ALIGNED HELP
          "" WIDGET-ID 12
          LABEL "Ключ новой БД"
     "Выводить параметры:" VIEW-AS TEXT
          SIZE 19.88 BY .67 AT ROW 4 COL 2.5
     "БД:" VIEW-AS TEXT
          SIZE 4 BY .67 AT ROW 5.25 COL 29.5 WIDGET-ID 6
     RECT-1 AT ROW 3.75 COL 1.5 WIDGET-ID 2
     SPACE(0.87) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Экспорт конфигурационных параметров":L.


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

/* SETTINGS FOR FILL-IN f-new-db-key IN FRAME d-cnf
   NO-DISPLAY NO-ENABLE LIKE = ub.db.db-key EXP-LABEL EXP-HELP EXP-SIZE */
ASSIGN 
       f-new-db-key:HIDDEN IN FRAME d-cnf           = TRUE.

/* SETTINGS FOR FILL-IN f-new-db-num IN FRAME d-cnf
   NO-DISPLAY NO-ENABLE LIKE = ub.db.db-num EXP-LABEL EXP-HELP EXP-SIZE */
ASSIGN 
       f-new-db-num:HIDDEN IN FRAME d-cnf           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-cnf
ON CHOOSE OF b-exit IN FRAME d-cnf /* Ввод  */
DO:
  ASSIGN
    export-type
    FName
    t-for-db
    f-new-db-num
    f-new-db-key
  .

  if ( sel-dbs:screen-value = ?
       or sel-dbs:screen-value = "":U
     )
    and export-type <> "curr":U
  then do:
    message
      "Необходимо выбрать хотя бы одну БД параметры которой будут выгружаться !"
      view-as alert-box.
    return no-apply .
  end.

  if t-for-db = true
    and num-entries( sel-dbs :screen-value ) > 1
  then do:
    message
      substitute("При выгрузке параметров для новой БД допускается выбирать только одну БД источник!") skip
      view-as alert-box error .
    return no-apply .
  end.

  if trim( FName ) = "":U then do:
    message
      "Необходимо указать имя файла в который будут выгружаться параметры !"
      view-as alert-box.
    return no-apply .
  end.

  assign
    p-fname    = fname
    p-exp-type = export-type
    p-sel-dbs  = sel-dbs:screen-value
  .
  if t-for-db = true then do:
    assign
      p-new-db-num = f-new-db-num
      p-new-db-key = f-new-db-key
    .
  end.
  else do:
    assign
      p-new-db-num = ?
      p-new-db-key = "":U
    .
  end.
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
  ASK-OVERWRITE
  CREATE-TEST-FILE
  DEFAULT-EXTENSION "*.cfg"
  SAVE-AS
  TITLE "Выберите файл для вывода конфигурации"
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
  assign
    p-exp-type = ?
    p-fname    = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME export-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL export-type d-cnf
ON RETURN OF export-type IN FRAME d-cnf
DO:
  apply "TAB" to {&self-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL export-type d-cnf
ON VALUE-CHANGED OF export-type IN FRAME d-cnf
DO:
  assign
    export-type
  .
  if export-type = "curr":U then do:
    disable
      sel-dbs
      with frame {&frame-name}.
  end.
  else do:
    enable
      sel-dbs
      with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-for-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-for-db d-cnf
ON VALUE-CHANGED OF t-for-db IN FRAME d-cnf /* Для новой БД */
DO:
  assign
    t-for-db
  .
  if t-for-db = true then do:
    enable
      f-new-db-num
      f-new-db-key
      with frame {&frame-name}.
  end.
  else do:
    disable
      f-new-db-num
      f-new-db-key
      with frame {&frame-name}.
    hide
      f-new-db-num
      f-new-db-key
      in frame {&frame-name}.
  end.

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

assign
  cur-der                   = session:data-entry-return
  session:data-entry-return = yes
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define variable v-log         as logical   no-undo .

  assign
    fname      = p-fname
    p-exp-type = ?
  .

  run enable_UI.

  if p-db-list <> "":U then do:
    sel-dbs :list-items in frame {&frame-name} = p-db-list  .
  end.

  if p-selected = FALSE then do:
    assign
      v-log = export-type:disable( "Текущий" )
    .
  end.

  apply "entry" to export-type.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

assign
  session:data-entry-return = cur-der
.

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
  DISPLAY FName export-type sel-dbs t-for-db 
      WITH FRAME d-cnf.
  ENABLE b-file b-exit b-quit b-help RECT-1 FName export-type sel-dbs t-for-db 
      WITH FRAME d-cnf.
  {&OPEN-BROWSERS-IN-QUERY-d-cnf}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

