&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE NEW SHARED BUFFER X_ord-line FOR ub.ord-line.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка заказов ПО

Автор: Чернова Светлана Александровна
Дата создания: 08/22/06
Author: Svetlana Chernova
Creation date: 08/22/06

*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc  as widget-handle no-undo.
define input-output parameter p-ord-doc-recid as recid no-undo .
define input parameter p-mode as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка заказов ПО".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cus/df-zakaz.i new }
{ cmp/r-page1.i  new }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ str/cntrcode.i }
{ trg/factord.i  }
{ str/mpl-auto.i }
{ cus/ordtrans.i }
{ str/cont-ms-def.i }

define variable v-cntxt-host-name-obj  as character no-undo .
define variable g#db-remote  as logical   no-undo .
define variable line-mode as character no-undo .
{ gbl/getcntxt.i get  }
assign
  g#db-remote   = (v-cntxt-db-num <> 0)
.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code  v-cntxt-host-code-obj v-cntxt-host-name-obj }

&scop col-l1  'N/п'
&scop col-l2  'Код товара'
&scop col-l3  'Артикул'
&scop col-l4  'Название'
&scop col-l5  'Количество'
&scop col-l6  'Цена({&abbr_rub})'
&scop col-l7  'Цена(вал)'
&scop col-l8  'Сумма в вал.'
&scop col-l9  'Сумма в {&abbr_rub}.'
&scop col-l10 'Текущий остаток'

&scop col-1  X_ord-line.line-num
&scop col-2  X_goods.gds-code
&scop col-3  X_ord-line.artic
&scop col-4  X_goods.gds-name
&scop col-5  X_ord-line.qnty
&scop col-6  X_ord-line.price-rubl
&scop col-7  X_ord-line.price-base
&scop col-8  X_ord-line.sum-base
&scop col-9  X_ord-line.sum-rubl
&scop col-10 v-fact-qnty

&glob order-type-gbd 2
&glob order-type-ubd 3


define  shared variable br-handle as handle  no-undo .
define  shared variable next-prev as logical no-undo .
define  shared buffer   buf-po_ord-doc for ub.ord-doc.

define buffer   buf_ord-doc  for ub.ord-doc .
define buffer   buf_clients  for ub.clients .
define variable loc-obj-code as integer no-undo .
define variable loc-obj-type as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-log            as logical   no-undo .
define variable gds-rec          as recid no-undo .

define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .

define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code     as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .



define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.

define variable  v-fact-qnty as decimal no-undo.
define variable v-recid-rc as integer no-undo.
define buffer   cli#clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ord-line X_goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 {&col-1} {&col-2} {&col-3} {&col-4} {&col-5} {&col-6} {&col-7} {&col-8} {&col-9} {&col-10} X_ord-line.sum-vat
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 X_ord-line.qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 X_ord-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 X_ord-line
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK, ~
             EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK, ~
             EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 X_ord-line X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 X_ord-line
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 X_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit I-deliver b-quit B-delivery B-help ~
scr-cli r-cli B-contract scr-ship-date scr-wrkr r-wrkr scr-agnt r-agnt ~
scr-boss r-boss B-add B-specif B-chg B-del BROWSE-2 scr-cli-name ~
scr-contract scr-obj-name scr-wrkr-name scr-agnt-name scr-sum-qnty ~
scr-boss-name scr-sum-rubl scr-sum-base
&Scoped-Define DISPLAYED-OBJECTS scr-cli scr-ship-date scr-wrkr scr-agnt ~
scr-boss scr-cli-name scr-contract scr-obj-name scr-wrkr-name scr-agnt-name ~
scr-sum-qnty scr-boss-name scr-sum-rubl scr-sum-base

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-zapr-qnty Dialog-Frame
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line , par-type as char )  FORWARD.

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

DEFINE BUTTON B-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Посмотреть договор".

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-delivery
     LABEL "Доставка"
     SIZE 10 BY 1 TOOLTIP "Условия доставки".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-specif
     LABEL "&Спецификация"
     SIZE 13 BY 1 TOOLTIP "Добавить товары по спецификации договора".

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY .88.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 3 BY .88.

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY 1.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY .88.

DEFINE VARIABLE scr-agnt AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.

DEFINE VARIABLE scr-agnt-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-boss AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.

DEFINE VARIABLE scr-boss-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-cli AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Покупатель"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1 NO-UNDO.

DEFINE VARIABLE scr-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.13 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-contract AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 18.88 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE scr-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 39.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-ship-date AS DATE FORMAT "99/99/9999":U
     LABEL "Заказ на"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1 TOOLTIP "Заказ на дату" NO-UNDO.

DEFINE VARIABLE scr-sum-base AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0
     LABEL "Итого сумма (вал)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-sum-qnty AS DECIMAL FORMAT ">>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Итого кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-sum-rubl AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0
     LABEL "Итого сумма (abbr_rub)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-wrkr AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.

DEFINE VARIABLE scr-wrkr-name AS CHARACTER FORMAT "X(20)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE I-deliver
     FILENAME "cmp/greenarr.bmp":U TRANSPARENT
     SIZE 3 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      X_ord-line,
      X_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      {&col-1}   COLUMN-LABEL  {&col-l1}  FORMAT ">>>>9"
     {&col-2}   COLUMN-LABEL  {&col-l2}  FORMAT ">>>>>>>>9"
     {&col-3}   COLUMN-LABEL  {&col-l3}
     {&col-4}   COLUMN-LABEL  {&col-l4}  FORMAT "X(25)"
     {&col-5}   COLUMN-LABEL  {&col-l5}  FORMAT ">>,>>>,>>9.<<<"
     {&col-6}   COLUMN-LABEL  {&col-l6}  FORMAT ">,>>>,>>9.99"
     {&col-7}   COLUMN-LABEL  {&col-l7}  FORMAT ">,>>>,>>9.99"
     {&col-8}   COLUMN-LABEL  {&col-l8}  FORMAT ">>>,>>>,>>9.99"
     {&col-9}   COLUMN-LABEL  {&col-l9}  FORMAT ">>>,>>>,>>9.99"
     {&col-10}  COLUMN-LABEL  {&col-l10} FORMAT "->>,>>>,>>9.<<<"
      /*X_ord-line.sum-vat*/
  ENABLE
      X_ord-line.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 13.42 ROW-HEIGHT-CHARS .6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-delivery AT ROW 1 COL 76.13
     B-help AT ROW 1 COL 86.13
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 6
     scr-cli AT ROW 2 COL 21.63 COLON-ALIGNED
     r-cli AT ROW 2 COL 32.25
     B-contract AT ROW 2 COL 93.25
     scr-ship-date AT ROW 3 COL 21.63 COLON-ALIGNED
     scr-wrkr AT ROW 6 COL 7.5 COLON-ALIGNED
     r-wrkr AT ROW 6.04 COL 20.25
     scr-agnt AT ROW 6.96 COL 7.5 COLON-ALIGNED
     r-agnt AT ROW 7.04 COL 20.25
     scr-boss AT ROW 7.96 COL 7.5 COLON-ALIGNED
     r-boss AT ROW 8.04 COL 20.25
     B-add AT ROW 9.17 COL 1
     B-specif AT ROW 9.17 COL 11 WIDGET-ID 6
     B-chg AT ROW 9.17 COL 24
     B-del AT ROW 9.17 COL 34
     BROWSE-2 AT ROW 10.25 COL 1
     scr-cli-name AT ROW 2 COL 33.38 COLON-ALIGNED NO-LABEL
     scr-contract AT ROW 2 COL 72 COLON-ALIGNED NO-LABEL
     scr-obj-name AT ROW 4.17 COL 21.5 COLON-ALIGNED
     scr-wrkr-name AT ROW 6.17 COL 21.63 COLON-ALIGNED NO-LABEL
     scr-agnt-name AT ROW 7.21 COL 21.63 COLON-ALIGNED NO-LABEL
     scr-sum-qnty AT ROW 7.83 COL 80.5 COLON-ALIGNED
     scr-boss-name AT ROW 8.25 COL 21.63 COLON-ALIGNED NO-LABEL
     scr-sum-rubl AT ROW 8.54 COL 80.5 COLON-ALIGNED
     scr-sum-base AT ROW 9.33 COL 80.5 COLON-ALIGNED
     I-deliver AT ROW 1 COL 73 WIDGET-ID 2
     SPACE(20.74) SKIP(21.67)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заказ ПО".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub ub.goods
      TABLE: X_ord-line B "NEW SHARED" ? ub ord-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-next IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-prev IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ord-line
      WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK,
      EACH X_goods WHERE X_goods.artic = X_ord-line.artic
  AND X_goods.prod-code = X_ord-line.prod-code
  AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "X_ord-line.doc-code = loc-ord-num"
     _JoinCode[2]      = "X_goods.artic = X_ord-line.artic
  AND X_goods.prod-code = X_ord-line.prod-code
  AND X_goods.prod-type = X_ord-line.prod-type"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Заказ ПО */
DO:

define buffer buf_ord-line for ub.ord-line.
define variable v-kol as integer init 0 no-undo .

  if p-mode =  {&lookup} then return.

  if p-mode <> {&lookup} then do:
     assign frame {&frame-name}
     scr-ship-date
     scr-cli-name
     scr-wrkr
     scr-agnt
     scr-boss

     .
     loc-date-ship = scr-ship-date .

  if can-find
    ( first buf_ord-line  no-lock    where
            buf_ord-line.doc-code = loc-ord-num  and
            buf_ord-line.qnty  =  0 ) then do:
      message "В заказе есть строки с 0 количеством . Удаляем их ? " view-as alert-box question  buttons yes-no update v-log.
       if v-log then do:
            for each buf_ord-line  exclusive-lock
                    where buf_ord-line.qnty = 0      and
                    buf_ord-line.doc-code = loc-ord-num
                    :
                     delete buf_ord-line .
            end. /* foreach*/
       end.
   end.



     define variable s-1 as decimal init 0 no-undo .
     define variable s-2 as decimal init 0 no-undo .
     define variable s-3 as decimal init 0 no-undo .

     for each  buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  :
         s-1  = s-1  + buf_ord-line.sum-rubl .
         s-2  = s-2  + buf_ord-line.sum-base .
         s-3  = s-3  + buf_ord-line.qnty .
         v-kol = v-kol + 1 .
     end. /* for each */


     if v-kol = 0 then do:
        message "В заказе нет строк . Удаляем документ ? " view-as alert-box question
        buttons yes-no title "" update t-log-3 as logical.
        if t-log-3 = true then do:
              find first buf-po_ord-doc exclusive-lock where recid(buf-po_ord-doc) = p-ord-doc-recid  no-error.
              if available buf-po_ord-doc then
              delete buf-po_ord-doc.
              p-ord-doc-recid = ? .
              return.
            end.
     end.
  end.

define variable   v-ok  as logical   no-undo .
define variable   v-err  as character no-undo .
v-ok = true .
  run validate-transport-contract in this-procedure (
         input v-cntxt-host-code-obj
        ,input loc-cli-type
        ,input loc-cli-code
        ,input loc-contract
        ,input v-transport-cli-type
        ,input v-transport-cli-code
        ,input v-transport-host-code
        ,input v-transport-contract
        ,input true
        ,output v-ok
        ,output v-err
        ) no-error .

       if v-ok = false then do:
          return no-apply .
       end.

  find current buf_ord-doc exclusive-lock no-error .
  assign
    buf_ord-doc.sum-rubl     = s-1
    buf_ord-doc.sum-base     = s-2
    buf_ord-doc.qnty         = s-3

    buf_ord-doc.ship-date    = scr-ship-date
    buf_ord-doc.wrkr         = scr-wrkr
    buf_ord-doc.boss         = scr-boss
    buf_ord-doc.agnt         = scr-agnt
    buf_ord-doc.status_      = {&g___new}
    buf_ord-doc.cli-code     = loc-cli-code
    buf_ord-doc.cli-type     = loc-cli-type
    buf_ord-doc.cli-name     = scr-cli-name
    buf_ord-doc.contract-code = loc-contract
    buf_ord-doc.deliv-type-code    = v-deliv-type-code
    buf_ord-doc.obj-point-code     = v-point-obj-code
    buf_ord-doc.cli-point-code     = v-point-cli-code
    buf_ord-doc.obj-point-db-num   = v-point-obj-db-num
    buf_ord-doc.cli-point-db-num   = v-point-cli-db-num
    buf_ord-doc.transport-host-code     = v-transport-host-code
    buf_ord-doc.transport-cli-type     = v-transport-cli-type
    buf_ord-doc.transport-cli-code     = v-transport-cli-code
    buf_ord-doc.transport-contract = v-transport-contract
    buf_ord-doc.transport-condition= v-transport-condition
    buf_ord-doc.transport-value    = v-transport-value
    buf_ord-doc.sum-ship           = v-transport-sum
    buf_ord-doc.transport-vat      = v-transport-vat
 .

  if buf_ord-doc.status_ = {&g___new} and buf_ord-doc.flag_ = false then do:
      message "Закрываем заказ до статуса НОВЫЙ+ ? " view-as alert-box question
            buttons yes-no title "" update t-log-4 as logical.
            if t-log-4 = true then do:
              run cus/ordpocls.p ( parParentProc , recid(buf_ord-doc) , true ) no-error .
              if error-status :error then return  .
            end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заказ ПО */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add.
  run recalc-head.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
 define variable r-stop as logical no-undo .
 define variable r-exit as logical no-undo .
 define variable r-recid as recid no-undo.

 find current x_ord-line  exclusive-lock  no-error .
 if available x_ord-line then do:

     r-recid =  recid ( x_ord-line)  .
     run cus/ord-frmp.w (parParentProc , input ?  , input r-recid  , input {&update},  output r-stop , output r-exit ) .
     v-log =  {&BROWSE-NAME}:refresh() .
 end.
    run recalc-head.
END.


ON return OF B-chg IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-contract Dialog-Frame
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:
define variable o-host-code as integer   no-undo .
{ gbl/hostcode.i loc-obj-type loc-obj-code o-host-code }

define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = loc-contract and
                                     b_contract.host-code         = o-host-code
                                     no-error .
if error-status :error then return no-apply.

run str/sh-contr.p (
  input parParentProc ,
  input recid (b_contract))
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
/* */
define variable v-ii as integer no-undo .
message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log as logical .
      if g-log = false then return no-apply.

 find current x_ord-line  exclusive-lock  no-error .
 if available x_ord-line then do:
    run x-delete ( recid(x_ord-line) , input-output v-ii ) no-error .
    if error-status :error then
    message vss-workfile vss-revision vss-description skip
           "Ошибка удаление 1 " skip
            skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error
    .
    Run OpenBr.
 end.
    run recalc-head.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delivery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delivery Dialog-Frame
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame /* Доставка */
DO:
   run cus/pardeliv.w
     (input parParentproc
      ,input        p-mode
      ,input        "ord" + {&p-o}
      ,input        loc-obj-type
      ,input        loc-obj-code
      ,input        loc-cli-type
      ,input        loc-cli-code
      ,input-output v-deliv-type-code
      ,input-output v-point-obj-code
      ,input-output v-point-obj-db-num
      ,input-output v-point-cli-code
      ,input-output v-point-cli-db-num
      ,input-output v-transport-host-code
      ,input-output v-transport-cli-type
      ,input-output v-transport-cli-code
      ,input-output v-transport-contract
      ,input-output v-transport-condition
      ,input-output v-transport-value
      ,input-output v-transport-sum
      ,input-output v-transport-vat
         ) no-error  .
         if error-status :error then message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "Ошибка"
           view-as alert-box error
         .
       hide i-deliver in frame {&frame-name} .
       i-deliver:tooltip = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    next-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
run step-next.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
   run step-prev.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
    next-prev = ?.
    message "Выходим без сохранения изменений ?" view-as alert-box question
            buttons yes-no
            update ll as log
            .
    if ll = no then return no-apply.
    else do:
      if p-mode  = {&add-def} then do:
        find first buf-po_ord-doc exclusive-lock where recid(buf-po_ord-doc) = p-ord-doc-recid  no-error.
        if available buf-po_ord-doc then
        delete buf-po_ord-doc.
      end.
     end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-specif
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-specif Dialog-Frame
ON CHOOSE OF B-specif IN FRAME Dialog-Frame /* Спецификация */
DO:
  run add-spec-contract.
  run recalc-head.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  define buffer buf_gds-obj for ub.gds-obj  .
    find first buf_gds-obj no-lock where
             buf_gds-obj.artic     = x_ord-line.artic     and
             buf_gds-obj.prod-type = x_ord-line.prod-type and
             buf_gds-obj.prod-code = x_ord-line.prod-code and
             buf_gds-obj.obj-type  = buf_ord-doc.obj-type   and
             buf_gds-obj.obj-code  = buf_ord-doc.obj-code   no-error .
   if available buf_gds-obj then
           v-fact-qnty = buf_gds-obj.fact-qnty.
      else v-fact-qnty = 0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame /* r boss 2 */
DO:
 define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
 define variable old-types as character no-undo .

    run ref/cli-all.w
        (input parparentproc,
         input "b-sel",
         {&cmp},
         ?,
         ?,
         ?,
         ?,
         ?,
         output  rid-list).
    assign
      v-recid-RC = integer(rid-list)
      .
    find first cli#clients no-lock where recid(cli#clients) = v-recid-rc  no-error.
    if available cli#clients then
        assign
            scr-cli      = cli#clients.obj-code
            loc-cli-code = cli#clients.obj-code
            loc-cli-type = cli#clients.obj-type
            scr-cli-name = cli#clients.obj-name
            .
        else
          assign
              scr-cli-name = ""
              scr-cli      = ?
              loc-cli-code = ?
              loc-cli-type = ""
              .

display scr-cli scr-cli-name with frame {&frame-name} .
define variable o-host-code as integer   no-undo .

{ gbl/hostcode.i loc-obj-type loc-obj-code o-host-code }

    run check-contract-code in this-procedure
     (input  "choose":u,
      input  o-host-code,
      input  loc-cli-type,
      input  loc-cli-code,
      input  ?,
      input  parparentproc,
      input  doc-date,
      input  {&expense} ,
      output loc-contract)
      no-error.
  scr-contract = "".
  if loc-contract <> 0 then do:
     scr-contract = "Вн.№ дог. " + string(loc-contract).
     /*999*/

     define buffer buf_contract for ub.contract  .

     find first buf_contract no-lock where
                buf_contract.contract-code = loc-contract and
                buf_contract.host-code     =  o-host-code
               .
     assign
        v-transport-cli-code     =  buf_contract.transport-cli-code
        v-transport-cli-type     =  buf_contract.transport-cli-type
        v-transport-host-code    =  buf_contract.transport-host
        v-transport-contract     =  buf_contract.transport-contract
        v-transport-condition    =  buf_contract.transport-uslov
        v-transport-value        =  buf_contract.transport-value
        .
        i-deliver:tooltip = "Транспортные настроики взяты из договора" .
        display I-deliver with frame {&frame-name} .
  define variable v-ok as logical   no-undo .
  define variable v-err as character no-undo .

  /*
  message 'v-cntxt-host-code-obj '  v-cntxt-host-code-obj  skip
          'loc-cli-type          '  loc-cli-type           skip
          'loc-cli-code          '  loc-cli-code           skip
          'loc-contract          '  loc-contract           skip
          'v-transport-cli-type  '  v-transport-cli-type   skip
          'v-transport-cli-code  '  v-transport-cli-code   skip
          'v-transport-host-code '  v-transport-host-code  skip
          'v-transport-contract  '  v-transport-contract   skip
          .
  */
  run validate-transport-contract in this-procedure (
         input v-cntxt-host-code-obj
        ,input loc-cli-type
        ,input loc-cli-code
        ,input loc-contract
        ,input v-transport-cli-type
        ,input v-transport-cli-code
        ,input v-transport-host-code
        ,input v-transport-contract
        ,input false
        ,output v-ok
        ,output v-err
        ) no-error .
       if v-ok = false then do:
        i-deliver:tooltip = "ОШИБКА " + v-err .
        i-deliver:LOAD-IMAGE("cmp/redx.bmp") .
        display I-deliver with frame {&frame-name} .

       end.



  end.
  display scr-contract with frame {&frame-name} .
  /* Если по договору был ТРАНСПОРТ то взвести галку */


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-agnt Dialog-Frame
ON return OF scr-agnt IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-agnt-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-agnt-name Dialog-Frame
ON return OF scr-agnt-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-boss Dialog-Frame
ON return OF scr-boss IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-boss-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-boss-name Dialog-Frame
ON return OF scr-boss-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-cli Dialog-Frame
ON return OF scr-cli IN FRAME Dialog-Frame /* Покупатель */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-ship-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-ship-date Dialog-Frame
ON return OF scr-ship-date IN FRAME Dialog-Frame /* Заказ на */
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-wrkr Dialog-Frame
ON return OF scr-wrkr IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-wrkr-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-wrkr-name Dialog-Frame
ON return OF scr-wrkr-name IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

assign
  scr-sum-rubl :label = "Итого сумма ({&abbr_rub})"
.
  hide I-deliver in frame {&frame-name}  .
  i-deliver:tooltip = "" .
{ gbl/brwrepos.i
  &line-num=8
}
{ gbl/ed_date.i scr-ship-date}
{ gbl/app_help.i }
{ gbl/mv-clmn.i
 &ext-col = 10
 &start-column = 1
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
}
{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_ord-line"
  &label-clmn_1     = "{&col-l1}"
  &label-clmn_2     = "{&col-l2}"
  &label-clmn_3     = "{&col-l3}"
  &label-clmn_4     = "{&col-l4}"
  &label-clmn_5     = "{&col-l5}"
  &label-clmn_6     = "{&col-l6}"
  &label-clmn_7     = "{&col-l7}"
  &label-clmn_8     = "{&col-l8}"
  &label-clmn_9     = "{&col-l9}"
  &label-clmn_10     = "{&col-l10}"
  &sort-clmn_1    =  "{&col-1}"
  &sort-clmn_2    =  "{&col-2}"
  &sort-clmn_3    =  "{&col-3}"
  &sort-clmn_4    =  "{&col-4}"
  &sort-clmn_5    =  "{&col-5}"
  &sort-clmn_6    =  "{&col-6}"
  &sort-clmn_7    =  "{&col-7}"
  &sort-clmn_8    =  "{&col-8}"
  &sort-clmn_9    =  "{&col-9}"
  &sort-clmn_10    =  "{&col-10}"

&open-query     = "Run OpenBr."
&open-query-otherwise = "Run OpenBr."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes"
}
{ gbl/f2.i BROWSE-2 goods-recid init-gds-rec parParentProc }
{ cus/ord-trgo.i boss}
{ cus/ord-trgo.i agnt}
{ cus/ord-trgo.i wrkr}

on end-error, stop of frame {&frame-name}  do:
  apply "choose" to b-exit in frame {&frame-name} .
  return no-apply.
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> {&lookup} then do:
    if p-mode  = {&add-def} then do:

      define variable v-i-doc as character no-undo .
      { cus/ord-code.i
          'main'
          v-cntxt-db-num
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-i-doc
          loc-ord-num
          }


define variable loc-order-type as integer no-undo .

if v-cntxt-db-num  = 0 then loc-order-type = {&order-type-gbd} . /* ГБД */
                       else loc-order-type = {&order-type-ubd} . /* УБД */

      run create-ord-doc in this-procedure (
          input loc-ord-num  ,
          input ?            ,
          input ""           ,
          input ""           ,
          input ""           ,
          input v-cntxt-host-code-obj  ,
          input v-cntxt-obj-code   ,
          input v-cntxt-obj-type   ,
          input {&p-o}       ,
          input {&g___new}   ,
          input today        ,
          input today        ,
          input loc-order-type ,
          output p-ord-doc-recid )
          .
    end.

  do transaction on error undo, return error return-value :
    find first buf_ord-doc  exclusive-lock  where
         recid(buf_ord-doc) = p-ord-doc-recid no-error .
         if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "Ошибка  " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error.
         end.
  end.
 loc-ord-num = buf_ord-doc.doc-code .
{&col-5}:read-only in browse {&browse-name} = true .
    run recalc-head in this-procedure .
    run my-enable_ui in this-procedure .
     if p-mode  = {&add-def} then WAIT-FOR GO  OF FRAME {&FRAME-NAME} focus  scr-ship-date.
     else WAIT-FOR GO  OF FRAME {&FRAME-NAME} focus BROWSE-2.


  end.
  else do:
      find first buf_ord-doc  no-lock where
           recid(buf_ord-doc) = p-ord-doc-recid no-error .
         if error-status :error then do:
         message vss-workfile vss-revision vss-description skip
                "Ошибка просмотра " skip
                 skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error
         .
         return error.
         end.

      loc-ord-num = buf_ord-doc.doc-code .

      run recalc-head in this-procedure .
      run my-enable-lkp in this-procedure .
      WAIT-FOR GO  OF FRAME {&FRAME-NAME} focus b-exit.
  end.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-spec-contract Dialog-Frame
PROCEDURE add-spec-contract :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii        as integer   no-undo .
define variable t-ret     as logical   no-undo .
define variable r-tmp     as recid no-undo .
define variable r-ord     as recid no-undo .
define variable r-stop    as logical no-undo .
define variable r-exit    as logical no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-price as logical   no-undo .

define buffer buf_ord-line for ub.ord-line  .
  do
  on error undo, return error return-value
  :


if loc-contract = 0 or loc-contract = ? then return .

message "Добавление товаров по спецификации договора "
        skip "Вн.№ " loc-contract skip
        "Продолжать ?"
        view-as alert-box question
        buttons yes-no
        update t-ret
        .
if t-ret = false then return .
message "Цены в заказе из спецификации договора ?"
        skip "Вн.№ " loc-contract skip
        view-as alert-box question
        buttons yes-no
        update v-price
        .
   t-ret =  session:set-wait-state("general") .

   line-mode = {&add-def}.
/*
   for each ub.contract-specif no-lock where
            ub.contract-specif.contract-num = loc-contract and
            ub.contract-specif.host-code    = v-cntxt-host-code-obj
   :
*/
   {str/cont-slave-inc.i
        &FOR_ = YES
        &EACH_ = YES
        &BUFFER_SPECIF = ub.contract-specif
        &P_HOST_CODE = v-cntxt-host-code-obj
        &P_CONTRACT_NUM = loc-contract
        &NO_LOCK=YES
   }

    ii = ii + 1 .
    if ii > 1 then assign line-mode = "ЦИКЛ":u.
    find first  buf_ord-line  exclusive-lock      where
                buf_ord-line.gds-code = ub.contract-specif.gds-code  and
                buf_ord-line.doc-code = loc-ord-num
                no-error .
     if available buf_ord-line then do:
         run cus/ord-frmp.w ( parParentProc , input ?  , input recid ( buf_ord-line)  , input {&update},  output r-stop , output r-exit ) no-error .
     end.
     else do:
        run create-tmp in this-procedure (input "contract-spec":u, input  v-price , output r-tmp , output r-ord) no-error .
        if not  error-status :error  then do:
          find first tmp#zakaz  where  recid ( tmp#zakaz ) = r-tmp  .
          var-ok-assort-pol = true .
          { gbl/goassizt.i
            {&P-O}
            ub.contract-specif.gds-code
            v-cntxt-obj-type
            v-cntxt-obj-code
            true
            var-ok-assort-pol
            var-mess-assort-pol
          }
          if var-ok-assort-pol = false then do:
              message var-mess-assort-pol skip "Товар не может быть включен в заказ !" view-as alert-box information .
              run p-delete in this-procedure ( r-tmp , input-output ii ) .
              next.
          end.

          run cus/ord-frmp.w ( parParentProc ,input r-tmp  , input r-ord  , input line-mode,  output r-stop , output r-exit ) .
          if r-stop then do:
             run p-delete in this-procedure ( r-tmp , input-output ii).
             leave.
          end.
          if r-exit then do:
             run p-delete in this-procedure ( r-tmp , input-output ii ) .
          end.
        end.
     end.
   end.

    run openbr in this-procedure  .
    t-ret =  session:set-wait-state("") .
    message "Добавлено " + string(ii) + " товаров".
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-ord-doc Dialog-Frame
PROCEDURE create-ord-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))

 :

define input parameter p-doc-code   like  ub.ord-doc.doc-code  no-undo .
define input parameter p-cli-code   like  ub.ord-doc.cli-code  no-undo .
define input parameter p-cli-type   like  ub.ord-doc.cli-type  no-undo .
define input parameter p-cli-name   like  ub.ord-doc.cli-name  no-undo .
define input parameter p-cons-code  like  ub.ord-doc.cons-code no-undo .
define input parameter p-host-code  like  ub.ord-doc.host-code no-undo .
define input parameter p-obj-code   like  ub.ord-doc.obj-code  no-undo .
define input parameter p-obj-type   like  ub.ord-doc.obj-type  no-undo .
define input parameter p-doc-type   like  ub.ord-doc.doc-type  no-undo .
define input parameter p-status_    like  ub.ord-doc.status_   no-undo .
define input parameter p-doc-date   like  ub.ord-doc.doc-date  no-undo .
define input parameter p-ship-date  like  ub.ord-doc.ship-date no-undo .
define input parameter p-order-type like  ub.ord-doc.order-type    no-undo .

define output parameter p-recid as recid no-undo .

define variable v-i-doc as character no-undo .
      { cus/ord-code.i
      'main'
      v-cntxt-db-num
      p-obj-type
      p-obj-code
      v-i-doc
      loc-ord-num
      }

/* Шапка заказа */
   create ub.ord-doc.
   assign
      ub.ord-doc.doc-code   = p-doc-code
      ub.ord-doc.cli-code   = p-cli-code
      ub.ord-doc.cli-type   = p-cli-type
      ub.ord-doc.cli-name   = p-cli-name
      ub.ord-doc.cons-code  = p-cons-code
      ub.ord-doc.host-code  = p-host-code
      ub.ord-doc.obj-code   = p-obj-code
      ub.ord-doc.obj-type   = p-obj-type
      ub.ord-doc.doc-type   = p-doc-type
      ub.ord-doc.status_    = p-status_
      ub.ord-doc.doc-date   = p-doc-date
      ub.ord-doc.ship-date     = p-ship-date
      ub.ord-doc.order-type = p-order-type

      p-recid = recid (ub.ord-doc)
      .
    { gbl/baserate.i
    ub.ord-doc.host-code
    p-doc-date
    ub.ord-doc.base-rate
    ub.ord-doc.base-scale }


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-tmp Dialog-Frame
PROCEDURE create-tmp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input    parameter tt as char no-undo.
define input    parameter p-price-contract as logical no-undo.
define output   parameter p-tmp as recid no-undo .
define output   parameter p-ord as recid no-undo .
define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .

define buffer ll-buf_ord-line for ub.ord-line .

define variable p-recid as recid no-undo .
    case tt :
    when "tt-gds-list" then do:
      find first ub.goods where
            ub.goods.artic     = tt-gds-list.artic     and
            ub.goods.prod-type = tt-gds-list.prod-type and
            ub.goods.prod-code = tt-gds-list.prod-code no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! tt-gds-list не = goods !"
                1
                view-as alert-box error .
            end.
      end.
    when "contract-spec" then do:
      find first ub.goods where
            ub.goods.gds-code  = ub.contract-specif.gds-code  no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "При добавлении товаров из спецификации по договору произошла ошибка :" skip
                "Нет товара с кодом : " ub.contract-specif.gds-code
                view-as alert-box error .
            end.
      end.

      end case.
      find  first ub.gds-obj  where
            ub.gds-obj.obj-type  = v-cntxt-obj-type and
            ub.gds-obj.obj-code  = v-cntxt-obj-code and
            ub.gds-obj.artic     = ub.goods.artic      and
            ub.gds-obj.prod-type = ub.goods.prod-type  and
            ub.gds-obj.prod-code = ub.goods.prod-code  no-lock no-error.

define buffer bufff-units for ub.units.
define variable t-type as character no-undo .


find first tmp#zakaz   where
    tmp#zakaz.prod-type       = ub.goods.prod-type and
    tmp#zakaz.prod-code       = ub.goods.prod-code and
    tmp#zakaz.artic           = ub.goods.artic     no-error.

 if not available tmp#zakaz  then  create tmp#zakaz .

  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = ub.goods.gds-code
    tmp#zakaz.prod-type       = ub.goods.prod-type
    tmp#zakaz.prod-code       = ub.goods.prod-code
    tmp#zakaz.artic           = ub.goods.artic
    tmp#zakaz.gds-name        = ub.goods.gds-name
    tmp#zakaz.deadline        = ub.goods.deadline
    tmp#zakaz.unit-cli        = ub.goods.unit-cli
    tmp#zakaz.unit-base       = ub.goods.unit-base
    tmp#zakaz.negative-rest   = ub.goods.negative-rest
    tmp#zakaz.cli-base-rate   = 1
    tmp#zakaz.ms-cart         = ub.goods.qnty-cart
    .

    define variable max-num as integer no-undo .
    max-num = 0.
    for each  ll-buf_ord-line no-lock  where ll-buf_ord-line.doc-code = loc-ord-num :
        if max-num < ll-buf_ord-line.line-num then
           max-num = ll-buf_ord-line.line-num .
    end.

    tmp#zakaz.line-num = max-num + 1.

  { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code tmp#zakaz.vat-pc no-error }


  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .

define variable  p-only-b-code     as logical   no-undo .
define variable  p-cli-type        as character no-undo .
define variable  p-cli-code        as integer   no-undo .
define variable  p-main-b-code     as integer   no-undo .
define variable  p-b-code          as integer   no-undo .
define variable  p-obj-type        as character no-undo .
define variable  p-obj-code        as integer   no-undo .
define variable  p-qnty-doc        as decimal   no-undo .
define variable  p-sum-doc         as decimal   no-undo .
define variable  p-fact-order      as decimal   no-undo .
define variable  p-plt-id          as integer   no-undo .
define variable  p-plt-db-num      as integer   no-undo .
define variable  p-pdf-id          as integer   no-undo .
define variable  p-pdf-db-num      as integer   no-undo .
define variable  p-sale-price-base as decimal   no-undo .
define variable  p-sale-price-rubl as decimal   no-undo .
define variable  p-road-tax-base   as decimal   no-undo .
define variable  p-road-tax-rubl   as decimal   no-undo .
define variable  p-excise-base     as decimal   no-undo .
define variable  p-excise-rubl     as decimal   no-undo .

{ gbl/gdsbcode.i tmp#zakaz.gds-code ? p-main-b-code }

run fact-order-mpl  in this-procedure (
    input doc-date ,
    input v-cntxt-obj-type ,
    input v-cntxt-obj-code ,
    output p-fact-order) .
run mpl-autoprice (
  input   false
 ,input   loc-cli-type
 ,input   loc-cli-code
 ,input   p-main-b-code
 ,input   p-main-b-code
 ,input   v-cntxt-obj-type
 ,input   v-cntxt-obj-code
 ,input   tmp#zakaz.qnty
 ,input   0
 ,input   ""    /* вид оплаты */
 ,input   ""    /* тип кассового платежа */
 ,input   p-fact-order
 ,output  p-plt-id
 ,output  p-plt-db-num
 ,output  p-pdf-id
 ,output  p-pdf-db-num
 ,output  p-sale-price-base
 ,output  p-sale-price-rubl
 ,output  p-road-tax-base
 ,output  p-road-tax-rubl
 ,output  p-excise-base
 ,output  p-excise-rubl )
 .

define variable v-baz-val as integer no-undo .
define variable v-base-rate  as decimal no-undo .
define variable v-base-scale  as decimal no-undo .
define variable p-r-b-abbr as character no-undo .
{ gbl/basecode.i v-cntxt-host-code-obj v-baz-val}
{ gbl/baserate.i
  v-cntxt-host-code-obj
  today
  v-base-rate
  v-base-scale
  }

{ gbl/curr-r-b.i p-r-b-abbr}
   assign
     tmp#zakaz.price-base = 0
     tmp#zakaz.price-rubl = 0
     tmp#zakaz.price-cli  = 0
   .
  if p-r-b-abbr = {&r-b-rubl} then do:
            if p-price-contract and ub.contract-specif.price-cli <> 0 and ub.contract-specif.price-cli <> ? then do:
              assign
                tmp#zakaz.vat-pc     = if ub.contract-specif.vat-pc <> 0  and ub.contract-specif.vat-pc <> ?
                                     then ub.contract-specif.vat-pc  else tmp#zakaz.vat-pc
                tmp#zakaz.price-base = ub.contract-specif.price-cli / v-base-rate  * v-base-scale
                tmp#zakaz.price-rubl = ub.contract-specif.price-cli
                tmp#zakaz.price-cli  = ub.contract-specif.price-cli
                tmp#zakaz.sum-vat    = ub.contract-specif.price-cli * tmp#zakaz.vat-pc / ( 100 + tmp#zakaz.vat-pc )
              .
            end.
            else do:
              assign
                tmp#zakaz.price-base = p-sale-price-base
                tmp#zakaz.price-rubl = p-sale-price-rubl
                tmp#zakaz.price-cli  = p-sale-price-rubl
                tmp#zakaz.sum-vat    = p-sale-price-rubl * tmp#zakaz.vat-pc / ( 100 + tmp#zakaz.vat-pc )
              .
            end.
    end.
    else do: /*rb = base */
            if p-price-contract and ub.contract-specif.price-cli <> 0 and ub.contract-specif.price-cli <> ? then do:
              assign
                tmp#zakaz.vat-pc     = if ub.contract-specif.vat-pc <> 0  and ub.contract-specif.vat-pc <> ?
                                      then  ub.contract-specif.vat-pc  else tmp#zakaz.vat-pc
                tmp#zakaz.price-base = ub.contract-specif.price-cli
                tmp#zakaz.price-rubl = ub.contract-specif.price-cli * v-base-rate  / v-base-scale
                tmp#zakaz.price-cli  = ub.contract-specif.price-cli
                tmp#zakaz.sum-vat    = ub.contract-specif.price-cli * tmp#zakaz.vat-pc / ( 100 + tmp#zakaz.vat-pc )
              .
            end.
            else do:
            assign
              tmp#zakaz.price-base = p-sale-price-base
              tmp#zakaz.price-rubl = p-sale-price-rubl
              tmp#zakaz.price-cli  = p-sale-price-base
              tmp#zakaz.sum-vat    = p-sale-price-base * tmp#zakaz.vat-pc / ( 100 + tmp#zakaz.vat-pc )
              .
            end.
    end.

find first shar_ord-line   exclusive-lock   where
    shar_ord-line.doc-code  = loc-ord-num    and
    shar_ord-line.prod-type = tmp#zakaz.prod-type and
    shar_ord-line.prod-code = tmp#zakaz.prod-code and
    shar_ord-line.artic     = tmp#zakaz.artic     no-error.

 if not available shar_ord-line  then
       create shar_ord-line  .
 buffer-copy tmp#zakaz to shar_ord-line
    assign shar_ord-line.doc-code    = loc-ord-num
  .

  p-tmp = recid ( tmp#zakaz   ) .
  p-ord = recid ( shar_ord-line  ) .


  end.  /* do */
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
  DISPLAY scr-cli scr-ship-date scr-wrkr scr-agnt scr-boss scr-cli-name
          scr-contract scr-obj-name scr-wrkr-name scr-agnt-name scr-sum-qnty
          scr-boss-name scr-sum-rubl scr-sum-base
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-delivery B-help I-deliver scr-cli r-cli B-contract
         scr-ship-date scr-wrkr r-wrkr scr-agnt r-agnt scr-boss r-boss B-add
         B-specif B-chg B-del BROWSE-2 scr-cli-name scr-contract scr-obj-name
         scr-wrkr-name scr-agnt-name scr-sum-qnty scr-boss-name scr-sum-rubl
         scr-sum-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dialog-Frame
PROCEDURE init-gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  find current x_goods no-lock no-error .
  gds-rec = recid(x_goods) .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

 find first buf_clients no-lock where
            buf_clients.obj-code = buf_ord-doc.obj-code and
            buf_clients.obj-type = buf_ord-doc.obj-type
            no-error .
            if error-status :error then do:
            message vss-workfile vss-revision vss-description skip
                   "Ошибка  " skip
                    skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error
            .
            return error .
            end.
 assign
  scr-ship-date    = buf_ord-doc.ship-date
  loc-date-ship    = scr-ship-date
  loc-obj-code     = buf_ord-doc.obj-code
  loc-obj-type     = buf_ord-doc.obj-type
  loc-cli-code     = buf_ord-doc.cli-code
  loc-cli-type     = buf_ord-doc.cli-type
  scr-cli-name     = buf_ord-doc.cli-name
  scr-cli          = buf_ord-doc.cli-code
  loc-doc-type     = buf_ord-doc.doc-type
  scr-obj-name     = buf_clients.obj-name
  loc-ord-num      = buf_ord-doc.doc-code
  scr-wrkr         = buf_ord-doc.wrkr
  scr-boss         = buf_ord-doc.boss
  scr-agnt         = buf_ord-doc.agnt
  loc-contract     = buf_ord-doc.contract-code
  v-deliv-type-code     =  buf_ord-doc.deliv-type-code
  v-point-obj-code      =  buf_ord-doc.obj-point-code
  v-point-cli-code      =  buf_ord-doc.cli-point-code
  v-point-obj-db-num    =  buf_ord-doc.obj-point-db-num
  v-point-cli-db-num    =  buf_ord-doc.cli-point-db-num
  v-transport-host-code      =  buf_ord-doc.transport-host-code
  v-transport-cli-type      =  buf_ord-doc.transport-cli-type
  v-transport-cli-code      =  buf_ord-doc.transport-cli-code
  v-transport-contract  =  buf_ord-doc.transport-contract
  v-transport-condition =  buf_ord-doc.transport-condition
  v-transport-value     =  buf_ord-doc.transport-value
  v-transport-sum       =  buf_ord-doc.sum-ship
  v-transport-vat       =  buf_ord-doc.transport-vat

  scr-contract     = if loc-contract <> 0 then "Вн.№ дог. " + string(loc-contract)  else ""
 .
 run leave-proc-wrkr .
 run leave-proc-boss .
 run leave-proc-agnt .

     ASSIGN frame {&frame-name}:TITLE = "Заказ  № " + loc-ord-num
   + " Тип: " +     buf_ord-doc.doc-type
   + " Статус: "  +  buf_ord-doc.status_
   + " - " + caps(p-mode).

assign
scr-agnt:label in frame {&frame-name}    = "И&сп"
scr-agnt:tooltip in frame {&frame-name}  = "Код исполнителя"
scr-wrkr:label in frame {&frame-name}    = "К&л-к"
scr-wrkr:tooltip in frame {&frame-name}  = "Код кладовщика"
scr-boss:label in frame {&frame-name}    = "&М-р"
scr-boss:tooltip in frame {&frame-name}  = "Код менеджера"

.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable-lkp Dialog-Frame
PROCEDURE my-enable-lkp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  run init-proc.
  X_ord-line.qnty:read-only in browse {&browse-name}  = true .
  DISPLAY scr-ship-date scr-obj-name
          scr-sum-base scr-sum-qnty scr-sum-rubl
          scr-cli-name
          scr-cli
          scr-contract
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-next b-prev B-help BROWSE-2
  b-contract B-delivery
       WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
      hide  b-quit in FRAME Dialog-Frame.
      b-exit:label = "&Выход" .
  Run OpenBr.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame
PROCEDURE my-enable_UI :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  run init-proc.
  DISPLAY scr-ship-date scr-obj-name
          scr-sum-base
          scr-sum-qnty scr-sum-rubl
          scr-wrkr-name
          scr-agnt-name
          scr-boss-name
          scr-cli-name
          scr-cli
          scr-contract
          WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help scr-ship-date B-add B-chg B-del
          BROWSE-2
         scr-wrkr r-wrkr
         scr-agnt r-agnt
         scr-boss r-boss
         b-contract B-delivery
         b-specif
         r-cli
         WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  Run OpenBr.



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

define input parameter p-widget-handle as handle no-undo .
define variable l-apply-entry as logical no-undo .

assign
  l-apply-entry = /* false */  true
.

do with frame {&frame-name} :
  if  scr-ship-date   :handle = p-widget-handle then do:  if  scr-wrkr        :sensitive then do: apply "entry":u to scr-wrkr       . return . end. end.
  if scr-wrkr         :handle = p-widget-handle then do:  if  scr-agnt        :sensitive then do: apply "entry":u to scr-agnt       . return . end. end.
  if scr-agnt         :handle = p-widget-handle then do:  if  scr-boss        :sensitive then do: apply "entry":u to scr-boss       . return . end. end.
  if scr-boss         :handle = p-widget-handle then do:  if  B-add           :sensitive then do: apply "entry":u to B-add          . return . end. end.
  if  B-add           :handle = p-widget-handle then do:  if  B-exit          :sensitive then do: apply "entry":u to B-exit    .      return . end. end.

  end. /* do with frame */


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

&scop OPEN-QUERY   OPEN QUERY browse-2 FOR EACH X_ord-line no-lock  ~
WHERE X_ord-line.doc-code = loc-ord-num , ~
EACH X_goods no-lock WHERE X_goods.artic = X_ord-line.artic  ~
AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type ~
by ~{&s-pole} .

/* message sort-column-name . */

case sort-column-name :
  when "{&col-1}" then do:
    &scop s-pole {&col-1}
    {&OPEN-QUERY}
  end.
  when "{&col-2}" then do:
    &scop s-pole {&col-2}
    {&OPEN-QUERY}
  end.
  when "{&col-3}" then do:
    &scop s-pole {&col-3}
    {&OPEN-QUERY}
  end.
  when "{&col-4}" then do:
    &scop s-pole {&col-4}
    {&OPEN-QUERY}
  end.
  when "{&col-5}" then do:
    &scop s-pole {&col-5}
    {&OPEN-QUERY}
  end.
  when "{&col-6}" then do:
    &scop s-pole {&col-6}
    {&OPEN-QUERY}
  end.
  when "{&col-7}" then do:
    &scop s-pole {&col-7}
    {&OPEN-QUERY}
  end.
  when "{&col-8}" then do:
    &scop s-pole {&col-8}
    {&OPEN-QUERY}
  end.
  when "{&col-9}" then do:
    &scop s-pole {&col-9}
    {&OPEN-QUERY}
  end.
otherwise do:
  {&OPEN-QUERY-BROWSE-2}
end.
end case.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-delete Dialog-Frame
PROCEDURE p-delete :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter tmp-recid as recid no-undo .
define input-output parameter ii as integer no-undo . .

    find first tmp#zakaz where recid(tmp#zakaz) = tmp-recid no-error .
    if not avail tmp#zakaz then return error.

    find first shar_ord-line  exclusive-lock    where
        shar_ord-line.doc-code        = loc-ord-num    and
        shar_ord-line.prod-type       = tmp#zakaz.prod-type and
        shar_ord-line.prod-code       = tmp#zakaz.prod-code and
        shar_ord-line.artic           = tmp#zakaz.artic     no-error.
    if not available shar_ord-line  then  return error .
    delete shar_ord-line .
    delete tmp#zakaz .
    ii = ii - 1 .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define variable ii as int init 0 no-undo.
define variable r-tmp as recid no-undo .
define variable r-ord as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable l-g#type as character no-undo .
define variable l-g#status as character no-undo .
define variable t-ret as logical no-undo .
define variable varschartic       like ub.price-list.artic initial " " no-undo.
define variable v-ref-list  as char                     no-undo.
define buffer buf_ord-line for ub.ord-line  .

    run str/chsgdsls.w (
        parParentProc ,
        input "order" + {&P-O},
        input "Строка документа № " + loc-ord-num , ? , ? ,
        input v-cntxt-host-code-obj,
        input-output varschartic,
        output v-ref-list,
        output table tt-gds-list,
        false
        ) no-error.

    if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
           "Ошибка procedure chsgdsls.w " skip
            skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error
    .
    return error  .
    end.

    t-ret =  session:set-wait-state("general") .
    line-mode = {&add-def} .
    for each tt-gds-list no-lock :
      ii = ii + 1 .
      if ii > 1 then assign line-mode = "ЦИКЛ":u.
      find first  buf_ord-line  exclusive-lock      where
                  buf_ord-line.gds-code = tt-gds-list.gds-code  and
                  buf_ord-line.doc-code = loc-ord-num
                  no-error .
            if available buf_ord-line then do:
                run cus/ord-frmp.w (parParentProc , input ?  , input recid ( buf_ord-line)  , input {&update},  output r-stop , output r-exit ) no-error .
            end.
            else do:
                run create-tmp in this-procedure  ( input "tt-gds-list":u , input  false , output r-tmp , output r-ord).
                run cus/ord-frmp.w ( parParentProc ,input r-tmp  , input r-ord  , input line-mode,  output r-stop , output r-exit ) .
                    if r-stop then do:
                      run p-delete ( r-tmp , input-output ii).
                      leave.
                    end.
                    if r-exit then do:
                        run p-delete ( r-tmp , input-output ii ) .
                    end.
          end.
    end.

    Run OpenBr.
    t-ret =  session:set-wait-state("") .
    message "Добавлено " + string(ii) + " товаров".


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-renum Dialog-Frame
PROCEDURE proc-renum :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define variable g-ok as logical no-undo .
define variable g as integer no-undo .
define buffer buf_ord-line for ub.ord-line.
 message " Перенумеровать список товаров ? "
    view-as alert-box question
    buttons yes-no
    UPDATE g-ok
    .
    if g-ok = false then return.
    g = 0 .
    for each buf_ord-line  exclusive-lock  where buf_ord-line.doc-code = loc-ord-num  by buf_ord-line.line-num :
        g = g + 1.
        buf_ord-line.line-num = g.
    end.
    run openbr.
 end. /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-head Dialog-Frame
PROCEDURE recalc-head :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer buf_ord-line for ub.ord-line.
define variable s-1 as decimal init 0 no-undo .
define variable s-2 as decimal init 0 no-undo .
define variable s-0 as decimal init 0 no-undo .

     assign frame {&frame-name}
     scr-ship-date
.


for each  buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  :
    s-1  = s-1  + buf_ord-line.sum-rubl .
    s-2  = s-2  + buf_ord-line.sum-base .
    s-0  = s-0  + buf_ord-line.qnty     .

end. /* for each */

assign
  scr-sum-qnty = s-0
  scr-sum-rubl = s-1
  scr-sum-base = s-2
.
display
 scr-sum-qnty
 scr-sum-rubl
 scr-sum-base
 with frame {&frame-name} .


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE step-next Dialog-Frame
PROCEDURE step-next :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  if valid-handle (br-handle) then do:
  v-log = br-handle:select-next-row () no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     v-log = false .
     end.

  if not v-log then message "Это последний документ списка.".
end.

    p-ord-doc-recid = recid ( buf-po_ord-doc ).
    next-prev = yes.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE step-prev Dialog-Frame
PROCEDURE step-prev :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

  if valid-handle (br-handle) then do:
  v-log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     v-log = false .
  end.
  if not v-log then do: message "Это первый документ списка.".   end.
end.
p-ord-doc-recid = recid (buf-po_ord-doc).
next-prev = yes .


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE x-delete Dialog-Frame
PROCEDURE x-delete :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-recid as recid no-undo .
define input-output parameter ii as integer no-undo . .
    find first shar_ord-line  exclusive-lock  where recid(shar_ord-line) = p-recid  .
    if not available shar_ord-line  then  return error .
    find first tmp#zakaz   where
                tmp#zakaz.prod-type = shar_ord-line.prod-type         and
                tmp#zakaz.prod-code = shar_ord-line.prod-code         and
                tmp#zakaz.artic     = shar_ord-line.artic             no-error.
    if  avail tmp#zakaz then delete tmp#zakaz .
    delete shar_ord-line .
    ii = ii - 1 .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-zapr-qnty Dialog-Frame
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line , par-type as char ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_doc-line     for ub.doc-line .
define buffer buf_trn-doc      for ub.trn-doc  .
define variable  res as decimal no-undo init 0 .

for each buf_ord-line-rcv no-lock
    where buf_ord-line-rcv.doc-code  = buf_ord-line.doc-code  and
          buf_ord-line-rcv.artic     = buf_ord-line.artic     and
          buf_ord-line-rcv.prod-type = buf_ord-line.prod-type and
          buf_ord-line-rcv.prod-code = buf_ord-line.prod-code
          on error undo, return error :

          find first buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.rcv-code  = buf_ord-line-rcv.rcv-code  and
                    buf_ord-doc-rcv.doc-code  = buf_ord-line-rcv.doc-code  no-error .
                    if error-status :error then next .
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
                find first buf_trn-doc no-lock  where
                          buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code and
                          buf_trn-doc.doc-type = par-type
                                    no-error .
                if not available buf_trn-doc then next .
                if buf_trn-doc.doc-type = {&income} then
                  if buf_trn-doc.status_ <>  {&inquiry} then next.

                find first buf_doc-line no-lock where
                          buf_doc-line.doc-code  = buf_trn-doc.doc-code  and
                          buf_doc-line.artic     = buf_ord-line.artic     and
                          buf_doc-line.prod-type = buf_ord-line.prod-type and
                          buf_doc-line.prod-code = buf_ord-line.prod-code  no-error .
                          if error-status :error then next .

                res  = res  + buf_doc-line.fact-qnty .

        end. /* for each */
end. /* for each */



  RETURN res .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
