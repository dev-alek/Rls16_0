&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_payment FOR ub.payment.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/16/05
Author: Bakhtadze Natalya
Creation date: 11/16/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/*справочник можно запускать в разных режимах в зависимолсти от значечния p-list-mode*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-list-mode as character no-undo .

/*p-list-mode бывает
{&all}
{client-cmp}
{client-cmp} + {&comma-char} + {&expected}
{client-cmp} + {&comma-char} + {&fact}
{&payer}
{&documents}
{&documents} + {&comma-char} + {&expected}
{&documents} + {&comma-char} + {&fact}
{&card}
*/


define input parameter cli-recid  as recid no-undo .
/*ссылка на клиента если list-mode = {&client-cmp} или {&client-cmp} + {&comma-char} + {&expected} */
define input parameter payer-recid  as recid no-undo .
/*сслыка на плательщика если list-mode {&payer}*/
define input parameter loc-source-type as char no-undo. ~
define input parameter loc-source-ref as char no-undo. ~
/*ссылка на документ если list-mode {&documents}*/
define input parameter loc-d-card as char no-undo. ~
/*ссылка на карту если list-mode {&card}*/
define output parameter p-rid-list    as  char no-undo . /* список recid'ов выбранных payment */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Cправочник платежей" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/flt-def.i  }
{ gbl/color.i    }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "payments" .
define variable filter-point0 as character no-undo init "payments" .
define variable filter-label as character no-undo init "Платежи" .
define variable filter-label0 as character no-undo init "Платежи" .

define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE NEW SHARED BUFFER buf-cli for ub.clients.
DEFINE NEW SHARED BUFFER buf-payer for ub.clients.
DEFINE NEW SHARED BUFFER buf-cli-card for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable v-doc-rec as recid no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-payment

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_payment

/* Definitions for BROWSE BR-payment                                    */
&Scoped-define FIELDS-IN-QUERY-BR-payment mark-string( recid( X_payment ) , v-rid-list) X_payment.pmnt-code X_payment.fact-date X_payment.status_ X_payment.creid X_payment.closid get-cli-name (buffer X_payment) X_payment.source-type X_payment.source-ref X_payment.d-card X_payment.tot-cli X_payment.tot-base X_payment.tot-rubl X_payment.exch-code X_payment.exch-date X_payment.exch-rate X_payment.exch-scale X_payment.base-rate X_payment.base-scale X_payment.due-date X_payment.pay-code get-payer-name (buffer X_payment)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-payment X_payment.tot-cli
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-payment X_payment
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-payment X_payment
&Scoped-define SELF-NAME BR-payment
&Scoped-define QUERY-STRING-BR-payment FOR EACH X_payment NO-LOCK
&Scoped-define OPEN-QUERY-BR-payment OPEN QUERY {&SELF-NAME} FOR EACH X_payment NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-payment X_payment
&Scoped-define FIRST-TABLE-IN-QUERY-BR-payment X_payment


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-payment}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-sel B-mark B-add B-lkp B-chg B-del ~
B-print B-sch B-Help BR-payment ed-notes mark-num
&Scoped-Define DISPLAYED-OBJECTS ed-notes mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-payment for ub.payment )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-full-source Dialog-Frame
FUNCTION get-full-source RETURNS CHARACTER
   (buffer loc-payment for ub.payment )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-payer-name Dialog-Frame
FUNCTION get-payer-name RETURNS CHARACTER
  (buffer loc-payment for ub.payment )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.88 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-payment FOR
      X_payment SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-payment
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-payment Dialog-Frame _FREEFORM
  QUERY BR-payment DISPLAY
      mark-string( recid( X_payment ) , v-rid-list) COLUMN-LABEL "*" FORMAT "x(1)"
X_payment.pmnt-code FORMAT "X(19)"
X_payment.fact-date
X_payment.status_
X_payment.creid   column-label "Создал!+сорт"
X_payment.closid column-label "Закрыл!+сорт"
get-cli-name (buffer X_payment) COLUMN-LABEL "Контрагент" FORMAT "X(20)"
X_payment.source-type COLUMN-LABEL "К док-ту" format "X(16)"
X_payment.source-ref COLUMN-LABEL "N док-та" format "X(20)"
X_payment.d-card
X_payment.tot-cli column-label "Сумма пл-жа!+сорт"
X_payment.tot-base
X_payment.tot-rubl
X_payment.exch-code
X_payment.exch-date column-label "Курс конверт.!+сорт"
X_payment.exch-rate
X_payment.exch-scale
X_payment.base-rate
X_payment.base-scale
X_payment.due-date
X_payment.pay-code COLUMN-LABEL "Вид опл.!+сорт"
get-payer-name (buffer X_payment) COLUMN-LABEL "Плательщик" FORMAT "X(20)"
ENABLE X_payment.tot-cli
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1.13
     B-sel AT ROW 1 COL 11
     B-mark AT ROW 1 COL 21
     B-add AT ROW 1 COL 24
     B-lkp AT ROW 1 COL 34
     B-chg AT ROW 1 COL 44
     B-del AT ROW 1 COL 54
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-payment AT ROW 3.21 COL 1.13
     ed-notes AT ROW 19.63 COL 1.13 NO-LABEL
     mark-num AT ROW 2.17 COL 2.88 NO-LABEL
     SPACE(86.34) SKIP(18.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Платежи"
         DEFAULT-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_payment B "?" ? ub payment
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-payment B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-payment:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 4.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-payment
/* Query rebuild information for BROWSE BR-payment
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_payment NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-payment */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Платежи */
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Платежи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable rid as recid no-undo init ?.
  define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_payments-expected_work':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  glog
  }
  if NOT glog then do:
    return no-apply.
  end.
  case p-list-mode:
    when {&documents} then do:
      /*если заказы то можно вводить ожидаемый платеж*/
      if loc-source-type = {&pmnt-ord-doc} and loc-source-ref <> ""  then do:
        run ref/paymento.w (
                        input parparentproc
                       ,input {&add-def}
                       ,input-output rid
                       ,input buf-cli.obj-type
                       ,input buf-cli.obj-code
                       ,input v-cntxt-host-code-obj
                       ,input loc-source-type
                       ,input loc-source-ref
                       ,input '':U
                       ,input ? /*tot-cli*/
                       ,input ? /*exch-code*/
                       ,input ? /*base-rate*/
                       ,input ? /*base-scale*/
                       ,input ? /*exch-rate*/
                       ,input ? /*exch-scale*/
                       ,input ? /*exch-date*/
                       ,input ? /*pay-code*/
                       ,input ? /*fact-date*/
                       ) no-error .
        if rid = ? then return no-apply.
        else do:
          run openbr in this-procedure ( input yes, input no, input '':U).
          reposition br-payment to recid rid no-error.
          APPLY "Value-CHanged" to br-payment.
          APPLY "ENTRY" to br-payment.
        end.
      end.
    end. /*when {&documents}*/
    when {&card} then do:
      /*если карты то можно вводить платеж*/
      run ref/paymento.w (
                       input parparentproc
                      ,input {&add-def}
                      ,input-output rid
                      ,input buf-cli-card.obj-type
                      ,input buf-cli-card.obj-code
                      ,input v-cntxt-host-code-obj
                      ,input {&table_payment}
                      ,input '':U
                      ,input buf_dis-card.d-card
                      ,input ? /*tot-cli*/
                      ,input ? /*exch-code*/
                      ,input ? /*base-rate*/
                      ,input ? /*base-scale*/
                      ,input ? /*exch-rate*/
                      ,input ? /*exch-scale*/
                      ,input ? /*exch-date*/
                      ,input ? /*pay-code*/
                      ,input ? /*fact-date*/
                      ) no-error .
      if rid = ? then return no-apply.
      else do:
        run openbr in this-procedure ( input yes, input no, input '':U).
        reposition br-payment to recid rid no-error.
        APPLY "Value-CHanged" to br-payment.
        APPLY "ENTRY" to br-payment.
      end.
    end. /*when {&card}*/
    otherwise do:
      "BELL".
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable rid as recid no-undo init ?.
  define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_payments-expected_work':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  glog
  }

  if NOT glog then do:
    return no-apply.
  end.
  if avail X_payment and X_payment.status_ <> {&fact} then do:
    rid = recid(X_payment).
    case p-list-mode:
      when {&documents} then do:
        /*если заказы то можно вводить ожидаемый платеж*/
        if loc-source-type = {&pmnt-ord-doc} and loc-source-ref <> ""  then do:
          run ref/paymento.w (input parparentproc
                         ,input {&update}
                         ,input-output rid
                         ,input buf-cli.obj-type
                         ,input buf-cli.obj-code
                         ,input v-cntxt-host-code-obj
                         ,input loc-source-type
                         ,input loc-source-ref
                         ,input X_payment.d-card
                         ,input ? /*tot-cli*/
                         ,input ? /*exch-code*/
                         ,input ? /*base-rate*/
                         ,input ? /*base-scale*/
                         ,input ? /*exch-rate*/
                         ,input ? /*exch-scale*/
                         ,input ? /*exch-date*/
                         ,input ? /*pay-code*/
                         ,input ? /*fact-date*/
                         ) .
          if rid = ? then return no-apply.
          else do:
            run openbr in this-procedure ( input yes, input no, input '':U).
            reposition br-payment to recid rid no-error.
            APPLY "Value-CHanged" to br-payment.
            APPLY "ENTRY" to br-payment.
          end.
        end.
      end. /*when {&documents}*/
      otherwise do:
          "BELL".
      end.
    END CASE.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define buffer for-payment for ub.payment.
  define variable glog as logical no-undo .
  if avail X_payment and X_payment.status_ <> {&fact} then do:
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_payments-expected_work':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    glog
    }
    if NOT glog then do:
      return no-apply.
    end.
    find first for-payment where
               recid(for-payment) = recid(X_payment) exclusive-lock no-wait no-error.
    if locked for-payment or
              not avail for-payment OR
              NOT for-payment.status_ = {&expected} then return no-apply.
    else do:
        delete for-payment no-error.
        if error-status:error then return no-apply.
        run OpenBr in this-procedure ( input yes, input no, input '':U).
        reposition br-payment to row 1 no-error.
        if error-status:error then do:
            ed-notes = "".
            display
            ed-notes
            WITH FRAME {&frame-name}.
        end.

        APPLY "ENTRY" to br-payment.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  define variable rid as recid no-undo init ?.
  if avail X_payment then do:
    if X_payment.host-code <> v-cntxt-host-code-obj then do:
        message "Выбран платеж другой фирмы!"
        view-as alert-box.
        return no-apply.
    end.
     rid = recid(X_payment).
    case p-list-mode:
      when {&documents} then do:
        /*если заказы то можно вводить ожидаемый платеж*/
        if loc-source-type = {&pmnt-ord-doc} and loc-source-ref <> ""  then do:
          run ref/paymento.w (
                                input parparentproc
                              ,input {&lookup}
                              ,input-output rid
                              ,input buf-cli.obj-type
                              ,input buf-cli.obj-code
                              ,input v-cntxt-host-code-obj
                              ,input loc-source-type
                              ,input loc-source-ref
                              ,input X_payment.d-card
                              ,input ? /*tot-cli*/
                              ,input ? /*exch-code*/
                              ,input ? /*base-rate*/
                              ,input ? /*base-scale*/
                              ,input ? /*exch-rate*/
                              ,input ? /*exch-scale*/
                              ,input ? /*exch-date*/
                              ,input ? /*pay-code*/
                              ,input ? /*fact-date*/
                              ) .
          APPLY "ENTRY" to br-payment.
        end.
      end. /*when {&documents}*/
      otherwise do:
          "BELL".
      end.
    END CASE.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
    if available X_payment then do:
      { gbl/markstrn.i X_payment v-rid-list }
      glog = br-payment:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          glog = br-payment:select-next-row ().
          apply "iteration-changed" to br-payment in frame {&frame-name}.
      end.
      if num-entries( v-rid-list ) = 0
      then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-payment in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-doc-rec as recid no-undo .
  v-doc-rec = recid( X_payment ).
  DO WHILE available X_payment :
      GET prev br-payment.
  END.
  run b-print-proc no-error.
  if error-status:error then do:
    return no-apply.
  end.
  reposition br-payment to recid v-doc-rec no-error.
  apply "entry" to br-payment in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'payment'
  join-tbl = 'X_payment'
  dim = '0'
  spr = "":U
  lab = "":U
  fld = "":U
  .
  run fltfield-add in this-procedure('pmnt-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure(',cli-type{&delim-flt}cli-code', 'Контрагент', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('source-type', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('source-ref', '', 'trn-stat',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('due-date', '', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('payer-type{&delim-flt}payer-code', 'Плательщик', 'pay',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('creid', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('closid', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('d-card', '', 'currr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-date', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-rate', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-scale', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-rate', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-scale', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('tot-cli', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('tot-base', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('tot-rubl', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                     , input (filter-point + {&delim-par} + filter-label)
                     , input tbl
                     , input join-tbl
                     , input fld
                     , input lab
                     , input spr
                     , input dim).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  END .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_payment ) AND ( v-rid-list = "" ) then
    v-rid-list = string( recid( X_payment ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-payment
&Scoped-define SELF-NAME BR-payment
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-payment Dialog-Frame
ON DEFAULT-ACTION OF BR-payment IN FRAME Dialog-Frame
DO:
    if b-sel:sensitive THEN
        apply "CHOOSE":U to b-sel.
    else
        apply "CHOOSE":U to b-lkp.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-payment Dialog-Frame
ON VALUE-CHANGED OF BR-payment IN FRAME Dialog-Frame
DO:
    if available X_payment then do:
      ed-notes = X_payment.PS.
    /* doc-rec = recid (c-doc) - это сюда ставить нельзя, неправ. будет работать leave ed-notes */
    end.
    ELSE DO:
      ed-notes = '':U.
    END.
    DISPLAY ed-notes
    with frame {&frame-name}.

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

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_payment.pay-code"
  &sort-clmn_2    = "X_payment.exch-code"
  &sort-clmn_3    = "X_payment.creid"
  &sort-clmn_4    = "X_payment.closid"
  &sort-clmn_5    = "X_payment.tot-cli"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/setfltnm.i }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/brwrefre.i
  " if available X_payment then v-doc-rec = recid(X_payment). ~
    RUn OpenBr in this-procedure ( input yes, input no, input no). ~
    reposition br-payment to recid v-doc-rec no-error. " }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  { gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-host-code v-host-name }

  RUN MYEnable.
  RUN OpenBR in this-procedure ( input yes, input no, input '':U).
/* &start-column = "{&num-locked-columns-br-list} + 1"*/
  { gbl/mv-clmn.i
  &ext-col = 22
  &frame-name = "{&frame-name}"
  &browse-name = "br-payment"
  &start-column = "1"
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,14,15,16,17,12,13,18,19,20,21,22,10'"
  &prev-order-column-condition_1 = " p-list-mode = {&all} "
  &prev-order-column_2 = "'1,2,3,4,7,8,9,11,14,15,16,17,12,13,18,19,20,21,22,10,5,6'"
  &prev-order-column-condition_2 = " p-list-mode = {&client-cmp} OR p-list-mode = {&client-cmp} + {&comma-char} + {&expected} OR p-list-mode = {&client-cmp} + {&comma-char} + {&fact} "
  &prev-order-column_3 = "'1,2,3,4,8,9,7,5,6,11,14,15,16,17,12,13,18,19,20,21,22,10'"
  &prev-order-column-condition_3 = " p-list-mode = {&documents} OR p-list-mode = {&documents} + {&comma-char} + {&expected} OR p-list-mode = {&documents} + {&comma-char} + {&fact} "
  &prev-order-column_4 = "'1,2,3,4,8,9,11,14,15,16,17,12,13,18,19,20,21,22,5,6,7,10'"
  &prev-order-column-condition_4 = " p-list-mode = {&card} "
  &prev-order-column_5 = "'1,2,3,4,21,7,8,9,11,14,15,16,17,12,13,18,19,20,22,10,5,6'"
  &prev-order-column-condition_5 = " p-list-mode = {&payer} "
   }
  HIDE mark-num in frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE b-print-proc Dialog-Frame
PROCEDURE b-print-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable accum-tot-base as decimal.
define variable accum-tot-rubl as decimal.
define variable for-client as char no-undo format "X(20)".
define variable for-payer as char no-undo format "X(20)".

DEFINE FRAME PList
X_payment.pmnt-code
X_payment.fact-date
X_payment.status_
X_payment.creid   column-label "Создал"
X_payment.closid column-label "Закрыл"
for-client COLUMN-LABEL "Контрагент" FORMAT "X(20)"
X_payment.source-type COLUMN-LABEL "К док-ту"
X_payment.source-ref COLUMN-LABEL "N док-та"
X_payment.d-card COLUMn-LABEL "Диск. карта"
X_payment.tot-cli column-label "Сумма в вал.пл-жа"
X_payment.tot-base COlumn-Label "Сумма в баз.вал."
X_payment.tot-rubl COlumn-Label "Сумма в {&abbr_rub}."
X_payment.exch-code column-label "Вал"
X_payment.exch-date column-label "Курс конверт."
X_payment.pay-code COLUMN-LABEL "Опл."
for-payer COLUMN-LABEL "Плательщик" FORMAT "X(20)"
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
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
        Line format "X(177)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME PList  .
run waitfram-show in this-procedure ("Ждите...").
GET next br-payment.

 DO WHILE available X_payment :
    Display STREAM PrnLibStream
    X_payment.pmnt-code
    (if X_payment.status_ = {&expected}
    then X_payment.due-date
    else X_payment.fact-date)
    @ X_payment.fact-date
    X_payment.status_
    X_payment.creid
    X_payment.closid
    get-cli-name (buffer X_payment) @ for-client
    X_payment.source-type
    X_payment.source-ref
    X_payment.d-card
    X_payment.tot-cli
    X_payment.tot-base
    X_payment.tot-rubl
    X_payment.exch-code
    X_payment.exch-date
    X_payment.pay-code
    get-payer-name (buffer X_payment) @ for-payer
    with FRAME PList .
    DOWN STREAM PrnLibStream 1 with FRAME PList  .
    assign
    accum-count = accum-count + 1
    accum-tot-base = accum-tot-base + X_payment.tot-base
    accum-tot-rubl = accum-tot-rubl + X_payment.tot-rubl
    .
    GET next br-payment.
  END.
  UNDERLINE  STREAM PrnLibStream
  X_payment.pmnt-code
  X_payment.fact-date
  X_payment.status_
  X_payment.creid
  X_payment.closid
  for-client
  X_payment.source-type
  X_payment.source-ref
  X_payment.d-card
  X_payment.tot-cli
  X_payment.tot-base
  X_payment.tot-rubl
  X_payment.exch-code
  X_payment.exch-date
  X_payment.pay-code
  for-payer
  with FRAME PList .
  DISPLAY STREAM PrnLibStream
  "ИТОГО " + string(accum-count) @ X_payment.pmnt-code
    "_" @ X_payment.fact-date
    "_" @ X_payment.status_
    "_" @ X_payment.creid
    "_" @ X_payment.closid
    "_" @ for-client
    "_" @ X_payment.source-type
    "_" @ X_payment.source-ref
    "_" @ X_payment.d-card
    "_" @ X_payment.tot-cli
    accum-tot-base @ X_payment.tot-base
    accum-tot-rubl @ X_payment.tot-rubl
    with frame PList.
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
/*
   assign
    g#rep-tblname = ""
    g#rep-tblrid = -117
    g#rep-updflds = string( "Список платежей|" ) .
*/
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 0
                                              ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY ed-notes mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-sel B-mark B-add B-lkp B-chg B-del B-print B-sch B-Help
         BR-payment ed-notes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DISPLAY
ed-notes
mark-num
WITH FRAME {&frame-name} .
ENABLE
B-quit
b-mark WHEN lookup("b-mark" , bttns) > 0
b-sel  WHEN lookup("b-sel" , bttns) > 0
b-add WHEN (lookup("b-add", bttns ) > 0
            and ( NOT v-cntxt-db-num > 0 )
            and LOOKUP({&fact}, p-list-mode) = 0
            and not transaction
            )
b-del WHEN (lookup("b-add" , bttns) > 0
            and  v-cntxt-db-num = 0
            and LOOKUP({&fact}, p-list-mode) = 0
            and not transaction
            )
b-chg WHEN (lookup("b-add", bttns ) > 0
            and  v-cntxt-db-num = 0
            and LOOKUP({&fact}, p-list-mode) = 0
            and not transaction
            )
b-lkp when LOOKUP({&expected}, p-list-mode) > 0
B-sch
B-print
B-Help
BR-payment
ed-notes mark-num
WITH FRAME {&frame-name}.
assign
X_payment.tot-cli :read-only in browse {&BROWSE-NAME} = yes.
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
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

&scop flt-open-open-query OPEN QUERY br-payment FOR EACH X_payment

&scop flt-open-dyn_open-query FOR EACH X_payment

&scop flt-open-query-handle QUERY br-payment:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes


CASE p-list-mode:
    when {&all} then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ПЛАТЕЖИ ПО ФИРМЕ &1", v-host-name)
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 одна фирма", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_payment.host-code = v-cntxt-host-code-obj "
            &dyn_where-cond = " substitute('X_payment.host-code = &1', v-cntxt-host-code-obj )"
            &use-ind = " use-index fact-date "
            &by = "  "
          }
    end.

    when {&client-cmp} then do:
        find first buf-cli WHERE recid(buf-cli) = cli-recid No-LOCK No-ERROR.
        ASSIGN frame {&frame-name}:TITLE = substitute("ПЛАТЕЖИ КОНТРАГЕНТА &1 ПО ФИРМЕ &2"
                                                      ,string(buf-cli.obj-name, "X(20)")
                                                      ,v-host-name)
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 Один контрагент", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.cli-type = buf-cli.obj-type ~
             AND X_payment.cli-code = buf-cli.obj-code"
            &dyn_where-cond = " substitute( 'X_payment.host-code = &1 ~
             AND X_payment.cli-type = &2&3&2 ~
             AND X_payment.cli-code = &4', v-cntxt-host-code-obj, ~{&double-quote~}, buf-cli.obj-type, buf-cli.obj-code)"

            &use-ind = " use-index client  "
            &by = "  "
          }
    end.

    when {&client-cmp} + {&comma-char} + {&expected} then do:
        find first buf-cli WHERE recid(buf-cli) = cli-recid No-LOCK No-ERROR.
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ОЖИДАЕМЫЕ ПЛАТЕЖИ КОНТРАГЕНТА &1 ПО ФИРМЕ &2"
                                                     , string(buf-cli.obj-name, "X(20)")
                                                     , v-host-name)
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 Ожидаемые по контрагенту", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.cli-type = buf-cli.obj-type ~
             AND X_payment.cli-code = buf-cli.obj-code ~
             AND X_payment.status_ = {&expected} "
            &dyn_where-cond = " substitute( 'X_payment.host-code = &1 ~
             AND X_payment.cli-type = &2&3&2 ~
             AND X_payment.cli-code = &4 ~
             AND X_payment.status_ = &2&5&2 ', v-cntxt-host-code-obj, ~{&double-quote~},  buf-cli.obj-type, buf-cli.obj-code, {&expected})"

            &use-ind = " use-index client  "
            &by = "  "
          }
    end.

    when {&client-cmp} + {&comma-char} + {&fact} then do:
        find first buf-cli WHERE recid(buf-cli) = cli-recid No-LOCK No-ERROR.
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ФАКТ ПЛАТЕЖИ КОНТРАГЕНТА &1 ПО ФИРМЕ &2"
                                               , string(buf-cli.obj-name, "X(20)")
                                               ,v-host-name)
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 ФАКТ платежи контрагента", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.cli-type = buf-cli.obj-type ~
             AND X_payment.cli-code = buf-cli.obj-code ~
             AND X_payment.status_ = {&fact} "
            &dyn_where-cond = " substitute( 'X_payment.host-code = &1 ~
             AND X_payment.cli-type = &2&3&2 ~
             AND X_payment.cli-code = &4 ~
             AND X_payment.status_ = &2&5&2 ', v-cntxt-host-code-obj, ~{&double-quote~}, buf-cli.obj-type, buf-cli.obj-code, {&fact})"

            &use-ind = " use-index client  "
            &by = "  "
          }
    end.

    when {&payer} then do:
        find first buf-payer WHERE recid(buf-cli) = payer-recid No-LOCK No-ERROR.
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ПЛАТЕЖИ КОНТРАГЕНТА-ПОСРЕДНИКА &1 ПО ФИРМЕ &2"
                                                ,string(buf-payer.obj-name, "X(20)")
                                                ,v-host-name)
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 Один контрагент-посредник", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.payer-type = buf-payer.obj-type ~
             AND X_payment.payer-code = buf-payer.obj-code"
            &dyn_where-cond = " substitute('X_payment.host-code = &1 ~
             AND X_payment.payer-type = &2&3&2 ~
             AND X_payment.payer-code = &4', v-cntxt-host-code-obj, ~{&double-quote~}, buf-payer.obj-type, buf-payer.obj-code)"

            &use-ind = " use-index payer "
            &by = "  "
          }
    end.

    when {&documents} then do:
        CASE loc-source-type:
            when {&pmnt-ord-doc} then do:
                FIND FIRST ub.ord-doc No-LOCK WHERE
                           ub.ord-doc.doc-code = loc-source-ref NO-ERROR.
                IF NOT AVAIL ord-doc then dO:
                    message "Не найден " loc-source-type loc-source-ref
                    view-as alert-box ERROR.
                    return error.
                end.
                FIND FIRST buf-cli No-LOCK WHERE
                           buf-cli.obj-type = ub.ord-doc.cli-type AND
                           buf-cli.obj-code = ub.ord-doc.cli-code NO-ERROR.
                IF not avail buf-cli then do:
                    message "Не найден контрагент " ub.ord-doc.cli-type + string(ub.ord-doc.cli-code)
                    view-as alert-box ERROR.
                    return error.
                end.
            END.
        END CASE.
         ASSIGN
         frame {&frame-name}:TITLE = substitute("ПЛАТЕЖИ ПО ДОКУМЕНТУ &1 &2 ПО ФИРМЕ &2"
                                                ,loc-source-type
                                                ,loc-source-ref
                                                ,v-host-name)
         filter-point = filter-point0 + p-list-mode
         filter-label = substitute("&1 Один документ", filter-label0)
         .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.source-type = loc-source-type ~
             AND X_payment.source-ref = loc-source-ref "
            &dyn_where-cond = " substitute('X_payment.host-code = &1 ~
             AND X_payment.source-type = &2&3&2 ~
             AND X_payment.source-ref = &2&4&2 ', v-cntxt-host-code-obj, ~{&double-quote~}, loc-source-type, loc-source-ref)"

            &use-ind = " use-index source "
            &by = "  "
          }
    end.
    when {&documents} + {&comma-char} + {&expected} then do:
        CASE loc-source-type:
            when {&pmnt-ord-doc} then do:
                FIND FIRST ord-doc No-LOCK WHERE
                           ord-doc.doc-code = loc-source-ref NO-ERROR.
                IF NOT AVAIL ord-doc then dO:
                    message "Не найден " loc-source-type loc-source-ref
                    view-as alert-box ERROR.
                    return error.
                end.
                FIND FIRST buf-cli No-LOCK WHERE
                           buf-cli.obj-type = ord-doc.cli-type AND
                           buf-cli.obj-code = ord-doc.cli-code NO-ERROR.
                IF not avail buf-cli then do:
                    message "Не найден контрагент " ord-doc.cli-type + string(ord-doc.cli-code)
                    view-as alert-box ERROR.
                    return error.
                end.
            END.
        END CASE.
         ASSIGN
         frame {&frame-name}:TITLE = substitute("ОЖИДАЕМЫЕ ПЛАТЕЖИ ПО ДОКУМЕНТУ &1 &2 ПО ФИРМЕ &2"
                                                ,loc-source-type
                                                ,loc-source-ref
                                                ,v-host-name)
         filter-point = filter-point0 + p-list-mode
         filter-label = substitute("&1 Один документ - ожидаемые", filter-label0)
         .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.source-type = loc-source-type ~
             AND X_payment.source-ref = loc-source-ref
             AND X_payment.status_ = {&expected} "
            &dyn_where-cond = " substitute('X_payment.host-code = &1 ~
             AND X_payment.source-type = &2&3&2 ~
             AND X_payment.source-ref = &2&4&2 ~
             AND X_payment.status_ = &2&5&2 ', v-cntxt-host-code-obj, ~{&double-quote~}, loc-source-type, loc-source-ref, {&expected})"

            &use-ind = " use-index source "
            &by = "  "
          }
    end.

    when {&documents} + {&comma-char} + {&fact} then do:
        CASE loc-source-type:
            when {&pmnt-ord-doc} then do:
                FIND FIRST ord-doc No-LOCK WHERE
                           ord-doc.doc-code = loc-source-ref NO-ERROR.
                IF NOT AVAIL ord-doc then dO:
                    message "Не найден " loc-source-type loc-source-ref
                    view-as alert-box ERROR.
                    return error.
                end.
                FIND FIRST buf-cli No-LOCK WHERE
                           buf-cli.obj-type = ord-doc.cli-type AND
                           buf-cli.obj-code = ord-doc.cli-code NO-ERROR.
                IF not avail buf-cli then do:
                    message "Не найден контрагент " ord-doc.cli-type + string(ord-doc.cli-code)
                    view-as alert-box ERROR.
                    return error.
                end.
            END.
        END CASE.
         ASSIGN
         frame {&frame-name}:TITLE = substitute("ФАКТ ПЛАТЕЖИ ПО ДОКУМЕНТУ &1 &2 ПО ФИРМЕ &2"
                                                ,loc-source-type
                                                ,loc-source-ref
                                                ,v-host-name)
         filter-point = filter-point0 + p-list-mode
         filter-label = substitute("&1 один документ - ФАКТ", filter-label0)
         .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.source-type = loc-source-type ~
             AND X_payment.source-ref = loc-source-ref
             AND X_payment.status_ = {&fact} "
            &dyn_where-cond = " substitute('X_payment.host-code = &1 ~
             AND X_payment.source-type = &2&3&2 ~
             AND X_payment.source-ref = &2&4&2 ~
             AND X_payment.status_ = &2&5&2 ', v-cntxt-host-code-obj, ~{&double-quote~}, loc-source-type, loc-source-ref, {&fact}) "

            &use-ind = " use-index source "
            &by = "  "
          }
    end.

    when {&card} then do:
         FIND FIRST buf_dis-card NO-LOCK WHERE
                    buf_dis-card.d-card = loc-d-card NO-ERROR.
         if avail buf_dis-card then do:
            FIND FIRST buf-cli-card No-LOCK WHERE
                       buf-cli-card.obj-type = buf_dis-card.cli-type
                   AND buf-cli-card.obj-code = buf_dis-card.cli-code NO-ERROR.
         end.
         ASSIGN
         frame {&frame-name}:TITLE = substitute("ПЛАТЕЖИ ПО КАРТЕ &1 ПО ФИРМЕ &2 КЛИЕНТА &3"
                                                ,buf_Dis-card.d-card
                                                ,v-host-name
                                                ,string(IF AVAIL buf-cli-card
                                                        then string(buf-cli-card.obj-name, "X(20)")
                                                        else "")
                                                )
         filter-point = filter-point0 + p-list-mode
         filter-label = substitute("&1 Одна фирма, одна карта", filter-label0)
         .
          { gbl/fltopend.i
            &where-cond = "X_payment.host-code = v-cntxt-host-code-obj ~
             AND X_payment.d-card = loc-d-card "
            &dyn_where-cond = " substitute('X_payment.host-code = &1 ~
             AND X_payment.d-card = &2&3&2 ', v-cntxt-host-code-obj, ~{&double-quote~}, loc-d-card)"

            &use-ind = " use-index d-card  "
            &by = "  "
          }
    end.
END CASE.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-payment.
APPLY "ENTRY" TO br-payment.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cli-name Dialog-Frame
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-payment for ub.payment ) :
/*------------------------------------------------------------------------------
  Purpose:  находит название контрагента
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients for ub.clients.
    define variable dop like ub.clients.obj-name.
    FIND FIRST buf_clients NO-LOCK WHERE
              buf_clients.obj-type = loc-payment.cli-type
          AND buf_clients.obj-code = loc-payment.cli-code
    No-ERROR.
    IF avail buf_clients then dop = buf_clients.obj-name.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-full-source Dialog-Frame
FUNCTION get-full-source RETURNS CHARACTER
   (buffer loc-payment for ub.payment ) :
/*------------------------------------------------------------------------------
  Purpose:  составляет полный тип документа
    Notes:
------------------------------------------------------------------------------*/
    define variable dop as char.
    dop = loc-payment.source-type.
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-payer-name Dialog-Frame
FUNCTION get-payer-name RETURNS CHARACTER
  (buffer loc-payment for ub.payment ) :
/*------------------------------------------------------------------------------
  Purpose:  находит название контрагента
    Notes:
------------------------------------------------------------------------------*/
    define variable dop like ub.clients.obj-name.
    define buffer buf_clients for ub.clients.
    FIND FIRST buf_clients NO-LOCK WHERE
              buf_clients.obj-type = loc-payment.payer-type
          AND buf_clients.obj-code = loc-payment.payer-code
    No-ERROR.
    IF avail buf_clients then dop = buf_clients.obj-name.
    ELSE dop = "".
  RETURN dop.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME