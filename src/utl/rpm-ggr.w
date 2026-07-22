&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Соответствие групп товаров в TH и RPM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/09
Author: Bakhtadze Natalya
Creation date: 02/17/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Соответствие групп товаров в TH и RPM".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/mrk-strf.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/fltopend.i defproc }

define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "rpm-ggr".
define variable filter-label     as character NO-UNDO INIT "Соответствие групп товаров в TH и RPM".
define variable filter-point0     as character NO-UNDO INIT "rpm-ggr".
define variable filter-label0     as character NO-UNDO INIT "Соответствие групп товаров в TH и RPM".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-closed as character no-undo .
define variable v-type as character no-undo .
define variable v-attr-code as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-gds-grp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif

/* Definitions for BROWSE br-gds-grp                                    */
&Scoped-define FIELDS-IN-QUERY-br-gds-grp mark-string(recid(X_ext-classif), v-rid-list) entry(2, X_ext-classif.uniq-key-rec, {&delim-key}) X_ext-classif.charKEy_one X_ext-classif.KEY#_one X_ext-classif.KEY#_two X_ext-classif.KEY#_three X_ext-classif.charkey_two
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-gds-grp
&Scoped-define SELF-NAME br-gds-grp
&Scoped-define QUERY-STRING-br-gds-grp FOR EACH X_ext-classif NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-gds-grp OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-gds-grp X_ext-classif
&Scoped-define FIRST-TABLE-IN-QUERY-br-gds-grp X_ext-classif


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-gds-grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-sch b-print B-Help ~
br-gds-grp mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-node-code Dialog-Frame
FUNCTION get-cli-node-code RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-node-name Dialog-Frame
FUNCTION get-cli-node-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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

DEFINE BUTTON b-print
     LABEL "&Печать"
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
DEFINE QUERY br-gds-grp FOR X_ext-classif SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gds-grp Dialog-Frame _FREEFORM
  QUERY br-gds-grp NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
entry(2, X_ext-classif.uniq-key-rec, {&delim-key}) COLUMN-LABEL "Вн.код!группы(TH)" FORMAT "X(9)"
X_ext-classif.charKEy_one  COLUMN-LABEL "Группа!RPM" FORMAT "X(5)"
X_ext-classif.KEY#_one  COLUMN-LABEL "Отдел!RPM" FORMAT ">>>>>>>>9"
X_ext-classif.KEY#_two  COLUMN-LABEL "Класс!RPM" FORMAT ">>>>>>>>9"
X_ext-classif.KEY#_three  COLUMN-LABEL "Подкласс!RPM" FORMAT ">>>>>>>>9"
X_ext-classif.charkey_two COLUMN-LABEL "Название группы" FORMAT "X(255)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19.4 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-sch AT ROW 1 COL 89 WIDGET-ID 12
     b-print AT ROW 1 COL 92 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     br-gds-grp AT ROW 2.87 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_ext-classif B "?" ? ub ext-classif
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-gds-grp B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-gds-grp
/* Query rebuild information for BROWSE br-gds-grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ext-classif NO-LOCK
INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-gds-grp FOR X_ext-classif SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-gds-grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
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
  if available X_ext-classif then do:
    { gbl/markstrn.i X_ext-classif v-rid-list }
    loc#log = br-gds-grp:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-gds-grp:select-next-row ().
        apply "VALUE-CHANGED" to br-gds-grp in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-gds-grp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
    if ( available X_ext-classif ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_ext-classif ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gds-grp
&Scoped-define SELF-NAME br-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gds-grp Dialog-Frame
ON VALUE-CHANGED OF br-gds-grp IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_ext-classif THEN DO:

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
{ gbl/setfltnm.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }


{ gbl/brwrefre.i "if available X_ext-classif then v-doc-rec = recid(X_ext-classif). ~
run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error. reposition br-gds-grp to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-gds-grp ." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-sch b-print B-Help br-gds-grp mark-num
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
b-print
b-sch
B-Help
br-gds-grp
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
X_ext-classif.charkey_two:RESIZABLE IN BROWSE br-gds-grp = YES.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.

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

&scop flt-open-debug-file

&scop flt-open-open-query         OPEN QUERY br-gds-grp FOR EACH X_ext-classif

&scop flt-open-dyn_open-query     FOR EACH X_ext-classif no-lock

&scop flt-open-query-handle      QUERY br-gds-grp:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION

&scop flt-open-waitfram yes

filter-point = filter-point0 + p-list-mode .

title0 = "Соответствие групп товаров в разных системах TH".


ASSIGN
frame {&frame-name}:title = substitute("&1", title0)
filter-label = SUBSTITUTE("&1"
                          , frame {&frame-name}:title
                          )
.
{ gbl/fltopend.i
        &where-cond = " X_ext-classif.classif-subject = ~{&table_gds-grp~} ~
                        and X_ext-classif.classif-name = ~{&extclass_gds-grp_rpm~} ~
                        AND X_ext-classif.db-num = - 1"
        &dyn_where-cond = " substitute('X_ext-classif.classif-subject = &1&2&1 ~
                        and X_ext-classif.classif-name = &1&3&1 ~
                        AND X_ext-classif.db-num = - 1', {&double-quote}, ~{&table_gds-grp~}, ~{&extclass_gds-grp_rpm~})"

        &use-ind    = "  "
        &by         = " BY X_ext-classif.charkey_two " }

APPLY "entry" TO br-gds-grp.
if available X_ext-classif then do:
    APPLY "VALUE-CHANGED":U to {&browse-name}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE VARIABLE date_string              as   character no-undo .
DEFINE VARIABLE Line                     as   character no-undo .
DEFINE VARIABLE for-time                 as   character no-undo .
DEFINE VARIABLE accum-count              as   integer   no-undo .
DEFINE VARIABLE accum-count2             as   integer   no-undo .
define variable v-rid                    as   recid no-undo .
define variable v-node-code-chr          as   character no-undo .

DEFINE FRAME list1
v-node-code-chr COLUMN-LABEL "СВОЙ!код группы" FORMAT "X(9)"
X_ext-classif.KEY#_one  COLUMN-LABEL "ЧУЖОЙ!код группы" FORMAT ">>>>>>>>9"
X_ext-classif.charkey_two COLUMN-LABEL "Полное название группы" FORMAT "X(176)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 75 PAGE-NUMBER(PrnLibStream) AT 85 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
v-rid = recid(X_ext-classif).
FORM with FRAME List1.
run waitfram-show in this-procedure ( input "Ждите...").
DO WHILE available X_ext-classif :
   GET prev br-gds-grp.
END.
GET next br-gds-grp.
DO WHILE available X_ext-classif :
  Display STREAM PrnLibStream
  (IF X_ext-classif.uniq-key-rec BEGINS {&table_gds-grp}
  THEN entry(2, X_ext-classif.uniq-key-rec, {&delim-key})
  ELSE '') @ v-node-code-chr
   X_ext-classif.KEY#_one
   X_ext-classif.charkey_two
  with FRAME List1.
  DOWN STREAM PrnLibStream
  1
  with FRAME List1.
  assign
  accum-count = accum-count + 1
  .
  if X_ext-classif.uniq-key-rec <> '' then do:
    accum-count2 = accum-count2 + 1.
  end.
  GET next br-gds-grp.
END.
UNDERLINE  STREAM PrnLibStream
v-node-code-chr
X_ext-classif.KEY#_one
X_ext-classif.charkey_two
with FRAME List1.
DISPLAY STREAM PrnLibStream
accum-count2 @ v-node-code-chr
accum-count @ X_ext-classif.key#_one
with frame List1.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME List1.
output  STREAM PrnLibStream CLOSE.
reposition br-gds-grp to recid v-rid no-error .
apply "ENTRY" to br-gds-grp in frame {&frame-name} .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_ext-classif then recid(X_ext-classif) else ?)
.
assign
tbl = {&table_ext-classif}
join-tbl = 'X_ext-classif'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('charkey_two', 'Назв.узла', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', 'Группа(RPM)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_one', 'Отдел(RPM)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_two', 'Отдел(RPM)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_three', 'Отдел(RPM)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('uniq-key-rec', 'Уникальный ключ записи в своей БД', '',
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
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-gds-grp to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-gds-grp in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-gds-grp.
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-node-code Dialog-Frame
FUNCTION get-cli-node-code RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_gds-grp FOR ub.gds-grp.
if p-uniq-key-rec = '' then return ''.

    RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                        ,INPUT ?
                                        ,INPUT "ub"
                                        ,INPUT ? /*p-bh-handle*/
                                        ,INPUT NO-LOCK
                                        ,OUTPUT v-rowid
                                        ,OUTPUT v-tbl-name) NO-ERROR.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
        error-status :get-message(2)
      view-as alert-box error.
      undo, return error.
    end.

    IF v-rowid = ? THEN RETURN ''.

    FIND FIRST buf_gds-grp NO-LOCK WHERE ROWID(buf_gds-grp) = v-rowid.
    RETURN substitute("&1"
                      ,buf_gds-grp.node-code
                      ).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-node-name Dialog-Frame 
FUNCTION get-cli-node-name RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS CHARACTER ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_gds-grp FOR ub.gds-grp.
if p-uniq-key-rec = '' then return ''.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ? /*p-bh-handle*/
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1)
    error-status :get-message(2)
  view-as alert-box error.
  undo, return error.
end.
IF v-rowid = ? THEN RETURN 'НЕИЗВЕСТНАЯ ГРУППА ТОВАРОВ'.

FIND FIRST buf_gds-grp NO-LOCK WHERE ROWID(buf_gds-grp) = v-rowid.
RETURN buf_gds-grp.node-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

