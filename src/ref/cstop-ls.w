&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-stop-list FOR ub.c-stop-list.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История стоплистов по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/12/07
Author: Bakhtadze Natalya
Creation date: 07/12/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
define input parameter p-stop-list-code as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список стоплистов по ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i DEF }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable filter-label as character no-undo .
define variable filter-label0 as character no-undo init "История Стоплистов" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "сstop-ls" .
DEFINE VARIABLE sort-column-name as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-stop-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-stop-list

/* Definitions for BROWSE BR-c-stop-list                                */
&Scoped-define FIELDS-IN-QUERY-BR-c-stop-list mark-string(recid(X_c-stop-list), v-rid-list) X_c-stop-list.stop-list-code X_c-stop-list.doc-date usrfulnf(X_c-stop-list.corr-user-name) X_c-stop-list.corr-user-db-num X_c-stop-list.corr-date string(X_c-stop-list.corr-time)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-stop-list
&Scoped-define SELF-NAME BR-c-stop-list
&Scoped-define QUERY-STRING-BR-c-stop-list FOR EACH X_c-stop-list NO-LOCK WHERE        X_c-stop-list.classif-type = {&TABLE_dis-card}      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-c-stop-list OPEN QUERY {&SELF-NAME} FOR EACH X_c-stop-list NO-LOCK WHERE        X_c-stop-list.classif-type = {&TABLE_dis-card}      INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-c-stop-list X_c-stop-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-stop-list X_c-stop-list


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-c-stop-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-lkp b-sch B-Help ~
BR-c-stop-list mark-num
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

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
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
DEFINE QUERY BR-c-stop-list FOR
      X_c-stop-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-stop-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-stop-list Dialog-Frame _FREEFORM
  QUERY BR-c-stop-list NO-LOCK DISPLAY
      mark-string(recid(X_c-stop-list), v-rid-list) COLUMN-LABEL "*" FORMAT "X(2)"
X_c-stop-list.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
X_c-stop-list.doc-date  COLUMN-LABEL "Дата стоплиста" FORMAT "99/99/9999"
usrfulnf(X_c-stop-list.corr-user-name)  COLUMN-LABEL "Изменил" FORMAT "X(20)"
X_c-stop-list.corr-user-db-num  COLUMN-LABEL "БД изм." FORMAT ">>>>9"
X_c-stop-list.corr-date  COLUMN-LABEL "Дата корр." FORMAT "99/99/9999"
string(X_c-stop-list.corr-time)  COLUMN-LABEL "Время корр." FORMAT "HH:MM:SS"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 19 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 61
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-c-stop-list AT ROW 3 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(79.40) SKIP(20.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История стоплистов по ДК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-stop-list B "?" ? ub c-stop-list
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-stop-list B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-stop-list
/* Query rebuild information for BROWSE BR-c-stop-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_c-stop-list NO-LOCK WHERE
       X_c-stop-list.classif-type = {&TABLE_dis-card}
     INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-c-stop-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* История стоплистов по ДК */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История стоплистов по ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_c-stop-list then do:
    { gbl/markstrn.i X_c-stop-list v-rid-list }
    loc#log = br-c-stop-list:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-stop-list:select-next-row ().
        apply "VALUE-CHANGED" to br-c-stop-list in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-stop-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-stop-list ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-stop-list ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-stop-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
/*{ gbl/hot-key.i b-print }*/
{ gbl/setfltnm.i }
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_c-stop-list then v-doc-rec = recid(X_c-stop-list). ~
               run openbr in this-procedure ( input yes, input no, input '':U) no-error. ~
               REPOSITION br-c-stop-list to recid v-doc-rec No-ERROR." }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  ASSIGN
  v-rid-list = p-rid-list.
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF v-rid-list <> '':U THEN DO:
    REPOSITION br-c-stop-list to RECID INTEGER(entry(1, v-rid-list)) NO-ERROR.
    APPLY "entry" to br-c-stop-list.
    APPLY "value-changed" TO br-c-stop-list.
  END.
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
  ENABLE b-quit B-mark B-sel b-lkp b-sch B-Help BR-c-stop-list mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ENABLE
b-quit
B-mark  when lookup("b-mark", bttns) > 0
B-sel when lookup("b-sel", bttns) > 0
b-lkp
b-sch
B-Help
BR-c-stop-list
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
run openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
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

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-c-stop-list FOR EACH X_c-stop-list

&scop flt-open-dyn_open-query FOR EACH X_c-stop-list

&scop flt-open-query-handle query br-c-stop-list:handle

&scop flt-open-query p-open-query

&scop flt-open-find-next p-find-next

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-buffer-name X_c-stop-list

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-search-option no-lock

&scop flt-open-waitfram yes

&scop flt-open-table-name X_c-stop-list
 CASE p-list-mode:
   WHEN {&ALL} THEN DO:
    ASSIGN
    FRAME {&frame-name}:TITLE = substitute("СТОПЛИСТЫ ПО ДК")
      filter-label = filter-label0
      filter-point = filter-point0
      .
      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_c-stop-list.classif-type = ~{&table_dis-card~} ~
                          "
          &dyn_where-cond = " substitute('X_c-stop-list.classif-type = &1&2&1', ~{&double-quote~}, ~{&table_dis-card~}) "

          &use-ind = "  "
          &by = " by X_c-stop-list.stop-list-code descending"
        }
      end.
   END.
   when "one" then do:
    ASSIGN
    FRAME {&frame-name}:TITLE = substitute("ИСТОРИЯ СТОПЛИСТА &1", p-stop-list-code)
      filter-label = filter-label0
      filter-point = filter-point0
      .
      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_c-stop-list.classif-type = ~{&table_dis-card~} ~
                         and X_c-stop-list.stop-list-code = p-stop-list-code ~
                          "
          &dyn_where-cond = " substitute('X_c-stop-list.classif-type = &1&2&1 ~
                         and X_c-stop-list.stop-list-code = &1&3&1 ', ~{&double-quote~}, ~{&table_dis-card~}, p-stop-list-code) "

          &use-ind = "  "
          &by = " by X_c-stop-list.stop-list-code descending"
        }
      end.
   END.

 END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-c-stop-list to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-stop-list:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-c-stop-list in frame {&frame-name}.
APPLY "ENTRY" TO br-c-stop-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAILABLE X_c-stop-list THEN RETURN ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_c-stop-list then recid(X_c-stop-list) else ?)
.
assign
tbl = 'c-stop-list'
join-tbl = 'X_c-stop-list'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('doc-date', 'Дата стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Факт.Дата стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('stop-list-code', 'N стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    RUN OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-c-stop-list to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-c-stop-list in frame {&frame-name} .
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
