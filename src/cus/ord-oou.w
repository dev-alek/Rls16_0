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

Корректировка заказов ОО

Автор: Чернова Светлана Александровна
Дата создания: 09/21/05
Author: Svetlana Chernova
Creation date: 09/21/05

Creation date: 06/15/04 7:38

*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER         parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input parameter         p-mode            as character no-undo .
define input-output  parameter p-ord-doc-recid as recid no-undo .
define input-output  parameter br-handle       as handle  no-undo .
define input-output  parameter next-prev       as logical   no-undo .

DEFINE  SHARED BUFFER BUF-OO_ORD-DOC FOR ub.ORD-DOC.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка заказов ОО".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cus/df-zakaz.i new }
{ cmp/r-page1.i  new }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }

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
&scop col-l10  'Текущий остаток'


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




define buffer   buf_ord-doc for ub.ord-doc .
define buffer   buf_clients for ub.clients .
define variable loc-obj-code as integer no-undo .
define variable loc-obj-type as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-log      as logical   no-undo .
define variable gds-rec as recid no-undo .

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.


define variable v-fact-qnty          as decimal   no-undo.
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .

define variable v-transport-host-code       as integer   no-undo .
define variable v-transport-cli-type       as character no-undo .
define variable v-transport-cli-code   as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .

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
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 X_ord-line.line-num X_goods.gds-code X_ord-line.artic X_goods.gds-name X_ord-line.qnty f-zapr-qnty ( Buffer X_ord-line , {&income} ) f-zapr-qnty ( Buffer X_ord-line , {&expense} ) X_ord-line.price-rubl X_ord-line.price-base X_ord-line.sum-base X_ord-line.sum-rubl v-fact-qnty
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
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-delivery B-notes B-help ~
scr-ship-date scr-date-sale-1 scr-date-sale-2 scr-wrkr r-wrkr ~
scr-order-type scr-agnt r-agnt scr-boss r-boss scr-e-method B-ins B-chg ~
B-del B-calc b-renum t-auto BROWSE-2 scr-obj-name scr-wrkr-name ~
scr-agnt-name scr-boss-name scr-sum-qnty scr-sum-rubl scr-sum-base
&Scoped-Define DISPLAYED-OBJECTS scr-ship-date scr-date-sale-1 ~
scr-date-sale-2 scr-wrkr scr-order-type scr-agnt scr-boss scr-e-method ~
t-auto scr-obj-name scr-wrkr-name scr-agnt-name scr-boss-name scr-sum-qnty ~
scr-sum-rubl scr-sum-base

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
DEFINE BUTTON B-calc
     LABEL "&Рассчитать"
     SIZE 12 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

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

DEFINE BUTTON B-ins
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.

DEFINE BUTTON B-notes
     LABEL "Примечание"
     SIZE 11.5 BY 1 TOOLTIP "Примечание по заказу".

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-renum
     LABEL "№ п/п"
     SIZE 10 BY 1 TOOLTIP "Перенумеровать список товаров".

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

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r boss 2"
     SIZE 3 BY .88.

DEFINE VARIABLE scr-e-method AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.38 BY 6.04
     BGCOLOR 8 FONT 4 NO-UNDO.

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

DEFINE VARIABLE scr-date-sale-1 AS DATE FORMAT "99/99/9999":U
     LABEL "Период продаж с"
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1 NO-UNDO.

DEFINE VARIABLE scr-date-sale-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1 NO-UNDO.

DEFINE VARIABLE scr-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "на Объект"
      VIEW-AS TEXT
     SIZE 37.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-ship-date AS DATE FORMAT "99/99/9999":U
     LABEL "Заказ на"
     VIEW-AS FILL-IN
     SIZE 11.13 BY 1 TOOLTIP "Заказ на дату" NO-UNDO.

DEFINE VARIABLE scr-sum-base AS DECIMAL FORMAT ">>>>>>>>>9.99":U INITIAL 0
     LABEL "Итого сумма (вал)"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-sum-qnty AS DECIMAL FORMAT ">>>>>>>>>9.<<<":U INITIAL 0
     LABEL "Итого кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-sum-rubl AS DECIMAL FORMAT ">>>>>>>>>9.99":U INITIAL 0
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

DEFINE VARIABLE scr-order-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Распределять в ГБД", 2,
"Распределять в УБД", 3
     SIZE 21.63 BY 1.71 TOOLTIP "Где создавать запросы в УБД или ГБД"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE t-auto AS LOGICAL INITIAL yes
     LABEL "авто"
     VIEW-AS TOGGLE-BOX
     SIZE 7 BY .83 NO-UNDO.

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
      X_ord-line.line-num    COLUMN-LABEL  {&col-l1}  FORMAT ">>>>9"
      X_goods.gds-code       COLUMN-LABEL  {&col-l2}  FORMAT ">>>>>>>>9"
      X_ord-line.artic       COLUMN-LABEL  {&col-l3}
      X_goods.gds-name       COLUMN-LABEL  {&col-l4}  FORMAT "X(40)"
      X_ord-line.qnty        COLUMN-LABEL  {&col-l5}  FORMAT ">>,>>>,>>9.<<<"
      f-zapr-qnty ( Buffer X_ord-line , {&income} )     COLUMN-LABEL  "Запр.прих."  FORMAT "->>>>>>>>.<<<"
      f-zapr-qnty ( Buffer X_ord-line , {&expense} )     COLUMN-LABEL  "Запр.расх."  FORMAT "->>>>>>>>.<<<"
      X_ord-line.price-rubl  COLUMN-LABEL  {&col-l6}  FORMAT ">,>>>,>>9.99"
      X_ord-line.price-base  COLUMN-LABEL  {&col-l7}  FORMAT ">,>>>,>>9.99"
      X_ord-line.sum-base    COLUMN-LABEL  {&col-l8}  FORMAT ">>>,>>>,>>9.99"
      X_ord-line.sum-rubl    COLUMN-LABEL  {&col-l9}  FORMAT ">>>,>>>,>>9.99"
      v-fact-qnty            COLUMN-LABEL  {&col-l10} FORMAT "->>,>>>,>>9.<<<"

  ENABLE
      X_ord-line.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 9.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-delivery AT ROW 1 COL 21
     B-notes AT ROW 1 COL 31 WIDGET-ID 2
     B-help AT ROW 1 COL 86.13
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 6
     scr-ship-date AT ROW 2.08 COL 24.13 COLON-ALIGNED
     scr-date-sale-1 AT ROW 2.08 COL 54.25 COLON-ALIGNED
     scr-date-sale-2 AT ROW 2.08 COL 70 COLON-ALIGNED
     scr-wrkr AT ROW 3.17 COL 5.88 COLON-ALIGNED
     r-wrkr AT ROW 3.21 COL 17.88
     scr-order-type AT ROW 4.04 COL 74.63 NO-LABEL
     scr-agnt AT ROW 4.21 COL 5.75 COLON-ALIGNED
     r-agnt AT ROW 4.29 COL 17.88
     scr-boss AT ROW 5.33 COL 5.75 COLON-ALIGNED
     r-boss AT ROW 5.42 COL 17.88
     scr-e-method AT ROW 6.54 COL 1 NO-LABEL
     B-ins AT ROW 12.83 COL 1
     B-chg AT ROW 12.83 COL 11
     B-del AT ROW 12.83 COL 21
     B-calc AT ROW 12.83 COL 31
     b-renum AT ROW 12.83 COL 43
     t-auto AT ROW 13.04 COL 88.25
     BROWSE-2 AT ROW 14 COL 1
     scr-obj-name AT ROW 3.25 COL 56.75 COLON-ALIGNED
     scr-wrkr-name AT ROW 3.33 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-agnt-name AT ROW 4.46 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-boss-name AT ROW 5.63 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-sum-qnty AT ROW 6.29 COL 80.38 COLON-ALIGNED
     scr-sum-rubl AT ROW 7 COL 80.38 COLON-ALIGNED
     scr-sum-base AT ROW 7.83 COL 80.38 COLON-ALIGNED
     SPACE(0.12) SKIP(15.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заказ ОО".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_goods B "?" ? ub ub.goods
      TABLE: X_ord-line B "NEW SHARED" ? ub ub.ord-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 t-auto Dialog-Frame */
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
ON GO OF FRAME Dialog-Frame /* Заказ ОО */
DO:

 define buffer buf_ord-line for ub.ord-line.
 define variable v-kol as integer init 0 no-undo .

  if p-mode =  {&lookup} then return.

  if p-mode <> {&lookup} then do:
     assign frame {&frame-name}
     scr-ship-date
     scr-e-method
     scr-date-sale-1
     scr-date-sale-2
     scr-wrkr
     scr-agnt
     scr-boss
     scr-order-type
     .
     loc-date-ship = scr-ship-date .
     if scr-date-sale-2 <  scr-date-sale-1 then do:
        message "Не верно введен интервал дат !"  .
        return no-apply .
     end.
     if scr-date-sale-1 <  loc-date-ship then do:
        message "Дата интервала меньше даты заказа !" .
        return no-apply .
     end.

  if can-find
    ( first buf_ord-line  no-lock    where
            buf_ord-line.doc-code = loc-ord-num  and
            buf_ord-line.qnty  =  0 ) then do:
      message "В заказе есть нерассчитанные строки . Удаляем их ? " view-as alert-box question  buttons yes-no update v-log.
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
              find first buf-oo_ord-doc exclusive-lock where recid(buf-oo_ord-doc) = p-ord-doc-recid  no-error.
              if available buf-oo_ord-doc then
              delete buf-oo_ord-doc.
              p-ord-doc-recid = ? .
              return.
            end.
     end.
  end.
  find current buf_ord-doc exclusive-lock no-error .
  assign
    buf_ord-doc.sum-rubl = s-1
    buf_ord-doc.sum-base = s-2
    buf_ord-doc.qnty     = s-3
    buf_ord-doc.e-method = scr-e-method
    buf_ord-doc.date-sale-1 = scr-date-sale-1
    buf_ord-doc.date-sale-2 = scr-date-sale-2
    buf_ord-doc.ship-date = scr-ship-date
    buf_ord-doc.wrkr   = scr-wrkr
    buf_ord-doc.boss   = scr-boss
    buf_ord-doc.agnt   = scr-agnt
    buf_ord-doc.status_     = {&g___new}
    buf_ord-doc.order-type  = scr-order-type
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
              run cus/ordoocls.p
                ( input parParentProc ,
                  input recid(buf_ord-doc) ,
                  input true
                  ) no-error .
              if error-status :error then return  .
            end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заказ ОО */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-calc Dialog-Frame
ON CHOOSE OF B-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:
define buffer buf_ord-line for ub.ord-line.
define buffer buf_goods for ub.goods.
assign frame {&frame-name} scr-ship-date scr-date-sale-1 scr-date-sale-2.
loc-date-ship = scr-ship-date .
date-sale-1 = scr-date-sale-1 .
date-sale-2 = scr-date-sale-2 .

if loc-date-ship < today then do:
   message "Для расчета заказа ДАТА ЗАКАЗА должна быть не меньше текущей " view-as alert-box information .
   return no-apply.
end.

if date-sale-1 < loc-date-ship then do:
   message "Для расчета заказа ДАТА ПЕРИОДА должна быть больше даты заказа " view-as alert-box information .
   return no-apply.
end.
if date-sale-2 <  date-sale-1 then do:
  message "Не верно введен интервал дат !" .
  return no-apply .
end.

for each tmp#zakaz :
    delete tmp#zakaz  .
end. /* for each */

for each  buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  :
    find first buf_goods no-lock where
            buf_goods.artic     = buf_ord-line.artic     and
            buf_goods.prod-type = buf_ord-line.prod-type and
            buf_goods.prod-code = buf_ord-line.prod-code .
    create tmp#zakaz .
    BUFFER-COPY buf_ord-line to tmp#zakaz
  assign
    tmp#zakaz.gds-code        = buf_goods.gds-code
    tmp#zakaz.prod-type       = buf_goods.prod-type
    tmp#zakaz.prod-code       = buf_goods.prod-code
    tmp#zakaz.artic           = buf_goods.artic
    tmp#zakaz.gds-name        = buf_goods.gds-name
    tmp#zakaz.deadline        = buf_goods.deadline
    tmp#zakaz.unit-cli        = buf_goods.unit-cli
    tmp#zakaz.unit-base       = buf_goods.unit-base
    tmp#zakaz.negative-rest   = buf_goods.negative-rest
    tmp#zakaz.cli-base-rate   = 1
    tmp#zakaz.ms-cart         = buf_goods.qnty-cart
    .


end. /* for each */
if not can-find (first tmp#zakaz )  then return.

if scr-date-sale-2 = ? or scr-date-sale-1 = ? then
    message  "ПРЕДУПРЕЖДЕНИЕ :  Не задан период продаж !"
    view-as alert-box information
    title "Внимание!!!".

pay-day =  scr-date-sale-2 - scr-date-sale-1 + 1.
if pay-day = 0 or pay-day = ? then pay-day = 1 .
loc-store-code = v-cntxt-obj-code .
loc-store-type = v-cntxt-obj-type .
loc-doc-type   = {&o-o}     .

if not available buf-oo_ord-doc then do:
   find first buf-oo_ord-doc exclusive-lock where buf-oo_ord-doc.doc-code = loc-ord-num  no-error.
   if error-status :error then
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "orderOO"
     view-as alert-box error
   .
end.
run cus/ord-m.w  ( input parParentProc ,  input ? , buf-oo_ord-doc.doc-type ) .
scr-e-method = e-method .
display scr-e-method with frame {&frame-name} .

run openbr in this-procedure .
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
     run cus/ord-frmo.w (parParentProc , input ?  , input r-recid  , input {&update},  output r-stop , output r-exit ) .
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
      ,input        "ord" + {&o-o}
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


&Scoped-define SELF-NAME B-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ins Dialog-Frame
ON CHOOSE OF B-ins IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add.
  run recalc-head.
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


&Scoped-define SELF-NAME B-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-notes Dialog-Frame
ON CHOOSE OF B-notes IN FRAME Dialog-Frame /* Примечание */
DO:
  run proc-d-notes in this-procedure .
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
        find first buf-oo_ord-doc exclusive-lock where recid(buf-oo_ord-doc) = p-ord-doc-recid  no-error.
        if available buf-oo_ord-doc then
        delete buf-oo_ord-doc.
      end.
     end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-renum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-renum Dialog-Frame
ON CHOOSE OF b-renum IN FRAME Dialog-Frame /* № п/п */
DO:
run proc-renum.

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


&Scoped-define SELF-NAME scr-date-sale-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-date-sale-1 Dialog-Frame
ON return OF scr-date-sale-1 IN FRAME Dialog-Frame /* Период продаж с */
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME scr-date-sale-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL scr-date-sale-2 Dialog-Frame
ON return OF scr-date-sale-2 IN FRAME Dialog-Frame /* по */
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


&Scoped-define SELF-NAME t-auto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-auto Dialog-Frame
ON VALUE-CHANGED OF t-auto IN FRAME Dialog-Frame /* авто */
DO:
  assign   frame {&frame-name} t-auto.
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
  {&col-4 }:resizable in browse {&browse-name}   = true
  .
{ gbl/brwrepos.i
  &line-num=8
}
{ gbl/ed_date.i scr-ship-date}
{ gbl/ed_date.i scr-date-sale-1}
{ gbl/ed_date.i scr-date-sale-2}
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

      run create-ord-doc(
          input loc-ord-num  ,
          input ?            ,
          input ""           ,
          input ""           ,
          input ""           ,
          input v-cntxt-host-code-obj  ,
          input v-cntxt-obj-code   ,
          input v-cntxt-obj-type   ,
          input {&o-o}       ,
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
scr-e-method:read-only in frame {&frame-name}  = true .
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
      ub.ord-doc.ship-date  = p-ship-date
      ub.ord-doc.order-type = p-order-type

      p-recid = recid (ord-doc)

      .


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

def input parameter tt as char no-undo.
def input parameter t as char no-undo.
define output parameter p-tmp as recid no-undo .
define output parameter p-ord as recid no-undo .
define variable prod-type#   like ub.ord-line.prod-type         no-undo .
define variable prod-code#   like ub.ord-line.prod-code         no-undo .
define variable artic#       like ub.ord-line.artic             no-undo .

define buffer ll-buf_ord-line for ub.ord-line .

define variable p-recid as recid no-undo .
      find first ub.goods where
            ub.goods.artic     = tt-gds-list.artic     and
            ub.goods.prod-type = tt-gds-list.prod-type and
            ub.goods.prod-code = tt-gds-list.prod-code no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! tt-gds-list не = ub.goods !"
                1
                view-as alert-box error .
            end.

      find  first ub.gds-obj  where
            ub.gds-obj.obj-type  = v-cntxt-obj-type and
            ub.gds-obj.obj-code  = v-cntxt-obj-code and
            ub.gds-obj.artic     = tt-gds-list.artic      and
            ub.gds-obj.prod-type = tt-gds-list.prod-type  and
            ub.gds-obj.prod-code = tt-gds-list.prod-code  no-lock no-error.

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

  { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code tmp#zakaz.vat-pc no-error }

  .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .

find first ub.gds-obj no-lock    where
    ub.gds-obj.obj-type        = v-cntxt-obj-type and
    ub.gds-obj.obj-code        = v-cntxt-obj-code and
    ub.gds-obj.prod-type       = ub.goods.prod-type and
    ub.gds-obj.prod-code       = ub.goods.prod-code and
    ub.gds-obj.artic           = ub.goods.artic     no-error.
    if available ub.gds-obj then do:
        define variable v-baz-val as integer no-undo .
        define variable v-base-rate  as decimal no-undo .
        define variable v-base-scale  as decimal no-undo .
        define variable p-r-b-abbr as character no-undo .
        { gbl/basecode.i v-cntxt-host-code-obj v-baz-val}
        { gbl/curr-r-b.i p-r-b-abbr}
        if p-r-b-abbr = {&r-b-rubl} then do:
              if v-baz-val = 0 then
                  assign
                    tmp#zakaz.price-base = ub.gds-obj.price-sale
                    tmp#zakaz.price-rubl = ub.gds-obj.price-sale
                    tmp#zakaz.price-cli  = ub.gds-obj.price-sale
                  .
                else do:
                  { gbl/baserate.i
                    v-cntxt-host-code-obj
                    today
                    v-base-rate
                    v-base-scale
                  }
                  assign
                    tmp#zakaz.price-rubl = ub.gds-obj.price-sale
                    tmp#zakaz.price-base = tmp#zakaz.price-rubl /( v-base-rate * v-base-scale )
                    tmp#zakaz.price-cli  = tmp#zakaz.price-rubl
                  .
                end.
          end.
          else do: /*rb = base */
                  { gbl/baserate.i
                    v-cntxt-host-code-obj
                    today
                    v-base-rate
                    v-base-scale
                  }
                  assign
                    tmp#zakaz.price-base = ub.gds-obj.price-sale
                    tmp#zakaz.price-rubl = tmp#zakaz.price-base * ( v-base-rate / v-base-scale )
                    tmp#zakaz.price-cli  = tmp#zakaz.price-base
                  .
          end.
   end.
   else do:
   assign
     tmp#zakaz.price-base = 0
     tmp#zakaz.price-rubl = 0
     tmp#zakaz.price-cli  = 0
   .
   end.

find first shar_ord-line   exclusive-lock   where
    shar_ord-line.doc-code        = loc-ord-num    and
    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
    shar_ord-line.artic           = tmp#zakaz.artic     no-error.

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
  DISPLAY scr-ship-date scr-date-sale-1 scr-date-sale-2 scr-wrkr scr-order-type
          scr-agnt scr-boss scr-e-method t-auto scr-obj-name scr-wrkr-name
          scr-agnt-name scr-boss-name scr-sum-qnty scr-sum-rubl scr-sum-base
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-delivery B-notes B-help scr-ship-date scr-date-sale-1
         scr-date-sale-2 scr-wrkr r-wrkr scr-order-type scr-agnt r-agnt
         scr-boss r-boss scr-e-method B-ins B-chg B-del B-calc b-renum t-auto
         BROWSE-2 scr-obj-name scr-wrkr-name scr-agnt-name scr-boss-name
         scr-sum-qnty scr-sum-rubl scr-sum-base
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
  scr-date-sale-1  = buf_ord-doc.date-sale-1
  scr-date-sale-2  = buf_ord-doc.date-sale-2
  scr-e-method     = buf_ord-doc.e-method
  e-method         = buf_ord-doc.e-method
  loc-obj-code     = buf_ord-doc.obj-code
  loc-obj-type     = buf_ord-doc.obj-type
  loc-doc-type     = buf_ord-doc.doc-type
  scr-obj-name     = buf_clients.obj-name
  loc-ord-num      = buf_ord-doc.doc-code
  scr-wrkr         = buf_ord-doc.wrkr
  scr-boss         = buf_ord-doc.boss
  scr-agnt         = buf_ord-doc.agnt
  scr-order-type   =  buf_ord-doc.order-type
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

 .
 run leave-proc-wrkr .
 run leave-proc-boss .
 run leave-proc-agnt .

     ASSIGN frame {&frame-name}:TITLE = "Заказ  № " + loc-ord-num
   + " Тип: " +     buf_ord-doc.doc-type
   + " Статус: "  +  buf_ord-doc.status_
   + " - " + caps(p-mode).

assign
scr-agnt:label in frame {&frame-name}     =  "И&сп"
scr-agnt:tooltip in frame {&frame-name}   =  "Код исполнителя"
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
                  scr-e-method scr-date-sale-1 scr-date-sale-2 scr-sum-base scr-sum-qnty scr-sum-rubl
                    scr-order-type
      WITH FRAME Dialog-Frame.

  ENABLE b-exit b-next b-prev B-help BROWSE-2 scr-e-method /*b-delivery*/ b-notes
       WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
      hide b-delivery b-quit in FRAME Dialog-Frame.
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
          scr-e-method scr-date-sale-1 scr-date-sale-2 scr-sum-base
          scr-sum-qnty scr-sum-rubl
          scr-wrkr-name
          scr-agnt-name
          scr-boss-name
          scr-order-type
          t-auto

              WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help scr-ship-date B-ins B-chg B-del b-notes
         B-calc BROWSE-2 b-renum t-auto
         scr-e-method scr-date-sale-1 scr-date-sale-2
         scr-wrkr r-wrkr
         scr-agnt r-agnt
         scr-boss r-boss
         scr-order-type
         /* b-delivery */
         WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  hide b-delivery in FRAME Dialog-Frame.
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
  if  scr-ship-date   :handle = p-widget-handle then do:  if  scr-date-sale-1 :sensitive then do: apply "entry":u to scr-date-sale-1. return . end. end.
  if  scr-date-sale-1 :handle = p-widget-handle then do:  if  scr-date-sale-2 :sensitive then do: apply "entry":u to scr-date-sale-2. return . end. end.
  if  scr-date-sale-2 :handle = p-widget-handle then do:  if  scr-wrkr        :sensitive then do: apply "entry":u to scr-wrkr       . return . end. end.
  if  scr-wrkr        :handle = p-widget-handle then do:  if  scr-agnt        :sensitive then do: apply "entry":u to scr-agnt       . return . end. end.
  if  scr-agnt        :handle = p-widget-handle then do:  if  scr-boss        :sensitive then do: apply "entry":u to scr-boss       . return . end. end.
  if  scr-boss        :handle = p-widget-handle then do:  if  b-ins           :sensitive then do: apply "entry":u to b-ins          . return . end. end.
  if  b-ins           :handle = p-widget-handle then do:  if  B-exit          :sensitive then do: apply "entry":u to B-exit    .      return . end. end.

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
 /*
   l-g#status = g#stat.
   l-g#type   = g#type.
 */

define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable v-ref-list  as character  no-undo.
     run str/chsgdsls.w (
        parParentProc ,
        input "order" + {&O-O}  ,
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
   /*
   g#type = l-g#type.
   g#stat = l-g#status.
   */
   t-ret =  session:set-wait-state("general") .
   line-mode = {&add-def} .
   for each tt-gds-list no-lock :
     ii = ii + 1 .
     if ii > 1 then assign line-mode = "ЦИКЛ":u.

     run create-tmp in this-procedure  (input "tt-gds-list":u, "" , output r-tmp , output r-ord).
     if not t-auto then do:
                run cus/ord-frmo.w ( parParentProc ,input r-tmp  , input r-ord  , input line-mode,  output r-stop , output r-exit ) .
                   if r-stop then do:
                      run p-delete ( r-tmp , input-output ii).
                      leave.
                      end.
                   if r-exit then do:
                       run p-delete( r-tmp , input-output ii ) .
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
     scr-e-method
     scr-date-sale-1
     scr-date-sale-2
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

    p-ord-doc-recid = recid ( buf-oo_ord-doc ).
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
p-ord-doc-recid = recid (buf-oo_ord-doc).
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
define input parameter p-recid as recid no-undo .
define input-output parameter ii as integer no-undo . .

 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
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
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_doc-line          for ub.doc-line .
define buffer buf_trn-doc           for ub.trn-doc  .
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
                     buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code  and
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

procedure proc-d-notes :
 do
 on error undo, return error return-value
 :

define variable  doc-rec     as  recid no-undo .
define buffer    buf_ord-doc for ub.ord-doc    .
define variable  notes       as  character no-undo .


find first buf_ord-doc where
           buf_ord-doc.doc-code  = loc-ord-num
          no-lock no-error .

doc-rec = recid (buf_ord-doc)  .
notes = buf_ord-doc.ps .

 run gbl/d-prompt.w (
        'title=примечание\'
      + 'type=editor\'
      + 'fillin_width=96\'
      + 'fillin_height=15\'
      +  ( if p-mode = {&lookup} then 'readonly=yes\':u else '' )
      , input-output notes ).
      if return-value = 'false':U
      then do:
        return .
      end.

    if p-mode <> {&lookup}  then do:
        if buf_ord-doc.ps <> notes then do:
          do on stop undo, return error:
            find buf_ord-doc where recid ( buf_ord-doc ) = doc-rec exclusive no-error .
            if available buf_ord-doc then do:
              buf_ord-doc.ps = notes.
            end.
          end.
        end.
    find first buf_ord-doc where recid ( buf_ord-doc ) = doc-rec no-lock no-error.
    end.

 end. /* do */
end procedure. /* proc-d-notes */