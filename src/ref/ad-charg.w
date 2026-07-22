&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE TEMP-TABLE tt-gds-add-charges NO-UNDO LIKE ub.gds-add-charges.
DEFINE TEMP-TABLE tt0-gds-add-charges NO-UNDO LIKE ub.gds-add-charges.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования Дополнительных расходов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/28/05
*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode             as character no-undo.
define input parameter p-gds-code         as integer no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
DEFINE INPUT-OUTPUT PARAMETER TABLE  FOR tt0-gds-add-charges.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования Дополнительных расходов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-add-charges buf_goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-gds-add-charges NO-LOCK, ~
             EACH buf_goods          OF tt-gds-add-charges NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-add-charges NO-LOCK, ~
             EACH buf_goods          OF tt-gds-add-charges NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-gds-add-charges buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-gds-add-charges
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-gds-add-charges.cost-include ~
tt-gds-add-charges.algoritm buf_goods.artic buf_goods.prod-type ~
buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name
&Scoped-define ENABLED-TABLES tt-gds-add-charges buf_goods
&Scoped-define FIRST-ENABLED-TABLE tt-gds-add-charges
&Scoped-define SECOND-ENABLED-TABLE buf_goods
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help FILL-IN-8
&Scoped-Define DISPLAYED-FIELDS tt-gds-add-charges.cost-include ~
tt-gds-add-charges.algoritm buf_goods.artic buf_goods.prod-type ~
buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name
&Scoped-define DISPLAYED-TABLES tt-gds-add-charges buf_goods
&Scoped-define FIRST-DISPLAYED-TABLE tt-gds-add-charges
&Scoped-define SECOND-DISPLAYED-TABLE buf_goods
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-8

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

DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Алгоритм включения в учетную цену"
      VIEW-AS TEXT
     SIZE 49 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-gds-add-charges,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 88.5
     tt-gds-add-charges.cost-include AT ROW 6.25 COL 8 WIDGET-ID 6
          VIEW-AS TOGGLE-BOX
          SIZE 32.5 BY .83
     tt-gds-add-charges.algoritm AT ROW 8 COL 26.5 COLON-ALIGNED WIDGET-ID 8
          LABEL "Пропорционально"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "сумме приходных цен","1",
                     "количеству(в баз. ед.изм.)","2",
                     "количеству(в пост. ед.изм.)","3",
                     "весу","4"
          DROP-DOWN
          SIZE 32.63 BY 1 TOOLTIP "Как включать дополнительные расходы в учетную цену"
     buf_goods.artic AT ROW 2 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 17 BY .67
     buf_goods.prod-type AT ROW 2 COL 41.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     buf_goods.prod-code AT ROW 2 COL 46 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-code AT ROW 2.75 COL 24 COLON-ALIGNED
          LABEL "Код услуги"
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-name AT ROW 3.75 COL 24 COLON-ALIGNED
          LABEL "Название доп.расхода"
           VIEW-AS TEXT
          SIZE 71.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     FILL-IN-8 AT ROW 7.25 COL 9.75 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     SPACE(37.75) SKIP(2.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительные расходы".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: tt-gds-add-charges T "?" NO-UNDO ub gds-add-charges
      TABLE: tt0-gds-add-charges T "?" NO-UNDO ub gds-add-charges
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

/* SETTINGS FOR COMBO-BOX tt-gds-add-charges.algoritm IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN buf_goods.gds-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN buf_goods.gds-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-add-charges NO-LOCK,
      EACH buf_goods          OF tt-gds-add-charges NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дополнительные расходы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-add-charges.algoritm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-add-charges.algoritm Dialog-Frame
ON VALUE-CHANGED OF tt-gds-add-charges.algoritm IN FRAME Dialog-Frame /* Пропорционально */
DO:
  ASSIGN tt-gds-add-charges.algoritm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-gds-add-charges.cost-include
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-add-charges.cost-include Dialog-Frame
ON VALUE-CHANGED OF tt-gds-add-charges.cost-include IN FRAME Dialog-Frame /* Включается в учетную цену */
DO:
  ASSIGN tt-gds-add-charges.cost-include.
  IF tt-gds-add-charges.cost-include = TRUE THEN DO:
      ENABLE tt-gds-add-charges.algoritm WITH FRAME {&FRAME-NAME}.
      DISPLAY FILL-IN-8 tt-gds-add-charges.algoritm WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    HIDE FILL-IN-8 tt-gds-add-charges.algoritm IN FRAME {&FRAME-NAME}.
  END.


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
  run init-proc no-error .
  if error-status :error then return error return-value .
  define variable v-user-name as character no-undo .
  run enable_ui.

  if p-mode = {&lookup} then do:
      assign
        b-quit:label = "&Выход"
        b-quit:col = 1
      .
      disable
          tt-gds-add-charges.algoritm
          tt-gds-add-charges.cost-include  with frame {&frame-name}.
      hide b-exit in frame {&frame-name}.
  end.
find first tt-gds-add-charges no-error .
if error-status :error then message error-status :get-message(1) .

enable
  b-exit when p-mode <> {&lookup}
  b-quit
  b-help
  tt-gds-add-charges.algoritm  when p-mode <> {&lookup}
  tt-gds-add-charges.cost-include         when p-mode <> {&lookup}
 with frame dialog-frame.
view frame dialog-frame.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-gds-add-charges.cost-include.
END.
run disable_ui.

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
  DISPLAY FILL-IN-8
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.prod-type buf_goods.prod-code
          buf_goods.gds-code buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-add-charges THEN
    DISPLAY tt-gds-add-charges.cost-include tt-gds-add-charges.algoritm
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-gds-add-charges.cost-include
         tt-gds-add-charges.algoritm buf_goods.artic buf_goods.prod-type
         buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name FILL-IN-8
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

if p-mode = {&lookup} then
   find first tt0-gds-add-charges no-lock where
              tt0-gds-add-charges.gds-code =  p-gds-code
              no-error .
else
   find first tt0-gds-add-charges exclusive-lock  where
              tt0-gds-add-charges.gds-code =  p-gds-code
              no-error .
  if p-gds-code = 0 then do:
    if not available tt0-gds-add-charges then do:
       create tt0-gds-add-charges .
    end.
  end.
 for each tt-gds-add-charges : delete tt-gds-add-charges. end.

  CREATE tt-gds-add-charges.
  if available tt0-gds-add-charges then
     BUFFER-COPY tt0-gds-add-charges TO tt-gds-add-charges .
  else do:
    if p-mode = {&lookup} then do:
        if p-gds-code = 0 then p-gds-code = 1.
        run cur-time in this-procedure(output v-date, output v-time).
        assign
          tt-gds-add-charges.algoritm           = ""
          tt-gds-add-charges.cost-include       = false
          tt-gds-add-charges.gds-code           = p-gds-code
        .
    end.
    else do:
    message "Значений нет в БД , будут установлены по умолчанию" view-as alert-box information .
    if p-gds-code = 0 then p-gds-code = 1.
    run cur-time in this-procedure(output v-date, output v-time).
    assign
      tt-gds-add-charges.algoritm           = "1"
      tt-gds-add-charges.cost-include       = true
      tt-gds-add-charges.gds-code           = p-gds-code
    .
    end.
  end.
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
define variable p-recid as recid no-undo.
define variable v-ident as logical no-undo .
if p-update-instantly then do:
    assign frame {&frame-name}
    tt-gds-add-charges.algoritm
    tt-gds-add-charges.cost-include.
    run ref/adcharg1.p
        (input-output p-recid
        ,input tt-gds-add-charges.gds-code
        ,input tt-gds-add-charges.algoritm
        ,input tt-gds-add-charges.cost-include
        ) no-error .
    if error-status :error then  do:
        message error-status :get-message(1) return-value .
        return error return-value .
    end.
END.
ELSE DO:
   if not available tt0-gds-add-charges then
   create tt0-gds-add-charges.
    if p-mode = {&add-def} then do:
      p-updated = yes.
    end.
    else do:
      if available tt0-gds-add-charges then do:
        buffer-compare tt0-gds-add-charges
        to
        tt-gds-add-charges save result in v-ident.
        assign
        p-updated = not v-ident.
      end.
      else do:
        if available tt-gds-add-charges then p-updated = yes.
      end.
    end.
   buffer-copy tt-gds-add-charges
   except gds-code
   to tt0-gds-add-charges
   .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME