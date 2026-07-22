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

Форма задания параметров бонусов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE input parameter p-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT parameter p-line-num AS integer NO-UNDO.
DEFINE INPUT-OUTPUT parameter p-src-d-card AS character NO-UNDO.
DEFINE INPUT-OUTPUT parameter p-discnt-type AS integer NO-UNDO.
DEFINE INPUT-OUTPUT parameter p-discnt-id AS integer NO-UNDO.
DEFINE INPUT-OUTPUT parameter p-kateg AS integer NO-UNDO.
DEFINE OUTPUT parameter p-updated AS LOGICAL NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма задания параметров бонусов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-line-num f-src-d-card ~
f-discnt-type f-discnt-id rs-curr-type f-kateg B-CURR f-curr-abbr
&Scoped-Define DISPLAYED-OBJECTS f-line-num f-src-d-card f-discnt-type ~
f-discnt-id rs-curr-type f-kateg f-curr-abbr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-CURR
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.07.

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

DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-discnt-id AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0
     LABEL "ID транзации (внешней системы)"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-discnt-type AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0
     LABEL "№ схемы начисления"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-kateg AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Код валюты начислений или -1"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-line-num AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "№ строки, после которой были начислены бонусы"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-src-d-card AS CHARACTER FORMAT "X(19)":U INITIAL "0"
     LABEL "№ карты для начисления"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE rs-curr-type AS LOGICAL
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Привязан к валюте", yes,
"Не привязан к валюте", no
     SIZE 24.5 BY 1.87 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     f-line-num AT ROW 2.87 COL 47 COLON-ALIGNED
     f-src-d-card AT ROW 4.2 COL 31.5 COLON-ALIGNED
     f-discnt-type AT ROW 5.27 COL 33 COLON-ALIGNED
     f-discnt-id AT ROW 6.33 COL 33 COLON-ALIGNED
     rs-curr-type AT ROW 7.67 COL 5 NO-LABEL
     f-kateg AT ROW 9.8 COL 41.5 COLON-ALIGNED
     B-CURR AT ROW 9.8 COL 48.5
     f-curr-abbr AT ROW 10.07 COL 51.5 COLON-ALIGNED NO-LABEL
     SPACE(0.09) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры начисленных бонусов"
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры начисленных бонусов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-CURR
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-CURR Dialog-Frame
ON CHOOSE OF B-CURR IN FRAME Dialog-Frame
DO:
    define variable rr as recid no-undo.
    DEFINE BUFFER buf_currency FOR ub.currency.
    rr = ? .
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
                recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ f-kateg
      buf_currency.curr-abbr @ f-curr-abbr
      with frame {&frame-name} .
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  IF p-mode = {&add-def}
  OR p-mode = {&UPDATE} THEN DO:
    ASSIGN
    f-line-num
    f-src-d-card
    f-discnt-type
    f-discnt-id
    f-kateg.
  END.
  ASSIGN
  p-line-num = f-line-num
  p-src-d-card = f-src-d-card
  p-discnt-type = f-discnt-type
  p-discnt-id = f-discnt-id
  p-kateg = f-kateg
  p-updated = YES
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-src-d-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-src-d-card Dialog-Frame
ON ANY-PRINTABLE OF f-src-d-card IN FRAME Dialog-Frame /* № карты для начисления */
DO:

    if (keyfunction(lastkey) lt "0" or
        keyfunction(lastkey) gt "9") and
        keyfunction(lastkey) ne "backspace"
    then
        return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-curr-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-curr-type Dialog-Frame
ON VALUE-CHANGED OF rs-curr-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-curr-type.
  CASE RS-CURR-TYPE:
    WHEN YES  THEN DO:
       ASSIGN
       F-KATEG = 0
       F-CURR-ABBR = "{&ABBR-RUB}".
       ENABLE B-CURR
       WITH FRAME {&FRAME-NAME}.
       DISPLAY
       F-KATEG
       F-CURR-ABBR
       WITH FRAME {&FRAME-NAME}.

    END.
    WHEN NO THEN DO:
      ASSIGN
      F-KATEG = - 1
      F-CURR-ABBR = '':u.
      DISABLE B-CURR
      WITH FRAME {&FRAME-NAME}.
      DISPLAY
      F-KATEG
      F-CURR-ABBR
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
  run Myenable in this-procedure .
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
  DISPLAY f-line-num f-src-d-card f-discnt-type f-discnt-id rs-curr-type f-kateg
          f-curr-abbr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-line-num f-src-d-card f-discnt-type f-discnt-id
         rs-curr-type f-kateg B-CURR f-curr-abbr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define buffer BUF_CURRENCY for ub.currency.
CASE p-mode :
  WHEN  {&add-def} THEN DO:
    ASSIGN
    rs-curr-type = YES
    f-kateg = 0
    .
  END.
  WHEN {&LOOKUP}
  OR
  WHEN {&UPDATE} THEN DO:
      ASSIGN
      f-line-num = p-line-num
      f-src-d-card = p-SRC-d-card
      f-discnt-type = p-discnt-type
      f-discnt-id = p-discnt-id
      f-kateg = p-kateg
      .

  END.
END CASE.
FIND FIRST buf_currency NO-LOCK WHERE
        buf_currency.curr-code = f-kateg NO-ERROR.
IF AVAILABLE buf_currency THEN DO:
  f-curr-abbr = buf_currency.curr-abbr.
END.
ELSE DO:
  f-curr-abbr = {&question-mark}.
END.
DISPLAY
f-line-num
f-src-d-card
f-discnt-type
f-discnt-id
rs-curr-type
f-kateg
f-curr-abbr
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
f-line-num
f-src-d-card
f-discnt-type
f-discnt-id
rs-curr-type  WHEN p-mode <> {&LOOKUP}
f-kateg
B-curr WHEN p-mode <> {&LOOKUP}
f-curr-abbr
WITH FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:column = 1.
END.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED" to rs-curr-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
