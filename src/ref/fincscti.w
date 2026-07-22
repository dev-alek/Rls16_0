&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-schet FOR ub.c-fin-schet.
DEFINE TEMP-TABLE tt-c-fin-schet NO-UNDO LIKE ub.c-fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_schet-clients FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка просмотра истории банковского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/03
Author: Bakhtadze Natalya
Creation date: 10/24/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/

define input parameter p-host-code like ub.c-fin-schet.host-code no-undo.
define input parameter p-code-schet like ub.c-fin-schet.code-schet no-undo.
define input parameter p-corr-user-db-num  like ub.c-fin-schet.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-fin-schet.chip-num no-undo .

define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка истории банковского счета".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-c-fin-schet X_schet-clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-c-fin-schet.host-code ~
tt-c-fin-schet.code-schet tt-c-fin-schet.cli-code tt-c-fin-schet.cli-type ~
tt-c-fin-schet.code-bank tt-c-fin-schet.c-schet tt-c-fin-schet.curr-code ~
tt-c-fin-schet.r-schet tt-c-fin-schet.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-c-fin-schet.cli-code ~
tt-c-fin-schet.cli-type tt-c-fin-schet.code-bank tt-c-fin-schet.c-schet ~
tt-c-fin-schet.curr-code tt-c-fin-schet.r-schet tt-c-fin-schet.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-c-fin-schet
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-c-fin-schet
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-c-fin-schet SHARE-LOCK, ~
      EACH X_schet-clients WHERE TRUE /* Join to tt-c-fin-schet incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-c-fin-schet SHARE-LOCK, ~
      EACH X_schet-clients WHERE TRUE /* Join to tt-c-fin-schet incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-c-fin-schet X_schet-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-c-fin-schet
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame X_schet-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-fin-schet.cli-code ~
tt-c-fin-schet.cli-type tt-c-fin-schet.code-bank tt-c-fin-schet.c-schet ~
tt-c-fin-schet.curr-code tt-c-fin-schet.r-schet tt-c-fin-schet.PS
&Scoped-define ENABLED-TABLES tt-c-fin-schet
&Scoped-define FIRST-ENABLED-TABLE tt-c-fin-schet
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-cli-name F-otdel ~
f-curr-abbr
&Scoped-Define DISPLAYED-FIELDS tt-c-fin-schet.host-code ~
tt-c-fin-schet.code-schet tt-c-fin-schet.cli-code tt-c-fin-schet.cli-type ~
tt-c-fin-schet.code-bank tt-c-fin-schet.c-schet tt-c-fin-schet.curr-code ~
tt-c-fin-schet.r-schet tt-c-fin-schet.PS
&Scoped-define DISPLAYED-TABLES tt-c-fin-schet
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-fin-schet
&Scoped-Define DISPLAYED-OBJECTS f-host-name f-cli-name f-bank-name F-otdel ~
f-bik f-curr-abbr

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

DEFINE VARIABLE f-bank-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 68 BY 1 NO-UNDO.

DEFINE VARIABLE f-bik AS CHARACTER FORMAT "X(22)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 14.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE F-otdel AS CHARACTER FORMAT "X(256)":U
     LABEL "Отделение"
     VIEW-AS FILL-IN
     SIZE 68 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-c-fin-schet,
      X_schet-clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 71
     tt-c-fin-schet.host-code AT ROW 2.5 COL 13 COLON-ALIGNED
          LABEL "Фирма"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     f-host-name AT ROW 2.5 COL 23.5 COLON-ALIGNED NO-LABEL
     tt-c-fin-schet.code-schet AT ROW 2.5 COL 78.5 COLON-ALIGNED
          LABEL "Код счета"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     tt-c-fin-schet.cli-code AT ROW 4.04 COL 18 COLON-ALIGNED
          LABEL "Держатель счета" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-schet.cli-type AT ROW 4.04 COL 30.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     f-cli-name AT ROW 4.04 COL 42.13 COLON-ALIGNED NO-LABEL
     tt-c-fin-schet.code-bank AT ROW 6.08 COL 13 COLON-ALIGNED
          LABEL "Код банка"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     f-bank-name AT ROW 6.08 COL 28 COLON-ALIGNED NO-LABEL
     F-otdel AT ROW 7.25 COL 28 COLON-ALIGNED
     f-bik AT ROW 8.33 COL 28 COLON-ALIGNED
     tt-c-fin-schet.c-schet AT ROW 9.54 COL 13 COLON-ALIGNED
          LABEL "Корр.счет"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-schet.curr-code AT ROW 9.54 COL 53.13 COLON-ALIGNED
          LABEL "Код валюты"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     f-curr-abbr AT ROW 9.54 COL 62.75 COLON-ALIGNED NO-LABEL
     tt-c-fin-schet.r-schet AT ROW 10.79 COL 13 COLON-ALIGNED
          LABEL "Расч. счет"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-schet.PS AT ROW 12.13 COL 13 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 63.5 BY 4
     "Примечания" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 12.25 COL 1.5
     SPACE(86.86) SKIP(3.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Банковский счет"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-schet B "?" ? ub c-fin-schet
      TABLE: tt-c-fin-schet T "?" NO-UNDO ub c-fin-schet
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_currency B "?" ? ub currency
      TABLE: X_fin-bank B "?" ? ub fin-bank
      TABLE: X_schet-clients B "?" NO-UNDO ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
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

/* SETTINGS FOR FILL-IN tt-c-fin-schet.c-schet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.cli-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.cli-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.code-bank IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.code-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.curr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-bank-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-bik IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-host-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.host-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-schet.r-schet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-c-fin-schet,Temp-Tables.X_schet-clients WHERE Temp-Tables.tt-c-fin-schet ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Банковский счет */
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
 if p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
  for each tt-c-fin-schet:
        delete tt-c-fin-schet.
    end.
  find first locked_c-fin-schet no-lock where
                    recid(locked_c-fin-schet) = p-doc-rec.

  if not available locked_c-fin-schet then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена запись БАНК"
    view-as alert-box error .
    undo, return error.
  end.
  create tt-c-fin-schet.
  buffer-copy locked_c-fin-schet to tt-c-fin-schet.
  RUN MYEnable.
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
  DISPLAY f-host-name f-cli-name f-bank-name F-otdel f-bik f-curr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-fin-schet THEN
    DISPLAY tt-c-fin-schet.host-code tt-c-fin-schet.code-schet
          tt-c-fin-schet.cli-code tt-c-fin-schet.cli-type
          tt-c-fin-schet.code-bank tt-c-fin-schet.c-schet
          tt-c-fin-schet.curr-code tt-c-fin-schet.r-schet tt-c-fin-schet.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-c-fin-schet.cli-code tt-c-fin-schet.cli-type
         f-cli-name tt-c-fin-schet.code-bank F-otdel tt-c-fin-schet.c-schet
         tt-c-fin-schet.curr-code f-curr-abbr tt-c-fin-schet.r-schet
         tt-c-fin-schet.PS
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
find first X_clients no-lock where
            X_clients.obj-type = {&cmp}
        AND X_clients.obj-code = p-host-code.
  find first X_schet-clients no-lock where
              X_schet-clients.obj-type = tt-c-fin-schet.cli-type
          AND X_schet-clients.obj-code = tt-c-fin-schet.cli-code.
  find first X_fin-bank no-lock where
              X_fin-bank.host-code = tt-c-fin-schet.host-code
          AND X_fin-bank.code-bank = tt-c-fin-schet.code-bank.
  find first X_currency no-lock where
              X_currency.curr-code = tt-c-fin-schet.curr-code.

  DISPLAY
  X_clients.obj-name @  f-host-name
   WITH FRAME Dialog-Frame.

  DISPLAY
  tt-c-fin-schet.host-code
  tt-c-fin-schet.code-schet
  tt-c-fin-schet.cli-type
  tt-c-fin-schet.cli-code
  X_schet-clients.obj-name @ f-cli-name
  X_fin-bank.bank-name @ f-bank-name
  X_fin-bank.otdel @ f-otdel
  X_fin-bank.bik @ f-bik
  X_currency.curr-abbr @ f-curr-abbr
  tt-c-fin-schet.curr-code
  tt-c-fin-schet.c-schet
  tt-c-fin-schet.r-schet
  tt-c-fin-schet.PS
  WITH FRAME {&frame-name} .


if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame {&frame-name}.
end.
ENABLE
b-quit
B-Help
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME