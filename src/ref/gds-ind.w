&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR goods.
DEFINE TEMP-TABLE tt-gds-obj-prop NO-UNDO LIKE gds-obj-prop.
DEFINE TEMP-TABLE tt0-gds-obj-prop NO-UNDO LIKE gds-obj-prop.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования индикаторов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/28/05
*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-host-code like ub.clients.obj-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
DEFINE INPUT-OUTPUT PARAMETER TABLE  FOR tt0-gds-obj-prop.
/*
message
 "p-mode            "  p-mode
skip "p-gds-code        "  p-gds-code
skip  "p-host-code       "  p-host-code
skip  "p-obj-type        "  p-obj-type
skip  "p-obj-code        "  p-obj-code
skip  "p-update-instantly"  p-update-instantly
skip
.
for each tt0-gds-obj-prop:
message tt0-gds-obj-prop.gds-code skip
        tt0-gds-obj-prop.obj-code
        tt0-gds-obj-prop.obj-type.
end.
*/
/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования индикаторов ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ ref/gds-ind1.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-obj-prop buf_goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-gds-obj-prop.gdop-igt ~
tt-gds-obj-prop.gdop-assort-min tt-gds-obj-prop.grop-date-update ~
tt-gds-obj-prop.grop-who-update tt-gds-obj-prop.grop-db-num-update
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update ~
tt-gds-obj-prop.grop-db-num-update
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-gds-obj-prop
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-gds-obj-prop
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-gds-obj-prop NO-LOCK, ~
      EACH buf_goods OF tt-gds-obj-prop NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-gds-obj-prop NO-LOCK, ~
      EACH buf_goods OF tt-gds-obj-prop NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-gds-obj-prop buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-gds-obj-prop
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS buf_goods.artic buf_goods.prod-type ~
buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name ~
tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update ~
tt-gds-obj-prop.grop-db-num-update
&Scoped-define ENABLED-TABLES buf_goods tt-gds-obj-prop
&Scoped-define FIRST-ENABLED-TABLE buf_goods
&Scoped-define SECOND-ENABLED-TABLE tt-gds-obj-prop
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help FILL-IN-5 FILL-IN-4 ~
F-time
&Scoped-Define DISPLAYED-FIELDS tt-gds-obj-prop.gdop-igt ~
tt-gds-obj-prop.gdop-assort-min buf_goods.artic buf_goods.prod-type ~
buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name ~
tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update ~
tt-gds-obj-prop.grop-db-num-update
&Scoped-define DISPLAYED-TABLES tt-gds-obj-prop buf_goods
&Scoped-define FIRST-DISPLAYED-TABLE tt-gds-obj-prop
&Scoped-define SECOND-DISPLAYED-TABLE buf_goods
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-5 FILL-IN-4 F-time

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

DEFINE VARIABLE F-time AS CHARACTER FORMAT "X(5)":U
     LABEL "Время изменения"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Принадлежность к ассортиментному минимуму(AMin):"
      VIEW-AS TEXT
     SIZE 48.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Индикатор жизнедеятельности товара (ИЖТ):"
      VIEW-AS TEXT
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-gds-obj-prop,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 78.5
     B-Help AT ROW 1 COL 88.5
     tt-gds-obj-prop.gdop-igt AT ROW 5.25 COL 51 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Новинка", "1":U,
"На вывод из ассортимента", "2":U,
"Пусто", "3":U,
"Item 4", "4":U
          SIZE 27.5 BY 3
     tt-gds-obj-prop.gdop-assort-min AT ROW 9 COL 51 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Да", yes,
"Нет", no
          SIZE 11.5 BY 1
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
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-name AT ROW 3.75 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 71.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     FILL-IN-5 AT ROW 5.25 COL 8.5 NO-LABEL
     FILL-IN-4 AT ROW 9 COL 2 NO-LABEL
     tt-gds-obj-prop.grop-date-update AT ROW 11.25 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 9 BY .67
     F-time AT ROW 12.25 COL 75.5 COLON-ALIGNED
     tt-gds-obj-prop.grop-who-update AT ROW 13.25 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 19.5 BY .67
     tt-gds-obj-prop.grop-db-num-update AT ROW 14.25 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 5 BY .67
     SPACE(16.00) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Индикаторы товара на объекте".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: tt-gds-obj-prop T "?" NO-UNDO ub gds-obj-prop
      TABLE: tt0-gds-obj-prop T "?" NO-UNDO ub gds-obj-prop
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

/* SETTINGS FOR BUTTON B-Hist IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR RADIO-SET tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-gds-obj-prop,buf_goods OF Temp-Tables.tt-gds-obj-prop"
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Индикаторы товара на объекте */
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
define variable pp-rid-list as character no-undo .

 run ref/cgds-ind.w (
  input  parparentproc ,
  input  tt-gds-obj-prop.gds-code ,
  input  tt-gds-obj-prop.obj-type ,
  input  tt-gds-obj-prop.obj-code ,
  input-output pp-rid-list    ).

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

   FRAME {&FRAME-NAME}:title = FRAME {&FRAME-NAME}:title + " " + p-obj-type + " " + string( p-obj-code ) .

  run init-proc no-error .
  if error-status :error then return error return-value .
  define variable v-user-name as character no-undo .
  run enable_ui.
  if available tt-gds-obj-prop then do:
  { gbl/usrfulnm.i
    tt-gds-obj-prop.grop-who-update
    v-user-name }
  end.


  display v-user-name @ tt-gds-obj-prop.grop-who-update with frame {&frame-name} .

  if p-mode = {&lookup} then do:
      assign
        b-quit:label = "&Выход"
        b-quit:col = 1
      .
      hide b-exit in frame {&frame-name}.
  end.
  else do:
 /* Проверка прав */
 define variable v-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-izt_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .

  end.
find first tt-gds-obj-prop no-error .
DISPLAY string(tt-gds-obj-prop.grop-time-update,"hh:mm") @ f-time WITH FRAME {&frame-name} no-error .
if error-status :error then message error-status :get-message(1) .

enable
  b-exit when p-mode <> {&lookup}
  b-quit
  b-hist when p-mode = {&lookup}
  b-help
  tt-gds-obj-prop.gdop-assort-min  when p-mode <> {&lookup}
  tt-gds-obj-prop.gdop-igt         when p-mode <> {&lookup}
with frame dialog-frame.

view frame dialog-frame.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-gds-obj-prop.gdop-igt.
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
  DISPLAY FILL-IN-5 FILL-IN-4 F-time
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.prod-type buf_goods.prod-code
          buf_goods.gds-code buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-obj-prop THEN
    DISPLAY tt-gds-obj-prop.gdop-igt tt-gds-obj-prop.gdop-assort-min
          tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update
          tt-gds-obj-prop.grop-db-num-update
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help buf_goods.artic buf_goods.prod-type
         buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name FILL-IN-5
         FILL-IN-4 tt-gds-obj-prop.grop-date-update F-time
         tt-gds-obj-prop.grop-who-update tt-gds-obj-prop.grop-db-num-update
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
   find first tt0-gds-obj-prop no-lock where
              tt0-gds-obj-prop.gds-code =  p-gds-code and
              tt0-gds-obj-prop.obj-type =  p-obj-type and
              tt0-gds-obj-prop.obj-code =  p-obj-code no-error .
else
   find first tt0-gds-obj-prop exclusive-lock  where
              tt0-gds-obj-prop.gds-code =  p-gds-code and
              tt0-gds-obj-prop.obj-type =  p-obj-type and
              tt0-gds-obj-prop.obj-code =  p-obj-code no-error .

 for each tt-gds-obj-prop : delete tt-gds-obj-prop. end.

  CREATE tt-gds-obj-prop.
  if available tt0-gds-obj-prop then
     BUFFER-COPY tt0-gds-obj-prop TO tt-gds-obj-prop .
  else do:
    if p-gds-code = 0 then p-gds-code = 1.
    run cur-time in this-procedure(output v-date, output v-time).
    assign
      tt-gds-obj-prop.gdop-assort-min    = no
      tt-gds-obj-prop.gdop-igt           = {&ass-izd-empty}
      tt-gds-obj-prop.gds-code           = p-gds-code
      tt-gds-obj-prop.grop-date-update   = v-date
      tt-gds-obj-prop.grop-time-update   = v-time
      tt-gds-obj-prop.grop-db-num-update = g#db-num
      tt-gds-obj-prop.grop-who-update    = g#userid
      tt-gds-obj-prop.obj-code           = p-obj-code
      tt-gds-obj-prop.obj-type           = p-obj-type
    .
  end.

if tt-gds-obj-prop.gdop-igt  = '' or tt-gds-obj-prop.gdop-igt  = ? then do:
   tt-gds-obj-prop.gdop-igt  = {&ass-izd-empty} .
end.
  tt-gds-obj-prop.gdop-igt:radio-buttons IN FRAME {&FRAME-NAME} =
    {&ass-izd-new}    + {&comma-char} +  {&ass-izd-new}  + {&comma-char} +
    {&ass-izd-com}    + {&comma-char} +  {&ass-izd-com}  + {&comma-char} +
    {&ass-izd-spec}   + {&comma-char} +  {&ass-izd-spec} + {&comma-char} +
    {&ass-izd-del}    + {&comma-char} +  {&ass-izd-del}  + {&comma-char} +
    {&ass-izd-empty}  + {&comma-char} +  {&ass-izd-empty} .


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
assign frame {&frame-name}  tt-gds-obj-prop.gdop-assort-min   no-error .
if error-status :error then message error-status :get-message(1)  "gdop-assort-min" .
assign frame {&frame-name}  tt-gds-obj-prop.gdop-igt  no-error .
if error-status :error then message  error-status :get-message(1) "gdop-igt " .

define variable p-recid as recid no-undo.
define variable v-ident as logical no-undo .
if p-update-instantly then do:

    run gds-ind1
        (input-output p-recid
        ,tt-gds-obj-prop.gds-code
        ,tt-gds-obj-prop.obj-type
        ,tt-gds-obj-prop.obj-code
        ,tt-gds-obj-prop.gdop-igt
        ,tt-gds-obj-prop.gdop-assort-min
        ,tt-gds-obj-prop.gdop-min-stock
        ,tt-gds-obj-prop.grop-level-always-presence
        ,tt-gds-obj-prop.grop-max-stock
        ,tt-gds-obj-prop.grop-min-order
        ) no-error .
    if error-status :error then  do:
    message error-status :get-message(1) return-value .
    return error return-value .
    end.
END.
ELSE DO:
   if not available tt0-gds-obj-prop then
   create tt0-gds-obj-prop.
    if p-mode = {&add-def} then do:
      p-updated = yes.
    end.
    else do:
      if available tt0-gds-obj-prop then do:
        buffer-compare tt0-gds-obj-prop
        to
        tt-gds-obj-prop save result in v-ident.
        assign
        p-updated = not v-ident.
      end.
      else do:
        if available tt-gds-obj-prop then p-updated = yes.
      end.
    end.
   buffer-copy tt-gds-obj-prop
   except gds-code
   to tt0-gds-obj-prop
   .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME