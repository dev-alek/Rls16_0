&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_cash-pay-attr FOR ub.cash-pay-attr.
DEFINE TEMP-TABLE tt-cash-pay-attr NO-UNDO LIKE ub.cash-pay-attr.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание атрибута ПРЕФЕКСЫ ПЛАТЕЖНОЙ КАРТЫ ДЛЯ ЭКСПОРТА В XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
define INPUT parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
define INPUT parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
define INPUT parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-attr-value AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание атрибута ПРЕФЕКСЫ ПЛАТЕЖНОЙ КАРТЫ ДЛЯ ЭКСПОРТА В XML".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }

DEFINE TEMP-TABLE tt-prefix NO-UNDO
FIELD prefix AS CHARACTER
INDEX pi IS UNIQUE PRIMARY
prefix.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-prefix

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-prefix

/* Definitions for BROWSE BR-prefix                                     */
&Scoped-define FIELDS-IN-QUERY-BR-prefix tt-prefix.prefix
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-prefix
&Scoped-define SELF-NAME BR-prefix
&Scoped-define QUERY-STRING-BR-prefix FOR EACH tt-prefix
&Scoped-define OPEN-QUERY-BR-prefix OPEN QUERY {&SELF-NAME} FOR EACH tt-prefix.
&Scoped-define TABLES-IN-QUERY-BR-prefix tt-prefix
&Scoped-define FIRST-TABLE-IN-QUERY-BR-prefix tt-prefix


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RECT-region RS-region ~
BR-prefix var-region v-host-name for-obj-name
&Scoped-Define DISPLAYED-OBJECTS RS-region var-region v-host-name ~
for-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.5 BY 1 NO-UNDO.

DEFINE VARIABLE var-region AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE RS-region AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", 0,
"Фирма", 1,
"Объект", 2
     SIZE 63 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-region
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72 BY 6.46.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-prefix FOR
      tt-prefix SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-prefix
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-prefix Dialog-Frame _FREEFORM
  QUERY BR-prefix DISPLAY
      tt-prefix.prefix FORMAT "X(19)" COLUMN-LABEL "Префикс"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 30 BY 6.67
         TITLE "Префиксы платежных карт" ROW-HEIGHT-CHARS .67 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-add AT ROW 9.25 COL 34
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     RS-region AT ROW 2.75 COL 3 NO-LABEL
     BR-prefix AT ROW 9.08 COL 2
     B-del AT ROW 9.25 COL 44
     var-region AT ROW 4.5 COL 18 COLON-ALIGNED NO-LABEL
     v-host-name AT ROW 6 COL 18 COLON-ALIGNED NO-LABEL
     for-obj-name AT ROW 7.5 COL 20.5 COLON-ALIGNED NO-LABEL
     RECT-region AT ROW 2.5 COL 1.5
     SPACE(3.62) SKIP(6.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Префиксы типа кассового платежа для экспорта в XML"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_cash-pay-attr B "?" ? ub cash-pay-attr
      TABLE: tt-cash-pay-attr T "?" NO-UNDO ub cash-pay-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-prefix RS-region Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-prefix
/* Query rebuild information for BROWSE BR-prefix
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-prefix.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-prefix */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Префиксы типа кассового платежа для экспорта в XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-dopi as decimal no-undo .
  DEFINE BUFFER buf_tt-prefix FOR tt-prefix.
 run gbl/d-prompt.w (
      'title=':u + "Добавить префикс платежной карты" + '\':u
    + 'format=' + "X(19)" + '\':u
    + 'type=' + {&type-char} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=19\':u
    + 'fillin_height=1\':u
    + 'max-chars=5\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
    if return-value = 'false':u then return NO-apply.

assign
v-dopi = decimal(v-value) no-error .
if error-status:error or
v-dopi < 0 or
v-dopi <> round(v-dopi, 0) or
index(v-value, {&comma-char}) > 0 then do:
  message
  "Вы должны ввесте целое положительное число длиной до 19 знаков"
  view-as alert-box error .
  return no-apply.
end.


FIND FIRST buf_tt-prefix NO-LOCK WHERE
          buf_tt-prefix.prefix = v-value NO-ERROR.
IF AVAILABLE buf_tt-prefix THEN DO:
     MESSAGE
        substitute("Вы уже задали префикс &1",  v-value)
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
END.
CREATE tt-prefix.
ASSIGN
tt-prefix.prefix = v-value
v-rid = RECID(tt-prefix)
.
open query br-prefix for each tt-prefix.
REPOSITION br-prefix TO RECID v-rid.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-prefix THEN RETURN NO-APPLY.
  DELETE tt-prefix.
  open query br-prefix for each tt-prefix.
  REPOSITION br-prefix TO ROW 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&Scoped-define BROWSE-NAME BR-prefix
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

  RUN fill-table IN THIS-PROCEDURE.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-region Dialog-Frame
PROCEDURE display-region :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE buffer buf_clients FOR ub.clients.
DEFINE buffer buf_objects FOR ub.clients.
    assign
    var-region = "Глобально"
    v-host-name = "":U
    for-obj-name = "":U.

    if p-host-code <> 0 then do:
        find first buf_clients No-LOCK WHERE
                buf_clients.obj-type = {&cmp} and
                buf_clients.obj-code = p-host-code No-ERROR.
        ASSIGN
        var-region = "Фирма: "
        v-host-name = buf_Clients.obj-name
        .
    end.
    if p-obj-code <> 0 then do:
        find first buf_objects No-LOCK WHERE
                buf_objects.obj-type = p-obj-type and
                buf_objects.obj-code = p-obj-code No-ERROR.
        ASSIGN
        var-region = "Объект: "
        for-obj-name = buf_objects.obj-name
        .
 end.
 DISPLAY
 var-region
 WITH FRAME {&FRAME-NAME}.
 IF p-host-code <> 0 THEN DO:
     DISPLAY
     v-host-name
     WITH FRAME {&FRAME-NAME}.
 END.
 ELSE DO:
     HIDE
     v-host-name
     IN FRAME {&FRAME-NAME}.
END.
 IF p-obj-code <> 0 THEN DO:
     DISPLAY
     for-obj-name
     WITH FRAME {&FRAME-NAME}.
 END.
 ELSE DO:
     HIDE
     for-obj-name
     IN FRAME {&FRAME-NAME}.
END.

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
  DISPLAY RS-region var-region v-host-name for-obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RECT-region RS-region BR-prefix var-region
         v-host-name for-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DO ii = 1 TO NUM-ENTRIES(p-attr-value):
    CREATE tt-prefix.
    ASSIGN
    tt-prefix.prefix = ENTRY(ii, p-attr-value)
    .
END.
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
assign
rs-region = (if p-host-code = 0
             then 0
             else (if p-obj-type = '':U then 1 else 2)
             )
.
display rs-region
with frame {&frame-name} .
 ENABLE
 B-exit
 RECT-region
 b-quit
 B-Help
 BR-prefix
 b-add
 b-del
 WITH FRAME {&frame-name}.
 VIEW FRAME {&frame-name}.
 RUN display-region IN THIS-PROCEDURE.
 open query br-prefix for each tt-prefix.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-dop AS character NO-UNDO.
FOR EACH tt-prefix:
    ASSIGN
    v-dop = v-dop + (IF v-dop = '':U THEN '':U ELSE {&comma-char}) + tt-prefix.prefix.
END.
ASSIGN
p-attr-value = v-dop
p-ok = yes
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME