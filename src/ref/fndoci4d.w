&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE SHARED TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования платежного поручения - дополнительные пол

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/25/03
Author: Bakhtadze Natalya
Creation date: 11/25/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.


define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.

define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования платежного поручения-дополнительные поля".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fin-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fin-doc.vid-opl ~
tt-fin-doc.srok-pl tt-fin-doc.nazn-pl tt-fin-doc.ocher-pl tt-fin-doc.f22 ~
tt-fin-doc.f23 tt-fin-doc.stat-pl tt-fin-doc.f104 tt-fin-doc.f105 ~
tt-fin-doc.f106 tt-fin-doc.f107 tt-fin-doc.f108 tt-fin-doc.f109 ~
tt-fin-doc.f110
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-fin-doc.ocher-pl ~
tt-fin-doc.stat-pl tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 ~
tt-fin-doc.f107 tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-fin-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-fin-doc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-fin-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-fin-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fin-doc.ocher-pl tt-fin-doc.stat-pl ~
tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 tt-fin-doc.f107 ~
tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
&Scoped-define ENABLED-TABLES tt-fin-doc
&Scoped-define FIRST-ENABLED-TABLE tt-fin-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-fin-doc.vid-opl tt-fin-doc.srok-pl ~
tt-fin-doc.nazn-pl tt-fin-doc.ocher-pl tt-fin-doc.f22 tt-fin-doc.f23 ~
tt-fin-doc.stat-pl tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 ~
tt-fin-doc.f107 tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
&Scoped-define DISPLAYED-TABLES tt-fin-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-fin-doc
&Scoped-Define DISPLAYED-OBJECTS F-stat-pl

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-stat-pl AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 51.75 BY 1
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-fin-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     tt-fin-doc.vid-opl AT ROW 2.25 COL 18 COLON-ALIGNED
          LABEL "Вид операции"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.srok-pl AT ROW 2.25 COL 45.63 COLON-ALIGNED
          LABEL "Срок платежа"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.nazn-pl AT ROW 3.5 COL 18 COLON-ALIGNED
          LABEL "Назн.платежа(код)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.ocher-pl AT ROW 3.5 COL 45.63 COLON-ALIGNED
          LABEL "Очер. платежа"
          VIEW-AS COMBO-BOX INNER-LINES 6
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f22 AT ROW 4.75 COL 18 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f23 AT ROW 4.75 COL 45.63 COLON-ALIGNED
          LABEL "Резервн. поле"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.stat-pl AT ROW 6 COL 21.25 COLON-ALIGNED
          LABEL "Статус плательщика"
          VIEW-AS COMBO-BOX INNER-LINES 8
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 7.63 BY 1
          BGCOLOR 15 FGCOLOR 4
     F-stat-pl AT ROW 6 COL 31 COLON-ALIGNED NO-LABEL
     tt-fin-doc.f104 AT ROW 7.25 COL 5.88 COLON-ALIGNED
          LABEL "КБК" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f105 AT ROW 7.25 COL 56.88 COLON-ALIGNED
          LABEL "ОКАТО муниц.образования"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f106 AT ROW 8.5 COL 27 COLON-ALIGNED
          LABEL "Показат. основания платежа"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.38 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f107 AT ROW 9.75 COL 27 COLON-ALIGNED
          LABEL "Показат. налог. периода"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f108 AT ROW 11 COL 27 COLON-ALIGNED
          LABEL "Показат. № документа"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f109 AT ROW 12.25 COL 27 COLON-ALIGNED
          LABEL "Показат. даты документа"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15 FGCOLOR 4
     tt-fin-doc.f110 AT ROW 13.5 COL 27.13 COLON-ALIGNED
          LABEL "Показат. типа платежа"
          VIEW-AS COMBO-BOX INNER-LINES 8
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 12 BY 1
     SPACE(58.11) SKIP(1.34)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Остальные поля платежа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-fin-doc T "SHARED" NO-UNDO ub fin-doc
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

/* SETTINGS FOR FILL-IN F-stat-pl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.f104 IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.f105 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-fin-doc.f106 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.f107 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.f108 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.f109 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-fin-doc.f110 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.f22 IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.f23 IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.nazn-pl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR COMBO-BOX tt-fin-doc.ocher-pl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.srok-pl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR COMBO-BOX tt-fin-doc.stat-pl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.vid-opl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-fin-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Остальные поля платежа */
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


&Scoped-define SELF-NAME tt-fin-doc.stat-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fin-doc.stat-pl Dialog-Frame
ON VALUE-CHANGED OF tt-fin-doc.stat-pl IN FRAME Dialog-Frame /* Статус плательщика */
DO:
  &scop fin-statpl-code tt-fin-doc.stat-pl:screen-value
  assign
  F-stat-pl = {&fin-statpl-codes-name} no-error .
  if error-status:error then do:
    assign
    f-stat-pl = ?
    .
  end.
  display
  f-stat-pl
  with frame {&frame-name}.
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
  DISPLAY F-stat-pl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-doc THEN
    DISPLAY tt-fin-doc.vid-opl tt-fin-doc.srok-pl tt-fin-doc.nazn-pl
          tt-fin-doc.ocher-pl tt-fin-doc.f22 tt-fin-doc.f23 tt-fin-doc.stat-pl
          tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 tt-fin-doc.f107
          tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-fin-doc.ocher-pl tt-fin-doc.stat-pl
         tt-fin-doc.f104 tt-fin-doc.f105 tt-fin-doc.f106 tt-fin-doc.f107
         tt-fin-doc.f108 tt-fin-doc.f109 tt-fin-doc.f110
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
find first tt-fin-doc.
assign
tt-fin-doc.stat-pl:list-items in frame {&frame-name} = "":U + {&comma-char} + {&fin-statpl-codes}
tt-fin-doc.f106:list-items in frame {&frame-name} = {&fin-osnpl-codes}
tt-fin-doc.f110:list-items in frame {&frame-name} = {&fin-tippl-codes}
tt-fin-doc.ocher-pl:list-items in frame {&frame-name} = "1,2,3,4,5,6"
.
CASE tt-fin-doc.fin-doc-type:
  when {&income-cashless} then do:
    IF AVAILABLE tt-fin-doc THEN
    DISPLAY
    tt-fin-doc.vid-opl
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    WITH FRAME Dialog-Frame.
    if p-mode <> {&lookup} then do:
      ENABLE
      B-exit
      B-Help
      tt-fin-doc.ocher-pl
      WITH FRAME Dialog-Frame.
    end.
    APPLY "VALUE-CHANGED" to tt-fin-doc.stat-pl.
  end.
  when {&expense-cashless}  then do:
    DISPLAY
    F-stat-pl
    WITH FRAME Dialog-Frame.
    IF AVAILABLE tt-fin-doc THEN
    DISPLAY
    tt-fin-doc.vid-opl
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    tt-fin-doc.stat-pl
    tt-fin-doc.f104
    tt-fin-doc.f105
    tt-fin-doc.f106
    tt-fin-doc.f107
    tt-fin-doc.f108
    tt-fin-doc.f109
    tt-fin-doc.f110
    WITH FRAME Dialog-Frame.
    if p-mode <> {&lookup} then do:
      ENABLE
      B-exit
      B-Help
      tt-fin-doc.ocher-pl
      tt-fin-doc.stat-pl
      tt-fin-doc.f104
      tt-fin-doc.f105
      tt-fin-doc.f106
      tt-fin-doc.f107
      tt-fin-doc.f108
      tt-fin-doc.f109
      tt-fin-doc.f110
      WITH FRAME Dialog-Frame.
    end.
    APPLY "VALUE-CHANGED" to tt-fin-doc.stat-pl.
  end.
END CASE.
ENABLE
B-quit
B-Help
WITH FRAME Dialog-Frame.
if p-mode = {&lookup} then do:
  hide b-exit in frame {&frame-name}.
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
VIEW FRAME Dialog-Frame.
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
CASE tt-fin-doc.fin-doc-type:
  when {&income-cashless} then do:
    assign
    tt-fin-doc.vid-opl frame {&frame-name}
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    .
  end.
  when {&expense-cashless} then do:
    assign
    tt-fin-doc.vid-opl frame {&frame-name}
    tt-fin-doc.srok-pl
    tt-fin-doc.nazn-pl
    tt-fin-doc.ocher-pl
    tt-fin-doc.f22
    tt-fin-doc.f23
    tt-fin-doc.stat-pl
    tt-fin-doc.f104
    tt-fin-doc.f105
    tt-fin-doc.f106
    tt-fin-doc.f107
    tt-fin-doc.f108
    tt-fin-doc.f109
    tt-fin-doc.f110
    .
  end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME