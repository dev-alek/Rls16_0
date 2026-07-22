&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Макрос формирования истории

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/19/05
Author: Bakhtadze Natalya
Creation date: 09/19/05


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define INPUT PARAMETER parparentproc as WIDGET-HANDLE NO-UNDO.
define INPUT PARAMETER p-callback-handle AS HANDLE NO-UNDO.
define INPUT PARAMETER p-title AS character NO-UNDO.
define INPUT PARAMETER bttns AS character NO-UNDO.
define input-output parameter p-current-step as integer no-undo .
define INPUT PARAMETER p-max-id AS integer NO-UNDO.
define OUTPUT PARAMETER p-result AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/listhist.i macro-list shared }
{ gbl/prn-lib.i }
DEFINE BUFFER buf_macro-list-hist FOR macro-list-hist.
DEFINE VARIABLE v-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-action AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-stop AS logical NO-UNDO.
DEFINE VARIABLE v-pause AS logical NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-macro

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_macro-list-hist

/* Definitions for BROWSE BR-macro                                      */
&Scoped-define FIELDS-IN-QUERY-BR-macro buf_macro-list-hist.done (if buf_macro-list-hist.line = 0 then string(buf_macro-list-hist.id, ">>>>>>>>9") else fill({&space-char} , 9) ) @ v-id (if buf_macro-list-hist.ITEM_ <> '':U THEN buf_macro-list-hist.hist-mode else '':U) @ v-action buf_macro-list-hist.num-add buf_macro-list-hist.num-recs buf_macro-list-hist.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-macro
&Scoped-define SELF-NAME BR-macro
&Scoped-define QUERY-STRING-BR-macro FOR EACH buf_macro-list-hist
&Scoped-define OPEN-QUERY-BR-macro OPEN QUERY {&SELF-NAME} FOR EACH buf_macro-list-hist.
&Scoped-define TABLES-IN-QUERY-BR-macro buf_macro-list-hist
&Scoped-define FIRST-TABLE-IN-QUERY-BR-macro buf_macro-list-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-macro}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-play B-step B-pause B-stop B-save B-Help

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

DEFINE BUTTON B-pause AUTO-END-KEY
     IMAGE-UP FILE "cmp/pause.bmp":U
     IMAGE-DOWN FILE "cmp/pausei.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/pausei.bmp":U
     LABEL "&||"
     SIZE 4 BY 1.25 TOOLTIP "Приостановка выполнения макроса истории".

DEFINE BUTTON B-play
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".

DEFINE BUTTON B-save
     IMAGE-UP FILE "cmp/save.bmp":U
     LABEL "&Сохранить"
     SIZE 4 BY 1.25.

DEFINE BUTTON B-step
     IMAGE-UP FILE "cmp/step.bmp":U
     IMAGE-DOWN FILE "cmp/stepi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stepi.bmp":U
     LABEL "&.>"
     SIZE 4 BY 1.25 TOOLTIP "Пошаговое выполнение макроса формирования истории".

DEFINE BUTTON B-stop AUTO-END-KEY
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Прекращение выполнения макроса - удаление макроса из памяти".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-macro FOR
      buf_macro-list-hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-macro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-macro Dialog-Frame _FREEFORM
  QUERY BR-macro DISPLAY
      buf_macro-list-hist.done COLUMN-LABEL "*" FORMAT "+/"
(if buf_macro-list-hist.line = 0
   then string(buf_macro-list-hist.id, ">>>>>>>>9")
   else fill({&space-char} , 9)
  ) @ v-id COLUMN-LABEL "№" FORMAT "X(9)"
(if buf_macro-list-hist.ITEM_ <> '':U
THEN buf_macro-list-hist.hist-mode
else '':U) @ v-action  COLUMN-LABEL "Действие" FORMAT "X(8)"
buf_macro-list-hist.num-add   COLUMN-LABEL "записей" FORMAT "->>>>>>>>9"
buf_macro-list-hist.num-recs   COLUMN-LABEL " = итого" FORMAT ">>>>>>>>9"
buf_macro-list-hist.des   COLUMN-LABEL "Множество" FORMAT "X(155)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-play AT ROW 1 COL 1
     B-step AT ROW 1 COL 5
     B-pause AT ROW 1 COL 9
     B-stop AT ROW 1 COL 13
     B-save AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.88
     BR-macro AT ROW 3 COL 1
     SPACE(0.24) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Макрос формирования истории".


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
/* BROWSE-TAB BR-macro B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE BR-macro IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-macro
/* Query rebuild information for BROWSE BR-macro
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_macro-list-hist.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-macro */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Макрос формирования истории */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pause
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pause Dialog-Frame
ON CHOOSE OF B-pause IN FRAME Dialog-Frame /* || */
DO:
  ASSIGN
  v-pause = YES.
  p-result = 'b-pause'.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-play
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-play Dialog-Frame
ON CHOOSE OF B-play IN FRAME Dialog-Frame /* > */
DO:
DEFINE VARIABLE v-id AS INTEGER NO-UNDO.
DEFINE VARIABLE v-start AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO INIT YES.
define variable v-dop as character no-undo .
DEFINE BUFFER loc_macro-list-hist FOR macro-list-hist.
DEFINE BUFFER loc_tree-macro-list-hist FOR macro-list-hist.
IF NOT AVAILABLE buf_macro-list-hist THEN RETURN NO-APPLY.
ASSIGN
v-start = 1
glog = no
.
if buf_macro-list-hist.line <> 0 then do:
  message
  "Для выполнения можно выбрать только действие <Верхнего> уровня"
  view-as alert-box error .
  return no-apply.
end.

DO WHILE glog OR v-start <= p-max-id:
  _loc-macro:
  FOR EACH loc_macro-list-hist WHERE
           loc_macro-list-hist.id >= v-start
  by loc_macro-list-hist.id:
    if loc_macro-list-hist.done = yes then do:
      assign
      v-start = loc_macro-list-hist.id + 1.
      next _loc-macro.
    end.

    RUN proc-macro-play IN p-callback-handle(INPUT v-start, input no, INPUT p-max-id) NO-ERROR.

    IF ERROR-STATUS:ERROR
    or entry(1, return-value, {&delim-par})  = "error":U
    THEN DO:
      assign
      v-dop = return-value
      v-dop = substring(v-dop, index(v-dop, {&delim-par}) + 1)
      .
      IF v-start < p-max-id THEN DO:
        MESSAGE
        substitute("Произошла ошибка при выполнении макроса&1&2&1&3&1" +
                    "продолжить выполнение?"
                    , {&NEW-LINE}
                    , ERROR-STATUS:GET-MESSAGE(1)
                    , v-dop)
        VIEW-AS ALERT-BOX ERROR BUTTONS YES-NO UPDATE glog.
        IF NOT glog THEN RETURN no-apply.
        glog = no.
      END.
      ELSE DO:
        MESSAGE
        substitute("Произошла ошибка при выполнении макроса&1&2&1&3&1"
                    , {&NEW-LINE}
                    , ERROR-STATUS:GET-MESSAGE(1)
                    , RETURN-VALUE)
        VIEW-AS ALERT-BOX ERROR.
      END.
    END. /*error-status*/
    ASSIGN
    loc_macro-list-hist.done = YES.
    for each loc_tree-macro-list-hist where
          loc_tree-macro-list-hist.id = loc_macro-list-hist.id:
      loc_tree-macro-list-hist.done = yes.
    end.
    p-current-step = loc_macro-list-hist.id.
    v-start = v-start + 1.
    br-macro:REFRESH().
    APPLY "CURSOR-DOWN" to br-macro.
    PROCESS EVENTS.
    RUN get-pause IN THIS-PROCEDURE (OUTPUT v-pause).
    RUN get-stop IN THIS-PROCEDURE (OUTPUT v-stop).
    IF v-stop  OR v-pause THEN RETURN NO-APPLY.
  END. /*for each loc_macro-list-hist*/
  v-start = v-start + 1.
END. /*do while*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  DEFINE VARIABLE f-name AS CHARACTER NO-UNDO.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  define variable filter-str1 as character no-undo .
  define variable filter-str2 as character no-undo .
  DEFINE BUFFER buf_macro-list-hist FOR macro-list-hist.
  find first buf_macro-list-hist no-error.
  if not available buf_macro-list-hist then do:
    message
    "Нет ни одной записи макроса формирования списка" skip
    "Нечего сохранять"
    view-as alert-box.
    return no-apply.

  end.

    assign
    f-name = "default." + entry(2, p-title, {&delim-par} )
    filter-str1 = substitute("&1 *.&2", entry(1, p-title, {&delim-par}), entry(2, p-title, {&delim-par} ))
    filter-str2 = substitute("*.&1", entry(2, p-title, {&delim-par}))
    glog = yes
    .
  system-dialog get-file f-name
    filters filter-str1 filter-str2
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension entry(2, p-title, {&delim-par} ).
  if not glog then do:
    apply "entry" to br-macro in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  for each buf_macro-list-hist:
      export stream PrnLibStream
      buf_macro-list-hist.
  end.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-step
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-step Dialog-Frame
ON CHOOSE OF B-step IN FRAME Dialog-Frame /* .> */
DO:
DEFINE VARIABLE v-id AS INTEGER NO-UNDO.
define variable v-dop as character no-undo .
DEFINE BUFFER loc_macro-list-hist FOR macro-list-hist.
DEFINE BUFFER loc_tree-macro-list-hist FOR macro-list-hist.
  IF NOT AVAILABLE buf_macro-list-hist
  or buf_macro-list-hist.done  THEN do:
    BELL.
    RETURN NO-APPLY.
  end.
  find first loc_macro-list-hist where loc_macro-list-hist.id = buf_macro-list-hist.id.
  RUN proc-macro-play IN p-callback-handle(INPUT buf_macro-list-hist.id, input yes, INPUT p-max-id) NO-ERROR.
  IF ERROR-STATUS:ERROR
  or entry(1, return-value, {&delim-par})  = "error":U
  THEN DO:
    assign
    v-dop = return-value
    v-dop = substring(v-dop, index(v-dop, {&delim-par}) + 1)
    .
     MESSAGE
      substitute("Произошла ошибка при выполнении макроса&1&2&1&3"
                 , {&NEW-LINE}
                 , ERROR-STATUS:GET-MESSAGE(1)
                 , v-dop)
      VIEW-AS ALERT-BOX ERROR.
  END.
  if not (error-status:error
         and return-value = '':U) then DO:
    ASSIGN
    buf_macro-list-hist.done = YES.
    for each loc_tree-macro-list-hist where
          loc_tree-macro-list-hist.id = loc_macro-list-hist.id:
      loc_tree-macro-list-hist.done = yes.
    end.
    br-macro:REFRESH().
    find first loc_macro-list-hist where loc_macro-list-hist.id > buf_macro-list-hist.id no-error .
    if available loc_macro-list-hist then do:
      REPOSITION br-macro TO RECID RECID(loc_macro-list-hist).
      p-current-step = loc_macro-list-hist.id.
    end.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-stop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-stop Dialog-Frame
ON CHOOSE OF B-stop IN FRAME Dialog-Frame /* [ ] */
DO:
define buffer loc_macro-list-hist for macro-list-hist.
  ASSIGN
  v-stop = YES.
  find first loc_macro-list-hist no-lock where
            loc_macro-list-hist.id > 0 AND
            loc_macro-list-hist.done = no no-error .
  if not available loc_macro-list-hist then
  p-result = 'end':U.
  else do:
    p-result = (if p-result = '':u then 'b-stop' else p-result).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-macro
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
  ENABLE B-play B-step B-pause B-stop B-save B-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-pause Dialog-Frame
PROCEDURE get-pause :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-pause AS LOGICAL NO-UNDO.
IF v-pause  THEN
p-pause = YES.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-stop Dialog-Frame
PROCEDURE get-stop :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-stop AS LOGICAL NO-UNDO.
IF v-stop  THEN
p-stop = YES.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer find_macro-list-hist for macro-list-hist.
ASSIGN
buf_macro-list-hist.des:RESIZABLE IN BROWSE br-macro = YES
buf_macro-list-hist.des:width IN BROWSE br-macro = 60
frame {&frame-name}:title = entry(1, p-title, {&delim-par})
.
ENABLE
B-play  WHEN lookup("b-play", bttns) > 0
B-step   WHEN lookup("b-step", bttns) > 0
b-save
B-pause
B-stop
B-save
B-Help
br-macro
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
if p-current-step <> 0  then do:
  find first find_macro-list-hist no-lock where
           find_macro-list-hist.id = p-current-step
       and find_macro-list-hist.line = 0 no-error .
  if available find_macro-list-hist then do:
    reposition br-macro to recid recid(find_macro-list-hist) no-error .
  end.
  apply "ENTRY" to br-macro.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME