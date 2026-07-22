&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_assortment-matrix FOR ub.assortment-matrix.
DEFINE TEMP-TABLE tt-assortment-matrix NO-UNDO LIKE ub.assortment-matrix
       field obj-name as character
       field is-rel as logic
       field rel-id as character.
DEFINE BUFFER X_curr_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования заголовка ассортиментной матрицы

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
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&update} {&lookup}*/
DEFINE INPUT PARAMETER p-asmt-id LIKE ub.assortment-matrix.asmt-id NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования заголовка ассортиментной матрицы ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/assmatat.i }

define variable v-rid-list  as character no-undo.
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.assortment-matrix.asmt-id no-undo.
&scop tab-order   "B-exit,b-quit,b-hist,b-help,asmt-id,asmt-name,asmt-des," +  ~
                  ""

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-assortment-matrix

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-assortment-matrix.asmt-id ~
tt-assortment-matrix.asmt-type tt-assortment-matrix.obj-type ~
tt-assortment-matrix.obj-code tt-assortment-matrix.asmt-name ~
tt-assortment-matrix.asmt-des tt-assortment-matrix.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-assortment-matrix.asmt-id tt-assortment-matrix.asmt-type ~
tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code ~
tt-assortment-matrix.asmt-name tt-assortment-matrix.asmt-des ~
tt-assortment-matrix.obj-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-assortment-matrix
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-assortment-matrix
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-assortment-matrix SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-assortment-matrix SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-assortment-matrix
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-assortment-matrix


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-assortment-matrix.asmt-id ~
tt-assortment-matrix.asmt-type tt-assortment-matrix.obj-type ~
tt-assortment-matrix.obj-code tt-assortment-matrix.asmt-name ~
tt-assortment-matrix.asmt-des tt-assortment-matrix.obj-name
&Scoped-define ENABLED-TABLES tt-assortment-matrix
&Scoped-define FIRST-ENABLED-TABLE tt-assortment-matrix
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Hist B-Help r-obj T-relation ~
r-assmatr v-rel-id v-shablon-name
&Scoped-Define DISPLAYED-FIELDS tt-assortment-matrix.asmt-id ~
tt-assortment-matrix.asmt-type tt-assortment-matrix.obj-type ~
tt-assortment-matrix.obj-code tt-assortment-matrix.asmt-name ~
tt-assortment-matrix.asmt-des tt-assortment-matrix.obj-name
&Scoped-define DISPLAYED-TABLES tt-assortment-matrix
&Scoped-define FIRST-DISPLAYED-TABLE tt-assortment-matrix
&Scoped-Define DISPLAYED-OBJECTS T-relation v-rel-id v-shablon-name

/* Custom List Definitions                                              */
/* List-obj,List-2,List-3,List-4,List-5,List-6                          */
&Scoped-define List-obj tt-assortment-matrix.obj-type ~
tt-assortment-matrix.obj-code r-obj T-relation r-assmatr v-rel-id ~
v-shablon-name

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
     SIZE 2.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 6.5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-assmatr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Выбор шаблона".

DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE v-rel-id AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-shablon-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.5 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE T-relation AS LOGICAL INITIAL no
     LABEL "Есть привязка к шаблону"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-assortment-matrix SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 89.5
     B-Help AT ROW 1 COL 96.5
     tt-assortment-matrix.asmt-id AT ROW 2 COL 34 COLON-ALIGNED
          LABEL "Внутр.код ассортиментной матрицы"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-assortment-matrix.asmt-type AT ROW 3 COL 36 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 34 BY 1 TOOLTIP "Тип ассортиментной матрицы"
     tt-assortment-matrix.obj-type AT ROW 4 COL 34 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS FILL-IN
          SIZE 4.5 BY 1
     tt-assortment-matrix.obj-code AT ROW 4 COL 39 COLON-ALIGNED NO-LABEL FORMAT ">>>>>>>>>"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     r-obj AT ROW 4 COL 50.5
     T-relation AT ROW 5.54 COL 9.25 WIDGET-ID 2
     r-assmatr AT ROW 5.54 COL 35.5 WIDGET-ID 12
     tt-assortment-matrix.asmt-name AT ROW 6.92 COL 34 COLON-ALIGNED
          LABEL "Название ассортиментной матрицы"
          VIEW-AS FILL-IN
          SIZE 32 BY 1
     tt-assortment-matrix.asmt-des AT ROW 9.33 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 6.5
     tt-assortment-matrix.obj-name AT ROW 4 COL 52 COLON-ALIGNED NO-LABEL FORMAT "x(20)"
           VIEW-AS TEXT
          SIZE 43.5 BY 1
     v-rel-id AT ROW 5.54 COL 36.88 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     v-shablon-name AT ROW 5.54 COL 51.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     "Описание:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 8 COL 3.25
     "Тип:" VIEW-AS TEXT
          SIZE 4.5 BY 1 AT ROW 3 COL 31
     SPACE(63.74) SKIP(12.32)
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
      TABLE: locked_assortment-matrix B "?" ? ub assortment-matrix
      TABLE: tt-assortment-matrix T "?" NO-UNDO ub assortment-matrix
      ADDITIONAL-FIELDS:
          field obj-name as character
          field is-rel as logic
          field rel-id as character
      END-FIELDS.
      TABLE: X_curr_clients B "?" ? ub clients
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

/* SETTINGS FOR FILL-IN tt-assortment-matrix.asmt-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-assortment-matrix.asmt-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-assortment-matrix.obj-code IN FRAME Dialog-Frame
   1 EXP-FORMAT                                                         */
/* SETTINGS FOR FILL-IN tt-assortment-matrix.obj-name IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt-assortment-matrix.obj-type IN FRAME Dialog-Frame
   1 EXP-LABEL                                                          */
/* SETTINGS FOR BUTTON r-assmatr IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON r-obj IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX T-relation IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN v-rel-id IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN v-shablon-name IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-assortment-matrix"
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


&Scoped-define SELF-NAME tt-assortment-matrix.asmt-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-assortment-matrix.asmt-type Dialog-Frame
ON VALUE-CHANGED OF tt-assortment-matrix.asmt-type IN FRAME Dialog-Frame
DO:
  ASSIGN tt-assortment-matrix.asmt-TYPE .
  RUN proc-rs-type.

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

 run str/cassmatr.w (
  input  parparentproc ,
  input  locked_assortment-matrix.asmt-id ,
  input  locked_assortment-matrix.db-num ,
  input-output pp-rid-list    ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-assmatr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-assmatr Dialog-Frame
ON CHOOSE OF r-assmatr IN FRAME Dialog-Frame
DO:

define buffer buf_assort-matrix for ub.assortment-matrix  .
  v-rid-list  = "".
  v-rel-id        = "" .
  v-shablon-name  = "" .
  display v-rel-id v-shablon-name  with frame {&frame-name} .

    run ref/assmatr.w (
        input parParentProc   ,
        input "b-sel"         ,
        input p-curr-obj-type ,
        input p-curr-obj-code ,
        input {&type-assmatr-shablon}  ,
        input 0               ,
        input-output v-rid-list ) .

  if num-entries(v-rid-list) <> 1 then return no-apply.

  find first buf_assort-matrix no-lock where  recid(buf_assort-matrix) = int(v-rid-list) no-error .
  if error-status :error then return no-apply.

  v-rel-id        = substitute( "&1&3&2" , buf_assort-matrix.asmt-id , buf_assort-matrix.db-num , {&delim-par} ) .
  v-shablon-name  = buf_assort-matrix.asmt-name .
  display v-rel-id v-shablon-name  with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-relation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-relation Dialog-Frame
ON VALUE-CHANGED OF T-relation IN FRAME Dialog-Frame /* Есть привязка к шаблону */
DO:
  assign t-relation.
  run select-list-sh .
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
 { ref/ord-trgg.i obj tt-assortment-matrix. p-curr- }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
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
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.


  for each tt-assortment-matrix:
    delete tt-assortment-matrix.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_assortment-matrix EXclusive-lock where
                   recid(locked_assortment-matrix) = p-doc-rec no-wait no-error.
      if locked locked_assortment-matrix then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись Ассортиментная матрица занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_assortment-matrix no-lock where
                       recid(locked_assortment-matrix) = p-doc-rec no-error .
      if not avail locked_assortment-matrix then do:
        find first locked_assortment-matrix no-lock where
                   locked_assortment-matrix.asmt-id = p-asmt-id no-error .
      end.
    end.
    if not available locked_assortment-matrix then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись Ассортиментной матрицы"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-assortment-matrix.
    buffer-copy locked_assortment-matrix to tt-assortment-matrix.

   end.
   else do:
          create tt-assortment-matrix.
          assign
          tt-assortment-matrix.asmt-id = v-last-code + 1
         .
   end.
   run init-attr.
  RUN Myenable.

  wait-for go of frame {&frame-name} focus tt-assortment-matrix.asmt-name .
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
  DISPLAY T-relation v-rel-id v-shablon-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-assortment-matrix THEN
    DISPLAY tt-assortment-matrix.asmt-id tt-assortment-matrix.asmt-type
          tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code
          tt-assortment-matrix.asmt-name tt-assortment-matrix.asmt-des
          tt-assortment-matrix.obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-assortment-matrix.asmt-id
         tt-assortment-matrix.asmt-type tt-assortment-matrix.obj-type
         tt-assortment-matrix.obj-code r-obj T-relation r-assmatr
         tt-assortment-matrix.asmt-name tt-assortment-matrix.asmt-des
         tt-assortment-matrix.obj-name v-rel-id v-shablon-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-attr Dialog-Frame
PROCEDURE init-attr :
/*------------------------------------------------------------------------------
  Purpose:     Получить атрибуты Матрицы из БД
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-exist   as logical   no-undo .
define variable v-type    as character no-undo .
define variable v-value   as character no-undo .

define buffer bufsh_assortment-matrix for ub.assortment-matrix  .
v-shablon-name = "" .
  run assmatat-exist (
      input tt-assortment-matrix.asmt-id
      ,input tt-assortment-matrix.db-num
      ,input {&assmatat-RootShablon}
      ,output v-exist
      ) .

  if v-exist then do:
  run assmatat-value (
      input tt-assortment-matrix.asmt-id
      ,input tt-assortment-matrix.db-num
      ,input {&assmatat-RootShablon}
      ,output v-value
      ,output v-type
      ) .

     find first bufsh_assortment-matrix no-lock where
                bufsh_assortment-matrix.asmt-id = int(entry(1,v-value,{&delim-par})) and
                bufsh_assortment-matrix.db-num  = int(entry(2,v-value,{&delim-par})) no-error .
    if not available bufsh_assortment-matrix then do:
        assign
            tt-assortment-matrix.is-rel = false
            tt-assortment-matrix.rel-id = ""
        .
    end.
    else do:
     assign
        tt-assortment-matrix.is-rel = true
        tt-assortment-matrix.rel-id = v-value
        v-shablon-name = bufsh_assortment-matrix.asmt-name
     .
     end.
  end.
  else do:
     assign
        tt-assortment-matrix.is-rel = false
        tt-assortment-matrix.rel-id = ""
     .
   end.

   assign
      T-relation =    tt-assortment-matrix.is-rel
      v-rel-id   =    tt-assortment-matrix.rel-id
   .


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
tt-assortment-matrix.asmt-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                = {&type-assmatr-obj} + {&comma-char} + {&type-assmatr-obj} + {&comma-char} +
                {&type-assmatr-shablon} + {&comma-char} + {&type-assmatr-shablon} .

  run select-list-sh .

  case p-mode:
  when {&add-def} then do:
    tt-assortment-matrix.asmt-type  = {&type-assmatr-shablon} .

    display
    ? @ tt-assortment-matrix.asmt-id
    ? @ tt-assortment-matrix.obj-code
    ? @ tt-assortment-matrix.obj-type
    ? @ tt-assortment-matrix.obj-name
        tt-assortment-matrix.asmt-type
    WITH FRAME Dialog-Frame.

    RUN proc-rs-type.

  end.
  otherwise do:
    IF AVAILABLE tt-assortment-matrix THEN
    DISPLAY
    tt-assortment-matrix.asmt-id
    tt-assortment-matrix.asmt-name
    tt-assortment-matrix.asmt-des
    tt-assortment-matrix.asmt-type
    tt-assortment-matrix.obj-code
    tt-assortment-matrix.obj-type
    tt-assortment-matrix.obj-name
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
r-obj                           when p-mode = {&add-def}  and  tt-assortment-matrix.asmt-type  <> {&type-assmatr-shablon}
tt-assortment-matrix.obj-code   when p-mode = {&add-def}  and  tt-assortment-matrix.asmt-type  <> {&type-assmatr-shablon}
tt-assortment-matrix.obj-type   when p-mode = {&add-def}  and  tt-assortment-matrix.asmt-type  <> {&type-assmatr-shablon}
tt-assortment-matrix.asmt-type  when p-mode = {&add-def}
tt-assortment-matrix.asmt-name  when p-mode <> {&lookup}
tt-assortment-matrix.asmt-des   when p-mode <> {&lookup}

WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-rs-type Dialog-Frame
PROCEDURE proc-rs-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF  tt-assortment-matrix.asmt-TYPE = {&type-assmatr-obj} THEN DO:
      DISPLAY {&List-obj} tt-assortment-matrix.obj-name WITH FRAME {&frame-name} .
      ENABLE {&List-obj} WITH FRAME {&frame-name} .
  END.
  ELSE DO:
     tt-assortment-matrix.obj-code = 0 .
     tt-assortment-matrix.obj-type = "" .
     tt-assortment-matrix.obj-name = "" .
     t-relation = false .
     v-rel-id = "".
     v-shablon-name = "".
     DISPLAY {&List-obj} tt-assortment-matrix.obj-name WITH FRAME {&frame-name} .
     DISABLE {&List-obj} tt-assortment-matrix.obj-name WITH FRAME {&frame-name} .
  END.

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

if not available tt-assortment-matrix then do:
    create tt-assortment-matrix.
end.

assign
  frame {&frame-name}
  tt-assortment-matrix.asmt-id
  tt-assortment-matrix.asmt-name
  tt-assortment-matrix.asmt-type
  tt-assortment-matrix.obj-type
  tt-assortment-matrix.obj-code
  T-relation
  v-rel-id
  .

assign
  tt-assortment-matrix.asmt-des = tt-assortment-matrix.asmt-des:SCREEN-VALUE.
/* проверки при вводе */
IF tt-assortment-matrix.asmt-TYPE = {&type-assmatr-obj}  THEN DO:

    IF tt-assortment-matrix.obj-type = "" AND tt-assortment-matrix.obj-code = 0 THEN DO:
        MESSAGE "Не заполнено значение Объекта !"
                 view-as alert-box ERROR.
        return error  .
    END.

    find first X_curr_clients no-lock where
               X_curr_clients.obj-type = tt-assortment-matrix.obj-type AND
               X_curr_clients.obj-code = tt-assortment-matrix.obj-code no-error.
if not available X_curr_clients then do:
 message
 vss-workfile vss-revision vss-description skip
 "Неверное значение для поиска Объекта"
     tt-assortment-matrix.obj-type
     tt-assortment-matrix.obj-code
     view-as alert-box ERROR.
 return error .
end.
 run leave-proc-obj no-error .
   if error-status :error then return error return-value .
end.
define buffer bufsh_assortment-matrix for ub.assortment-matrix  .
if T-relation then do:
     find first bufsh_assortment-matrix no-lock where
                bufsh_assortment-matrix.asmt-id = int(entry(1,v-rel-id,{&delim-par})) and
                bufsh_assortment-matrix.db-num  = int(entry(2,v-rel-id,{&delim-par})) no-error .
    if not available bufsh_assortment-matrix then do:
     message "Не верно задан ШАБЛОН МАТРИЦ !" view-as alert-box information .
     return error return-value .
    end.

    if bufsh_assortment-matrix.asmt-type <> {&type-assmatr-shablon} then do:
      message "Можно выбрать только  ШАБЛОН МАТРИЦ !" view-as alert-box information .
      return error return-value .
    end.

    if bufsh_assortment-matrix.asmt-status <> 0 then do:
      message "Статус ШАБЛОНА МАТРИЦ  должен быть текущим!" view-as alert-box information .
      return error return-value .
    end.
end.
run ref/assmatr1.p
(input-output p-doc-rec
,input p-mode
,input tt-assortment-matrix.asmt-id
,input tt-assortment-matrix.asmt-name
,input tt-assortment-matrix.asmt-des
,input tt-assortment-matrix.asmt-type
,input tt-assortment-matrix.obj-type
,input tt-assortment-matrix.obj-code
,input T-relation
,input v-rel-id
) no-error.
if error-status:error then do:
 { gbl/reterhnd.i  error }
   undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-list-sh Dialog-Frame
PROCEDURE select-list-sh :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  if tt-assortment-matrix.asmt-type = {&type-assmatr-shablon} then do:
    hide
      v-rel-id in frame {&frame-name}
      v-shablon-name
      r-assmatr
      t-relation
      in frame {&frame-name} .
  end.
  else do:
      if p-mode <> {&lookup} then do:
          enable  t-relation with frame {&frame-name} .
      end.
      display t-relation with frame {&frame-name} .

      if t-relation then do:
         display v-rel-id v-shablon-name r-assmatr with frame  {&frame-name}.
         if p-mode <> {&lookup} then do:
            enable  r-assmatr with frame  {&frame-name}.
         end.
      end.
      else do:
        disable v-rel-id v-shablon-name r-assmatr with frame {&frame-name}.
        hide    v-rel-id v-shablon-name r-assmatr in frame {&frame-name}.
      end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
