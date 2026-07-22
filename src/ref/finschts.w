&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_fin-schet FOR ub.fin-schet.
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

Список банковских счетов

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
/*all company cmp currency bank cmp-host company-host*/

define input parameter p-cli-type like ub.clients.obj-type no-undo.
define input parameter p-cli-code like ub.clients.obj-code no-undo.
define input parameter p-curr-code like ub.currency.curr-code no-undo.
define input parameter p-host-code like ub.fin-schet.host-code no-undo .
define input parameter p-code-bank like ub.fin-schet.code-bank no-undo.

define input-output parameter p-status_ like ub.fin-bank.status_ no-undo .
/*счета в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список банковских счетов":U.
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
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
define variable filter-point as character no-undo init "finschts" .
define variable filter-point0 as character no-undo init "finschts" .
define variable filter-label as character no-undo init "Список банковских счетов" .
define variable filter-label0 as character no-undo init "Список банковских счетов" .

define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
define variable vipiska-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".


define buffer X_curr_sysconf for ub.sysconf.
define buffer X_clients-host for ub.clients.
define buffer pos_fin-schet for ub.fin-schet.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_fin-schet no-lock where ~
                                  recid(pos_fin-schet) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи БАНКОВСКИЙ СЧЕТ" skip~
                            string(if avail pos_fin-schet ~
                                    then  substitute("Код фирмы: &1, вн. код счета &2" ~
                                                    , pos_fin-schet.host-code  ~
                                                    , pos_fin-schet.code-schet) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-schet

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_fin-schet

/* Definitions for BROWSE br-schet                                      */
&Scoped-define FIELDS-IN-QUERY-br-schet mark-string(recid(X_fin-schet), v-rid-list) X_fin-schet.host-code X_fin-schet.code-schet X_fin-schet.code-bank get-bank-short-name(buffer X_fin-schet) X_fin-schet.status_ X_fin-schet.cli-type + string(X_fin-schet.cli-code) get-cli-name(buffer X_fin-schet) X_fin-schet.r-schet X_fin-schet.c-schet get-currency(buffer X_fin-schet)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-schet X_fin-schet.status_
&Scoped-define ENABLED-TABLES-IN-QUERY-br-schet X_fin-schet
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-schet X_fin-schet
&Scoped-define SELF-NAME br-schet
&Scoped-define QUERY-STRING-br-schet FOR EACH X_fin-schet NO-LOCK
&Scoped-define OPEN-QUERY-br-schet OPEN QUERY {&SELF-NAME} FOR EACH X_fin-schet NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-schet X_fin-schet
&Scoped-define FIRST-TABLE-IN-QUERY-br-schet X_fin-schet


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-add b-lkp B-chg B-del ~
B-vipiska B-print B-hist B-sch B-Help B-bank B-copy RS-status_ br-schet ~
ED-notes sch-code sch-c-schet sch-r-schet RS-cli-type B-cli sch-cli-code ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS RS-status_ ED-notes sch-code sch-c-schet ~
sch-r-schet RS-cli-type sch-cli-code mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-bank-short-name Dialog-Frame
FUNCTION get-bank-short-name RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
 ( BUFFER loc-fin-schet FOR ub.fin-schet )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Один"
       MENU-ITEM m_list         LABEL "Список"        .

DEFINE MENU MENU-B-vipiska
       MENU-ITEM m_statement    LABEL "Документы выписки"
       MENU-ITEM m_report       LABEL "Отчет в виде выписки".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-bank
     LABEL "&Банк"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-copy
     LABEL "&Копия"
     SIZE 10 BY 1 TOOLTIP "Скопировать в другие фирмы".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
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

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-vipiska
     LABEL "В&ыписка"
     SIZE 10 BY 1.

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

DEFINE VARIABLE RS-status_ AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-schet FOR
      X_fin-schet SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-schet Dialog-Frame _FREEFORM
  QUERY br-schet DISPLAY
      mark-string(recid(X_fin-schet), v-rid-list) FORMAT "X(1)":U
      X_fin-schet.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>>99999":U
      X_fin-schet.code-schet COLUMN-LABEL "Код счета" FORMAT "9999999":U
      X_fin-schet.code-bank COLUMN-LABEL "Код!банка" FORMAT "9999999":U
      get-bank-short-name(buffer X_fin-schet) COLUMN-LABEL "Название банка" FORMAT "X(20)":U
      X_fin-schet.status_ FORMAT "X(8)":U
      X_fin-schet.cli-type + string(X_fin-schet.cli-code) COLUMN-LABEL "Держатель!счета" FORMAT "X(12)":U
      get-cli-name(buffer X_fin-schet) COLUMN-LABEL "Название держателя счета" FORMAT "X(20)":U
      X_fin-schet.r-schet FORMAT "X(20)":U
      X_fin-schet.c-schet FORMAT "X(20)":U
      get-currency(buffer X_fin-schet) COLUMN-LABEL "Вал" FORMAT "X(3)":U
  ENABLE
      X_fin-schet.status_
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 13.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-vipiska AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-bank AT ROW 2 COL 51
     B-copy AT ROW 2 COL 61
     RS-status_ AT ROW 3 COL 1.5 NO-LABEL
     br-schet AT ROW 4.25 COL 1.38
     ED-notes AT ROW 17.71 COL 1 NO-LABEL
     sch-code AT ROW 19.79 COL 16.38 COLON-ALIGNED
     sch-c-schet AT ROW 19.79 COL 36.75 COLON-ALIGNED
     sch-r-schet AT ROW 19.79 COL 71.25 COLON-ALIGNED
     RS-cli-type AT ROW 20.88 COL 30.5 NO-LABEL
     B-cli AT ROW 20.96 COL 50.75
     sch-cli-code AT ROW 21 COL 16.38 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 19.79 COL 1.5
          FGCOLOR 4
     SPACE(88.49) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список банковских счетов"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_fin-schet B "?" NO-UNDO ub fin-schet
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
/* BROWSE-TAB br-schet RS-status_ Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       B-vipiska:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-vipiska:HANDLE.

ASSIGN
       br-schet:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-schet
/* Query rebuild information for BROWSE br-schet
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_fin-schet NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-schet */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список банковских счетов */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_add-def':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}

if not loc#log then return no-apply.
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code /*p-host-code*/
                ,input {&add-def}
                ,input p-curr-host-code
                ,input 0 /*p-code-schet*/
                ,input (if p-mode = "bank":U
                        then p-code-bank
                        else 0) /*p-code-bank*/
                ,input (if p-mode = {&cmp}
                        or p-mode = "cmp-host":U
                        then p-cli-type
                        else "":U) /*p-cli-type*/
                ,input (if p-mode = {&cmp}
                        or p-mode = "cmp-host":U
                        then p-cli-code
                        else 0) /*p-cli-code*/
                ,input (if p-mode = "currency":U
                        then p-curr-code
                        else 0) /*p-curr-code*/
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input no).
  reposition br-schet to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-schet in frame {&frame-name}.
apply "value-changed" to br-schet in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-bank Dialog-Frame
ON CHOOSE OF B-bank IN FRAME Dialog-Frame /* Банк */
DO:
define variable loc-doc-rec as recid no-undo .
if not available X_fin-schet then return no-apply.
run ref/finbanki.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input {&lookup}
                ,input X_fin-schet.host-code /*p-host-code*/
                ,input X_fin-schet.code-bank /*p-code-bank*/
                ,input-output loc-doc-rec
                            )
.
apply "entry" to br-schet in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .

if not available X_fin-schet then return no-apply.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_add-def':U
  {&cntxt-firm}
  p-curr-host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}

if not loc#log then return no-apply.
assign
loc-doc-rec = recid(X_fin-schet).
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input {&update}
                ,input X_fin-schet.host-code
                ,input X_fin-schet.code-schet
                ,input X_fin-schet.code-bank
                ,input X_fin-schet.cli-type
                ,input X_fin-schet.cli-code
                ,input X_fin-schet.curr-code
                ,input-output loc-doc-rec
                            )  no-error
.
if loc-doc-rec <> ? then do:
  reposition br-schet to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-schet in frame {&frame-name}.
apply "value-changed" to br-schet in frame {&frame-name}.

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
  run ref/cli-all.w (
                   input parParentProc
                  ,input "b-sel"
                  ,input RS-cli-type
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input "without-obj":U
                  ,output ref-list) .
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

apply "return":u to sch-cli-code in frame {&frame-name} .
 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* Копия */
DO:
  run proc-copy in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_fin-schet then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-schet).
  .
  run ref/fincscts.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input X_fin-schet.host-code
                ,input X_fin-schet.cli-type
                ,input X_fin-schet.cli-code
                ,input X_fin-schet.curr-code
                ,input X_fin-schet.code-bank
                ,input X_fin-schet.code-schet
                ,input-output v-rid-list
                              )



  .
  reposition br-schet to recid loc-doc-rec no-error.
  apply "entry" to br-schet in frame {&frame-name}.
  apply "value-changed" to br-schet in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc-doc-rec as recid no-undo .
  if NOT available X_fin-schet then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-schet).
  .
  run ref/finschti.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input {&lookup}
                ,input X_fin-schet.host-code
                ,input X_fin-schet.code-schet
                ,input X_fin-schet.code-bank
                ,input X_fin-schet.cli-type
                ,input X_fin-schet.cli-code
                ,input X_fin-schet.curr-code
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
  if available X_fin-schet then do:
    { gbl/markstrn.i X_fin-schet v-rid-list }
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


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_fin-schet then return no-apply.
  if print-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-schet.
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
  if ( available X_fin-schet ) then dO:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_fin-schet ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-vipiska
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-vipiska Dialog-Frame
ON CHOOSE OF B-vipiska IN FRAME Dialog-Frame /* Выписка */
DO:
  if not avail X_fin-schet then return no-apply.
 if vipiska-option = '':U then do:
        run gbl/pop-up.p ( INPUT self:handle, INPUT no) no-error.
  end.
  if vipiska-option = '':U then return no-apply.
  RUN proc-b-vipiska IN THIS-PROCEDURE ( INPUT vipiska-option ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      vipiska-option = '':U.
      RETURN NO-APPLY.
  END.
  vipiska-option = '':U.
  APPLY "ENTRY" to br-schet.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-schet
&Scoped-define SELF-NAME br-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-schet Dialog-Frame
ON RETURN OF br-schet IN FRAME Dialog-Frame
DO:
   run proc-br-schet in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-schet Dialog-Frame
ON VALUE-CHANGED OF br-schet IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_fin-schet then X_fin-schet.ps else '':U.
  ED-notes:screen-value = dops.
  if not available X_fin-schet
  or not (X_fin-schet.cli-type = {&cmp}
         and
         X_fin-schet.cli-code = X_fin-schet.host-code) then do:
    assign
    menu-item m_statement:sensitive in menu menu-b-vipiska  = no.
  end.
  else do:
    assign
    menu-item m_statement:sensitive in menu menu-b-vipiska  = yes.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-schet for ub.fin-schet.
  if not available X_fin-schet then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_fin-schet where
           recid (ps_fin-schet) = recid(X_fin-schet) exclusive.
      if ps_fin-schet.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_fin-schet.PS = input frame {&frame-name} ed-notes
      .
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список */
DO:
   assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Один */
DO:
   assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_report
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_report Dialog-Frame
ON CHOOSE OF MENU-ITEM m_report /* Отчет в виде выписки */
DO:
   assign
  vipiska-option = 'report':U.
  APPLY "CHOOSE" to b-vipiska  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_statement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_statement Dialog-Frame
ON CHOOSE OF MENU-ITEM m_statement /* Документы выписки */
DO:
   assign
  vipiska-option = 'statement':U.
  APPLY "CHOOSE" to b-vipiska  in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cli-type Dialog-Frame
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
  run proc-find-cli-code in this-procedure ( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-status_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-status_ Dialog-Frame
ON VALUE-CHANGED OF RS-status_ IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-status_
  p-status_ = rs-status_
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input NO) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-c-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON CTRL-J OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счету */
DO:
  run proc-find-c-schet in this-procedure ( input yes, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-c-schet Dialog-Frame
ON RETURN OF sch-c-schet IN FRAME Dialog-Frame /* Корр.счету */
DO:
  run proc-find-c-schet in this-procedure ( input no, input frame {&frame-name} sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame /* коду держателя */
DO:
  run proc-find-cli-code in this-procedure ( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-cli-code Dialog-Frame
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame /* коду держателя */
DO:
  run proc-find-cli-code in this-procedure ( input yes, input frame {&frame-name} sch-cli-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* коду */
DO:
  run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
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
  run proc-find-r-schet in this-procedure ( input yes, input frame {&frame-name} sch-r-schet) no-error.
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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_fin-schet.code-schet"
  &sort-clmn_2    = "X_fin-schet.code-bank"
  &sort-clmn_3    = "X_fin-schet.r-schet"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(X_fin-schet). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-schet to recid v-doc-rec no-error. v-doc-rec = ?. " }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

 if LOOKUP(p-mode, ({&all} + {&comma-char} +
                    {&company} + {&comma-char} +
                    {&cmp}  + {&comma-char} +
                    "currency":U + {&comma-char} + "bank":U) + {&comma-char} +
                    "cmp-host":U + {&comma-char} + "company-host":U) = 0 then dO:
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
  p-mode p-curr-host-code
  view-as alert-box ERROR.
  return.
end.
 if p-mode = {&company} or p-mode = "cmp-host":U or p-mode = "company-host":U then do:
  find first X_sysconf no-lock where
                  X_sysconf.host-code = p-curr-host-code no-error.
  find first X_clients-host no-lock where
                X_clients-host.obj-type = {&cmp}
            and X_clients-host.obj-code = p-curr-host-code no-error.
    if not available X_clients-host then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code"
        p-host-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = {&cmp} or p-mode = "cmp-host":U then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-cli-type
            and X_clients.obj-code = p-cli-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-cli-type и/или p-cli-code" p-cli-type p-cli-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "bank":U then do:
  find first X_fin-bank no-lock where
                X_fin-bank.host-code = p-host-code
            and X_fin-bank.code-bank = p-code-bank no-error.
    if not available X_fin-bank then do:
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
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_fin-schet No-LOCK where
                 recid(find_fin-schet) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if v-rid-list <> "":U then
  REPOSITION br-schet to recid integer(entry(1, v-rid-list)) No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-schet"
    &frame-name = "{&frame-name}"
    &ext-col = 11
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11'"
    &prev-order-column-condition_1 = " p-mode = {&all} "
    &prev-order-column_2 = "'1,3,4,5,6,7,8,9,10,11,2'"
    &prev-order-column-condition_2 = " p-mode = {&company} "
    &prev-order-column_3 = "'1,2,3,4,5,6,8,9,10,11,7'"
    &prev-order-column-condition_3 = " p-mode = {&cmp} "
    &prev-order-column_4 = "'1,2,3,4,5,6,7,8,9,10,11'"
    &prev-order-column-condition_4 = " p-mode = 'currency':U "
    &prev-order-column_5 = "'1,2,3,5,6,7,8,9,10,11,4'"
    &prev-order-column-condition_5 = " p-mode = 'bank':U "
    &prev-order-column_6 = "'1,3,4,5,6,8,9,10,11,7,2'"
    &prev-order-column-condition_6 = " p-mode = 'cmp-host':U  or p-mode = 'company-host':U "

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
  DISPLAY RS-status_ ED-notes sch-code sch-c-schet sch-r-schet RS-cli-type
          sch-cli-code mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add b-lkp B-chg B-del B-vipiska B-print B-hist
         B-sch B-Help B-bank B-copy RS-status_ br-schet ED-notes sch-code
         sch-c-schet sch-r-schet RS-cli-type B-cli sch-cli-code mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
b-print:MENU-MOUSE in frame {&frame-name} = 1
br-schet:num-locked-columns = 1
X_fin-schet.status_:read-only in browse br-schet = yes
RS-cli-type:radio-buttons = {&CMp} + {&comma-char} + {&cmp} + {&comma-char} + {&prs} + {&comma-char} + {&prs}
rs-status_:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                      = "Текущие&+" + {&comma-char} +  {&current-status} + {&comma-char} +
                      "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                      "Удаленные&-" + {&comma-char} + {&deleted-status}
rs-status_ = p-status_
b-vipiska:menu-mouse = 1
.
DISPLAY
ED-notes
sch-code
sch-c-schet
sch-r-schet
sch-cli-code
mark-num
RS-cli-type
RS-status_
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
B-add when ((p-mode = {&company} or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-add":U, bttns) > 0 and not transaction
            )
b-sel when lookup("b-sel":U, bttns) > 0
B-copy when ((p-mode = {&company} or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-copy":U, bttns) > 0 and not transaction
            )
b-lkp
B-chg when ((p-mode = {&company} or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-add":U, bttns) > 0  and not transaction
            )
B-del when ((p-mode = {&company} or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-add":U, bttns) > 0  and not transaction
            )
B-sch
b-cli
B-print
b-vipiska
b-bank
B-Help
b-hist
br-schet
ED-notes
sch-code
sch-cli-code
sch-c-schet
sch-r-schet
RS-cli-type
mark-num
RS-status_
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

&scop flt-open-open-query OPEN QUERY br-schet FOR EACH X_fin-schet

&scop flt-open-dyn_open-query FOR EACH X_fin-schet

&scop flt-open-query-handle QUERY br-schet:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_fin-schet

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_fin-schet

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


  CASE p-mode :
    WHEN {&all}        THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 + {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
          .
      end.
      IF p-status_ = {&all} THEN DO:
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind    = "  "
            &by         = "  " }
      END.
      ELSE DO:
            { gbl/fltopend.i
              &where-cond = " X_fin-schet.status_ = p-status_ "
              &dyn_where-cond = " substitute('X_fin-schet.status_ = &1&2&1', ~{&double-quote~}, p-status_) "
              &use-ind    = "  "
              &by         = "  " }

      END.
    END.
    WHEN {&company} THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна фирма", filter-label0)
      .
      if p-open-query then do:
       assign
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Фирма: (&1) &2",
                                   p-host-code, X_clients-host.obj-name) +
                                   {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
       .
      end.
        IF p-status_ = {&ALL}  THEN DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.host-code  = p-host-code    ~
                            "
              &dyn_where-cond = " substitute(' X_fin-schet.host-code  = &1', p-host-code)"

              &use-ind    = "  "
              &by         = "  " }

        END.
        ELSE DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.host-code  = p-host-code   ~
                AND X_fin-schet.status_ = p-status_ "
              &dyn_where-cond = " substitute(' X_fin-schet.host-code  = &1   ~
                AND X_fin-schet.status_ = &2&3&2', p-host-code, {&double-quote}, p-status_)"

              &use-ind    = "  "
              &by         = "  " }

        END.
    END.
    WHEN {&cmp} THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Контрагент", filter-label0)
      .
      if p-open-query then do:
       assign
       frame {&frame-name}:TITLE = title0 +
                                  substitute(" Контрагент: (&1&2) &3",
                                   X_clients.obj-type , X_clients.obj-code, X_clients.obj-name) +
                                   {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
       .
      end.
      IF p-status_ = {&all} THEN DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code     ~
                            "
              &dyn_where-cond = " substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3 '  ~
                            , ~{&double-quote~}, p-cli-type, p-cli-code)"

              &use-ind    = "  "
              &by         = "  " }

        END.
        ELSE DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code     ~
                AND X_fin-schet.status_ = p-status_  "
              &dyn_where-cond = " substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3 ~
                AND X_fin-schet.status_ = &1&4&1 ', ~{&double-quote~}, p-cli-type, p-cli-code, p-status_ )"

              &use-ind    = "  "
              &by         = "  " }

        END.
    END.
    WHEN "cmp-host":U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 одна фирма, один контрагент", filter-label0)
      .
      if p-open-query then do:
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                   substitute(" Фирма: (&1) &2 Контрагент (&3&4) &5",
                                   p-host-code, X_clients-host.obj-name,
                                   X_clients.obj-type, X_clients.obj-code, X_clients.obj-name) +
                                   {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
        .
      end.
        IF p-status_ = {&ALL} THEN DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code     ~
                            "
              &dyn_where-cond = " substitute(' X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 ' ~
                                 , p-host-code, {&double-quote}, p-cli-type, p-cli-code)"

              &use-ind    = "  "
              &by         = "  " }

        END.
        ELSE DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code     ~
                AND X_fin-schet.status_ = p-status_ "
              &dyn_where-cond = " substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 ~
                AND X_fin-schet.status_ = &1&4&1' , p-host-code, ~{&double-quote~}, p-cli-type, p-cli-code, p-status_)"

              &use-ind    = "  "
              &by         = "  " }

        END.
    END.
    WHEN "company-host":U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Собственные счета фирмы", filter-label0)
      .
      if p-open-query then do:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                   substitute(" Фирма: (&1) &2 Собственные счета",
                                   p-host-code, X_clients-host.obj-name
                                   ) +
                                   {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
       .
      end.
      IF p-status_ = {&ALL}  THEN DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = ~{&cmp~} AND X_fin-schet.cli-code  = p-host-code     ~
                            "
              &dyn_where-cond = " substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '    ~
                            , p-host-code, ~{&double-quote~}, ~{&cmp~}, p-host-code)"

              &use-ind    = "  "
              &by         = "  " }

        END.
        ELSE DO:
            { gbl/fltopend.i
              &where-cond = " ~
                X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = ~{&cmp~} AND X_fin-schet.cli-code  = p-host-code     ~
                AND X_fin-schet.status_ = p-status_  "
              &dyn_where-cond = " substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 ~
                AND X_fin-schet.status_ = &2&5&2 ', p-host-code, ~{&double-quote~}, ~{&cmp~}, p-host-code, p-status_)"

              &use-ind    = "  "
              &by         = "  " }

        END.
    END.
    WHEN "currency" THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна валюта", filter-label0)
      .
      if p-open-query then do:
       ASSIGN
       frame {&frame-name}:TITLE = title0 +
                                    substitute(" Валюта: (&1) &2",
                                    X_currency.curr-code, X_currency.curr-abbr) +
                                    {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
       .
      end.
      IF p-status_ = {&ALL} THEN DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code     ~
                          "
            &dyn_where-cond = " substitute( ' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2', p-curr-host-code, p-curr-code)"

            &use-ind    = "  "
            &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code     ~
              AND X_fin-schet.status_ = p-status_ "
            &dyn_where-cond = " substitute(' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2    ~
              AND X_fin-schet.status_ = &3&4&3 ',  p-curr-host-code, p-curr-code, ~{&double-quote~}, p-status_ )"

            &use-ind    = "  "
            &by         = "  " }

      END.
    END.
    WHEN "bank" THEN DO:
      assign
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 Один банк", filter-label0)
      .
      if p-open-query then do:
        assign
        frame {&frame-name}:TITLE = title0 +
                                  substitute(" Банк: &1", X_fin-bank.short-name) +
                                  {&space-char}  + (if p-status_ = {&all} then "":U else p-status_)
        .
      end.
      IF p-status_ = {&ALL} THEN DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank     ~
                          "
            &dyn_where-cond = " substitute('  X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2 ', p-host-code, p-code-bank ) "

            &use-ind    = "  "
            &by         = "  " }

      END.
      ELSE DO:
          { gbl/fltopend.i
            &where-cond = " ~
              X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank     ~
              AND X_fin-schet.status_ = p-status_ "
            &dyn_where-cond = " substitute('X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2     ~
              AND X_fin-schet.status_ = &3&4&3', p-host-code, p-code-bank, ~{&double-quote~}, p-status_ )"

            &use-ind    = "  "
            &by         = "  " }

      END.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo .
define variable loc-doc-rec as recid no-undo .
if not available X_fin-schet then return error.

do
on error undo, return error
on stop undo, return error

:

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_deletion':U
  {&cntxt-firm}
  p-curr-host-code
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
  v-status_ = "":U
  loc-doc-rec = recid(X_fin-bank)
  .
  run ref/finscht2.p (
                  input recid(X_fin-schet)
                  ,input no /*p-silent*/
                  ,input ''
                  ,input-output v-status_
                 ) no-error .
  if error-status:error then undo, return error.
   if v-status_ <> p-status_ then do:
    RUn OpenBR in this-procedure ( input yes, input no, input no).
    reposition br-schet to recid loc-doc-rec no-error.
    {&cant-positioning}
  end.
  else do:
    display
    X_fin-schet.status_
    with browse br-schet.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER loc-option as character no-undo.
if loc-option = '':U then return error.
CASE loc-option:
when 'ONE':U then do:
  run proc-print-one in this-procedure .
end.
when 'LIST':U then do:
  run proc-print-list no-error.
end.
end case.
loc-option = ''.
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
  tbl = 'fin-schet'
  join-tbl = 'X_fin-schet'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('host-code', 'Кoд фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('code-schet', 'Код счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('code-bank', 'Код банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Держатель счета', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('c-schet', 'Коррсчет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dop1', 'Доп к назв.держ.счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dop2', 'Доп к назв.банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('r-schet', 'Р/счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-vipiska Dialog-Frame
PROCEDURE proc-b-vipiska :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.

CASE p-option :
  WHEN 'report' THEN DO:
    run rep/fextract.p ( input parparentproc
                       , input X_fin-schet.host-code
                       , input X_fin-schet.code-schet) no-error.
  END.
  WHEN 'statement' THEN DO:
   run ref/finsttms.w (
               input parparentproc
              ,input v-cntxt-host-code-obj /*p-current-host-code*/
              ,input "":U  /*bttns*/
              ,input 'code-schet':U
              ,input X_fin-schet.host-code /*p-host-code*/
              ,input '':U /*p-status_*/
              ,input '':U /*p-fin-ext-doc-type*/
              ,input '':U  /*p-fins-ext-doc-type*/
              ,input ?      /*p-start-date  */
              ,input ?      /*p-end-date  */
              ,input X_fin-schet.code-bank  /*p-code-bank*/
              ,input X_fin-schet.code-schet  /* p-code-schet */
              ,input X_fin-schet.curr-code      /* p-curr-code */
              ,input-output v-rid-list).

  END.
END CASE.


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
  if b-sel:sensitive in frame {&frame-name} then
      if b-mark:sensitive then
          apply "choose" to b-mark in frame {&frame-name}.
      else
          apply "choose" to b-sel in frame {&frame-name}.
  else
      if b-lkp:sensitive then
          apply "choose" to b-lkp in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-fin-code as integer no-undo .
define variable p-out-host-code like ub.sysconf.host-code no-undo.
define variable firm-rid-list as char no-undo.
define variable p-ok as logical no-undo .
define variable ii as integer no-undo .
define variable Jj as integer no-undo .
define variable kk as integer no-undo .
define variable p-ret as logical no-undo .
define variable glog as logical no-undo.
define variable v-out-host-code like ub.sysconf.host-code no-undo .
define variable v-recid-schet as recid no-undo.
define variable v-recid-bank as recid no-undo.
define variable v-new-rid-list as character no-undo .
define variable v-final-rid-list as character no-undo .
define variable v-stay-doc-rec as recid no-undo.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf2_fin-bank for ub.fin-bank.
define buffer buf2_fin-schet for ub.fin-schet.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-bank-accounts_add-copy':U
  {&cntxt-firm}
  p-host-code
  '':U
  0
  0
  0
  0
  true
  glog
}
if not glog then  return .
if num-entries(v-rid-list) = 0 then do:
  message
  "Не отмечены записи для копирования !!!"
  view-as alert-box error.
  return error.
end.
assign
v-stay-doc-rec = recid(X_fin-schet)
.
run adm/sconfs.w (
              input parparentproc
            , input "b-mark,b-sel":U
            , input no
            , input p-curr-host-code
            , output v-out-host-code
            , input-output firm-rid-list) .
if num-entries(firm-rid-list) = 0 then do:
 message "Не выбрана фирмы для копирования !!!" .
 return error.
end.


message
"Вы отметили " num-entries(firm-rid-list) " фирмы. " skip
"Скопировать выбранные счета в эти фирмы ?"
view-as alert-box question
buttons yes-no
update p-ok.

kk = 0.
if p-ok = false then return.
_ii:
repeat ii = 1 to num-entries(firm-rid-list) :
  find first buf_sysconf no-lock where
            recid(buf_sysconf) = integer(entry(ii, firm-rid-list)) no-error .
  if not available buf_sysconf then next _ii.
  if buf_sysconf.host-code = p-host-code then do:
    message
    "Нельзя скопировать счета в свою собственную фирму" buf_sysconf.host-code
    view-as alert-box error .
    next _ii.
  end.
  /* список recid справочника */
   /*проверим что sysconf той же базы*/
  if buf_sysconf.firm-db-num <> X_sysconf.firm-db-num then do:
    message
    "Нельзя скопировать счета на фирму" buf_sysconf.host-code  skip
    "Текущая БД " v-db-num "Главная БД данной фирмы" buf_sysconf.firm-db-num
    view-as alert-box error .
    next _ii.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-bank-accounts_add-copy':U
    {&cntxt-firm}
    buf_sysconf.host-code
    '':U
    0
    0
    0
    0
    no
    glog
  }
  if not glog then do:
    message
    "Нельзя скопировать счета на фирму" buf_sysconf.host-code  skip
    "У Вас нет прав на добавление банков и банковских счетов в фирме" buf_sysconf.host-code
    view-as alert-box error .
    next _ii.
  end.
  _rr:
  repeat jj = 1 to num-entries(v-rid-list) :
    for each buf_fin-schet where
          recid(buf_fin-schet) =  integer(entry(jj, v-rid-list)):
      if buf_fin-schet.cli-type = {&cmp}
      AND buf_fin-schet.cli-code = buf_sysconf.host-code then do:
        message
        "Нельзя скопировать счета, для которых фирма является держателем счета" buf_sysconf.host-code
        view-as alert-box error .
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
        .
        next _rr.
      end.
      if buf_fin-schet.status_ = {&deleted-status} then do:
        message
        "Нельзя скопировать счета" buf_fin-schet.code-schet "на фирму" buf_sysconf.host-code  skip
        "Счет имеет статус" {&deleted-status} "в фирме" p-host-code
        view-as alert-box error .
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
        .
        next _rr.
      end.
      /*сначал найдем банк для счета в исфходной фирме*/
      find first buf_fin-bank no-lock where
                buf_fin-bank.host-code = p-host-code
            AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
      if not available buf_fin-bank then next _rr.
      /*теперь найдем есть ли такой банк для счета в фирме куда копируем*/
      find first buf2_fin-bank no-lock where
                buf2_fin-bank.host-code = buf_sysconf.host-code
            AND buf2_fin-bank.bik = buf_fin-bank.bik
            AND buf2_fin-bank.cor-acc = buf_fin-bank.cor-acc no-error .
      if not available buf2_fin-bank then do:
        assign
        v-recid-bank = ?.
        /*скопируем банк*/
        run ref/finbank1.p (
        input-output v-recid-bank
        ,input {&add-def}
        ,input no
        ,input "bik" /*p-verify*/
        ,input "":U
        ,input buf_sysconf.host-code
        ,input 0
        ,input buf_fin-bank.addres
        ,input buf_fin-bank.bank-city
        ,input buf_fin-bank.addres1
        ,input buf_fin-bank.bank-name
        ,input buf_fin-bank.bik
        ,input buf_fin-bank.cor-acc
        ,input buf_fin-bank.e-mail
        ,input buf_fin-bank.fax
        ,input buf_fin-bank.inn
        ,input buf_fin-bank.kpp
        ,input buf_fin-bank.licenz
        ,input buf_fin-bank.okato
        ,input buf_fin-bank.okonx
        ,input buf_fin-bank.okpo
        ,input buf_fin-bank.otdel
        ,input buf_fin-bank.phone
        ,input (substitute("@Копирование с фирмы &1@ &2", p-host-code, buf_fin-bank.PS))
        ,input buf_fin-bank.rkc
        ,input buf_fin-bank.short-name
        ,input buf_fin-bank.cl-bank
        )
        no-error.
        if error-status:error then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
          .
          next _rr.
        end.
        find first buf2_fin-bank no-lock where
                  recid(buf2_fin-bank) = v-recid-bank no-error.
      end.
      if available buf2_fin-bank then do:
        if buf2_fin-bank.status_ = {&deleted-status} then do:
          message
          "Нельзя скопировать счета" buf_fin-schet.code-schet "на фирму" buf_sysconf.host-code  skip
          "Банк счета имеет статус" {&deleted-status} "в фирме" buf_sysconf.host-code
          view-as alert-box error .
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
          .
          next _rr.
        end.
        /*а теперь можно и счет*/
        find first buf2_fin-schet no-lock where
                    buf2_fin-schet.host-code      = buf_sysconf.host-code
                AND buf2_fin-schet.code-bank      = buf2_fin-bank.code-bank
                AND buf2_fin-schet.c-schet      = buf_fin-schet.c-schet
                AND buf2_fin-schet.r-schet      = buf_fin-schet.r-schet no-error.
        if not available buf2_fin-schet then do:
          /*скопируем счет*/
          assign
          v-recid-schet = ?.
          run ref/finscht1.p (
          input-output v-recid-schet
          ,input {&add-def}
          ,input no
          ,input "r-schet"
          ,input buf_sysconf.host-code
          ,input 0
          ,input buf_fin-schet.c-schet
          ,input buf_fin-schet.cli-type
          ,input buf_fin-schet.cli-code
          ,input buf2_fin-bank.code-bank
          ,input buf_fin-schet.curr-code
          ,input buf_fin-schet.dop1
          ,input buf_fin-schet.dop2
          ,input buf_fin-schet.r-schet
          ,input (substitute("@Копирование с фирмы &1@ &2", p-host-code, buf_fin-schet.PS))
          )
          no-error.
          find first buf2_fin-schet no-lock where
                    recid(buf2_fin-schet) = v-recid-schet no-error .
          if available buf2_fin-schet then do:
            assign
            kk = kk + 1
            .
          end.
          else do:
            assign
            v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(jj, v-rid-list)
            .
          end.
        end.
      end.
    end. /*for each fin-schet*/
  end. /*repeat jj*/
  assign
  v-final-rid-list = cross-list(v-rid-list, v-new-rid-list, {&comma-char})
  .
end. /*repeat ii*/
v-rid-list = v-final-rid-list.
run OpenBr in this-procedure ( input yes, input no, input no).
reposition br-schet to recid v-stay-doc-rec no-error.
message
"Скопировано " kk  "записей" view-as alert-box .

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
define input parameter p-c-schet like ub.fin-schet.c-schet no-undo.
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
    ,input substitute("and X_fin-schet.c-schet   begins &1 "
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
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo.
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
    ,input substitute("and X_fin-schet.cli-type = '&1' and X_fin-schet.cli-code = &2"
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
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo.
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
    ,input substitute("and X_fin-schet.code-schet = &1 "
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
    ,input substitute("and X_fin-schet.r-schet   begins &1 "
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
define variable v-bank-short-name     as character no-undo .
define variable v-cli-name      as character no-undo .
define variable v-curr-abbr     as character no-undo .

DEFINE FRAME fin-schet-list
X_fin-schet.host-code COLUMN-LABEL "Код!фирмы" format "9999999999"
X_fin-schet.code-schet
X_fin-schet.code-bank COLUMN-LABEL "Код банка"  format ">>>>>>9"
v-bank-short-name format "X(40)" COLUMN-LABEL "Банк"
X_fin-schet.cli-type
X_fin-schet.cli-code
v-cli-name  format "X(20)" COLUMn-LABEL "Держатель счета"
v-curr-abbr format "X(3)" COLUMn-LABEL "Вал"
X_fin-schet.status_
X_fin-schet.r-schet
X_fin-schet.c-schet
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
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
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME fin-schet-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_fin-schet).
DO WHILE available X_fin-schet :
  GET prev br-schet.
END.
GET next br-schet.
DO WHILE available X_fin-schet :
  Display STREAM PrnLibStream
  X_fin-schet.host-code
  X_fin-schet.code-schet
  X_fin-schet.code-bank
  get-bank-short-name(buffer X_fin-schet) @  v-bank-short-name
  X_fin-schet.cli-type
  X_fin-schet.cli-code
  get-cli-name(buffer X_fin-schet) @ v-cli-name
  get-currency(buffer X_fin-schet)  @ v-curr-abbr
  X_fin-schet.status_
  X_fin-schet.r-schet
  X_fin-schet.c-schet
  with FRAME fin-schet-list .
  DOWN STREAM PrnLibStream 1
  with FRAME fin-schet-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-schet.
END.
UNDERLINE  STREAM PrnLibStream
X_fin-schet.host-code
X_fin-schet.code-schet
X_fin-schet.code-bank
v-bank-short-name
X_fin-schet.cli-type
X_fin-schet.cli-code
v-cli-name
v-curr-abbr
X_fin-schet.status_
X_fin-schet.r-schet
X_fin-schet.c-schet
with FRAME fin-schet-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_fin-schet.host-code
accum-count @ X_fin-schet.code-schet
with frame fin-schet-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-schet-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-schet to recid v-doc-rec no-error.
APPLY "entry" to br-schet.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-one Dialog-Frame
PROCEDURE proc-print-one :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if not available X_fin-schet then return error.
run ref/finschtp.p (
                 INPUT parParentProc
                 ,input X_fin-schet.host-code
                 ,input X_fin-schet.code-schet
              ) no-error.
if error-status:error then do:
  return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-bank-short-name Dialog-Frame
FUNCTION get-bank-short-name RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_fin-bank for ub.fin-bank.

find first buf_fin-bank no-lock where
            buf_fin-bank.code-bank = loc-fin-schet.code-bank
                AND    buf_fin-bank.host-code = loc-fin-schet.host-code  no-error.
if available buf_fin-bank then
RETURN (if buf_fin-bank.short-name <> "":U then buf_fin-bank.short-name else buf_fin-bank.bank-name).   /* Function return value. */
return (string(loc-fin-schet.host-code) + string(loc-fin-schet.code-bank)).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
 ( BUFFER loc-fin-schet FOR ub.fin-schet ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.

find first buf_clients no-lock where
            buf_clients.obj-type = loc-fin-schet.cli-type
                AND    buf_clients.obj-code = loc-fin-schet.cli-code  no-error.
if available buf_clients then
RETURN (buf_clients.obj-name).   /* Function return value. */
return (loc-fin-schet.cli-type + string(loc-fin-schet.cli-code)).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_currency for ub.currency.

find first buf_currency no-lock where
            buf_currency.curr-code = loc-fin-schet.curr-code no-error.
if available buf_currency then
  RETURN buf_currency.curr-abbr.   /* Function return value. */
return string(loc-fin-schet.curr-code).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME