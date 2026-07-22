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

Информация, посылаемая на кассу для типа ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-cardname-sent AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-custom-sent AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация, посылаемая на кассу для типа ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/dct-algo.i }
{ gbl/get-regf.i }
{ gbl/key-rec.i }
DEFINE VARIABLE v-sum-id-value1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sum-id-value2 AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help cardname-sent ~
t-sum-id-output f-sum-id-output b-sum-id t-sum-id-output-2 ~
f-sum-id-output-2 b-sum-id-2
&Scoped-Define DISPLAYED-OBJECTS cardname-sent t-sum-id-output ~
f-sum-id-output t-sum-id-output-2 f-sum-id-output-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sum-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.

DEFINE BUTTON b-sum-id-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.

DEFINE VARIABLE f-sum-id-output AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 64 BY 1 NO-UNDO.

DEFINE VARIABLE f-sum-id-output-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 64 BY 1 NO-UNDO.

DEFINE VARIABLE cardname-sent AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", "1":U,
"Item 2", "2":U
     SIZE 25.5 BY 1.77 NO-UNDO.

DEFINE VARIABLE t-sum-id-output AS LOGICAL INITIAL no
     LABEL "Настраивать поле 1"
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-sum-id-output-2 AS LOGICAL INITIAL no
     LABEL "Настраивать поле 2"
     VIEW-AS TOGGLE-BOX
     SIZE 24.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     cardname-sent AT ROW 3 COL 44.5 NO-LABEL
     t-sum-id-output AT ROW 5.27 COL 2 WIDGET-ID 26
     f-sum-id-output AT ROW 5.27 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     b-sum-id AT ROW 5.27 COL 93 WIDGET-ID 6
     t-sum-id-output-2 AT ROW 7.4 COL 1.5 WIDGET-ID 28
     f-sum-id-output-2 AT ROW 7.4 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     b-sum-id-2 AT ROW 7.4 COL 93 WIDGET-ID 20
     "Поле ДЕРЖАТЕЛЬ карты" VIEW-AS TEXT
          SIZE 23 BY 1 AT ROW 3 COL 3 WIDGET-ID 16
          FGCOLOR 4
     SPACE(73.79) SKIP(5.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         FGCOLOR 4
         TITLE FGCOLOR 4 ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       f-sum-id-output:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-sum-id-output-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  ASSIGN
  cardname-sent
  p-cardname-sent = cardname-sent
  p-custom-sent = substitute("&1,&2"
                             ,v-sum-id-value1
                             ,v-sum-id-value2)
  p-ok = YES
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sum-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sum-id Dialog-Frame
ON CHOOSE OF b-sum-id IN FRAME Dialog-Frame /* Btn 1 */
DO:
  RUN proc-b-sum-id IN THIS-PROCEDURE (INPUT-OUTPUT v-sum-id-value1) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-sum-id-output =  dct-algo_custom-sent-description(v-sum-id-value1).
  DISPLAY
  f-sum-id-output
  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sum-id-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sum-id-2 Dialog-Frame
ON CHOOSE OF b-sum-id-2 IN FRAME Dialog-Frame /* Btn 1 */
DO:
  RUN proc-b-sum-id IN THIS-PROCEDURE (INPUT-OUTPUT v-sum-id-value2) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-sum-id-output-2 =  dct-algo_custom-sent-description(v-sum-id-value2).
  DISPLAY
  f-sum-id-output-2
  WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sum-id-output
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sum-id-output Dialog-Frame
ON VALUE-CHANGED OF t-sum-id-output IN FRAME Dialog-Frame /* Настраивать поле 1 */
DO:
  ASSIGN
  t-sum-id-output.
  CASE t-sum-id-output:
    WHEN YES  THEN DO:
      ENABLE b-sum-id
      WITH FRAME {&FRAME-NAME}.
      APPLY "CHOOSE" TO b-sum-id.
    END.
    WHEN NO THEN DO:
      ASSIGN
      v-sum-id-VALUE1 = {&question-mark}
      f-sum-id-output =  dct-algo_custom-sent-description(v-sum-id-value1).
      DISPLAY
      f-sum-id-output
      WITH FRAME {&FRAME-NAME}.
      DISABLE b-sum-id
      WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sum-id-output-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sum-id-output-2 Dialog-Frame
ON VALUE-CHANGED OF t-sum-id-output-2 IN FRAME Dialog-Frame /* Настраивать поле 2 */
DO:
    ASSIGN
  t-sum-id-output-2.
  CASE t-sum-id-output-2:
    WHEN YES  THEN DO:
      ENABLE b-sum-id-2
      WITH FRAME {&FRAME-NAME}.
      APPLY "CHOOSE" TO b-sum-id-2.
    END.
    WHEN NO THEN DO:
      ASSIGN
      v-sum-id-VALUE2 = {&question-mark}
      f-sum-id-output-2 =  dct-algo_custom-sent-description(v-sum-id-value2).
      DISPLAY
      f-sum-id-output-2
      WITH FRAME {&FRAME-NAME}.
      DISABLE b-sum-id-2
      WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
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
  RUN Myenable in this-procedure .
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
  DISPLAY cardname-sent t-sum-id-output f-sum-id-output t-sum-id-output-2
          f-sum-id-output-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help cardname-sent t-sum-id-output f-sum-id-output
         b-sum-id t-sum-id-output-2 f-sum-id-output-2 b-sum-id-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
cardname-sent:RADIO-BUTTONS in frame {&frame-name} =  '{&bef-dc-cn-sent-name-full}' + {&comma-char} +
                                  {&dc-cn-sent-name} +  {&comma-char} +
                                 '{&bef-dc-cn-sent-card-full}' + {&comma-char} +
                                 {&dc-cn-sent-card}
v-sum-id-value1 = entry(1, p-custom-sent)
v-sum-id-value2 = (if num-entries(p-custom-sent) > 1
                   then entry(2, p-custom-sent)
                   else {&question-mark})
f-sum-id-output = dct-algo_custom-sent-description ( input v-sum-id-value1)
f-sum-id-output-2 = dct-algo_custom-sent-description ( input v-sum-id-value2)
t-sum-id-output = NOT (v-sum-id-value1 = {&question-mark})
t-sum-id-output-2 = NOT (v-sum-id-value2 = {&question-mark})
frame {&frame-name}:title = "Настройка информации, передаваемой на кассу по картам данного типа"
.
DISPLAY
f-sum-id-output
f-sum-id-output-2
t-sum-id-output
t-sum-id-output-2
WITH FRAME {&frame-name}.
cardname-sent = p-cardname-sent.
DISPLAY
cardname-sent
f-sum-id-output-2
f-sum-id-output
WITH FRAME {&frame-name}.
ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Help
cardname-sent WHEN p-mode <> {&LOOKUP}
b-sum-id        WHEN (p-mode <> {&LOOKUP} AND v-sum-id-value1 <> {&question-mark})
b-sum-id-2    WHEN (p-mode <> {&LOOKUP} AND v-sum-id-value2 <> {&question-mark})
t-sum-id-output WHEN p-mode <> {&LOOKUP}
t-sum-id-output-2 WHEN p-mode <> {&LOOKUP}
WITH FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide
  b-exit
  in frame {&frame-name} .
end.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sum-id Dialog-Frame
PROCEDURE proc-b-sum-id :
DEFINE INPUT-output PARAMETER p-sum-id-value AS CHARACTER.
define variable v-rid-list-0 as character no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list2 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
define buffer buf_dis-card-type for ub.dis-card-type.
if p-sum-id-value <> {&question-mark} then do:
  assign
  v-storage-place = entry(1, p-sum-id-value, {&delim-par})
  v-dtm-code = integer(entry(2, p-sum-id-value, {&delim-par}))
  v-sum-id   = entry(3, p-sum-id-value, {&delim-par})
  v-caller-id = entry(4, p-sum-id-value, {&delim-par})
  v-node-code = integer(entry(5, p-sum-id-value, {&delim-par}))
  no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    "Не могу разобрать строку, описывающую итог"
    VIEW-AS ALERT-BOX WARNING.
  END.
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.sum-id = v-sum-id
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF AVAILABLE buf_prop-ref THEN DO:
    ASSIGN
    v-rid-list = STRING(RECID(buf_prop-ref)).
  END.
  else do:
    FIND FIRST buf_prop-ref NO-LOCK WHERE
              buf_prop-ref.dtm-code = v-dtm-code
        AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
    IF AVAILABLE buf_prop-ref THEN DO:
      ASSIGN
      v-rid-list = STRING(RECID(buf_prop-ref)).
    end.
  end.
end.
MESSAGE
substitute("Выберите срез/итог&1" +
           "Если Вы выберете срез/итог для конкретного временного периода,&1" +
           "то на кассу автоматически будут посылаться данные за ТЕКУЩИЙ временной период"
           , {&NEW-LINE})
VIEW-AS ALERT-BOX .
if p-mode <> {&add-def} then do:
  find first buf_dis-card-type no-lock where
          buf_dis-card-type.emitent-host-code = p-emitent-host-code
      and buf_dis-card-type.type = p-type
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 .
    run gen-key-rec in this-procedure (
                                        input  {&table_dis-card-type}
                                        ,input  buffer buf_dis-card-type:handle
                                        ,output v-uniq-key-rec
                                        ) .
end.
v-rid-list-0 = v-rid-list.
run ref/proprefs.w (
                      input parparentproc
                    , input 'b-sel' /*bttns*/
                    , input "call_id"
                    , input 0 /*p-dtm-code*/
                    , input '':U
                    , input v-uniq-key-rec   /*p-calli-id*/
                    , input-output v-rid-list ) NO-ERROR.
IF v-rid-list = '':U
or v-rid-list = v-rid-list-0
THEN DO:
 RETURN ERROR.
END.

FIND FIRST buf_prop-ref NO-LOCK WHERE
           RECID(buf_prop-ref) = INTEGER(STRING(v-rid-list)) NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN do:
  MESSAGE
  substitute("Не найден срез/итога с recid &1", v-rid-list)
  VIEW-AS ALERT-BOX.
  undo, RETURN ERROR.
END.
MESSAGE
substitute("Выберите свойство, значение которого будет посылаться на кассу&1"
           , {&NEW-LINE})
VIEW-AS ALERT-BOX .

FIND FIRST buf_prop-map NO-LOCK WHERE
          buf_prop-map.dtm-code = v-dtm-code
     AND  buf_prop-map.node-code = v-node-code
      NO-ERROR.
IF AVAILABLE buf_prop-map THEN DO:
  ASSIGN
  v-rid-list2 = STRING(RECID(buf_prop-map)).
END.
run rul/prop-map-s.w (
                       input parparentproc
                      ,INPUT "b-sel"
                      ,INPUT "dtm-code" /* p-list-mode */
                      ,INPUT buf_prop-ref.dtm-code
                      ,INPUT-OUTPUT v-rid-list2) NO-ERROR.
IF v-rid-list2 = '':U THEN DO:
    RETURN ERROR.
END.
FIND FIRST buf_prop-map NO-LOCK WHERE
           RECID(buf_prop-map) = INTEGER(STRING(v-rid-list2)) NO-ERROR.
IF NOT AVAILABLE buf_prop-map THEN do:
  MESSAGE
  substitute("Не найдено свойство recid &1", v-rid-list2)
  VIEW-AS ALERT-BOX.
  undo, RETURN ERROR.
END.
find FIRST buf_prop-head NO-LOCK WHERE
        buf_prop-head.dtm-code = buf_prop-map.dtm-code NO-ERROR.
IF NOT AVAILABLE buf_prop-head THEN RETURN ERROR.
ASSIGN
p-sum-id-value = SUBSTITUTE("&2&1&3&1&4&1&5&1&6"
                             ,{&delim-par}
                             ,buf_prop-head.storage-place
                             ,buf_prop-head.dtm-code
                             ,buf_prop-ref.sum-id
                             ,buf_prop-ref.caller_id
                             ,buf_prop-map.node-code) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
