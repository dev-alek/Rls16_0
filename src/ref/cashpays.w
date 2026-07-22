&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-cash-pay


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_cash-pay FOR ub.cash-pay.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-cash-pay
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник типов кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/25/05
Author: Bakhtadze Natalya
Creation date: 09/25/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns         as character  no-undo .
define input parameter p-list-mode  as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.

define output parameter p-rid-list      as character no-undo . /* список recid'ов выбранных аписей */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник типов кассовых платежей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ ref/cp-attr.i interface parparentproc  }
{ gbl/prn-lib.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }


define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable varwht-name like ub.wealth.wth-name no-undo.
DEFINE VARIABLE attr-option AS CHARACTER NO-UNDO.
define variable dcpr-option as character no-undo .
define variable v-rep-rec as recid no-undo .
define variable v-is-deploy as logical no-undo .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "cashpays".
define variable filter-label     as character NO-UNDO INIT "Список типов кассовых платежей".
define variable filter-point0     as character NO-UNDO INIT "cashpays".
define variable filter-label0     as character NO-UNDO INIT "Список типов кассовых платежей".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-cash-pay
&Scoped-define BROWSE-NAME br-cashpay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cash-pay

/* Definitions for BROWSE br-cashpay                                    */
&Scoped-define FIELDS-IN-QUERY-br-cashpay (IF ( CAN-DO (v-rid-list, string( recid( X_cash-pay ) ) ) ) THEN ("*") ELSE (" ")) X_cash-pay.cdpay-code X_cash-pay.obj-name X_cash-pay.curr-code X_cash-pay.pay-code X_cash-pay.status_ get-grp-name(input X_cash-pay.cdpay-code, X_cash-pay.curr-code) X_cash-pay.wth-code get-wth-name(X_cash-pay.wth-code) X_cash-pay.pay-limit X_cash-pay.is-cash X_cash-pay.atr1 X_cash-pay.atr2 X_cash-pay.atr4 X_cash-pay.atr8 X_cash-pay.atr16 X_cash-pay.atr32 X_cash-pay.atr64 X_cash-pay.atr128
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cashpay
&Scoped-define SELF-NAME br-cashpay
&Scoped-define QUERY-STRING-br-cashpay FOR EACH X_cash-pay NO-LOCK     BY X_cash-pay.cdpay-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-cashpay OPEN QUERY {&SELF-NAME} FOR EACH X_cash-pay NO-LOCK     BY X_cash-pay.cdpay-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-cashpay X_cash-pay
&Scoped-define FIRST-TABLE-IN-QUERY-br-cashpay X_cash-pay


/* Definitions for DIALOG-BOX d-cash-pay                                */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit mark-num b-sel B-mark b-add b-lkp ~
b-chg B-del B-attr B-disc b-hist B-sch b-print b-help f-obj-name br-cashpay
&Scoped-Define DISPLAYED-OBJECTS mark-num f-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-grp-name d-cash-pay
FUNCTION get-grp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS integer, INPUT p-curr-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-wth-name d-cash-pay
FUNCTION get-wth-name RETURNS CHARACTER
  ( input parwth-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup-attr  LABEL "Просмотр"
       MENU-ITEM m_update-attr  LABEL "Изменение"     .

DEFINE MENU MENU-B-disc
       MENU-ITEM m_lookup-disc  LABEL "Просмотр"
       MENU-ITEM m_update-disc  LABEL "Изменение"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON B-attr
     LABEL "&Атриб."
     SIZE 8 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-disc
     LABEL "&Скидки"
     SIZE 8 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Поиск по назв."
     VIEW-AS FILL-IN
     SIZE 16.5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-cashpay FOR
      X_cash-pay SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cashpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cashpay d-cash-pay _FREEFORM
  QUERY br-cashpay NO-LOCK DISPLAY
      (IF ( CAN-DO (v-rid-list, string( recid( X_cash-pay ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
X_cash-pay.cdpay-code FORMAT "9999":U
X_cash-pay.obj-name FORMAT "X(25)":U
X_cash-pay.curr-code COLUMN-LABEL "Валюта" FORMAT ">>9":U
X_cash-pay.pay-code COLUMN-LABEL "Вид оплаты" FORMAT "99999":U
X_cash-pay.status_ FORMAT "X(8)":U
get-grp-name(input X_cash-pay.cdpay-code, X_cash-pay.curr-code) COLUMN-LABEL "Группа" FORMAT "X(20)":U
X_cash-pay.wth-code COLUMN-LABEL "Код МЦ" FORMAT "999999999":U
get-wth-name(X_cash-pay.wth-code) COLUMN-LABEL "МЦ" FORMAT "X(20)":U
X_cash-pay.pay-limit COLUMN-LABEL "Предел без! авторизации" FORMAT "->>>,>>9.99":U
X_cash-pay.is-cash FORMAT "  +/":U
X_cash-pay.atr1 COLUMN-LABEL "Сдача" FORMAT "  +/":U
X_cash-pay.atr2 COLUMN-LABEL "Перевод" FORMAT "  +/":U
X_cash-pay.atr4 COLUMN-LABEL "Слип" FORMAT " +/":U
X_cash-pay.atr8 COLUMN-LABEL "Фактура" FORMAT "  +/":U
X_cash-pay.atr16 COLUMN-LABEL "On-line" FORMAT "  +/":U
X_cash-pay.atr32 COLUMN-LABEL "Обяз PIN" FORMAT "  +/":U
X_cash-pay.atr64 FORMAT "  +/":U
X_cash-pay.atr128 FORMAT "  +/":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 98 BY 20
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-cash-pay
     b-quit AT ROW 1 COL 1
     mark-num AT ROW 1 COL 9 COLON-ALIGNED NO-LABEL
     b-sel AT ROW 1 COL 17
     B-mark AT ROW 1 COL 27
     b-add AT ROW 1 COL 30
     b-lkp AT ROW 1 COL 40
     b-chg AT ROW 1 COL 50
     B-del AT ROW 1 COL 60
     B-attr AT ROW 1 COL 70
     B-disc AT ROW 1 COL 78
     b-hist AT ROW 1 COL 87
     B-sch AT ROW 1 COL 90 WIDGET-ID 2
     b-print AT ROW 1 COL 93
     b-help AT ROW 1 COL 96
     f-obj-name AT ROW 2 COL 21.5 COLON-ALIGNED WIDGET-ID 4
     br-cashpay AT ROW 3 COL 1
     SPACE(0.00) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ТИПЫ КАССОВЫХ ПЛАТЕЖЕЙ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_cash-pay B "?" ? ub cash-pay
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-cash-pay
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cashpay f-obj-name d-cash-pay */
ASSIGN
       FRAME d-cash-pay:SCROLLABLE       = FALSE.

ASSIGN
       B-attr:POPUP-MENU IN FRAME d-cash-pay       = MENU MENU-B-attr:HANDLE.

ASSIGN
       B-disc:POPUP-MENU IN FRAME d-cash-pay       = MENU MENU-B-disc:HANDLE.

ASSIGN
       br-cashpay:NUM-LOCKED-COLUMNS IN FRAME d-cash-pay     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cashpay
/* Query rebuild information for BROWSE br-cashpay
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cash-pay NO-LOCK
    BY X_cash-pay.cdpay-code INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.cash-pay.cdpay-code|yes"
     _Query            is NOT OPENED
*/  /* BROWSE br-cashpay */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-cash-pay
/* Query rebuild information for DIALOG-BOX d-cash-pay
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-cash-pay */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-cash-pay d-cash-pay
ON GO OF FRAME d-cash-pay /* ТИПЫ КАССОВЫХ ПЛАТЕЖЕЙ */
DO:
  IF b-sel:SENSITIVE THEN DO:
     if ( available X_cash-pay ) AND ( v-rid-list = "" ) THEN DO:
         v-rid-list = string( recid( X_cash-pay ) ) .
     END.
  END.
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-cash-pay
ON CHOOSE OF b-add IN FRAME d-cash-pay /* Добавить */
DO:
  define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_payments-types_input-deletion-updating':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
  }
  if NOT glog then return no-apply .
  run ref/cashpayi.w ( input parparentproc
                  ,input {&add-def}
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  , input-output rr ).
  if rr <> ? then do:
    run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
    reposition br-cashpay to recid rr no-error .
    log-res  = br-cashpay:select-focused-row( ).
    apply "ENTRY":U to br-cashpay.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr d-cash-pay
ON CHOOSE OF B-attr IN FRAME d-cash-pay /* Атрибуты */
DO:
  if not available X_cash-pay THEN return no-apply.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if attr-option = "":U then do:
      return no-apply.
  end.
  IF attr-option = {&UPDATE} THEN DO:
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_payments-types_input-deletion-updating':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    glog
    }
    if NOT glog then return no-apply .
  END.
  run ref/cp-atti.w ( input parparentproc
                ,input attr-option
                ,input X_cash-pay.cdpay-code
                ,input X_cash-pay.curr-code
                ,input p-host-code
                ,input p-obj-type
                ,input p-obj-code
               ) NO-ERROR.
  if attr-option = {&update} then do:
    br-cashpay:refresh().
  end.
  attr-option = "":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-cash-pay
ON CHOOSE OF b-chg IN FRAME d-cash-pay /* Изменить */
DO:
define variable glog as logical no-undo .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_payments-types_input-deletion-updating':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply .
if not available X_cash-pay THEN
    return no-apply.
rr = recid( X_cash-pay ).
run ref/cashpayi.w (
                input parparentproc
              ,input {&update}
              ,input p-host-code
              ,input p-obj-type
              ,input p-obj-code
              ,input-output rr ).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition br-cashpay to recid rr no-error .
apply "ENTRY" to br-cashpay.
/*
    disp X_cash-pay.obj-name with browse br-cashpay.
*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del d-cash-pay
ON CHOOSE OF B-del IN FRAME d-cash-pay /* Удалить */
DO:
define variable v-status_ like ub.cash-pay.status_ no-undo.
define variable v-rec as recid no-undo.
define variable glog as logical no-undo .
if not available X_cash-pay then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_payments-types_input-deletion-updating':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then  return no-apply .
assign
v-rec = recid(X_cash-pay).
run ref/cashpay3.p (recid(X_cash-pay),  input-output v-status_) no-error.
if not error-status:error then do:
  run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
  REPOSITION br-cashpay to recid v-rec No-error.
  if available X_cash-pay then do:
    log-res = br-cashpay:select-focused-row( ).
  end.
end.
apply "ENTRY" to br-cashpay.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-disc d-cash-pay
ON CHOOSE OF B-disc IN FRAME d-cash-pay /* Скидки */
DO:
  if not available X_cash-pay THEN return no-apply.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if dcpr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if dcpr-option = "":U then do:
      return no-apply.
  end.
  run ref/discprui.w ( input parparentproc
                ,input dcpr-option
                ,input X_cash-pay.cdpay-code
                ,input X_cash-pay.curr-code
                ,input p-host-code
                ,input p-obj-type
                ,input p-obj-code
               ) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-cash-pay
ON CHOOSE OF b-hist IN FRAME d-cash-pay /* История */
DO:
  define variable v-rid-list as character no-undo.
 if not available X_cash-pay then return no-apply.
      run ref/ccashpay.w (
                         input parparentproc
                       , INPUT "":U /*bttns*/
                       , INPUT "one":U /*parref-mode*/
                       , OUTPUT  v-rid-list
                       , INPUT X_cash-pay.cdpay-code
                       , INPUT X_cash-pay.curr-code
                       , input "":U /*p-subject*/
                        ) no-error .

    apply "entry" to br-cashpay.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-cash-pay
ON CHOOSE OF b-lkp IN FRAME d-cash-pay /* Просмотр */
DO:
    if not available X_cash-pay THEN
        return no-apply.
    rr = recid( X_cash-pay ).
    run ref/cashpayi.w (
                   input parparentproc
                  ,input {&lookup}
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  , input-output rr ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-cash-pay
ON CHOOSE OF B-mark IN FRAME d-cash-pay /* * */
DO:
 define variable glog as logical no-undo .
 if not available X_cash-pay then return no-apply.
 { gbl/markstrn.i X_cash-pay v-rid-list }
 glog = br-cashpay  :refresh( ) in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          glog = br-cashpay:select-next-row () in frame {&frame-name}.
          apply "iteration-changed" to br-cashpay in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-cashpay in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-cash-pay
ON CHOOSE OF b-print IN FRAME d-cash-pay /* Печать */
DO:
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.

define variable Line                    as char         no-undo.

define variable ii      as integer   no-undo.
define variable StartRecid      as integer   no-undo.

DEFINE FRAME List
sym1 column-label ":" format "x(1)"
X_cash-pay.cdpay-code column-label "Код" format "9999"
sym2 column-label ":" format "x(1)"
X_cash-pay.obj-name column-label "Наименование" format "x(34)"
sym3 column-label ":" format "x(1)"
X_cash-pay.curr-code column-label "Валюта" format ">>>>>9"
sym4 column-label ":" format "x(1)"
X_cash-pay.pay-limit column-label "Предел" format "->>>,>>9.99"
X_cash-pay.atr1 COLUMN-LABEL "Сдача" FORMAT "  +/"
X_cash-pay.atr2 COLUMN-LABEL "Перевод" FORMAT "  +/"
X_cash-pay.atr4 COLUMN-LABEL "Слип" FORMAT " +/"
X_cash-pay.atr8 COLUMN-LABEL "Фактура" FORMAT "  +/"
X_cash-pay.atr16 COLUMN-LABEL "On-line" FORMAT "  +/"
X_cash-pay.atr32 COLUMN-LABEL "Обяз PIN" FORMAT "  +/"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(110)" AT 1
with width {&A4_CW} down use-text stream-io no-box .

if num-results( "br-cashpay" ) = 0 then  do:
    message "Список  П У С Т !" skip view-as alert-box information .
    return no-apply .
end.

    if session:set-wait-state( "compiler" ) then .
    Line = fill( "-" , 140 ) .
/*
    Это из-за того, что в QUERY br-cashpay используется index reposition и,
    как следствие, не работает GET first br-cashpay  ( ошибка 3157 )
*/
    StartRecid = recid( X_cash-pay ) .
DO WHILE available X_cash-pay :
    GET prev br-cashpay NO-LOCK .
END.
GET next br-cashpay NO-LOCK .
ii = 1 .

run prn-lib-open-stream  in this-procedure (
                                            input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
FORM HEADER
Line format "X(130)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(20)
    "С П И С О К   К А С С О В Ы Х   Т И П О В   П Л А Т Е Ж Е Й" format "X(100)" SKIP(2) .
FORM with frame List .
DO WHILE available X_cash-pay :
    DISPLAY stream PrnLibStream
    sym1 X_cash-pay.cdpay-code
    sym2 X_cash-pay.obj-name
    sym3 X_cash-pay.curr-code
    sym4 X_cash-pay.pay-limit
    X_cash-pay.atr1
    X_cash-pay.atr2
    X_cash-pay.atr4
    X_cash-pay.atr8
    X_cash-pay.atr16
    X_cash-pay.atr32
    sym6    with frame List .
    DOWN stream PrnLibStream 1 with frame List .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
      run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
    GET next br-cashpay .
END.
PUT stream PrnLibStream Line format "X(110)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
reposition br-cashpay to recid StartRecid NO-ERROR .
run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch d-cash-pay
ON CHOOSE OF B-sch IN FRAME d-cash-pay /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-cash-pay
ON CHOOSE OF b-sel IN FRAME d-cash-pay /* Выбор  */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cashpay
&Scoped-define SELF-NAME br-cashpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cashpay d-cash-pay
ON DEFAULT-ACTION OF br-cashpay IN FRAME d-cash-pay
DO:
  case yes:
      when  b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cashpay d-cash-pay
ON MOUSE-SELECT-DBLCLICK OF br-cashpay IN FRAME d-cash-pay
DO:
    if can-do( bttns, "b-sel" ) THEN do:
      apply "choose" to b-sel in frame {&frame-name} .
      return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cashpay d-cash-pay
ON RETURN OF br-cashpay IN FRAME d-cash-pay
DO:
    if can-do( bttns, "b-sel" ) THEN do:
      apply "choose" to b-sel in frame {&frame-name} .
      return no-apply .
    end.
    ELSE DO:
      apply "DEFAULT-ACTION":U to self.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-obj-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-obj-name d-cash-pay
ON RETURN OF f-obj-name IN FRAME d-cash-pay /* Поиск по назв. */
OR ctrl-J OF f-obj-name IN FRAME {&frame-name} DO:
 DEFINE VARIABLE v-next AS LOGICAL NO-UNDO.
 IF LAST-EVENT:LABEL = "CTRL-J" THEN DO:
   v-next = YES.
 END.
  assign f-obj-name.
  run proc-find in THIS-PROCEDURE ( INPUT v-next, input frame {&frame-name} f-obj-name) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-attr d-cash-pay
ON CHOOSE OF MENU-ITEM m_lookup-attr /* Просмотр */
DO:
   assign
  ATTR-option = {&LOOKUP}
  .
  APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-disc d-cash-pay
ON CHOOSE OF MENU-ITEM m_lookup-disc /* Просмотр */
DO:
  assign
  dcpr-option = {&lookup}
  .
  APPLY "CHOOSE" TO b-disc IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-attr d-cash-pay
ON CHOOSE OF MENU-ITEM m_update-attr /* Изменение */
DO:
  assign
  ATTR-option = {&UPDATE}
  .
  APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-disc d-cash-pay
ON CHOOSE OF MENU-ITEM m_update-disc /* Изменение */
DO:
  assign
  dcpr-option = {&UPDATE}
  .
  APPLY "CHOOSE" TO b-disc IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-cash-pay


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/brwrefre.i " v-rep-rec = ?. if available X_cash-pay then v-rep-rec = recid(X_cash-pay). ~
               run openbr in this-procedure ( input yes, input no, input '':U) no-error. ~
               REPOSITION br-cashpay to recid v-rep-rec No-ERROR." }


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

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

ON END-ERROR, ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
   if error-status:error then return no-apply.
   else do:
     v-rid-list = '':U.
   end.
END.


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if lookup('s-deploy', bttns) > 0 then do:
      assign
      v-is-deploy = yes.
    end.
    { gbl/getcntxt.i get }
    define variable v-parent-handle as handle no-undo .
    v-parent-handle = this-procedure:instantiating-procedure .
    // ак как запустили из класса v-parent-handle не существует
    if valid-object(v-parent-handle) and lookup("cb_set-cp-list", v-parent-handle :internal-entries) > 0 then do:
      run cb_set-cp-list in v-parent-handle (output p-rid-list).
    end.
    v-rid-list = p-rid-list.
    RUN enable_UI.
    if num-entries (v-rid-list) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp
        num-entries (v-rid-list) @ mark-num
        with frame {&frame-name}.
    apply 'entry':U to br-cashpay.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-cash-pay  _DEFAULT-DISABLE
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
  HIDE FRAME d-cash-pay.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-cash-pay
PROCEDURE enable_UI :
ASSIGN
b-attr:MENU-MOUSE IN frame {&FRAME-NAME} = 1
B-disc:MENU-MOUSE IN frame {&FRAME-NAME} = 1
.
ENABLE
br-cashpay
b-quit
b-add WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0)
b-sel WHEN lookup("b-sel", bttns) > 0
b-mark when lookup("b-mark", bttns) > 0
b-chg WHEN (lookup("b-add", bttns) > 0  and v-cntxt-db-num = 0)
b-del WHEN (lookup("b-add", bttns) > 0  and v-cntxt-db-num = 0)
b-sch
b-disc
b-ATTR when not v-is-deploy
b-lkp
b-print when valid-handle(parparentproc) and not v-is-deploy
b-hist when not v-is-deploy
b-help
f-obj-name
WITH FRAME {&frame-name} .
run Openbr in this-procedure ( input yes, input no, input '':U) no-error.
if available X_cash-pay then
log-res  = br-cashpay:select-focused-row( ).
if  (lookup("b-add", bttns) = 0  or v-cntxt-db-num > 0) then do:
  assign
  menu-item m_update-disc:sensitive in menu menu-b-disc = no.
end.
IF NOT  (can-do( bttns, "b-add" )  and v-cntxt-db-num = 0)
or p-host-code = 0
or p-obj-code = 0
THEN DO:
ASSIGN
MENU-ITEM M_UPDATE-attr:SENSITIVE  IN MENU menu-b-attr = NO.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr d-cash-pay
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define buffer buf_clients for clients.

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

&scop flt-open-open-query         OPEN QUERY br-cashpay FOR EACH X_cash-pay

&scop flt-open-dyn_open-query      FOR EACH X_cash-pay

&scop flt-open-query-handle        QUERY br-cashpay:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened   l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point         filter-point

&scop flt-open-set-filter-name    set-filter-name

&scop flt-open-indexed-reposition INDEXED-REPOSITION

&scop flt-open-find-next p-find-next

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-recid v-rep-rec

&scop flt-open-find-buffer-name  X_cash-pay

&scop flt-open-waitfram yes

&scop flt-open-table-name X_cash-pay

&scop flt-open-search-option no-lock

&scop flt-open-query p-open-query


/*filter-point = filter-point0 + p-list-mode .*/


title0 = "ТИПЫ КАССОВЫХ ПЛАТЕЖЕЙ".
case p-list-mode:
  when {&all} then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1: ВСЕ", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    { gbl/fltopend.i
    &where-cond = " true "
    &use-ind    = "  "
    &by         = " BY X_cash-pay.cdpay-code  " }


  end.
  when "with-return" then do:
    ASSIGN
    frame {&frame-name}:title = substitute("&1 для которых разрешен возрат", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame {&frame-name}:title
                              )
    .
    { gbl/fltopend.i
    &where-cond = " X_cash-pay.has-return = 1 "
    &use-ind    = "  "
    &by         = " BY X_cash-pay.cdpay-code  " }


  end.
end case.

if not p-open-query and v-rep-rec <> ? then
REPOSITION br-cashpay to recid v-rep-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-cashpay:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

APPLY "entry" TO br-cashpay.
if available X_cash-pay then do:
    APPLY "VALUE-CHANGED":U to {&browse-name}.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch d-cash-pay
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_cash-pay then recid(X_cash-pay) else ?)
.
assign
tbl = 'cash-pay'
join-tbl = 'X_cash-pay'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('cdpay-code', 'Код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Код валюты', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code', 'Вид оплаты', 'pay',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wth-code', 'Код МЦ', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-limit', 'Предел без авторизации', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('slip-file-name', 'Имя файла слипа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('rule-file-name', 'Имя файла правил обработки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-cash', 'Наличные', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr1', 'Разрешается сдача', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr2', 'Разрешен перевод оплаты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr4', 'Принудит. печать слипа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr8', 'Принудительная печать фактуры', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr16', 'Необход.On-line авториз.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr32', 'Обяз.PIN', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr64', 'Топливный платеж', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-credit', 'Платеж <В КРЕДИТ>', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('(register > 0)', 'Ведомость', 'function_logical',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('atr128', 'Платеж по Smart карте', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-credit-card', 'Кредитная карта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-debet-card', 'Дебетовая карта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-goods-pay', 'Платеж за товары', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-service-pay', 'Платеж за услуги', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-all-pay', 'ОБЩИЙ платеж', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-card-swap', 'Прокатывать карту', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-bar-read', 'Использовать сканер баркодов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-advance', 'Учет авансового платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-card-view', 'Префиксы N плат.карт для просмотра', '',
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
      reposition br-cashpay to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-cashpay in frame {&frame-name} .
    APPLY "VALUE-CHANGED" to br-cashpay.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find d-cash-pay
PROCEDURE proc-find :
define input parameter p-next as logical no-undo.
define input parameter p-obj-name like ub.cash-pay.obj-name no-undo.
assign
p-obj-name = replace(p-obj-name, {&double-quote}, "":U)
p-obj-name = replace(p-obj-name, {&single-quote}, {&single-quote} + {&single-quote})
p-obj-name = {&double-quote} + p-obj-name + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute(" and X_cash-pay.obj-name  begins &1 " , p-obj-name)
    ).
apply "entry":u to f-obj-name in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-grp-name d-cash-pay
FUNCTION get-grp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS integer, INPUT p-curr-code AS INTEGER ) :

    DEFINE VARIABLE v-dop AS character NO-UNDO .
   DEFINE VARIABLE v-value AS character NO-UNDO.
   DEFINE VARIABLE v-type AS character NO-UNDO.
     RUN cp-attr-value  IN THIS-PROCEDURE(
       input p-cdpay-code
       ,input p-curr-code
       ,input 0 /*p-host-code    */
       ,input '':U /*p-obj-type     */
       ,input 0 /* p-obj-code     */
       ,INPUT {&cp-attr-grp-code}
       ,output v-value
       ,OUTPUT v-type) NO-ERROR.

     IF NOT ERROR-STATUS:ERROR THEN DO:
         ASSIGN
         v-dop = entry(1, v-value, {&delim-par})
         .
     END.
     RETURN v-dop.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-wth-name d-cash-pay
FUNCTION get-wth-name RETURNS CHARACTER
  ( input parwth-code as integer) :
define buffer buf_wealth for ub.wealth.
if parwth-code > 0 then do:
    FIND FIRST buf_wealth no-lock where
                     buf_wealth.wth-code = X_cash-pay.wth-code No-ERROR.
        if avail buf_wealth then do:
           return buf_wealth.wth-name .
        end.
     end.
  RETURN "?".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME