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

Корректировка заказов ОР

Автор: Чернова Светлана Александровна
Дата создания: 04/14/06
Author: Svetlana Chernova
Creation date: 04/14/06


*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle no-undo .
define input-output parameter p-ord-doc-recid as recid no-undo .
define input parameter p-mode as character no-undo .
define input-output parameter br-handle as handle  no-undo .
define input-output parameter next-prev as logical   no-undo .

define  shared buffer buf-or_ord-doc for ub.ord-doc.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка заказов ОО".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i  }
{ gbl/usr-flt.i  }
{ cus/df-zakaz.i new }
{ cmp/r-page1.i  new }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cus/ord-code.i def }
{ str/cntrcode.i }
{ gbl/thbj-def.i }
{ str/vrclvmd.i  }
{ str/cont-ms-def.i }



&scop col-l1   'N/п'
&scop col-l2   'Код'
&scop col-l3   'Артикул'
&scop col-l4   'Название'
&scop col-l5   'Кол-во'
&scop col-l6   'Рекомен-!довано  '
&scop col-l7   'ед.!изм'
&scop col-l8   'Заказано!в днях'
&scop col-l9   'Заказано'
&scop col-l10  'Текущий!остаток РЦ'
&scop col-l11  'ABC1'
&scop col-l12  'ABC2'
&scop col-l13  'Темп'
&scop col-l14  'Свободный!остаток РЦ'
&scop col-l15  'Остаток на!момент расчета'
&scop col-l16  'Остаток!в днях'

&scop col-1   X_ord-line.line-num
&scop col-2   X_goods.gds-code
&scop col-3   X_ord-line.artic
&scop col-4   X_goods.gds-name
&scop col-5   X_ord-line.qnty
&scop col-6   X_ord-line.initial-qnty
&scop col-7   X_goods.unit-base
&scop col-8   ( if X_ord-line.temp-rash <> 0 then X_ord-line.order-qnty / X_ord-line.temp-rash  else 0 )
&scop col-9   X_ord-line.order-qnty
&scop col-10  v-rc-qnty
&scop col-11  (chr(int(X_ord-line.add-cli-qnty)) + string(X_ord-line.add-qnty))
&scop col-12  (chr(int(X_ord-line.cancel-cli-qnty)) + string(X_ord-line.cancel-qnty))
&scop col-13  X_ord-line.temp-rash
&scop col-14  v-rc-qnty-free
&scop col-15  X_ord-line.qnty-stk
&scop col-16  ( if X_ord-line.temp-rash <> 0 then X_ord-line.qnty-stk / X_ord-line.temp-rash  else 0 )

&scop head-col ~
 {&col-l1} + '#' + ~
 {&col-l2} + '#' + ~
 {&col-l3} + '#' + ~
 {&col-l4} + '#' + ~
 {&col-l5} + '#' + ~
 {&col-l6} + '#' + ~
 {&col-l7} + '#' + ~
 {&col-l8} + '#' + ~
 {&col-l9} + '#' + ~
 {&col-l10} + '#' + ~
 {&col-l11} + '#' + ~
 {&col-l12} + '#' + ~
 {&col-l13} + '#' + ~
 {&col-l14} + '#' + ~
 {&col-l15} + '#' + ~
 {&col-l16}

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

define variable flag as logical   no-undo init false .
define variable v-quest as logical   no-undo init true .
define variable v-update-price as integer   no-undo .
define variable choice   as      logical no-undo    init ?.

define variable g#ok        as logical   no-undo .
define variable g#log       as logical   no-undo .
define variable gds-rec     as recid no-undo .
define variable line-mode   as character no-undo .
define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .
define variable v-size-col3 as decimal   no-undo .
define variable v-size-col4 as decimal   no-undo .
define variable v-size-col5 as decimal   no-undo .
define variable v-size-col6 as decimal   no-undo .
define variable v-size-col7 as decimal   no-undo .
define variable v-size-col8 as decimal   no-undo .
define variable v-size-col9 as decimal   no-undo .
define variable v-size-col10 as decimal   no-undo .
define variable v-size-col11 as decimal   no-undo .
define variable v-size-col12 as decimal   no-undo .
define variable v-size-col13 as decimal   no-undo .
define variable v-size-col14 as decimal   no-undo .
define variable v-size-col15 as decimal   no-undo .
define variable v-size-col16 as decimal   no-undo .

run uf-get in this-procedure(
     input  {&uf-ord-rc}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

  end.

if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,{&delim-par} ) no-error.
   v-size-col1  = decimal (entry ( 2 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col2  = decimal (entry ( 3 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col3  = decimal (entry ( 4 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col4  = decimal (entry ( 5 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col5  = decimal (entry ( 6 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col6  = decimal (entry ( 7 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col7  = decimal (entry ( 8, v-uf-List_  ,{&delim-par})) no-error.
   v-size-col8  = decimal (entry ( 9, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col9  = decimal (entry ( 10, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col10 = decimal (entry ( 11, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col11 = decimal (entry ( 12, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col12 = decimal (entry ( 13, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col13 = decimal (entry ( 14, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col14 = decimal (entry ( 15 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col15 = decimal (entry ( 16 , v-uf-List_ ,{&delim-par})) no-error.
   v-size-col16 = decimal (entry ( 17 , v-uf-List_ ,{&delim-par})) no-error.

   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1     = 4 .
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2     = 10 .
   if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3     = 16 .
   if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4     = 10 .
   if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5     = 6  .
   if v-size-col7  = 0 or v-size-col7  = ? then v-size-col7   = 3 .
   if v-size-col8  = 0 or v-size-col8  = ? then v-size-col8   = 8 .
   if v-size-col10 = 0 or v-size-col10 = ? then v-size-col10  = 6  .
   if v-size-col11 = 0 or v-size-col11 = ? then v-size-col11  = 6  .
   if v-size-col12 = 0 or v-size-col12 = ? then v-size-col12  = 6  .
   if v-size-col13 = 0 or v-size-col13 = ? then v-size-col13 = 10 .
   if v-size-col14 = 0 or v-size-col14 = ? then v-size-col14  = 10  .
   if v-size-col15 = 0 or v-size-col15 = ? then v-size-col15  = 10  .
   if v-size-col16 = 0 or v-size-col16 = ? then v-size-col16  = 6  .
   if v-size-col6 = 0 or v-size-col6 = ? then v-size-col6  = 10  .
   if v-size-col9 = 0 or v-size-col9 = ? then v-size-col9  = 10  .

   if v-order-col = "" or v-order-col = ? then v-order-col = "1,2,3,4,7,11,12,13,5,8,10,14,6,9,15,16".
end.




define buffer   buf_ord-doc for ub.ord-doc .
define buffer   buf_clients for ub.clients .
define variable loc-obj-code as integer no-undo .
define variable loc-obj-type as character no-undo .
define variable sort-column-name as character no-undo .

define variable v-recid-RC as recid no-undo .
define buffer cli#clients for ub.clients.

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.

DEFINE VARIABLE  v-rc-qnty AS DECIMAL NO-UNDO.
DEFINE VARIABLE  v-rc-qnty-free AS DECIMAL NO-UNDO.

define variable v-ord-askp as logical   no-undo .
define variable v-ord-obj-rc as character no-undo .

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
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 {&col-1} {&col-2} {&col-3} {&col-4} {&col-5} {&col-6} {&col-7} {&col-8} {&col-9} {&col-10} {&col-11} {&col-12} {&col-13} {&col-14} {&col-15} {&col-16}
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
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-delivery B-help B-spec r-cli ~
B-contract scr-wrkr scr-ship-date r-wrkr scr-pay-day scr-agnt r-agnt ~
scr-boss r-boss scr-e-method b-add B-chg B-del B-calc b-renum b-spec-gds ~
t-auto BROWSE-2 scr-obj-name scr-cli-name scr-contract scr-wrkr-name ~
scr-agnt-name scr-boss-name scr-sum-qnty
&Scoped-Define DISPLAYED-OBJECTS scr-cli scr-wrkr scr-ship-date scr-pay-day ~
scr-agnt scr-boss scr-e-method t-auto scr-obj-name scr-cli-name ~
scr-contract scr-wrkr-name scr-agnt-name scr-boss-name scr-sum-qnty

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
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-calc
     LABEL "&Рассчитать"
     SIZE 12 BY 1.

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

DEFINE BUTTON b-renum
     LABEL "№ п/п"
     SIZE 10 BY 1 TOOLTIP "Перенумеровать список товаров".

DEFINE BUTTON B-spec
     IMAGE-UP FILE "cmp/image3.bmp":U
     IMAGE-DOWN FILE "cmp/image3.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/image3.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 2.5 BY 1 TOOLTIP "Спецификация к договору".

DEFINE BUTTON b-spec-gds
     LABEL "Специ&фикация"
     SIZE 13.5 BY 1 TOOLTIP "Добавление товаров по спецификации".

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

DEFINE VARIABLE scr-cli AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "РЦ"
     VIEW-AS FILL-IN
     SIZE 4.13 BY 1 NO-UNDO.

DEFINE VARIABLE scr-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33.38 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-contract AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 20.5 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE scr-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "на Объект"
      VIEW-AS TEXT
     SIZE 39.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-pay-day AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "На дней продаж"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

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
      {&col-1}   COLUMN-LABEL  {&col-l1}   FORMAT ">>>>9"
      {&col-2}   COLUMN-LABEL  {&col-l2}   FORMAT ">>>>>>>>9"
      {&col-3}   COLUMN-LABEL  {&col-l3}
      {&col-4}   COLUMN-LABEL  {&col-l4}   FORMAT "X(100)"
      {&col-5}   COLUMN-LABEL  {&col-l5}   FORMAT "->>,>>>,>>9.<<<"
      {&col-6}   COLUMN-LABEL  {&col-l6}   FORMAT "->>,>>>,>>9.<<<"
      {&col-7}   COLUMN-LABEL  {&col-l7}   FORMAT "X(3)"
      {&col-8}   COLUMN-LABEL  {&col-l8}   FORMAT "->>>>>>>>9.99"
      {&col-9}   COLUMN-LABEL  {&col-l9}   FORMAT "->>,>>>,>>9.<<<"
      {&col-10}  COLUMN-LABEL  {&col-l10}  FORMAT "->>,>>>,>>9.<<<"
      {&col-11}  COLUMN-LABEL  {&col-l11}  FORMAT "x(6)"
      {&col-12}  COLUMN-LABEL  {&col-l12}  FORMAT "x(6)"
      {&col-13}  COLUMN-LABEL  {&col-l13}  FORMAT "->>,>>>,>>9.<<<"
      {&col-14}  COLUMN-LABEL  {&col-l14}  FORMAT "->>,>>>,>>9.<<<"
      {&col-15}  COLUMN-LABEL  {&col-l15}  FORMAT "->>,>>>,>>9.<<<"
      {&col-16}  COLUMN-LABEL  {&col-l16}  FORMAT "->,>>>,>>9.99"
      ENABLE
      X_ord-line.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 9.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-delivery AT ROW 1 COL 76.13
     B-help AT ROW 1 COL 86.13
     b-prev AT ROW 2 COL 1
     b-next AT ROW 2 COL 6
     B-spec AT ROW 2 COL 93.5 WIDGET-ID 2
     scr-cli AT ROW 2.04 COL 27 COLON-ALIGNED
     r-cli AT ROW 2.04 COL 33
     B-contract AT ROW 2.04 COL 90.25
     scr-wrkr AT ROW 3.17 COL 5.88 COLON-ALIGNED
     scr-ship-date AT ROW 3.17 COL 82.5 COLON-ALIGNED
     r-wrkr AT ROW 3.25 COL 18
     scr-pay-day AT ROW 4.17 COL 82.5 COLON-ALIGNED
     scr-agnt AT ROW 4.21 COL 5.75 COLON-ALIGNED
     r-agnt AT ROW 4.29 COL 17.88
     scr-boss AT ROW 5.33 COL 5.75 COLON-ALIGNED
     r-boss AT ROW 5.42 COL 17.88
     scr-e-method AT ROW 6.54 COL 1 NO-LABEL
     b-add AT ROW 12.83 COL 1
     B-chg AT ROW 12.83 COL 11
     B-del AT ROW 12.83 COL 21
     B-calc AT ROW 12.83 COL 31
     b-renum AT ROW 12.83 COL 43
     b-spec-gds AT ROW 12.83 COL 53 WIDGET-ID 4
     t-auto AT ROW 13.04 COL 88.25
     BROWSE-2 AT ROW 14 COL 1
     scr-obj-name AT ROW 1.21 COL 35.13 COLON-ALIGNED
     scr-cli-name AT ROW 2.04 COL 35.13 COLON-ALIGNED NO-LABEL
     scr-contract AT ROW 2.04 COL 68 COLON-ALIGNED NO-LABEL
     scr-wrkr-name AT ROW 3.33 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-agnt-name AT ROW 4.46 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-boss-name AT ROW 5.63 COL 19.25 COLON-ALIGNED NO-LABEL
     scr-sum-qnty AT ROW 6.29 COL 80.38 COLON-ALIGNED
     scr-sum-rubl AT ROW 7 COL 80.38 COLON-ALIGNED
     scr-sum-base AT ROW 7.79 COL 80.38 COLON-ALIGNED
     SPACE(0.24) SKIP(15.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заказ ОРЦ".


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

/* SETTINGS FOR FILL-IN scr-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN scr-sum-base IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       scr-sum-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN scr-sum-rubl IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       scr-sum-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

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
ON GO OF FRAME Dialog-Frame /* Заказ ОРЦ */
DO:

define buffer buf_ord-line for ub.ord-line.
define variable v-kol as integer init 0 no-undo .
/*---- сохранение настроек экрана ------*/
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column
    v-list        = column-handle:label + "#"
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.

   v-list = trim(v-list, "#") .
   define variable v-i as integer   no-undo .
   define variable v-pos as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem as character no-undo .

   repeat v-i = 1 to {&browse-name}:num-columns :
      v-elem = entry( v-i, v-list , "#") .
      v-pos = lookup( v-elem , {&head-col} , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.

   define variable v-list-str as character no-undo .
   define variable v-nn as integer   no-undo .
   v-nn = num-entries(v-list-new) .

   v-list-str = "" .
   repeat v-i = 1 to v-nn :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 0 then
      v-list-str  = v-list-str + v-elem + "," .
   end.

   v-list-new = trim ( v-list-str , ",")  +  {&delim-par}
              + string(decimal( {&col-1 }:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-2 }:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-3 }:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-4 }:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-5 }:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-6}:width in browse {&browse-name}    )) +  {&delim-par}
              + string(decimal( {&col-7 }:width in browse {&browse-name}   )) +  {&delim-par}
              + string(10)  +  {&delim-par}
              + string(decimal( {&col-9} :width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-10 }:width  in browse {&browse-name} )) +  {&delim-par}
              + string(8) +  {&delim-par}
              + string(8) +  {&delim-par}
              + string(decimal( {&col-13}:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-14}:width in browse {&browse-name}   )) +  {&delim-par}
              + string(decimal( {&col-15}:width in browse {&browse-name}   )) +  {&delim-par}
              + string(10) +  {&delim-par}
              .

    run uf-set in this-procedure(
        input  {&uf-ord-rc}
        ,input v-cntxt-userid
        ,input v-list-new
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    ) no-error    .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "uf-set"
          view-as alert-box error
        .
/*---- END сохранение настроек экрана END  ------*/


  if p-mode =  {&lookup} then return.

  if p-mode <> {&lookup} then do:
     assign frame {&frame-name}
     scr-ship-date
     scr-e-method
     scr-wrkr
     scr-agnt
     scr-boss
     scr-cli
     scr-pay-day
     .
     loc-date-ship = scr-ship-date.
     pay-day = scr-pay-day.

  if loc-cli-code = 0 or loc-cli-code = ? then do:
      message "Не выбран РЦ ! "
      view-as alert-box error .
      return no-apply .
  end.

  if (loc-cli-code = loc-obj-code) and (loc-cli-type = loc-obj-type) then do:
      message "Не верно выбран РЦ ! "
      view-as alert-box error .
      return no-apply .
  end.

  if not (loc-cli-type = {&shop}  or loc-cli-type = {&stock} ) then do:
      message "РЦ  должен быть объектом ! "
      view-as alert-box error .
      return no-apply .
  end.

define variable o-host-code as integer   no-undo .
define variable c-host-code as integer   no-undo .
define variable o-base-code as integer   no-undo .
define variable c-base-code as integer   no-undo .

{ gbl/hostcode.i loc-obj-type loc-obj-code o-host-code }
{ gbl/hostcode.i loc-cli-type loc-cli-code c-host-code }
{ gbl/basecode.i o-host-code o-base-code }
{ gbl/basecode.i c-host-code c-base-code }

if o-base-code <> c-base-code then do:
  message "Контрагенты имеют разную базовую валюту. Создание заказа не возможно ! " view-as alert-box error .
  return .
end.



      if can-find ( first buf_ord-line  no-lock    where
                          buf_ord-line.doc-code = loc-ord-num  and
                          buf_ord-line.qnty  =  0 ) then do:
          find first buf-or_ord-doc exclusive-lock where recid(buf-or_ord-doc) = p-ord-doc-recid  no-error.
          if buf-or_ord-doc.status_ = {&g___new} then do:
              message "В заказе есть нерассчитанные строки . Удаляем их ? " view-as alert-box question  buttons yes-no update g#log.
              if g#log then do:
                    for each buf_ord-line  exclusive-lock
                            where buf_ord-line.qnty = 0      and
                            buf_ord-line.doc-code = loc-ord-num
                            :
                            delete buf_ord-line .
                    end. /* foreach*/
              end.
          end.
          else do:
            message "В заказе есть строки с нулевым количеством ! " view-as alert-box information .
          end.
      end.

   /* услуги */
   define variable v-del as integer   no-undo .
   v-del = 0 .
     for each  buf_ord-line  exclusive-lock    where
               buf_ord-line.doc-code = loc-ord-num :
            find first ub.goods WHERE ub.goods.artic = buf_ord-line.artic   AND
                                      ub.goods.prod-code = buf_ord-line.prod-code   AND
                                      ub.goods.prod-type = buf_ord-line.prod-type NO-LOCK.
              if ub.goods.gds-type =  {&gds-office}  then do:
                  delete buf_ord-line .
                  v-del = v-del + 1.
              end.
     end.
     if v-del > 0  then message "Удалено " v-del  " услуг"  view-as alert-box information .

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
                find first buf-or_ord-doc exclusive-lock where recid(buf-or_ord-doc) = p-ord-doc-recid  no-error.
                if available buf-or_ord-doc then
                delete buf-or_ord-doc.
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
    buf_ord-doc.ship-date = scr-ship-date
    buf_ord-doc.wrkr   = scr-wrkr
    buf_ord-doc.boss   = scr-boss
    buf_ord-doc.agnt   = scr-agnt
    buf_ord-doc.cli-code = loc-cli-code
    buf_ord-doc.cli-type = loc-cli-type
    buf_ord-doc.status_     = (if buf_ord-doc.status_ = {&ord-req} then {&ord-req} else  {&g___new})
    buf_ord-doc.cli-name = scr-cli-name
    buf_ord-doc.pay-day  = scr-pay-day
    buf_ord-doc.contract-code  = loc-contract
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
      message "Закрываем заказ до статуса ЗАПРОС+ и отправляем по новостям ? " view-as alert-box question
            buttons yes-no title "Вопрос" update t-log-4 as logical.
            if t-log-4 = true then do:
              run cus/ordorcls.p ( parparentproc, recid(buf_ord-doc) , true   ) no-error .
              if error-status :error then do:
                 if return-value begins 'izt' then do:
                    message "Товары не прошедшие по Ассортиментной политике удаляются из заказа и прописываются в примечании"
                    return-value
                    view-as alert-box information .
                 end.
                 else do:
                 message
                   error-status :get-message(1) skip
                   return-value skip
                   "Ошибка при закрытии заказа"
                   view-as alert-box error
                 .
                 end.
                 return  .
              end.
            end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заказ ОРЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure .
  run recalc-head in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-calc Dialog-Frame
ON CHOOSE OF B-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:
define buffer buf_ord-line for ub.ord-line.
define buffer buf_goods for ub.goods.
assign frame {&frame-name} scr-ship-date scr-pay-day .
loc-date-ship = scr-ship-date .
if loc-date-ship < today then do:
   message "Для расчета заказа ДАТА ЗАКАЗА должна быть больше текущей " view-as alert-box information .
   return no-apply.
end.
pay-day = scr-pay-day.
if pay-day = ? or pay-day = 0 then
    message  "ПРЕДУПРЕЖДЕНИЕ :  Не задано количество дней продаж !"
    view-as alert-box information
    title "Внимание!!!".

for each tmp#zakaz :
    delete tmp#zakaz  .
end.

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

if pay-day = 0 or pay-day = ? then pay-day = 1 .
loc-store-code = v-cntxt-obj-code .
loc-store-type = v-cntxt-obj-type .
loc-doc-type   = {&O-R}     .

run cus/ord-m.w ( input parParentProc , input ? , {&o-r} ) .
scr-e-method = e-method .
display scr-e-method with frame {&frame-name} .

run openbr in this-procedure .
run recalc-head in this-procedure .

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

  if p-mode =  {&lookup} then return.

 find current x_ord-line  exclusive-lock  no-error .
 if available x_ord-line then do:

     r-recid =  recid ( x_ord-line )  .
     run cus/ord-frmo.w
       ( input parParentProc ,
         input ?         ,
         input r-recid   ,
         input {&update} ,
         output r-stop   ,
         output r-exit
         ) .
     g#log =  {&BROWSE-NAME}:refresh() .
 end.
    run recalc-head in this-procedure  .
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
    run x-delete in this-procedure ( recid(x_ord-line) , input-output v-ii ) no-error .
    if error-status :error then
    message vss-workfile vss-revision vss-description skip
           "Ошибка удаление 1 " skip
            skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error
    .
    run openbr in this-procedure .
 end.
    run recalc-head in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delivery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delivery Dialog-Frame
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame /* Доставка */
DO:
  run cus/pardeliv.w
      (input        parParentproc
      ,input        p-mode
      ,input        "ord" + {&o-r}
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


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
run step-next in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
   run step-prev in this-procedure .
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
        find first buf-or_ord-doc exclusive-lock where recid(buf-or_ord-doc) = p-ord-doc-recid  no-error.
        if available buf-or_ord-doc then
        delete buf-or_ord-doc.
      end.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-renum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-renum Dialog-Frame
ON CHOOSE OF b-renum IN FRAME Dialog-Frame /* № п/п */
DO:
run proc-renum in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-spec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-spec Dialog-Frame
ON CHOOSE OF B-spec IN FRAME Dialog-Frame
DO:
define variable o-host-code as integer   no-undo .
define variable v-rid-list as char no-undo.
{ gbl/hostcode.i loc-obj-type loc-obj-code o-host-code }

define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = loc-contract and
                                     b_contract.host-code         = o-host-code
                                     no-error .
if error-status :error then return no-apply.

  run str/contspec.w (
      input  parparentproc,
      input  "b-mark,b-add,b-del,b-chg",
      input  p-mode,
      input  o-host-code,
      input  loc-contract,
      output v-rid-list) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spec-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spec-gds Dialog-Frame
ON CHOOSE OF b-spec-gds IN FRAME Dialog-Frame /* Спецификация */
DO:
  run add-spec-gds  in this-procedure .
  run recalc-head in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
DO:

define buffer buf_prt-obj for ub.prt-obj .
define variable p-node as integer   no-undo .

 { gbl/rootnode.i
    x_ord-line.artic
    x_ord-line.prod-type
    x_ord-line.prod-code
    p-node
 }
  find first buf_prt-obj no-lock where
            buf_prt-obj.prt-code  = p-node and
            buf_prt-obj.artic     = x_ord-line.artic     and
            buf_prt-obj.prod-type = x_ord-line.prod-type and
            buf_prt-obj.prod-code = x_ord-line.prod-code and
            buf_prt-obj.obj-type  = loc-cli-type and
            buf_prt-obj.obj-code  = loc-cli-code
            no-error .
   if available buf_prt-obj
      then
         assign
            v-rc-qnty = buf_prt-obj.fact-qnty
            v-rc-qnty-free = buf_prt-obj.free-qnty
         .

      else
         assign
            v-rc-qnty = 0
            v-rc-qnty-free = 0
         .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  apply "CHOOSE" to B-chg .
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
         {&shop},
         ?,
         ?,
         ?,
         ?,
         ?,
         output  rid-list) no-error .
         if error-status :error or
         rid-list = "" or rid-list = ?
         then return no-apply .

    assign
      v-recid-RC = integer(rid-list)
      .
    find first cli#clients no-lock WHERE recid(cli#clients) = v-recid-RC  No-ERROR.
    if avail cli#clients then do:
          run ver-clients  (cli#clients.obj-type , cli#clients.obj-code , output g#log) .
          if g#log then return no-apply.

        Assign
            scr-cli = cli#clients.obj-code
            loc-cli-code = cli#clients.obj-code
            loc-cli-type = cli#clients.obj-type
            scr-cli-name = cli#clients.obj-name
            .
     end.
        else
          assign
              scr-cli-name = ""
              scr-cli      = ?
              loc-cli-code = ?
              loc-cli-type = ""
              .

display scr-cli scr-cli-name with frame {&frame-name} .

 run p-cont .

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
ON return OF scr-cli IN FRAME Dialog-Frame /* РЦ */
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
.
{ gbl/brwrepos.i
  &line-num=8
}
{ gbl/ed_date.i scr-ship-date}
{ gbl/app_help.i }
{ gbl/srt-clmn.i
&browse-name   = "{&browse-name}"
&frame-name    = "{&frame-name}"
&table-name    = "X_ord-line"
&label-clmn_1  = "{&col-l1}"
&label-clmn_2  = "{&col-l2}"
&label-clmn_3  = "{&col-l3}"
&label-clmn_4  = "{&col-l4}"
&label-clmn_5  = "{&col-l5}"
&label-clmn_6  = "{&col-l6}"
&label-clmn_7  = "{&col-l7}"
&label-clmn_8  = "{&col-l8}"
&label-clmn_9  = "{&col-l9}"
&label-clmn_10 = "{&col-l10}"
&label-clmn_11 = "{&col-l11}"
&label-clmn_12 = "{&col-l12}"
&label-clmn_13 = "{&col-l13}"
&label-clmn_14 = "{&col-l14}"
&label-clmn_15 = "{&col-l15}"
&label-clmn_16 = "{&col-l16}"
&sort-clmn_1   =  "{&col-1}"
&sort-clmn_2   =  "{&col-2}"
&sort-clmn_3   =  "{&col-3}"
&sort-clmn_4   =  "{&col-4}"
&sort-clmn_5   =  "{&col-5}"
&sort-clmn_6   =  "{&col-6}"
&sort-clmn_7   =  "{&col-7}"
&sort-clmn_8   =  "{&col-8}"
&sort-clmn_9   =  "{&col-9}"
&sort-clmn_10  =  "{&col-10}"
&sort-clmn_11  =  "{&col-11}"
&sort-clmn_12  =  "{&col-12}"
&sort-clmn_13  =  "{&col-13}"
&sort-clmn_14  =  "{&col-14}"
&sort-clmn_15  =  "{&col-15}"
&sort-clmn_16  =  "{&col-16}"
&open-query    = "Run OpenBr."
&open-query-otherwise = "Run OpenBr."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes"
}

{&col-1 }:resizable in browse {&browse-name}   = true .
{&col-2 }:resizable in browse {&browse-name}   = true .
{&col-3 }:resizable in browse {&browse-name}   = true .
{&col-4 }:resizable in browse {&browse-name}   = true .
{&col-5 }:resizable in browse {&browse-name}   = true .
{&col-7 }:resizable in browse {&browse-name}   = true .
{&col-6 }:resizable in browse {&browse-name}   = true .
{&col-9 }:resizable in browse {&browse-name}   = true .
{&col-10}:resizable in browse {&browse-name}   = true .
{&col-13}:resizable in browse {&browse-name}   = true .
{&col-14}:resizable in browse {&browse-name}   = true .
{&col-15}:resizable in browse {&browse-name}   = true .

{&col-1 }:width     in browse {&browse-name}   = v-size-col1 .
{&col-2 }:width     in browse {&browse-name}   = v-size-col2 .
{&col-3 }:width     in browse {&browse-name}   = v-size-col3 .
{&col-4 }:width     in browse {&browse-name}   = v-size-col4 .
{&col-5 }:width     in browse {&browse-name}   = v-size-col5 .
{&col-7 }:width     in browse {&browse-name}   = v-size-col7 .
{&col-10}:width     in browse {&browse-name}   = v-size-col10.
{&col-13}:width     in browse {&browse-name}   = v-size-col13.
{&col-14}:width     in browse {&browse-name}   = v-size-col14.
{&col-15}:width     in browse {&browse-name}   = v-size-col15.
{&col-6}:width      in browse {&browse-name}   = v-size-col6.
{&col-9}:width      in browse {&browse-name}   = v-size-col9.




{ gbl/f2.i browse-2 goods-recid init-gds-rec parparentproc }
{ cus/ord-trgo.i boss }
{ cus/ord-trgo.i agnt }
{ cus/ord-trgo.i wrkr }


on end-error, stop of frame {&frame-name}  do:
  apply "choose" to b-exit in frame {&frame-name} .
  return no-apply.
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable loc-order-type as integer no-undo .
define variable v-i-doc as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-int as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable par-type as character no-undo .
define buffer bufc_clients for ub.clients  .

  if p-mode <> {&lookup} then do:

  empty temp-table thbjattr_thbj-attr .
    run adm/shattri.p (
     input "get":U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input {&attr-ord-obj}
    ,input ""
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-int
    ,output v-value-logical
    ,output par-type
    ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) no-error .
    for each thbjattr_thbj-attr :
       if thbjattr_thbj-attr.prop-code = "ord-askp"    then v-ord-askp    =  thbjattr_thbj-attr.property-value-logical.
       if thbjattr_thbj-attr.prop-code = "ord-obj-rc"  then v-ord-obj-rc  =  thbjattr_thbj-attr.property-value-character.
    end.

    if p-mode  = {&add-def} then do:
      { cus/ord-code.i
          'main'
          v-cntxt-db-num
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-i-doc
          loc-ord-num
          }
      if ( loc-cli-code = 0  or loc-cli-code = ? ) and v-ord-obj-rc <> ""  then  do:
          assign
          loc-cli-type = substring(v-ord-obj-rc,1,3)
          loc-cli-code = int(substring(v-ord-obj-rc,4,10))
          no-error
          .
          if not error-status :error then DO:
           find first bufc_clients no-lock where
                      bufc_clients.obj-code = loc-cli-code and
                      bufc_clients.obj-type = loc-cli-type no-error .
           if available bufc_clients then do:
           scr-cli-name = bufc_clients.obj-name .
           scr-cli = loc-cli-code               .
           end.

          display
            scr-cli
            scr-cli-name
            with frame {&frame-name} .
            loc-obj-type = v-cntxt-obj-type .
            loc-obj-code = v-cntxt-obj-code .
            run p-cont .
          END.
      end.

      run create-ord-doc in this-procedure (
          input loc-ord-num  ,
          input loc-cli-code ,
          input loc-cli-type ,
          input ""           ,
          input ""           ,
          input v-cntxt-host-code-obj ,
          input v-cntxt-obj-code      ,
          input v-cntxt-obj-type      ,
          input {&O-R}       ,
          input {&g___new}   ,
          input today        ,
          input today        ,
          input  loc-order-type ,
          input  loc-contract ,
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
  end.

/**/
{ gbl/mv-clmn.i
 &ext-col = 16
 &start-column = 1
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
 &prev-order-column_1 = v-order-col
 &prev-order-column-condition_1 = " true = true  "
}

if  ( (buf_ord-doc.status_ = {&g___new} ) or
    (  buf_ord-doc.status_ = {&ord-req} and buf_ord-doc.flag_ = false )) then do:
       {&col-9} :visible  in browse {&browse-name}    =  false .
end.
else do:
   {&col-9} :visible  in browse {&browse-name}    =  true  .
end.


if p-mode  = {&add-def} then {&col-9} :visible  in browse {&browse-name}    =  false .

/* для корректировки в статусе ЗАПР */
if buf_ord-doc.status_ = {&ord-req} then
  disable b-add b-calc b-del r-cli
          scr-ship-date scr-pay-day
          scr-wrkr  r-wrkr
          scr-agnt  r-agnt
          scr-boss  r-boss
  with frame {&frame-name} .



if p-mode <> {&lookup}  then do:
  if p-mode  = {&add-def}
  then
       wait-for go  of frame {&frame-name} focus  scr-ship-date.
  else
      wait-for go  of frame {&frame-name} focus browse-2.
end.
else do:
      wait-for go  of frame {&frame-name} focus b-exit.
end.

END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-spec-gds Dialog-Frame
PROCEDURE add-spec-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer   no-undo .
define variable v-i as integer   no-undo .
define variable t-ret as logical   no-undo .
define variable r-tmp as recid no-undo .
define variable r-ord as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-choice as integer   no-undo .

define buffer buf_ord-line for ub.ord-line  .
define buffer bf_contract-specif for ub.contract-specif  .

  do
  on error undo, return error return-value
  :

if loc-contract = 0 or loc-contract = ? then return .
/*
find first bf_contract-specif where bf_contract-specif.host-code    = v-cntxt-host-code-obj and
                                    bf_contract-specif.contract-num = loc-contract no-lock no-error.
*/

{str/cont-slave-inc.i
    &FIND_FIRST = YES
    &BUFFER_SPECIF  = bf_contract-specif
    &P_HOST_CODE    = v-cntxt-host-code-obj
    &P_CONTRACT_NUM = loc-contract
    &NO_LOCK=YES
    &NO_ERROR=YES
}

if not available bf_contract-specif then return .

      run gbl/d-askw.w
        (input "Данные из спецификации"
        ,input "Выберите один из пунктов для добавления в заказ" + {&new-line}
             + "товаров по спецификации к договору" + {&new-line}
        ,input "|"
        ,input "Все|Выборочно|Обновить|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Обновить цены из спецификации|"
             + "Отказ от выполнения операции"
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 4 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).
      if v-choice = 4 then do:
        return.
      end.


t-ret =  session:set-wait-state("general") .
ii = 0.
case v-choice :
when 1 then do:
   line-mode = {&add-def} .

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
       find first  buf_ord-line  exclusive-lock      where
                buf_ord-line.gds-code = ub.contract-specif.gds-code  and
                buf_ord-line.doc-code = loc-ord-num
                no-error .
          if available buf_ord-line then do:
             run cus/ord-frmo.w (parParentProc , input ?  , input recid ( buf_ord-line)  , input {&update},  output r-stop , output r-exit ) no-error .
          end.
          else do:
              ii = ii + 1 .
              run create-tmp-contr-sp in this-procedure  ( input (recid(ub.contract-specif)) , output r-tmp , output r-ord).
              if not t-auto then do:
                    run cus/ord-frmo.w
                      ( input parParentProc ,
                        input r-tmp  ,
                        input r-ord  ,
                        input line-mode,
                        output r-stop ,
                        output r-exit ) .
                      if r-stop then do:
                          run p-delete in this-procedure
                            ( r-tmp , input-output ii).
                          leave.
                      end.
                      if r-exit then do:
                          run p-delete in this-procedure
                              ( r-tmp , input-output ii ) .
                      end.
              end.
          end.
   end.
end.
when 2 then do:
   run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input {&lookup},
                      input v-cntxt-host-code-obj,
                      input loc-contract,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.

    /* Формируем список recid'ов товаров по выбранным строкам спецификации */
    line-mode = {&add-def} .
    do v-i = 1 to num-entries(v-rid-list) :
     find ub.contract-specif where recid(ub.contract-specif) = integer(entry(v-i, v-rid-list)) no-lock no-error.
     if error-status :error then next.
     ii = ii + 1 .
     run create-tmp-contr-sp in this-procedure  (input recid(ub.contract-specif), output r-tmp , output r-ord).
        find first tmp#zakaz where
                   tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
        if not  error-status :error  and not t-auto then do:
            r-tmp = recid ( tmp#zakaz   ) .
            run cus/ord-frmo.w
              ( input parParentProc ,
                input r-tmp  ,
                input r-ord  ,
                input line-mode,
                output r-stop ,
                output r-exit ) .

            if r-stop then do:
              run p-delete ( r-tmp , input-output ii).
              leave.
            end.
            if r-exit then do:
               run p-delete( r-tmp ,input-output ii ) .
            end.
        end.
   end.
end.
when 3 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
/*
   find first  ub.contract-specif no-lock where
               ub.contract-specif.contract-num = loc-contract and
               ub.contract-specif.host-code    = v-cntxt-host-code-obj and
               ub.contract-specif.gds-code     = tmp#zakaz.gds-code
               no-error .
*/
   {str/cont-slave-inc.i
        &FIND_FIRST = YES
        &BUFFER_SPECIF  = ub.contract-specif
        &P_HOST_CODE    = v-cntxt-host-code-obj
        &P_CONTRACT_NUM = loc-contract
        &P_GDS_CODE     = tmp#zakaz.gds-code
        &NO_LOCK=YES
        &NO_ERROR=YES
   }
   if not available ub.contract-specif then next .
     ii = ii + 1 .
     run create-tmp-contr-sp in this-procedure  ( input recid(ub.contract-specif) , output r-tmp , output r-ord).
   end.
end.
end case.
choice = ?.
run openbr in this-procedure  .
t-ret =  session:set-wait-state("") .
message
( if v-choice = 3
  then substitute("Исправлено  &1 из " ,v-update-price )
  else  'Добавлено'  )
  ii 'товаров'
  view-as alert-box information
  .
  ii = 0.
  v-update-price = 0 .
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
define input parameter p-contract-code like  ub.ord-doc.contract-code    no-undo .

define output parameter p-recid as recid no-undo .

define variable v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
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
      ub.ord-doc.contract-code = p-contract-code

      p-recid = recid (ub.ord-doc)

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

define input parameter tt     as char no-undo.
define input parameter t      as char no-undo.
define output parameter p-tmp as recid no-undo .
define output parameter p-ord as recid no-undo .

define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .

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
           tmp#zakaz.prod-type = ub.goods.prod-type and
           tmp#zakaz.prod-code = ub.goods.prod-code and
           tmp#zakaz.artic     = ub.goods.artic     no-error.

 if not available tmp#zakaz  then  create tmp#zakaz .

  assign
    tmp#zakaz.doc-code      = loc-ord-num
    tmp#zakaz.gds-code      = ub.goods.gds-code
    tmp#zakaz.prod-type     = ub.goods.prod-type
    tmp#zakaz.prod-code     = ub.goods.prod-code
    tmp#zakaz.artic         = ub.goods.artic
    tmp#zakaz.gds-name      = ub.goods.gds-name
    tmp#zakaz.deadline      = ub.goods.deadline
    tmp#zakaz.unit-cli      = ub.goods.unit-cli
    tmp#zakaz.unit-base     = ub.goods.unit-base
    tmp#zakaz.negative-rest = ub.goods.negative-rest
    tmp#zakaz.cli-base-rate = 1
    tmp#zakaz.cli-qnty = 1
    tmp#zakaz.qnty = 1
    tmp#zakaz.ms-cart       = ub.goods.qnty-cart
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



define variable v1-host-code as integer   no-undo .
define variable v1-obj-type as character no-undo .
define variable v1-obj-code as integer   no-undo .

if flag = false  then do:
    if v-ord-askp then
        message
          substitute ( "Цена берется с объекта РЦ &1&2 ? " , loc-cli-type , loc-cli-code )
          view-as alert-box question
          buttons yes-no
          update v-quest
          .
    else
      v-quest = false .

     flag = true .
end.

if v-quest then do:
    find first ub.gds-obj no-lock    where
        ub.gds-obj.obj-type   = loc-cli-type and
        ub.gds-obj.obj-code   = loc-cli-code and
        ub.gds-obj.prod-type  = ub.goods.prod-type and
        ub.gds-obj.prod-code  = ub.goods.prod-code and
        ub.gds-obj.artic      = ub.goods.artic
        no-error.
    if error-status :error then do:
      message  substitute( "Неизвестна ИНФОРМАЦИЯ по товару &4 &1 по объекту &2&3 берем с текущего", ub.goods.gds-name, loc-cli-type, loc-cli-code , ub.goods.artic )   view-as alert-box information .
      v1-obj-type = v-cntxt-obj-type.
      v1-obj-code = v-cntxt-obj-code.
    end.
    ELSE DO:
      v1-obj-type = loc-cli-type.
      v1-obj-code = loc-cli-code.
    END.
end.
else do:
  v1-obj-type = v-cntxt-obj-type.
  v1-obj-code = v-cntxt-obj-code.
end.

{ gbl/hostcode.i
  v1-obj-type
  v1-obj-code
  v1-host-code
}

find first ub.gds-obj no-lock    where
    ub.gds-obj.obj-type        = v1-obj-type and
    ub.gds-obj.obj-code        = v1-obj-code and
    ub.gds-obj.prod-type       = ub.goods.prod-type and
    ub.gds-obj.prod-code       = ub.goods.prod-code and
    ub.gds-obj.artic           = ub.goods.artic
    no-error.
    if available ub.gds-obj then do:
        define variable v-baz-val     as integer no-undo .
        define variable v-base-rate   as decimal no-undo .
        define variable v-base-scale  as decimal no-undo .
        define variable p-r-b-abbr    as character no-undo .
        { gbl/basecode.i v1-host-code v-baz-val}
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
                    v1-host-code
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
                    v1-host-code
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
  DISPLAY scr-cli scr-wrkr scr-ship-date scr-pay-day scr-agnt scr-boss
          scr-e-method t-auto scr-obj-name scr-cli-name scr-contract
          scr-wrkr-name scr-agnt-name scr-boss-name scr-sum-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-delivery B-help B-spec r-cli B-contract scr-wrkr
         scr-ship-date r-wrkr scr-pay-day scr-agnt r-agnt scr-boss r-boss
         scr-e-method b-add B-chg B-del B-calc b-renum t-auto BROWSE-2
         scr-obj-name scr-cli-name scr-contract scr-wrkr-name scr-agnt-name
         scr-boss-name scr-sum-qnty
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
define buffer buf_2clients for ub.clients  .
 find first buf_2clients no-lock where
            buf_2clients.obj-code = buf_ord-doc.cli-code and
            buf_2clients.obj-type = buf_ord-doc.cli-type
            no-error .

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
  loc-contract     = buf_ord-doc.contract-code
  v-deliv-type-code     =  buf_ord-doc.deliv-type-code
  v-point-obj-code      =  buf_ord-doc.obj-point-code
  v-point-cli-code      =  buf_ord-doc.cli-point-code
  v-point-obj-db-num    =  buf_ord-doc.obj-point-db-num
  v-point-cli-db-num    =  buf_ord-doc.cli-point-db-num
  v-transport-host-code =  buf_ord-doc.transport-host-code
  v-transport-cli-type  =  buf_ord-doc.transport-cli-type
  v-transport-cli-code  =  buf_ord-doc.transport-cli-code
  v-transport-contract  =  buf_ord-doc.transport-contract
  v-transport-condition =  buf_ord-doc.transport-condition
  v-transport-value     =  buf_ord-doc.transport-value
  v-transport-sum       =  buf_ord-doc.sum-ship
  v-transport-vat       =  buf_ord-doc.transport-vat

  scr-contract     = if loc-contract = 0 then "" else  "Вн.№ дог. " + string(buf_ord-doc.contract-code)
  scr-ship-date    = buf_ord-doc.ship-date
  scr-pay-day      = buf_ord-doc.pay-day
  pay-day          = buf_ord-doc.pay-day
  loc-date-ship    = scr-ship-date
  scr-e-method     = buf_ord-doc.e-method
  e-method         = buf_ord-doc.e-method
  loc-obj-code     = buf_ord-doc.obj-code
  loc-obj-type     = buf_ord-doc.obj-type
  loc-cli-code     = buf_ord-doc.cli-code
  loc-cli-type     = buf_ord-doc.cli-type
  loc-doc-type     = buf_ord-doc.doc-type
  scr-obj-name     = buf_clients.obj-name
  loc-ord-num      = buf_ord-doc.doc-code
  scr-wrkr         = buf_ord-doc.wrkr
  scr-boss         = buf_ord-doc.boss
  scr-agnt         = buf_ord-doc.agnt
  scr-cli          = buf_ord-doc.cli-code
  scr-cli-name     = if available buf_2clients then buf_2clients.obj-name else ""
 .
 run leave-proc-wrkr in this-procedure .
 run leave-proc-boss in this-procedure .
 run leave-proc-agnt in this-procedure .

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
  run init-proc in this-procedure .
  X_ord-line.qnty:read-only in browse {&browse-name}  = true .
  DISPLAY scr-ship-date scr-obj-name
          scr-e-method scr-sum-qnty
          scr-cli-name
          scr-cli
          scr-pay-day
          scr-contract
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-next b-prev B-delivery b-contract B-help BROWSE-2 scr-e-method
       b-spec
       WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
      hide  b-quit in FRAME Dialog-Frame.
      b-exit:label = "&Выход" .
  run openbr in this-procedure .


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
  run init-proc in this-procedure .
  display scr-ship-date scr-obj-name
          scr-e-method
          scr-sum-qnty
          scr-wrkr-name
          scr-agnt-name
          scr-boss-name
          scr-cli-name
          t-auto
          scr-cli
          scr-pay-day
          scr-contract
          with frame dialog-frame.
  enable b-exit b-quit b-help
      B-delivery b-contract
         b-spec
         scr-ship-date b-add b-chg b-del
         b-calc browse-2 b-renum t-auto
         scr-e-method
         scr-wrkr r-wrkr
         scr-agnt r-agnt
         scr-boss r-boss
         r-cli
         scr-pay-day
         b-spec-gds
         with frame dialog-frame.
  view frame dialog-frame.
  run openbr in this-procedure .
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
  if scr-ship-date :handle = p-widget-handle then do:  if  scr-wrkr  :sensitive then do: apply "entry":u to scr-wrkr       . return . end. end.
  if scr-wrkr      :handle = p-widget-handle then do:  if  scr-agnt  :sensitive then do: apply "entry":u to scr-agnt       . return . end. end.
  if scr-agnt      :handle = p-widget-handle then do:  if  scr-boss  :sensitive then do: apply "entry":u to scr-boss       . return . end. end.
  if scr-boss      :handle = p-widget-handle then do:  if  b-add     :sensitive then do: apply "entry":u to b-add          . return . end. end.
  if b-add         :handle = p-widget-handle then do:  if  B-exit    :sensitive then do: apply "entry":u to B-exit    .      return . end. end.
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
  when "{&col-7}" then do:
    &scop s-pole {&col-7}
    {&OPEN-QUERY}
  end.
  when "{&col-8}" then do:
    &scop s-pole {&col-8}
    {&OPEN-QUERY}
  end.
  when "{&col-10}" then do:
    &scop s-pole {&col-10}
    {&OPEN-QUERY}
  end.
  when "{&col-11}" then do:
    &scop s-pole {&col-11}
    {&OPEN-QUERY}
  end.
  when "{&col-12}" then do:
    &scop s-pole {&col-12}
    {&OPEN-QUERY}
  end.
  when "{&col-13}" then do:
    &scop s-pole {&col-13}
    {&OPEN-QUERY}
  end.
  when "{&col-14}" then do:
    &scop s-pole {&col-14}
    {&OPEN-QUERY}
  end.
  when "{&col-15}" then do:
    &scop s-pole {&col-15}
    {&OPEN-QUERY}
  end.
  when "{&col-16}" then do:
    &scop s-pole {&col-16}
    {&OPEN-QUERY}
  end.

  when "{&col-6}" then do:
    &scop s-pole {&col-6}
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-cont Dialog-Frame
PROCEDURE p-cont :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable o-host-code as integer   no-undo .
define variable c-host-code as integer   no-undo .

{ gbl/hostcode.i loc-obj-type loc-obj-code o-host-code }
{ gbl/hostcode.i loc-cli-type loc-cli-code c-host-code }

   if o-host-code <> c-host-code  then do:
    run check-contract-code in this-procedure
     (input  "choose":u,
      input  o-host-code,
      input  {&cmp},
      input  c-host-code,
      input  ?,
      input  parparentproc,
      input  doc-date ,
      input  {&income} ,
      output loc-contract) no-error.
      if error-status :error then
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка проверки договора"
            view-as alert-box error
          .
   end.
   else do:
     loc-contract = 0 .
   end.

  scr-contract = "".
  if loc-contract <> 0 then do:
     find first buf_contract no-lock where
                buf_contract.contract-code = loc-contract and
                buf_contract.host-code = o-host-code  no-error .

     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "не найден договор" skip
       "№договора "  loc-contract        skip
       "фирма " o-host-code         skip
       view-as alert-box error
     .


     scr-contract = "Вн.№ дог. " + string(loc-contract).
     assign
        v-transport-cli-code     =  buf_contract.transport-cli-code
        v-transport-cli-type     =  buf_contract.transport-cli-type
        v-transport-host-code    =  buf_contract.transport-host
        v-transport-contract     =  buf_contract.transport-contract
        v-transport-condition    =  buf_contract.transport-uslov
        v-transport-value        =  buf_contract.transport-value
        .
  end.

  display scr-contract with frame {&frame-name} .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
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
    run str/chsgdsls.w
       (
        input parparentproc,
        input "order" + {&O-R} ,
        input "Строка документа № " + loc-ord-num ,
        input ? ,
        input ? ,
        input v-cntxt-host-code-obj,
        input-output varschartic,
        output v-ref-list,
        output table tt-gds-list ,
        input false) no-error.

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
              run cus/ord-frmp.w
                 (input parParentProc ,
                  input ?  ,
                  input recid ( buf_ord-line)  ,
                  input {&update},
                  output r-stop ,
                  output r-exit )
                  no-error .
          end.
          else do:
              run create-tmp in this-procedure  (input "tt-gds-list":u, "" , output r-tmp , output r-ord).
              if not t-auto then do:
                    run cus/ord-frmo.w
                      ( input parParentProc ,
                        input r-tmp  ,
                        input r-ord  ,
                        input line-mode,
                        output r-stop ,
                        output r-exit ) .
                      if r-stop then do:
                          run p-delete in this-procedure
                            ( r-tmp , input-output ii).
                          leave.
                          end.
                      if r-exit then do:
                          run p-delete in this-procedure
                              ( r-tmp , input-output ii ) .
                          end.
              end.
          end.
   end.
  run openbr in this-procedure .
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
    run openbr in this-procedure .
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
  g#log = br-handle:select-next-row () no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
     end.

  if not g#log then message "Это последний документ списка.".
end.

    p-ord-doc-recid = recid ( buf-or_ord-doc ).
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
  g#log = br-handle:select-prev-row() no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
  end.
  if not g#log then do: message "Это первый документ списка.".   end.
end.
p-ord-doc-recid = recid (buf-or_ord-doc).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-contr-sp Dialog-Frame
PROCEDURE create-tmp-contr-sp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-recid as recid no-undo .
define output parameter p-tmp as recid no-undo .
define output parameter p-ord as recid no-undo .

define buffer buf_contract-specif for ub.contract-specif  .
define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .

define variable v-base-rate   as decimal no-undo .
define variable v-base-scale  as decimal no-undo .

define buffer ll-buf_ord-line for ub.ord-line .

 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 find first buf_contract-specif no-lock where
            recid(buf_contract-specif)  = p-recid no-error .
            if error-status :error then return error return-value .

find first ub.goods where
      ub.goods.gds-code  = buf_contract-specif.gds-code
      no-lock no-error.
      if error-status :error  then return error return-value .


define buffer bufff-units for ub.units.
define variable t-type as character no-undo .

find first tmp#zakaz   where
           tmp#zakaz.prod-type = ub.goods.prod-type and
           tmp#zakaz.prod-code = ub.goods.prod-code and
           tmp#zakaz.artic     = ub.goods.artic     no-error.

 if not available tmp#zakaz  then  create tmp#zakaz .

  { gbl/baserate.i
    v-cntxt-host-code-obj
    today
    v-base-rate
    v-base-scale
  }


  assign
    tmp#zakaz.doc-code      = loc-ord-num
    tmp#zakaz.gds-code      = ub.goods.gds-code
    tmp#zakaz.prod-type     = ub.goods.prod-type
    tmp#zakaz.prod-code     = ub.goods.prod-code
    tmp#zakaz.artic         = ub.goods.artic
    tmp#zakaz.gds-name      = ub.goods.gds-name
    tmp#zakaz.deadline      = ub.goods.deadline
    tmp#zakaz.unit-cli      = buf_contract-specif.unit-base
    tmp#zakaz.unit-base     = ub.goods.unit-base
    tmp#zakaz.negative-rest = ub.goods.negative-rest
    tmp#zakaz.cli-base-rate = ( if buf_contract-specif.cli-base-rate = 0 or buf_contract-specif.cli-base-rate = ? then 1 else buf_contract-specif.cli-base-rate)
    tmp#zakaz.ms-cart       = ub.goods.qnty-cart
    tmp#zakaz.vat-pc        = buf_contract-specif.vat-pc
    tmp#zakaz.price-cli     = buf_contract-specif.price-cli
    tmp#zakaz.price-rubl    = buf_contract-specif.price-cli / tmp#zakaz.cli-base-rate
    tmp#zakaz.price-base    = tmp#zakaz.price-rubl * v-base-rate / v-base-scale
    tmp#zakaz.cli-qnty      = ( if buf_contract-specif.qnty = 0 or buf_contract-specif.qnty = ? then 1 else buf_contract-specif.qnty)
    tmp#zakaz.qnty          = tmp#zakaz.cli-qnty * tmp#zakaz.cli-base-rate
    .

    define variable max-num as integer no-undo .
    max-num = 0.
    for each  ll-buf_ord-line no-lock  where ll-buf_ord-line.doc-code = loc-ord-num :
        if max-num < ll-buf_ord-line.line-num then
           max-num = ll-buf_ord-line.line-num .
    end.

    tmp#zakaz.line-num = max-num + 1.


  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .



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