&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_c-fin-schet FOR ub.c-fin-schet.
DEFINE BUFFER X_c-fin-schet FOR ub.c-fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории банковских счетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/15/03
Author: Bakhtadze Natalya
Creation date: 10/15/03

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
/*all company cmp currency bank */

define input parameter p-host-code like ub.c-fin-schet.host-code no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo.
define input parameter p-cli-code like ub.clients.obj-code no-undo.
define input parameter p-curr-code like ub.currency.curr-code no-undo.
define input parameter p-code-bank like ub.c-fin-schet.code-bank no-undo.
define input parameter p-code-schet like ub.c-fin-schet.code-schet no-undo.


/*счета в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории банковских счетов":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable filter-point as character no-undo init "fincscts" .
define variable filter-point0 as character no-undo init "fincstcs" .
define variable filter-label as character no-undo init "Список истории банковских счетов" .
define variable filter-label0 as character no-undo init "Список истории банковских счетов" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

define buffer X_curr_sysconf for ub.sysconf.
DEFINE BUFFER X_clients-host FOR ub.clients.

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
&Scoped-define INTERNAL-TABLES temp-changes X_c-fin-schet

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-schet                                      */
&Scoped-define FIELDS-IN-QUERY-br-schet mark-string(recid(X_c-fin-schet), v-rid-list) X_c-fin-schet.host-code X_c-fin-schet.code-schet X_c-fin-schet.code-bank get-bank-short-name(buffer X_c-fin-schet) X_c-fin-schet.cli-type + string(X_c-fin-schet.cli-code) get-cli-name(buffer X_c-fin-schet) X_c-fin-schet.corr-date string(X_c-fin-schet.corr-time, "HH:MM") usrfulnf(X_c-fin-schet.corr-user-name) X_c-fin-schet.status_ X_c-fin-schet.r-schet X_c-fin-schet.c-schet get-currency(buffer X_c-fin-schet)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-schet X_c-fin-schet.status_
&Scoped-define ENABLED-TABLES-IN-QUERY-br-schet X_c-fin-schet
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-schet X_c-fin-schet
&Scoped-define SELF-NAME br-schet
&Scoped-define QUERY-STRING-br-schet FOR EACH X_c-fin-schet NO-LOCK
&Scoped-define OPEN-QUERY-br-schet OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-schet NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-schet X_c-fin-schet
&Scoped-define FIRST-TABLE-IN-QUERY-br-schet X_c-fin-schet


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-lkp B-sch B-Help ~
br-schet ED-notes sch-code sch-c-schet sch-r-schet RS-cli-type sch-cli-code ~
B-cli BR-changes mark-num
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-code sch-c-schet sch-r-schet ~
RS-cli-type sch-cli-code mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-bank-short-name Dialog-Frame
FUNCTION get-bank-short-name RETURNS CHARACTER
  ( BUFFER loc-c-fin-schet FOR ub.c-fin-schet )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
 ( BUFFER loc-c-fin-schet FOR ub.c-fin-schet )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-schet FOR ub.c-fin-schet )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

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

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

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

DEFINE VARIABLE sch-c-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Корр.счету"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "коду держателя"
     VIEW-AS FILL-IN
     SIZE 11 BY .92 NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "коду"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Расч.счету"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RS-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 19.38 BY 1.04 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.

DEFINE QUERY br-schet FOR
      X_c-fin-schet SCROLLING.
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
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.21.

DEFINE BROWSE br-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-schet Dialog-Frame _FREEFORM
  QUERY br-schet DISPLAY
      mark-string(recid(X_c-fin-schet), v-rid-list) FORMAT "X(1)":U
      X_c-fin-schet.host-code COLUMN-LABEL "Код!фирмы" FORMAT "9999999999":U
      X_c-fin-schet.code-schet COLUMN-LABEL "Код счета" FORMAT "9999999":U
      X_c-fin-schet.code-bank COLUMN-LABEL "Код!банка" FORMAT "9999999":U
      get-bank-short-name(buffer X_c-fin-schet) COLUMN-LABEL "Название банка" FORMAT "X(20)":U
      X_c-fin-schet.cli-type + string(X_c-fin-schet.cli-code) COLUMN-LABEL "Держатель!счета" FORMAT "X(12)":U
      get-cli-name(buffer X_c-fin-schet) COLUMN-LABEL "Название держателя счета" FORMAT "X(20)":U
      X_c-fin-schet.corr-date COLUMN-LABEL "Дата корр." FORMAT "99/99/9999":U
      string(X_c-fin-schet.corr-time, "HH:MM") COLUMN-LABEL "Время корр."
      usrfulnf(X_c-fin-schet.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-fin-schet.status_ FORMAT "X(8)":U
      X_c-fin-schet.r-schet COLUMN-LABEL "Р/счет" FORMAT "X(20)":U
      X_c-fin-schet.c-schet COLUMN-LABEL "Коррсчет" FORMAT "X(20)":U
      get-currency(buffer X_c-fin-schet) COLUMN-LABEL "Вал" FORMAT "X(3)":U
  ENABLE
      X_c-fin-schet.status_
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 8.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 41
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-schet AT ROW 2.21 COL 1.38
     ED-notes AT ROW 11.25 COL 1 NO-LABEL
     sch-code AT ROW 13.38 COL 16.25 COLON-ALIGNED
     sch-c-schet AT ROW 13.38 COL 36.63 COLON-ALIGNED
     sch-r-schet AT ROW 13.38 COL 71.13 COLON-ALIGNED
     RS-cli-type AT ROW 14.58 COL 30.13 NO-LABEL
     sch-cli-code AT ROW 14.63 COL 16.13 COLON-ALIGNED
     B-cli AT ROW 14.63 COL 50.5
     BR-changes AT ROW 15.83 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 13.38 COL 1.38
          FGCOLOR 4
     SPACE(88.61) SKIP(7.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список истории банковских счетов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_c-fin-schet B "?" NO-UNDO ub c-fin-schet
      TABLE: X_c-fin-schet B "?" ? ub c-fin-schet
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_currency B "?" ? ub currency
      TABLE: X_fin-bank B "?" ? ub fin-bank
      TABLE: X_fin-schet B "?" ? ub fin-schet
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-schet B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes B-cli Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-schet:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

ASSIGN
       ED-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-schet
/* Query rebuild information for BROWSE br-schet
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-fin-schet NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-schet */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список истории банковских счетов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dialog-Frame
ON CHOOSE OF B-cli IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w ( input parParentProc
                  , input "b-sel"
                  , input RS-cli-type
                  , input ?
                  , input ?
                  , input ?
                  , input ?
                  , input "without-obj":U
                  , output ref-list) .
    if ref-list = "" then   do:
      apply "entry" to b-cli in frame {&frame-name}.
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
    if NOT (buf_clients.obj-type = {&cmp}
            or
            buf_clients.obj-type = {&prs} ) then do:
      message
      "Выберите контрагента типа" {&cmp} "или" {&prs}
      view-as alert-box error .
      return no-apply.
    end.
    assign
    RS-cli-type =  buf_clients.obj-type
    sch-cli-code = buf_clients.obj-code
    .
    display
    RS-cli-type
    sch-cli-code
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc-doc-rec as recid no-undo .
define buffer buf_c-fin-schet for ub.c-fin-schet.
  if NOT available X_c-fin-schet then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  find first buf_c-fin-schet no-lock where
             buf_c-fin-schet.host-code = X_c-fin-schet.host-code
         AND buf_c-fin-schet.code-schet = X_c-fin-schet.code-schet use-index pi no-error .
  if available buf_c-fin-schet and
    recid(buf_c-fin-schet) = recid(X_c-fin-schet) then do:
    message
    "Данная запись истории пуста - т.к. соответствует СОЗДАНИЮ записи банковского счета" skip
    "Просмотр невозможен"
    view-as alert-box .
    return no-apply.
  end.
  assign
  loc-doc-rec = recid (X_c-fin-schet).

  run ref/fincscti.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input {&lookup}
                ,input X_c-fin-schet.host-code
                ,input X_c-fin-schet.code-schet
                ,input X_c-fin-schet.corr-user-db-num
                ,input X_c-fin-schet.chip-num
                ,input-output loc-doc-rec
                              )
  .
  reposition br-schet to recid loc-doc-rec no-error.
  apply "entry" to br-schet in frame {&frame-name}.
  apply "value-changed" to br-schet in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-fin-schet then do:
    { gbl/markstrn.i X_c-fin-schet v-rid-list }
    loc#log = br-schet:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-schet:select-next-row ().
        apply "VALUE-CHANGED" to br-schet in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-schet in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
      run gbl/markqwa.p (
                 input b-mark:sensitive
               , input v-rid-list) no-error.
  if error-status:error then return no-apply.
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


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-fin-schet ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_c-fin-schet ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-schet
&Scoped-define SELF-NAME br-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-schet Dialog-Frame
ON RETURN OF br-schet IN FRAME Dialog-Frame
DO:
    run proc-br-schet no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-schet Dialog-Frame
ON VALUE-CHANGED OF br-schet IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-fin-schet then X_c-fin-schet.ps else '':U.
  ED-notes:screen-value = dops.
run proc-view-changes in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_c-fin-schet for ub.c-fin-schet.
  if not available X_c-fin-schet then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_c-fin-schet where
           recid (ps_c-fin-schet) = recid(X_c-fin-schet) exclusive.
      if ps_c-fin-schet.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_c-fin-schet.PS = input frame {&frame-name} ed-notes
      .
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli-type Dialog-Frame
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-c-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON CTRL-J OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счету */
DO:
  run proc-find-c-schet in this-procedure(yes, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON RETURN OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счету */
DO:
  run proc-find-c-schet in this-procedure(no, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame /* коду держателя */
DO:
  run proc-find-cli-code in this-procedure( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame /* коду держателя */
DO:
  run proc-find-cli-code in this-procedure( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-r-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счету */
DO:
  run proc-find-r-schet in this-procedure (input yes, input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-r-schet Dialog-Frame
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame /* Расч.счету */
DO:
  run proc-find-r-schet in this-procedure ( input no, input frame {&frame-name} sch-r-schet) no-error.
  if error-status:error then return no-apply.
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
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-schet" }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-fin-schet). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-schet to recid v-doc-rec no-error. v-doc-rec = ?. ~
              apply 'value-changed' to br-schet. " }
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "br-schet"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-fin-schet.c-schet"
  &sort-clmn_2    = "X_c-fin-schet.r-schet"
  &sort-clmn_3    = "X_c-fin-schet.corr-date"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

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
 if LOOKUP(p-mode, ({&all} + {&comma-char} +
                    {&company} + {&comma-char} +
                    {&cmp}  + {&comma-char} +
                    "currency":U + {&comma-char} +
                    "bank":U + {&comma-char} + "one":U)) = 0 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code no-error.
if not available X_curr_sysconf then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-curr-host-code"
  p-curr-host-code
  view-as alert-box ERROR.
  return.
end.
 if LOOKUP(p-mode,
                    ({&company} + {&comma-char} +
                    {&cmp}  + {&comma-char} +
                    "currency":U + {&comma-char} +
                    "bank":U + {&comma-char} + "one":U)) = 0 then dO:
  find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code.
  find first X_clients-host no-lock where
                X_clients-host.obj-type = {&cmp}
            and X_clients-host.obj-code = p-host-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code"
        p-host-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = {&cmp} then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-cli-type
            and X_clients.obj-code = p-cli-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-cli-type и/или p-cli-codee" p-cli-type p-cli-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "bank":U then do:
  find first X_fin-bank no-lock where
                X_fin-bank.host-code = p-host-code
            and X_fin-bank.code-bank = p-code-bank no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-host-code и/или p-code-bank" p-host-code p-code-bank
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "currency":U then do:
  find first X_currency no-lock where
                X_currency.curr-code = p-curr-code no-error.
    if not available X_currency then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-code" p-curr-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "one":U then do:
  find first X_fin-schet no-lock where
                X_fin-schet.host-code = p-host-code
            and X_fin-schet.code-schet = p-code-schet no-error.
    if not available X_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code и/или p-code-schet "
        p-host-code p-code-schet
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-fin-schet No-LOCK where
                 recid(find_c-fin-schet) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-schet to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-schet"
    &frame-name = "{&frame-name}"
    &ext-col = 14
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,3,4,5,6,7,8,9,10,11,12,13,14,2'"
    &prev-order-column-condition_2 = " p-mode = {&company} "
    &prev-order-column_3 = "'1,2,3,4,5,8,9,10,11,12,13,14,6,7'"
    &prev-order-column-condition_3 = " p-mode = {&cmp} "
    &prev-order-column_4 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14'"
    &prev-order-column-condition_4 = " p-mode = 'currency':U "
    &prev-order-column_5 = "'1,2,3,6,7,8,9,10,11,12,13,14,4,5'"
    &prev-order-column-condition_5 = " p-mode = 'bank':U "
    &prev-order-column_6 = "'1,8,9,10,11,2,3,4,5,6,7,12,13,14,2,3'"
    &prev-order-column-condition_6 = " p-mode = 'one':U "
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
  DISPLAY ED-notes sch-code sch-c-schet sch-r-schet RS-cli-type sch-cli-code
          mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-lkp B-sch B-Help br-schet ED-notes sch-code
         sch-c-schet sch-r-schet RS-cli-type sch-cli-code B-cli BR-changes
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
  br-schet:num-locked-columns in frame {&frame-name}  = 1
  X_c-fin-schet.status_:read-only in browse br-schet = yes
  RS-cli-type:radio-buttons = {&CMp} + {&comma-char} + {&cmp} + {&comma-char} + {&prs} + {&comma-char} + {&prs}
  temp-changes.l_name:resizable in browse br-changes = true
  temp-changes.v_old:resizable in browse br-changes = true
  temp-changes.v_new:resizable in browse br-changes = true
  temp-changes.l_name:width in browse br-changes = 30
  temp-changes.v_old:width in browse br-changes = 40
  temp-changes.v_new:width in browse br-changes = 40
  .
  .
  DISPLAY
  ED-notes
  sch-code
  sch-c-schet
  sch-r-schet
  sch-cli-code
  mark-num
  RS-cli-type
  WITH FRAME {&frame-name} .
  ENABLE
  b-quit
  B-mark when lookup("b-mark":U, bttns) > 0
  b-sel when lookup("b-sel":U, bttns) > 0
  b-lkp
  B-sch
  b-cli
  B-Help
  br-schet
  br-changes
  ED-notes
  sch-code
  sch-cli-code
  sch-c-schet
  sch-r-schet
  RS-cli-type
  mark-num
  WITH FRAME {&frame-name} .
  VIEW FRAME {&frame-name} .
  APPLY "VALUE-changed" to RS-cli-type.
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
title0 = "Список банковских счетов" + {&space-char}.
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

&scop flt-open-open-query OPEN QUERY br-schet FOR EACH X_c-fin-schet

&scop flt-open-dyn_open-query FOR EACH X_c-fin-schet

&scop flt-open-query-handle QUERY br-schet:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-fin-schet

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-fin-schet

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
     { gbl/fltopend.i
        &where-cond = " TRUE "
        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN {&company} THEN DO:

       ASSIGN
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 Одна фирма", filter-label0)
       .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2",
                                    p-host-code, X_clients-host.obj-name).
      end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-fin-schet.host-code  = p-host-code    ~
                      "
        &dyn_where-cond = " substitute(' X_c-fin-schet.host-code  = &1', p-host-code ) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN {&cmp} THEN DO:

       ASSIGN
       filter-point = filter-point0 + p-mode
       filter-label = substitute("&1 Один контрагент", filter-label0)
       .
       if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Контрагент: (&1&2) &3",
                                      X_clients.obj-type, X_clients.obj-code, X_clients.obj-name).
       end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-fin-schet.cli-type  = p-cli-type AND X_c-fin-schet.cli-code  = p-cli-code     ~
                      "
        &dyn_where-cond = " substitute(' X_c-fin-schet.cli-type  = &1&2&1 AND X_c-fin-schet.cli-code  = &3 ', {&double-quote}, p-cli-type, p-cli-code ) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "currency" THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна фирма, одна валюта", filter-label0)
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                   substitute(" Фирма (&1) &2 Валюта: (&3) &4",
                                    p-host-code, X_clients-host.obj-name, X_currency.curr-code, X_currency.curr-abbr).
      end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-fin-schet.host-code  = p-host-code AND X_c-fin-schet.curr-code  = p-curr-code     ~
                      "
        &dyn_where-cond = " substitute(' X_c-fin-schet.host-code  = &1 AND X_c-fin-schet.curr-code  = &2  ', p-host-code, p-curr-code )  "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "bank" THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна фирма, один банк", filter-label0)
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                   substitute(" Фирма (&1) &2 Банк: &3",
                                    p-host-code, X_clients-host.obj-name, X_fin-bank.short-name)
        .
      end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-fin-schet.host-code  = p-host-code AND X_c-fin-schet.code-bank  = p-code-bank     ~
                      "
        &dyn_where-cond = " substitute(' X_c-fin-schet.host-code  = &1 AND X_c-fin-schet.code-bank  = &2 ', p-host-code, p-code-bank) "

        &use-ind    = "  "
        &by         = "  " }
    END.
    WHEN "one":u THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна фирма, один банк.счет", filter-label0)
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                   substitute(" Банковский счет: (Фирма (&1) &2",
                                    X_fin-schet.host-code, X_fin-schet.code-schet)
        .
      end.
      { gbl/fltopend.i
        &where-cond = " ~
          X_c-fin-schet.host-code  = p-host-code AND X_c-fin-schet.code-schet = p-code-schet   ~
                      "
        &dyn_where-cond = " substitute(' X_c-fin-schet.host-code  = &1 AND X_c-fin-schet.code-schet = &2 ', p-host-code, p-code-schet) "

        &use-ind    = "  "
        &by         = "  " }
    END.


END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-schet to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-schet:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-schet in frame {&frame-name}.
APPLY "ENTRY" TO br-schet.
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
  tbl = 'c-fin-schet'
  join-tbl = 'X_c-fin-schet'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('code-schet', 'Код в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('code-bank', 'Код банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Держатель счета', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('c-schet', 'Коррсчет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('r-schet', 'Р/Счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dop1', 'Доп к назв.держ.счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dop2', 'Доп к назв.банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-schet Dialog-Frame
PROCEDURE proc-br-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-c-schet Dialog-Frame
PROCEDURE proc-find-c-schet :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-c-schet like ub.c-fin-schet.c-schet no-undo.
display
"0":U @ sch-code
"0":U @ sch-cli-code
"":U @ sch-r-schet
with frame {&frame-name}.
assign
p-c-schet = replace(p-c-schet, {&double-quote}, "":U)
p-c-schet = replace(p-c-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-c-schet = {&double-quote} + p-c-schet + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-schet.c-schet   begins &1 "
      , p-c-schet)
    ).
apply "entry":u to sch-c-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-cli-code Dialog-Frame
PROCEDURE proc-find-cli-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.c-fin-schet.cli-code no-undo.
define variable v-cli-code as character no-undo.
assign
frame {&frame-name} RS-cli-type .
display
"":U @ sch-c-schet
"":U @ sch-r-schet
0 @ sch-code
with frame {&frame-name}.
assign
v-cli-code = string(p-cli-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-schet.cli-type = '&1' and X_c-fin-schet.cli-code = &2"
      , RS-cli-type, v-cli-code )
    ).
apply "entry":u to sch-cli-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-next as logical no-undo.
define input parameter p-code-schet like ub.c-fin-schet.code-schet no-undo.
define variable v-code-schet as character no-undo.
display
"0":U @ sch-cli-code
"":U @ sch-c-schet
"":U @ sch-r-schet
with frame {&frame-name}.
assign
v-code-schet = string(p-code-schet).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-schet.code-schet = &1 "
      , v-code-schet)
    ).
apply "entry":u to sch-code in frame {&frame-name} .


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
define input parameter p-r-schet as character no-undo.
display
"0":U @ sch-code
"0":U @ sch-cli-code
"":U @ sch-c-schet
with frame {&frame-name}.
assign
p-r-schet = replace(p-r-schet, {&double-quote}, "":U)
p-r-schet = replace(p-r-schet, {&single-quote}, {&single-quote} + {&single-quote})
p-r-schet = {&double-quote} + p-r-schet + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and X_c-fin-schet.r-schet   begins &1 "
      , p-r-schet)
    ).
apply "entry":u to sch-r-schet in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-fin-schet then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
&scop fields-name-list  "c-schet,cli-code,cli-type,code-bank,code-schet,curr-code,dop1,dop2,host-code,r-schet,PS"
define variable v-label-param as character no-undo .

v-label-param =
  "c-schet" + {&delim-par} + "Корр.счет" + {&delim-par} + "" + {&delim-flf}
 + "cli-code" + {&delim-par} + "Код держателя" + {&delim-par} + "" + {&delim-flf}
 + "cli-type" + {&delim-par} + "Тип держателя" + {&delim-par} + "" + {&delim-flf}
 + "code-bank" + {&delim-par} + "Вн.Код банка" + {&delim-par} + "" + {&delim-flf}
 + "code-schet" + {&delim-par} + "Вн.код счета" + {&delim-par} + "" + {&delim-flf}
 + "curr-code" + {&delim-par} + "Код валюты" + {&delim-par} + "" + {&delim-flf}
 + "dop1" + {&delim-par} + "Дополн.к назв.держ.счета" + {&delim-par} + "" + {&delim-flf}
 + "dop2" + {&delim-par} + "Дополн.к назв.банка" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "r-schet" + {&delim-par} + "Расч. счет" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечания" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-fin-schet:handle
                                            ,input  {&table_fin-schet}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-bank-short-name Dialog-Frame
FUNCTION get-bank-short-name RETURNS CHARACTER
  ( BUFFER loc-c-fin-schet FOR ub.c-fin-schet ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_fin-bank for ub.fin-bank.

find first buf_fin-bank no-lock where
            buf_fin-bank.code-bank = loc-c-fin-schet.code-bank
                AND    buf_fin-bank.host-code = loc-c-fin-schet.host-code  no-error.
if available buf_fin-bank then
RETURN (if buf_fin-bank.short-name <> "":U then buf_fin-bank.short-name else buf_fin-bank.bank-name).   /* Function return value. */
return (string(loc-c-fin-schet.host-code) + string(loc-c-fin-schet.code-bank)).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
 ( BUFFER loc-c-fin-schet FOR ub.c-fin-schet ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.

find first buf_clients no-lock where
            buf_clients.obj-type = loc-c-fin-schet.cli-type
                AND    buf_clients.obj-code = loc-c-fin-schet.cli-code  no-error.
if available buf_clients then
RETURN (buf_clients.obj-name).   /* Function return value. */
return (loc-c-fin-schet.cli-type + string(loc-c-fin-schet.cli-code)).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-schet FOR ub.c-fin-schet ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_currency for ub.currency.

find first buf_currency no-lock where
            buf_currency.curr-code = loc-c-fin-schet.curr-code no-error.
if available buf_currency then
  RETURN buf_currency.curr-abbr.   /* Function return value. */
return string(loc-c-fin-schet.curr-code).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME