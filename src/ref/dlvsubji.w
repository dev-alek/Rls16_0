&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_delivery-subject FOR ub.delivery-subject.
DEFINE TEMP-TABLE tt-delivery-subject NO-UNDO LIKE ub.delivery-subject.
DEFINE BUFFER X_curr_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования СУБЪЕКТА ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/17/04
Author: Bakhtadze Natalya
Creation date: 03/17/04

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
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.delivery-subject.deliv-subj-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования СУБЪЕКТА ДОСТАВКИ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.delivery-subject.deliv-subj-code no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,deliv-subj-code,deliv-subj-name,des," +  ~
                  ""

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-delivery-subject

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-delivery-subject.deliv-subj-code tt-delivery-subject.deliv-subj-name ~
tt-delivery-subject.reg-code tt-delivery-subject.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-delivery-subject.deliv-subj-code tt-delivery-subject.deliv-subj-name ~
tt-delivery-subject.reg-code tt-delivery-subject.des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-delivery-subject
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-delivery-subject
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-delivery-subject SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-delivery-subject SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-delivery-subject
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-delivery-subject


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-delivery-subject.deliv-subj-code ~
tt-delivery-subject.deliv-subj-name tt-delivery-subject.reg-code ~
tt-delivery-subject.des
&Scoped-define ENABLED-TABLES tt-delivery-subject
&Scoped-define FIRST-ENABLED-TABLE tt-delivery-subject
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help b-region
&Scoped-Define DISPLAYED-FIELDS tt-delivery-subject.deliv-subj-code ~
tt-delivery-subject.deliv-subj-name tt-delivery-subject.reg-code ~
tt-delivery-subject.des
&Scoped-define DISPLAYED-TABLES tt-delivery-subject
&Scoped-define FIRST-DISPLAYED-TABLE tt-delivery-subject
&Scoped-Define DISPLAYED-OBJECTS f-reg-name

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

DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-region
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1.

DEFINE VARIABLE f-reg-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 61.5 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-delivery-subject SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-delivery-subject.deliv-subj-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-delivery-subject.deliv-subj-name AT ROW 4.27 COL 34 COLON-ALIGNED
          LABEL "Название субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 63 BY 1
     tt-delivery-subject.reg-code AT ROW 6.33 COL 34 COLON-ALIGNED WIDGET-ID 4
          LABEL "Регион"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     b-region AT ROW 6.33 COL 40 WIDGET-ID 2
     f-reg-name AT ROW 7.4 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     tt-delivery-subject.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.77
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.77 COL 1.5
     SPACE(81.74) SKIP(4.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Субъект доставки"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_delivery-subject B "?" ? ub delivery-subject
      TABLE: tt-delivery-subject T "?" NO-UNDO ub delivery-subject
      TABLE: X_curr_clients B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-delivery-subject.deliv-subj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-delivery-subject.deliv-subj-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-reg-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-delivery-subject.reg-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-delivery-subject"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Субъект доставки */
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
    run ref/dlvcsubs.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_delivery-subject.deliv-subj-code
                ,input-output v-rid-list
                              )

 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-region Dialog-Frame
ON CHOOSE OF b-region IN FRAME Dialog-Frame
DO:
  define buffer buf_regions for ub.regions.

  define variable v-reg-code like ub.regions.reg-code no-undo .

  run ref/regions.w ( input  parParentProc
                    , input  {&choose}
                    , output v-reg-code
                    ).
  /*apply "ENTRY" to b-exit.  АНАЛОГИЧНО*/
  if v-reg-code <> ? then do :
    find first buf_regions no-lock
      where buf_regions.reg-code = v-reg-code
    no-error .
    if not available buf_regions then do:
      message
        "Неверный код региона " v-reg-code
      view-as alert-box error.
      return no-apply.
    end.
    else do:
      assign
        tt-delivery-subject.reg-code = buf_regions.reg-code
      .
      display
      tt-delivery-subject.reg-code
      buf_regions.reg-name @ f-reg-name
      with frame {&frame-name}.
    end.
  end.
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
    "Нельзя редактировать запись СУБЪЕКТА ДОСТАВКИ в УБД"
    view-as alert-box ERROR.
    return error .
END.

  for each tt-delivery-subject:
    delete tt-delivery-subject.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_delivery-subject EXclusive-lock where
                   recid(locked_delivery-subject) = p-doc-rec no-wait no-error.
      if locked locked_delivery-subject then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись СУБЪЕКТА ДОСТАВКИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_delivery-subject no-lock where
                       recid(locked_delivery-subject) = p-doc-rec no-error .
      if not avail locked_delivery-subject then do:
        find first locked_delivery-subject no-lock where
                   locked_delivery-subject.deliv-subj-code = p-deliv-subj-code no-error .
      end.
    end.
    if not available locked_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СУБЪЕКТА ДОСТАВКИ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-delivery-subject.
    buffer-copy locked_delivery-subject to tt-delivery-subject.
   end.
   else do:
          create tt-delivery-subject.
          assign
         tt-delivery-subject.deliv-subj-code = v-last-code + 1
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
  DISPLAY f-reg-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-delivery-subject THEN
    DISPLAY tt-delivery-subject.deliv-subj-code
          tt-delivery-subject.deliv-subj-name tt-delivery-subject.reg-code
          tt-delivery-subject.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-delivery-subject.deliv-subj-code
         tt-delivery-subject.deliv-subj-name tt-delivery-subject.reg-code
         b-region tt-delivery-subject.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
DEFINE BUFFER buf_regions FOR ub.regions.
IF tt-delivery-subject.reg-code > 0  THEN DO:
  find first buf_regions no-lock
      where buf_regions.reg-code = tt-delivery-subject.reg-code
    no-error .
  if not available buf_regions then do:
    message
    SUBSTITUTE("Неверный код региона &1", tt-delivery-subject.reg-code)
    view-as alert-box error.
   end.
END.
case p-mode:
  when {&add-def} then do:
    display
    ? @ tt-delivery-subject.deliv-subj-code
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-delivery-subject THEN
    DISPLAY
    tt-delivery-subject.deliv-subj-code
    tt-delivery-subject.deliv-subj-name
    tt-delivery-subject.des
    (IF AVAILABLE buf_regions
     THEN buf_regions.reg-name
     ELSE '')   @ f-reg-name
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
b-region when p-mode <> {&lookup}
B-Help
tt-delivery-subject.deliv-subj-name when p-mode <> {&lookup}
tt-delivery-subject.des when p-mode <> {&lookup}
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

if not available tt-delivery-subject then do:
    create tt-delivery-subject.
end.

assign
tt-delivery-subject.deliv-subj-code frame {&frame-name}
tt-delivery-subject.deliv-subj-name
tt-delivery-subject.des = tt-delivery-subject.des:SCREEN-VALUE
.
 run ref/dlvsubj1.p (
input-output p-doc-rec
,input p-mode
,input tt-delivery-subject.deliv-subj-code
,input tt-delivery-subject.deliv-subj-name
,input tt-delivery-subject.reg-code
,input tt-delivery-subject.des
)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
