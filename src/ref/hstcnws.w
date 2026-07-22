&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-hist-nws-option FOR ub.c-hist-nws-option.
DEFINE BUFFER X_hist-nws-option FOR ub.hist-nws-option.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории настроек опции истории и маршрутизации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 16/03/04
Author: Bakhtadze Natalya
Creation date: 16/03/04

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*db one subject-group subject-group-db one-db*/
define input parameter p-db-num like ub.hist-nws-option.db-num no-undo .
define input parameter p-subject-group as character no-undo .
define input parameter p-table-name as character no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории настроек опции истории и маршрутизации":U.
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
define variable v-rid-list as character no-undo .

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-hist-nws-option

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-hst-nws-option                             */
&Scoped-define FIELDS-IN-QUERY-br-hst-nws-option mark-string(if available X_c-hist-nws-option then recid(X_c-hist-nws-option) else ?, v-rid-list) usrfulnf(X_c-hist-nws-option.corr-user-name) X_c-hist-nws-option.corr-date X_c-hist-nws-option.table-name string(X_c-hist-nws-option.corr-time, "HH:MM") X_c-hist-nws-option.option-descr X_c-hist-nws-option.db-num X_c-hist-nws-option.hn-id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-hst-nws-option
&Scoped-define SELF-NAME br-hst-nws-option
&Scoped-define QUERY-STRING-br-hst-nws-option FOR EACH X_c-hist-nws-option NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-hst-nws-option OPEN QUERY {&SELF-NAME} FOR EACH X_c-hist-nws-option NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-hst-nws-option X_c-hist-nws-option
&Scoped-define FIRST-TABLE-IN-QUERY-br-hst-nws-option X_c-hist-nws-option


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-hst-nws-option}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-lookup B-Help ~
br-hst-nws-option BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-hn-label Dialog-Frame
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lookup
     LABEL "Button 1"
     SIZE 10 BY 1.

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

DEFINE QUERY br-hst-nws-option FOR
      X_c-hist-nws-option SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.03.

DEFINE BROWSE br-hst-nws-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-hst-nws-option Dialog-Frame _FREEFORM
  QUERY br-hst-nws-option NO-LOCK DISPLAY
      mark-string(if available X_c-hist-nws-option then recid(X_c-hist-nws-option) else ?, v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
usrfulnf(X_c-hist-nws-option.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
X_c-hist-nws-option.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
X_c-hist-nws-option.table-name FORMAT "X(20)":U
string(X_c-hist-nws-option.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
X_c-hist-nws-option.option-descr FORMAT "X(50)":U
X_c-hist-nws-option.db-num FORMAT ">>>>9":U
X_c-hist-nws-option.hn-id COLUMN-LABEL "Иденти!фикатор" FORMAT "->,>>>,>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.27.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-lookup AT ROW 1 COL 58 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     br-hst-nws-option AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.62) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История настроек записи истории и маршрутизации"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-hist-nws-option B "?" ? ub c-hist-nws-option
      TABLE: X_hist-nws-option B "?" ? ub hist-nws-option
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-hst-nws-option B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-hst-nws-option Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-hst-nws-option
/* Query rebuild information for BROWSE br-hst-nws-option
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-hist-nws-option NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-hst-nws-option */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История настроек записи истории и маршрутизации */
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История настроек записи истории и маршрутизации */
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
  if available X_c-hist-nws-option then do:
    { gbl/markstrn.i X_c-hist-nws-option v-rid-list }
    loc#log = br-hst-nws-option:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-hst-nws-option:select-next-row ().
        apply "VALUE-CHANGED" to br-hst-nws-option in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-hst-nws-option in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-hist-nws-option ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-hist-nws-option ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-hst-nws-option
&Scoped-define SELF-NAME br-hst-nws-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-hst-nws-option Dialog-Frame
ON RETURN OF br-hst-nws-option IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-hst-nws-option IN FRAME Dialog-Frame
    DO:
    run proc-br-hst-nws-option no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-hst-nws-option Dialog-Frame
ON VALUE-CHANGED OF br-hst-nws-option IN FRAME Dialog-Frame
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-hst-nws-option" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-hist-nws-option). run OpenBr in this-procedure. reposition br-hst-nws-option to recid v-doc-rec no-error. v-doc-rec = ?. ~
              apply 'value-changed' to br-hst-nws-option. " }
{ gbl/srt-clmn.i
  &browse-name    = "br-hst-nws-option"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-hist-nws-option.table-name"
  &open-query     = "run OpenBr in this-procedure ."
  &open-query-otherwise = "run OpenBr in this-procedure ."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if LOOKUP(p-mode, ('one':U + {&delim-par} +
                    "subject-group-db" + {&delim-par}  +
                    "one-db" + {&delim-par} +
                    "subject-group" + {&delim-par} +
                    "db"
                     )
                , {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 { gbl/curdbnum.i v-db-num }
  v-rid-list = p-rid-list.
  RUN MyEnable.
  RUn OpenBR in this-procedure .
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-hst-nws-option to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-hst-nws-option"
    &frame-name = "{&frame-name}"
    &ext-col = 8
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_1 = " p-mode = ~'one' "
    }
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
  ENABLE b-quit B-mark B-sel b-lookup B-Help br-hst-nws-option BR-changes
         mark-num
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
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-hst-nws-option
mark-num
br-changes
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
case p-mode:
  when "one" then do:
    OPEN QUERY br-hst-nws-option FOR EACH X_c-hist-nws-option NO-LOCK where
                               X_c-hist-nws-option.table-name = p-table-name
                                  INDEXED-REPOSITION.
  end.
  when "db" then do:
    OPEN QUERY br-hst-nws-option FOR EACH X_c-hist-nws-option NO-LOCK where
                                  X_c-hist-nws-option.db-num = p-db-num
                                  INDEXED-REPOSITION.
  end.
  when "subject-group" then do:
    OPEN QUERY br-hst-nws-option FOR EACH X_c-hist-nws-option NO-LOCK where
                                  X_c-hist-nws-option.subject-group = p-subject-group
                                  INDEXED-REPOSITION.
  end.
  when "subject-group-db" then do:
    OPEN QUERY br-hst-nws-option FOR EACH X_c-hist-nws-option NO-LOCK where
                                  X_c-hist-nws-option.subject-group = p-subject-group
                              and X_c-hist-nws-option.db-num = p-db-num
                                  INDEXED-REPOSITION.
  end.
  when "one-db" then do:
    OPEN QUERY br-hst-nws-option FOR EACH X_c-hist-nws-option NO-LOCK where
                                  X_c-hist-nws-option.table-name = p-table-name
                              and X_c-hist-nws-option.db-num = p-db-num
                                  INDEXED-REPOSITION.
  end.
end case.
IF v-rid-list <> '':U THEN DO:
   REPOSITION br-hst-nws-option TO RECID (INTEGER(entry(1,v-rid-list))) NO-ERROR.
END.
APPLY "VALUE-CHANGED" TO br-hst-nws-option in frame {&frame-name}.
APPLY "ENTRY" TO br-hst-nws-option.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-hst-nws-option Dialog-Frame 
PROCEDURE proc-br-hst-nws-option :
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-hist-nws-option then do:
  Open QUery br-changes for each temp-changes.
  return.
end.

&scop fields-name-list "option-descr,db-num,table-name,subject-group,get-hist-form-nws,hist-from-prim,hist-to-nws,nws-to-hist"
define variable v-label-param as character no-undo .

v-label-param =
  "option-descr" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "table-name" + {&delim-par} + "Таблица/Сущность" + {&delim-par} + "" + {&delim-flf}
 + "subject-group" + {&delim-par} + "Группа данных" + {&delim-par} + "" + {&delim-flf}
 + "get-hist-from-nws" + {&delim-par} + "Прием истории из другой УБД" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "hist-from-prim" + {&delim-par} + "Запись истории при непосред.изменении" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "hist-to-nws" + {&delim-par} + "Пересылка ист. в другие БД" + {&delim-par} + "get-hn-label" + {&delim-flf}
 + "nws-to-hist" + {&delim-par} + "Создание ист. при приеме по СПН" + {&delim-par} + "get-hn-label"
 .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-hist-nws-option:handle
                                            ,input  {&table_hist-nws-option}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-hn-label Dialog-Frame 
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS character ) :
&SCOPED-DEFINE hn-option-val-code p-hn-option
  RETURN {&hn-option-val-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

