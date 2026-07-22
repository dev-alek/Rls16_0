&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_currency FOR ub.currency.
DEFINE TEMP-TABLE tt-currency NO-UNDO LIKE ub.currency.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка  валюты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/03
Author: Bakhtadze Natalya
Creation date: 10/16/03

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE  INPUT        PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define  input        parameter p-mode as char  no-undo.
define  input        parameter p-curr-code like ub.currency.curr-code no-undo .
define  input-output parameter p-rid   as   recid  init ? no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "карточка валюты".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
define variable v-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-currency

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-currency.okv-code ~
tt-currency.curr-name tt-currency.curr-name-one tt-currency.curr-name-three ~
tt-currency.curr-name-five tt-currency.curr-eng-name ~
tt-currency.curr-eng-name-one tt-currency.curr-eng-name-three ~
tt-currency.curr-eng-name-five tt-currency.part-name ~
tt-currency.part-name-one tt-currency.part-name-three ~
tt-currency.part-name-five tt-currency.part-abbr 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-currency.curr-abbr ~
tt-currency.curr-code tt-currency.okv-code tt-currency.curr-name ~
tt-currency.curr-name-one tt-currency.curr-name-three ~
tt-currency.curr-name-five tt-currency.curr-eng-name ~
tt-currency.curr-eng-name-one tt-currency.curr-eng-name-three ~
tt-currency.curr-eng-name-five tt-currency.part-name ~
tt-currency.part-name-one tt-currency.part-name-three ~
tt-currency.part-name-five tt-currency.part-abbr 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-currency
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-currency
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-currency SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-currency SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-currency
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-currency


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-currency.curr-abbr tt-currency.curr-code ~
tt-currency.okv-code tt-currency.curr-name tt-currency.curr-name-one ~
tt-currency.curr-name-three tt-currency.curr-name-five ~
tt-currency.curr-eng-name tt-currency.curr-eng-name-one ~
tt-currency.curr-eng-name-three tt-currency.curr-eng-name-five ~
tt-currency.part-name tt-currency.part-name-one tt-currency.part-name-three ~
tt-currency.part-name-five tt-currency.part-abbr 
&Scoped-define ENABLED-TABLES tt-currency
&Scoped-define FIRST-ENABLED-TABLE tt-currency
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help f-okv-code-chr 
&Scoped-Define DISPLAYED-FIELDS tt-currency.okv-code tt-currency.curr-name ~
tt-currency.curr-name-one tt-currency.curr-name-three ~
tt-currency.curr-name-five tt-currency.curr-eng-name ~
tt-currency.curr-eng-name-one tt-currency.curr-eng-name-three ~
tt-currency.curr-eng-name-five tt-currency.part-name ~
tt-currency.part-name-one tt-currency.part-name-three ~
tt-currency.part-name-five tt-currency.part-abbr 
&Scoped-define DISPLAYED-TABLES tt-currency
&Scoped-define FIRST-DISPLAYED-TABLE tt-currency
&Scoped-Define DISPLAYED-OBJECTS f-okv-code-chr 

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

DEFINE VARIABLE f-okv-code-chr AS CHARACTER FORMAT "X(3)":U 
     LABEL "Буквенный код" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-currency SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.9
     tt-currency.curr-abbr AT ROW 3.63 COL 47.9 COLON-ALIGNED
          LABEL "Аббревиатура"
          VIEW-AS FILL-IN 
          SIZE 7.6 BY 1
     tt-currency.curr-code AT ROW 3.67 COL 28.4 COLON-ALIGNED
          LABEL "Код валюты"
          VIEW-AS FILL-IN 
          SIZE 3.3 BY 1
     tt-currency.okv-code AT ROW 4.97 COL 28 COLON-ALIGNED
          LABEL "Код Общерос.Классиф.Валют"
          VIEW-AS FILL-IN 
          SIZE 8.1 BY 1
     f-okv-code-chr AT ROW 5 COL 55 COLON-ALIGNED WIDGET-ID 2
     tt-currency.curr-name AT ROW 6.3 COL 17.6 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN 
          SIZE 41 BY 1
     tt-currency.curr-name-one AT ROW 7.57 COL 27.4 COLON-ALIGNED
          LABEL "один/одна..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите название в единственном числе"
     tt-currency.curr-name-three AT ROW 8.8 COL 27.5 COLON-ALIGNED
          LABEL "три..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите спряжение для числительных 2-4"
     tt-currency.curr-name-five AT ROW 9.93 COL 27.5 COLON-ALIGNED
          LABEL "пять..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите спряженеи для числительных пять и т.д."
     tt-currency.curr-eng-name AT ROW 11.07 COL 1.1
          LABEL "Название (англ.)"
          VIEW-AS FILL-IN 
          SIZE 41 BY 1
     tt-currency.curr-eng-name-one AT ROW 12.3 COL 28 COLON-ALIGNED
          LABEL "one..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите название в единственном числе"
     tt-currency.curr-eng-name-three AT ROW 13.37 COL 28 COLON-ALIGNED
          LABEL "three..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите спряжение для числительных 2-4"
     tt-currency.curr-eng-name-five AT ROW 14.5 COL 28.1 COLON-ALIGNED
          LABEL "five..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите спряженеи для числительных пять и т.д."
     tt-currency.part-name AT ROW 15.7 COL 23.8 COLON-ALIGNED
          LABEL "Название дробной части"
          VIEW-AS FILL-IN 
          SIZE 36 BY 1
     tt-currency.part-name-one AT ROW 16.8 COL 28 COLON-ALIGNED
          LABEL "один/одна..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите название в единственном числе"
     tt-currency.part-name-three AT ROW 17.87 COL 28 COLON-ALIGNED
          LABEL "три..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите спряжение для числительных 2-4"
     tt-currency.part-name-five AT ROW 19 COL 28.1 COLON-ALIGNED
          LABEL "пять..."
          VIEW-AS FILL-IN 
          SIZE 41 BY 1 TOOLTIP "Укажите спряженеи для числительных пять и т.д."
     tt-currency.part-abbr AT ROW 20.2 COL 28.3 COLON-ALIGNED
          LABEL "Сокращение дробной части"
          VIEW-AS FILL-IN 
          SIZE 6.6 BY 1
     SPACE(39.72) SKIP(0.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Валюта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_currency B "?" ? ub currency
      TABLE: tt-currency T "?" NO-UNDO ub currency
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

/* SETTINGS FOR FILL-IN tt-currency.curr-abbr IN FRAME Dialog-Frame
   NO-DISPLAY EXP-LABEL                                                 */
/* SETTINGS FOR FILL-IN tt-currency.curr-code IN FRAME Dialog-Frame
   NO-DISPLAY EXP-LABEL                                                 */
/* SETTINGS FOR FILL-IN tt-currency.curr-eng-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-currency.curr-eng-name-five IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.curr-eng-name-one IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.curr-eng-name-three IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.curr-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.curr-name-five IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.curr-name-one IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.curr-name-three IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.okv-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.part-abbr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.part-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.part-name-five IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.part-name-one IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-currency.part-name-three IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-currency"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Валюта */
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
    define variable v-rid-list as character no-undo.
    run ref/ccurrenc.w
                (
                 input parParentProc
                ,input "":U /*bttns*/
                ,input "one":U
                ,input tt-currency.curr-code
                ,input-output v-rid-list
                              ).

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
 if p-mode <> {&lookup} then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ВАЛЮТЫ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-currency:
    delete tt-currency.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_currency EXclusive-lock where
                   recid(locked_currency) = p-rid no-wait no-error.
      if locked locked_currency then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВАЛЮТЫ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_currency no-lock where
                       recid(locked_currency) = p-rid no-error .
      if not avail locked_currency then do:
        find first locked_currency where
                  locKed_currency.curr-code = p-curr-code no-error .
      end.
    end.
    if not available locked_currency then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАЛЮТЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-currency.
    buffer-copy locked_currency to tt-currency.
  end.
  if p-mode = {&add-def} then do:
    create tt-currency.
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
  DISPLAY f-okv-code-chr 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-currency THEN 
    DISPLAY tt-currency.okv-code tt-currency.curr-name tt-currency.curr-name-one 
          tt-currency.curr-name-three tt-currency.curr-name-five 
          tt-currency.curr-eng-name tt-currency.curr-eng-name-one 
          tt-currency.curr-eng-name-three tt-currency.curr-eng-name-five 
          tt-currency.part-name tt-currency.part-name-one 
          tt-currency.part-name-three tt-currency.part-name-five 
          tt-currency.part-abbr 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-currency.curr-abbr 
         tt-currency.curr-code tt-currency.okv-code f-okv-code-chr 
         tt-currency.curr-name tt-currency.curr-name-one 
         tt-currency.curr-name-three tt-currency.curr-name-five 
         tt-currency.curr-eng-name tt-currency.curr-eng-name-one 
         tt-currency.curr-eng-name-three tt-currency.curr-eng-name-five 
         tt-currency.part-name tt-currency.part-name-one 
         tt-currency.part-name-three tt-currency.part-name-five 
         tt-currency.part-abbr 
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
if num-entries(tt-currency.curr-eng-name, {&delim-par}) > 1 then do:
  f-okv-code-chr = entry(2, tt-currency.curr-eng-name, {&delim-par}).
  tt-currency.curr-eng-name = entry(2, tt-currency.curr-eng-name, {&delim-par}).
end.
IF AVAILABLE
tt-currency THEN
DISPLAY
f-okv-code-chr
tt-currency.okv-code
tt-currency.curr-abbr
tt-currency.curr-code
tt-currency.curr-name
tt-currency.curr-name-one
tt-currency.curr-name-three
tt-currency.curr-name-five
tt-currency.curr-eng-name
tt-currency.curr-eng-name-one
tt-currency.curr-eng-name-three
tt-currency.curr-eng-name-five
tt-currency.part-name
tt-currency.part-name-one
tt-currency.part-name-three
tt-currency.part-name-five
tt-currency.part-abbr
WITH FRAME Dialog-Frame.
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход".
  ENABLE
  b-quit
  B-Help
  with frame {&frame-name} .
  hide
  b-exit in frame {&frame-name} .
end.
else do:
  ENABLE
  B-exit
  b-quit
  b-hist WHEN p-mode <> {&ADD-DEF}
  B-Help
  f-okv-code-chr
  tt-currency.curr-abbr when p-mode = {&add-def}
  tt-currency.curr-code when p-mode = {&add-def}
  tt-currency.okv-code
  tt-currency.curr-name
  tt-currency.curr-name-one
  tt-currency.curr-name-three
  tt-currency.curr-name-five
  tt-currency.curr-eng-name
  tt-currency.curr-eng-name-one
  tt-currency.curr-eng-name-three
  tt-currency.curr-eng-name-five
  tt-currency.part-name
  tt-currency.part-name-one
  tt-currency.part-name-three
  tt-currency.part-name-five
  tt-currency.part-abbr
  WITH FRAME {&frame-name} .
end.

VIEW FRAME {&frame-name} .

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
define variable glog as logical no-undo .
if tt-currency.curr-eng-name:screen-value in frame {&frame-name} = ""  then do:
  message
  "Вы уверены, что для данной валюты НЕ НУЖНО вводить АНГЛИЙСКОE НАЗВАНИЕ?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then do:
      apply "ENTRY":U to tt-currency.curr-eng-name.
      return error.
  end.
end.
if tt-currency.part-abbr:screen-value = "" OR
   tt-currency.part-name:screen-value  = "" then do:
  message
  "Вы уверены, что у данной валюты НЕТ ДРОБНОЙ ЧАСТИ?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then do:
    apply "ENTRY":U  to tt-currency.part-name.
    return error.
  end.
end.
assign
frame {&frame-name}
f-okv-code-chr
tt-currency.curr-code
tt-currency.curr-abbr
tt-currency.part-abbr
tt-currency.curr-name
tt-currency.curr-name-one
tt-currency.curr-name-three
tt-currency.curr-name-five
tt-currency.curr-eng-name
tt-currency.curr-eng-name-one
tt-currency.curr-eng-name-three
tt-currency.curr-eng-name-five
tt-currency.part-name
tt-currency.part-name-one
tt-currency.part-name-three
tt-currency.part-name-five
tt-currency.okv-code
.
run ref/currenc1.p (
 input-output p-rid
,input p-mode
,input false /* p-silent */
,input tt-currency.curr-code
,input tt-currency.curr-abbr
,input tt-currency.part-abbr
,input tt-currency.curr-name
,input tt-currency.curr-name-one
,input tt-currency.curr-name-three
,input tt-currency.curr-name-five
,input tt-currency.curr-eng-name
,input tt-currency.curr-eng-name-one
,input tt-currency.curr-eng-name-three
,input tt-currency.curr-eng-name-five
,input tt-currency.part-name
,input tt-currency.part-name-one
,input tt-currency.part-name-three
,input tt-currency.part-name-five
,input tt-currency.okv-code
,input f-okv-code-chr
) no-error .

if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

