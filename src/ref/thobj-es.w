&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Соответстие объектов внешней и текущей системы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/08
Author: Bakhtadze Natalya
Creation date: 02/10/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo.
define input-output parameter p-obj-correspondence as character no-undo.
define output parameter p-ok as logical no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Соответстие объектов внешней и текущей системы".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
define variable v-cli-string as character no-undo.
define variable v-ext-cli-string as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame X_clients.obj-type ~
X_clients.obj-code X_clients.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame X_clients.obj-type ~
X_clients.obj-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame X_clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_clients
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_clients SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_clients SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_clients.obj-type X_clients.obj-code
&Scoped-define ENABLED-TABLES X_clients
&Scoped-define FIRST-ENABLED-TABLE X_clients
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help rs-obj-type f-obj-code ~
B-cli
&Scoped-Define DISPLAYED-FIELDS X_clients.obj-type X_clients.obj-code ~
X_clients.obj-name
&Scoped-define DISPLAYED-TABLES X_clients
&Scoped-define FIRST-DISPLAYED-TABLE X_clients
&Scoped-Define DISPLAYED-OBJECTS rs-obj-type f-obj-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE rs-obj-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", 1
     SIZE 16.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      X_clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     rs-obj-type AT ROW 3 COL 22.5 NO-LABEL WIDGET-ID 8
     f-obj-code AT ROW 3 COL 38 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     X_clients.obj-type AT ROW 5 COL 22.5 NO-LABEL WIDGET-ID 12
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1"
          SIZE 16.5 BY 1
     X_clients.obj-code AT ROW 5 COL 37.5 COLON-ALIGNED NO-LABEL WIDGET-ID 14 FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     B-cli AT ROW 5 COL 48 WIDGET-ID 22
     X_clients.obj-name AT ROW 7 COL 3.5 COLON-ALIGNED NO-LABEL WIDGET-ID 16 FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 90.5 BY 1
     "Объект тек.системы" VIEW-AS TEXT
          SIZE 18 BY 1 AT ROW 5 COL 2 WIDGET-ID 20
     "Объект вн.системы" VIEW-AS TEXT
          SIZE 18 BY 1 AT ROW 3 COL 2 WIDGET-ID 18
     SPACE(79.74) SKIP(5.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Соответстие объектов внешней и текущей системы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
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

/* SETTINGS FOR FILL-IN X_clients.obj-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN X_clients.obj-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
ASSIGN
       X_clients.obj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_clients"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Соответстие объектов внешней и текущей системы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-recid as recid no-undo.
  define variable v-ok as logical no-undo.
  define variable v-cli-type as character no-undo.
  define variable v-cli-code as integer no-undo.


  if available X_clients then do:
    v-recid = recid(X_clients).
  end.
    run ref/selcli.p (
                      input  parparentproc
                     ,input ? /* h-call-prog  */
                     ,input {&prs} /*p-client-types */
                     ,input yes /*lock-cli-type*/
                     ,output v-ok
                     ,output v-cli-type
                     ,output v-cli-code ) no-error.
   if error-status:error or v-ok = no then return no-apply.
   if not (v-cli-type = X_clients.obj-type
           and
           v-cli-code = X_clients.obj-code) then do:
     find first X_clients no-lock where
                X_clients.obj-type = v-cli-type
            and X_clients.obj-code = v-cli-code.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  if not available X_clients then do:
    message
    substitute("Не выбран контрагент текущей системы, соответствущий контрагенту &1 внешней системы"
                ,v-ext-cli-string)
    view-as alert-box error.
    undo, return no-apply.
  end.
  assign
  p-obj-correspondence = substitute("&1=&2&3"
                                  ,v-ext-cli-string
                                  ,X_clients.obj-type
                                  ,X_clients.obj-code)
  p-ok = yes.
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
  assign
  v-ext-cli-string = entry(1, p-obj-correspondence, "=")
  v-cli-string = entry(2, p-obj-correspondence, "=")
  .
  find first X_clients no-lock where
            X_clients.obj-type = substring(v-cli-string, 1, 3)
        and X_clients.obj-code = integer(substring(v-cli-string, 4)) no-error.


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
  DISPLAY rs-obj-type f-obj-code
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_clients THEN
    DISPLAY X_clients.obj-type X_clients.obj-code X_clients.obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rs-obj-type f-obj-code X_clients.obj-type
         X_clients.obj-code B-cli
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
rs-obj-type:radio-buttons in frame {&frame-name} = {&shop} + {&comma-char} + {&shop} + {&comma-char} +
                                                   {&stock} + {&comma-char} + {&stock}
X_clients.obj-type:radio-buttons in frame {&frame-name} = {&shop} + {&comma-char} + {&shop} + {&comma-char} +
                                                   {&stock} + {&comma-char} + {&stock}
.
DISPLAY
rs-obj-type
f-obj-code
WITH FRAME {&frame-name} .
IF AVAILABLE X_clients THEN  do:
  DISPLAY
  X_clients.obj-type
  X_clients.obj-code
  X_clients.obj-name
  WITH FRAME {&frame-name} .
end.
ENABLE
B-exit
b-quit
B-Help
rs-obj-type
f-obj-code
X_clients.obj-type
X_clients.obj-code
B-cli
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME