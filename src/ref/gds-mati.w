&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_assortment-matrix-goods FOR ub.assortment-matrix-goods.
DEFINE TEMP-TABLE tt-assortment-matrix-goods NO-UNDO LIKE ub.assortment-matrix-goods
       field artic as char
       field prod-code as int
       field prod-type as char
       field gds-name as char.
DEFINE BUFFER X_curr_clients FOR ub.clients.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования ассортиментной матрицы

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/23/05
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode         as character no-undo. /*может быть {&add-def} {&update} {&lookup}*/
define input parameter p-asmt-id      like ub.assortment-matrix.asmt-id no-undo.
define input parameter p-db-num       like ub.assortment-matrix.db-num no-undo.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования товаров ассортиментной матрицы ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ ref/gds-matl.i }

define buffer buf_assortment-matrix for ub.assortment-matrix  .
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.assortment-matrix-goods.asmt-id no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,asmt-id,asmt-name,asmt-des," +  ~
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
&Scoped-define INTERNAL-TABLES tt-assortment-matrix-goods ub.goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ~
tt-assortment-matrix-goods.asmg-des tt-assortment-matrix-goods.asmt-id ~
tt-assortment-matrix-goods.gds-code tt-assortment-matrix-goods.artic ~
tt-assortment-matrix-goods.prod-type tt-assortment-matrix-goods.prod-code ~
tt-assortment-matrix-goods.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-assortment-matrix-goods.asmg-des tt-assortment-matrix-goods.asmt-id ~
tt-assortment-matrix-goods.gds-code tt-assortment-matrix-goods.artic ~
tt-assortment-matrix-goods.prod-type tt-assortment-matrix-goods.prod-code ~
tt-assortment-matrix-goods.gds-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ~
tt-assortment-matrix-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-assortment-matrix-goods
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-assortment-matrix-goods SHARE-LOCK, ~
      EACH ub.goods WHERE TRUE /* Join to tt-assortment-matrix-goods incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-assortment-matrix-goods SHARE-LOCK, ~
      EACH ub.goods WHERE TRUE /* Join to tt-assortment-matrix-goods incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-assortment-matrix-goods ~
ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-assortment-matrix-goods
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-assortment-matrix-goods.asmg-des ~
tt-assortment-matrix-goods.asmt-id tt-assortment-matrix-goods.gds-code ~
tt-assortment-matrix-goods.artic tt-assortment-matrix-goods.prod-type ~
tt-assortment-matrix-goods.prod-code tt-assortment-matrix-goods.gds-name
&Scoped-define ENABLED-TABLES tt-assortment-matrix-goods
&Scoped-define FIRST-ENABLED-TABLE tt-assortment-matrix-goods
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help
&Scoped-Define DISPLAYED-FIELDS tt-assortment-matrix-goods.asmg-des ~
tt-assortment-matrix-goods.asmt-id tt-assortment-matrix-goods.gds-code ~
tt-assortment-matrix-goods.artic tt-assortment-matrix-goods.prod-type ~
tt-assortment-matrix-goods.prod-code tt-assortment-matrix-goods.gds-name
&Scoped-define DISPLAYED-TABLES tt-assortment-matrix-goods
&Scoped-define FIRST-DISPLAYED-TABLE tt-assortment-matrix-goods


/* Custom List Definitions                                              */
/* List-obj,List-2,List-3,List-4,List-5,List-6                          */

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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-assortment-matrix-goods,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     tt-assortment-matrix-goods.asmg-des AT ROW 7.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 6.5
     tt-assortment-matrix-goods.asmt-id AT ROW 2 COL 34 COLON-ALIGNED
          LABEL "Внутр.код ассортиментной матрицы"
           VIEW-AS TEXT
          SIZE 11 BY .67
     tt-assortment-matrix-goods.gds-code AT ROW 3 COL 34 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 14 BY .67
     tt-assortment-matrix-goods.artic AT ROW 4 COL 34 COLON-ALIGNED
          LABEL "Артикул" FORMAT "x(16)"
           VIEW-AS TEXT
          SIZE 17 BY .67
          FGCOLOR 4
     tt-assortment-matrix-goods.prod-type AT ROW 4 COL 51.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-assortment-matrix-goods.prod-code AT ROW 4 COL 56 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-assortment-matrix-goods.gds-name AT ROW 5 COL 34 COLON-ALIGNED
          LABEL "Наименование" FORMAT "x(255)"
           VIEW-AS TEXT
          SIZE 60 BY .67
          FGCOLOR 4
     "Описание товара:" VIEW-AS TEXT
          SIZE 19.5 BY 1 AT ROW 6.5 COL 1.5
     SPACE(78.00) SKIP(6.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заголовок ассортиментной матрицы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_assortment-matrix-goods B "?" ? ub assortment-matrix-goods
      TABLE: tt-assortment-matrix-goods T "?" NO-UNDO ub assortment-matrix-goods
      ADDITIONAL-FIELDS:
          field artic as char
          field prod-code as int
          field prod-type as char
          field gds-name as char
      END-FIELDS.
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

/* SETTINGS FOR FILL-IN tt-assortment-matrix-goods.artic IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-assortment-matrix-goods.asmt-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-assortment-matrix-goods.gds-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-assortment-matrix-goods,ub.goods WHERE Temp-Tables.tt-assortment-matrix-goods ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заголовок ассортиментной матрицы */
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

 run str/cgdsmatr.w
 (input  parparentproc ,
  input  tt-assortment-matrix-goods.asmt-id ,
  input  tt-assortment-matrix-goods.db-num ,
  input  tt-assortment-matrix-goods.gds-code,
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
{ ref/tabhndmv.i v-tab-order }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   find first buf_assortment-matrix exclusive-lock where
              buf_assortment-matrix.asmt-id = p-asmt-id and
              buf_assortment-matrix.db-num = p-db-num no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
 ASSIGN frame {&frame-name}:TITLE = buf_assortment-matrix.asmt-name .
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
/*IF v-db-num <> 0
AND (p-mode = {&add-def}
     OR p-mode = {&UPDATE} ) THEN DO:
      message
    vss-workfile vss-revision vss-description skip
    "Нельзя редактировать запись Ассортиментная матрица в УБД"
    view-as alert-box ERROR.
    return error .
END.
*/

  for each tt-assortment-matrix-goods:
    delete tt-assortment-matrix-goods.
  end.

  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_assortment-matrix-goods exclusive-lock where
                   recid(locked_assortment-matrix-goods) = p-doc-rec no-wait no-error.
      if locked locked_assortment-matrix-goods then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись товара Ассортиментной матрицы занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_assortment-matrix-goods no-lock where
                       recid(locked_assortment-matrix-goods) = p-doc-rec no-error .
      if not avail locked_assortment-matrix-goods then do:
        find first locked_assortment-matrix-goods no-lock where
                   locked_assortment-matrix-goods.db-num  = p-db-num and
                   locked_assortment-matrix-goods.asmt-id = p-asmt-id no-error .
      end.
    end.
    if not available locked_assortment-matrix-goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись товара Ассортиментной матрицы"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-assortment-matrix-goods.
    buffer-copy locked_assortment-matrix-goods to tt-assortment-matrix-goods.
    find first goods no-lock where goods.gds-code = locked_assortment-matrix-goods.gds-code no-error .
    assign
      tt-assortment-matrix-goods.artic     = goods.artic
      tt-assortment-matrix-goods.prod-code = goods.prod-code
      tt-assortment-matrix-goods.prod-type = goods.prod-type
      tt-assortment-matrix-goods.gds-name  = goods.gds-name
    .

   end.
   else do:
          create tt-assortment-matrix-goods.
          assign
          tt-assortment-matrix-goods.asmt-id = v-last-code + 1
          tt-assortment-matrix-goods.db-num  = p-db-num
         .
   end.
  run myenable.

  wait-for go of frame {&frame-name} focus tt-assortment-matrix-goods.asmg-des .
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
  IF AVAILABLE tt-assortment-matrix-goods THEN
    DISPLAY tt-assortment-matrix-goods.asmg-des tt-assortment-matrix-goods.asmt-id
          tt-assortment-matrix-goods.gds-code tt-assortment-matrix-goods.artic
          tt-assortment-matrix-goods.prod-type
          tt-assortment-matrix-goods.prod-code
          tt-assortment-matrix-goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-assortment-matrix-goods.asmg-des
         tt-assortment-matrix-goods.asmt-id tt-assortment-matrix-goods.gds-code
         tt-assortment-matrix-goods.artic tt-assortment-matrix-goods.prod-type
         tt-assortment-matrix-goods.prod-code
         tt-assortment-matrix-goods.gds-name
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
  end.
  otherwise do:
    IF AVAILABLE tt-assortment-matrix-goods THEN
    DISPLAY
    tt-assortment-matrix-goods.asmt-id
    tt-assortment-matrix-goods.artic
    tt-assortment-matrix-goods.prod-code
    tt-assortment-matrix-goods.prod-type
    tt-assortment-matrix-goods.gds-name
    tt-assortment-matrix-goods.gds-code
    tt-assortment-matrix-goods.asmg-des
    WITH FRAME Dialog-Frame.
  end.
END CASE.


if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
b-quit:col = 1
.
hide
b-exit in frame {&frame-name}.
end.


ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Hist when p-mode <> {&add-def}
B-Help
tt-assortment-matrix-goods.asmg-des   when p-mode <> {&lookup}

WITH FRAME Dialog-Frame.
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
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-assortment-matrix-goods then do:
    create tt-assortment-matrix-goods.
end.

assign
frame {&frame-name}
tt-assortment-matrix-goods.asmt-id
.
assign
  tt-assortment-matrix-goods.asmg-des = tt-assortment-matrix-goods.asmg-des:SCREEN-VALUE.
/* проверки при вводе */

{ ref/gds-mat1.i
    this-procedure
    p-doc-rec
    p-mode
    tt-assortment-matrix-goods.asmt-id
    tt-assortment-matrix-goods.db-num
    tt-assortment-matrix-goods.gds-code
    tt-assortment-matrix-goods.asmg-des
    no-error }
    if error-status:error then do:
      { gbl/reterhnd.i  error }
      undo, return error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME