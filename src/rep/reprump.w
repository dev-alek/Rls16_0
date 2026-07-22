&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Просмотр и печать  отчетов, отработавших пакетно

Автор: Бахтадзе Наталья Викторовна
Дата создания: 26/04/10
Author: Bakhtadze Natalya
Creation date: 26/04/10

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и печать  отчетов, отработавших пакетно".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ rep/tmpcxmlr.i tables-def t "shared" }
&scop label-param-name "Параметр"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-report

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES report-headert report-destinationt ~
report-errorst report-parameterst

/* Definitions for BROWSE BR-report                                     */
&Scoped-define FIELDS-IN-QUERY-BR-report report-headert.report-id report-headert.report-label report-headert.datetimeStart report-headert.datetimeEnd
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-report
&Scoped-define SELF-NAME BR-report
&Scoped-define QUERY-STRING-BR-report FOR EACH report-headert
&Scoped-define OPEN-QUERY-BR-report OPEN QUERY {&SELF-NAME} FOR EACH report-headert.
&Scoped-define TABLES-IN-QUERY-BR-report report-headert
&Scoped-define FIRST-TABLE-IN-QUERY-BR-report report-headert


/* Definitions for BROWSE BR-report-destination                         */
&Scoped-define FIELDS-IN-QUERY-BR-report-destination report-destinationt.destination-id report-destinationt.destination
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-report-destination
&Scoped-define SELF-NAME BR-report-destination
&Scoped-define QUERY-STRING-BR-report-destination FOR EACH report-destinationt WHERE     report-destinationt.report-id = report-headert.report-id
&Scoped-define OPEN-QUERY-BR-report-destination OPEN QUERY {&SELF-NAME} FOR EACH report-destinationt WHERE     report-destinationt.report-id = report-headert.report-id.
&Scoped-define TABLES-IN-QUERY-BR-report-destination report-destinationt
&Scoped-define FIRST-TABLE-IN-QUERY-BR-report-destination report-destinationt


/* Definitions for BROWSE BR-report-errorst                             */
&Scoped-define FIELDS-IN-QUERY-BR-report-errorst report-errorst.ErrNum report-errorst.Errseverity report-errorst.ErrMessage
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-report-errorst
&Scoped-define SELF-NAME BR-report-errorst
&Scoped-define QUERY-STRING-BR-report-errorst FOR EACH report-errorst WHERE     report-errorst.report-id = report-headert.report-id
&Scoped-define OPEN-QUERY-BR-report-errorst OPEN QUERY {&SELF-NAME} FOR EACH report-errorst WHERE     report-errorst.report-id = report-headert.report-id.
&Scoped-define TABLES-IN-QUERY-BR-report-errorst report-errorst
&Scoped-define FIRST-TABLE-IN-QUERY-BR-report-errorst report-errorst


/* Definitions for BROWSE BR-report-parameters                          */
&Scoped-define FIELDS-IN-QUERY-BR-report-parameters report-parameterst.parameter-label + (IF report-parameterst.parameter-index > 0 THEN substitute("[&1]",report-parameterst.parameter-index) ELSE '') report-parameterst.parameter-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-report-parameters
&Scoped-define SELF-NAME BR-report-parameters
&Scoped-define QUERY-STRING-BR-report-parameters FOR EACH report-parameterst WHERE     report-parameterst.report-id = report-headert.report-id
&Scoped-define OPEN-QUERY-BR-report-parameters OPEN QUERY {&SELF-NAME} FOR EACH report-parameterst WHERE     report-parameterst.report-id = report-headert.report-id.
&Scoped-define TABLES-IN-QUERY-BR-report-parameters report-parameterst
&Scoped-define FIRST-TABLE-IN-QUERY-BR-report-parameters report-parameterst


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-report}~
    ~{&OPEN-QUERY-BR-report-destination}~
    ~{&OPEN-QUERY-BR-report-errorst}~
    ~{&OPEN-QUERY-BR-report-parameters}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-print B-Help I-parameter BR-report ~
BR-report-parameters BR-report-errorst BR-report-destination

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE IMAGE I-parameter
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-report FOR
      report-headert SCROLLING.

DEFINE QUERY BR-report-destination FOR
      report-destinationt SCROLLING.

DEFINE QUERY BR-report-errorst FOR
      report-errorst SCROLLING.

DEFINE QUERY BR-report-parameters FOR
      report-parameterst SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-report
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-report Dialog-Frame _FREEFORM
  QUERY BR-report DISPLAY
      report-headert.report-id COLUMN-LABEL "ID отчета"
report-headert.report-label COLUMN-LABEL "Название отчета" FORMAT "X(255)" WIDTH 50
report-headert.datetimeStart FORMAT "99/99/9999 HH:MM:SS" COLUMN-LABEL "Начало расчета"
report-headert.datetimeEnd FORMAT "99/99/9999 HH:MM:SS" COLUMN-LABEL "Конец расчета"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.8
         FONT 4
         TITLE "Выполненные отчеты" FIT-LAST-COLUMN.

DEFINE BROWSE BR-report-destination
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-report-destination Dialog-Frame _FREEFORM
  QUERY BR-report-destination DISPLAY
      report-destinationt.destination-id COLUMN-LABEL "Тип вывода" FORMAT "X(8)"
 report-destinationt.destination COLUMN-LABEL "Ресурс" FORMAT "X(255)" WIDTH 70
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 4
         FONT 4
         TITLE "Направления вывода" FIT-LAST-COLUMN.

DEFINE BROWSE BR-report-errorst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-report-errorst Dialog-Frame _FREEFORM
  QUERY BR-report-errorst DISPLAY
      report-errorst.ErrNum COLUMN-LABEL "Пор.№"
report-errorst.Errseverity COLUMN-LABEL "Серьезность"
report-errorst.ErrMessage COLUMN-LABEL "Сообщение" FORMAT "X(255)" WIDTH 50
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 4.2
         FONT 4
         TITLE "Ошибки при расчете отчета" FIT-LAST-COLUMN.

DEFINE BROWSE BR-report-parameters
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-report-parameters Dialog-Frame _FREEFORM
  QUERY BR-report-parameters DISPLAY
      report-parameterst.parameter-label + (IF
                                      report-parameterst.parameter-index > 0
                                      THEN substitute("[&1]",report-parameterst.parameter-index)
                                      ELSE '')
COLUMN-LABEL {&label-param-name} FORMAT "X(255)" WIDTH 60
report-parameterst.parameter-value COLUMN-LABEL "Знач. пар-ра" FORMAT "X(255)" WIDTH 36
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.5
         FONT 4
         TITLE "Параметры отчета" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-print AT ROW 1 COL 92.5 WIDGET-ID 4
     B-Help AT ROW 1 COL 95
     BR-report AT ROW 2 COL 1 WIDGET-ID 100
     BR-report-parameters AT ROW 7.8 COL 1 WIDGET-ID 300
     BR-report-errorst AT ROW 14.3 COL 1 WIDGET-ID 400
     BR-report-destination AT ROW 18.5 COL 1 WIDGET-ID 200
     I-parameter AT ROW 8.2 COL 96.5 WIDGET-ID 34
     SPACE(0.20) SKIP(14.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр выполненных отчетов"
         CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB BR-report I-parameter Dialog-Frame */
/* BROWSE-TAB BR-report-parameters BR-report Dialog-Frame */
/* BROWSE-TAB BR-report-errorst BR-report-parameters Dialog-Frame */
/* BROWSE-TAB BR-report-destination BR-report-errorst Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-report
/* Query rebuild information for BROWSE BR-report
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH report-headert.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-report */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-report-destination
/* Query rebuild information for BROWSE BR-report-destination
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH report-destinationt WHERE
    report-destinationt.report-id = report-headert.report-id.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-report-destination */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-report-errorst
/* Query rebuild information for BROWSE BR-report-errorst
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH report-errorst WHERE
    report-errorst.report-id = report-headert.report-id.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-report-errorst */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-report-parameters
/* Query rebuild information for BROWSE BR-report-parameters
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH report-parameterst WHERE
    report-parameterst.report-id = report-headert.report-id.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-report-parameters */
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр выполненных отчетов */
or CHOOSE OF B-quit IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  MESSAGE
  "Выйти из режима просмотра отчетов?"
   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN RETURN NO-APPLY.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Btn 1 */
DO:
  RUN proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-report
&Scoped-define SELF-NAME BR-report
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-report Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-report IN FRAME Dialog-Frame /* Выполненные отчеты */
DO:
  IF NOT AVAILABLE report-headert  THEN RETURN NO-APPLY.
  RUN proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-report Dialog-Frame
ON VALUE-CHANGED OF BR-report IN FRAME Dialog-Frame /* Выполненные отчеты */
DO:
  {&OPEN-QUERY-BR-report-parameters}
  {&OPEN-QUERY-BR-report-destination}
  {&OPEN-QUERY-BR-report-errorst}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-report-destination
&Scoped-define SELF-NAME BR-report-destination
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-report-destination Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-report-destination IN FRAME Dialog-Frame /* Направления вывода */
DO:
  IF NOT AVAILABLE report-headert  THEN RETURN NO-APPLY.
  RUN proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-parameter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-parameter Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-parameter IN FRAME Dialog-Frame
DO:
   IF NOT AVAILABLE report-parameterst THEN RETURN NO-APPLY.

   MESSAGE report-parameterst.parameter-des
   VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-report
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_get-options Dialog-Frame
PROCEDURE cb_get-options :
DEFINE INPUT PARAMETER p-caller AS HANDLE NO-UNDO.
DEFINE BUFFER buf_report-destinationt FOR report-destinationt.
FOR EACH buf_report-destinationt WHERE
    buf_report-destinationt.report-id = report-headert.report-id:
  RUN cb_set-options IN p-caller ( INPUT buf_report-destinationt.destination-id
                                   ,INPUT buf_report-destinationt.destination
                                   ) .

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
  ENABLE b-quit B-print B-Help I-parameter BR-report BR-report-parameters
         BR-report-errorst BR-report-destination
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-ch0 as handle no-undo .
v-ch0 = br-report-parameters:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-param-name} THEN DO:
     v-ch0:resizable = yes.
   END.
   v-ch0 = v-ch0:NEXT-COLUMN.
end.
ENABLE
b-quit
B-print
B-Help
BR-report
BR-report-parameters
BR-report-errorst
BR-report-destination
i-parameter
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
assign
report-headert.report-label:resizable in browse br-report = yes
report-errorst.errmessage:resizable in browse br-report-errorst = yes
report-destinationt.destination:resizable in browse br-report-destination = yes
.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable v-user-action as character no-undo .
define variable v-printed as logical no-undo .
define variable v-disabled-options as integer no-undo init -1.
define variable v-font-number as integer no-undo .
define buffer pt_report-destinationt for report-destinationt.
define buffer xls_report-destinationt for report-destinationt.
find first pt_report-destinationt where
        pt_report-destinationt.report-id = report-headert.report-id
    and  pt_report-destinationt.destination-id = {&output-type-plain-text} no-error.
find first xls_report-destinationt where
        xls_report-destinationt.report-id = report-headert.report-id
    and  xls_report-destinationt.destination-id = {&output-type-excel} no-error.
if available pt_report-destinationt then do:
  assign
  v-disabled-options = integer(entry(1, pt_report-destinationt.destination-details, {&delim-par} ))
  v-font-number = integer(entry(2, pt_report-destinationt.destination-details, {&delim-par} ))
  .
end.
  if available xls_report-destinationt then do:
    assign
    v-disabled-options = integer(entry(1, xls_report-destinationt.destination-details, {&delim-par} ))
    v-font-number = integer(entry(2, xls_report-destinationt.destination-details, {&delim-par} ))
    .
  end.
if v-disabled-options = -1 then do:
  message
  "Отчет не может быть просмотрен/распечатан, так как это не предусмотрено заданными параметрами" skip
  "или отсутствуют задания на печать/просмотр!"
  view-as alert-box warning.
  return.
end.
run gbl/prnfilen.w
  (input  report-headert.report-label
  ,input  v-disabled-options + 30
  ,input  ''
  ,input  v-font-number
  ,output v-user-action
  ,output v-printed
  ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

