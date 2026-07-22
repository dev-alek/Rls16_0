&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_country FOR ub.country.
DEFINE TEMP-TABLE tt-country NO-UNDO LIKE ub.country.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования страны

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/05
Author: Bakhtadze Natalya
Creation date: 02/15/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
/* Parameters Definitions ---                                           */
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/
define input parameter p-alpha1 like ub.country.alpha1 no-undo .
define input-output parameter p-doc-rec as recid no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования страны".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.

&scop tab-order   "B-exit,b-quit,b-help,alpha1,num-code,alpha2,short-name,long-name"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-country

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-country.alpha1 ~
tt-country.num-code tt-country.alpha2 tt-country.short-name ~
tt-country.long-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-country.alpha1 ~
tt-country.num-code tt-country.alpha2 tt-country.short-name ~
tt-country.long-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-country
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-country
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-country SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-country SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-country
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-country


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-country.alpha1 tt-country.num-code ~
tt-country.alpha2 tt-country.short-name tt-country.long-name
&Scoped-define ENABLED-TABLES tt-country
&Scoped-define FIRST-ENABLED-TABLE tt-country
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help
&Scoped-Define DISPLAYED-FIELDS tt-country.alpha1 tt-country.num-code ~
tt-country.alpha2 tt-country.short-name tt-country.long-name
&Scoped-define DISPLAYED-TABLES tt-country
&Scoped-define FIRST-DISPLAYED-TABLE tt-country


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

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-country SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     B-Help AT ROW 1 COL 61
     tt-country.alpha1 AT ROW 3 COL 18 COLON-ALIGNED
          LABEL "Код страны - 1"
          VIEW-AS FILL-IN
          SIZE 3.5 BY 1
     tt-country.num-code AT ROW 3 COL 39 COLON-ALIGNED
          LABEL "Цифровой код"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-country.alpha2 AT ROW 4.5 COL 18 COLON-ALIGNED
          LABEL "Код страны - 2"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-country.short-name AT ROW 6 COL 18 COLON-ALIGNED
          LABEL "Короткое назв."
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-country.long-name AT ROW 8 COL 18 COLON-ALIGNED
          LABEL "Название страны"
          VIEW-AS FILL-IN
          SIZE 54 BY 1
     SPACE(2.37) SKIP(1.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Страна"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_country B "?" ? ub country
      TABLE: tt-country T "?" NO-UNDO ub country
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

/* SETTINGS FOR FILL-IN tt-country.alpha1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-country.alpha2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-country.long-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-country.num-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-country.short-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-country"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Страна */
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


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-undo.

      run ref/ccountrs.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT tt-country.num-code
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.


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

 { gbl/curdbnum.i v-db-num }
IF v-db-num <> 0
AND (p-mode = {&add-def}
     OR p-mode = {&UPDATE} ) THEN DO:
      message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись СТРАНЫ в УБД"
    view-as alert-box ERROR.
    return error .
END.

  for each tt-country:
    delete tt-country.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_country EXclusive-lock where
                   recid(locked_country) = p-doc-rec no-wait no-error.
      if locked locked_country then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись СТРАНЫ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_country no-lock where
                       recid(locked_country) = p-doc-rec no-error .
      if not avail locked_country then do:
        find first locked_country no-lock where
                   locked_country.alpha1 = p-alpha1 no-error .
      end.
    end.
    if not available locked_country then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СТРАНЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-country.
    buffer-copy locked_country to tt-country.
   end.
   else do:
          create tt-country.
         .
   end.


  RUN MYenable.
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
  IF AVAILABLE tt-country THEN
    DISPLAY tt-country.alpha1 tt-country.num-code tt-country.alpha2
          tt-country.short-name tt-country.long-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-country.alpha1 tt-country.num-code
         tt-country.alpha2 tt-country.short-name tt-country.long-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
IF AVAILABLE tt-country THEN
DISPLAY tt-country.alpha1
WITH FRAME {&frame-name}.
IF AVAILABLE locked_country THEN
DISPLAY
tt-country.alpha1
tt-country.num-code
tt-country.alpha2
tt-country.short-name
tt-country.long-name
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&lookup}
b-quit
B-Help
b-hist WHEN p-mode <> {&add-def}
tt-country.alpha1    WHEN p-mode = {&add-def}
tt-country.alpha2    WHEN p-mode <> {&lookup}
tt-country.num-code  WHEN p-mode = {&add-def}
tt-country.short-name  WHEN p-mode <> {&lookup}
tt-country.long-name  WHEN p-mode <> {&lookup}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
CASE p-mode:
  WHEN {&LOOKUP} THEN DO:
    HIDE b-exit IN FRAME {&frame-name}.
    ASSIGN
    b-quit:LABEL = "&Выход".

  END.
  WHEN {&add-def} THEN DO:
    FRAME {&frame-name}:TITLE = "Ввод СТРАНЫ" .
  END.
WHEN {&update} THEN DO:
    FRAME {&frame-name}:TITLE = "Редактирование СТРАНЫ".
  END.
END CASE.
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
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-country then do:
    create tt-country.
end.
assign
frame {&frame-name}
tt-country.alpha1
tt-country.alpha2
tt-country.num-code
tt-country.short-name
tt-country.long-name
.

 run ref/country1.p (
input-output p-doc-rec
,input p-mode
,input tt-country.alpha1
,input tt-country.alpha2
,input tt-country.num-code
,input tt-country.short-name
,input tt-country.long-name

)
no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
