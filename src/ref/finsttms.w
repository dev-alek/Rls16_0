&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_fin-statement FOR ub.fin-statement.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE NEW SHARED BUFFER X_fin-statement FOR ub.fin-statement.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список банковских выписок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/05
Author: Bakhtadze Natalya
Creation date: 08/03/05

*/
/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY br-fin-statement !!!!!!!
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
/*
{&all}
{&company}
"code-bank":U
"code-schet":U
"currency":U
"type":U
"type-stat":U
"type-stat-date":U
"type-date":U
"ext-type":U
"ext-type-stat":U
"ext-type-stat-start":U
"ext-type-stat-end":U
"ext-type-stat-date":U
"ext-type-date":U

*/

define input parameter p-host-code          like ub.fin-statement.host-code no-undo .
define input parameter p-status_            like ub.fin-statement.status_ no-undo.
define input parameter p-fins-doc-type      like ub.fin-statement.fins-doc-type no-undo.
define input parameter p-fins-ext-doc-type  like ub.fin-statement.fins-ext-doc-type no-undo.
define input parameter p-start-date         like ub.fin-statement.doc-date no-undo .
define input parameter p-end-date           like ub.fin-statement.doc-date no-undo .
define input parameter p-code-bank          like ub.fin-statement.code-bank no-undo.
define input parameter p-code-schet         like ub.fin-statement.code-schet no-undo.
define input parameter p-curr-code          like ub.fin-statement.curr-code no-undo.

/*записи в выборке*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список банковских выписок":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
FUNCTION uf-convert-mode returns character(
                                        input p-mode as character):
CASE p-mode:
when {&all}
or
when "currency":U
or
when "code-schet":U
or
when "code-bank":U
then do:
return p-mode.
end.
when "type":U
or
when "type-date":U
then do:
return (p-mode + {&delim-par} + p-fins-doc-type).
end.
when "ext-type":U
or
when "ext-type-date":U
then do:
return (p-mode + {&delim-par} + p-fins-ext-doc-type).
end.
when "type-stat":U
or
when "type-stat-date":U
then do:
  return (p-mode + {&delim-par} + p-fins-doc-type + p-status_).
end.
when "ext-type-stat":U
or
when "ext-type-stat-start":U
or
when "ext-type-stat-end":U
or
when "ext-type-stat-date":U
then do:
return (p-mode + {&delim-par} + p-fins-ext-doc-type + p-status_).
end.
when {&company} then do:
return (p-mode + {&delim-par} + string(p-host-code)).
end.
END CASE.
END FUNCTION.


define variable filter-label as character no-undo init "Список выписок" .
define variable filter-label0 as character no-undo init "Список выписок" .
define variable filter-point as character no-undo init "finsttms" .
define variable filter-point0 as character no-undo init "finsttms" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
define variable add-option as character no-undo.
define variable client-option as character no-undo.
define variable schet-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-for-title as character no-undo.
define variable is-type-mode as logical no-undo .
define variable is-fact-mode as logical no-undo .
define variable is-stat-mode as logical no-undo init ?.
define variable is-fin as logical   no-undo .

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
define buffer X_curr_sysconf for ub.sysconf.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-fin-statement

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_fin-statement

/* Definitions for BROWSE br-fin-statement                              */
&Scoped-define FIELDS-IN-QUERY-br-fin-statement mark-string(recid(X_fin-statement), v-rid-list) X_fin-statement.host-code X_fin-statement.prn-doc-code X_fin-statement.fins-ext-doc-type X_fin-statement.code-schet X_fin-statement.start-date X_fin-statement.end-date X_fin-statement.status_ X_fin-statement.bank-date X_fin-statement.fact-date X_fin-statement.sum-doc X_fin-statement.cli-name get-currency(buffer X_fin-statement) X_fin-statement.sttm-code X_fin-statement.cl-bank
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-fin-statement X_fin-statement.prn-doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-br-fin-statement X_fin-statement
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-fin-statement X_fin-statement
&Scoped-define SELF-NAME br-fin-statement
&Scoped-define QUERY-STRING-br-fin-statement FOR EACH X_fin-statement NO-LOCK
&Scoped-define OPEN-QUERY-br-fin-statement OPEN QUERY {&SELF-NAME} FOR EACH X_fin-statement NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-fin-statement X_fin-statement
&Scoped-define FIRST-TABLE-IN-QUERY-br-fin-statement X_fin-statement


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-add b-lkp B-chg B-del ~
B-print B-hist B-sch B-Help T-batch B-close B-open B-reject B-schet B-attr ~
B-exp br-fin-statement ED-notes sch-prn-doc-code sch-doc-date sch-fact-date ~
sch-bank-date sch-r-schet sch-curr-code B-curr sch-BIK mark-num
&Scoped-Define DISPLAYED-OBJECTS T-batch ED-notes sch-prn-doc-code ~
sch-doc-date sch-fact-date sch-bank-date sch-r-schet sch-curr-code sch-BIK ~
mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-statement FOR ub.fin-statement )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM standard-sttm  LABEL "стандартная"   .

DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Один"
       MENU-ITEM m_one-graphics LABEL "Один-графика"
       MENU-ITEM m_list         LABEL "Список"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-attr
     LABEL "&Аттриб."
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exp
     LABEL "&Экспорт"
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

DEFINE BUTTON B-open
     LABEL "&Открыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-reject
     LABEL "&-Отказ"
     SIZE 10 BY 1.

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

DEFINE VARIABLE T-batch AS LOGICAL INITIAL no
     LABEL "Пктн.рж"
     VIEW-AS TOGGLE-BOX
     SIZE 10.5 BY 1 TOOLTIP "Пакетная обработка выбранных выписок" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY br-fin-statement FOR
      X_fin-statement SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-fin-statement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-fin-statement Dialog-Frame _FREEFORM
  QUERY br-fin-statement DISPLAY
      mark-string(recid(X_fin-statement), v-rid-list) FORMAT "X(1)":U
WIDTH 2
X_fin-statement.host-code COLUMN-LABEL "Код!фирмы" FORMAT "99999":U
X_fin-statement.prn-doc-code FORMAT "X(22)":U
X_fin-statement.fins-ext-doc-type COLUMN-LABEL "Расш.тип" FORMAT "X(8)":U
X_fin-statement.code-schet COLUMN-LABEL "Вн.№счета"
X_fin-statement.start-date FORMAT "99/99/9999":U COLUMN-LABEL "С"
X_fin-statement.end-date FORMAT "99/99/9999":U COLUMN-LABEL "По"
X_fin-statement.status_ FORMAT "X(8)":U
X_fin-statement.bank-date COLUMN-LABEL "Дата банка!(пост.из банка)" FORMAT "99/99/9999":U
X_fin-statement.fact-date FORMAT "99/99/9999":U
X_fin-statement.sum-doc FORMAT "->,>>>,>>>,>>>,>>9.99":U
X_fin-statement.cli-name COLUMN-LABEL "Название держателя счета" FORMAT "X(255)":U WIDTH 20
get-currency(buffer X_fin-statement) COLUMN-LABEL "Вал" FORMAT "X(3)":U
X_fin-statement.sttm-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
X_fin-statement.cl-bank COLUMN-LABEL "Кл-банк" FORMAT "X(8)"
ENABLE
X_fin-statement.prn-doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 14.37.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 41
     b-lkp AT ROW 1 COL 51
     B-chg AT ROW 1 COL 61
     B-del AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     T-batch AT ROW 2 COL 1
     B-close AT ROW 2 COL 21
     B-open AT ROW 2 COL 31
     B-reject AT ROW 2 COL 41
     B-schet AT ROW 2 COL 51
     B-attr AT ROW 2 COL 61
     B-exp AT ROW 2 COL 71
     br-fin-statement AT ROW 3.03 COL 1.4
     ED-notes AT ROW 17.5 COL 1 NO-LABEL
     sch-prn-doc-code AT ROW 19.57 COL 16 COLON-ALIGNED
     sch-doc-date AT ROW 19.57 COL 38.1 COLON-ALIGNED
     sch-fact-date AT ROW 19.57 COL 62 COLON-ALIGNED
     sch-bank-date AT ROW 19.57 COL 86 COLON-ALIGNED
     sch-r-schet AT ROW 20.8 COL 75.3 COLON-ALIGNED
     sch-curr-code AT ROW 20.93 COL 9 COLON-ALIGNED
     B-curr AT ROW 20.93 COL 15.5
     sch-BIK AT ROW 20.93 COL 27.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 19.57 COL 1
     SPACE(89.90) SKIP(1.46)
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
      TABLE: find_fin-statement B "?" NO-UNDO ub fin-statement
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_fin-statement B "NEW SHARED" ? ub fin-statement
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-fin-statement B-exp Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       br-fin-statement:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-fin-statement
/* Query rebuild information for BROWSE br-fin-statement
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_fin-statement NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-fin-statement */
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


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-option = '':U then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure ( input add-option) no-error.
  if error-status:error then do:
    add-option = (if is-type-mode then p-fins-doc-type else  '':U).
    return no-apply.
  end.
  APPLY "ENTRY" to br-fin-statement.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Аттриб. */
DO:
define variable loc-doc-rec as recid no-undo .

  if  available X_fin-statement then do:
    run ref/fd-atti.w (  input parparentproc
                        ,input {&lookup}
                        ,input X_fin-statement.host-code
                        ,input X_fin-statement.sttm-code
                      ) NO-ERROR.
    apply "entry" to br-fin-statement in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available X_fin-statement then return no-apply.
run proc-b-chg-lookup in this-procedure ( input {&update}) no-error.
if error-status:error then do:
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  if not available X_fin-statement then return no-apply.
  run proc-close-open in this-procedure ( input {&close-doc}
                                        , input t-batch) no-error.
  if error-status:error then return no-apply.
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


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run proc-b-del in this-procedure ( input t-batch) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exp Dialog-Frame
ON CHOOSE OF B-exp IN FRAME Dialog-Frame /* Экспорт */
DO:
  RUN proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if available X_fin-statement then do:
      loc-doc-rec = recid (X_fin-statement).
    .
    run ref/fincstts.w
                  (
                   input parParentProc
                  ,input p-curr-host-code
                  ,input "":U /*bttns*/
                  ,input "one":U
                  ,input X_fin-statement.host-code
                  ,input X_fin-statement.sttm-code
                  ,input X_fin-statement.code-schet
                  ,input-output v-rid-list
                                )
    .
    reposition br-fin-statement to recid loc-doc-rec no-error.
    apply "entry" to br-fin-statement in frame {&frame-name}.
    apply "value-changed" to br-fin-statement in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
if not available X_fin-statement then return no-apply.
run proc-b-chg-lookup in this-procedure ( input {&lookup}) no-error.
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
  if available X_fin-statement then do:
    { gbl/markstrn.i X_fin-statement v-rid-list }
    loc#log = br-fin-statement:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-fin-statement:select-next-row ().
        apply "VALUE-CHANGED" to br-fin-statement in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-fin-statement in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-open Dialog-Frame
ON CHOOSE OF B-open IN FRAME Dialog-Frame /* Открыть */
DO:
  if not available X_fin-statement then return no-apply.
  run proc-close-open in this-procedure ( {&open-doc}, input t-batch ) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_fin-statement then return no-apply.
  if print-option = '':U then do:
     run gbl/pop-up.p ( input self:handle
                       ,input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-fin-statement.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
    v-uf-List_ = string(recid(X_fin-statement))
    .
    run uf-set in this-procedure (
       input  ({&uf-finsttms-p} + {&delim-par} + uf-convert-mode(p-mode))
      ,input  g#userid
      ,input v-uf-List_
      ,input v-uf-Naim
      ,input v-uf-print-graft
      ,input v-uf-sort-gr
      ,input v-uf-type-price
      ,input v-uf-type-val
  )  no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-reject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-reject Dialog-Frame
ON CHOOSE OF B-reject IN FRAME Dialog-Frame /* -Отказ */
DO:
  if not available X_fin-statement then return no-apply.
  run proc-close-open in this-procedure ( input {&reject-doc}
                                        , input t-batch) no-error .
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


&Scoped-define SELF-NAME B-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-schet Dialog-Frame
ON CHOOSE OF B-schet IN FRAME Dialog-Frame /* Счет */
DO:
define variable loc-doc-rec as recid no-undo.
if not available X_fin-statement then return no-apply.

run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code /*p-curr-host-code*/
                ,input {&lookup}
                ,input X_fin-statement.host-code
                ,input X_fin-statement.code-schet  /*p-code-schet*/
                ,input X_fin-statement.code-bank /*code-bank*/
                ,input {&cmp}
                ,input X_fin-statement.host-code
                ,input X_fin-statement.curr-code
                ,input-output loc-doc-rec
                            )
.
 schet-option = '':U.
 APPLY "ENTRY" to br-fin-statement.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_fin-statement ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_fin-statement ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-fin-statement
&Scoped-define SELF-NAME br-fin-statement
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fin-statement Dialog-Frame
ON RETURN OF br-fin-statement IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-fin-statement IN FRAME Dialog-Frame
DO:
  run proc-br-fin-statement no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fin-statement Dialog-Frame
ON VALUE-CHANGED OF br-fin-statement IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_fin-statement then X_fin-statement.ps else '':U.
  ED-notes:screen-value = dops.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-statement for ub.fin-statement.
  if not available X_fin-statement then return no-apply.

   DO on stop undo, return no-apply:
      FIND PS_fin-statement where
           recid (ps_fin-statement) = recid(X_fin-statement) exclusive.
      if ps_fin-statement.PS <> input frame {&frame-name} ed-notes then
      assign
      ps_fin-statement.PS = input frame {&frame-name} ed-notes
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


&Scoped-define SELF-NAME m_one-graphics
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one-graphics Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one-graphics /* Один-графика */
DO:
   assign
  print-option = 'ONE-GRAPHICS':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.

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


&Scoped-define SELF-NAME standard-sttm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL standard-sttm Dialog-Frame
ON CHOOSE OF MENU-ITEM standard-sttm /* стандартная */
DO:
    assign
   add-option = {&FSEDT_standard-sttm}.
   APPLY "CHOOSE" to b-add  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-batch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-batch Dialog-Frame
ON VALUE-CHANGED OF T-batch IN FRAME Dialog-Frame /* Пктн.рж */
DO:
define variable GLOG as logical no-undo .
  assign
  t-batch.
  run proc-buttons in this-procedure ( input t-batch).
  if t-batch = no
  and b-mark:sensitive = no then do:
    assign
    v-rid-list = "":U.
    if avail X_fin-statement then
    GLOG = br-fin-statement:refresh().
  end.
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
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/setfltnm.i }

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_fin-statement.prn-doc-code"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure (  input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(X_fin-statement). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-fin-statement to recid v-doc-rec no-error. v-doc-rec = ?. " }

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
  REPOSITION br-fin-statement to recid v-doc-rec No-ERROR.
  { gbl/mv-clmn.i
    &browse-name = "br-fin-statement"
    &frame-name = "{&frame-name}"
    &ext-col = 16
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,5,6,7,8,9,10,11,12,13,14,15,4'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} "
    &prev-order-column_2 = "'1,3,5,6,7,8,9,10,11,12,13,2,14,15,4'"
    &prev-order-column-condition_2 = " p-mode = ~{&company~} "
    &prev-order-column_3 = "'1,3,5,6,7,8,9,10,11,12,13,2,14,15,4'"
    &prev-order-column-condition_3 = " is-type-mode = yes "
    &prev-order-column_4 = "'1,3,5,6,7,8,9,10,11,12,13,2,14,15,4'"
    &prev-order-column-condition_4 = " p-mode = 'code-schet' "
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
  DISPLAY T-batch ED-notes sch-prn-doc-code sch-doc-date sch-fact-date
          sch-bank-date sch-r-schet sch-curr-code sch-BIK mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add b-lkp B-chg B-del B-print B-hist B-sch
         B-Help T-batch B-close B-open B-reject B-schet B-attr B-exp
         br-fin-statement ED-notes sch-prn-doc-code sch-doc-date sch-fact-date
         sch-bank-date sch-r-schet sch-curr-code B-curr sch-BIK mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MainProc Dialog-Frame
PROCEDURE MainProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
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
                  {&company} + {&delim-par} +
                "fins-doc-type":U + {&delim-par} +
                "status_":U + {&delim-par} +
                "code-bank":U + {&delim-par} +
                "code-schet":U + {&delim-par} +
                "currency":U + {&delim-par} +
                "type":U + {&delim-par} +
                "type-stat":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "type-date":U + {&delim-par} +
                "ext-type":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-start":U + {&delim-par} +
                "ext-type-stat-end":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par} +
                "ext-type-date":U + {&delim-par} +
                "trn-doc":U),
                {&delim-par}) = 0
    then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
end.
run uf-get in this-procedure(
    input  ({&uf-finsttms-p} + {&delim-par} + uf-convert-mode(p-mode))
    ,input  g#userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 2 then do:
  assign
  v-doc-rec = (if v-rid-list = "":U
              then integer(entry(2, v-uf-List_, {&delim-par}))
              else integer(entry(2, v-uf-List_, v-rid-list)) )
  .
end.
if lOOKUP(p-mode,
                (
                "type":U + {&delim-par} +
                "type-stat":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "type-date":U), {&delim-par} ) > 0 then do:
  assign
  is-type-mode = yes
  .
  if LOOKUP(p-fins-doc-type , {&fins-doc-types}) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-fins-doc-type"
    p-fins-doc-type
    view-as alert-box ERROR.
    return error .
  end.
end.
if lOOKUP(p-mode,
                (
                "type-stat":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-date":U
                ), {&delim-par} ) > 0 then do:
  assign
  is-stat-mode = yes
  .
  if p-status_ = {&fact} then do:
    assign
    is-fact-mode = yes
    .
  end.
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
if lookup(p-mode,
                ("type-stat":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-start":U + {&delim-par} +
                "ext-type-stat-end":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par}), {&delim-par} ) > 0
AND
lookup(p-status_, {&fin-status-all}) = 0 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-status_"
  p-status_
  view-as alert-box ERROR.
  return error .
end.

if lookup(p-mode,
                ("type":U + {&delim-par} +
                "type-stat":U + {&delim-par} +
                "type-stat-date":U + {&delim-par} +
                "type-date":U + {&delim-par} +
                "ext-type":U + {&delim-par} +
                "ext-type-stat":U + {&delim-par} +
                "ext-type-stat-start":U + {&delim-par} +
                "ext-type-stat-end":U + {&delim-par} +
                "ext-type-stat-date":U + {&delim-par} +
                "ext-type-date":U + {&delim-par}
                ), {&delim-par} ) > 0 then do:

  if lookup( p-fins-ext-doc-type , {&fins-ext-doc-types}) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-fins-ext-doc-type"
    p-fins-ext-doc-type
    view-as alert-box ERROR.
    return error .
  end.
end.

  if LOOKUP(p-mode, (
                {&company} + {&delim-par } +
                "currency":U + {&delim-par} +
                "type":U + {&delim-par } +
                "type-stat":U + {&delim-par } +
                "type-stat-date":U + {&delim-par } +
                "type-date":U + {&delim-par } +
                "ext-type":U + {&delim-par } +
                "ext-type-stat":U + {&delim-par } +
                "ext-type-stat-start":U + {&delim-par } +
                "ext-type-stat-end":U + {&delim-par } +
                "ext-type-stat-date":U + {&delim-par } +
                "ext-type-date":U + {&delim-par } +
                "code-schet":U + {&delim-par} +
                "code-bank":U ),
                {&delim-par}) > 0 then do:
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
    p-code-bank = X_fin-schet.code-bank.
  end.
  if lookup(p-mode
          , "code-bank":U + {&delim-par} + "code-schet"
          , {&delim-par}) > 0 then do:
    find first X_fin-bank no-lock where
              X_fin-bank.host-code = p-curr-host-code
          AND  X_fin-bank.code-bank = p-code-bank  no-error.
    if not available X_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-code-bank"
        p-code-bank
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , "currency":U
          , {&delim-par}) > 0 then do:
    find first X_currency no-lock where
              X_currency.curr-code = p-curr-code no-error.
    if not available X_currency then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-code"
        p-curr-code
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if v-rid-list <> "" then do:
      FIND FIRST find_fin-statement No-LOCK where
                recid(find_fin-statement) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-statement then do:
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
define variable is-finvalue as character no-undo .
define variable is-fintype as character no-undo .
{ gbl/conf-rd.i
"'is-fin'"
"''"
"''"
0
"''"
"''"
"''"
no
is-finvalue
is-fintype
no-error }
is-fin = logical(is-finvalue).

assign
b-print:MENU-MOUSE in frame {&frame-name} = 1
b-add:MENU-MOUSE in frame {&frame-name} = 1
b-schet:MENU-MOUSE in frame {&frame-name} = 1
br-fin-statement:num-locked-columns = 1
X_fin-statement.prn-doc-code:read-only in browse br-fin-statement = yes
B-add:POPUP-MENU = (if is-type-mode then ? else B-add:POPUP-MENU)
add-option = p-fins-doc-type
X_fin-statement.cli-name:RESIZABLE IN BROWSE br-fin-statement = YES
.
if
LOOKUP(p-mode, ("type":U + {&delim-par} +
              "type-stat":U + {&delim-par} +
              "type-stat-date":U + {&delim-par} +
              "type-date":U), {&delim-par}) > 0 then do:
CASE p-fins-doc-type:
    when '':U then do:
        assign
        menu-item standard-sttm:sensitive in menu menu-b-add = yes
        .
    end.
END CASE.
end.
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
run proc-buttons in this-procedure ( input no).
ENABLE
b-quit
b-lkp
b-sel when lookup("b-sel":U, bttns) > 0
B-del when (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num and is-fin)
B-add when (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num and is-fin)
b-chg when (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num and is-fin)
B-sch
B-print
b-exp
B-schet
B-Help
b-hist
b-attr
br-fin-statement
b-curr
T-batch when (
            (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num)
          )
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
title0 = "Список выписок" + {&space-char}.

&scop run-file   input  p-open-query ~
, input  p-find-next ~
,  input  p-find-condition ~
~
,  INPUT parParentProc ~
,  input p-curr-host-code ~
~
,  input p-mode ~
~
,  input p-host-code ~
,  input p-status_    ~
,  input p-fins-doc-type ~
,  input p-fins-ext-doc-type ~
,  input p-start-date ~
,  input p-end-date    ~
,  input p-code-bank  ~
,  input p-code-schet  ~
,  input p-curr-code  ~
,  input-output v-rid-list ~
~
,  input filter-point  ~
,  input filter-point0 ~
,  input sort-column-name ~
,  output v-filter-name ~
,  input-output v-doc-rec ~
~
) .
filter-point = filter-point0 + p-mode.
if lookup(p-mode,
(
{&all}               + {&delim-par} +
{&company}           + {&delim-par} +
"code-schet"         + {&delim-par} +
"code-bank"          + {&delim-par} +
"currency":U
), {&delim-par}) > 0 then do:
  run ref/finscsq1.p ( {&run-file}
end.
if lookup(p-mode,
("type":U               + {&delim-par} +
"type-stat":U           + {&delim-par} +
"type-stat-date":U       + {&delim-par} +
"type-date":U
  ) , {&delim-par}) > 0 then do:
  run ref/finscsq2.p (  {&run-file}
end.
if lookup(p-mode,
("ext-type":U             + {&delim-par} +
"ext-type-stat":U        + {&delim-par} +
"ext-type-stat-date":U   + {&delim-par} +
"ext-type-date":U        + {&delim-par} +
"ext-type-stat-start"    + {&delim-par} +
"ext-type-stat-end"
  ) , {&delim-par}) > 0 then do:
  run ref/finscsq3.p ( {&run-file}
end.

&scop fins-doc-type-code p-fins-doc-type
if p-open-query then do:
  CASE p-mode :
    WHEN {&company} THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2", p-host-code, X_clients-host.obj-name).
    END.
    WHEN "currency":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, X_currency.curr-abbr).
    END.
    WHEN "code-schet":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Банк &3 Р/c Получателя &4"
                                              ,p-host-code
                                              , X_clients-host.obj-name
                                              , X_fin-bank.short-name
                                              , X_fin-schet.r-schet).
    END.
    WHEN "code-bank":U THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Банк &3"
                                              ,p-host-code
                                              , X_clients-host.obj-name
                                              , X_fin-bank.short-name
                                              ).
    END.
    WHEN 'type' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, {&fins-doc-type-name}).
    END.
    WHEN 'type-stat' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4",
                                    p-host-code, X_clients-host.obj-name, {&fins-doc-type-name}, p-status_).
    END.
    WHEN 'type-stat-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4 &5-&6",
                                    p-host-code, X_clients-host.obj-name, {&fins-doc-type-name}, p-status_,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'type-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &5-&6",
                                    p-host-code, X_clients-host.obj-name, {&fins-doc-type-name},
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'ext-type' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type).
    END.
    WHEN 'ext-type-stat'
    or
    when 'ext-type-stat-start'
    or
    when 'ext-type-stat-end'
    THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type, p-status_).
    END.
    WHEN 'ext-type-stat-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4 &5-&6",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type, p-status_,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'ext-type-date' THEN DO:
        ASSIGN
        frame {&frame-name}:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &5-&6",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").

    END.
  END CASE.
  ASSIGN frame {&frame-name}:TITLE =
  frame {&frame-name}:TITLE + {&space-char} + v-for-title.
  run set-filter-name in this-procedure ( INPUT v-filter-name) no-error .
end.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-fin-statement to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-fin-statement in frame {&frame-name}.
APPLY "ENTRY" TO br-fin-statement.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-option as character no-undo.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-code-schet like ub.fin-statement.code-schet no-undo.
define variable v-code-bank  like ub.fin-statement.code-bank no-undo.
define variable v-mode as character no-undo.
define variable vlog as logical no-undo .
define variable choice as integer no-undo .
define variable v-rid-list as character no-undo .
define variable loc-line-rec as recid no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-statement_add-def':U
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
v-mode = {&add-def}
.

CASE p-mode :
  WHEN {&company} THEN DO:
    assign
    v-code-schet = 0
    v-code-bank = 0
    .
  END.
  WHEN "currency":U THEN DO:
    assign
    v-code-schet = 0
    v-code-bank = 0
    .
  END.
  WHEN "code-schet":U THEN DO:
    assign
    v-code-schet = p-code-schet
    v-code-bank = p-code-bank
    .
  END.
  WHEN "code-bank":U THEN DO:
    assign
    v-code-schet = 0
    v-code-bank  = p-code-bank
    .
  END.
END CASE.

CASE p-option:
    when ''
    or
    when
    {&FSEDT_standard-sttm}
    then do:
            run ref/finstti1.w
                      (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input v-mode
                        ,input p-host-code /*p-host-code*/
                        ,input 0 /*p-sttm-code*/
                        ,input "":U /*p-fins-ext-doc-type*/
                        ,input v-code-bank
                        ,input v-code-schet
                        ,input "":U /*p-other*/
                        ,input-output loc-doc-rec
                        ,input-output loc-line-rec
                                    ) no-error
        .
    end.
END CASE.
if loc-doc-rec <> ? then do:
    RUn OpenBR in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid loc-doc-rec no-error.
end.
apply "entry" to br-fin-statement in frame {&frame-name}.
apply "value-changed" to br-fin-statement in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg-lookup Dialog-Frame
PROCEDURE proc-b-chg-lookup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-change-mode as character no-undo.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable loc-line-rec as recid no-undo .

if p-change-mode = {&update} then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-statement_update':U
    {&cntxt-firm}
    X_fin-statement.host-code
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
end.
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-statement_lookup':U
    {&cntxt-firm}
    X_fin-statement.host-code
    '':U
    0
    0
    0
    0
    true
    loc#log
  }

end.

if not loc#log then return error.

assign
loc-doc-rec = recid(X_fin-statement).
CASE X_fin-statement.fins-ext-doc-type:
  when '':U
  or when {&FSEDT_standard-sttm}
  then do:
    run ref/finstti1.w
                  (
                        input parParentProc
                        ,input p-curr-host-code /*p-curr-host-code*/
                        ,input p-change-mode
                        ,input X_fin-statement.host-code /*p-host-code*/
                        ,input 0 /*p-sttm-code*/
                        ,input "":U /*p-fins-ext-doc-type*/
                        ,input X_fin-statement.code-bank
                        ,input X_fin-statement.code-schet
                        ,input "":U /*p-other*/
                        ,input-output loc-doc-rec
                        ,input-output loc-line-rec
                   )
    .
  end.
END CASE.
if loc-doc-rec <> ? and p-change-mode = {&update} then do:
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  reposition br-fin-statement to recid loc-doc-rec no-error.
end.
apply "entry" to br-fin-statement in frame {&frame-name}.
apply "value-changed" to br-fin-statement in frame {&frame-name}.


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
define input parameter p-is-batch as logical no-undo .
define variable loc#log as logical no-undo.
define variable ii as integer no-undo .
define variable ok-ii as integer no-undo .
define variable v-new-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo.
define buffer buf_fin-statement for ub.fin-statement.

if not available X_fin-statement then return error.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-statement_deletion':U
  {&cntxt-firm}
  X_fin-statement.host-code
  '':U
  0
  0
  0
  0
  true
  loc#log
}

if not loc#log then return error.

CASE p-is-batch:
  when no then do:
      find first buf_fin-statement exclusive-lock where
      recid(buf_fin-statement) = recid(X_fin-statement) NO-ERROR.
      if not avail buf_fin-statement then return no-apply.
      IF buf_fin-statement.status_ <> {&fin-new}
      and buf_fin-statement.status_ <> {&fin-fact}
      THEN DO:
        MESSAGE
        "Выписка закрыта - удалять нельзя!"
        VIEW-AS ALERT-BOX ERROR.
        RETURN error.
      END.
      loc#log = no.
      MESSAGE
      "Вы уверены, что хотите удалить выписку?" skip(0)
      string(if buf_fin-statement.status_ = {&fin-fact} then "Выписка закрыта до статуса <факт>, удаление повлечет за собой перерасчет архивов" else "")
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
      IF loc#log <> YES THEN DO:
        RETURN error.
      END.
    do
    on error undo, return error
    on stop undo, return error

    :
      if buf_fin-statement.status_ = {&fin-fact} then do:
        run trg/finsttdl.p (
                        input buf_fin-statement.host-code
                       ,input buf_fin-statement.sttm-code
                       ,input yes /*удаление закртого на факт*/
                       ,input no) no-error.
        if error-status:error then do:
          message
          "Ошибка при удалении выписки, закрытой до статуса факт" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error .
        end.
      end.
      else do:
        run trg/finsttdl.p (
                        input buf_fin-statement.host-code
                       ,input buf_fin-statement.sttm-code
                       ,input no /*удаление закртого на факт*/
                       ,input no) no-error.
      end.
    end.
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to row 1 No-ERROR.
  end.
  when yes then do:
      loc#log = no.
      MESSAGE
      "Вы уверены, что хотите удалить ВСЕ отмеченные ВАМИ выписки?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
      IF loc#log <> YES THEN DO:
        RETURN error.
      END.
    do
    on error undo, return error
    on stop undo, return error

    :
      _do:
      do ii = 1 to num-entries(v-rid-list):
        run waitfram-show in this-procedure ( input substitute("Обрабатывается &1 выписка списка", ii)).
        find first buf_fin-statement where
            recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
        if ii = 1 then do:
          assign
          v-doc-rec = recid(buf_fin-statement)
          .
        end.
        if not avail buf_fin-statement
        or (buf_fin-statement.status_ <> {&fin-new}
        and buf_fin-statement.status_ <> "":U)
        then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
          .
          NEXT _do.
        end.
        if buf_fin-statement.status_ = {&fin-fact} then do:
          run trg/finsttdl.p (
                          input buf_fin-statement.host-code
                        ,input buf_fin-statement.sttm-code
                        ,input yes
                        ,input yes ) no-error.
        end.
        else do:
          run trg/finsttdl.p (
                          input buf_fin-statement.host-code
                        ,input buf_fin-statement.sttm-code
                        ,input no
                        ,input yes ) no-error.
        end.
        if error-status:error then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
          .
          NEXT _do.
        end.
        else do:
          assign
          ok-ii = ok-ii + 1
          .
        end.
      end.
    end.
    run waitfram-hide in this-procedure .
    assign
    v-rid-list = v-new-rid-list
    .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid integer(entry(1, v-rid-list)) No-ERROR.
    message
    substitute("Из &1 выбранных Вами выписок удалось удалить &2", ii - 1, ok-ii)
    view-as alert-box.
  end. /*when yes*/
END CASE.
APPLY "Value-CHanged" to br-fin-statement in frame {&frame-name}.
APPLY "ENTRY" to br-fin-statement in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exp Dialog-Frame
PROCEDURE proc-b-exp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo .
define variable accum-count-ok as integer no-undo .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define buffer buf_fin-statement for ub.fin-statement.
if not available X_fin-statement then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
define variable v-sys-key   as character         no-undo.
{ gbl/currsysk.i
  v-sys-key
  no-error
}
CASE t-batch:
  when no then do:
    assign
    v-file-name = /*"fs":U + string(X_fin-statement.sttm-code) + ".xml"*/ ?
    .
    run str/xmlfstt.p ( input X_fin-statement.host-code
                       ,input X_fin-statement.sttm-code
                       ,input-output v-file-name
                       ,input yes
                       ,input yes) no-error .
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одной выписки"
        view-as alert-box error.
        return error.
    end.
    run gbl/d-file.p
      (
       input-output v-file-name             /* p-file-id           */
      ,input-output for-dir                 /* p-file-directory    */
      ,input  (" Все файлы XML (*.xml) ") /* p-filter-names      */
      ,input  ("*.xml":U)                   /* p-filter-values     */
      ,input  {&comma-char}                 /* p-filter-delimiter  */
      ,input  (".xml":U)                    /* p-default-extension */
      ,input  no                            /* p-must-exist        */
      ,input  yes                           /* p-save-as           */
      ,input  yes                           /* p-use-filename      */
      ,input  "Введите имя файла"           /* p-title             */
      ,output loclog                       /* p-choose            */
      ) .
    if not loclog then do:
      return .
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    assign
    v-doc-rec = recid(X_fin-statement)
    ii0 = num-entries(v-rid-list)
    .

    _do:
    do ii = 1 to ii0:
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) no-error .

      if available buf_fin-statement then do:
        assign
        accum-count = accum-count + 1
        .
        run str/xmlfstt.p (
                        input buf_fin-statement.host-code
                      , input buf_fin-statement.sttm-code
                      , input-output v-file-name
                      , input (accum-count-ok = 0)
                      , input ii = ii0
                      ) no-error .
        if not error-status:error then
        assign
        accum-count-ok = accum-count-ok + 1
        .
      end.
    end. /*do ii*/
    run waitfram-hide in this-procedure .
  end.
END CASE.
if error-status:error
or (t-batch and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при выгрузке выписки(-ок) в XML-формате" skip
  string(if t-batch then substitute("Выгружено &1 выписок из &2", accum-count-ok, accum-count) else "":U)
  view-as alert-box .
  if not t-batch then
  return error .
end.

if search ("exmldoc.bat") <> ? then do:
  os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
end.
else do:
  if search (v-file-name ) <> ? then do:
    message "Выписки(-ы) выгружен(-ы) в файл " v-file-name view-as alert-box.
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
when 'ONE-GRAPHICS':U then do:
  RUN proc-print-one-graphics IN THIS-PROCEDURE.
end.
when 'LIST':U then do:
  run proc-print-list in this-procedure no-error.
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
  tbl = 'fin-statement'
  join-tbl = 'X_fin-statement'
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
run fltfield-add in this-procedure ( 'status_', '', 'fin-statement-stat',
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
               , INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-fin-statement Dialog-Frame
PROCEDURE proc-br-fin-statement :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { ref/brwsretr.i b-lkp }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-buttons Dialog-Frame
PROCEDURE proc-buttons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-batch as logical no-undo.
ENABLE
b-close when (is-fact-mode = no
              AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
              AND (p-curr-host-code = p-host-code
                  AND available X_sysconf
                  AND X_sysconf.firm-db-num = v-db-num)
              and is-fin
                  )
b-open when (is-fact-mode = no
            AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
            AND (p-curr-host-code = p-host-code
                AND available X_sysconf
                AND X_sysconf.firm-db-num = v-db-num)
            and is-fin
                )
b-reject when (is-fact-mode = no
              AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
              AND (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num)
             and is-fin
                    )
with frame {&frame-name} .
CASE p-is-batch:
    when yes then do:
        ENABLE
        B-mark
        with frame {&frame-name}.
        disable
        b-add
        b-chg with frame {&frame-name}.
      assign
      menu-item m_one:label     in menu menu-b-print = "Выбранные"
      menu-item m_one-graphics:label     in menu menu-b-print = "Выбранные-графика"
      menu-item m_one:sensitive in menu menu-b-print = (is-type-mode = yes).
    end.
    when no then do:
        ENABLE
        B-mark when lookup("b-mark":U, bttns) > 0
        B-add when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num
                    AND not p-is-batch
                    AND not(is-stat-mode = yes and p-status_ <> {&fin-new})
                    and is-fin
                    )
        B-chg when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num
                    and is-fin
                    )
        with frame {&frame-name}.
        DISABLE
        b-mark when lookup("b-mark":U, bttns) = 0
        with frame {&frame-name}.
        assign
        menu-item m_one:label     in menu menu-b-print = "Один"
        menu-item m_one-graphics:label     in menu menu-b-print = "Один-графика"
        menu-item m_one:sensitive in menu menu-b-print = yes.
    end.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-close-open Dialog-Frame
PROCEDURE proc-close-open :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-close-mode as character no-undo .
define input parameter p-is-batch as logical no-undo .

define variable v-status_ as character no-undo .
/*куда перейдет*/
define variable v-old-status_ as character no-undo .
/*статус первой записи*/
define variable v-fins-doc-type as character no-undo .
/*тип первой записи*/
define variable v-ask-date as logical no-undo .
/*дата перехода статуса*/
define variable v-ask-message as character no-undo .
/*подтверждающий запрос пользователю */
define variable v-status-date-chr as character no-undo.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable ok as logical no-undo .
define variable ii as integer no-undo.
define variable ok-ii as integer no-undo.
define variable v-new-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable glog as logical no-undo .

define buffer buf_fin-statement for ub.fin-statement.
if t-batch = no then do:
    if not available X_fin-statement then return error.
    assign
    v-doc-rec = recid(X_fin-statement).
end.
if t-batch = yes then do:
if v-rid-list = "":U then do:
    message
    "Вы не отметили ни одного платежа"
    view-as alert-box error.
    return error.
  end.
end.
do
on error undo, return error
:
  CASE t-batch:
    when no then do:
      find first buf_fin-statement where
                recid(buf_fin-statement) = recid(X_fin-statement) exclusive-lock no-error .
      if not avail buf_fin-statement then return error.
      assign
      v-old-status_ = buf_fin-statement.status_
      .
    end.
    when yes then do:
      _do:
      do ii = 1 to num-entries(v-rid-list):
        find first buf_fin-statement where
            recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
        if ii = 1 then do:
          assign
          v-old-status_ = buf_fin-statement.status_
          V-fins-doc-type = BUF_fin-statement.fins-doc-type
          v-doc-rec = recid(buf_fin-statement)
          .
        end.
        if not avail buf_fin-statement
        or (avail buf_fin-statement and v-old-status_ <> "":U and buf_fin-statement.status_ <> v-old-status_)
        or (avail buf_fin-statement and v-fins-doc-type <> "":U aND buf_fin-statement.fins-doc-type <> v-fins-doc-type)
        then NEXT _do.
        LEAVE _do.
      end.
    end.
  END CASE.
end. /*doe*/
run trg/finsgraf.p (
                 input  buf_fin-statement.host-code
                ,input  buf_fin-statement.sttm-code
                ,input  p-close-mode
                ,input  'cl-bank' /*много платежей неизвестно можн и ли нет*/
                ,input  v-old-status_
                ,input  ?                     /*p-status-date*/
                ,output v-status_
                ,output v-ask-date
                ,output v-ask-message
                ) no-error.
if error-status:error then do:
  message
  "Ошибка при проверке возможности" p-close-mode skip
  return-value
  view-as alert-box error.
  return error.
end.

case buf_fin-statement.fins-doc-type
:
  when {&standard-sttm}
  then do:
    if v-status_ = {&fin-fact}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_standard-sttm_close-fact':U
        {&cntxt-firm}
        buf_fin-statement.host-code
        '':U
        0
        0
        0
        0
        true
        OK
      }
    end.
    else do:
      case p-close-mode
      :
        when {&close-doc}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_standard-sttm_close-doc':U
            {&cntxt-firm}
            buf_fin-statement.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&open-doc}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_standard-sttm_open-doc':U
            {&cntxt-firm}
            buf_fin-statement.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        when {&reject-doc}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_standard-sttm_reject-doc':U
            {&cntxt-firm}
            buf_fin-statement.host-code
            '':U
            0
            0
            0
            0
            true
            OK
          }
        end.
        otherwise do:
          message
            "Ошибка при проверке возможности" p-close-mode skip
            "Неизвестное значение p-close-mode" skip
            view-as alert-box error.
          return error.
        end.
      end case .
    end.
  end.

  otherwise do:
    message
      "Ошибка при проверке возможности" p-close-mode skip
      "Неизвестный тип банковской выписки" buf_fin-statement.fins-doc-type skip
      view-as alert-box error.
    return error.
  end.
end case .



if not ok then return error.
ok = no.
message
v-ask-message skip(1)
(if t-batch
then
substitute("Все платежи, которые Вы отметили, но которые к настоящему моменту не находятся в статусе <&1>,&2 &3 обработаны не будут "
            , v-old-status_
            , {&new-line}
            , (if is-type-mode = no
              then substitute("или не имеют типа <&1>,", v-fins-doc-type)
              else "":U)
            )
  else "":U
)
view-as alert-box QUESTION buttons Yes-NO update ok.
if not ok then return error.

if v-ask-date then do:
  run cur-time in this-procedure ( output v-date, output v-time).
  assign
  v-status-date-chr = string(v-date, "99/99/9999":U)
  .
  run gbl/d-prompt.w (
      'title=':u + "Введите дату смены статуса платежа" + '\':u
    + 'text1=':u + "Дата смены статуса" + '\':u
    + 'format=99/99/9999\'
    + 'type=' + {&type-date} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\'
    , input-output v-status-date-chr
    ).
  if return-value = 'false':u then return error.
  assign
  v-date = date(integer(substr(v-status-date-chr, 4, 2)),
                integer(substr(v-status-date-chr, 1, 2)),
                integer(substr(v-status-date-chr, 7, 4))
               )
  no-error .
  if error-status:error then do:
    message
    "Неверная дата для смены статуса"
    view-as alert-box error .
    return error.
  end.
end. /*v-ask-date*/
run waitfram-show in this-procedure ( input "Ждите..." ).
CASE t-batch:
  when no then do:
    run trg/finsstat.p (
                     input buf_fin-statement.host-code
                    ,input buf_fin-statement.sttm-code
                    ,input p-close-mode
                    ,input '':U /*не из cl-bank*/
                    ,input v-status_
                    ,input-output v-date
                    ,input no /*p-silent*/
                   ) no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      if error-status:get-message(1) <> "":u then
      message
      error-status:get-message(1)  skip
      return-value view-as alert-box .
      return error .
    end.
    run waitfram-hide in this-procedure .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid v-doc-rec No-ERROR.
  end.
  when yes then do:
    _do1:
    do ii = 1 to num-entries(v-rid-list):
      run waitfram-show in this-procedure ( input substitute("Обрабатывается &1 платеж списка", ii)).
      find first buf_fin-statement where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
      if not avail buf_fin-statement
      or (avail buf_fin-statement and buf_fin-statement.status_ <> v-old-status_)
      or (avail buf_fin-statement and buf_fin-statement.fins-doc-type <> v-fins-doc-type)
      then DO:
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
        .
        NEXT _do1.
      END.
      run trg/finsstat.p (
                     input buf_fin-statement.host-code
                    ,input buf_fin-statement.sttm-code
                    ,input p-close-mode
                    ,input '':U /*не из cl-bank*/
                    ,input v-status_
                    ,input-output v-date
                    ,input no /*p-silent*/
                    ) no-error .
      if error-status:error then do:
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else {&comma-char}) + entry(ii, v-rid-list)
        .
        NEXT _do1 .
      end.
      assign
      ok-ii = ok-ii + 1
      v-new-rid-list = v-new-rid-list
      .
    end.
    run waitfram-hide in this-procedure .
    assign
    v-rid-list = v-new-rid-list
    .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid v-doc-rec No-ERROR.
    message
    substitute("Из &1 выбранных Вами платежей удалось сменить статус на &2 у &3 платежей", ii - 1, v-status_, ok-ii)
    view-as alert-box.
  end.
END CASE.

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
define input parameter p-bik like ub.fin-statement.bik no-undo.
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
     ,input substitute("and X_fin-statement.bik   begins &1 "
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
define input parameter p-curr-code like ub.fin-statement.curr-code no-undo.
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
     ,input substitute("and X_fin-statement.curr-code = &1 "
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
define input parameter p-date like ub.fin-statement.doc-date no-undo.
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
         ,input substitute("and X_fin-statement.doc-date = &1 "
                          , v-date-chr)
        ).
      apply "entry":u to sch-doc-date in frame {&frame-name}.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        ( input false /* p-open-query */
         ,input true  /* p-find-next  */
         ,input substitute("and X_fin-statement.fact-date = &1 "
                            , v-date-chr)
        ).
      apply "entry":u to sch-fact-date in frame {&frame-name}.
    end.
        when "bank-date":U then do:
       run OpenBr in this-procedure
        ( input false /* p-open-query */
         ,input true  /* p-find-next  */
         ,input substitute("and X_fin-statement.bank-date = &1 "
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
define input parameter p-prn-doc-code like ub.fin-statement.prn-doc-code no-undo.
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
     ,input substitute("and X_fin-statement.prn-doc-code = '&1'"
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
     ,input substitute("and X_fin-statement.r-schet   begins &1 "
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

DEFINE FRAME fin-statement-list
X_fin-statement.prn-doc-code FORMAT "X(22)"
X_fin-statement.code-schet COLUMN-LABEL "Вн.№счета"
X_fin-statement.start-date FORMAT "99/99/9999":U COLUMN-LABEL "С"
X_fin-statement.end-date FORMAT "99/99/9999":U COLUMN-LABEL "По"
X_fin-statement.doc-date
X_fin-statement.bank-date  COLUMn-LABEL "Дата прин!банком"
X_fin-statement.fact-date COLUMn-LABEL "Дата факт"
X_fin-statement.status_
X_fin-statement.sum-doc
X_fin-statement.cli-name COLUMN-LABEL "Назв.!плательщика" FORMAT "X(16)"
v-curr-abbr /*get-currency(buffer X_fin-statement) */ COLUMN-LABEL "Вал" FORMAT "X(3)"
X_fin-statement.sttm-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
X_fin-statement.cl-bank COLUMN-LABEL "Кл-банк"
X_fin-statement.host-code COLUMN-LABEL "Код!фирмы"
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

FORM with FRAME fin-statement-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_fin-statement).
DO WHILE available X_fin-statement :
  GET prev br-fin-statement.
END.
GET next br-fin-statement.
DO WHILE available X_fin-statement :
  if not t-batch or
  mark-string (recid(X_fin-statement), input v-rid-list) = "*":U then do:
    Display STREAM PrnLibStream
    X_fin-statement.prn-doc-code
    X_fin-statement.code-schet
    X_fin-statement.start-date
    X_fin-statement.end-date
    X_fin-statement.doc-date
    X_fin-statement.bank-date
    X_fin-statement.fact-date
    X_fin-statement.status_
    X_fin-statement.sum-doc
    X_fin-statement.cli-name
    get-currency(buffer X_fin-statement) @ v-curr-abbr
    X_fin-statement.sttm-code
    X_fin-statement.cl-bank
    X_fin-statement.host-code
    with FRAME fin-statement-list .
    DOWN STREAM PrnLibStream 1
    with FRAME fin-statement-list  .
  end.
  assign
  accum-count = accum-count + 1
  .
  GET next br-fin-statement.
END.
UNDERLINE  STREAM PrnLibStream
X_fin-statement.prn-doc-code
X_fin-statement.code-schet
X_fin-statement.start-date
X_fin-statement.end-date
X_fin-statement.doc-date
X_fin-statement.bank-date
X_fin-statement.fact-date
X_fin-statement.status_
X_fin-statement.sum-doc
X_fin-statement.cli-name
v-curr-abbr
X_fin-statement.sttm-code
X_fin-statement.cl-bank
X_fin-statement.host-code
with FRAME fin-statement-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_fin-statement.host-code
accum-count @ X_fin-statement.prn-doc-code
with frame fin-statement-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-statement-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-fin-statement to recid v-doc-rec no-error.
APPLY "entry" to br-fin-statement.
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
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer no-undo .
define variable v-format as integer no-undo .
define variable ii as integer no-undo .
if not available X_fin-statement then return error.
define buffer buf_fin-statement  for ub.fin-statement.

CASE t-batch:
  when no then do:
    run rep/finsttmp.p (
                    INPUT parParentProc
                    ,input X_fin-statement.host-code
                    ,input X_fin-statement.sttm-code
                    ,input T-batch /*p-append*/
                    ,input no /*p-is-last*/
                    ,input-output v-format
                  ) no-error.
    if error-status:error then do:
      return error.
    end.
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одной выписки"
        view-as alert-box error.
        return error.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    v-doc-rec = recid(X_fin-statement).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    output  STREAM PrnLibStream CLOSE.
    assign
    v-format = ?
    .
    _do:
    do ii = 1 to num-entries(v-rid-list):
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) no-error .

      if available buf_fin-statement then do:
        run rep/finsttmp.p (
                         INPUT parParentProc
                        ,input buf_fin-statement.host-code
                        ,input buf_fin-statement.sttm-code
                        ,T-batch
                        ,(if T-batch and (ii = num-entries(v-rid-list))
                          then yes
                          else no)
                        ,input-output v-format
                      ) no-error.
        if error-status:error or v-format = ? then do:
          next _do .
        end.
        assign
        accum-count = accum-count + 1
        .
      end.
    end. /*do ii*/
    run prn-lib-prn-file in this-procedure (
                                                   input parParentProc
                                                  ,input (if v-format = 0 then 0 else 8)
                                                 ).
    run waitfram-hide in this-procedure .
    APPLY "entry" to br-fin-statement in frame {&frame-name} .
  end.
END CASE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-one-graphics Dialog-Frame
PROCEDURE proc-print-one-graphics :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo .
define variable accum-count-ok as integer no-undo .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define variable v-template-code as character no-undo .
define variable v-copy-nums as integer no-undo .
define variable v-add-info as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

define buffer buf_fin-statement for ub.fin-statement.
if not available X_fin-statement then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
run gbl/filename.p (
                input "fxmlstt.bat"
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  message
  substitute("Не найден командный файл для графической печати выписок fxmlstt.bat:&1 &2", {&new-line}, return-value )
  view-as alert-box error .
  return error .
end.
if t-batch then
ii0 = num-entries(v-rid-list).
else ii0 = 1.
run ref/finstcgp.w (
                input X_fin-statement.fins-doc-type
               ,input X_fin-statement.fins-ext-doc-type
               ,input ii0
               ,output v-template-code
               ,output v-copy-nums
               ,output v-add-info) no-error.
if error-status:error
or v-template-code = "":U
then do:
  undo, return error.
end.
CASE t-batch:
  when no then do:
    assign
    v-file-name = ?
                        /*"f":U + string(X_fin-statement.sttm-code) + ".xml"*/
    .
    run str/xmlfstt.p ( input X_fin-statement.host-code
                       ,input X_fin-statement.sttm-code
                       ,input-output v-file-name
                       ,input yes
                       ,input yes) no-error .
    if not error-status:error then do:
      os-command silent value(search ("fxmldoc.bat") + {&space-char}
                                     + v-full-path + {&space-char}
                                     + v-file-name + {&space-char}
                                     + v-template-code + {&space-char}
                                     + string(v-copy-nums) + {&space-char}
                                     + v-add-info
                                     ).
      if os-error = 0 then
      assign
      accum-count-ok = accum-count-ok + 1
      .
    end.
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одного платежа"
        view-as alert-box error.
        return error.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    assign
    v-doc-rec = recid(X_fin-statement)
    .
    _do:
    do ii = 1 to ii0:
      run waitfram-show in this-procedure ( input substitute("Ждите... Обрабатывается &1-й документ, всего &2", accum-count + 1, ii0)).
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) no-error .

      if available buf_fin-statement then do:
        assign
        accum-count = accum-count + 1
        .
        assign
        v-file-name = ?
                        /*"f":U + string(X_fin-statement.sttm-code) + ".xml"*/
        .
        run str/xmlfstt.p (
                        input buf_fin-statement.host-code
                      , input buf_fin-statement.sttm-code
                      , input-output v-file-name
                      , input yes
                      , input yes
                      ) no-error .
        if not error-status:error then do:
          os-command silent value(search ("fxmldoc.bat") + {&space-char}
                                        + v-full-path + {&space-char}
                                        + v-file-name + {&space-char}
                                        + v-template-code + {&space-char}
                                        + string(v-copy-nums) + {&space-char}
                                        + v-add-info
                                        ).
          if os-error = 0 then
          assign
          accum-count-ok = accum-count-ok + 1
          .
        end.
      end.
    end. /*do ii*/
    run waitfram-hide in this-procedure .
  end.
END CASE.
if error-status:error
or (t-batch and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при печати платежа(-ей) в графике" skip
  string(if t-batch then substitute("Напечатано &1 платежей из &2", accum-count-ok, accum-count) else "":U)
  view-as alert-box .
  if not t-batch then
  return error .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-statement FOR ub.fin-statement ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

 define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
                buf_currency.curr-code = loc-fin-statement.curr-code no-error.
    if available buf_currency then return buf_currency.curr-abbr.

  RETURN string(loc-fin-statement.curr-code).   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME