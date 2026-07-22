&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-sr-izmerenia FOR c-sr-izmerenia.
DEFINE BUFFER X_curr_clients FOR clients.
DEFINE BUFFER X_sr-izmerenia FOR sr-izmerenia.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории средств измерения

Автор: Бахтадзе Наталья Викторовна
Дата создания: 22/02/18
Author: Bakhtadze Natalya
Creation date: 22/02/18

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc AS HANDLE NO-UNDO .
define input parameter bttns         as character no-undo . /*кнопки для нажатия*/
define input parameter p-mode        as character no-undo . /*one*/
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-node-code like ub.sr-izmerenia.node-code no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории средств измерения":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.


{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-sr-izmerenia

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-wp                                         */
&Scoped-define FIELDS-IN-QUERY-br-wp mark-string(recid(X_c-sr-izmerenia), p-rid-list) usrfulnf(X_c-sr-izmerenia.corr-user-name) X_c-sr-izmerenia.corr-date string(X_c-sr-izmerenia.corr-time, "HH:MM") X_c-sr-izmerenia.node-code X_c-sr-izmerenia.sr-model   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-wp   
&Scoped-define SELF-NAME br-wp
&Scoped-define QUERY-STRING-br-wp FOR EACH X_c-sr-izmerenia NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-wp OPEN QUERY {&SELF-NAME} FOR EACH X_c-sr-izmerenia NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-wp X_c-sr-izmerenia
&Scoped-define FIRST-TABLE-IN-QUERY-br-wp X_c-sr-izmerenia


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-wp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-wp BR-changes ~
mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-wp FOR 
      X_c-sr-izmerenia SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(120)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.05.

DEFINE BROWSE br-wp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-wp Dialog-Frame _FREEFORM
  QUERY br-wp NO-LOCK DISPLAY
      mark-string(recid(X_c-sr-izmerenia), p-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      usrfulnf(X_c-sr-izmerenia.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-sr-izmerenia.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
      string(X_c-sr-izmerenia.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
      X_c-sr-izmerenia.node-code
      X_c-sr-izmerenia.sr-model
      X_c-sr-izmerenia.sr-type-id
      /* 17/IV-2018 лишние поля не показывать
      X_c-sr-izmerenia.sr-temp-line column-label "Температурный коэффициент!линейного расширения материала!средства измерения уровня"
      X_c-sr-izmerenia.sr-abs-err-neft-water column-label "Абсолютная погрешность!измерений уровня нефтепродукта!и подтоварной воды"
      X_c-sr-izmerenia.sr-abs-err-water column-label "Абсолютная погрешность!измерений уровня!подтоварной воды"
      X_c-sr-izmerenia.sr-abs-err-dens column-label "Абсолютная погрешность!измерений плотности!нефтепродукта ареометром"
      X_c-sr-izmerenia.sr-abs-err-temp-vol column-label "Абсолютная погрешность!измерений температуры нефтепродукта!при измерении его объема"
      X_c-sr-izmerenia.sr-abs-err-temp-dens column-label "Абсолютная погрешность!измерений температуры нефтепродукта!при измерении его плотности"
      X_c-sr-izmerenia.sr-otnos column-label "Предел допускаемой!относительной погрешности!средства обработки!результатов измерений"
      */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.24 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-Help AT ROW 1 COL 95
     br-wp AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.6 COLON-ALIGNED NO-LABEL
     SPACE(78.52) SKIP(20.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История средств измерения"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-sr-izmerenia B "?" ? ub c-sr-izmerenia
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_sr-izmerenia B "?" ? ub sr-izmerenia
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-wp B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-wp Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN 
       br-wp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1
       br-wp:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE
       br-wp:COLUMN-MOVABLE IN FRAME Dialog-Frame         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-wp
/* Query rebuild information for BROWSE br-wp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-sr-izmerenia NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-wp */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История средств измерения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_c-sr-izmerenia then do:
    { gbl/markstrn.i X_c-sr-izmerenia p-rid-list }
    loc#log = br-wp:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-wp:select-next-row ().
        apply "VALUE-CHANGED" to br-wp in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-sr-izmerenia ) then do:
    if  ( p-rid-list = "" ) or b-mark:sensitive = no
    then
    p-rid-list = string( recid( X_c-sr-izmerenia ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-wp
&Scoped-define SELF-NAME br-wp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wp Dialog-Frame
ON RETURN OF br-wp IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-wp IN FRAME Dialog-Frame
    DO:
    run proc-br-wp no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wp Dialog-Frame
ON VALUE-CHANGED OF br-wp IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-wp" }
{ gbl/brwrefre.i "
    v-doc-rec = recid(X_c-sr-izmerenia).
    run openbr in this-procedure.
    reposition br-wp to recid v-doc-rec no-error.
    apply 'value-changed' to br-wp.
" }
{ gbl/srt-clmn.i
  &browse-name    = "br-wp"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-sr-izmerenia.sr-model"
  &sort-clmn_2    = "X_c-sr-izmerenia.corr-date"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if LOOKUP(p-mode, 'one':U, {&delim-par}) = 0 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if p-mode = "one":U then do:
   find first X_c-sr-izmerenia no-lock
        where X_c-sr-izmerenia.node-code = p-node-code no-error.
    if not available X_c-sr-izmerenia then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("Отсутствует история средства измерения с кодом &1", p-node-code)
        view-as alert-box ERROR.
        return.
    end.
  end.

/* { gbl/curdbnum.i v-db-num } 17/IV-2018 - не применяется */
  RUN MyEnable.
  RUn OpenBR.
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-wp to recid v-doc-rec No-ERROR.
  /* 17/IV-2018 - не применяется
  { gbl/mv-clmn.i
    &browse-name = "br-wp"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
    &prev-order-column-condition_1 = " p-mode = ~'one' "
  }
  */
 run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
 run diasize_init in this-procedure .
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
  DISPLAY mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-Help br-wp BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-wp mark-num
br-changes
with FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define variable v-host-code as integer no-undo .
/*{ gbl/hostcode.i p-obj-type p-obj-code v-host-code } 17/IV-2018 - не применяется */
OPEN QUERY br-wp FOR EACH X_c-sr-izmerenia NO-LOCK
                    where X_c-sr-izmerenia.node-code = p-node-code
                              INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-wp in frame {&frame-name}.
APPLY "ENTRY" TO br-wp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-wp Dialog-Frame 
PROCEDURE proc-br-wp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*{ ref/brwsretr.i } 17/IV-2018 - не применяется */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
/* 17/IV-2018 - то же самое выполняется внутри proc-full-temp-changes()
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-sr-izmerenia then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
*/
&scop fields-name-list "node-code,sr-model,sr-type-id,sr-temp-line,sr-abs-err-neft-water,sr-abs-err-water,sr-abs-err-dens,sr-abs-err-temp-vol,sr-abs-err-temp-dens,sr-otnos"
define variable v-label-param as character no-undo .

v-label-param =   "node-code" + {&delim-par} + "Код средства измерения" + {&delim-par} + ""
 + {&delim-flf} + "sr-model"  + {&delim-par} + "Модель" + {&delim-par} + ""
 + {&delim-flf} + "sr-type-id"  + {&delim-par} + "Тип" + {&delim-par} + ""
 + {&delim-flf} + "sr-temp-line"  + {&delim-par} + "Температурный коэффициент линейного расширения материала средства измерения уровня" + {&delim-par} + ""
 + {&delim-flf} + "sr-abs-err-neft-water"  + {&delim-par} + "Абсолютная погрешность измерений уровня нефтепродукта и подтоварной воды" + {&delim-par} + ""
 + {&delim-flf} + "sr-abs-err-water"  + {&delim-par} + "Абсолютная погрешность измерений уровня подтоварной воды" + {&delim-par} + ""
 + {&delim-flf} + "sr-abs-err-dens"  + {&delim-par} + "Абсолютная погрешность измерений плотности нефтепродукта ареометром" + {&delim-par} + ""
 + {&delim-flf} + "sr-abs-err-temp-vol"  + {&delim-par} + "Абсолютная погрешность измерений температуры нефтепродукта при измерении его объема" + {&delim-par} + ""
 + {&delim-flf} + "sr-abs-err-temp-dens"  + {&delim-par} + "Абсолютная погрешность измерений температуры нефтепродукта при измерении его плотности" + {&delim-par} + ""
 + {&delim-flf} + "sr-otnos"  + {&delim-par} + "Предел допускаемой относительной погрешности средства обработки результатов измерений" + {&delim-par} + ""
.
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-sr-izmerenia:handle
                                            ,input  {&table_sr-izmerenia}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

