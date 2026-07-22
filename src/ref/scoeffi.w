&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tree-s-coeff NO-UNDO LIKE ub.s-coeff.
DEFINE TEMP-TABLE tt-s-coeff NO-UNDO LIKE ub.s-coeff.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка значения сезонного коэффициента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .

/* Parameters Definitions ---                                           */
define input parameter ref-mode as char no-undo.
define input parameter p-gds-code like ub.s-coeff.gds-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
DEFINE INPUT-output PARAMETER TABLE FOR tt-s-coeff .
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tree-s-coeff.
define output parameter p-result as character no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка значения сезонного коэффициента" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }

define buffer b-objects for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-s-coeff

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-s-coeff SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-s-coeff SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-s-coeff
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-s-coeff


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-s-coeff.coeff-value tt-s-coeff.host-code ~
tt-s-coeff.obj-type tt-s-coeff.obj-code
&Scoped-define ENABLED-TABLES tt-s-coeff
&Scoped-define FIRST-ENABLED-TABLE tt-s-coeff
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-help s-month f-day ~
var-region host-name for-obj-name RECT-region
&Scoped-Define DISPLAYED-FIELDS tt-s-coeff.coeff-value tt-s-coeff.host-code ~
tt-s-coeff.obj-type tt-s-coeff.obj-code
&Scoped-define DISPLAYED-TABLES tt-s-coeff
&Scoped-define FIRST-DISPLAYED-TABLE tt-s-coeff
&Scoped-Define DISPLAYED-OBJECTS s-month f-day var-region host-name ~
for-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE s-month AS CHARACTER FORMAT "X(10)":U INITIAL "Январь"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"
     DROP-DOWN-LIST
     SIZE 13.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-day AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Начало действия коэффициента"
     VIEW-AS FILL-IN
     SIZE 3.63 BY 1 NO-UNDO.

DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.88 BY 1 NO-UNDO.

DEFINE VARIABLE host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.5 BY 1 NO-UNDO.

DEFINE VARIABLE var-region AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-region
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72 BY 6.46.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-s-coeff SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 41
     tt-s-coeff.coeff-value AT ROW 2.17 COL 10.38 COLON-ALIGNED
          LABEL "Значение" FORMAT ">9.999%"
          VIEW-AS FILL-IN
          SIZE 14.25 BY 1
     tt-s-coeff.s-date AT ROW 2.25 COL 57.38 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10.75 BY 1
     s-month AT ROW 3.33 COL 41.63 COLON-ALIGNED NO-LABEL
     f-day AT ROW 3.38 COL 36 COLON-ALIGNED
     var-region AT ROW 5.5 COL 19.38 COLON-ALIGNED NO-LABEL
     host-name AT ROW 7.08 COL 19 COLON-ALIGNED NO-LABEL
     tt-s-coeff.host-code AT ROW 7.13 COL 1.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5.88 BY 1
     tt-s-coeff.obj-type AT ROW 9.54 COL 1.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.13 BY 1
     tt-s-coeff.obj-code AT ROW 9.54 COL 8.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.63 BY 1
     for-obj-name AT ROW 9.58 COL 20.75 COLON-ALIGNED NO-LABEL
     RECT-region AT ROW 4.83 COL 2.13
     "Область действия:" VIEW-AS TEXT
          SIZE 16.63 BY 1 AT ROW 5.5 COL 3.38
          FGCOLOR 4
     SPACE(55.98) SKIP(5.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод значения сезонного коэффициента"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tree-s-coeff T "?" NO-UNDO ub s-coeff
      TABLE: tt-s-coeff T "?" NO-UNDO ub s-coeff
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-s-coeff.coeff-value IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-s-coeff.host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-s-coeff.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-s-coeff.obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-s-coeff.s-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN
       tt-s-coeff.s-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       s-month:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "1,2,3,4,5,6,7,8,9,10,11,12".

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "tt-s-coeff"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Ввод значения сезонного коэффициента */
DO:
 define variable v-dop-date as date no-undo .
 DEFINE VARIABLE v-today as date no-undo .
 DEFINE VARIABLE v-time as integer no-undo .

 assign
 frame {&frame-name} s-month
 f-day.
 assign
 v-dop-date = date(integer(entry(lookup(s-month, s-month:list-items), s-month:private-data)), f-day, 1996)
 no-error .
 if error-status:error then do:
  message
  "Неверно выбрана дата"
  view-as alert-box error .
  return no-apply.
 end.
 find first tree-s-coeff no-lock where
            tree-s-coeff.gds-code = p-gds-code
        AND tree-s-coeff.host-code = p-host-code
        AND tree-s-coeff.obj-type = p-obj-type
        AND tree-s-coeff.obj-code = p-obj-code
        AND tree-s-coeff.s-date = v-dop-date
        No-ERROR.
  if available tree-s-coeff then do:
    message
    "Уже задано значение сезонного коэффициента"
    "товар" tree-s-coeff.gds-code skip
    "фирма" tree-s-coeff.host-code "объект" tree-s-coeff.obj-type tree-s-coeff.obj-code
    "дата" string(string(DAY(tree-s-coeff.s-date)) + {&slash-char} + string(Month(tree-s-coeff.s-date)))
    view-as alert-box  error .
    return no-apply.
  end.
  if input frame {&frame-name} tt-s-coeff.coeff-value = 100 then do:
    message
    "Сезонный коэффициент не может равняться 100"
    view-as alert-box error .
    return no-apply.
  end.
  run cur-time in this-procedure(output v-today, output v-time).
  create tree-s-coeff.
  assign
  tree-s-coeff.gds-code = p-gds-code
  tree-s-coeff.coeff-value = input frame {&frame-name} tt-s-coeff.coeff-value
  tree-s-coeff.host-code = input frame {&frame-name} tt-s-coeff.host-code
  tree-s-coeff.obj-type = input frame {&frame-name} tt-s-coeff.obj-type
  tree-s-coeff.obj-code = input frame {&frame-name} tt-s-coeff.obj-code
  tree-s-coeff.s-date = V-DOP-DATE
  tree-s-coeff.creid = g#userid
  tree-s-coeff.credate = v-today
  .

  /*выясним нужно ли писать в tt или за эту дату на объект берется миз другой записи*/
  find first tt-s-coeff no-lock where
               tt-s-coeff.gds-code = p-gds-code
          AND tt-s-coeff.s-date = tree-s-coeff.s-date no-error.
    if not available tt-s-coeff then do:
    create tt-s-coeff.
    assign
    tt-s-coeff.gds-code = p-gds-code
    tt-s-coeff.coeff-value = input frame {&frame-name} tt-s-coeff.coeff-value
    tt-s-coeff.host-code = input frame {&frame-name} tt-s-coeff.host-code
    tt-s-coeff.obj-type = input frame {&frame-name} tt-s-coeff.obj-type
    tt-s-coeff.obj-code = input frame {&frame-name} tt-s-coeff.obj-code
    tt-s-coeff.s-date = v-dop-date
    tt-s-coeff.creid = g#userid
    tt-s-coeff.credate = v-today
    .
    assign
    p-result = string(recid(tt-s-coeff))
    .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ввод значения сезонного коэффициента */
DO:
  APPLY "END-ERROR":U TO SELF.
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
    if ref-mode <> {&add-def} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова ref-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if (p-host-code = 0 and
           (p-obj-type <> "":U or p-obj-code <> 0)) OR
           (p-obj-type = "":U and p-obj-code <> 0) or
           (p-obj-type <> "" and  p-obj-code = 0)
            then do:
            message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова p-host-code и/или p-obj-type и/или p-obj-code"
            view-as alert-box ERROR.
            return error.

    end.
    var-region = "Глобально".
    if p-host-code <> 0 then do:
        find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = {&cmp} and
                ub.clients.obj-code = p-host-code No-ERROR.
        var-region = "Фирма: ".
    end.
    if p-obj-code <> 0 then do:
        find first b-objects No-LOCK WHERE
                b-objects.obj-type = p-obj-type and
                b-objects.obj-code = p-obj-code No-ERROR.
            var-region = "Объект: ".

    end.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY s-month f-day var-region host-name for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-s-coeff THEN
    DISPLAY tt-s-coeff.coeff-value tt-s-coeff.host-code tt-s-coeff.obj-type
          tt-s-coeff.obj-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-help tt-s-coeff.coeff-value s-month f-day var-region
         host-name tt-s-coeff.host-code tt-s-coeff.obj-type tt-s-coeff.obj-code
         for-obj-name RECT-region
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

assign
s-month = entry(1, s-month:list-items in frame {&frame-name})
.

  ENABLE
  B-exit
  B-quit
  B-help
  tt-s-coeff.coeff-value
  s-month
  f-day
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run cur-time in this-procedure(output v-today, output v-time).
  DISPLAY
  s-month
  var-region
  0 @ tt-s-coeff.coeff-value
  1 @ f-day
  WITH FRAME Dialog-Frame.
  if p-host-code > 0 then
     DISPLAY
     p-host-code @ tt-s-coeff.host-code
     (if avail ub.clients then ub.clients.obj-name else "":U) @ host-name

    WITH FRAME Dialog-Frame.
    if p-obj-code <> 0 then do:
      DISPLAY
      p-obj-type @ tt-s-coeff.obj-type
      p-obj-code @ tt-s-coeff.obj-code
      (if avail b-objects then b-objects.obj-name else "":U) @ for-obj-name
       WITH FRAME Dialog-Frame.
 end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME