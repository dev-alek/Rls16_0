&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-drt-prop NO-UNDO LIKE ub.drt-prop
       field upper-prop-label as character
       field prop-label as character
       field full-prop-name as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование свойств шаблона правил скидок и расписаний  - служебное окно

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
DEFINE OUTPUT PARAMETER p-upper-prop-code AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-upper-node-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-upper-prop-label AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-upper-full-prop-name AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-prop-code AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-prop-label AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование свойств шаблона правил скидок и расписаний".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
DEFINE STREAM instream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-drt-prop

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-drt-prop

/* Definitions for BROWSE BR-drt-prop                                   */
&Scoped-define FIELDS-IN-QUERY-BR-drt-prop temp-drt-prop.upper-prop-code temp-drt-prop.upper-node-code temp-drt-prop.upper-prop-label temp-drt-prop.node-code temp-drt-prop.prop-code temp-drt-prop.prop-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-drt-prop
&Scoped-define SELF-NAME BR-drt-prop
&Scoped-define QUERY-STRING-BR-drt-prop FOR EACH temp-drt-prop NO-LOCK BY temp-drt-prop.upper-prop-code BY temp-drt-prop.prop-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-drt-prop OPEN QUERY {&SELF-NAME} FOR EACH temp-drt-prop NO-LOCK BY temp-drt-prop.upper-prop-code BY temp-drt-prop.prop-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-drt-prop temp-drt-prop
&Scoped-define FIRST-TABLE-IN-QUERY-BR-drt-prop temp-drt-prop


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-drt-prop}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit rs-add B-Help f-prop-label ~
f-prop-code BR-drt-prop full-prop-name
&Scoped-Define DISPLAYED-OBJECTS rs-add f-upper-prop-code ~
f-upper-prop-label f-prop-label f-prop-code full-prop-name

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

DEFINE VARIABLE f-prop-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Название  пар-ра"
     VIEW-AS FILL-IN NATIVE
     SIZE 28.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-prop-label AS CHARACTER FORMAT "X(256)":U
     LABEL "Лейбл  пар-ра"
     VIEW-AS FILL-IN NATIVE
     SIZE 28.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-upper-prop-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Название  секции"
     VIEW-AS FILL-IN NATIVE
     SIZE 28.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-upper-prop-label AS CHARACTER FORMAT "X(256)":U
     LABEL "Лейбл секции"
     VIEW-AS FILL-IN NATIVE
     SIZE 28.5 BY 1 NO-UNDO.

DEFINE VARIABLE full-prop-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 97.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-add AS CHARACTER INITIAL "sel"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Существующий", "sel",
"Новый", "add"
     SIZE 23.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-drt-prop FOR
      temp-drt-prop SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-drt-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-drt-prop Dialog-Frame _FREEFORM
  QUERY BR-drt-prop NO-LOCK DISPLAY
      temp-drt-prop.upper-prop-code COLUMN-LABEL "Назв.секции" FORMAT "X(255)" WIDTH 12
temp-drt-prop.upper-node-code COLUMN-LABEL "Код выше.!узла" FORMAT ">>>>9"
temp-drt-prop.upper-prop-label COLUMN-LABEL "Лейбл секции" FORMAT "X(255)" WIDTH 30
temp-drt-prop.node-code COLUMN-LABEL "Код!узла" FORMAT ">>>>9"
temp-drt-prop.prop-code  COLUMN-LABEL "Назв.пар-ра" FORMAT "X(255)" WIDTH 12
temp-drt-prop.prop-label COLUMN-LABEL "Лейбл пар-ра" FORMAT "X(255)" WIDTH 30
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     rs-add AT ROW 1 COL 39 NO-LABEL WIDGET-ID 50
     B-Help AT ROW 1 COL 95
     f-upper-prop-code AT ROW 2 COL 17 COLON-ALIGNED WIDGET-ID 42
     f-upper-prop-label AT ROW 2 COL 66.5 COLON-ALIGNED WIDGET-ID 46
     f-prop-label AT ROW 3 COL 66.5 COLON-ALIGNED WIDGET-ID 48
     f-prop-code AT ROW 3.27 COL 17 COLON-ALIGNED WIDGET-ID 44
     BR-drt-prop AT ROW 4.77 COL 1 WIDGET-ID 100
     full-prop-name AT ROW 22.5 COL 1.5 NO-LABEL WIDGET-ID 54
     SPACE(0.00) SKIP(0.10)
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
      TABLE: temp-drt-prop T "?" NO-UNDO ub drt-prop
      ADDITIONAL-FIELDS:
          field upper-prop-label as character
          field prop-label as character
          field full-prop-name as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-drt-prop f-prop-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-upper-prop-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-upper-prop-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-upper-prop-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-upper-prop-label:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN full-prop-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-drt-prop
/* Query rebuild information for BROWSE BR-drt-prop
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH temp-drt-prop NO-LOCK
BY temp-drt-prop.upper-prop-code
BY temp-drt-prop.prop-code
INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-drt-prop */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
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


&Scoped-define BROWSE-NAME BR-drt-prop
&Scoped-define SELF-NAME BR-drt-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-drt-prop Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-drt-prop IN FRAME Dialog-Frame
DO:
  if not available temp-drt-prop then return no-apply.
  apply "go":u to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-drt-prop Dialog-Frame
ON VALUE-CHANGED OF BR-drt-prop IN FRAME Dialog-Frame
DO:
  IF rs-add = "add" THEN DO:
    rs-add = "sel".
    DISPLAY
    rs-add
    WITH FRAME {&FRAME-NAME}.
  END.
  IF AVAILABLE temp-drt-prop THEN DO:

  DISPLAY
  temp-drt-prop.upper-prop-code @ f-upper-prop-code
  temp-drt-prop.upper-prop-label @ f-upper-prop-label
  temp-drt-prop.prop-code @ f-prop-code
  temp-drt-prop.prop-label @ f-prop-label
  temp-drt-prop.full-prop-name @ full-prop-name
  WITH FRAME {&FRAME-NAME}
  .
  END.
  ELSE DO:
    DISPLAY
    '':U @ f-upper-prop-code
    '':U @ f-upper-prop-label
    '':U @ f-prop-code
    '':U @ f-prop-label
    '':U @ full-prop-name
    WITH FRAME {&FRAME-NAME}
    .

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-add Dialog-Frame
ON VALUE-CHANGED OF rs-add IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_temp-drt-prop FOR temp-drt-prop.
  ASSIGN
   rs-add.
  CASE rs-add:
    WHEN "add" THEN DO:
      IF NOT AVAILABLE temp-drt-prop THEN DO:
        MESSAGE
        "Не к чему привязать"
        VIEW-AS ALERT-BOX ERROR.
        ASSIGN
        rs-add = "sel".
        DISPLAY
        rs-add
        WITH FRAME {&FRAME-NAME}.
        UNDO, RETURN NO-APPLY.
      END.
        ASSIGN
        f-prop-code = '':U
        f-prop-label = '':U
        f-upper-prop-code = temp-drt-prop.prop-code
        f-upper-prop-label = temp-drt-prop.prop-label
        .
        DISPLAY
        f-prop-code
        f-prop-label
        f-upper-prop-code
        f-upper-prop-label
        WITH frame {&FRAME-NAME}.
    ENd.
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
  run fill-temp-drt-prop in this-procedure .
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
  DISPLAY rs-add f-upper-prop-code f-upper-prop-label f-prop-label f-prop-code
          full-prop-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit rs-add B-Help f-prop-label f-prop-code BR-drt-prop
         full-prop-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-drt-prop Dialog-Frame
PROCEDURE fill-temp-drt-prop :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
DEFINE VARIABLE v-start                   AS LOGICAL no-UNDO.
DEFINE VARIABLE v-node-code AS integer NO-UNDO.
DEFINE BUFFER UPPER_drt-prop FOR temp-drt-prop.

run gbl/filename.p (
                input 'cmp/drt-prop.new'
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  run gbl/filename.p (
                  input 'cmp/drt-prop.txt'
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
end.

INPUT STREAM instream FROM value(v-full-path).
REPEAT:
  CREATE temp-drt-prop.
  IMPORT STREAM instream temp-drt-prop no-error.
END.
INPUT STREAM instream CLOSE.

FOR EACH temp-drt-prop NO-LOCK WHERE
        temp-drt-prop.node-code = 0 :
  DELETE temp-drt-prop.
END.
_temp-drt-prop:
FOR EACH temp-drt-prop:
  FIND FIRST UPPER_drt-prop NO-LOCK WHERE
            UPPER_drt-prop.upper-node-code = temp-drt-prop.upper-node-code
        AND UPPER_drt-prop.node-code = temp-drt-prop.node-code
        AND UPPER_drt-prop.templ-rl-root = temp-drt-prop.templ-rl-root.
  v-start = yes.
  DO WHILE v-start OR temp-drt-prop.upper-node-code <> 0:
    v-start = NO.
    IF AVAILABLE UPPER_drt-prop THEN DO:
      ASSIGN
      temp-drt-prop.full-prop-name = UPPER_drt-prop.prop-code +
                                          {&slash-char} +
                                      temp-drt-prop.full-prop-name.

    END.
    v-node-code = UPPER_drt-prop.upper-node-code.
    FIND FIRST UPPER_drt-prop NO-LOCK WHERE
               UPPER_drt-prop.node-code = v-node-code
            and UPPER_drt-prop.templ-rl-root = temp-drt-prop.templ-rl-root
               NO-ERROR.
   IF NOT AVAILABLE UPPER_drt-prop THEN NEXT _temp-drt-prop.
   /*temp-drt-prop.upper-prop-label = upper_drt-prop.prop-label.*/
  END.

END.
FOR EACH temp-drt-prop NO-LOCK WHERE
        temp-drt-prop.node-code = 0 :
  DELETE temp-drt-prop.
END.
CREATE temp-drt-prop.
ASSIGN
temp-drt-prop.prop-code = '':U
temp-drt-prop.node-code = 0
temp-drt-prop.prop-label = '':U
temp-drt-prop.upper-prop-code = '':U
temp-drt-prop.upper-node-code = 0
temp-drt-prop.upper-prop-label = '':U
temp-drt-prop.templ-rl-root = 0
.
RELEASE temp-drt-prop.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
temp-drt-prop.upper-prop-code:RESIZABLE IN BROWSE br-drt-prop = YES
temp-drt-prop.upper-prop-label:RESIZABLE IN BROWSE br-drt-prop = YES
temp-drt-prop.prop-code:RESIZABLE IN BROWSE br-drt-prop = YES
temp-drt-prop.prop-label:RESIZABLE IN BROWSE br-drt-prop = YES
.
DISPLAY
f-upper-prop-code
f-upper-prop-label
f-prop-label
f-prop-code
rs-add
WITH FRAME {&frame-name}.
ENABLE
rs-add
B-exit
b-quit
B-Help
f-upper-prop-code
f-upper-prop-label
f-prop-label
f-prop-code
br-drt-prop
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
Open query br-drt-prop for each temp-drt-prop.
APPLY "ENTRY" to br-drt-prop.
APPLY "VALUE-CHANGED" to br-drt-prop.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-node-code as integer no-undo .
define variable v-upper-node-code as integer no-undo .
DEFINE BUFFER buf_temp-drt-prop FOR temp-drt-prop.
ASSIGN
FRAME {&FRAME-NAME}
f-prop-code
f-prop-label
f-upper-prop-code
f-upper-prop-label
.
IF rs-add = "add" THEN DO:
  FIND FIRST buf_temp-drt-prop WHERE
            buf_temp-drt-prop.prop-code = f-prop-code
        AND buf_temp-drt-prop.upper-node-code = temp-drt-prop.node-code NO-ERROR.
  IF AVAILABLE buf_temp-drt-prop THEN DO:
    MESSAGE
    "Уже есть такое свойство в такой секции"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
END.
IF rs-add = "add" THEN DO:
  find last buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = 0 no-error .
  v-node-code = (if available buf_temp-drt-prop
                then buf_temp-drt-prop.node-code + 1
                else 1).
  v-upper-node-code = (if available temp-drt-prop
                      then temp-drt-prop.node-code
                      else 0).

   CREATE buf_temp-drt-prop.
   ASSIGN
   buf_temp-drt-prop.prop-code = f-prop-code
   buf_temp-drt-prop.node-code =  v-node-code
   buf_temp-drt-prop.prop-label = f-prop-label
   buf_temp-drt-prop.upper-prop-code = f-upper-prop-code
   buf_temp-drt-prop.upper-prop-label = f-upper-prop-label
   buf_temp-drt-prop.upper-node-code =  v-upper-node-code
   buf_temp-drt-prop.full-prop-name = temp-drt-prop.full-prop-name + f-prop-code + {&slash-char}
   .
END.
else do:
  assign
  v-node-code = temp-drt-prop.node-code
  v-upper-node-code = temp-drt-prop.upper-node-code
  .
end.
ASSIGN
p-prop-code = f-prop-code
p-node-code = v-node-code
p-upper-node-code = v-upper-node-code
p-prop-label = f-prop-label
p-upper-prop-code = f-upper-prop-code
p-upper-prop-label = f-upper-prop-label
p-upper-full-prop-name = (if rs-add = "add"
                          then buf_temp-drt-prop.full-prop-name
                          else temp-drt-prop.full-prop-name)
.
if rs-add = "add" then do:
  OUTPUT STREAM instream TO value("cmp/drt-prop.NEW").
  FOR EACH buf_temp-drt-prop:
    if buf_temp-drt-prop.node-code > 0 then
    EXPORT STREAM instream buf_temp-drt-prop EXCEPT buf_temp-drt-prop.full-prop-name.
  END.
  OUTPUT stream instream CLOSE.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

