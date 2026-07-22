&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER X_doc-line FOR ub.doc-line.
DEFINE BUFFER X_gds-obj FOR ub.gds-obj.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER x_ord-chain FOR ub.ord-chain.
DEFINE BUFFER X_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER X_ord-line FOR ub.ord-line.
DEFINE BUFFER X_trn-doc FOR ub.trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран ручного распределения  заказа ОО по запросам

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/22/04 6:16

*/
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Распределение ручное".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ cus/df-zakaz.i new }
{ cmp/r-page1.i new }
{ rep/gn-extp.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ gbl/thbjattr.i }
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parParentProc   as widget-handle no-undo.
define input-output parameter p-ord-doc-recid as recid no-undo .

/* Local Variable Definitions ---                                       */

&scop col-l1  '*'
&scop col-l2  'Артикул'
&scop col-l3  'Название'
&scop col-l4  'Количество'

&scop col-1  mark-string(buffer X_ord-line, rid-list)
&scop col-2  X_ord-line.artic
&scop col-3  X_goods.gds-name
&scop col-4  X_ord-line.qnty


define  shared variable br-handle as handle  no-undo .
define  shared buffer buf-oo_ord-doc for ub.ord-doc.

define buffer   buf_ord-doc for ub.ord-doc .
define buffer   buf_clients for ub.clients .
define variable loc-obj-code as integer no-undo .
define variable loc-obj-type as character no-undo .
define variable sort-column-name as character no-undo .

define variable  rid-list         as  char no-undo . /* список recid'ов выбранных */
define variable r-gener as integer init 1  no-undo .
define variable v-poisk as character no-undo .

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.


define variable var-zapros-qnty-all as decimal no-undo.
define variable var-zapros-qnty as decimal no-undo.



define variable  g-log  as logical no-undo .
define variable  par-ord-oobj as logical no-undo .
define variable  t-log-4 as logical no-undo init false .
define variable varpurch-code as integer no-undo.

define variable p-host-code     as integer no-undo .
define variable p-host-name as character no-undo .
define new shared variable  next-prev as logical   no-undo .
define variable gds-rec as recid no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#db-remote as logical   no-undo .
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#db-remote   =(v-cntxt-db-num <> 0)
.
{ gbl/hostname.i store-type store-code  p-host-code p-host-name }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-gds-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_gds-obj X_ord-line X_goods X_doc-line ~
buf_goods obj-list X_ord-doc-rcv X_ord-chain X_trn-doc

/* Definitions for BROWSE BR-gds-obj                                    */
&Scoped-define FIELDS-IN-QUERY-BR-gds-obj SUBSTRING (X_gds-obj.obj-type,1,1) X_gds-obj.obj-code X_gds-obj.fact-qnty X_gds-obj.free-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds-obj
&Scoped-define SELF-NAME BR-gds-obj
&Scoped-define QUERY-STRING-BR-gds-obj FOR EACH X_gds-obj NO-LOCK where x_gds-obj.artic = x_ord-line.artic and x_gds-obj.prod-code = x_ord-line.prod-code and x_gds-obj.prod-type = x_ord-line.prod-type and x_gds-obj.host-code = p-host-code and not ( x_gds-obj.fact-qnty = 0 and x_gds-obj.free-qnty = 0 )
&Scoped-define OPEN-QUERY-BR-gds-obj OPEN QUERY {&SELF-NAME} FOR EACH X_gds-obj NO-LOCK where x_gds-obj.artic = x_ord-line.artic and x_gds-obj.prod-code = x_ord-line.prod-code and x_gds-obj.prod-type = x_ord-line.prod-type and x_gds-obj.host-code = p-host-code and not ( x_gds-obj.fact-qnty = 0 and x_gds-obj.free-qnty = 0 )  .
&Scoped-define TABLES-IN-QUERY-BR-gds-obj X_gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds-obj X_gds-obj


/* Definitions for BROWSE BR-goods                                      */
&Scoped-define FIELDS-IN-QUERY-BR-goods {&col-1} X_ord-line.artic X_goods.gds-name X_ord-line.qnty f-zapr-qnty (buffer X_ord-line )
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-goods X_ord-line.qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-goods X_ord-line
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-goods X_ord-line
&Scoped-define SELF-NAME BR-goods
&Scoped-define QUERY-STRING-BR-goods FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK, ~
             EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK
&Scoped-define OPEN-QUERY-BR-goods OPEN QUERY {&SELF-NAME} FOR EACH X_ord-line       WHERE X_ord-line.doc-code = loc-ord-num NO-LOCK, ~
             EACH X_goods WHERE X_goods.artic = X_ord-line.artic   AND X_goods.prod-code = X_ord-line.prod-code   AND X_goods.prod-type = X_ord-line.prod-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-goods X_ord-line X_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-goods X_ord-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-goods X_goods


/* Definitions for BROWSE BR-line-trn                                   */
&Scoped-define FIELDS-IN-QUERY-BR-line-trn X_doc-line.artic buf_goods.gds-name X_doc-line.fact-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-line-trn
&Scoped-define SELF-NAME BR-line-trn
&Scoped-define QUERY-STRING-BR-line-trn FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code , ~
       EACH buf_goods OF X_doc-line NO-LOCK
&Scoped-define OPEN-QUERY-BR-line-trn OPEN QUERY {&SELF-NAME} FOR EACH X_doc-line NO-LOCK where      X_doc-line.doc-code =X_trn-doc.doc-code , ~
       EACH buf_goods OF X_doc-line NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-line-trn X_doc-line buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-line-trn X_doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-BR-line-trn buf_goods


/* Definitions for BROWSE BR-obj-list                                   */
&Scoped-define FIELDS-IN-QUERY-BR-obj-list substring(obj-list.obj-type,1,1) string(obj-list.obj-code) string(obj-list.db-num)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-obj-list
&Scoped-define SELF-NAME BR-obj-list
&Scoped-define QUERY-STRING-BR-obj-list FOR EACH obj-list NO-LOCK WHERE BY obj-list.obj-code
&Scoped-define OPEN-QUERY-BR-obj-list OPEN QUERY {&SELF-NAME} FOR EACH obj-list NO-LOCK WHERE BY obj-list.obj-code .
&Scoped-define TABLES-IN-QUERY-BR-obj-list obj-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-obj-list obj-list


/* Definitions for BROWSE BR-rcv                                        */
&Scoped-define FIELDS-IN-QUERY-BR-rcv substring(X_ord-doc-rcv.cli-type,1,1) X_ord-doc-rcv.cli-code X_trn-doc.doc-code substring(X_trn-doc.status_,1,4) + string(X_trn-doc.flag_ ,"+/-")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rcv
&Scoped-define SELF-NAME BR-rcv
&Scoped-define QUERY-STRING-BR-rcv FOR EACH X_ord-doc-rcv NO-LOCK where X_ord-doc-rcv.doc-code = loc-ord-num , ~
       each X_ord-chain NO-LOCK where     x_ord-chain.doc-code = X_ord-doc-rcv.rcv-code and     x_ord-chain.doc-type = 'rcv'                  and     x_ord-chain.rel-doc-type = 'trn'    , ~
       each X_trn-doc NO-LOCK         where X_trn-doc.doc-code = x_ord-chain.rel-doc-code
&Scoped-define OPEN-QUERY-BR-rcv OPEN QUERY {&SELF-NAME} FOR EACH X_ord-doc-rcv NO-LOCK where X_ord-doc-rcv.doc-code = loc-ord-num , ~
       each X_ord-chain NO-LOCK where     x_ord-chain.doc-code = X_ord-doc-rcv.rcv-code and     x_ord-chain.doc-type = 'rcv'                  and     x_ord-chain.rel-doc-type = 'trn'    , ~
       each X_trn-doc NO-LOCK         where X_trn-doc.doc-code = x_ord-chain.rel-doc-code  .
&Scoped-define TABLES-IN-QUERY-BR-rcv X_ord-doc-rcv X_ord-chain X_trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rcv X_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BR-rcv X_ord-chain
&Scoped-define THIRD-TABLE-IN-QUERY-BR-rcv X_trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-gds-obj}~
    ~{&OPEN-QUERY-BR-goods}~
    ~{&OPEN-QUERY-BR-line-trn}~
    ~{&OPEN-QUERY-BR-obj-list}~
    ~{&OPEN-QUERY-BR-rcv}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 B-mark B-grp B-hand B-help ~
BR-goods BR-gds-obj B-del B-lkp B-chg BR-rcv BR-line-trn BR-obj-list ~
scr-obj-name src-obj-list-name FILL-IN-22 FILL-IN-23 src-gds-name ~
scr-main-num FI-all-str scr-obj FI-all-str-3 scr-all-qnty FILL-IN-26 ~
FILL-IN-27 src-ext-doc-type
&Scoped-Define DISPLAYED-OBJECTS scr-obj-name src-obj-list-name FILL-IN-22 ~
FILL-IN-23 src-gds-name scr-main-num FI-all-str scr-obj FI-all-str-3 ~
scr-all-qnty FILL-IN-26 FILL-IN-27 src-ext-doc-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-zapr-qnty Dialog-Frame
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER

(buffer fl for x_ord-line, input m as char) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 9 BY 1.

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 8 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON B-grp
     LABEL "&Группы"
     SIZE 8 BY 1 TOOLTIP "Отметить товары по группам".

DEFINE BUTTON B-hand
     LABEL "Генерация"
     SIZE 14 BY 1 TOOLTIP "Создать запросы".

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON B-lkp
     LABEL "Просмотр"
     SIZE 9 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить товары".

DEFINE VARIABLE FI-all-str AS CHARACTER FORMAT "X(16)":U INITIAL "на объект"
      VIEW-AS TEXT
     SIZE 8.38 BY .67
     FONT 4 NO-UNDO.

DEFINE VARIABLE FI-all-str-3 AS CHARACTER FORMAT "X(16)":U INITIAL "запрошено"
      VIEW-AS TEXT
     SIZE 8.13 BY .67
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Товары заказа"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-23 AS CHARACTER FORMAT "X(256)":U INITIAL "Остатки по объектам"
      VIEW-AS TEXT
     SIZE 20 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Запросы"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-27 AS CHARACTER FORMAT "X(256)":U INITIAL "Товары запроса"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE scr-all-qnty AS DECIMAL FORMAT ">>>>>>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 11.75 BY .67 TOOLTIP "Запрошено по запросам"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-main-num AS CHARACTER FORMAT "X(16)":U
     LABEL "По заказу и его щепкам"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Головной заказ и его щепки"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-obj AS CHARACTER FORMAT "X(9)":U
      VIEW-AS TEXT
     SIZE 8.38 BY .67
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE scr-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Заказывает"
      VIEW-AS TEXT
     SIZE 24 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE src-ext-doc-type AS CHARACTER FORMAT "x(30)"
      VIEW-AS TEXT
     SIZE 33.75 BY .67
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE src-gds-name AS CHARACTER FORMAT "x(40)"
      VIEW-AS TEXT
     SIZE 40 BY .67
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE src-obj-list-name AS CHARACTER FORMAT "x(24)"
      VIEW-AS TEXT
     SIZE 24.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 26 BY .92
     BGCOLOR 4 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-gds-obj FOR
      X_gds-obj SCROLLING.

DEFINE QUERY BR-goods FOR
      X_ord-line,
      X_goods SCROLLING.

DEFINE QUERY BR-line-trn FOR
      X_doc-line,
      buf_goods SCROLLING.

DEFINE QUERY BR-obj-list FOR
      obj-list SCROLLING.

DEFINE QUERY BR-rcv FOR
      X_ord-doc-rcv,
      X_ord-chain,
      X_trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gds-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds-obj Dialog-Frame _FREEFORM
  QUERY BR-gds-obj DISPLAY
      SUBSTRING (X_gds-obj.obj-type,1,1) COLUMN-LABEL "T" FORMAT "x(1)"
      X_gds-obj.obj-code
      X_gds-obj.fact-qnty COLUMN-LABEL "Факт"         FORMAT "->>>>>>>>9.<<<"
      X_gds-obj.free-qnty COLUMN-LABEL "Свободно" FORMAT "->>>>>>>>9.<<<"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 34.25 BY 8.5.

DEFINE BROWSE BR-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-goods Dialog-Frame _FREEFORM
  QUERY BR-goods NO-LOCK DISPLAY
      {&col-1}                  COLUMN-LABEL  {&col-l1} FORMAT "X(1)"
      X_ord-line.artic         COLUMN-LABEL  {&col-l2} FORMAT "X(16)"
      X_goods.gds-name   COLUMN-LABEL  {&col-l3}  FORMAT "X(18)"
      X_ord-line.qnty     COLUMN-LABEL  {&col-l4}  FORMAT ">>>>>>>9.<<<"
      f-zapr-qnty (buffer X_ord-line )    COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>>.<<<"
  ENABLE
      X_ord-line.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 59.75 BY 8.5.

DEFINE BROWSE BR-line-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-line-trn Dialog-Frame _FREEFORM
  QUERY BR-line-trn NO-LOCK DISPLAY
      X_doc-line.artic
      buf_goods.gds-name FORMAT "X(20)"
      X_doc-line.fact-qnty FORMAT "->>>>>>>9.<<<" column-label "Количество"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.38 BY 7.67.

DEFINE BROWSE BR-obj-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-obj-list Dialog-Frame _FREEFORM
  QUERY BR-obj-list DISPLAY
      substring(obj-list.obj-type,1,1) format "x(1)"
      string(obj-list.obj-code)  Column-label "Объект" format "x(5)"
      string(obj-list.db-num)  Column-label "БД"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 10.38 BY 7.67 TOOLTIP "Выбор объекта; Поиск по номеру объекта, BACKSPACE - очистить поиск".

DEFINE BROWSE BR-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rcv Dialog-Frame _FREEFORM
  QUERY BR-rcv DISPLAY
      substring(X_ord-doc-rcv.cli-type,1,1) COLUMN-LABEL "Т" format "x(1)"
      X_ord-doc-rcv.cli-code COLUMN-LABEL "Объект" Format "99999"
      X_trn-doc.doc-code format "x(14)"
      substring(X_trn-doc.status_,1,4) + string(X_trn-doc.flag_ ,"+/-") COLUMN-LABEL "Статус" Format "x(6)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.5 BY 7.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11.13
     B-grp AT ROW 1 COL 14.25
     B-hand AT ROW 1 COL 22.25
     B-help AT ROW 1 COL 36.38
     BR-goods AT ROW 3.79 COL 1
     BR-gds-obj AT ROW 3.79 COL 61.13
     B-del AT ROW 14.13 COL 1
     B-lkp AT ROW 14.13 COL 9
     B-chg AT ROW 14.13 COL 18
     BR-rcv AT ROW 15.25 COL 1
     BR-line-trn AT ROW 15.25 COL 34.75
     BR-obj-list AT ROW 15.25 COL 85
     scr-obj-name AT ROW 1.21 COL 63.5 COLON-ALIGNED
     src-obj-list-name AT ROW 2.13 COL 89.88 RIGHT-ALIGNED NO-LABEL
     FILL-IN-22 AT ROW 3 COL 1.75 NO-LABEL
     FILL-IN-23 AT ROW 3 COL 61.38 NO-LABEL
     src-gds-name AT ROW 12.38 COL 1.38 NO-LABEL
     scr-main-num AT ROW 12.42 COL 79 COLON-ALIGNED
     FI-all-str AT ROW 13.17 COL 55.5 COLON-ALIGNED NO-LABEL
     scr-obj AT ROW 13.17 COL 64.13 COLON-ALIGNED NO-LABEL
     FI-all-str-3 AT ROW 13.17 COL 72.63 COLON-ALIGNED NO-LABEL
     scr-all-qnty AT ROW 13.17 COL 81.25 COLON-ALIGNED NO-LABEL
     FILL-IN-26 AT ROW 13.42 COL 1.75 NO-LABEL
     FILL-IN-27 AT ROW 13.79 COL 34.88 NO-LABEL
     src-ext-doc-type AT ROW 22.92 COL 1 NO-LABEL
     RECT-1 AT ROW 2 COL 65.5
     SPACE(5.62) SKIP(20.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Распределение заказа по запросам на объекты".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" NO-UNDO ub ub.goods
      TABLE: X_doc-line B "?" ? ub ub.doc-line
      TABLE: X_gds-obj B "?" ? ub gds-obj
      TABLE: X_goods B "?" ? ub ub.goods
      TABLE: x_ord-chain B "?" ? ub ub.ord-chain
      TABLE: X_ord-doc-rcv B "?" ? ub ub.ord-doc-rcv
      TABLE: X_ord-line B "?" ? ub ub.ord-line
      TABLE: X_trn-doc B "?" ? ub ub.trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-goods B-help Dialog-Frame */
/* BROWSE-TAB BR-gds-obj BR-goods Dialog-Frame */
/* BROWSE-TAB BR-rcv B-chg Dialog-Frame */
/* BROWSE-TAB BR-line-trn BR-rcv Dialog-Frame */
/* BROWSE-TAB BR-obj-list BR-line-trn Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-22 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-23 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-26 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-27 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN src-ext-doc-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN src-gds-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN src-obj-list-name IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds-obj
/* Query rebuild information for BROWSE BR-gds-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_gds-obj NO-LOCK
where x_gds-obj.artic = x_ord-line.artic and
x_gds-obj.prod-code = x_ord-line.prod-code and
x_gds-obj.prod-type = x_ord-line.prod-type and
x_gds-obj.host-code = p-host-code and
not ( x_gds-obj.fact-qnty = 0 and
x_gds-obj.free-qnty = 0 )

.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-gds-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-goods
/* Query rebuild information for BROWSE BR-goods
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
*/  /* BROWSE BR-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-line-trn
/* Query rebuild information for BROWSE BR-line-trn
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR
EACH X_doc-line NO-LOCK where
     X_doc-line.doc-code =X_trn-doc.doc-code ,
EACH buf_goods OF X_doc-line NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BR-line-trn */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-obj-list
/* Query rebuild information for BROWSE BR-obj-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH obj-list NO-LOCK WHERE BY obj-list.obj-code .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-obj-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rcv
/* Query rebuild information for BROWSE BR-rcv
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_ord-doc-rcv NO-LOCK
where X_ord-doc-rcv.doc-code = loc-ord-num ,
each X_ord-chain NO-LOCK where
    x_ord-chain.doc-code = X_ord-doc-rcv.rcv-code and
    x_ord-chain.doc-type = 'rcv'                  and
    x_ord-chain.rel-doc-type = 'trn'    ,
each X_trn-doc NO-LOCK
        where X_trn-doc.doc-code = x_ord-chain.rel-doc-code  .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-rcv */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Распределение заказа по запросам на объекты */
DO:
   run exit-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Распределение заказа по запросам на объекты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
   if available x_trn-doc and
                x_trn-doc.doc-type = {&income} and
                x_trn-doc.status_  = {&inquiry}      then do:
        run gbl/calc-trn.p ( input parParentProc , input recid(x_trn-doc)).
        run cus/ord-outu.p ( input parParentProc , input recid(x_trn-doc)).
        {&OPEN-QUERY-BR-line-trn}
        {&OPEN-QUERY-BR-goods}
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run del-trn in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    next-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-grp Dialog-Frame
ON CHOOSE OF B-grp IN FRAME Dialog-Frame /* Группы */
DO:
    message "Отметить товары по группам ?"
           view-as alert-box question
            buttons yes-no
           update g-log
           .
  if g-log = false then return.
   run grp-num in this-procedure .
   run OpenBr in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hand Dialog-Frame
ON CHOOSE OF B-hand IN FRAME Dialog-Frame /* Генерация */
DO:
define variable g-ok as logical no-undo .
define variable v-rowid as integer no-undo .

  find current x_ord-line no-lock no-error .
  find current obj-list no-error .
  if error-status :error then do:
        message "Подтвердите Объект заказа !"
        view-as alert-box .
        return .
     end.


  if r-gener = 1 then do:
     if num-entries (rid-list) = 0 then do:
        message "Не отмечены товары в заказе !"
        view-as alert-box .
        return .
     end.

     if obj-list.obj-code = buf_ord-doc.obj-code and
        obj-list.obj-type = buf_ord-doc.obj-type then do:
        message "Нельзя перемещать на тот же объект "  obj-list.obj-name "!"
        view-as alert-box .
        return .

     end.


      message "Сформировать запрос на объект"  obj-list.obj-name " ? "
              view-as alert-box question
              buttons yes-no
              update g-ok
              .
  end.


  if g-ok = false then return.
  .
  run make-trn-doc in this-procedure .
  run OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
   if available x_trn-doc then
      run str/showdoc.p
          (input parparentproc
          ,input x_trn-doc.doc-code
          ,input ""
          ,input ""
          ,input 0
          ,input true
          ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
        if available x_ord-line then do:
        { gbl/markstrn.i x_ord-line rid-list }
        g-log = br-goods:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-goods:select-next-row ().
            apply "VALUE-CHANGED" to br-goods in frame {&frame-name}.
        end.
    end.
    apply "entry" to br-goods in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds-obj
&Scoped-define SELF-NAME BR-gds-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds-obj Dialog-Frame
ON VALUE-CHANGED OF BR-gds-obj IN FRAME Dialog-Frame
DO:
  /* высветить obj-list */
run proc-gds-obj in this-procedure .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-goods
&Scoped-define SELF-NAME BR-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-goods Dialog-Frame
ON VALUE-CHANGED OF BR-goods IN FRAME Dialog-Frame
DO:
src-gds-name = "" .
if available x_goods then do:
   src-gds-name = x_goods.gds-name .
   {&OPEN-QUERY-BR-gds-obj}
   run proc-gds-obj in this-procedure .
end.
display src-gds-name  with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-obj-list
&Scoped-define SELF-NAME BR-obj-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-obj-list Dialog-Frame
ON ANY-PRINTABLE OF BR-obj-list IN FRAME Dialog-Frame
DO:

  v-poisk = v-poisk + last-event:label.
  find first obj-list where string(obj-list.obj-code ) begins v-poisk  no-error .
  if available  obj-list then
     reposition BR-obj-list to recid recid(obj-list) no-error .
  apply "VALUE-CHANGED" TO BR-obj-list IN FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-obj-list Dialog-Frame
ON BACKSPACE OF BR-obj-list IN FRAME Dialog-Frame
DO:
  v-poisk = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-obj-list Dialog-Frame
ON VALUE-CHANGED OF BR-obj-list IN FRAME Dialog-Frame
DO:
  if available obj-list then do:
    src-obj-list-name = "у " + obj-list.obj-name.
    display src-obj-list-name with frame {&frame-name}.
    run proc-gds-obj in this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rcv
&Scoped-define SELF-NAME BR-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-rcv Dialog-Frame
ON VALUE-CHANGED OF BR-rcv IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-BR-line-trn}
if available x_trn-doc  then do:
   src-ext-doc-type = func-get-name-from-ext-type (x_trn-doc.ext-doc-type,no) .
end.
display src-ext-doc-type with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds-obj
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/f2.i BR-goods goods-recid init-gds-rec parParentProc }

on end-error, stop of frame {&frame-name}  do:
  apply "choose" to b-exit in frame {&frame-name} .
  return no-apply.
end.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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

{&col-4}:read-only in browse br-goods = true .
  run init-proc in this-procedure .
  run enable_UI in this-procedure .
  run openbr in this-procedure .
  wait-for go of frame {&frame-name}.
End.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-trn Dialog-Frame
PROCEDURE del-trn :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer x_ord-doc-line-rcv for ub.ord-line-rcv.
define variable varchip-code as integer no-undo.

    if available x_ord-doc-rcv then do:
       find current x_ord-doc-rcv exclusive-lock no-error.
            if avail x_ord-doc-rcv then do:
               for each ub.ord-chain no-lock where
                      ub.ord-chain.doc-code = x_ord-doc-rcv.rcv-code and
                      ub.ord-chain.doc-type = 'rcv'                  and
                      ub.ord-chain.rel-doc-type = 'trn'
                      :
                    find first x_trn-doc  no-lock  where
                          x_trn-doc.doc-code = ub.ord-chain.rel-doc-code no-error .
                      if available x_trn-doc then do:
                            if not ( x_trn-doc.status_ = {&inquiry}  and
                                    x_trn-doc.flag_   = false )  then do :
                                      message "Статус " x_trn-doc.status_   + string( x_trn-doc.flag_ , "+/-")  " удалять нельзя! "
                                              view-as alert-box error .
                                              return.
                            end.
                            message "Удалить накладную №"  x_trn-doc.doc-code "?" view-as alert-box
                                    question buttons yes-no title "Вопрос" update g-log.
                          if g-log then do:
                              run str/del-doc.p
                                  ( input  parParentProc,
                                    input  x_trn-doc.doc-code,
                                    input  v-cntxt-db-num,
                                    input  "del-doc.err",
                                    input  ?,
                                    input  ?,
                                    input  v-cntxt-userid,
                                    input  x_trn-doc.doc-code,
                                    input  ?,
                                    output varchip-code )
                                    .

                              if x_ord-doc-rcv.status_ <> {&g___new} then do :
                                  for each  x_ord-doc-line-rcv  exclusive-lock  where
                                            x_ord-doc-line-rcv.doc-code = x_ord-doc-rcv.doc-code and
                                            x_ord-doc-line-rcv.rcv-code = x_ord-doc-rcv.rcv-code
                                            on error undo, return error :
                                            delete x_ord-doc-line-rcv.
                                  end. /* for each */
                                  assign
                                    x_ord-doc-rcv.status_ = {&fact}
                                  .

                              end.
                              else do:
                                delete  x_ord-doc-rcv .
                              end.
                              run Openbr in this-procedure .
                          end.
                    end.
                 end.
              end.
              else do:
              /*подвисший rcv без накладной */
                message "Удалить запись ?" view-as alert-box
                      question buttons yes-no title "Вопрос" update g-log.
                      if g-log then
                        delete  x_ord-doc-rcv .
              end.
  end.


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
  DISPLAY scr-obj-name src-obj-list-name FILL-IN-22 FILL-IN-23 src-gds-name
          scr-main-num FI-all-str scr-obj FI-all-str-3 scr-all-qnty FILL-IN-26
          FILL-IN-27 src-ext-doc-type
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 B-mark B-grp B-hand B-help BR-goods BR-gds-obj B-del
         B-lkp B-chg BR-rcv BR-line-trn BR-obj-list scr-obj-name
         src-obj-list-name FILL-IN-22 FILL-IN-23 src-gds-name scr-main-num
         FI-all-str scr-obj FI-all-str-3 scr-all-qnty FILL-IN-26 FILL-IN-27
         src-ext-doc-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exit-proc Dialog-Frame
PROCEDURE exit-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define variable glob-gen as logical init false  no-undo .
define variable v-kk as integer no-undo .
define buffer buf_ver_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer buf_ver_doc-line for ub.doc-line.
define buffer buf_ver_trn-doc  for ub.trn-doc.
define variable varchip-code as integer no-undo.

for each buf_ver_ord-doc-rcv no-lock where
         buf_ver_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
         on error undo, return error :
        v-kk = 0 .
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ver_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :

              for each buf_ver_doc-line no-lock where
                       buf_ver_doc-line.doc-code = ub.ord-chain.rel-doc-code
                       on error undo, return error :
                       v-kk = v-kk + 1 .
              end. /* for each строки */
        end.
        if v-kk = 0 then do:
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ver_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
           find first buf_ver_trn-doc no-lock where buf_ver_trn-doc.doc-code = ub.ord-chain.rel-doc-code no-error .
           if available buf_ver_trn-doc then
              run str/del-doc.p
                ( input  parParentProc,
                  input  buf_ver_trn-doc.doc-code,
                  input  v-cntxt-db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  v-cntxt-userid,
                  input  buf_ver_trn-doc.doc-code,
                  input  ?,
                  output varchip-code ) .
           find x_ord-doc-rcv  exclusive-lock where recid(x_ord-doc-rcv) = recid(buf_ver_ord-doc-rcv) no-error .
           if available x_ord-doc-rcv then
              delete x_ord-doc-rcv.
        end.
        end.
end. /* for each */


if buf_ord-doc.status_ = {&ord-req} and buf_ord-doc.flag_ = false  then do:

    if can-find(first X_ord-doc-rcv no-lock where X_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ) = true
      then glob-gen = true .

    if  glob-gen = true  then do:
      message "Закрываем заказ до статуса " + caps( {&ord-req} ) +  "+ ? " view-as alert-box question
            buttons yes-no title "" update t-log-4 .
            if t-log-4 = true then do:
              run cus/ordoocls.p
                ( input parParentProc ,
                  input recid(buf_ord-doc) ,
                  input true )
                   .
            end.
    end.
end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE grp-num Dialog-Frame
PROCEDURE grp-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable v-grp-recid as character no-undo .
 define buffer buf_gds-grp for ub.gds-grp .
 define buffer buf_goods   for ub.goods .
 define buffer buf_ord-line for ub.ord-line.
 rid-list = "" .
 run ref/gds-grp.w ( parParentProc, "b-sel,b-mark", store-type, store-code, input-output v-grp-recid ).

 if num-entries( v-grp-recid ) = 0  then do :
    message "Ни чего не выбрано !"  view-as alert-box .
    return .
 end.

define variable v-ind as integer   no-undo .
define variable  Grp_Name as character no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries( v-grp-recid ) .
    repeat v-ind = 1 to v-nn
    :
      FIND buf_gds-grp no-lock  WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,v-grp-recid )) .
      run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
            /*message grp_name.*/
            for each buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num ,
                each buf_goods no-lock where buf_goods.artic = buf_ord-line.artic   and
                                    buf_goods.prod-code = buf_ord-line.prod-code   and
                                    buf_goods.prod-type = buf_ord-line.prod-type   and
                                    buf_goods.grp-name begins grp_name
                on error undo, return error :
                find first x_ord-line no-lock where
                      recid(x_ord-line) = recid(buf_ord-line) no-error .
                      if available  x_ord-line then
                          apply "CHOOSE" to b-mark in frame {&frame-name} .
            end. /* for each */
    end.
end.  /* do */
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
  scr-obj-name     = buf_clients.obj-name
  loc-ord-num      = buf_ord-doc.doc-code
 .
     ASSIGN frame {&frame-name}:TITLE = frame  {&frame-name}:TITLE + " Заказ  № " + loc-ord-num  .

  /* список объектов фирмы */
  for each obj-list   :
     delete obj-list .
  end. /* for each */
  for each ub.shop where ub.shop.host-code   = p-host-code:
      { cmp/cr-objls.i "{&shop}"  ub.shop.obj-code no-error }
  end.
  for each ub.store where ub.store.host-code  = p-host-code:
      { cmp/cr-objls.i "{&stock}"  ub.store.obj-code no-error }

  end.

/* главный заказ */
run main-ord (  input loc-ord-num  ,  output scr-main-num  ) .

define variable par-type     as char no-undo.    /* тип параметра конфигурации */
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-oobj}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-oobj
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-oobj = false .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-ord Dialog-Frame
PROCEDURE main-ord :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter   p-in-ord-num as character no-undo .
define output parameter  p-out-ord-num as character no-undo .

if num-entries(p-in-ord-num , "." ) = 1 then
   p-out-ord-num = p-in-ord-num .
   else do:
     p-out-ord-num = entry(1, entry( 1 , p-in-ord-num , "." ) , "-" )  + "-" + entry( 2 , p-in-ord-num , "."  ) .
   end.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-rcv Dialog-Frame
PROCEDURE make-rcv :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

/* -----------------------------------------------------------
  Purpose: генерация поставок по заказу
-------------------------------------------------------------*/
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define output parameter  r-rec as recid no-undo.

define variable l-recid as recid no-undo.
define variable v-root-node as integer no-undo .


define variable ks          as  integer no-undo .
define variable loc-rcv-num as  character no-undo .
define variable ii          as  integer no-undo .
define buffer   b-goods     for ub.goods .
define buffer   bfp-ord-doc for ub.ord-doc .
define buffer   buf2-ord-line-rcv for ub.ord-line-rcv.
define buffer   buf2-ord-doc-rcv  for ub.ord-doc-rcv .
define buffer   buf2-doc-line     for ub.doc-line     .
define buffer   buf_gds-obj       for ub.gds-obj.
define variable last-all-rcv as decimal no-undo .

define buffer buf_ord-doc-rcv  for  ub.ord-doc-rcv.
define buffer buf_ord-line     for ub.ord-line.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv.

ks = 0.
define variable v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-rcv-num
    }


  find first bfp-ord-doc where bfp-ord-doc.doc-code = loc-ord-num no-lock no-error.
       if error-status :error  then return.

   if not( bfp-ord-doc.status_  = {&ord-req} and
           bfp-ord-doc.flag_    = false  )
   then do:
        message "Нелязя делать ЗАПРОС по   Заказу в статусе " caps(bfp-ord-doc.status_) string(bfp-ord-doc.flag_,"+/-") " !"
                 view-as alert-box information .
        return.
   end.

/* Шапка поставки */

create buf_ord-doc-rcv.
buffer-copy bfp-ord-doc to buf_ord-doc-rcv
   assign
      buf_ord-doc-rcv.rcv-code  = loc-rcv-num
      buf_ord-doc-rcv.doc-type  = {&ord-req}
      buf_ord-doc-rcv.doc-date  = today
      buf_ord-doc-rcv.status_   = {&g___new}
      buf_ord-doc-rcv.cli-code = p-cli-code
      buf_ord-doc-rcv.cli-type = p-cli-type
   .

   for each buf_ord-line no-lock where buf_ord-line.doc-code = loc-ord-num  and
       lookup( string( recid( buf_ord-line ) ) , rid-list ) > 0   :
        ks = ks + 1 .
        if not can-find  (first buf_ord-line-rcv where
          buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code and
          buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code and
          buf_ord-line-rcv.artic     = buf_ord-line.artic and
          buf_ord-line-rcv.prod-code = buf_ord-line.prod-code and
          buf_ord-line-rcv.prod-type = buf_ord-line.prod-type no-lock ) then do:
          last-all-rcv = 0 .

        /* сколько уже этого товара распределили ======Cчитать надо по запросам , а не по поставкам  */
        for each buf2-ord-line-rcv where
          buf2-ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code and
          buf2-ord-line-rcv.artic     = buf_ord-line.artic and
          buf2-ord-line-rcv.prod-code = buf_ord-line.prod-code and
          buf2-ord-line-rcv.prod-type = buf_ord-line.prod-type no-lock ,
            first buf2-ord-doc-rcv no-lock where
                   buf2-ord-doc-rcv.rcv-code =  buf2-ord-line-rcv.rcv-code and
                   buf2-ord-doc-rcv.doc-code =  buf2-ord-line-rcv.doc-code    ,
           each ub.ord-chain no-lock where
                    ub.ord-chain.doc-code = buf2-ord-doc-rcv.rcv-code and
                    ub.ord-chain.doc-type = 'rcv'                  and
                    ub.ord-chain.rel-doc-type = 'trn' ,
            first buf2-doc-line no-lock where
                   buf2-doc-line.doc-code     =  ub.ord-chain.rel-doc-code  and
                   buf2-doc-line.artic        =  buf2-ord-line-rcv.artic    and
                   buf2-doc-line.prod-code    =  buf2-ord-line-rcv.prod-code and
                   buf2-doc-line.prod-type    =  buf2-ord-line-rcv.prod-type
             :

              last-all-rcv =  last-all-rcv + buf2-doc-line.fact-qnty .
        end.

         { gbl/rootnode.i
           buf_ord-line.artic
           buf_ord-line.prod-type
           buf_ord-line.prod-code
           v-root-node
         }

         create buf_ord-line-rcv.
         buffer-copy buf_ord-line to buf_ord-line-rcv
         assign
           buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
           buf_ord-line-rcv.line-num  = ks
           buf_ord-line-rcv.qnty      = if (buf_ord-line.qnty - last-all-rcv) < 0 then 0
                                                                                  else  (buf_ord-line.qnty - last-all-rcv)
           buf_ord-line-rcv.cli-qnty  = buf_ord-line-rcv.qnty / buf_ord-line-rcv.cli-base-rate

         .
         /* если задан параметр то надо сверить с остатком на объекте */
         if par-ord-oobj  = true then do :
              find first buf_gds-obj no-lock
                      where buf_gds-obj.artic     = buf_ord-line.artic and
                            buf_gds-obj.prod-code = buf_ord-line.prod-code and
                            buf_gds-obj.prod-type = buf_ord-line.prod-type and
                            buf_gds-obj.obj-code  = buf_ord-doc-rcv.cli-code and
                            buf_gds-obj.obj-type  = buf_ord-doc-rcv.cli-type and
                            buf_gds-obj.host-code = p-host-code no-error .

              if available buf_gds-obj and buf_gds-obj.free-qnty > 0 then do:
                  if buf_ord-line-rcv.qnty > buf_gds-obj.free-qnty then do:
                      assign
                        buf_ord-line-rcv.qnty = buf_gds-obj.free-qnty
                      .
                  end.
                  buf_ord-line-rcv.cli-qnty  = buf_ord-line-rcv.qnty / buf_ord-line-rcv.cli-base-rate    .
              end.
              else do:
                assign
                    buf_ord-line-rcv.qnty = 0
                    buf_ord-line-rcv.cli-qnty = 0
                .
              end.
         end.

         create buf_ord-dtl-rcv.
         buffer-copy buf_ord-line-rcv to buf_ord-dtl-rcv
            assign
              buf_ord-dtl-rcv.node-code = v-root-node
            .
            define variable l-terminal-prt as logical   no-undo .
            { gbl/prtat.i
              buf_ord-dtl-rcv.node-code
              'terminal-prt=request':u
              l-terminal-prt
            }
         if not l-terminal-prt then do:
            /* поиск первого терминального признака */
            { gbl/termnode.i
              buf_ord-dtl-rcv.node-code
              buf_ord-dtl-rcv.node-code
            }
         end.

         l-recid = recid(buf_ord-line-rcv).
         end.
end.

if ks > 0 then do:
    r-rec = recid(buf_ord-doc-rcv).
    /* message "Сделана поставка № " loc-rcv-num . */

    run cus/ord-trnz.p (parParentProc ,
                    input r-rec ,
                    input {&income},
                    input "" ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
             "Ошибка ord-trnz.p " skip
              skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error
      .
      delete buf_ord-doc-rcv .
      return error .
    end.

   end.
 else do:

   find first buf_ord-doc-rcv where buf_ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  .
   delete buf_ord-doc-rcv .
   r-rec = ?.
end.

rid-list = "" .

end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-rcv-avto Dialog-Frame
PROCEDURE make-rcv-avto :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-trn-doc Dialog-Frame
PROCEDURE make-trn-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable p-recid as recid no-undo .
run waitfram-show in this-procedure ("Формирование связки заказ - запрос....") .
if r-gener = 1 then do:
    run make-rcv in this-procedure (
      input obj-list.obj-type ,
      input obj-list.obj-code ,
      output p-recid )
      .
 end.

{&OPEN-QUERY-BR-rcv}
  apply "VALUE-CHANGED" TO BR-rcv IN FRAME Dialog-Frame.
  apply "entry" TO BR-rcv IN FRAME Dialog-Frame.
{&OPEN-QUERY-BR-line-trn}
run waitfram-hide in this-procedure .
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  apply "VALUE-CHANGED" TO BR-goods IN FRAME Dialog-Frame.
  apply "VALUE-CHANGED" TO BR-gds-obj IN FRAME Dialog-Frame.
  apply "VALUE-CHANGED" TO BR-rcv IN FRAME Dialog-Frame.
  apply "VALUE-CHANGED" TO BR-obj-list IN FRAME Dialog-Frame.
  apply "entry" TO BR-gds-obj IN FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-gds-obj Dialog-Frame
PROCEDURE proc-gds-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define buffer buf_all-ord-doc for ub.ord-doc .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv for ub.ord-line-rcv .
define buffer buf_doc-line          for ub.doc-line .
define buffer buf_trn-doc for ub.trn-doc.

define variable temp-number as character no-undo .
define variable v-doc-rec as recid no-undo .

scr-obj = "" .

 if not available x_gds-obj then return.

   find current obj-list no-error .

   if available  obj-list then do:
      v-doc-rec = recid(obj-list) .
      reposition br-obj-list to recid v-doc-rec no-error .
      apply "value-changed" to br-obj-list in frame {&frame-name} .
      apply "entry" to br-obj-list in frame {&frame-name}    .
      scr-obj = obj-list.obj-type + " " + string(obj-list.obj-code) .
      scr-all-qnty = 0.
      /*Сколько по объекту этого товара заказано по главному заказу и по щепкам */
          for each buf_all-ord-doc no-lock
              where buf_all-ord-doc.doc-code begins entry( 1 , loc-ord-num , "-" ) and
                    buf_all-ord-doc.obj-type =  store-type and
                    buf_all-ord-doc.obj-code =  store-code

              on error undo, return error :
                run main-ord in this-procedure (  input buf_all-ord-doc.doc-code  ,  output  temp-number ) .
                if temp-number <> scr-main-num then next .

                for each buf_ord-line-rcv no-lock
                    where buf_ord-line-rcv.doc-code  = buf_all-ord-doc.doc-code  and
                          buf_ord-line-rcv.artic     = x_gds-obj.artic     and
                          buf_ord-line-rcv.prod-type = x_gds-obj.prod-type and
                          buf_ord-line-rcv.prod-code = x_gds-obj.prod-code
                          on error undo, return error :

                          find first buf_ord-doc-rcv no-lock where
                                    buf_ord-doc-rcv.rcv-code  = buf_ord-line-rcv.rcv-code  and
                                    buf_ord-doc-rcv.doc-code  = buf_ord-line-rcv.doc-code  no-error .
                                    if error-status :error then return error .
                          for each ub.ord-chain no-lock where
                                    ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                                    ub.ord-chain.doc-type = 'rcv'                  and
                                    ub.ord-chain.rel-doc-type = 'trn'
                                    :
                                  find first buf_trn-doc no-lock where
                                          buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code  and
                                          buf_trn-doc.doc-type = {&income}           and
                                          buf_trn-doc.cli-type =  x_gds-obj.obj-type and
                                          buf_trn-doc.cli-code =  x_gds-obj.obj-code no-error .

                                if not available buf_trn-doc then next.
                                find first buf_doc-line no-lock where
                                          buf_doc-line.doc-code  = buf_trn-doc.doc-code  and
                                          buf_doc-line.artic     = buf_ord-line-rcv.artic     and
                                          buf_doc-line.prod-type = buf_ord-line-rcv.prod-type and
                                          buf_doc-line.prod-code = buf_ord-line-rcv.prod-code
                                          no-error .

                                if available buf_doc-line then do:
                                  scr-all-qnty  = scr-all-qnty  + buf_doc-line.fact-qnty .
                                end.
                          end.

                end. /* for each */
          end. /* for each */
   end.

display scR-obj scr-all-qnty  with frame {&frame-name}.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-zapr-qnty Dialog-Frame
FUNCTION f-zapr-qnty RETURNS decimal
  ( buffer buf_ord-line for ub.ord-line ) :
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
                    if error-status :error then next.
          for each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                    and
                   ub.ord-chain.rel-doc-type = 'trn'
                   :
          find first buf_trn-doc no-lock  where
                     buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code  and
                     buf_trn-doc.doc-type = {&income} and
                     buf_trn-doc.status_  = {&inquiry}
                     no-error .
          if not available buf_trn-doc then next .
          find first buf_doc-line no-lock where
                     buf_doc-line.doc-code = ub.ord-chain.rel-doc-code  and
                     buf_doc-line.artic     = buf_ord-line.artic       and
                     buf_doc-line.prod-type = buf_ord-line.prod-type   and
                     buf_doc-line.prod-code = buf_ord-line.prod-code   no-error .
                     if error-status :error then next .

          res  = res  + buf_doc-line.fact-qnty .

         end. /* for each */
end. /* for each */



  RETURN res .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER

(buffer fl for x_ord-line, input m as char):
if lookup(string(recid(fl)),m) > 0 then return chr(42).
else return chr(32).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME