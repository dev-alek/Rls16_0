&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_tare FOR ub.tare.
DEFINE TEMP-TABLE tt-tare NO-UNDO LIKE ub.tare.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка ТАРЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/09
Author: Bakhtadze Natalya
Creation date: 09/30/09


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo.
define input parameter p-tare-code like ub.tare.tare-code no-undo.
define input-output parameter p-rid as recid init ? no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка ТАРЫ".
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
&Scoped-define INTERNAL-TABLES tt-tare

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-tare.tare-code ~
tt-tare.tare-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-tare.tare-code ~
tt-tare.tare-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-tare
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-tare
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-tare SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-tare SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-tare
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-tare


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-tare.tare-code tt-tare.tare-name
&Scoped-define ENABLED-TABLES tt-tare
&Scoped-define FIRST-ENABLED-TABLE tt-tare
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help
&Scoped-Define DISPLAYED-FIELDS tt-tare.tare-code tt-tare.tare-name
&Scoped-define DISPLAYED-TABLES tt-tare
&Scoped-define FIRST-DISPLAYED-TABLE tt-tare


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

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-tare SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 58
     B-Help AT ROW 1 COL 61
     tt-tare.tare-code AT ROW 3.77 COL 20 COLON-ALIGNED
          LABEL "Код (аббревиатура)"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-tare.tare-name AT ROW 5.27 COL 20 COLON-ALIGNED
          LABEL "Полное наименование"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
     SPACE(6.12) SKIP(1.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ТАРА"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_tare B "?" ? ub tare
      TABLE: tt-tare T "?" NO-UNDO ub tare
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

/* SETTINGS FOR FILL-IN tt-tare.tare-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-tare.tare-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-tare"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Единица измерения */
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

      run ref/ctares.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT tt-tare.tare-code
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
 if p-mode <> {&lookup} then do:
    if v-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи ЕД.ИЗМ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-tare:
        delete tt-tare.
    end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_tare EXclusive-lock where
                   recid(locked_tare) = p-rid no-wait no-error.
      if locked locked_tare then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ЕД.ИЗМ. занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_tare no-lock where
                       recid(locked_tare) = p-rid no-error .
      if not avail locked_tare then do:
        find first locked_tare where
                  locKed_tare.tare-code = p-tare-code no-error .
      end.
    end.
    if not available locked_tare then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ЕД.ИЗМ."
      view-as alert-box error .
      undo, return error.
    end.
    create tt-tare.
    buffer-copy locked_tare to tt-tare.
  end.
  else do:
    create tt-tare.
  end.
  RUN MYenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
session:data-entry-return = no .
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
  IF AVAILABLE tt-tare THEN
    DISPLAY tt-tare.tare-code tt-tare.tare-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-tare.tare-code tt-tare.tare-name
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
session:data-entry-return = yes .
IF AVAILABLE tt-tare THEN
    DISPLAY
    tt-tare.tare-name
    tt-tare.tare-code
    WITH FRAME {&frame-name} .
  if p-mode = {&lookup} then do:
    assign
    b-exit:label = "&Выход".
  end.
  ENABLE
  B-exit when p-mode <> {&lookup}
  b-quit
  B-Help
  b-hist WHEN p-mode <> {&add-def}
  tt-tare.tare-name when p-mode <> {&lookup}
  tt-tare.tare-code when p-mode = {&add-def}
  WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  IF p-mode = {&update} then do:
   FRAME {&frame-name}:title = "Изменение тары".
    DISPLAY
    tt-tare.tare-name
    tt-tare.tare-code
    WITH frame {&frame-name}.
  end.
  if p-mode = {&lookup} then do:
    hide
    b-exit in frame {&frame-name} .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
assign
frame {&frame-name}
tt-tare.tare-name
tt-tare.tare-code
.
run ref/tare01.p (
 input-output v-rid
,input no /*p-silent*/
,input p-mode
,input tt-tare.tare-name
,input tt-tare.tare-code
,input tt-tare.key#_one
,input tt-tare.key#_two
,input tt-tare.charkey_one
,input tt-tare.charkey_two
) no-error.

if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rid = v-rid.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME