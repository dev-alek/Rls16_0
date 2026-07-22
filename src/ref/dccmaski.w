&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-dis-card-mask FOR ub.c-dis-card-mask.
DEFINE BUFFER LOCKED_dis-card-mask FOR ub.dis-card-mask.
DEFINE BUFFER locked_dis-card-type FOR ub.dis-card-type.
DEFINE TEMP-TABLE tt-c-dis-card-mask NO-UNDO LIKE ub.c-dis-card-mask.
DEFINE TEMP-TABLE tt-dis-card-mask NO-UNDO LIKE ub.dis-card-mask.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_clients_dctype FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История маски дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/17/04
Author: Bakhtadze Natalya
Creation date: 05/17/04

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode           AS CHARACTER             no-undo .
define input parameter p-mask-num       like ub.c-dis-card-mask.mask-num no-undo .
define input parameter p-chip-num       like ub.c-dis-card-mask.chip-num no-undo .
define input parameter p-corr-user-db-num   like ub.c-dis-card-mask.corr-user-db-num no-undo .
define INPUT-OUTPUT parameter p-doc-rec AS recid no-undo .

/* Local Variable Definitions ---                                       */
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "История маски дисконтной карты":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }

DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-last-code LIKE ub.c-dis-card-mask.mask-num NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-c-dis-card-mask

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-c-dis-card-mask.use-on ~
tt-c-dis-card-mask.type tt-c-dis-card-mask.mask-num ~
tt-c-dis-card-mask.emitent-host-code tt-c-dis-card-mask.rank ~
tt-c-dis-card-mask.mask tt-c-dis-card-mask.cli-type ~
tt-c-dis-card-mask.cli-code tt-c-dis-card-mask.cli-mask
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-c-dis-card-mask.use-on tt-c-dis-card-mask.rank tt-c-dis-card-mask.mask
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-c-dis-card-mask
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-c-dis-card-mask
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-c-dis-card-mask SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-c-dis-card-mask SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-c-dis-card-mask
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-c-dis-card-mask


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-dis-card-mask.use-on ~
tt-c-dis-card-mask.rank tt-c-dis-card-mask.mask
&Scoped-define ENABLED-TABLES tt-c-dis-card-mask
&Scoped-define FIRST-ENABLED-TABLE tt-c-dis-card-mask
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RS-region RS-cli-mask ~
CB-CC-run f-emitent-name f-cli-name
&Scoped-Define DISPLAYED-FIELDS tt-c-dis-card-mask.use-on ~
tt-c-dis-card-mask.type tt-c-dis-card-mask.mask-num ~
tt-c-dis-card-mask.emitent-host-code tt-c-dis-card-mask.rank ~
tt-c-dis-card-mask.mask tt-c-dis-card-mask.cli-type ~
tt-c-dis-card-mask.cli-code tt-c-dis-card-mask.cli-mask
&Scoped-define DISPLAYED-TABLES tt-c-dis-card-mask
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-dis-card-mask
&Scoped-Define DISPLAYED-OBJECTS RS-region RS-cli-mask CB-CC-run ~
f-emitent-name f-cli-name

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

DEFINE VARIABLE CB-CC-run AS CHARACTER FORMAT "X(256)":U
     LABEL "Алгоритм КЦ"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 46.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-emitent-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 50.5 BY .67 NO-UNDO.

DEFINE VARIABLE RS-cli-mask AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Маска КОРОТКОГО №", "cli-mask",
"Определенный контрагент", "cli-code"
     SIZE 51 BY 1.27 NO-UNDO.

DEFINE VARIABLE RS-region AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", 0,
"Фирма", 1,
"Объект", 2
     SIZE 63 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-c-dis-card-mask SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     tt-c-dis-card-mask.use-on AT ROW 3.27 COL 67.5 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Использовать на кассе и в TH", 0,
"Использовать ТОЛЬКО на кассе", 1,
"Использовать ТОЛЬКО в TH", 2
          SIZE 31.5 BY 2.27
     tt-c-dis-card-mask.type AT ROW 3.77 COL 18 COLON-ALIGNED
          LABEL "Тип карты"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-c-dis-card-mask.mask-num AT ROW 3.77 COL 47.5 COLON-ALIGNED
          LABEL "Номер маски"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-c-dis-card-mask.emitent-host-code AT ROW 5 COL 18 COLON-ALIGNED
          LABEL "Эмитент карты"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     RS-region AT ROW 6.5 COL 20.5 NO-LABEL
     tt-c-dis-card-mask.rank AT ROW 8.5 COL 79 COLON-ALIGNED
          LABEL "Ранг(приоритет при поиске)"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-c-dis-card-mask.mask AT ROW 8.77 COL 14.5 COLON-ALIGNED
          LABEL "Маска карты"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     RS-cli-mask AT ROW 10.27 COL 43.5 NO-LABEL
     tt-c-dis-card-mask.cli-type AT ROW 12.27 COL 16.5 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 14 BY 1
     tt-c-dis-card-mask.cli-code AT ROW 12.27 COL 29.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-c-dis-card-mask.cli-mask AT ROW 14.27 COL 19 COLON-ALIGNED
          LABEL "Маска КОРОТКОГО №"
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     CB-CC-run AT ROW 14.27 COL 67 COLON-ALIGNED
     f-emitent-name AT ROW 5.27 COL 37 COLON-ALIGNED NO-LABEL
     f-cli-name AT ROW 12.5 COL 50.5 COLON-ALIGNED NO-LABEL
     "Контрагент" VIEW-AS TEXT
          SIZE 13.5 BY 1.27 AT ROW 12 COL 2
     "Метод поиска контрагента по маске карты" VIEW-AS TEXT
          SIZE 39.5 BY 1.27 AT ROW 10.27 COL 2.5
     "Область действия" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 6.5 COL 2.5
     SPACE(79.24) SKIP(8.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История маски дисконтной карты"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-dis-card-mask B "?" ? ub c-dis-card-mask
      TABLE: LOCKED_dis-card-mask B "?" ? ub dis-card-mask
      TABLE: locked_dis-card-type B "?" ? ub dis-card-type
      TABLE: tt-c-dis-card-mask T "?" NO-UNDO ub c-dis-card-mask
      TABLE: tt-dis-card-mask T "?" NO-UNDO ub dis-card-mask
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_clients_dctype B "?" ? ub clients
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
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

/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.cli-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.cli-mask IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR RADIO-SET tt-c-dis-card-mask.cli-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.emitent-host-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.mask IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.mask-num IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.rank IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-dis-card-mask.type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-c-dis-card-mask"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История маски дисконтной карты */
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
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
for each tt-c-dis-card-mask:
  delete tt-c-dis-card-mask.
end.
  if p-mode = {&lookup} then do:
    find first locked_c-dis-card-mask no-lock where
                      recid(locked_c-dis-card-mask) = p-doc-rec no-error .
    if not avail locked_c-dis-card-mask then do:
      find first locked_c-dis-card-mask no-lock where
                  locked_c-dis-card-mask.mask-num = p-mask-num
              AND locked_c-dis-card-mask.corr-user-db-num = p-corr-user-db-num
              AND locked_c-dis-card-mask.chip-num = p-chip-num
              no-error .
    end.
    if not available locked_c-dis-card-mask then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ИСТОРИИ МАСКИ ДИСКОНТНОЙ КАРТЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-c-dis-card-mask.
    buffer-copy locked_c-dis-card-mask to tt-c-dis-card-mask.
    if LOCKED_c-dis-card-mask.cc-run > 0 then
    cb-cc-run = string(LOCKED_c-dis-card-mask.cc-run).
    else
    cb-cc-run = '':U
    .
   end.
   IF p-mode = {&lookup} THEN DO:
       FIND FIRST locked_dis-card-type  no-lock WHERE
                  locked_dis-card-type.emitent-host-code = locked_c-dis-card-mask.emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = LOCKED_c-dis-card-mask.TYPE NO-ERROR.

  END.
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = locked_c-dis-card-mask.obj-type
       AND X_curr_clients.obj-code = locked_c-dis-card-mask.obj-code no-error.
  find first X_sysconf no-lock where
            X_sysconf.host-code = locked_c-dis-card-mask.host-code no-error.
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
  DISPLAY RS-region RS-cli-mask CB-CC-run f-emitent-name f-cli-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-dis-card-mask THEN
    DISPLAY tt-c-dis-card-mask.use-on tt-c-dis-card-mask.type
          tt-c-dis-card-mask.mask-num tt-c-dis-card-mask.emitent-host-code
          tt-c-dis-card-mask.rank tt-c-dis-card-mask.mask
          tt-c-dis-card-mask.cli-type tt-c-dis-card-mask.cli-code
          tt-c-dis-card-mask.cli-mask
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-c-dis-card-mask.use-on RS-region
         tt-c-dis-card-mask.rank tt-c-dis-card-mask.mask RS-cli-mask CB-CC-run
         f-emitent-name f-cli-name
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
IF tt-c-dis-card-mask.cli-code <> 0 THEN DO:
    FIND FIRST X_clients  NO-LOCK WHERE
              X_clients.obj-type = tt-c-dis-card-mask.cli-type
        AND    X_clients.obj-code = tt-c-dis-card-mask.cli-code.

END.
IF tt-c-dis-card-mask.emitent-host-code <> 0 THEN DO:
  FIND FIRST X_clients_dctype  NO-LOCK WHERE
                  X_clients_dctype.obj-type = {&cmp}
            AND    X_clients_dctype.obj-code = tt-c-dis-card-mask.emitent-host-code.

END.

ASSIGN
v-tab-order = "b-exit,b-quit,b-help"
tt-c-dis-card-mask.cli-type:RADIO-BUTTONS IN FRAME {&frame-name} = "Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                                                                   "Чел" + {&comma-char} + {&prs}
RS-cli-mask = IF tt-c-dis-card-mask.cli-code > 0 THEN "cli-code":U ELSE "cli-mask":U
Rs-region:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
"Глобально" + {&comma-char} + "0":U + {&comma-char} +
("Фирма" + {&space-char} + STRING(tt-c-dis-card-mask.host-code)) + {&comma-char} + "1":U + {&comma-char} +
("Объект" + {&space-char} + tt-c-dis-card-mask.obj-type + STRING(tt-c-dis-card-mask.obj-code)) + {&comma-char} + "2":U
Rs-region = IF tt-c-dis-card-mask.host-code = 0
            THEN 0
            ELSE ( IF tt-c-dis-card-mask.obj-code = 0
                   THEN 1
                   ELSE 2
                  )
f-emitent-name = IF p-mode = {&add-def}
                 THEN "":U
                ELSE (IF tt-c-dis-card-mask.emitent-host-code = 0
                      THEN "Глобально"
                      ELSE X_clients_dctype.obj-name

                    )
cb-cc-run:LIST-ITEM-PAIRS  in frame {&frame-name} =  "Не используется" + {&comma-char} + {&dcm-cc-algo-no} + {&comma-char} +
                                                      "Методу Luhna" + {&comma-char} + {&dcm-cc-algo-luhn}.


if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  .
  hide
  b-exit in frame {&frame-name}.
end.
DISPLAY
b-quit
b-help
RS-region
RS-cli-mask
f-emitent-name
f-cli-name
WITH FRAME {&frame-name} .
Enable
b-quit
b-help
with frame {&frame-name} .
IF AVAILABLE tt-c-dis-card-mask THEN
DISPLAY
tt-c-dis-card-mask.type
tt-c-dis-card-mask.emitent-host-code
tt-c-dis-card-mask.mask-num
tt-c-dis-card-mask.rank
tt-c-dis-card-mask.mask
tt-c-dis-card-mask.cli-type
tt-c-dis-card-mask.cli-code
tt-c-dis-card-mask.cli-mask
tt-c-dis-card-mask.use-on
cb-cc-run
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME