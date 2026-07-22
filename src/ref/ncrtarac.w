&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_cash-desk-attr FOR ub.cash-desk-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Соответствие кодов тары и весов тары для кассы NCR

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
define input parameter p-db-num    like ub.cash-desk-attr.db-num no-undo .
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.clients.obj-code NO-UNDO.
define input parameter p-pos-type  like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num  like ub.cash-desk-attr.cash-num no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Соответствие кодов тары и весов тары для кассы NCR".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cd-attr.i interface parparentproc }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE dflt-cd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-obj-db-num AS INTEGER NO-UNDO.
DEFINE VARIABLE rr AS RECID NO-UNDO.
DEFINE VARIABLE conf-attr AS CHARACTER NO-UNDO.
DEFINE VARIABLE conf-par AS CHARACTER NO-UNDO.
DEFINE VARIABLE par-type AS CHARACTER NO-UNDO.
define variable v-attr-code as character no-undo .
define variable v-upper-attr-code as character no-undo .
define buffer locked_cash-desk-attr for ub.cash-desk-attr.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-taracodes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cash-desk-attr

/* Definitions for BROWSE BR-taracodes                                  */
&Scoped-define FIELDS-IN-QUERY-BR-taracodes entry(2, X_cash-desk-attr.attr-code, {&delim-par}) X_cash-desk-attr.attr-value-character
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-taracodes
&Scoped-define SELF-NAME BR-taracodes
&Scoped-define QUERY-STRING-BR-taracodes FOR EACH X_cash-desk-attr NO-LOCK where         X_cash-desk-attr.obj-code = p-obj-code     AND X_cash-desk-attr.db-num = p-db-num     AND X_cash-desk-attr.pos-type = p-pos-type     AND X_cash-desk-attr.cash-num = p-cash-num     AND X_cash-desk-attr.upper-attr-code = v-upper-attr-code     AND X_cash-desk-attr.attr-code BEGINS (v-attr-code + {&delim-par}) INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-taracodes OPEN QUERY {&SELF-NAME} FOR EACH X_cash-desk-attr NO-LOCK where         X_cash-desk-attr.obj-code = p-obj-code     AND X_cash-desk-attr.db-num = p-db-num     AND X_cash-desk-attr.pos-type = p-pos-type     AND X_cash-desk-attr.cash-num = p-cash-num     AND X_cash-desk-attr.upper-attr-code = v-upper-attr-code     AND X_cash-desk-attr.attr-code BEGINS (v-attr-code + {&delim-par}) INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-taracodes X_cash-desk-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-taracodes X_cash-desk-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-taracodes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del B-Help ~
mark-num BR-taracodes
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "В&ыбор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-taracodes FOR
      X_cash-desk-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-taracodes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-taracodes Dialog-Frame _FREEFORM
  QUERY BR-taracodes NO-LOCK DISPLAY
      entry(2, X_cash-desk-attr.attr-code, {&delim-par}) COLUMN-LABEL "Код тары"
X_cash-desk-attr.attr-value-character COLUMN-LABEL "Вес тары" FORMAT "X(4)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.5 BY 13.77 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-chg AT ROW 1 COL 34
     b-del AT ROW 1 COL 44
     B-Help AT ROW 1 COL 54
     mark-num AT ROW 2 COL 1 NO-LABEL
     BR-taracodes AT ROW 3.5 COL 1
     SPACE(30.19) SKIP(0.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Соответствие кодов тары и весов тары для сканер-весов NCR"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_cash-desk-attr B "?" ? ub cash-desk-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-taracodes mark-num Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-taracodes
/* Query rebuild information for BROWSE BR-taracodes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_cash-desk-attr NO-LOCK where
        X_cash-desk-attr.obj-code = p-obj-code
    AND X_cash-desk-attr.db-num = p-db-num
    AND X_cash-desk-attr.pos-type = p-pos-type
    AND X_cash-desk-attr.cash-num = p-cash-num
    AND X_cash-desk-attr.upper-attr-code = v-upper-attr-code
    AND X_cash-desk-attr.attr-code BEGINS (v-attr-code + {&delim-par})
INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-taracodes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Соответствие кодов тары и весов тары для сканер-весов NCR */
OR ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input p-rid-list) no-error.
   if error-status:error then return no-apply.
   APPLY "GO" TO FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Соответствие кодов тары и весов тары для сканер-весов NCR */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    if available X_cash-desk-attr then do:
    { gbl/markstrn.i X_cash-desk-attr p-rid-list }
    glog = br-taracodes:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-taracodes:select-next-row ().
        apply "VALUE-CHANGED" to br-taracodes in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        DISPLAY
        num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-taracodes in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_cash-desk-attr ) AND (( p-rid-list = "" ) or b-mark:sensitive = no) then
    p-rid-list = string( recid( X_cash-desk-attr ) ) .
  APPLY "GO" to frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-taracodes
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
  { gbl/getcntxt.i get }
  if p-db-num = ? then do:
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
    p-db-num = v-obj-db-num.
  end.
  if p-pos-type = ? then do:
    { gbl/dflt-cd.i  p-obj-type p-obj-code dflt-cd }
    p-pos-type = dflt-cd.
  end.
  if p-cash-num = ? then do:
    if p-pos-type = {&cd-type-ncr-GM}
    or p-pos-type = {&cd-type-ncr-AS-R} then do:
      p-cash-num = 0.
    end.
  end.
  case p-pos-type:
    when {&cd-type-ncr-gm} then do:
      v-attr-code = {&cda-NCR-GM_general_tara-ref}.
      v-upper-attr-code = {&cda-NCR-GM_general}.
    end.
    when {&cd-type-ncr-AS-R} then do:
      v-attr-code = {&cda-NCR-AS-R_general_tara-ref}.
      v-upper-attr-code = {&cda-NCR-AS-R_general}.
    end.
  end.
  if lookup("b-add", bttns) > 0 then do:
    find first locked_cash-desk-attr no-lock where
              locked_cash-desk-attr.db-num = p-db-num
           and locked_cash-desk-attr.obj-code = p-obj-code
           and locked_cash-desk-attr.pos-type = p-pos-type
           and locked_cash-desk-attr.cash-num = p-cash-num
           AND locked_cash-desk-attr.upper-attr-code = v-upper-attr-code
           and locked_cash-desk-attr.attr-code = v-attr-code no-error .
    if not available locked_cash-desk-attr then do:
      run refresh-root-record in this-procedure .
    end.
    find first locked_cash-desk-attr exclusive-lock where
              locked_cash-desk-attr.db-num = p-db-num
           and locked_cash-desk-attr.obj-code = p-obj-code
           and locked_cash-desk-attr.pos-type = p-pos-type
           and locked_cash-desk-attr.cash-num = p-cash-num
           AND locked_cash-desk-attr.upper-attr-code = v-upper-attr-code
           and locked_cash-desk-attr.attr-code = v-attr-code .
  end.
  run Myenable IN THIS-PROCEDURE.
  HIDE
  mark-num in frame {&frame-name}.
  if p-rid-list <> "":U then do:
    assign
    rr = integer(p-rid-list) no-error .
    .
    if not error-status:error then do:
      reposition br-taracodes to recid rr no-error .
    end.
    APPLY "ENTRY" to br-taracodes.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del B-Help mark-num BR-taracodes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = SUBSTITUTE ("&1 &2&3"
                                         , FRAME {&FRAME-NAME}:TITLE
                                        , p-obj-type
                                        , p-obj-code ).
ENABLE
b-sel WHEN LOOKUP("b-sel", bttns) > 0
b-mark WHEN LOOKUP("b-mark", bttns) > 0
b-quit
b-add WHEN LOOKUP("b-add", bttns) > 0
b-chg WHEN LOOKUP("b-add", bttns) > 0
b-del WHEN LOOKUP("b-add", bttns) > 0
B-Help
BR-taracodes
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-QUERY-BR-taracodes}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE buffer buf_cash-desk-attr FOR ub.cash-desk-attr.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
define variable v-rid as recid no-undo .

run gbl/d-prompt.w (
          'title=':u + "Введите код тары" + '\':u
        + 'format=' + "99" + '\':u
        + 'type=' + {&type-int} + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=10\':u
        + 'fillin_height=1\':u
        + 'max-chars=12\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=no\':u
        , input-output v-value
        ).
if return-value = 'false':u then return NO-apply.
if v-value = '00' then do:
  message
  "Нельзя ввести код <00>" skip
  "Разрешенные значения кодов 01-99"
  view-as alert-box error
  .
  undo, return error .
end.
FIND FIRST buf_cash-desk-attr no-LOCK WHERE
         buf_cash-desk-attr.attr-code = (v-attr-code + {&delim-par} + v-value)
    AND buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
   AND   buf_cash-desk-attr.db-num = p-db-num
    AND   buf_cash-desk-attr.obj-code = p-obj-code
    AND   buf_cash-desk-attr.pos-type = p-pos-type
    AND   buf_cash-desk-attr.cash-num = p-cash-num NO-ERROR.
IF AVAILABLE buf_cash-desk-attr THEN DO:
  MESSAGE
  SUBSTITUTE("Тара с таким кодом уже есть в справочнике для касс магазина &1", p-obj-code)
  VIEW-AS ALERT-BOX ERROR.
END.
CREATE buf_cash-desk-attr.
ASSIGN
buf_cash-desk-attr.attr-code = (v-attr-code + {&delim-par} + v-value)
buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
buf_cash-desk-attr.db-num = p-db-num
buf_cash-desk-attr.obj-code = p-obj-code
buf_cash-desk-attr.pos-type = p-pos-type
buf_cash-desk-attr.cash-num = p-cash-num
v-rid = recid(buf_cash-desk-attr).
.
release buf_cash-desk-attr no-error.
if error-status:error then return no-apply.
{&OPEN-QUERY-BR-taracodes}
run refresh-root-record in this-procedure .
reposition br-taracodes to recid v-rid no-error.
APPLY "ENTRY" TO br-taracodes in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE buffer buf_cash-desk-attr FOR ub.cash-desk-attr.
IF NOT AVAILABLE X_cash-desk-attr THEN RETURN NO-APPLY.

run gbl/d-prompt.w (
      'title=':u + "Изменить вес тары (гр)" + '\':u
    + 'format=' + "9999" + '\':u
    + 'type=' + {&type-dec} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=10\':u
    + 'fillin_height=1\':u
    + 'max-chars=12\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
    if return-value = 'false':u then return NO-apply.
FIND FIRST buf_cash-desk-attr EXCLUSIVE-LOCK WHERE
         buf_cash-desk-attr.attr-code = X_cash-desk-attr.attr-code
   AND buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
   AND   buf_cash-desk-attr.db-num = X_cash-desk-attr.db-num
    AND   buf_cash-desk-attr.obj-code = X_cash-desk-attr.obj-code
    AND   buf_cash-desk-attr.pos-type = X_cash-desk-attr.pos-type
    AND   buf_cash-desk-attr.cash-num = X_cash-desk-attr.cash-num .
ASSIGN
buf_cash-desk-attr.attr-value-character = v-value.
run refresh-root-record in this-procedure .
br-taracodes:REFRESH() IN FRAME {&frame-name}.
APPLY "ENTRY" TO br-taracodes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE buffer buf_cash-desk-attr FOR ub.cash-desk-attr.
IF NOT AVAILABLE X_cash-desk-attr THEN RETURN NO-APPLY.
MESSAGE
substitute("Вы уверены, что хотите удалить код тары &1?&2" +
           "Если данный код может использоваться"
           ,entry(2, X_cash-desk-attr.attr-code, {&delim-par})
          ,{&NEW-LINE})
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog  THEN RETURN ERROR.
FIND FIRST buf_cash-desk-attr EXCLUSIVE-LOCK WHERE
         buf_cash-desk-attr.attr-code = X_cash-desk-attr.attr-code
    AND buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
   AND   buf_cash-desk-attr.db-num = X_cash-desk-attr.db-num
    AND   buf_cash-desk-attr.obj-code = X_cash-desk-attr.obj-code
    AND   buf_cash-desk-attr.pos-type = X_cash-desk-attr.pos-type
    AND   buf_cash-desk-attr.cash-num = X_cash-desk-attr.cash-num .
DELETE buf_cash-desk-attr.
run refresh-root-record in this-procedure .
{&OPEN-QUERY-BR-taracodes}
APPLY "ENTRY" TO br-taracodes IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-root-record Dialog-Frame
PROCEDURE refresh-root-record :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-comp-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_cash-desk-attr FOR ub.cash-desk-attr .
FIND FIRST buf_cash-desk-attr no-LOCK WHERE
         buf_cash-desk-attr.attr-code = (v-attr-code )
    AND buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
   AND   buf_cash-desk-attr.db-num = p-db-num
    AND   buf_cash-desk-attr.obj-code = p-obj-code
    AND   buf_cash-desk-attr.pos-type = p-pos-type
    AND   buf_cash-desk-attr.cash-num = p-cash-num NO-ERROR.
IF NOT AVAILABLE buf_cash-desk-attr THEN DO:
    CREATE buf_cash-desk-attr.
    ASSIGN
    buf_cash-desk-attr.attr-code = (v-attr-code)
    buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
    buf_cash-desk-attr.db-num = p-db-num
    buf_cash-desk-attr.obj-code = p-obj-code
    buf_cash-desk-attr.pos-type = p-pos-type
    buf_cash-desk-attr.cash-num = p-cash-num .
END.
run cur-time in this-procedure ( output v-today, output v-time).
assign
buf_cash-desk-attr.attr-value-character = SUBSTITUTE ("... (послед. изменение &1 &2 &3)"
                                           ,v-cntxt-userid
                                           ,string(v-today, "99/99/9999")
                                           ,string(v-time, "hh:mm:ss")
                                           ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
