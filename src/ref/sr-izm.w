&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Справочник средств измерений

Автор: Шальнев Иван Сергеевич
Дата создания: 28/12/11
Author: Shalnev Ivan
Creation date: 28/12/11

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
block-level on error undo, throw.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-type-izm-list AS character NO-UNDO.
DEFINE INPUT PARAMETER p-izm-par AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
define output parameter p-sr-type as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник средств измерений".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF}
/*{ gbl/color.i }*/
/*{ ref/sr-izm.i sr-izmerenia ds}*/
{ ref/sr-izm.i dop-sr-izm }
/*{ ref/sr-izm.i " " proc }*/

define shared variable g#db-num as integer no-undo .

DEFINE VARIABLE v-max-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
define variable v-edit-mode as logical no-undo .
define variable v-action-mode as character no-undo . /* что с редактируемой записью: {&add-def}, {&update} */ 
define variable mNotUsedStr as character no-undo fgcolor 12.
define buffer buf_clob-bind for ub.clob-bind.

define variable cb-sr-type-id as integer column-label "Тип"
  format ">9" label "Тип"
  view-as combo-box list-item-pairs
    "Ареометр, отградуирован при 15°С",1,
    "Ареометр, отградуирован при 20°С",2,
    "Поточный плотномер",3,
    "Погружной плотномер",4,
    "Канал измерения плотности (с поточным плотномером)",5,
    "Канал измерения плотности (без поточного плотномера)",6
  inner-lines 5 drop-down-list size-chars 55 by 1
.

&scoped-define view-dop-sr-izm ~
DISPLAY ~
dop-sr-izm.node-code             AT ROW 18 COL 5 LEFT-ALIGNED  SKIP ~
mNotUsedStr                      AT ROW 18 COL 45 LEFT-ALIGNED format "x(42)" no-label SKIP  ~
dop-sr-izm.sr-model              AT ROW 19 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-type               AT ROW 20 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-abs-err-neft-water AT ROW 21 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-abs-err-water      AT ROW 22 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-abs-err-dens       AT ROW 23 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-abs-err-temp-vol   AT ROW 24 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-abs-err-temp-dens  AT ROW 25 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-otnos              AT ROW 26 COL 5 LEFT-ALIGNED  SKIP ~
dop-sr-izm.sr-temp-line          AT ROW 27 COL 5 LEFT-ALIGNED  ~
with FRAME ~{&FRAME-NAME~}

&SCOPED-DEFINE hide-dop-sr-izm ~
hide ~
dop-sr-izm.node-code             ~
in FRAME {&FRAME-NAME} ~
dop-sr-izm.sr-model              ~
mNotUsedStr                      ~
dop-sr-izm.sr-type               ~
dop-sr-izm.sr-abs-err-neft-water ~
dop-sr-izm.sr-abs-err-water      ~
dop-sr-izm.sr-abs-err-dens       ~
dop-sr-izm.sr-abs-err-temp-vol   ~
dop-sr-izm.sr-abs-err-temp-dens  ~
dop-sr-izm.sr-otnos              ~
dop-sr-izm.sr-temp-line          ~
in FRAME {&FRAME-NAME}
/*
&SCOPED-DEFINE disable-dop-sr-izm ~
disable ~
dop-sr-izm.node-code             ~
dop-sr-izm.sr-model              ~
dop-sr-izm.sr-type               ~
dop-sr-izm.sr-abs-err-neft-water ~
dop-sr-izm.sr-abs-err-water      ~
dop-sr-izm.sr-abs-err-dens       ~
dop-sr-izm.sr-abs-err-temp-vol   ~
dop-sr-izm.sr-abs-err-temp-dens  ~
dop-sr-izm.sr-otnos              ~
dop-sr-izm.sr-temp-line          ~
with FRAME {&FRAME-NAME}
*/
&SCOPED-DEFINE disable-dop-sr-izm ~
disable ~
dop-sr-izm.sr-model              ~
cb-sr-type-id               ~
dop-sr-izm.sr-abs-err-neft-water ~
dop-sr-izm.sr-abs-err-water      ~
dop-sr-izm.sr-abs-err-dens       ~
dop-sr-izm.sr-abs-err-temp-vol   ~
dop-sr-izm.sr-abs-err-temp-dens  ~
dop-sr-izm.sr-otnos              ~
with FRAME {&FRAME-NAME}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-sr-izm

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES sr-izmerenia

/* Definitions for BROWSE BR-msf                                        */
&Scoped-define FIELDS-IN-QUERY-BR-sr-izm sr-izmerenia.node-code sr-izmerenia.sr-model sr-izmerenia.sr-type sr-izmerenia.sr-abs-err-neft-water sr-izmerenia.sr-abs-err-water sr-izmerenia.sr-abs-err-dens sr-izmerenia.sr-abs-err-temp-vol sr-izmerenia.sr-abs-err-temp-dens sr-izmerenia.sr-otnos sr-izmerenia.sr-temp-line
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sr-izm
&Scoped-define SELF-NAME BR-sr-izm
&Scoped-define QUERY-STRING-BR-sr-izm FOR EACH sr-izmerenia NO-LOCK
&Scoped-define OPEN-QUERY-BR-sr-izm OPEN QUERY {&SELF-NAME} FOR EACH sr-izmerenia NO-LOCK .
&Scoped-define TABLES-IN-QUERY-BR-sr-izm sr-izmerenia
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sr-izm sr-izmerenia



/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-add b-cng b-del b-sel B-hist B-Help BR-sr-izm

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-look
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-cancel
     LABEL "Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-cng
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel
     LABEL "&Выбор"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Закрыть"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-sr-izm FOR
      sr-izmerenia SCROLLING.
&ANALYZE-RESUME


/* Browse definitions                                                   */
DEFINE BROWSE BR-sr-izm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sr-izm Dialog-Frame _FREEFORM
   QUERY BR-sr-izm NO-LOCK DISPLAY
      sr-izmerenia.node-code
      sr-izmerenia.sr-model
      sr-izmerenia.sr-type-id
      sr-izmerenia.sr-abs-err-neft-water
      sr-izmerenia.sr-abs-err-water
      sr-izmerenia.sr-abs-err-dens
      sr-izmerenia.sr-abs-err-temp-vol
      sr-izmerenia.sr-abs-err-temp-dens
      sr-izmerenia.sr-otnos
      sr-izmerenia.sr-temp-line
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 142 BY 13 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     b-sel at row 1 col 26  WIDGET-ID 10
     b-add AT ROW 1 COL 45 WIDGET-ID 14
     b-cng AT ROW 1 COL 55 WIDGET-ID 4
     b-del AT ROW 1 COL 65 WIDGET-ID 22
     b-look AT ROW 1 COL 75 WIDGET-ID 22
     B-hist AT ROW 1 COL 137
     B-Help AT ROW 1 COL 140.5
     BR-sr-izm AT ROW 4.25 COL 1.5 WIDGET-ID 200
     b-cancel AT ROW 18 COL 88 WIDGET-ID 26
     SPACE(45.87) SKIP(8.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник средств измерений" WIDGET-ID 100.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-sr-izm B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-cancel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-cancel:HIDDEN IN FRAME Dialog-Frame           = TRUE.


/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник средств измерений */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  v-action-mode = {&add-def} .
  RUN ref\sr-izm-frm.w ({&add-def}, ?) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  {&OPEN-QUERY-{&BROWSE-NAME}}
    APPLY "value-changed" TO BROWSE br-sr-izm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  RUN proc-undo-record IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    enable
    b-add when v-edit-mode
    b-cng when v-edit-mode
    b-del when v-edit-mode
    with frame {&frame-name} .
    RETURN NO-APPLY.
  end.
  v-action-mode= "":U.
  enable
  b-add when v-edit-mode
  b-cng when v-edit-mode
  b-del when v-edit-mode
  with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cng
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cng Dialog-Frame
ON CHOOSE OF b-cng IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable vnode-code as integer  no-undo.
  IF NOT AVAILABLE sr-izmerenia THEN RETURN NO-APPLY.
  vnode-code = sr-izmerenia.node-code.
  RUN ref\sr-izm-frm.w ({&update}, sr-izmerenia.node-code) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run reopen-query .
  find first sr-izmerenia where sr-izmerenia.node-code eq  vnode-code no-lock.
  reposition {&BROWSE-NAME} to rowid rowid(sr-izmerenia) no-error .
    APPLY "value-changed" TO BROWSE br-sr-izm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE sr-izmerenia  THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run reopen-query .
    APPLY "value-changed" TO BROWSE br-sr-izm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cng
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-look Dialog-Frame
ON CHOOSE OF b-look IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable vnode-code as integer  no-undo.
  IF NOT AVAILABLE sr-izmerenia THEN RETURN NO-APPLY.
  vnode-code = sr-izmerenia.node-code.
  RUN ref\sr-izm-frm.w ({&lookup}, sr-izmerenia.node-code) .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run reopen-query .
  find first sr-izmerenia where sr-izmerenia.node-code eq  vnode-code no-lock.
  reposition {&BROWSE-NAME} to rowid rowid(sr-izmerenia) no-error .
  APPLY "value-changed" TO BROWSE br-sr-izm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available sr-izmerenia then do :
    if sr-izmerenia.sr-not-used then do:
      message "Средство измерения отмечено как неиспользуемое. Выбор запрещен."
      view-as alert-box warning.
      return no-apply.
    end.
    p-node-code = sr-izmerenia.node-code. 
    p-sr-type = string(sr-izmerenia.sr-type-id).
  end.
  else p-node-code = ? .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  apply "choose" to b-quit .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF AVAILABLE sr-izmerenia THEN DO:

  run ref/csr-izm.w (
                    INPUT parParentProc
                   ,input '':U /*bttns*/
                   ,input 'one':U /*p-mode*/
                   ,input /* X_wth-place.obj-type */ ''
                   ,input /* X_wth-place.obj-code */ 0
                   ,INPUT sr-izmerenia.node-code
                   ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BR-sr-izm
&Scoped-define SELF-NAME BR-sr-izm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-sr-izm Dialog-Frame
ON VALUE-CHANGED OF BR-sr-izm IN FRAME Dialog-Frame
DO:
  define variable vNotUsedStr as character no-undo.
  if b-cancel:visible in frame {&frame-name}  then do:
    return no-apply.
  end.
  IF AVAILABLE sr-izmerenia THEN do:
    /*
    ASSIGN
    dop-sr-izm.node-code             = sr-izmerenia.node-code
    dop-sr-izm.sr-model              = sr-izmerenia.sr-model
    dop-sr-izm.sr-type               = sr-izmerenia.sr-type
    dop-sr-izm.sr-abs-err-neft-water = sr-izmerenia.sr-abs-err-neft-water
    dop-sr-izm.sr-abs-err-water      = sr-izmerenia.sr-abs-err-water
    dop-sr-izm.sr-abs-err-dens       = sr-izmerenia.sr-abs-err-dens
    dop-sr-izm.sr-abs-err-temp-vol   = sr-izmerenia.sr-abs-err-temp-vol
    dop-sr-izm.sr-abs-err-temp-dens  = sr-izmerenia.sr-abs-err-temp-dens
    dop-sr-izm.sr-otnos              = sr-izmerenia.sr-otnos
    dop-sr-izm.sr-temp-line          = sr-izmerenia.sr-temp-line
    .
    {&view-dop-sr-izm}.
    */
    assign
      cb-sr-type-id   = sr-izmerenia.sr-type-id
      vNotUsedStr     = if sr-izmerenia.sr-not-used then "!!! СРЕДСТВО ИЗМЕРЕНИЯ НЕ ИСПОЛЬЗУЕТСЯ !!!"  else ""
    . 
    DISPLAY
      sr-izmerenia.node-code @ dop-sr-izm.node-code AT ROW 18 COL 5 LEFT-ALIGNED  SKIP
      vNotUsedStr @ mNotUsedStr  AT ROW 18 COL 45 LEFT-ALIGNED format "x(42)" no-label SKIP
      sr-izmerenia.sr-model  @ dop-sr-izm.sr-model  AT ROW 19 COL 5 LEFT-ALIGNED  SKIP
      cb-sr-type-id    AT ROW 20 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-neft-water @ dop-sr-izm.sr-abs-err-neft-water AT ROW 21 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-water      @ dop-sr-izm.sr-abs-err-water      AT ROW 22 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-dens       @ dop-sr-izm.sr-abs-err-dens       AT ROW 23 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-temp-vol   @ dop-sr-izm.sr-abs-err-temp-vol   AT ROW 24 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-temp-dens  @ dop-sr-izm.sr-abs-err-temp-dens  AT ROW 25 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-otnos              @ dop-sr-izm.sr-otnos              AT ROW 26 COL 5 LEFT-ALIGNED  SKIP
    with FRAME {&FRAME-NAME} .
  END.
  /*
  ELSE DO:
    {&view-dop-sr-izm}.
  END.
  */
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
{ gbl/getcntxt.i GET }
  IF LOOKUP(p-mode, {&UPDATE} + {&comma-char} + {&LOOKUP}) = 0  THEN DO:
    MESSAGE
    substitute("Неверное значение параметров p-mode = &1"
    , p-mode)
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  END.
  IF p-mode = {&UPDATE}
  AND LOOKUP("b-sel", bttns) > 0   THEN DO:
    MESSAGE
    substitute("Неверное значение параметров bttns = &1 и/или p-mode = &2"
               , bttns
               , p-mode)
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  END.
  v-node-code = p-node-code.
  RUN Myenable.
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
  ENABLE b-quit b-sel b-add b-cng b-del B-hist B-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
  FRAME Dialog-Frame:visible = true
.

/*
  if p-mode = {&update}
  and v-cntxt-db-num > 0 then do:
    MESSAGE
    substitute("Нельзя редактировать справочник в УБД")
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  end.
*/
if p-mode = {&UPDATE} then do:
  v-edit-mode = yes.
end.
v-action-mode = "":U .
/* FIND FIRST dop-sr-izm. */
enable
br-sr-izm
b-add WHEN v-edit-mode and g#db-num = 0
b-cng WHEN v-edit-mode and g#db-num = 0
b-del WHEN v-edit-mode and g#db-num = 0
b-look
b-hist
b-help
b-quit
b-sel when not v-edit-mode
WITH FRAME {&FRAME-NAME}
.
IF p-mode <> {&UPDATE} THEN DO:
  b-quit:COLUMN  = 1.
  b-quit:label in frame {&frame-name} = "&Выход".
END.
run reopen-query .
APPLY "value-changed" TO BROWSE br-sr-izm.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE BUFFER buf_sr-izm FOR sr-izmerenia.
define variable v-del-confirm as logical no-undo. /* если вдруг случайно нажали */
/*
IF sr-izmerenia.node-code <= v-max-node-code  THEN DO:
  MESSAGE
  "К сожалению, удалить эту запись уже невозможно!!!" SKIP
  "Она сохранена в БД"
   VIEW-AS ALERT-BOX.
   undo, return error .
END.
FIND FIRST buf_sr-izm WHERE RECID(buf_sr-izm) = RECID(sr-izmerenia) NO-ERROR.
*/
define variable Msg as character no-undo.
define variable v-retfl as logical no-undo.
Msg = "".
v-retfl = false.

  v-del-confirm = false.
  message substitute("Удалить запись о средстве измерения &1 &2?", sr-izmerenia.node-code, sr-izmerenia.sr-model)
    view-as alert-box question buttons yes-no update v-del-confirm .
  if v-del-confirm then do transaction:

    run ref/sr-izm03.p
    (input sr-izmerenia.node-code /* p-node-code (int) */
    ) .
    {&OPEN-QUERY-{&BROWSE-NAME}}
    APPLY "value-changed" TO BROWSE br-sr-izm.
    
    v-retfl = true.
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError при удалении в sr-izmerenia" .
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . else Msg = "ProError при удалении в sr-izmerenia" .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error при удалении в sr-izmerenia" .
    end catch .
    finally :
      if v-retfl then .
      else do:
        message Msg view-as alert-box error.
        return error.
      end.
    end finally .
  end.
  else return error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
  if p-type-izm-list = ""
  then do :
    if p-izm-par = ""
    then do :
      {&OPEN-QUERY-{&BROWSE-NAME}}
    end .
    else do :
      open query BR-sr-izm for each sr-izmerenia no-lock where (sr-izmerenia.sr-level and p-izm-par = "lvl")
                                                            or (sr-izmerenia.sr-density and p-izm-par = "dnst")
                                                            or (sr-izmerenia.sr-temperature and p-izm-par = "tmp")
                                                            .
    end .
  end .
  else do :
    if p-izm-par = ""
    then do :
      open query BR-sr-izm for each sr-izmerenia no-lock where can-do(p-type-izm-list, string(sr-izmerenia.sr-type-izm)) .
    end .
    else do :
      open query BR-sr-izm for each sr-izmerenia no-lock where can-do(p-type-izm-list, string(sr-izmerenia.sr-type-izm))
                                                           and ((sr-izmerenia.sr-level and p-izm-par = "lvl")
                                                            or (sr-izmerenia.sr-density and p-izm-par = "dnst")
                                                            or (sr-izmerenia.sr-temperature and p-izm-par = "tmp"))
                                                            .
    end .
  end .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-record Dialog-Frame
PROCEDURE proc-save-record :
define input parameter p-action as character no-undo.
define variable v-node-code as integer no-undo .
define variable v-rec       as recid no-undo .
define variable Msg         as character no-undo.
define variable v-retfl     as logical no-undo.
define variable v-err-field as character no-undo .
DEFINE BUFFER buf_sr-izm FOR sr-izmerenia.
  
ASSIGN
FRAME {&FRAME-NAME}
dop-sr-izm.sr-model
cb-sr-type-id
dop-sr-izm.sr-abs-err-neft-water
dop-sr-izm.sr-abs-err-water
dop-sr-izm.sr-abs-err-dens
dop-sr-izm.sr-abs-err-temp-vol
dop-sr-izm.sr-abs-err-temp-dens
dop-sr-izm.sr-otnos
.

/* проверки значений */
define variable v-msg2  as character no-undo . /* "...воды выходит за границы допустимого диапазона..." */
define variable v-delta as decimal decimals 2 no-undo . /* границы допустимого диапазона абсолютной погрешности измерений */

  if dop-sr-izm.sr-model > "" then .
  else do: /* Название не может быть пустым */
    message "Пожалуйста заполните наименование модели средства измерения"
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-model in frame {&frame-name} .
    return error .
  end .

  assign
    v-msg2 = "выходит за границы допустимого диапазона"
    v-delta = 3 
  .
  if dop-sr-izm.sr-abs-err-neft-water > v-delta or dop-sr-izm.sr-abs-err-neft-water < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 мм",
                 dop-sr-izm.sr-abs-err-neft-water:label in frame {&frame-name}, v-msg2, {&new-line}, string(v-delta, "9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-neft-water in frame {&frame-name} .
    return error .
  end.
  if dop-sr-izm.sr-abs-err-water > v-delta or dop-sr-izm.sr-abs-err-water < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 мм",
                 dop-sr-izm.sr-abs-err-water:label in frame {&frame-name}, v-msg2, {&new-line}, string(v-delta, "9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-water in frame {&frame-name} .
    return error .
  end.
  v-delta = 0.5 .
  if dop-sr-izm.sr-abs-err-dens > v-delta or dop-sr-izm.sr-abs-err-dens < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 кг/м3",
                 dop-sr-izm.sr-abs-err-dens:label in frame {&frame-name}, v-msg2, {&new-line}, string(v-delta, "9.9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-dens in frame {&frame-name} .
    return error .
  end.
  if dop-sr-izm.sr-abs-err-temp-vol > v-delta or dop-sr-izm.sr-abs-err-temp-vol < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 °С",
                 dop-sr-izm.sr-abs-err-temp-vol:label in frame {&frame-name}, v-msg2, {&new-line}, string(v-delta, "9.9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-temp-vol in frame {&frame-name} .
    return error .
  end.
  if dop-sr-izm.sr-abs-err-temp-dens > v-delta or dop-sr-izm.sr-abs-err-temp-dens < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 °С",
                 dop-sr-izm.sr-abs-err-temp-dens:label in frame {&frame-name}, v-msg2, {&new-line}, string(v-delta, "9.9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-temp-dens in frame {&frame-name} .
    return error .
  end.
  v-delta = 0.05 .
  if dop-sr-izm.sr-otnos > v-delta or dop-sr-izm.sr-otnos < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 %",
                 dop-sr-izm.sr-otnos:label in frame {&frame-name}, v-msg2, {&new-line}, string(v-delta, "9.99") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-otnos in frame {&frame-name} .
    return error .
  end.

  assign
    dop-sr-izm.sr-type-id   = cb-sr-type-id
    v-node-code = if p-action = {&add-def} then next-value (s-sr-izmerenia, {&db-name_schema}) else dop-sr-izm.node-code
    Msg = "":U
    v-retfl = false
  .

  do transaction :
    run ref/sr-izm01.p
    (input v-node-code /* p-node-code (int) */
    ,input dop-sr-izm.sr-model /* p-sr-model (chr) */
    ,input dop-sr-izm.sr-type-id /* p-sr-type-id (int) */
    ,input dop-sr-izm.sr-abs-err-neft-water /* p-sr-abs-err-neft-water (dec) */
    ,input dop-sr-izm.sr-abs-err-water /* p-sr-abs-err-water (dec) */
    ,input dop-sr-izm.sr-abs-err-dens /* p-sr-abs-err-dens (dec) */
    ,input dop-sr-izm.sr-abs-err-temp-vol /* p-sr-abs-err-temp-vol (dec) */
    ,input dop-sr-izm.sr-abs-err-temp-dens /* p-sr-abs-err-temp-dens (dec) */
    ,input dop-sr-izm.sr-otnos /* p-sr-otnos (dec) */
    ,input dop-sr-izm.sr-temp-line /* p-sr-temp-line (dec) */
    ) .
    DELETE dop-sr-izm.
    find first buf_sr-izm no-lock where buf_sr-izm.node-code = v-node-code no-error .
    v-rec = if available buf_sr-izm then RECID(buf_sr-izm) else ?.
    v-retfl = true.
    
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError при добавлении в sr-izmerenia" .
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . else Msg = "ProError при добавлении в sr-izmerenia" .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error при добавлении в sr-izmerenia" .
    end catch .
    finally :
      if v-retfl then .
      else do:
        message Msg view-as alert-box error.
        return error.
      end.
    end finally .
  end . /* end_of transaction */

{&disable-dop-sr-izm}.
HIDE b-cancel IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-{&BROWSE-NAME}}
REPOSITION br-sr-izm TO RECID v-rec.
APPLY "value-changed" TO br-sr-izm.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-undo-record Dialog-Frame
PROCEDURE proc-undo-record :
delete dop-sr-izm.
/*
create dop-sr-izm.
RELEASE dop-sr-izm.
FIND FIRST dop-sr-izm.
*/
{&disable-dop-sr-izm}.
HIDE b-cancel IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" TO br-sr-izm IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
