&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-fin-statement FOR ub.c-fin-statement.
DEFINE BUFFER X_c-fin-statement FOR ub.c-fin-statement.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_fin-statement FOR ub.fin-statement.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории банковских выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/05
Author: Bakhtadze Natalya
Creation date: 08/03/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/

define input parameter p-mode  as char   no-undo .

/*{&all}
"one":U
{&deletion}
"code-schet"
*/
define input parameter p-host-code          like ub.c-fin-statement.host-code no-undo .
define input parameter p-sttm-code          like ub.c-fin-statement.sttm-code no-undo .
define input parameter p-code-schet         like ub.c-fin-statement.code-schet no-undo.

/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список историии банковских выписок":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable filter-label0 as character no-undo init "Список истории выписок" .
define variable filter-label as character no-undo init "Список истории выписок" .
define variable filter-point0 as character no-undo init "finсstts" .
define variable filter-point as character no-undo init "finсstts" .
define variable sort-column-name as character no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-for-title as character no-undo.

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
define buffer X_curr_sysconf for ub.sysconf.

{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-fin-statement

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-fin-statement temp-changes

/* Definitions for BROWSE br-c-fin-statement                            */
&Scoped-define FIELDS-IN-QUERY-br-c-fin-statement mark-string(recid(X_c-fin-statement), v-rid-list) X_c-fin-statement.host-code X_c-fin-statement.prn-doc-code X_c-fin-statement.corr-date string(X_c-fin-statement.corr-time, "HH:MM:SS") usrfulnf(X_c-fin-statement.corr-user-name) X_c-fin-statement.fins-ext-doc-type X_c-fin-statement.code-schet X_c-fin-statement.start-date X_c-fin-statement.end-date X_c-fin-statement.status_ X_c-fin-statement.bank-date X_c-fin-statement.fact-date X_c-fin-statement.sum-doc X_c-fin-statement.cli-name get-currency(buffer X_c-fin-statement) X_c-fin-statement.sttm-code X_c-fin-statement.cl-bank
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-fin-statement X_c-fin-statement.prn-doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-br-c-fin-statement X_c-fin-statement
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-c-fin-statement X_c-fin-statement
&Scoped-define SELF-NAME br-c-fin-statement
&Scoped-define QUERY-STRING-br-c-fin-statement FOR EACH X_c-fin-statement NO-LOCK
&Scoped-define OPEN-QUERY-br-c-fin-statement OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-statement NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-c-fin-statement X_c-fin-statement
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-fin-statement X_c-fin-statement


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-lookup B-schet B-print ~
B-sch B-Help br-c-fin-statement ED-notes sch-prn-doc-code sch-doc-date ~
sch-fact-date sch-bank-date sch-r-schet sch-curr-code B-curr sch-BIK ~
BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-prn-doc-code sch-doc-date ~
sch-fact-date sch-bank-date sch-r-schet sch-curr-code sch-BIK mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-statement FOR ub.c-fin-statement )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-schet
     LABEL "&Счет"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-bank-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате банка."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "коду вал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE sch-doc-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате док-та"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-fact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате факт."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE sch-prn-doc-code AS CHARACTER FORMAT "X(22)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(35)":U
     LABEL "Расч.счет"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-fin-statement FOR
      X_c-fin-statement SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-fin-statement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-fin-statement Dialog-Frame _FREEFORM
  QUERY br-c-fin-statement DISPLAY
      mark-string(recid(X_c-fin-statement), v-rid-list) FORMAT "X(1)":U
WIDTH 2
X_c-fin-statement.host-code COLUMN-LABEL "Код!фирмы" FORMAT "99999":U
X_c-fin-statement.prn-doc-code FORMAT "X(22)":U
X_c-fin-statement.corr-date FORMAT "99/99/9999" COLUMN-LABEL "Дата измен."
string(X_c-fin-statement.corr-time, "HH:MM:SS") FORMAT "X(8)" COLUMN-LABEL "Время"
usrfulnf(X_c-fin-statement.corr-user-name) FORMAT "X(18)" COLUMN-LABEL "Изменил"
X_c-fin-statement.fins-ext-doc-type COLUMN-LABEL "Расш.тип" FORMAT "X(8)":U
X_c-fin-statement.code-schet COLUMN-LABEL "Вн.№счета"
X_c-fin-statement.start-date FORMAT "99/99/9999":U COLUMN-LABEL "С"
X_c-fin-statement.end-date FORMAT "99/99/9999":U COLUMN-LABEL "По"
X_c-fin-statement.status_ FORMAT "X(8)":U
X_c-fin-statement.bank-date COLUMN-LABEL "Дата банка!(пост.из банка)" FORMAT "99/99/9999":U
X_c-fin-statement.fact-date FORMAT "99/99/9999":U
X_c-fin-statement.sum-doc FORMAT "->,>>>,>>>,>>>,>>9.99":U
X_c-fin-statement.cli-name COLUMN-LABEL "Название держателя счета" FORMAT "X(255)":U WIDTH 20
get-currency(buffer X_c-fin-statement) COLUMN-LABEL "Вал" FORMAT "X(3)":U
X_c-fin-statement.sttm-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
X_c-fin-statement.cl-bank COLUMN-LABEL "Кл-банк" FORMAT "X(8)"
ENABLE
X_c-fin-statement.prn-doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 9.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     B-schet AT ROW 1 COL 41
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-c-fin-statement AT ROW 2.03 COL 1.4
     ED-notes AT ROW 11.27 COL 1 NO-LABEL
     sch-prn-doc-code AT ROW 13.27 COL 16 COLON-ALIGNED
     sch-doc-date AT ROW 13.27 COL 38.1 COLON-ALIGNED
     sch-fact-date AT ROW 13.27 COL 62 COLON-ALIGNED
     sch-bank-date AT ROW 13.27 COL 86 COLON-ALIGNED
     sch-r-schet AT ROW 14.33 COL 75 COLON-ALIGNED
     sch-curr-code AT ROW 14.63 COL 9 COLON-ALIGNED
     B-curr AT ROW 14.63 COL 15.5
     sch-BIK AT ROW 14.63 COL 27.5 COLON-ALIGNED
     BR-changes AT ROW 16.03 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 13.27 COL 1
     SPACE(89.89) SKIP(7.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список выписок"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-fin-statement B "?" NO-UNDO ub c-fin-statement
      TABLE: X_c-fin-statement B "?" ? ub c-fin-statement
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_fin-statement B "?" ? ub fin-statement
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-fin-statement B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes sch-BIK Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-c-fin-statement:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-fin-statement
/* Query rebuild information for BROWSE br-c-fin-statement
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-statement NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-c-fin-statement */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Список выписок */
DO:
  run gbl/markqwa.p (
                        input b-mark:sensitive
                      , input v-rid-list) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список выписок */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-curr Dialog-Frame
ON CHOOSE OF B-curr IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable rr as recid no-undo.
define buffer buf_currency for ub.currency.
    rr = ? .
    run ref/currency.w (
                        input parparentproc
                       ,input "b-sel"
                       ,input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
            recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ sch-curr-code
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
if not available X_c-fin-statement then return no-apply.
run proc-b-lookup in this-procedure no-error.
if error-status:error then do:
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-fin-statement then do:
    { gbl/markstrn.i X_c-fin-statement v-rid-list }
    loc#log = br-c-fin-statement:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-fin-statement:select-next-row ().
        apply "VALUE-CHANGED" to br-c-fin-statement in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-fin-statement in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-print-list in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-c-fin-statement.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-schet Dialog-Frame
ON CHOOSE OF B-schet IN FRAME Dialog-Frame /* Счет */
DO:
define variable loc-doc-rec as recid no-undo.
if not available X_c-fin-statement then return no-apply.

if X_c-fin-statement.code-schet = 0 then do:
  message
  "Для данного среза истории счет еще не был оперделен"
  view-as alert-box .
  return no-apply.
end.

run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code /*p-curr-host-code*/
                ,input {&lookup}
                ,input X_c-fin-statement.host-code
                ,input X_c-fin-statement.code-schet  /*p-code-schet*/
                ,input X_c-fin-statement.code-bank /*code-bank*/
                ,input {&cmp}
                ,input X_c-fin-statement.host-code
                ,input X_c-fin-statement.curr-code
                ,input-output loc-doc-rec
                            )
.
 APPLY "ENTRY" to br-c-fin-statement.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-fin-statement ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-fin-statement ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-fin-statement
&Scoped-define SELF-NAME br-c-fin-statement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-fin-statement Dialog-Frame
ON RETURN OF br-c-fin-statement IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-fin-statement IN FRAME Dialog-Frame
DO:
  run proc-br-c-fin-statement no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-fin-statement Dialog-Frame
ON VALUE-CHANGED OF br-c-fin-statement IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-fin-statement then X_c-fin-statement.ps else '':U.
  ED-notes:screen-value = dops.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&Scoped-define SELF-NAME BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-changes Dialog-Frame
ON VALUE-CHANGED OF BR-changes IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-fin-statement then X_c-fin-statement.ps else '':U.
  ED-notes:screen-value = dops.
  run proc-view-changes in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_c-fin-statement for ub.c-fin-statement.
  if not available X_c-fin-statement then return no-apply.

   DO on stop undo, return no-apply:
      FIND PS_c-fin-statement where
           recid (ps_c-fin-statement) = recid(X_c-fin-statement) exclusive.
      if ps_c-fin-statement.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_c-fin-statement.PS = input frame {&frame-name} ed-notes
      .
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-bank-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-bank-date Dialog-Frame
ON CTRL-J OF sch-bank-date IN FRAME Dialog-Frame /* Дате банка. */
DO:
  run proc-find-date in this-procedure ( input no
                                       , input frame {&frame-name} sch-bank-date
                                       , input "bank-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-bank-date Dialog-Frame
ON RETURN OF sch-bank-date IN FRAME Dialog-Frame /* Дате банка. */
DO:
  run proc-find-date in this-procedure ( input yes
                                       , input frame {&frame-name} sch-bank-date
                                       , input "bank-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-BIK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure (  input yes
                                       , input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-BIK Dialog-Frame
ON RETURN OF sch-BIK IN FRAME Dialog-Frame /* БИК */
DO:
  run proc-find-bik in this-procedure ( input no
                                      , input frame {&frame-name} sch-bik) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-curr-code Dialog-Frame
ON CTRL-J OF sch-curr-code IN FRAME Dialog-Frame /* коду вал */
DO:
  run proc-find-curr-code in this-procedure ( input yes
                                            , input frame {&frame-name} sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-curr-code Dialog-Frame
ON RETURN OF sch-curr-code IN FRAME Dialog-Frame /* коду вал */
DO:
   run proc-find-curr-code in this-procedure ( input no
                                             , input frame {&frame-name} sch-curr-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-doc-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-doc-date Dialog-Frame
ON CTRL-J OF sch-doc-date IN FRAME Dialog-Frame /* Дате док-та */
DO:
   run proc-find-date in this-procedure ( input yes
                                        , input frame {&frame-name} sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-doc-date Dialog-Frame
ON RETURN OF sch-doc-date IN FRAME Dialog-Frame /* Дате док-та */
DO:
  run proc-find-date in this-procedure ( input no
                                       , input frame {&frame-name} sch-doc-date
                                       , input "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact-date Dialog-Frame
ON CTRL-J OF sch-fact-date IN FRAME Dialog-Frame /* Дате факт. */
DO:
  run proc-find-date in this-procedure ( input yes
                                       , input frame {&frame-name} sch-fact-date
                                       , input "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact-date Dialog-Frame
ON RETURN OF sch-fact-date IN FRAME Dialog-Frame /* Дате факт. */
DO:
   run proc-find-date in this-procedure ( input no
                                        , input frame {&frame-name} sch-fact-date
                                        , input "fact-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-prn-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-prn-doc-code Dialog-Frame
ON CTRL-J OF sch-prn-doc-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-prn-doc-code in this-procedure ( input yes
                                               , input frame {&frame-name} sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-prn-doc-code Dialog-Frame
ON RETURN OF sch-prn-doc-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-prn-doc-code in this-procedure ( input no
                                               , input frame {&frame-name} sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-r-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счет */
DO:
  run proc-find-r-schet in this-procedure ( input yes
                                          , input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счет */
DO:
  run proc-find-r-schet in this-procedure ( input no
                                          , input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-fin-statement
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "br-c-fin-statement"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-fin-statement.prn-doc-code"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure (  input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(X_c-fin-statement). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-c-fin-statement to recid v-doc-rec no-error. v-doc-rec = ?. " }

{ gbl/ed_date.i sch-doc-date }
{ gbl/ed_date.i sch-bank-date }
{ gbl/ed_date.i sch-fact-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  run Mainproc in this-procedure no-error .
  if error-status:error then return error .
  RUN MyEnable in this-procedure .
  RUn OpenBR  in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-c-fin-statement to recid v-doc-rec No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-c-fin-statement"
    &frame-name = "{&frame-name}"
    &ext-col = 18
    &start-column = 1
    &prev-order-column_1 = "'2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,2'"
    &prev-order-column-condition_2 = " p-mode = ~{&company~} "
    &prev-order-column_3 = "'1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,8'"
    &prev-order-column-condition_3 = " p-mode = 'code-schet' "
    &prev-order-column_3 = "'1,3,4,5,6,9,10,11,12,13,14,15,16,17,18,2,7,8'"
    &prev-order-column-condition_3 = " p-mode = 'one' "

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
  DISPLAY ED-notes sch-prn-doc-code sch-doc-date sch-fact-date sch-bank-date
          sch-r-schet sch-curr-code sch-BIK mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lookup B-schet B-print B-sch B-Help
         br-c-fin-statement ED-notes sch-prn-doc-code sch-doc-date
         sch-fact-date sch-bank-date sch-r-schet sch-curr-code B-curr sch-BIK
         BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc Dialog-Frame
PROCEDURE MainProc :
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code no-error.
if not available X_curr_sysconf then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-curr-host-code"
  p-curr-host-code
  view-as alert-box ERROR.
  return error .
end.
if LOOKUP(p-mode, ({&all} + {&delim-par} +
                "code-schet":U + {&delim-par} +
                "one":U + {&delim-par} +
                "deletion":U ),
                {&delim-par}) = 0
  then dO:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметров вызова p-mode"
  p-mode
  view-as alert-box ERROR.
  return error .
end.

find first X_clients-host no-lock where
            X_clients-host.obj-type = {&cmp}
        and X_clients-host.obj-code = p-host-code no-error.
if not available X_clients-host then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code"
    p-host-code
    view-as alert-box ERROR.
    return error .
end.

if LOOKUP("one":U, p-mode, {&delim-par}) > 0 then do:
  find first X_fin-statement no-lock where
              X_fin-statement.host-code = p-host-code
          AND X_fin-statement.sttm-code = p-sttm-code no-error .
  if not available X_fin-statement then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code и/или p-sttm-code"
    p-host-code p-sttm-code
    view-as alert-box ERROR.
    return.
  end.
end.

if LOOKUP(p-mode, "code-schet":U, {&delim-par}) > 0 then do:
  find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code no-error.
  if not available X_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code"
    p-host-code
    view-as alert-box ERROR.
    return error .
  end.
end.

if lookup(p-mode
        , "code-schet":U
        , {&delim-par}) > 0 then do:
  find first X_fin-schet no-lock where
            X_fin-schet.host-code = p-curr-host-code
        AND  X_fin-schet.code-schet = p-code-schet no-error.
  if not available X_fin-schet then do:
    message
    substitute("Не задан счет для просмотра выписок (вн. код счета &1)", p-code-schet)
    view-as alert-box ERROR.
    return error .
  end.
end.
if lookup(p-mode
        , "code-schet"
        , {&delim-par}) > 0 then do:
  find first X_fin-bank no-lock where
            X_fin-bank.host-code = p-curr-host-code
        AND  X_fin-bank.code-bank = X_fin-schet.code-bank  no-error.
  if not available X_fin-bank then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-code-schet"
      p-code-schet
      view-as alert-box ERROR.
      return error .
  end.
end.
if v-rid-list <> "" then do:
    FIND FIRST find_c-fin-statement No-LOCK where
              recid(find_c-fin-statement) = integer(entry(1, v-rid-list)) No-ERROR.
    if not avail find_c-fin-statement then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова v-rid-list" v-rid-list
      view-as alert-box error .
      return error.
    end.
    v-doc-rec = integer(entry(1, v-rid-list)).
  end.
{ gbl/curdbnum.i v-db-num }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
b-print:MENU-MOUSE in frame {&frame-name} = 1
b-schet:MENU-MOUSE in frame {&frame-name} = 1
br-c-fin-statement:num-locked-columns = 1
X_c-fin-statement.prn-doc-code:read-only in browse br-c-fin-statement = yes
X_c-fin-statement.cli-name:RESIZABLE IN BROWSE br-c-fin-statement = YES
.
DISPLAY
ED-notes
sch-prn-doc-code
sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
sch-r-schet
sch-BIK
mark-num
WITH FRAME {&FRAME-NAME}.
ENABLE
b-quit
B-lookup
b-sel when lookup("b-sel":U, bttns) > 0
B-sch
B-print
B-schet
B-Help
br-c-fin-statement
b-curr
ED-notes
sch-prn-doc-code
sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
sch-r-schet
sch-BIK
mark-num
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable title0 as character no-undo.
define variable v-filter-name as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

title0 = "Список выписок" + {&space-char}.

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


&scop flt-open-open-query OPEN QUERY br-c-fin-statement FOR EACH X_c-fin-statement

&scop flt-open-dyn_open-query FOR EACH X_c-fin-statement

&scop flt-open-query-handle QUERY br-c-fin-statement:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-fin-statement

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-fin-statement

&scop flt-open-waitfram yes



filter-point = filter-point0 + p-mode.
CASE p-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-label = substitute("&1", filter-label0)
    .
    { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }

  END.
  WHEN "one":U        THEN DO:
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + substitute(" Фирма: (&1) &2 Выписка &3 &4",
                                      p-host-code, X_clients-host.obj-name,  X_fin-statement.fins-doc-type, X_fin-statement.prn-doc-code)
      .
    end.
    filter-label = substitute("&1 Одна фирма, одна выписка", filter-label0)
    .


    { gbl/fltopend.i
      &where-cond = " x_c-fin-statement.host-code = p-host-code AND x_c-fin-statement.sttm-code  = p-sttm-code "
      &dyn_where-cond = " substitute('x_c-fin-statement.host-code = &1 AND x_c-fin-statement.sttm-code  = &2 ', p-host-code, p-sttm-code)"
      &use-ind    = "  "
      &by         = "  " }
  END.
  WHEN {&deletion}        THEN DO:
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + substitute(" Фирма: (&1) &2 - Выписки, удаленные в статусе &3",
                                       p-host-code, X_clients-host.obj-name,  {&fact})
      .
    end.
    filter-label = substitute("&1 Одна фирма,  выписки, удаленные в стат.ФАКТ", filter-label0)
                                      .
    { gbl/fltopend.i
      &where-cond = " x_c-fin-statement.host-code = p-host-code AND x_c-fin-statement.is-del = yes "
      &dyn_where-cond = " substitute('x_c-fin-statement.host-code = &1 AND x_c-fin-statement.is-del = yes ', p-host-code)"
      &use-ind    = "  "
      &by         = "  " }
  END.
end case.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-c-fin-statement to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-fin-statement:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-c-fin-statement in frame {&frame-name}.
APPLY "ENTRY" TO br-c-fin-statement.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lookup Dialog-Frame
PROCEDURE proc-b-lookup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable loc-line-rec as recid no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-statement_lookup':U
  {&cntxt-firm}
  X_c-fin-statement.host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}

if not loc#log then return error.

assign
loc-doc-rec = recid(X_c-fin-statement).
CASE X_c-fin-statement.fins-ext-doc-type:
  when '':U
  or when {&FSEDT_standard-sttm}
  then do:
    run ref/fincsti1.w
                  (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input {&lookup}
                        ,input X_c-fin-statement.host-code /*p-host-code*/
                        ,input 0 /*p-sttm-code*/
                        ,input "":U /*p-fins-ext-doc-type*/
                        ,input-output loc-doc-rec
                        ,input-output loc-line-rec
                   )
    .
  end.
END CASE.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  reposition br-c-fin-statement to recid loc-doc-rec no-error.
end.
apply "entry" to br-c-fin-statement in frame {&frame-name}.
apply "value-changed" to br-c-fin-statement in frame {&frame-name}.


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
  tbl = 'c-fin-statement'
  join-tbl = 'X_c-fin-statement'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure ( 'sttm-code', 'Вн.№ выписки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'prn-doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'corr-date', 'Дата изменения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



run fltfield-add in this-procedure ( 'start-date', 'Дата c', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-date', 'Да по', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure ( 'doc-date', 'Дата док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'bank-date', 'Дата платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'num-docs', 'Кол-во док-тов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



run fltfield-add in this-procedure ( 'fins-doc-type', 'Тип документа', 'fins-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'fins-ext-doc-type', 'Расширен. тип документа', 'fins-ext-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'status_', '', 'c-fin-statement-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-doc', 'Вход. ост. в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-doc', 'Исход. ост. в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-rubl', 'Вход. ост. в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-rubl', 'Исход. ост. в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-base', 'Вход. ост. в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-base', 'Исход. ост. в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-doc-th', 'Вход. ост. в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-doc-th', 'Исход. ост. в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-rubl-th', 'Вход. ост. в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-rubl-th', 'Исход. ост. в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-base-th', 'Вход. ост. в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-base-th', 'Исход. ост. в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-doc', 'Обор-т вход. платежей в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-doc', 'Обор-т исход. платежей в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-rubl', 'Обор-т вход. платежей в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-rubl', 'Обор-т исход. платежей нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-base', 'Обор-т вход. платежей в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-base', 'Обор-т исход. платежей баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-doc-th', 'Обор-т вход. платежей в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-doc-th', 'Обор-т исход. платежей в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-rubl-th', 'Обор-т вход. платежей в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-rubl-th', 'Обор-т исход. платежей нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-base-th', 'Обор-т вход. платежей в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-base-th', 'Обор-т исход. платежей баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-doc', 'Оборот в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-rubl', 'Оборот ост. в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-base', 'Оборот ост. в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-doc-th', 'Оборот в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-rubl-th', 'Оборот ост. в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-base-th', 'Оборот ост. в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'num-docs', 'Кол-во платежей', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'num-docs-th', 'Кол-во платежей(по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ( 'code-schet', 'Код счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'code-bank', 'Код банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'bik', 'БИК банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'bank-name', 'Банк', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'r-schet', 'Расч.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'c-schet', 'Корр.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.




Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
               , INPUT (filter-point + {&delim-par} +
                        filter-label + {&delim-par} +
                        string(yes))
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-c-fin-statement Dialog-Frame
PROCEDURE proc-br-c-fin-statement :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-bik Dialog-Frame
PROCEDURE proc-find-bik :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.c-fin-statement.bik no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
with frame {&frame-name}.
display
"":U @ sch-r-schet
with frame {&frame-name} .
assign
p-bik = replace(p-bik, {&double-quote}, "":U)
p-bik = replace(p-bik, {&single-quote}, {&single-quote} + {&single-quote})
p-bik = {&double-quote} + p-bik + {&double-quote}.
run OpenBr in this-procedure
    ( input false /* p-open-query */
     ,input p-next  /* p-find-next  */
     ,input substitute("and X_c-fin-statement.bik   begins &1 "
                      , p-bik)
    ).
apply "entry":u to sch-bik in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-curr-code Dialog-Frame
PROCEDURE proc-find-curr-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-curr-code like ub.c-fin-statement.curr-code no-undo.
define variable v-curr-code-chr as character no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.

display
"":U @ sch-prn-doc-code
"":U @ sch-BIK
sch-doc-date
sch-fact-date
sch-bank-date
"":U @ sch-r-schet
with frame {&frame-name}.
assign
v-curr-code-chr = string(p-curr-code)
.
run OpenBr in this-procedure
    ( input false /* p-open-query */
     ,input p-next  /* p-find-next  */
     ,input substitute("and X_c-fin-statement.curr-code = &1 "
                       , v-curr-code-chr)
    ).
apply "entry":u to sch-curr-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.c-fin-statement.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-BIK
0 @ sch-curr-code
"":U @ sch-prn-doc-code
"":U @ sch-r-schet
with frame {&frame-name}.

CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-bank-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-bank-date
      with frame {&frame-name}.
    end.
    when "fact-date":U then do:
      assign
      sch-doc-date = ?
      sch-bank-date = ?
      .
      display
      sch-doc-date
      sch-bank-date
      with frame {&frame-name}.
    end.
    when "bank-date":U then do:
      assign
      sch-doc-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-doc-date
      with frame {&frame-name}.
    end.
END CASE.

assign
v-date-chr = string(day(p-date)) + {&slash-char} +
                 string(month(p-date)) + {&slash-char} +
                 string(year(p-date)).

CASE p-what-date:
    when "doc-date":U then do:
       run OpenBr in this-procedure
        ( input false /* p-open-query */
         ,input true  /* p-find-next  */
         ,input substitute("and X_c-fin-statement.doc-date = &1 "
                          , v-date-chr)
        ).
      apply "entry":u to sch-doc-date in frame {&frame-name}.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        ( input false /* p-open-query */
         ,input true  /* p-find-next  */
         ,input substitute("and X_c-fin-statement.fact-date = &1 "
                            , v-date-chr)
        ).
      apply "entry":u to sch-fact-date in frame {&frame-name}.
    end.
        when "bank-date":U then do:
       run OpenBr in this-procedure
        ( input false /* p-open-query */
         ,input true  /* p-find-next  */
         ,input substitute("and X_c-fin-statement.bank-date = &1 "
                          , v-date-chr)
        ).
      apply "entry":u to sch-bank-date in frame {&frame-name}.
    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-prn-doc-code Dialog-Frame
PROCEDURE proc-find-prn-doc-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-prn-doc-code like ub.c-fin-statement.prn-doc-code no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.

display
"":U @ sch-BIK
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
"":U @ sch-r-schet
with frame {&frame-name}.

assign
  p-prn-doc-code = replace(p-prn-doc-code, {&single-quote}, {&single-quote} + {&single-quote})
.

run OpenBr in this-procedure
    ( input false /* p-open-query */
     ,input p-next  /* p-find-next  */
     ,input substitute("and X_c-fin-statement.prn-doc-code = '&1'"
                       ,p-prn-doc-code)
    ).
apply "entry":u to sch-prn-doc-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-r-schet Dialog-Frame
PROCEDURE proc-find-r-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-r-schet like ub.fin-schet.r-schet no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
with frame {&frame-name}.
display
"":U @ sch-BIK
with frame {&frame-name}.
assign
p-r-schet = replace(p-r-schet, {&double-quote}, "":U)
p-r-schet = replace(p-r-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-r-schet = {&double-quote} + p-r-schet + {&double-quote}.
run OpenBr in this-procedure
    ( input false /* p-open-query */
     ,input p-next  /* p-find-next  */
     ,input substitute("and X_c-fin-statement.r-schet   begins &1 "
                        , p-r-schet)
    ).
apply "entry":u to sch-r-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame
PROCEDURE proc-print-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-curr-abbr as character no-undo.
DEFINE VARIABLE v-time AS CHARACTER NO-UNDO.

DEFINE FRAME c-fin-statement-list
X_c-fin-statement.prn-doc-code FORMAT "X(22)"
X_c-fin-statement.corr-date FORMAT "99/99/9999" COLUMN-LABEL "Дата измен."
v-time FORMAT "X(8)" COLUMN-LABEL "Время"
X_c-fin-statement.corr-user-name FORMAT "99/99/9999" COLUMN-LABEL "Изменил"
X_c-fin-statement.code-schet COLUMN-LABEL "Вн.№счета"
X_c-fin-statement.start-date FORMAT "99/99/9999":U COLUMN-LABEL "С"
X_c-fin-statement.end-date FORMAT "99/99/9999":U COLUMN-LABEL "По"
X_c-fin-statement.doc-date
X_c-fin-statement.bank-date  COLUMn-LABEL "Дата прин!банком"
X_c-fin-statement.fact-date COLUMn-LABEL "Дата факт"
X_c-fin-statement.status_
X_c-fin-statement.sum-doc
X_c-fin-statement.cli-name COLUMN-LABEL "Назв.!плательщика" FORMAT "X(16)"
v-curr-abbr /*get-currency(buffer X_c-fin-statement) */ COLUMN-LABEL "Вал" FORMAT "X(3)"
X_c-fin-statement.sttm-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
X_c-fin-statement.cl-bank COLUMN-LABEL "Кл-банк"
X_c-fin-statement.host-code COLUMN-LABEL "Код!фирмы"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
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
SPACE(25) ( frame {&frame-name}:title + {&space-char} + "Только отмеченные записи")
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME c-fin-statement-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_c-fin-statement).
DO WHILE available X_c-fin-statement :
  GET prev br-c-fin-statement.
END.
GET next br-c-fin-statement.
DO WHILE available X_c-fin-statement :
  Display STREAM PrnLibStream
  X_c-fin-statement.prn-doc-code
  X_c-fin-statement.corr-date
  STRING(X_c-fin-statement.corr-time, "HH:MM:SS") @ v-time
  X_c-fin-statement.corr-user-name
  X_c-fin-statement.code-schet
  X_c-fin-statement.start-date
  X_c-fin-statement.end-date
  X_c-fin-statement.doc-date
  X_c-fin-statement.bank-date
  X_c-fin-statement.fact-date
  X_c-fin-statement.status_
  X_c-fin-statement.sum-doc
  X_c-fin-statement.cli-name
  get-currency(buffer X_c-fin-statement) @ v-curr-abbr
  X_c-fin-statement.sttm-code
  X_c-fin-statement.cl-bank
  X_c-fin-statement.host-code
  with FRAME c-fin-statement-list .
  DOWN STREAM PrnLibStream 1
  with FRAME c-fin-statement-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-c-fin-statement.
END.
UNDERLINE  STREAM PrnLibStream
X_c-fin-statement.prn-doc-code
X_c-fin-statement.code-schet
X_c-fin-statement.corr-date
v-time
X_c-fin-statement.corr-user-name
X_c-fin-statement.start-date
X_c-fin-statement.end-date
X_c-fin-statement.doc-date
X_c-fin-statement.bank-date
X_c-fin-statement.fact-date
X_c-fin-statement.status_
X_c-fin-statement.sum-doc
X_c-fin-statement.cli-name
v-curr-abbr
X_c-fin-statement.sttm-code
X_c-fin-statement.cl-bank
X_c-fin-statement.host-code
with FRAME c-fin-statement-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_c-fin-statement.host-code
accum-count @ X_c-fin-statement.prn-doc-code
with frame c-fin-statement-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME c-fin-statement-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-c-fin-statement to recid v-doc-rec no-error.
APPLY "entry" to br-c-fin-statement.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                           input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-fin-statement then do:
  Open QUery br-changes for each temp-changes.
  return.
end.


&scop fields-name-list ~
"acc-date,bank-city,bank-date,bank-name,bge-date,bik,c-schet,cl-bank,cli-name,code-bank," + ~
"code-schet,curr-code,doc-date,dop1,dop2,dop3,dop4,end-date,end-sum-base,end-sum-base-th,end-sum-doc,end-sum-doc-th,end-sum-rubl,end-sum-rubl-th," + ~
"fact-date,fins-doc-type,fins-ext-doc-type," + ~
"host-code,in-sum-base,in-sum-base-th,in-sum-doc,in-sum-doc-th,in-sum-rubl,in-sum-rubl-th," + ~
"is-back-date,is-corr,is-del,num-docs,num-docs-th," + ~
"out-sum-base,out-sum-base-th,out-sum-doc,out-sum-doc-th,out-sum-rubl,out-sum-rubl-th," + ~
"prn-doc-code,PS,r-schet,start-date," + ~
"start-sum-base,start-sum-base-th,start-sum-doc,start-sum-doc-th,start-sum-rubl,start-sum-rubl-th," + ~
"status_,sttm-code,sum-base,sum-base-th,sum-doc,sum-doc-th,sum-rubl,sum-rubl-th"

define variable v-label-param as character no-undo .

v-label-param =
  "acc-date" + {&delim-par} + "Дата бухг.проводки" + {&delim-par} + "" + {&delim-flf}
 + "bank-city" + {&delim-par} + "Город банка" + {&delim-par} + "" + {&delim-flf}
 + "bank-date" + {&delim-par} + "Дата подвтерждения банком" + {&delim-par} + "" + {&delim-flf}
 + "bank-name" + {&delim-par} + "Банк" + {&delim-par} + "" + {&delim-flf}
 + "bge-date" + {&delim-par} + "Дата выгрузки в XML" + {&delim-par} + "" + {&delim-flf}
 + "bik" + {&delim-par} + "БИК" + {&delim-par} + "" + {&delim-flf}
 + "c-schet" + {&delim-par} + "Кор.счет" + {&delim-par} + "" + {&delim-flf}
 + "cl-bank" + {&delim-par} + "Клиент-Банк" + {&delim-par} + "" + {&delim-flf}
 + "cli-name" + {&delim-par} + "Держатель счета" + {&delim-par} + "" + {&delim-flf}
 + "code-bank" + {&delim-par} + "Вн.код банка" + {&delim-par} + "" + {&delim-flf}
 + "code-schet" + {&delim-par} + "Вн.№ счета" + {&delim-par} + "" + {&delim-flf}
 + "curr-code" + {&delim-par} + "Код валюты" + {&delim-par} + "" + {&delim-flf}
 + "doc-date" + {&delim-par} + "Дата док-та" + {&delim-par} + "" + {&delim-flf}
 + "dop1" + {&delim-par} + "Допполе1" + {&delim-par} + "" + {&delim-flf}
 + "dop2" + {&delim-par} + "Допполе2" + {&delim-par} + "" + {&delim-flf}
 + "dop3" + {&delim-par} + "Допполе3" + {&delim-par} + "" + {&delim-flf}
 + "dop4" + {&delim-par} + "Допполе4" + {&delim-par} + "" + {&delim-flf}
 + "end-date" + {&delim-par} + "Дата конца" + {&delim-par} + "" + {&delim-flf}
 + "end-sum-base" + {&delim-par} + "Исходящий остаток в баз.ва." + {&delim-par} + "" + {&delim-flf}
 + "end-sum-base-th" + {&delim-par} + "Исходящий остаток в баз.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "end-sum-doc" + {&delim-par} + "Исходящий остаток в вал.счета" + {&delim-par} + "" + {&delim-flf}
 + "end-sum-doc-th" + {&delim-par} + "Исходящий остаток в вал.счета(TH)" + {&delim-par} + "" + {&delim-flf}
 + "end-sum-rubl" + {&delim-par} + "Исходящий остаток в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "end-sum-rubl-th" + {&delim-par} + "Исходящий остаток в нац.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "fact-date" + {&delim-par} + "Дата факт" + {&delim-par} + "" + {&delim-flf}
 + "fins-doc-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "fins-ext-doc-type" + {&delim-par} + "Расширенный тип выписки" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Своя организация (код)" + {&delim-par} + "" + {&delim-flf}
 + "in-sum-base" + {&delim-par} + "Оборот входящий в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "in-sum-base-th" + {&delim-par} + "Оборот входящий в баз.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "in-sum-doc" + {&delim-par} + "Оборот входящий в вал.счета" + {&delim-par} + "" + {&delim-flf}
 + "in-sum-doc-th" + {&delim-par} + "Оборот входящий в вал.счета(TH)" + {&delim-par} + "" + {&delim-flf}
 + "in-sum-rubl" + {&delim-par} + "Оборот входящий в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "in-sum-rubl-th" + {&delim-par} + "Оборот входящий в нац.вал(TH)" + {&delim-par} + "" + {&delim-flf}
 + "is-back-date" + {&delim-par} + "Заднее число" + {&delim-par} + "" + {&delim-flf}
 + "is-corr" + {&delim-par} + "Выписка корректировалась в статусе ФАКТ" + {&delim-par} + "" + {&delim-flf}
 + "is-del" + {&delim-par} + "Выписка удалялась в статусе ФАКТ" + {&delim-par} + "" + {&delim-flf}
 + "num-docs" + {&delim-par} + "Число платежей" + {&delim-par} + "" + {&delim-flf}
 + "num-docs-th" + {&delim-par} + "Число платежей(TH)" + {&delim-par} + "" + {&delim-flf}
 + "out-sum-base" + {&delim-par} + "Оборот исходящий ва баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "out-sum-base-th" + {&delim-par} + "Оборот исходящий в баз.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "out-sum-doc" + {&delim-par} + "Оборот исходящий в вал.счета" + {&delim-par} + "" + {&delim-flf}
 + "out-sum-doc-th" + {&delim-par} + "Оборот исходящий в вал.счета(TH)" + {&delim-par} + "" + {&delim-flf}
 + "out-sum-rubl" + {&delim-par} + "Оборот исходящий в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "out-sum-rubl-th" + {&delim-par} + "Оборот исходящий в нац.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "prn-doc-code" + {&delim-par} + "Внешний Номер" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Доп. инфо" + {&delim-par} + "" + {&delim-flf}
 + "r-schet" + {&delim-par} + "Рас.счет" + {&delim-par} + "" + {&delim-flf}
 + "start-date" + {&delim-par} + "Дата начала" + {&delim-par} + "" + {&delim-flf}
 + "start-sum-base" + {&delim-par} + "Входящий остаток в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "start-sum-base-th" + {&delim-par} + "Входящий остаток в баз.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "start-sum-doc" + {&delim-par} + "Входящий остаток в вал.счета" + {&delim-par} + "" + {&delim-flf}
 + "start-sum-doc-th" + {&delim-par} + "Входящий остаток в вал.счета(TH)" + {&delim-par} + "" + {&delim-flf}
 + "start-sum-rubl" + {&delim-par} + "Входящий остаток в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "start-sum-rubl-th" + {&delim-par} + "Входящий остаток в нац.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "sttm-code" + {&delim-par} + "Вн.№ выписки" + {&delim-par} + "" + {&delim-flf}
 + "sum-base" + {&delim-par} + "Сумма в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-base-th" + {&delim-par} + "Сумма в баз.вал.(TH)" + {&delim-par} + "" + {&delim-flf}
 + "sum-doc" + {&delim-par} + "Сумма в вал.счета" + {&delim-par} + "" + {&delim-flf}
 + "sum-doc-th" + {&delim-par} + "Сумма в вал.счета(TH)" + {&delim-par} + "" + {&delim-flf}
 + "sum-rubl" + {&delim-par} + "Сумма в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-rubl-th" + {&delim-par} + "Сумма в нац.вал.(TH)" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-fin-statement:handle
                                            ,input  {&table_fin-statement}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-statement FOR ub.c-fin-statement ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

 define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
                buf_currency.curr-code = loc-c-fin-statement.curr-code no-error.
    if available buf_currency then return buf_currency.curr-abbr.

  RETURN string(loc-c-fin-statement.curr-code).   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
