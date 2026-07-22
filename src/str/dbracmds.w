&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_db-rec-attr FOR ub.db-rec-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выполняющиеся распределенные команды СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/12/04
Author: Bakhtadze Natalya
Creation date: 08/12/04

*/

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*может быть {&all} "db-num" "attr-code" "uniq-key-rec" */
define input parameter p-db-num         LIKE ub.db-rec-attr.db-num no-undo .
define input parameter p-attr-code         LIKE ub.db-rec-attr.attr-code no-undo .
define input parameter p-uniq-key-rec      LIKE ub.db-rec-attr.uniq-key-rec no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Выполняющиеся распределенные команды СПН":U.
{ cmp/vssrevis.i }
{cmp\trg-def.i}
/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/library.i }
{ nws/db-rec.i }
{ gbl/key-rec.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable sort-column-name as character no-undo .
define variable filter-point as character no-undo init "dbracmds" .
define variable filter-point0 as character no-undo init "dbracmds" .
define variable filter-label as character no-undo init "Выполняющиеся распределенные команды СПН" .
define variable filter-label0 as character no-undo init "Выполняющиеся распределенные команды СПН" .
define variable v-rid-list as character no-undo .

DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-tbl-row  as rowid     no-undo.
define variable v-tbl-name as character no-undo.
define variable v-command-title as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-db-rec-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_db-rec-attr

/* Definitions for BROWSE BR-db-rec-attr                                */
&Scoped-define FIELDS-IN-QUERY-BR-db-rec-attr ~
mark-string(recid(X_db-rec-attr), p-rid-list) ~
progs-title-function(X_db-rec-attr.attr-code) X_db-rec-attr.db-num ~
X_db-rec-attr.attr-value-date X_db-rec-attr.attr-type ~
X_db-rec-attr.attr-value-logical ~
uniq-key-rec-string-f(X_db-rec-attr.uniq-key-rec) ~
X_db-rec-attr.attr-value-decimal
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-db-rec-attr
&Scoped-define QUERY-STRING-BR-db-rec-attr FOR EACH X_db-rec-attr NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-db-rec-attr OPEN QUERY BR-db-rec-attr FOR EACH X_db-rec-attr NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-db-rec-attr X_db-rec-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-db-rec-attr X_db-rec-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-db-rec-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-refresh B-sch B-Help ~
BR-db-rec-attr mark-num
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

DEFINE BUTTON B-lkp
     LABEL "Невидимая кнопка для brwsretr.i"
     SIZE 31 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-refresh DEFAULT
     LABEL "Обновить"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-db-rec-attr FOR
      X_db-rec-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-db-rec-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-db-rec-attr Dialog-Frame _STRUCTURED
  QUERY BR-db-rec-attr NO-LOCK DISPLAY
      mark-string(recid(X_db-rec-attr), p-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
            WIDTH 2
      progs-title-function(X_db-rec-attr.attr-code) COLUMN-LABEL "Команда" FORMAT "X(35)":U
      X_db-rec-attr.db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
      X_db-rec-attr.attr-value-date COLUMN-LABEL "Дата!команды" FORMAT "99/99/9999":U
      X_db-rec-attr.attr-type COLUMN-LABEL "Статус" FORMAT "X(8)":U
      X_db-rec-attr.attr-value-logical COLUMN-LABEL "ok" FORMAT "+/-":U
      uniq-key-rec-string-f(X_db-rec-attr.uniq-key-rec) COLUMN-LABEL "Объект команды" FORMAT "X(45)":U
      X_db-rec-attr.attr-value-decimal COLUMN-LABEL "БД!инициатор" FORMAT ">>>>9":U
            WIDTH 10
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-refresh AT ROW 1 COL 31
     B-lkp AT ROW 1 COL 50
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-db-rec-attr AT ROW 3 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.75) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выполняющиеся распределенные команды СПН"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_db B "?" ? ub db
      TABLE: X_db-rec-attr B "?" ? ub db-rec-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-db-rec-attr B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lkp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-lkp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-db-rec-attr
/* Query rebuild information for BROWSE BR-db-rec-attr
     _TblList          = "X_db-rec-attr"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_db-rec-attr), p-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no "2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"progs-title-function(X_db-rec-attr.attr-code)" "Команда" "X(35)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"X_db-rec-attr.db-num" "БД" ">>>>9" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"X_db-rec-attr.attr-value-date" "Дата!команды" "99/99/9999" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"X_db-rec-attr.attr-type" "Статус" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"X_db-rec-attr.attr-value-logical" "ok" "+/-" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"uniq-key-rec-string-f(X_db-rec-attr.uniq-key-rec)" "Объект команды" "X(45)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"X_db-rec-attr.attr-value-decimal" "БД!инициатор" ">>>>9" ? ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-db-rec-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выполняющиеся распределенные команды СПН */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выполняющиеся распределенные команды СПН */
OR ENDKEY OF FRAME {&frame-name} DO:
    run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input p-rid-list) no-error.
  if error-status:error then return no-apply.

  APPLY "END-ERROR":U TO SELF.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_db-rec-attr then do:
    { gbl/markstrn.i X_db-rec-attr p-rid-list }
    loc#log = BR-db-rec-attr:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = BR-db-rec-attr:select-next-row ().
        apply "VALUE-CHANGED" to BR-db-rec-attr in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to BR-db-rec-attr in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  DEFINE VARIABLE v-rec-recid AS RECID NO-UNDO.
  if g#db-num eq 0
  then
     run adm\comcom.p (0).
  v-rec-recid = recid(X_db-rec-attr).
  run openbr in this-procedure ( input yes, input no, input "").
  reposition br-db-rec-attr to recid v-rec-recid no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
    RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_db-rec-attr ) then do:
    if  ( p-rid-list = "" ) or b-mark:sensitive = no
    then
    p-rid-list = string( recid( X_db-rec-attr ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-db-rec-attr
&Scoped-define SELF-NAME BR-db-rec-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-db-rec-attr Dialog-Frame
ON RETURN OF BR-db-rec-attr IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-db-rec-attr IN FRAME {&frame-name} DO:
   run proc-br-db-rec-attr no-error.
  if error-status:error then return no-apply.
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
{ gbl/setfltnm.i }

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if LOOKUP(p-mode, ({&all} + {&delim-par} +
                    "db-num":U + {&delim-par} +
                    "attr-code":U + {&delim-par} +
                    "uniq-key-rec":U),
                {&delim-par}) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 IF p-mode = "db-num":U THEN DO:
     FIND FIRST X_db NO-LOCK WHERE X_db.db-num = p-db-num NO-ERROR.
     IF NOT AVAILABLE X_db THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-db-num"
         p-db-num
         view-as alert-box ERROR.
         return error .
   END.
END.
IF p-mode = "attr-code":U THEN DO:
  IF LOOKUP (p-attr-code, {&db-rec-attr-list}) = 0 THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-attr-code"
         p-attr-code
         view-as alert-box ERROR.
         return error .
   END.
END.
IF p-mode = "uniq-key-rec":U THEN DO:
  RUN gen-row-keyr IN THIS-PROCEDURE
  ( input  p-uniq-key-rec
   ,input ?
   ,input "ub":U
   ,input ?
   ,input share-lock
   ,output v-tbl-row
   ,output  v-tbl-name
  ) NO-ERROR.
  IF error-status:error THEN DO:
     message
     vss-workfile vss-revision vss-description skip
     "Неверное значение параметров вызова p-uniq-key-rec"
     p-uniq-key-rec
     view-as alert-box ERROR.
     return error .
   END.
END.
v-rid-list = p-rid-list.
  RUN Myenable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-db-rec-attr to recid v-doc-rec No-ERROR.
    { gbl/mv-clmn.i
    &browse-name = "br-db-rec-attr"
    &frame-name = "{&frame-name}"
    &ext-col = 7
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,2,4,5,6,7,3'"
    &prev-order-column-condition_2 = " p-mode = 'db-num':U "
    &prev-order-column_3 = "'1,3,4,5,6,7,2'"
    &prev-order-column-condition_3 = " p-mode = 'attr-code':U "
    &prev-order-column_4 = "'1,2,3,4,5,7,6'"
    &prev-order-column-condition_4 = " p-mode = 'uniq-key-rec':U "
    }
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
  ENABLE b-quit B-mark B-sel b-refresh B-sch B-Help BR-db-rec-attr mark-num
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
 DISPLAY mark-num
      WITH FRAME Dialog-Frame.
 DISPLAY mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
b-sch
B-Help
b-refresh
br-db-rec-attr
mark-num

with FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Выполняющиеся распределенные команды СПН" + {&space-char}.

run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-db-rec-attr FOR EACH X_db-rec-attr

&scop flt-open-dyn_open-query FOR EACH X_db-rec-attr

&scop flt-open-query-handle QUERY br-db-rec-attr:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_db-rec-attr

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_db-rec-attr

&scop flt-open-waitfram true

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
     filter-point = filter-point0 + p-mode.
       ASSIGN
       frame {&frame-name}:TITLE = title0
       filter-label = substitute("&1", filter-label0)
       .

     { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "db-num" THEN DO:
       filter-point = filter-point0 + p-mode.
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" БД № &1", p-db-num)
       filter-label = substitute("&1 Одна БД", filter-label0)
                                   .
      { gbl/fltopend.i
        &where-cond = " ~
          X_db-rec-attr.db-num  = p-db-num    ~
                      "
        &dyn_where-cond = " substitute(' X_db-rec-attr.db-num  = &1', p-db-num )"

        &use-ind    = "  "
        &by         = "  " }
    END.
  WHEN "attr-code" THEN DO:
     filter-point = filter-point0 + p-mode.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Команда: &1", progs-title-function (p-attr-code))
     filter-label = substitute("&1 Один тип команды", filter-label0)
                                 .
    { gbl/fltopend.i
      &where-cond = " ~
        X_db-rec-attr.attr-code  = p-attr-code    ~
                    "
      &dyn_where-cond = " substitute(' X_db-rec-attr.attr-code  = &1&2&1', ~{&double-quote~}, p-attr-code ) "
      &use-ind    = "  "
      &by         = "  " }
  END.
WHEN "uniq-key-rec" THEN DO:
     filter-point = filter-point0 + p-mode.
     ASSIGN
     frame {&frame-name}:TITLE = title0 +
                                 substitute(" Запись: &1",  uniq-key-rec-string-f(p-uniq-key-rec))
     filter-label = substitute("&1 Одна запись", filter-label0)
                                 .
    { gbl/fltopend.i
      &where-cond = " ~
        X_db-rec-attr.uniq-key-rec  = p-uniq-key-rec    ~
                    "
      &dyn_where-cond = " substitute(' X_db-rec-attr.uniq-key-rec  = &1&2&1', ~{&double-quote~}, p-uniq-key-rec ) "

      &use-ind    = "  "
      &by         = "  " }
  END.


END CASE.
if not p-open-query then
REPOSITION br-db-rec-attr to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-db-rec-attr:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-db-rec-attr in frame {&frame-name}.
APPLY "ENTRY" TO br-db-rec-attr.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'db-rec-attr'
  join-tbl = 'X_db-rec-attr'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('attr-code', 'Команда', 'db-rec-attr-cmd',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД №', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('attr-value-decimal', 'БД-инициатор', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('attr-type', 'Статус команды', 'db-rec-attr-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('attr-value-logical', 'Выполнение команды', 'db-rec-attr-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-db-rec-attr Dialog-Frame
PROCEDURE proc-br-db-rec-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
