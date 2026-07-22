&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_group-period-validity FOR ub.group-period-validity.
DEFINE TEMP-TABLE tt-group-period-validity NO-UNDO LIKE ub.group-period-validity.
DEFINE BUFFER X_curr_clients FOR ub.clients.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования группы сроков годности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/12/04
Author: Bakhtadze Natalya
Creation date: 03/12/04

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/
DEFINE INPUT PARAMETER p-gr-per-val-code LIKE ub.group-period-validity.gr-per-val-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования группы сроков годности".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.group-period-validity.gr-per-val-code no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,gr-per-val-code,gr-per-val-name,des," +  ~
                  "gr-per-from,gr-per-to"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-group-period-validity

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-group-period-validity.gr-per-val-code ~
tt-group-period-validity.gr-per-val-name ~
tt-group-period-validity.gr-per-from tt-group-period-validity.gr-per-to ~
tt-group-period-validity.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-group-period-validity.gr-per-val-code ~
tt-group-period-validity.gr-per-val-name ~
tt-group-period-validity.gr-per-from tt-group-period-validity.gr-per-to ~
tt-group-period-validity.des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ~
tt-group-period-validity
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-group-period-validity
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-group-period-validity SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-group-period-validity SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-group-period-validity
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-group-period-validity


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-group-period-validity.gr-per-val-code ~
tt-group-period-validity.gr-per-val-name ~
tt-group-period-validity.gr-per-from tt-group-period-validity.gr-per-to ~
tt-group-period-validity.des
&Scoped-define ENABLED-TABLES tt-group-period-validity
&Scoped-define FIRST-ENABLED-TABLE tt-group-period-validity
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help
&Scoped-Define DISPLAYED-FIELDS tt-group-period-validity.gr-per-val-code ~
tt-group-period-validity.gr-per-val-name ~
tt-group-period-validity.gr-per-from tt-group-period-validity.gr-per-to ~
tt-group-period-validity.des
&Scoped-define DISPLAYED-TABLES tt-group-period-validity
&Scoped-define FIRST-DISPLAYED-TABLE tt-group-period-validity


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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-group-period-validity SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-group-period-validity.gr-per-val-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код группы сроков хранения"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-group-period-validity.gr-per-val-name AT ROW 4.25 COL 34 COLON-ALIGNED
          LABEL "Название группы сроков хранения"
          VIEW-AS FILL-IN
          SIZE 63 BY 1
     tt-group-period-validity.gr-per-from AT ROW 5.5 COL 34 COLON-ALIGNED
          LABEL "С"
          VIEW-AS FILL-IN
          SIZE 8.5 BY 1
     tt-group-period-validity.gr-per-to AT ROW 6.75 COL 34 COLON-ALIGNED
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-group-period-validity.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.75 COL 1.5
     "Количество дней хранения" VIEW-AS TEXT
          SIZE 27 BY 1 AT ROW 5.75 COL 2
     SPACE(70.24) SKIP(7.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группа сроков годности"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_group-period-validity B "?" ? ub group-period-validity
      TABLE: tt-group-period-validity T "?" NO-UNDO ub group-period-validity
      TABLE: X_curr_clients B "?" ? ub clients
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

/* SETTINGS FOR FILL-IN tt-group-period-validity.gr-per-from IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-group-period-validity.gr-per-to IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-group-period-validity.gr-per-val-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-group-period-validity.gr-per-val-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-group-period-validity"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группа сроков годности */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Hist Dialog-Frame
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo.
    run ref/gcprvals.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_group-period-validity.gr-per-val-code
                ,input-output v-rid-list
                              )

 .

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
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
{ gbl/ed_date.i tt-group-period-validity.gr-per-from }
{ gbl/ed_date.i tt-group-period-validity.gr-per-to }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.

 { gbl/curdbnum.i v-db-num }
IF v-db-num <> 0
AND (p-mode = {&add-def}
     OR p-mode = {&UPDATE} ) THEN DO:
      message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись ГРУППЫ СРОКОВ ГОДНОСТИ в УБД"
    view-as alert-box ERROR.
    return error .
END.

  for each tt-group-period-validity:
    delete tt-group-period-validity.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_group-period-validity EXclusive-lock where
                   recid(locked_group-period-validity) = p-doc-rec no-wait no-error.
      if locked locked_group-period-validity then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ГРУППЫ СРОКОВ ГОДНОСТИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_group-period-validity no-lock where
                       recid(locked_group-period-validity) = p-doc-rec no-error .
      if not avail locked_group-period-validity then do:
        find first locked_group-period-validity no-lock where
                   locked_group-period-validity.gr-per-val-code = p-gr-per-val-code no-error .
      end.
    end.
    if not available locked_group-period-validity then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ГРУППЫ СРОКОВ ГОДНОСТИ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-group-period-validity.
    buffer-copy locked_group-period-validity to tt-group-period-validity.
   end.
   else do:
          create tt-group-period-validity.
          assign
         tt-group-period-validity.gr-per-val-code = v-last-code + 1
         .
   end.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  IF AVAILABLE tt-group-period-validity THEN
    DISPLAY tt-group-period-validity.gr-per-val-code
          tt-group-period-validity.gr-per-val-name
          tt-group-period-validity.gr-per-from
          tt-group-period-validity.gr-per-to tt-group-period-validity.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-group-period-validity.gr-per-val-code
         tt-group-period-validity.gr-per-val-name
         tt-group-period-validity.gr-per-from
         tt-group-period-validity.gr-per-to tt-group-period-validity.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
case p-mode:
  when {&add-def} then do:
    display
    ? @ tt-group-period-validity.gr-per-val-code
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-group-period-validity THEN
    DISPLAY
    tt-group-period-validity.gr-per-val-code
    tt-group-period-validity.gr-per-val-name
    tt-group-period-validity.gr-per-from
    tt-group-period-validity.gr-per-to tt-group-period-validity.des
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame {&frame-name}.
end.


ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Hist when p-mode <> {&add-def}
B-Help
tt-group-period-validity.gr-per-val-name when p-mode <> {&lookup}
tt-group-period-validity.gr-per-from      when p-mode <> {&lookup}
tt-group-period-validity.gr-per-to when p-mode <> {&lookup}
tt-group-period-validity.des when p-mode <> {&lookup}
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-save Dialog-Frame
PROCEDURE Proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-group-period-validity then do:
    create tt-group-period-validity.
end.

assign
tt-group-period-validity.gr-per-val-code frame {&frame-name}
tt-group-period-validity.gr-per-val-name
tt-group-period-validity.gr-per-to
tt-group-period-validity.des = tt-group-period-validity.des:SCREEN-VALUE
tt-group-period-validity.gr-per-from

.
 run ref/gperval1.p (
input-output p-doc-rec
,input p-mode
,input tt-group-period-validity.gr-per-val-code
,input tt-group-period-validity.gr-per-val-name
,input tt-group-period-validity.des
,input tt-group-period-validity.gr-per-from
,input tt-group-period-validity.gr-per-to

)
no-error.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
