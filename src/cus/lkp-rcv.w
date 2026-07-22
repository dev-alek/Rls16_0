&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE SHARED BUFFER bufs_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_ord-chain FOR ub.ord-chain.
DEFINE TEMP-TABLE loc-line-rcv NO-UNDO LIKE ub.ord-line-rcv.
DEFINE BUFFER Obj-clients FOR ub.clients.
DEFINE BUFFER Post-clients FOR ub.clients.
DEFINE BUFFER Post-goods FOR ub.goods.
DEFINE BUFFER post-ord-line-rcv FOR ub.ord-line-rcv.
DEFINE BUFFER rcv_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр поставки

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

*/

define input  parameter parParentProc   as widget-handle no-undo.
define input-output  parameter p-ord-rec       as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр строки поставки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ str/lib-trn.i  }
{ cus/df-zakaz.i new }
{ cus/ord-lib.i  def }
{ gbl/getcntxt.i def }

define shared variable next-prev     as logical   no-undo .
define shared variable br-rcv-handle as handle no-undo   .

define variable p-host-code     as integer   no-undo .
define variable p-g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable prt-mode          as character no-undo .
define variable doc-rec           as recid no-undo .
define variable line-rec          as recid no-undo . /* - */
define variable gds-rec           as recid no-undo . /* для F9 */
define variable prt-rec           as recid no-undo . /* - */
define variable g#log             as logical   no-undo .
define variable g#stat            as character no-undo .
define variable g#type            as character no-undo .
define variable g#internal        as logical   no-undo .
define variable g#mainmenu-handle as handle no-undo .
define variable base-code         as integer   no-undo .
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

&Scoped-define OPEN-QUERY-BROWSE-30-sort OPEN QUERY BROWSE-30 FOR EACH post-ord-line-rcv     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and     bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code  NO-LOCK, ~
       EACH Post-goods where     Post-goods.artic  =  post-ord-line-rcv.artic  and     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and     Post-goods.prod-type  =  post-ord-line-rcv.prod-type    NO-LOCK


{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#mainmenu-handle = parParentProc
.

if store-type = ? or store-type = "" then do:
    p-host-code = v-cntxt-host-code-obj .
    define buffer buf_clients-name for ub.clients  .
    find first buf_clients-name no-lock where buf_clients-name.obj-code =  p-host-code and
                                              buf_clients-name.obj-type = {&cmp} no-error .
    p-g#host-name = buf_clients-name.obj-name.
end.
else do:
    { gbl/hostname.i store-type store-code  p-host-code p-g#host-name }
    p-host-code   = v-cntxt-host-code-obj.
end.
{ gbl/basecode.i p-host-code base-code }

define buffer b-ord-line for ub.ord-line-rcv  .
define variable loc-time as char no-undo   .
define variable loc-time-2 as char no-undo .
define variable sort-column-name as character no-undo .
define variable kk as integer no-undo .



define variable doc-mode as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-30

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES post-ord-line-rcv Post-goods buf_ord-chain ~
bufs_ord-doc-rcv ord-doc-rcv post-clients obj-clients

/* Definitions for BROWSE BROWSE-30                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-30 post-ord-line-rcv.artic Post-goods.gds-name Post-goods.unit-base post-ord-line-rcv.qnty post-ord-line-rcv.unit-cli post-ord-line-rcv.cli-qnty post-ord-line-rcv.price-rubl post-ord-line-rcv.price-base post-ord-line-rcv.price-cli post-ord-line-rcv.line-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-30 post-ord-line-rcv.qnty ~
post-ord-line-rcv.cli-qnty ~
post-ord-line-rcv.price-cli ~
post-ord-line-rcv.line-num
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-30 post-ord-line-rcv
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-30 post-ord-line-rcv
&Scoped-define SELF-NAME BROWSE-30
&Scoped-define QUERY-STRING-BROWSE-30 FOR EACH post-ord-line-rcv  NO-LOCK     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and           bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code , ~
       EACH Post-goods  NO-LOCK where      Post-goods.artic      =  post-ord-line-rcv.artic  and      Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and      Post-goods.prod-type  =  post-ord-line-rcv.prod-type
&Scoped-define OPEN-QUERY-BROWSE-30 OPEN QUERY {&SELF-NAME} FOR EACH post-ord-line-rcv  NO-LOCK     where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and           bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code , ~
       EACH Post-goods  NO-LOCK where      Post-goods.artic      =  post-ord-line-rcv.artic  and      Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and      Post-goods.prod-type  =  post-ord-line-rcv.prod-type.
&Scoped-define TABLES-IN-QUERY-BROWSE-30 post-ord-line-rcv Post-goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-30 post-ord-line-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-30 Post-goods


/* Definitions for BROWSE BROWSE-35                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-35 buf_ord-chain.rel-doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-35
&Scoped-define SELF-NAME BROWSE-35
&Scoped-define QUERY-STRING-BROWSE-35 FOR EACH buf_ord-chain NO-LOCK  where           buf_ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and           buf_ord-chain.doc-type = 'rcv'                  and           buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-35 OPEN QUERY {&SELF-NAME} FOR EACH buf_ord-chain NO-LOCK  where           buf_ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and           buf_ord-chain.doc-type = 'rcv'                  and           buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-35 buf_ord-chain
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-35 buf_ord-chain


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-30}~
    ~{&OPEN-QUERY-BROWSE-35}
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH bufs_ord-doc-rcv where recid(bufs_ord-doc-rcv) = p-ord-rec no-LOCK, ~
             first ub.ord-doc-rcv where  recid(ord-doc-rcv) = p-ord-rec no-lock , ~
             EACH post-clients WHERE                       bufs_ord-doc-rcv.cli-code = post-clients.obj-code and                       bufs_ord-doc-rcv.cli-type = post-clients.obj-type  no-LOCK , ~
             EACH obj-clients WHERE                       bufs_ord-doc-rcv.obj-code = obj-clients.obj-code and                       bufs_ord-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH bufs_ord-doc-rcv where recid(bufs_ord-doc-rcv) = p-ord-rec no-LOCK, ~
             first ub.ord-doc-rcv where  recid(ord-doc-rcv) = p-ord-rec no-lock , ~
             EACH post-clients WHERE                       bufs_ord-doc-rcv.cli-code = post-clients.obj-code and                       bufs_ord-doc-rcv.cli-type = post-clients.obj-type  no-LOCK , ~
             EACH obj-clients WHERE                       bufs_ord-doc-rcv.obj-code = obj-clients.obj-code and                       bufs_ord-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame bufs_ord-doc-rcv ub.ord-doc-rcv ~
post-clients obj-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame bufs_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.ord-doc-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame post-clients
&Scoped-define FOURTH-TABLE-IN-QUERY-Dialog-Frame obj-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.ord-doc-rcv.rcv-code ~
ub.ord-doc-rcv.doc-code ub.ord-doc-rcv.cli-code ub.ord-doc-rcv.cli-type ~
ub.ord-doc-rcv.obj-code ub.ord-doc-rcv.obj-type ub.ord-doc-rcv.ship-date ~
ub.ord-doc-rcv.exch-rate ub.ord-doc-rcv.exch-scale ub.ord-doc-rcv.exch-code ~
ub.ord-doc-rcv.base-rate ub.ord-doc-rcv.base-scale
&Scoped-define ENABLED-TABLES ub.ord-doc-rcv
&Scoped-define FIRST-ENABLED-TABLE ub.ord-doc-rcv
&Scoped-Define ENABLED-OBJECTS B-exit b-prev b-next B-diff B-delivery ~
B-Help RECT-3 BROWSE-35 B-trn b-lkp b-scl b-export BROWSE-30 loc-type-doc ~
loc-cli-out-code post_obj-name obj_obj-name l-loc-hour l-loc-min ~
l-loc-hour-2 l-loc-min-2 abbr-cli abbr-base
&Scoped-Define DISPLAYED-FIELDS ub.ord-doc-rcv.rcv-code ~
ub.ord-doc-rcv.doc-code ub.ord-doc-rcv.cli-code ub.ord-doc-rcv.cli-type ~
ub.ord-doc-rcv.obj-code ub.ord-doc-rcv.obj-type ub.ord-doc-rcv.ship-date ~
ub.ord-doc-rcv.exch-rate ub.ord-doc-rcv.exch-scale ub.ord-doc-rcv.exch-code ~
ub.ord-doc-rcv.base-rate ub.ord-doc-rcv.base-scale
&Scoped-define DISPLAYED-TABLES ub.ord-doc-rcv
&Scoped-define FIRST-DISPLAYED-TABLE ub.ord-doc-rcv
&Scoped-Define DISPLAYED-OBJECTS loc-type-doc loc-cli-out-code ~
post_obj-name obj_obj-name l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 ~
abbr-cli abbr-base

/* Custom List Definitions                                              */
/* doc-list,line-list,trn-list,List-4,List-5,List-6                     */
&Scoped-define doc-list loc-type-doc loc-cli-out-code post_obj-name ~
obj_obj-name l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 abbr-cli ~
abbr-base
&Scoped-define line-list loc-type-doc loc-cli-out-code post_obj-name ~
obj_obj-name
&Scoped-define trn-list B-trn l-loc-hour-2 l-loc-min-2

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-export-2
       MENU-ITEM m___Excel-2    LABEL "Экспорт в Excel"
       MENU-ITEM m_mobilscn-2   LABEL "Экспорт в Моб.сканер".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-delivery
     LABEL "&Доставка"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-diff
     LABEL "&Разница"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-export
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт".

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 3.13 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр строки".

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1 TOOLTIP "Предыдущая поставка"
     BGCOLOR 8 .

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1 TOOLTIP "Предыдущая поставка"
     BGCOLOR 8 .

DEFINE BUTTON b-scl
     LABEL "&Шкала"
     SIZE 10 BY 1 TOOLTIP "Признаки товара".

DEFINE BUTTON B-trn
     LABEL "Просмотр накл"
     SIZE 19 BY 1 TOOLTIP "Просмотр накладной".

DEFINE VARIABLE abbr-base AS CHARACTER FORMAT "X(256)":U
     LABEL "Баз.Вал."
      VIEW-AS TEXT
     SIZE 4 BY .67 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE abbr-cli AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4.25 BY .67 TOOLTIP "Валюта поставщика"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Факт.время доставки"
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE loc-cli-out-code AS CHARACTER FORMAT "X(256)":U
     LABEL "№ по пост."
      VIEW-AS TEXT
     SIZE 28.63 BY .67 TOOLTIP "Номер по нумерации поставщика"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc-type-doc AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE obj_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52.5 BY .88.

DEFINE VARIABLE post_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 52.5 BY 1.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 62.75 BY 3.04.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-30 FOR
      post-ord-line-rcv,
      Post-goods SCROLLING.

DEFINE QUERY BROWSE-35 FOR
      buf_ord-chain SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      bufs_ord-doc-rcv,
      ub.ord-doc-rcv,
      post-clients,
      obj-clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-30
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-30 Dialog-Frame _FREEFORM
  QUERY BROWSE-30 NO-LOCK DISPLAY
      post-ord-line-rcv.artic      COLUMN-LABEL "Артикул"
      Post-goods.gds-name          COLUMN-LABEL "Наименование"
      Post-goods.unit-base         COLUMN-LABEL "Ед.изм!баз."
      post-ord-line-rcv.qnty       COLUMN-LABEL "Кол-во!(баз.ед.изм.)" FORMAT "->>>>>>>9.<<<"         COLUMN-FGCOLOR 1
      post-ord-line-rcv.unit-cli   COLUMN-LABEL "Ед.изм!пост"
      post-ord-line-rcv.cli-qnty   COLUMN-LABEL "Кол-во!(ед.изм.пост)" FORMAT "->>>>>>>9.<<<"      COLUMN-FGCOLOR 1
      post-ord-line-rcv.price-rubl COLUMN-LABEL "Цена!(нац.вал.)"      FORMAT "->>>>>>>>>>>>9.99"
      post-ord-line-rcv.price-base COLUMN-LABEL "Цена!(баз.вал.)"      FORMAT "->>>>>>>>>>9.99"
      post-ord-line-rcv.price-cli  COLUMN-LABEL "Цена!(пост-ка)"       FORMAT "->>>>>>>>>>9.99" COLUMN-FGCOLOR 1
      post-ord-line-rcv.sub-par    COLUMN-LABEL "Code39"               FORMAT "x(40)" COLUMN-FGCOLOR 1
      post-ord-line-rcv.line-num   COLUMN-LABEL "№"                    FORMAT ">>>>>>9" COLUMN-FGCOLOR 1
  ENABLE
      post-ord-line-rcv.qnty
      post-ord-line-rcv.cli-qnty
      post-ord-line-rcv.price-cli
      post-ord-line-rcv.line-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 12.63.

DEFINE BROWSE BROWSE-35
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-35 Dialog-Frame _FREEFORM
  QUERY BROWSE-35 NO-LOCK DISPLAY
      buf_ord-chain.rel-doc-code FORMAT "X(16)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-BOX NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 30 BY 2.75 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 16
     B-diff AT ROW 1 COL 76 WIDGET-ID 10
     B-delivery AT ROW 1 COL 86
     B-Help AT ROW 1 COL 96
     BROWSE-35 AT ROW 5.25 COL 36 WIDGET-ID 100
     B-trn AT ROW 5.25 COL 68.5
     b-lkp AT ROW 9.13 COL 1.5 WIDGET-ID 6
     b-scl AT ROW 9.13 COL 11.5 WIDGET-ID 8
     b-export AT ROW 9.13 COL 21.5 WIDGET-ID 4
     BROWSE-30 AT ROW 10.38 COL 1.13 WIDGET-ID 200
     ub.ord-doc-rcv.rcv-code AT ROW 1.25 COL 33 COLON-ALIGNED
          LABEL "Поставка"
           VIEW-AS TEXT
          SIZE 13.63 BY .67
          FGCOLOR 4
     loc-type-doc AT ROW 1.25 COL 53 COLON-ALIGNED
     ub.ord-doc-rcv.doc-code AT ROW 2.13 COL 15.25 COLON-ALIGNED
          LABEL "Заказ"
           VIEW-AS TEXT
          SIZE 15 BY .63 TOOLTIP "Номер заказа"
          FGCOLOR 4
     loc-cli-out-code AT ROW 2.13 COL 44.13 COLON-ALIGNED WIDGET-ID 2
     ub.ord-doc-rcv.cli-code AT ROW 3.08 COL 15.25 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.ord-doc-rcv.cli-type AT ROW 3.08 COL 25.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     post_obj-name AT ROW 3.08 COL 33.5 COLON-ALIGNED NO-LABEL
     obj_obj-name AT ROW 4.25 COL 33.5 COLON-ALIGNED NO-LABEL
     ub.ord-doc-rcv.obj-code AT ROW 4.29 COL 18 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.ord-doc-rcv.obj-type AT ROW 4.29 COL 25.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     ub.ord-doc-rcv.ship-date AT ROW 5.42 COL 15.13 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11.25 BY .67 TOOLTIP "Планируемая дата доставки"
     l-loc-hour AT ROW 6.54 COL 15.25 COLON-ALIGNED
     l-loc-min AT ROW 6.54 COL 20.25 COLON-ALIGNED NO-LABEL
     l-loc-hour-2 AT ROW 6.71 COL 87.38 COLON-ALIGNED
     l-loc-min-2 AT ROW 6.71 COL 92.38 COLON-ALIGNED NO-LABEL
     abbr-cli AT ROW 8.17 COL 25.75 COLON-ALIGNED NO-LABEL
     ub.ord-doc-rcv.exch-rate AT ROW 8.29 COL 30.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
     ub.ord-doc-rcv.exch-scale AT ROW 8.29 COL 43.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     ub.ord-doc-rcv.exch-code AT ROW 8.33 COL 18.13 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 4 BY .67 TOOLTIP "код валюты поставщика"
     abbr-base AT ROW 8.38 COL 73.25 COLON-ALIGNED
     ub.ord-doc-rcv.base-rate AT ROW 8.38 COL 78.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
     ub.ord-doc-rcv.base-scale AT ROW 8.38 COL 91 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     ":" VIEW-AS TEXT
          SIZE 1.25 BY .67 AT ROW 6.71 COL 92
          FGCOLOR 1
     ":" VIEW-AS TEXT
          SIZE 1.25 BY 1 AT ROW 6.33 COL 20.5
          FGCOLOR 1
     RECT-3 AT ROW 5.21 COL 35.5
     SPACE(1.36) SKIP(15.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поставка по заказу".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: bufs_ord-doc-rcv B "SHARED" ? ub ord-doc-rcv
      TABLE: buf_ord-chain B "?" ? ub ord-chain
      TABLE: loc-line-rcv T "?" NO-UNDO ub ord-line-rcv
      TABLE: Obj-clients B "?" ? ub ub.clients
      TABLE: Post-clients B "?" ? ub ub.clients
      TABLE: Post-goods B "?" ? ub ub.goods
      TABLE: post-ord-line-rcv B "?" ? ub ord-line-rcv
      TABLE: rcv_goods B "?" ? ub ub.goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-35 RECT-3 Dialog-Frame */
/* BROWSE-TAB BROWSE-30 b-export Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN abbr-base IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN abbr-cli IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       B-diff:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       b-export:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-export-2:HANDLE.

/* SETTINGS FOR BUTTON B-trn IN FRAME Dialog-Frame
   3                                                                    */
ASSIGN
       BROWSE-30:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* SETTINGS FOR FILL-IN ub.ord-doc-rcv.doc-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN l-loc-hour IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-hour-2 IN FRAME Dialog-Frame
   1 3                                                                  */
/* SETTINGS FOR FILL-IN l-loc-min IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min-2 IN FRAME Dialog-Frame
   1 3                                                                  */
/* SETTINGS FOR FILL-IN loc-cli-out-code IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN loc-type-doc IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN obj_obj-name IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN post_obj-name IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN ub.ord-doc-rcv.rcv-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-30
/* Query rebuild information for BROWSE BROWSE-30
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH post-ord-line-rcv  NO-LOCK
    where bufs_ord-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and
          bufs_ord-doc-rcv.doc-code = post-ord-line-rcv.doc-code ,
EACH Post-goods  NO-LOCK where
     Post-goods.artic      =  post-ord-line-rcv.artic  and
     Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and
     Post-goods.prod-type  =  post-ord-line-rcv.prod-type
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-30 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-35
/* Query rebuild information for BROWSE BROWSE-35
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_ord-chain NO-LOCK

where
          buf_ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and
          buf_ord-chain.doc-type = 'rcv'                  and
          buf_ord-chain.rel-doc-type = 'trn'


INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-35 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bufs_ord-doc-rcv where recid(bufs_ord-doc-rcv) = p-ord-rec no-LOCK,
      first ub.ord-doc-rcv where  recid(ord-doc-rcv) = p-ord-rec no-lock ,
      EACH post-clients WHERE
                      bufs_ord-doc-rcv.cli-code = post-clients.obj-code and
                      bufs_ord-doc-rcv.cli-type = post-clients.obj-type  no-LOCK ,
      EACH obj-clients WHERE
                      bufs_ord-doc-rcv.obj-code = obj-clients.obj-code and
                      bufs_ord-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Поставка по заказу */
DO:
  apply "CHOOSE":u to b-exit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delivery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delivery Dialog-Frame
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame /* Доставка */
DO:
define buffer buf_ord-doc for ub.ord-doc  .
define variable type-mode as character no-undo .

if bufs_ord-doc-rcv.doc-type = "in" then type-mode = "rcv" + {&o-o} .
else do:
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code no-error .
    if not available buf_ord-doc  then do:
       type-mode = "ord" + {&o-o} .
    end.
    else type-mode = "ord" + buf_ord-doc.doc-type .
end.

    run cus/pardeliv.w
      (input        parParentproc
      ,input        {&LOOKUP}
      ,input        type-mode
      ,input        bufs_ord-doc-rcv.obj-type
      ,input        bufs_ord-doc-rcv.obj-code
      ,input        bufs_ord-doc-rcv.cli-type
      ,input        bufs_ord-doc-rcv.cli-code
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


&Scoped-define SELF-NAME B-diff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-diff Dialog-Frame
ON CHOOSE OF B-diff IN FRAME Dialog-Frame /* Разница */
DO:
define variable v-ps as character no-undo .
  if ub.ord-doc-rcv.ord-int2 = integer({&edoc-diff}) then do:
    v-ps = ub.ord-doc-rcv.PS .
    run gbl/notes.w ( input {&lookup} , input-output v-ps ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
next-prev = ?.
apply "end-error":u to self.
return.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Экспорт */
DO:
  run cus/z-tot3.p (parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  find current post-ord-line-rcv no-error.
  if avail post-ord-line-rcv then do:
  doc-mode  = {&lookup} .
    run cus/or-obj.w (
      parParentProc
    , bufs_ord-doc-rcv.host-code
    , recid(post-ord-line-rcv)
    , 2
    , {&lookup}
    , {&lookup}
    , input-output doc-mode
    ) no-error  .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка при корректировке строки поставки"
      view-as alert-box error
    .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
RUN STEP-NEXT IN THIS-PROCEDURE .

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


&Scoped-define SELF-NAME b-scl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scl Dialog-Frame
ON CHOOSE OF b-scl IN FRAME Dialog-Frame /* Шкала */
DO:
  message "Режим недоступен" view-as alert-box information .
  return .
/*
  run cus/rcv-p.p
      (parParentProc
      , recid ( bufs_ord-doc-rcv )
      , recid ( post-ord-line-rcv)
      , recid ( Post-goods)
      , {&Lookup}
      , input post-ord-line-rcv.qnty
      , input post-ord-line-rcv.cli-qnty )
      no-error  .

   if error-status:error then  do:
       message
         vss-workfile vss-revision vss-description skip
         error-status:get-message(1)
         "Ошибка при вызове rcv-p.p"
         view-as alert-box error .
     end.
 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* Просмотр накл */
DO:
if not available buf_ord-chain then return .

    run str/showdoc.p
      (input parparentproc
      ,input buf_ord-chain.rel-doc-code
      ,input ""
      ,input ""
      ,input 0
      ,input true
      ) no-error  .
      if error-status :error then
       message
          "Вернулась из процедуры showdoc.p "
          error-status :get-message(1)
          view-as alert-box error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_mobilscn-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mobilscn-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mobilscn-2 /* Экспорт в Моб.сканер */
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot2.p (input parparentproc , input "rcv" , input "" ,input  ub.ord-doc-rcv.rcv-code ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m___Excel-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m___Excel-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m___Excel-2 /* Экспорт в Excel */
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot3.p ( input parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-30
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */


/*{ gbl/app_help.i &disable_diasize_init=true  &browse-name="Browse-30" &frame-name="frame-A" &proc_frame="dialog-frame" } */
{ gbl/app_help.i  }

{ gbl/f2.i browse-30 goods-recid get_gds-rec  }
&scop frame-name dialog-frame

on F2 of frame {&frame-name}  anywhere do:
 return no-apply.
end.


{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "post-ord-line-rcv.artic"
  &sort-clmn_2    = "Post-goods.gds-name"
  &sort-clmn_3    = "Post-goods.unit-base"
  &sort-clmn_4    = "post-ord-line-rcv.qnty"
  &sort-clmn_5    = "post-ord-line-rcv.unit-cli"
  &sort-clmn_6    = "post-ord-line-rcv.cli-qnty"
  &sort-clmn_7    = "post-ord-line-rcv.price-rubl"
  &sort-clmn_8    = "post-ord-line-rcv.price-base"
  &sort-clmn_9    = "post-ord-line-rcv.price-cli"
  &sort-clmn_10   = "post-ord-line-rcv.line-num"
  &label-clmn_1   = "'Артикул'"
  &label-clmn_2   = "'Наименование'"
  &label-clmn_3   = "'Ед.изм!баз.'"
  &label-clmn_4   = "'Кол-во!(баз.ед.изм.)'"
  &label-clmn_5   = "'Ед.изм!пост'"
  &label-clmn_6   = "'Кол-во!(ед.изм.пост)'"
  &label-clmn_7   = "'Цена!(нац.вал.)'"
  &label-clmn_8   = "'Цена!(баз.вал.)'"
  &label-clmn_9   = "'Цена!(пост-ка)'"
  &label-clmn_10  = "'№'"
  &open-query     = "{&OPEN-QUERY-BROWSE-30-sort} BY ~{&sort-clmn_~{&clmn_num~}~} ."
  &open-query-otherwise = "run openbr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "yes" }

ASSIGN
  b-export:POPUP-MENU IN FRAME {&frame-name}  = MENU m-export-2:HANDLE
  b-export:MENU-MOUSE = 1.

next-prev = yes.
n-p: do while next-prev :

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   find first bufs_ord-doc-rcv no-lock  where recid(bufs_ord-doc-rcv) = p-ord-rec  no-error .
     if not available bufs_ord-doc-rcv then do:
        next-prev = ?.
        return error.
        end.

  Post-goods.gds-name:resizable in browse {&browse-name}  = true .

  run input-p in this-procedure no-error .
  run enable_ui in this-procedure no-error .
  if bufs_ord-doc-rcv.ord-int2 = integer({&edoc-diff})  then
     display B-diff with frame {&frame-name} .
  else hide  B-diff in frame {&frame-name} .

  { gbl/mv-clmn.i
  &ext-col = 10
  &frame-name = "{&frame-name}"
  &browse-name = "BROWSE-30"
  &start-column = "2"
  }

  WAIT-FOR GO OF FRAME  dialog-frame  .
END.
END.
run disable_ui  in this-procedure no-error .

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY loc-type-doc loc-cli-out-code post_obj-name obj_obj-name l-loc-hour
          l-loc-min l-loc-hour-2 l-loc-min-2 abbr-cli abbr-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.ord-doc-rcv THEN
    DISPLAY ub.ord-doc-rcv.rcv-code ub.ord-doc-rcv.doc-code
          ub.ord-doc-rcv.cli-code ub.ord-doc-rcv.cli-type
          ub.ord-doc-rcv.obj-code ub.ord-doc-rcv.obj-type
          ub.ord-doc-rcv.ship-date ub.ord-doc-rcv.exch-rate
          ub.ord-doc-rcv.exch-scale ub.ord-doc-rcv.exch-code
          ub.ord-doc-rcv.base-rate ub.ord-doc-rcv.base-scale
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-prev b-next B-diff B-delivery B-Help RECT-3 BROWSE-35 B-trn
         b-lkp b-scl b-export BROWSE-30 ub.ord-doc-rcv.rcv-code loc-type-doc
         ub.ord-doc-rcv.doc-code loc-cli-out-code ub.ord-doc-rcv.cli-code
         ub.ord-doc-rcv.cli-type post_obj-name obj_obj-name
         ub.ord-doc-rcv.obj-code ub.ord-doc-rcv.obj-type
         ub.ord-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2
         abbr-cli ub.ord-doc-rcv.exch-rate ub.ord-doc-rcv.exch-scale
         ub.ord-doc-rcv.exch-code abbr-base ub.ord-doc-rcv.base-rate
         ub.ord-doc-rcv.base-scale
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

  OPEN QUERY  BROWSE-30 {&QUERY-STRING-BROWSE-30} by post-ord-line-rcv.line-num.
  {&OPEN-QUERY-BROWSE-35}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get_gds-rec Dialog-Frame
PROCEDURE get_gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if not available Post-goods then return .
gds-rec = recid(Post-goods) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE input-p Dialog-Frame
PROCEDURE input-p :
do
 on error undo, return error return-value
 :

 ASSIGN
  v-deliv-type-code     =  bufs_ord-doc-rcv.deliv-type-code
  v-point-obj-code      =  bufs_ord-doc-rcv.obj-point-code
  v-point-cli-code      =  bufs_ord-doc-rcv.cli-point-code
  v-point-obj-db-num    =  bufs_ord-doc-rcv.obj-point-db-num
  v-point-cli-db-num    =  bufs_ord-doc-rcv.cli-point-db-num
  v-transport-host-code      =  bufs_ord-doc-rcv.transport-host-code
  v-transport-cli-type      =  bufs_ord-doc-rcv.transport-cli-type
  v-transport-cli-code      =  bufs_ord-doc-rcv.transport-cli-code
  v-transport-contract  =  bufs_ord-doc-rcv.transport-contract
  v-transport-condition =  bufs_ord-doc-rcv.transport-condition
  v-transport-value     =  bufs_ord-doc-rcv.transport-value
  v-transport-sum       =  bufs_ord-doc-rcv.sum-ship
  v-transport-vat       =  bufs_ord-doc-rcv.transport-vat
  .

define buffer b_trn-doc for ub.trn-doc .

find first post-clients no-lock where
            post-clients.obj-code = bufs_ord-doc-rcv.cli-code   and
            post-clients.obj-type = bufs_ord-doc-rcv.cli-type
            no-error .
            post_obj-name = post-clients.obj-name.

find first obj-clients no-lock where
            bufs_ord-doc-rcv.obj-code = obj-clients.obj-code and
            bufs_ord-doc-rcv.obj-type = obj-clients.obj-type
            no-error .
            obj_obj-name = obj-clients.obj-name.

for each ub.ord-chain no-lock where
          ub.ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and
          ub.ord-chain.doc-type = 'rcv'                  and
          ub.ord-chain.rel-doc-type = 'trn'
          :

end.

find first ub.currency no-lock   where ub.currency.curr-code = bufs_ord-doc-rcv.EXCH-CODE no-error.
  if available ub.currency then abbr-cli = ub.currency.curr-abbr .


define variable   p-exch-rate  as decimal   no-undo .
define variable   p-exch-scale as decimal   no-undo .
{ gbl/exchrate.i
  base-code
  today
  p-exch-rate
  p-exch-scale
  abbr-base }


loc-doc-type = bufs_ord-doc-rcv.doc-type.

Assign
   loc-time       = string( bufs_ord-doc-rcv.ship-time ,"HH:MM")
   loc-time-2     = string( bufs_ord-doc-rcv.fact-ship-time ,"HH:MM")
   l-loc-hour     = integer (entry(1,loc-time,":"))
   l-loc-min      = integer (entry(2,loc-time,":"))
   l-loc-hour-2   = integer (entry(1,loc-time-2,":"))
   l-loc-min-2    = integer (entry(2,loc-time-2,":"))

   loc-type-doc    = IF (bufs_ord-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр")
   loc-base-rate   = bufs_ord-doc-rcv.base-rate
   loc-base-scale  = bufs_ord-doc-rcv.base-scale
   loc-exch-code   = bufs_ord-doc-rcv.exch-code
   loc-exch-rate   = bufs_ord-doc-rcv.exch-rate
   loc-exch-scale  = bufs_ord-doc-rcv.exch-scale
   loc-cli-out-code =  entry(1,bufs_ord-doc-rcv.sub-par,{&delim-par})
   no-error .

   assign frame {&frame-name}:title  = "ПОСТАВКА " + bufs_ord-doc-rcv.rcv-code + " - " + {&lookup} .

  assign
    post-ord-line-rcv.qnty :read-only      in browse BROWSE-30 = true
    post-ord-line-rcv.cli-qnty:read-only   in browse browse-30 = true
    post-ord-line-rcv.price-cli:read-only  in browse browse-30 = true
    post-ord-line-rcv.line-num:read-only   in browse browse-30 = true.

   enable b-trn  with frame  {&frame-name} .

  view frame {&frame-name}  .
  display  {&browse-name} with frame  {&frame-name}.
  {&OPEN-QUERY-{&BROWSE-NAME}}
  find first ub.goods no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE look-trn-all Dialog-Frame
PROCEDURE look-trn-all :
do
 on error undo, return error return-value
 :


  display  browse-30 with frame  {&frame-name}.
  {&OPEN-QUERY-BROWSE-30}
  find first ub.goods  no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .
end.
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
 do
 on error undo, return error return-value
 :

{&OPEN-QUERY-{&BROWSE-NAME}}
end.
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
 on error undo, return error return-value
 :

if valid-handle (br-rcv-handle) then do:
  g#log = br-rcv-handle:select-next-row().
  if not g#log then message "Это последний документ списка.".
end.
    doc-rec = recid ( bufs_ord-doc-rcv ).
    p-ord-rec = recid ( bufs_ord-doc-rcv ).
    next-prev = true .
    line-rec = ? .  /* чтоб не терять время на reposition  при входе в документ */
    prt-rec  = ? .  /* чтоб не терять время на reposition  при входе в документ */


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
 on error undo, return error return-value
 :

if valid-handle (br-rcv-handle) then do:
  g#log = br-rcv-handle:select-prev-row().
  if not g#log then message "Это первый документ списка.".
end.
doc-rec   = recid ( bufs_ord-doc-rcv ) .
p-ord-rec = recid ( bufs_ord-doc-rcv ) .
next-prev = true .
line-rec = ?. /* чтоб не терять время на reposition  при входе в документ */
prt-rec = ?.  /* чтоб не терять время на reposition  при входе в документ */

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME