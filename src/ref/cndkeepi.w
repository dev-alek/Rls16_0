&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_condition-keeping FOR ub.condition-keeping.
DEFINE TEMP-TABLE tt-condition-keeping NO-UNDO LIKE ub.condition-keeping.
DEFINE BUFFER X_curr_clients FOR ub.clients.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования УСЛОВИЙ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/15/04
Author: Bakhtadze Natalya
Creation date: 03/15/04

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
DEFINE INPUT PARAMETER p-cond-keep-code LIKE ub.condition-keeping.cond-keep-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования УСЛОВИЙ ХРАНЕНИЯ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/showinf.i }


define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.condition-keeping.cond-keep-code no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,cond-keep-code,cond-keep-name,des," +  ~
                  ""

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-condition-keeping

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-condition-keeping.cond-keep-code tt-condition-keeping.cond-keep-name ~
tt-condition-keeping.t-mode-from tt-condition-keeping.t-mode-to ~
tt-condition-keeping.h-mode-from tt-condition-keeping.h-mode-to ~
tt-condition-keeping.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-condition-keeping.cond-keep-code tt-condition-keeping.cond-keep-name ~
tt-condition-keeping.t-mode-from tt-condition-keeping.t-mode-to ~
tt-condition-keeping.h-mode-from tt-condition-keeping.h-mode-to ~
tt-condition-keeping.des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-condition-keeping
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-condition-keeping
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-condition-keeping SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-condition-keeping SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-condition-keeping
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-condition-keeping


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-condition-keeping.cond-keep-code ~
tt-condition-keeping.cond-keep-name tt-condition-keeping.t-mode-from ~
tt-condition-keeping.t-mode-to tt-condition-keeping.h-mode-from ~
tt-condition-keeping.h-mode-to tt-condition-keeping.des
&Scoped-define ENABLED-TABLES tt-condition-keeping
&Scoped-define FIRST-ENABLED-TABLE tt-condition-keeping
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help
&Scoped-Define DISPLAYED-FIELDS tt-condition-keeping.cond-keep-code ~
tt-condition-keeping.cond-keep-name tt-condition-keeping.t-mode-from ~
tt-condition-keeping.t-mode-to tt-condition-keeping.h-mode-from ~
tt-condition-keeping.h-mode-to tt-condition-keeping.des
&Scoped-define DISPLAYED-TABLES tt-condition-keeping
&Scoped-define FIRST-DISPLAYED-TABLE tt-condition-keeping
&Scoped-Define DISPLAYED-OBJECTS varsts

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

DEFINE VARIABLE varsts AS CHARACTER FORMAT "X(3)":U
     LABEL "Статус"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-condition-keeping SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-condition-keeping.cond-keep-code AT ROW 3 COL 34 COLON-ALIGNED
          LABEL "Внутр.код условий хранения"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     varsts AT ROW 3 COL 54 COLON-ALIGNED
     tt-condition-keeping.cond-keep-name AT ROW 4.25 COL 34 COLON-ALIGNED
          LABEL "Название условий хранения"
          VIEW-AS FILL-IN
          SIZE 63 BY 1
     tt-condition-keeping.t-mode-from AT ROW 5.5 COL 34 COLON-ALIGNED
          LABEL "Темп.режим: от(град C)"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-condition-keeping.t-mode-to AT ROW 5.5 COL 60 COLON-ALIGNED
          LABEL "до (град C)"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-condition-keeping.h-mode-from AT ROW 6.75 COL 34 COLON-ALIGNED
          LABEL "Влажность: от(%)" FORMAT ">9.99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-condition-keeping.h-mode-to AT ROW 6.75 COL 60 COLON-ALIGNED
          LABEL "до (%)" FORMAT ">9.99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-condition-keeping.des AT ROW 10 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 8.75 COL 1.5
     SPACE(81.74) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Условия хранения"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_condition-keeping B "?" ? ub condition-keeping
      TABLE: tt-condition-keeping T "?" NO-UNDO ub condition-keeping
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

/* SETTINGS FOR FILL-IN tt-condition-keeping.cond-keep-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-condition-keeping.cond-keep-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-condition-keeping.h-mode-from IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-condition-keeping.h-mode-to IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-condition-keeping.t-mode-from IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-condition-keeping.t-mode-to IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN varsts IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-condition-keeping"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Условия хранения */
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
    run ref/ccnkeeps.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_condition-keeping.cond-keep-code
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
{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &diasize_resizable_object="tt-condition-keeping.des" }

run diasize_init in this-procedure .

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
    "Нельзя редактировать запись УСЛОВИЯ ХРАНЕНИЯ в УБД"
    view-as alert-box ERROR.
    return error .
END.

  for each tt-condition-keeping:
    delete tt-condition-keeping.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_condition-keeping EXclusive-lock where
                   recid(locked_condition-keeping) = p-doc-rec no-wait no-error.
      if locked locked_condition-keeping then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись УСЛОВИЯ ХРАНЕНИЯ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_condition-keeping no-lock where
                       recid(locked_condition-keeping) = p-doc-rec no-error .
      if not avail locked_condition-keeping then do:
        find first locked_condition-keeping no-lock where
                   locked_condition-keeping.cond-keep-code = p-cond-keep-code no-error .
      end.
    end.
    if not available locked_condition-keeping then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись УСЛОВИЯ ХРАНЕНИЯ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-condition-keeping.
    buffer-copy locked_condition-keeping to tt-condition-keeping.
   end.
   else do:
          create tt-condition-keeping.
          assign
         tt-condition-keeping.cond-keep-code = v-last-code + 1
         .
   end.
   &SCOPED-DEFINE status-code STRING(tt-condition-keeping.sts)
   ASSIGN varsts = {&status-int-name}.
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
  DISPLAY varsts
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-condition-keeping THEN
    DISPLAY tt-condition-keeping.cond-keep-code
          tt-condition-keeping.cond-keep-name tt-condition-keeping.t-mode-from
          tt-condition-keeping.t-mode-to tt-condition-keeping.h-mode-from
          tt-condition-keeping.h-mode-to tt-condition-keeping.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-condition-keeping.cond-keep-code
         tt-condition-keeping.cond-keep-name tt-condition-keeping.t-mode-from
         tt-condition-keeping.t-mode-to tt-condition-keeping.h-mode-from
         tt-condition-keeping.h-mode-to tt-condition-keeping.des
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
    ? @ tt-condition-keeping.cond-keep-code
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-condition-keeping THEN
    DISPLAY
    tt-condition-keeping.cond-keep-code
    tt-condition-keeping.cond-keep-name
    tt-condition-keeping.h-mode-from
    tt-condition-keeping.h-mode-to
    tt-condition-keeping.t-mode-from
    tt-condition-keeping.t-mode-to
    tt-condition-keeping.des
    varsts
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
tt-condition-keeping.cond-keep-name when p-mode <> {&lookup}
tt-condition-keeping.des
tt-condition-keeping.h-mode-from  when p-mode <> {&lookup}
tt-condition-keeping.h-mode-to    when p-mode <> {&lookup}
tt-condition-keeping.t-mode-from  when p-mode <> {&lookup}
tt-condition-keeping.t-mode-to    when p-mode <> {&lookup}
WITH FRAME Dialog-Frame.
if p-mode = {&lookup} then do:
  assign
    tt-condition-keeping.des:read-only in frame {&frame-name} = yes.
end.

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
DEFINE BUFFER bf_condition-keeping FOR ub.condition-keeping.
if p-mode = {&lookup} then do:
   return error.
end.
FIND FIRST bf_condition-keeping WHERE bf_condition-keeping.sts            =  0 AND
                                      bf_condition-keeping.cond-keep-name =  INPUT FRAME {&FRAME-NAME} tt-condition-keeping.cond-keep-name AND
                                      bf_condition-keeping.cond-keep-code <> tt-condition-keeping.cond-keep-code NO-LOCK NO-ERROR.
IF AVAILABLE bf_condition-keeping THEN DO:
  MESSAGE "Уже есть условие хранение со статусом <тек> с таким названием." VIEW-AS ALERT-BOX.
  RETURN ERROR.
END.
IF INPUT FRAME {&FRAME-NAME} tt-condition-keeping.h-mode-to < INPUT FRAME {&FRAME-NAME} tt-condition-keeping.h-mode-from THEN DO:
    MESSAGE "Влажность 'до' меньше влажности 'от'." VIEW-AS ALERT-BOX.
    RETURN ERROR.
END.
IF INPUT FRAME {&FRAME-NAME} tt-condition-keeping.t-mode-to < INPUT FRAME {&FRAME-NAME} tt-condition-keeping.t-mode-from THEN DO:
    MESSAGE "Температура 'до' меньше температуры 'от'." VIEW-AS ALERT-BOX.
    RETURN ERROR.
END.
if not available tt-condition-keeping then do:
    create tt-condition-keeping.
end.
assign
frame {&frame-name}
tt-condition-keeping.cond-keep-code
tt-condition-keeping.cond-keep-name
tt-condition-keeping.h-mode-from
tt-condition-keeping.h-mode-to
tt-condition-keeping.t-mode-from
tt-condition-keeping.t-mode-to
.
assign
  tt-condition-keeping.des = tt-condition-keeping.des:SCREEN-VALUE.
 run ref/cndkeep1.p (
input-output p-doc-rec
,input p-mode
,input tt-condition-keeping.cond-keep-code
,input tt-condition-keeping.cond-keep-name
,input tt-condition-keeping.des
,input tt-condition-keeping.h-mode-from
,input tt-condition-keeping.h-mode-to
,input tt-condition-keeping.t-mode-from
,input tt-condition-keeping.t-mode-to

)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME