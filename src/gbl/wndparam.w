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

Редактирование пользовательских параметров настройки интерфейса

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование пользовательских параметров настройки интерфейса".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 b-default b-delete-size b-help ~
tb-wndmax tb-wndstore fi-description
&Scoped-Define DISPLAYED-OBJECTS tb-wndmax tb-wndstore fi-description

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-default
     LABEL "&По умолчанию"
     SIZE 15 BY 1.

DEFINE BUTTON b-delete-size
     LABEL "&Удалить размеры"
     SIZE 17 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U INITIAL "ПАРАМЕТРЫ ОКНА"
      VIEW-AS TEXT
     SIZE 15 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 3.5.

DEFINE VARIABLE tb-wndmax AS LOGICAL INITIAL no
     LABEL "Максимизировать при открытии и восстановливать сохранённые параметры"
     VIEW-AS TOGGLE-BOX
     SIZE 72 BY .83 NO-UNDO.

DEFINE VARIABLE tb-wndstore AS LOGICAL INITIAL no
     LABEL "Сохранять внешний вид окна"
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-default AT ROW 1 COL 11
     b-delete-size AT ROW 1 COL 26
     b-help AT ROW 1 COL 43
     tb-wndmax AT ROW 4 COL 4
     tb-wndstore AT ROW 5.25 COL 4
     fi-description AT ROW 3 COL 3.5 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3.25 COL 3
     SPACE(2.12) SKIP(1.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры интерфейса"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры интерфейса */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-default
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-default Dialog-Frame
ON CHOOSE OF b-default IN FRAME Dialog-Frame /* По умолчанию */
DO:
  /* удаление настроек пользователя */
  /* в интерфейсе будут показаны настройки на основании параметров конфигурации */
  run gbl/wndpar_d.p
    (input  g#db-num
    ,input  g#userid
    ,input  {&user-window-maximize}
    ) .
  run gbl/wndpar_d.p
    (input  g#db-num
    ,input  g#userid
    ,input  {&user-window-size-store}
    ) .

  run read-values-from-db in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-delete-size
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-delete-size Dialog-Frame
ON CHOOSE OF b-delete-size IN FRAME Dialog-Frame /* Удалить размеры */
DO:
  define variable v-ok as logical   no-undo .
  message
    "Удалить сохранённое значение ширины и высоты для всех окон" skip
    "для пользователя" g#userid skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok = true
  then do:
    run gbl/wndsizea.p
      (input  g#db-num
      ,input  g#userid
      ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-wndmax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-wndmax Dialog-Frame
ON VALUE-CHANGED OF tb-wndmax IN FRAME Dialog-Frame /* Максимизировать при открытии и восстановливать сохранённые параметры */
DO:
  run gbl/wndpar_w.p
    (input  g#db-num
    ,input  g#userid
    ,input  {&user-window-maximize}
    ,input  self :checked
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-wndstore
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-wndstore Dialog-Frame
ON VALUE-CHANGED OF tb-wndstore IN FRAME Dialog-Frame /* Сохранять внешний вид окна */
DO:
  run gbl/wndpar_w.p
    (input  g#db-num
    ,input  g#userid
    ,input  {&user-window-size-store}
    ,input  self :checked
    ) .
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
  RUN enable_UI.

  run read-values-from-db in this-procedure .

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
  DISPLAY tb-wndmax tb-wndstore fi-description
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 b-default b-delete-size b-help tb-wndmax tb-wndstore
         fi-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-values-from-db Dialog-Frame
PROCEDURE read-values-from-db :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-param-value   as logical   no-undo .
  define variable v-default-value as logical   no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      run gbl/wndpar_r.p
        (input  g#db-num
        ,input  g#userid
        ,input  {&user-window-maximize}
        ,output v-param-value
        ,output v-default-value
        ) .
      assign
        tb-wndmax :checked = v-param-value
      .

      run gbl/wndpar_r.p
        (input  g#db-num
        ,input  g#userid
        ,input  {&user-window-size-store}
        ,output v-param-value
        ,output v-default-value
        ) .
      assign
        tb-wndstore :checked = v-param-value
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME