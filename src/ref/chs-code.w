&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-code-range NO-UNDO LIKE ub.code-range.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура поиска первого сободного кода заданного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/24/05
Author: Bakhtadze Natalya
Creation date: 02/24/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-db-num   LIKE ub.db.db-num NO-UNDO.
DEFINE OUTPUT PARAMETER p-code   AS integer NO-UNDO INIT ?.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ str/clc-rng.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-code-range

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-code-range

/* Definitions for BROWSE BR-code-range                                 */
&Scoped-define FIELDS-IN-QUERY-BR-code-range tt-code-range.first-code tt-code-range.last-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-code-range
&Scoped-define SELF-NAME BR-code-range
&Scoped-define QUERY-STRING-BR-code-range FOR EACH tt-code-range BY first-code
&Scoped-define OPEN-QUERY-BR-code-range OPEN QUERY {&SELF-NAME} FOR EACH tt-code-range BY first-code.
&Scoped-define TABLES-IN-QUERY-BR-code-range tt-code-range
&Scoped-define FIRST-TABLE-IN-QUERY-BR-code-range tt-code-range


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-code-range}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RS-up-down F-cv B-find ~
BR-code-range
&Scoped-Define DISPLAYED-OBJECTS RS-up-down F-cv F-start FILL-IN-4 ~
FILL-IN-5 F-end F-free-code

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

DEFINE BUTTON B-find
     LABEL "&Найти"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-cv AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-end AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE F-free-code AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0
     LABEL "Свободный код"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-start AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "<"
      VIEW-AS TEXT
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL ">"
      VIEW-AS TEXT
     SIZE 2.5 BY .67 NO-UNDO.

DEFINE VARIABLE RS-up-down AS INTEGER INITIAL -1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Меньше", -1,
"Больше", 1
     SIZE 29 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-code-range FOR
      tt-code-range SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-code-range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-code-range Dialog-Frame _FREEFORM
  QUERY BR-code-range DISPLAY
      tt-code-range.first-code COLUMN-LABEL "Нижняя граница"
tt-code-range.last-code  COLUMN-LABEL "Верхняя граница"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57.3 BY 14.77
         TITLE "Диапазоны использованных кодов по БД" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     RS-up-down AT ROW 2.5 COL 2.5 NO-LABEL
     F-cv AT ROW 4 COL 18 NO-LABEL
     B-find AT ROW 6 COL 11
     BR-code-range AT ROW 8.77 COL 17
     F-start AT ROW 4 COL 2.5 NO-LABEL
     FILL-IN-4 AT ROW 4 COL 13 COLON-ALIGNED NO-LABEL
     FILL-IN-5 AT ROW 4 COL 29 COLON-ALIGNED NO-LABEL
     F-end AT ROW 4 COL 36.5 NO-LABEL
     F-free-code AT ROW 7 COL 35 COLON-ALIGNED
     SPACE(23.49) SKIP(16.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Подобрать свободный код"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-code-range T "?" NO-UNDO ub code-range
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-code-range B-find Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN F-cv IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F-end IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN F-free-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       F-free-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-start IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-code-range
/* Query rebuild information for BROWSE BR-code-range
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-code-range BY first-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-code-range */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Подобрать свободный код */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  IF f-free-code <> 0 THEN
  p-code = f-free-code.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-find Dialog-Frame
ON CHOOSE OF B-find IN FRAME Dialog-Frame /* Найти */
DO:
    RUN proc-b-find IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-code-range
&Scoped-define SELF-NAME BR-code-range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-code-range Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-code-range IN FRAME Dialog-Frame /* Диапазоны использованных кодов по БД */
DO:
   IF NOT AVAILABLE tt-code-range THEN RETURN no-apply.
    RUN assign-and-find IN THIS-PROCEDURE NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-code-range Dialog-Frame
ON RETURN OF BR-code-range IN FRAME Dialog-Frame /* Диапазоны использованных кодов по БД */
DO:
   IF NOT AVAILABLE tt-code-range THEN RETURN no-apply.
    RUN assign-and-find IN THIS-PROCEDURE NO-ERROR.

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
  IF p-obj-type <> {&cmp}
  AND p-obj-type <> {&prs}
  AND p-obj-type <> {&shop}
  AND p-obj-type <> {&stock} THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-obj-type"
    p-obj-type
    view-as alert-box ERROR.
    return.
  END.
  IF (p-obj-type = {&shop}
  or p-obj-type = {&stock}) AND p-db-num <> 0 THEN DO:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Неверное значение параметров вызова p-db-num=&1 для p-obj-type=&2"
                , p-db-num
                , p-obj-type)
      view-as alert-box ERROR.
      return.

  END.
  if p-obj-type = {&cmp}
  or p-obj-type = {&prs} then
  run fill-tt in this-procedure ( input (if p-obj-type = {&cmp} then {&gbl-fm-code} else {&gbl-pn-code})) .
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-and-fin Dialog-Frame
PROCEDURE assign-and-find :
ASSIGN
f-cv = tt-code-range.first-code.
DISPLAY
f-cv
WITH FRAME {&FRAME-NAME}.
RUN proc-b-find IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-code Dialog-Frame
PROCEDURE check-code :
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ii AS integer NO-UNDO.
DEFINE output PARAMETER p-free AS logical NO-UNDO.
define variable v-result as logical no-undo .
DEFINE BUFFER buf_Clients FOR ub.clients.
CASE p-obj-type:
  WHEN {&cmp} OR WHEN {&prs} THEN do:
    assign
    v-result = calc-range(
                    input p-db-num
                    ,input p-ii
                    ,input (IF p-obj-type = {&cmp} THEN {&gbl-fm-code} ELSE {&gbl-pn-code})
                    ) no-error .
    if v-result = ? then do:
      /*неверный диапазон*/
      MESSAGE
      SUBSTITUTE("Код нового контрагента типа &1 может принимать значения&2" +
                  "ТОЛЬКО ВНУТРИ УКАЗАННЫХ ДИАПАЗОНОВ"
                , p-obj-type
                , {&new-line}
                )
      VIEW-AS ALERT-BOX ERROR.
      RETURN error.
    END.
    if v-result = no then return "next":U.
  END.
END CASE.
FIND FIRST buf_Clients NO-LOCK WHERE
          buf_clients.obj-type = p-obj-type
      AND buf_clients.obj-code = p-ii NO-ERROR.
IF NOT AVAILABLE buf_clients THEN DO:
  ASSIGN
  p-free = YES.
  RETURN.
END.


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
  DISPLAY RS-up-down F-cv F-start FILL-IN-4 FILL-IN-5 F-end F-free-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RS-up-down F-cv B-find BR-code-range
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dialog-Frame
PROCEDURE fill-tt :
define input  parameter p-range-type like ub.code-range.range-type no-undo .

define variable v-stts       as character no-undo .
define VARIABLE ii AS integer no-undo .
define VARIABLE v-seq-val AS integer no-undo .

define buffer buf_code-range for ub.code-range .
IF p-range-type = {&gbl-fm-code} THEN
ASSIGN
v-seq-val = current-value(s-fmgb-code, {&db-name_schema}).
IF p-range-type = {&gbl-pn-code} THEN
ASSIGN
v-seq-val = current-value(s-pngb-code, {&db-name_schema}).
DO ii = 1 TO 2 :
    IF ii = 1 THEN v-stts = 'u':U.
    IF ii = 2 THEN v-stts = 'a':U.
    FOR EACH buf_code-range no-lock
          where buf_code-range.range-type = p-range-type
            and buf_code-range.db-num = p-db-num
            and buf_code-range.stts = v-stts:
        create tt-code-range .
        BUFFER-COPY buf_code-range TO tt-code-range.
        IF v-stts = 'a'
        and tt-code-range.last-code >= v-seq-val
        and tt-code-range.last-code <= v-seq-val
        THEN DO:
            ASSIGN
            tt-code-range.last-code = v-seq-val.
        END.
        release tt-code-range.
    END.
END.
output close.
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
DEFINE VARIABLE v-log AS LOGICAL NO-UNDO.
CASE p-obj-type:
    WHEN {&cmp}
    OR
    WHEN {&prs} THEN DO:
       FRAME {&FRAME-NAME}:TITLE = substitute("&1 для контрагента типа &2"
                                              , FRAME {&FRAME-NAME}:TITLE
                                              , p-obj-type).
    END.
    WHEN {&shop}
    OR
    WHEN {&stock} THEN DO:
      ASSIGN
      f-start = 1
      f-end = 99999
      .
      FRAME {&FRAME-NAME}:TITLE = substitute("&1 для &2"
                                             , FRAME {&FRAME-NAME}:TITLE
                                             , p-obj-type).

    END.
END CASE.
DISPLAY
RS-up-down
f-cv
f-start  WHEN (p-obj-type = {&shop} OR p-obj-type = {&stock})
f-end    WHEN (p-obj-type = {&shop} OR p-obj-type = {&stock})
WITH FRAME {&frame-name}.
ENABLE
f-cv
B-exit
b-quit
B-Help
RS-up-down
B-find
br-code-range WHEN (p-obj-TYPE = {&cmp} OR p-obj-type = {&prs})
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
IF (p-obj-type = {&shop}
    or p-obj-type = {&stock}) THEN DO:
    HIDE
    br-code-range.

END.
else do:
  OPEN QUERY br-code-range FOR EACH tt-code-range BY first-code.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-find Dialog-Frame
PROCEDURE proc-b-find :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-border AS INTEGER NO-UNDO.
DEFINE VARIABLE v-free AS LOGICAL NO-UNDO.
define variable v-0 as integer no-undo .
DEFINE BUFFER buf_tt-code-range FOR tt-code-range.
ASSIGN
FRAME {&FRAME-NAME}
f-cv
RS-up-down.
CASE p-obj-type:
  WHEN  {&shop}
  OR
  WHEN {&stock} THEN DO:
    IF f-cv < F-start
    OR f-cv > F-end THEN DO:
      MESSAGE
      "Выберите число, которое попадает в указанные диапазоны"
      VIEW-AS ALERT-BOX.
      return error.
    END.
    CASE rs-up-down:
      WHEN -1  THEN DO:
        v-border = f-start.
       _ii:
        DO ii = f-cv TO v-border BY -1:
          run waitfram-show in this-procedure ( input substitute("Проверка: код &1", ii )) no-error .
          RUN check-code IN THIS-PROCEDURE (
                                            input p-obj-type
                                           ,input ii
                                           ,OUTPUT v-free) no-error.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            return error.
          end.
          if return-value = "next" then next _ii.
          IF v-free THEN DO:
            run waitfram-hide in this-procedure .
            ASSIGN
            f-free-code = ii
            f-free-code:LABEL = substitute("Первый свободный код &1 &2"
                                          ,(IF rs-up-down = -1 THEN "<" ELSE ">")
                                          , f-cv).
            DISPLAY
            f-free-code WITH FRAME {&FRAME-NAME}.
            return.
          END.
        END.
      END.
      WHEN 1  THEN DO:
        v-border = f-end.
          _ii:
          DO ii = f-cv TO v-border:
            run waitfram-show in this-procedure ( input substitute("Проверка: код &1", ii )).
            RUN check-code IN THIS-PROCEDURE ( input p-obj-type
                                             , input ii
                                             , OUTPUT v-free) no-error .
            if error-status:error then do:
                run waitfram-hide in this-procedure .
                return error.
            end.
            if return-value = "next" then next _ii.
            IF v-free THEN DO:
              run waitfram-hide in this-procedure .
              ASSIGN
              f-free-code = ii
              f-free-code:LABEL = substitute("Первый свободный код &1 &2"
                                              ,(IF rs-up-down = -1 THEN "<=" ELSE ">=")
                                              , f-cv).
              DISPLAY
              f-free-code WITH FRAME {&FRAME-NAME}.
              return.
            END.
        END.
      END.
    END CASE.
  END.
  WHEN {&cmp}
  OR
  WHEN {&prs} THEN DO:
    CASE rs-up-down:
      WHEN -1  THEN DO:
        find FIRST buf_tt-code-range WHERE
                 buf_tt-code-range.last-code >= f-cv NO-ERROR.
        IF AVAILABLE buf_tt-code-range THEN DO:
          ASSIGN
          v-border = buf_tt-code-range.last-code.
          _tt:
          FOR EACH buf_tt-code-range WHERE buf_tt-code-range.last-code <= v-border
          BY buf_tt-code-range.last-code
          DESCENDING:
            assign
            v-0 = buf_tt-code-range.last-code
            .
            if v-0 = v-border then do:
                assign
                v-0 = f-cv - 1.
                if v-0 < buf_tt-code-range.first-code then next _tt.
            end.
          _ii:
            DO ii = v-0 TO buf_tt-code-range.first-code BY -1:
              run waitfram-show in this-procedure ( input substitute("Проверка: код &1", ii )).
              RUN check-code IN THIS-PROCEDURE (
                                                input p-obj-type
                                              , input ii
                                              , OUTPUT v-free) no-error .
              if error-status:error then do:
                 run waitfram-hide in this-procedure .
                 return error.
              end.
              if return-value = "next" then next _ii.
              IF v-free THEN DO:
                run waitfram-hide in this-procedure .
                ASSIGN
                f-free-code = ii
                f-free-code:LABEL = substitute("Первый свободный код &1 &2"
                                              ,(IF rs-up-down = -1 THEN "<" ELSE ">")
                                              , f-cv).
                DISPLAY
                f-free-code WITH FRAME {&FRAME-NAME}.
                return.
              END.
            END.
          END.
        END.
      END.
      WHEN  1 THEN DO:
        find last buf_tt-code-range WHERE
                 buf_tt-code-range.first-code <= f-cv NO-ERROR.
        IF AVAILABLE buf_tt-code-range THEN DO:
          ASSIGN
          v-border = buf_tt-code-range.first-code.
          _tt:
          FOR EACH buf_tt-code-range WHERE buf_tt-code-range.first-code >= v-border
          BY buf_tt-code-range.first-code:
            assign
            v-0 = buf_tt-code-range.first-code
            .
            if v-0 = v-border then do:
                assign
                v-0 = f-cv + 1.
                if v-0 > buf_tt-code-range.last-code then next _tt.
            end.
            _ii:
            DO ii = v-0 TO buf_tt-code-range.last-code BY 1:
              run waitfram-show in this-procedure ( input substitute("Проверка: код &1", ii )).
              RUN check-code IN THIS-PROCEDURE (
                                                 input p-obj-type
                                               , input ii
                                               , OUTPUT v-free) no-error .
              if error-status:error then do:
                 run waitfram-hide in this-procedure .
                 return error.
              end.
              if return-value = "next" then next _ii.
              IF v-free THEN DO:
                run waitfram-hide in this-procedure .
                ASSIGN
                f-free-code = ii
                f-free-code:LABEL = substitute("Первый свободный код &1 &2"
                                              ,(IF rs-up-down = -1 THEN "<" ELSE ">")
                                              , f-cv).
                DISPLAY
                f-free-code WITH FRAME {&FRAME-NAME}.
                return.
              END.
            END.
          END.
        END.
      END.
    END CASE.
  END.
END CASE.
IF NOT v-free THEN DO:
  run waitfram-hide in this-procedure .
  ASSIGN
  f-free-code = ?.
  DISPLAY
  f-free-code WITH FRAME {&FRAME-NAME}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
