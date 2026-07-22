&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-attr-prop NO-UNDO LIKE ub.attr-prop
       field upper-prop-label as character
       field prop-label as character
       .
DEFINE TEMP-TABLE tt-attr-prop NO-UNDO LIKE ub.attr-prop
       field full-prop-name as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список свойств АТРИБУТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/07
Author: Bakhtadze Natalya
Creation date: 08/15/07


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-table-name as character no-undo .
DEFINE INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-rec AS RECID NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список свойств АТРИБУТА ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-attr-prop

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-attr-prop

/* Definitions for BROWSE br-attr-prop                                  */
&Scoped-define FIELDS-IN-QUERY-br-attr-prop tt-attr-prop.node-code tt-attr-prop.full-prop-name tt-attr-prop.property-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attr-prop
&Scoped-define SELF-NAME br-attr-prop
&Scoped-define QUERY-STRING-br-attr-prop FOR EACH tt-attr-prop WHERE tt-attr-prop.table-name = p-table-name INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-attr-prop OPEN QUERY attr-prop FOR EACH tt-attr-prop WHERE tt-attr-prop.table-name = p-table-name INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-attr-prop tt-attr-prop
&Scoped-define FIRST-TABLE-IN-QUERY-br-attr-prop tt-attr-prop


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-add b-del b-chg B-Help ~
br-attr-prop

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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-attr-prop FOR
      tt-attr-prop SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-attr-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attr-prop Dialog-Frame _FREEFORM
  QUERY br-attr-prop NO-LOCK DISPLAY
      tt-attr-prop.node-code COLUMN-LABEL "код" FORMAT ">>9"
      tt-attr-prop.full-prop-name COLUMN-LABEL "Свойство" FORMAT "X(255)" WIDTH 40
tt-attr-prop.property-value COLUMN-LABEL "Значение" FORMAT "X(255)" WIDTH 58
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 41 WIDGET-ID 36
     b-del AT ROW 1 COL 51 WIDGET-ID 38
     b-chg AT ROW 1 COL 61 WIDGET-ID 40
     B-Help AT ROW 1 COL 95
     br-attr-prop AT ROW 3 COL 1 WIDGET-ID 100
     SPACE(0.70) SKIP(1.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-attr-prop T "?" NO-UNDO ub attr-prop
      ADDITIONAL-FIELDS:
          field upper-prop-label as character
          field prop-label as character

      END-FIELDS.
      TABLE: tt-attr-prop T "?" NO-UNDO ub attr-prop
      ADDITIONAL-FIELDS:
          field full-prop-name as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-attr-prop B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-attr-prop
/* Query rebuild information for BROWSE br-attr-prop
     _START_FREEFORM
OPEN QUERY attr-prop FOR EACH tt-attr-prop WHERE tt-attr-prop.table-name = p-table-name INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-attr-prop */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.


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


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable v-node-code as integer   no-undo .

  RUN proc-b-add IN THIS-PROCEDURE ( output v-node-code) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  if not available tt-attr-prop or v-node-code = ? then return no-apply.
  run proc-b-chg in this-procedure no-error .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF NOT AVAILABLE tt-attr-prop THEN RETURN NO-APPLY.
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-attr-prop THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-attr-prop
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
  IF p-mode <> {&UPDATE}
  AND p-mode <> {&LOOKUP}
  THEN DO:
    MESSAGE
    "Неверное значение параметра p-mode=" p-mode
     VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.

  RUN fill-temp-attr-prop IN THIS-PROCEDURE.
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
  ENABLE B-exit b-quit b-add b-del b-chg B-Help br-attr-prop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-attr-prop Dialog-Frame
PROCEDURE fill-temp-attr-prop :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
DEFINE VARIABLE v-start AS LOGICAL NO-UNDO INIT YES.
DEFINE VARIABLE v-node-code AS integer NO-UNDO.
DEFINE BUFFER buf_attr-prop FOR  ub.attr-prop.
DEFINE BUFFER upper_attr-prop FOR ub.attr-prop.
DEFINE BUFFER buf_tt-attr-prop FOR tt-attr-prop.
_buf_attr-prop:
FOR EACH buf_attr-prop NO-LOCK WHERE
        buf_attr-prop.table-name = p-table-name
     and buf_attr-prop.templ-rl-root = p-templ-rl-root:
  CREATE buf_tt-attr-prop.
  BUFFER-COPY buf_attr-prop TO buf_tt-attr-prop
  .
  /*
  if v-is-copy = yes then do:
    assign
    buf_tt-attr-prop.templ-rl-root = -1.
  end.
  */
  v-start = YES.
  FIND FIRST UPPER_attr-prop NO-LOCK WHERE
            UPPER_attr-prop.table-name = p-table-name
        and UPPER_attr-prop.upper-node-code = buf_attr-prop.upper-node-code
        AND UPPER_attr-prop.node-code = buf_attr-prop.node-code
        AND UPPER_attr-prop.templ-rl-root = buf_attr-prop.templ-rl-root.
  DO WHILE v-start OR buf_attr-prop.upper-node-code <> 0:
    v-start = NO.
    IF AVAILABLE UPPER_attr-prop THEN DO:
      ASSIGN
      buf_tt-attr-prop.full-prop-name = UPPER_attr-prop.prop-code +
                                          {&slash-char} +
                                      buf_tt-attr-prop.full-prop-name.

    END.
    v-node-code = upper_attr-prop.upper-node-code.
    FIND FIRST UPPER_attr-prop NO-LOCK WHERE
               UPPER_attr-prop.table-name = p-table-name
            and UPPER_attr-prop.node-code = v-node-code
            AND UPPER_attr-prop.templ-rl-root = buf_attr-prop.templ-rl-root NO-ERROR.
    IF NOT AVAILABLE UPPER_attr-prop THEN next _buf_attr-prop.
  END.

END.
CREATE tt-attr-prop.
ASSIGN
tt-attr-prop.table-name = p-table-name
tt-attr-prop.prop-code = '':U
tt-attr-prop.node-code = 0
tt-attr-prop.upper-prop-code = '':U
tt-attr-prop.upper-node-code = 0
/*tt-attr-prop.templ-rl-root = (if v-is-copy then - 1 else p-templ-rl-root)*/
tt-attr-prop.templ-rl-root =  p-templ-rl-root
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
frame {&frame-name}:title = substitute("Таблица &1, код &2"
                                       ,p-table-name
                                       , p-templ-rl-root).
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
b-add WHEn p-mode <> {&LOOKUP}
b-del WHEn p-mode <> {&LOOKUP}
b-chg WHEn p-mode <> {&LOOKUP}
br-attr-prop
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:column = 1
  b-quit:label = "&Выход"
  .
end.
RUN OPENbr IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
OPEN QUERY br-attr-prop FOR EACH tt-attr-prop by tt-attr-prop.full-prop-name.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define output parameter p-node-code     as integer initial ?  no-undo .

DEFINE VARIABLE v-upper-prop-code       AS CHARACTER NO-UNDO .
define variable v-upper-node-code       as integer   no-undo .
DEFINE VARIABLE v-upper-prop-label      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-full-prop-name        AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-upper-full-prop-name  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-prop-code             AS CHARACTER NO-UNDO .
define variable v-node-code             as integer   no-undo .
DEFINE VARIABLE v-prop-label            AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-property-value        AS CHARACTER NO-UNDO .

DEFINE BUFFER buf_tt-attr-prop FOR tt-attr-prop.

run utl/attrprpi.w (  INPUT parparentproc
                     ,input p-table-name
                     ,output v-upper-prop-code
                     ,output v-upper-node-code
                     ,OUTPUT v-upper-prop-label
                     ,OUTPUT v-full-prop-name
                     ,OUTPUT v-prop-code
                     ,output v-node-code
                     ,OUTPUT v-prop-label
                     ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN undo, RETURN ERROR.
if v-prop-code = '':u then return.
FIND FIRST buf_tt-attr-prop WHERE
          buf_tt-attr-prop.full-prop-name = v-full-prop-name
      and buf_tt-attr-prop.table-name = p-table-name
          NO-ERROR.
IF AVAILABLE buf_tt-attr-prop THEN DO:
   MESSAGE
  "Уже есть такой параметр в такой секции" SKIP
   v-full-prop-name
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
ASSIGN
v-UPPER-full-prop-name = v-full-prop-name
.
ASSIGN
v-upper-full-prop-name = RIGHT-TRIM(v-upper-full-prop-name, {&slash-char})
.
ENTRY(NUM-ENTRIES(v-upper-full-prop-name, {&slash-char}), v-upper-full-prop-name, {&slash-char}) = '':U.

FIND FIRST buf_tt-attr-prop WHERE
           buf_tt-attr-prop.table-name = p-table-name
       and buf_tt-attr-prop.full-prop-name = v-upper-full-prop-name NO-ERROR.
IF NOT AVAILABLE buf_tt-attr-prop THEN DO:
   MESSAGE
  "Нет секции с полным именем ="
   v-upper-full-prop-name
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
CREATE buf_tt-attr-prop.
ASSIGN
buf_tt-attr-prop.table-name      = p-table-name
buf_tt-attr-prop.prop-code       = v-prop-code
buf_tt-attr-prop.node-code       = v-node-code
buf_tt-attr-prop.upper-prop-code = v-upper-prop-code
buf_tt-attr-prop.upper-node-code = v-upper-node-code
buf_tt-attr-prop.property-value  = v-property-value
buf_tt-attr-prop.full-prop-name  = v-full-prop-name
buf_tt-attr-prop.templ-rl-root   = p-templ-rl-root
p-node-code                     = v-node-code
.
release buf_tt-attr-prop.
RUN openbr IN THIS-PROCEDURE .
find first buf_tt-attr-prop no-lock
  where buf_tt-attr-prop.templ-rl-root = p-templ-rl-root
    and buf_tt-attr-prop.table-name = p-table-name
    and buf_tt-attr-prop.node-code     = v-node-code
no-error .
if available buf_tt-attr-prop  then do:
  REPOSITION  br-attr-prop TO RECID RECID(buf_tt-attr-prop) NO-ERROR.
end.
APPLY "ENTRY" TO BROWSE br-attr-prop.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
v-value = tt-attr-prop.property-value.
      run gbl/d-character.w (
             input ? /*callback*/
            ,input (
            'title=':u + substitute("Изменение свойства &1", tt-attr-prop.prop-code) + '\':u
          + 'text1=':u + tt-attr-prop.prop-code + '\':u
          + 'format=' + "X(90)" + '\':u
          + 'fillin_row=3\':u
          + 'fillin_col=4\':u
          + 'fillin_width=90\':u
          + 'fillin_height=1\':u
          + 'max-chars=90\':u     /*- максимальное количество символов для редактора*/
          + 'readonly=no' + '\':u)
          , input-output v-value
          , output v-ok
              ).
          if not v-ok then return error.
assign
tt-attr-prop.property-value = v-value.
br-attr-prop:REFRESH() IN FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE VARIABLE glog AS LOGICAL no-undo.
DEFINE BUFFER buf_tt-attr-prop FOR tt-attr-prop.
MESSAGE
SUBSTITUTE("Вы уверены, что хотите удалить свойство?")
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog  THEN RETURN ERROR.
FIND FIRST buf_tt-attr-prop WHERE
          buf_tt-attr-prop.table-name = p-table-name
      and buf_tt-attr-prop.upper-node-code = tt-attr-prop.node-code  NO-ERROR.
IF AVAILABLE buf_tt-attr-prop THEN DO:
  MESSAGE
  "Нельзя удалить свойство, к нему есть привязки"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FIND FIRST buf_tt-attr-prop WHERE
         RECID(buf_tt-attr-prop) = RECID(tt-attr-prop).
DELETE buf_tt-attr-prop.
RUN Openbr IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define buffer buf_tt-attr-prop for tt-attr-prop.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = {&LOOKUP} THEN RETURN .
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.

for each buf_tt-attr-prop:
  assign
  buf_tt-attr-prop.templ-rl-root = p-templ-rl-root
  .
end.
run utl/attrprp0.p ( INPUT p-mode
                    ,INPUT NO /*p-silent*/
                    ,input p-table-name
                    ,input p-templ-rl-root
                    ,input table tt-attr-prop
                    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
 { gbl/reterhnd.i error }
  undo, return error.
END.
p-rec = v-rec.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME