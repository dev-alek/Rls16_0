&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_ord-chain FOR ub.ord-chain.
DEFINE TEMP-TABLE loc-doc-rcv NO-UNDO LIKE ub.ord-doc-rcv.
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

Форма редактирования поставки

Автор: Чернова Светлана Александровна
Дата создания: 26/03/02
Author: Svetlana Chernova
Creation date: 26/03/02

*/

define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-ord-rec       as recid no-undo .
define input  parameter p-mode          as integer no-undo .
define input  parameter list-mode       as character no-undo .
define input  parameter line-mode       as character no-undo .
define input-output parameter  doc-mode          as character no-undo .
/*
p-mode
1- Добавить новую поставку
2- Изменить сразу новый
3- Изменить существ новый и поставку
*/



define SHARED variable x-make-avto as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования поставки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/library.i }
{ str/lib-trn.i }
{ cus/df-zakaz.i new }
{ cus/ord-lib.i  def }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ cus/ord-lib.i  create-chain }
{ cus/vqntyrcv.i }

define variable var-report-r-b as character no-undo .
{ gbl/curr-r-b.i  var-report-r-b }
define variable  type-pr  as widget-handle.
define buffer b-ord-line for ub.ord-line-rcv  .
define buffer buf_trn-doc for ub.trn-doc  .

define variable p-g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .

define variable prt-mode          as character no-undo .
define variable doc-rec           as recid no-undo .
define variable line-rec          as recid no-undo . /* - */
define variable gds-rec           as recid no-undo . /* - */
define variable prt-rec           as recid no-undo . /* - */
define variable g#log             as logical   no-undo .
define variable g#stat            as character no-undo .
define variable g#type            as character no-undo .
define variable g#internal        as logical   no-undo .
define variable g#mainmenu-handle as handle no-undo .
define variable base-code         as integer   no-undo .
define variable loc-cli-base-rate as decimal no-undo.
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#mainmenu-handle = parParentProc
.
{ gbl/hostname.i store-type store-code  p-host-code p-g#host-name }
{ gbl/basecode.i p-host-code base-code }
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .

define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code   as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .


define variable loc-time as char no-undo   .
define variable loc-time-2 as char no-undo .
define variable sort-column-name as character no-undo .
define variable kk like ub.goods.cli-base-rate no-undo .


if p-mode = 1 or p-mode = 3  then do:
   find first ub.ord-doc-rcv no-lock  where recid(ub.ord-doc-rcv) = p-ord-rec .
end.
if p-mode = 2 then do:
if doc-mode = {&lookup} and line-mode = {&lookup} then do:
    find first ub.ord-line-rcv no-lock  where recid(ub.ord-line-rcv) = p-ord-rec no-error .
    find first ub.ord-doc-rcv  no-lock  where ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code  no-error .
    find first b-ord-line   no-lock  where recid(b-ord-line) = p-ord-rec no-error .
  end.
  else do:
    find first ub.ord-line-rcv  exclusive-lock    where recid(ub.ord-line-rcv) = p-ord-rec no-error .
    find first ub.ord-doc-rcv   exclusive-lock    where ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code  no-error .
    find first b-ord-line    exclusive-lock    where recid(b-ord-line) = p-ord-rec no-error .
  end.
end.

if not available  ub.ord-doc-rcv  then do:
   return error.
end.
if not (available  ub.ord-doc-rcv and avail ub.ord-doc-rcv)  and p-mode = 2 then do:
   return error.
end.
create loc-doc-rcv.
buffer-copy ub.ord-doc-rcv to loc-doc-rcv  .

define buffer bufi_ord-doc for ub.ord-doc  .
find first bufi_ord-doc no-lock where
           bufi_ord-doc.doc-code = ub.ord-doc-rcv.doc-code no-error .
if available bufi_ord-doc then do:
   g#stat  = bufi_ord-doc.status_ .
   g#type  = bufi_ord-doc.doc-type.
end.


if p-mode = 2 then do:
  create loc-line-rcv.
  buffer-copy ub.ord-line-rcv to loc-line-rcv.
end.

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
&Scoped-define INTERNAL-TABLES post-ord-line-rcv Post-goods ub.doc-line ~
buf_ord-chain loc-doc-rcv loc-line-rcv post-clients obj-clients ub.goods

/* Definitions for BROWSE BROWSE-30                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-30 post-ord-line-rcv.artic Post-goods.gds-name Post-goods.unit-base post-ord-line-rcv.qnty post-ord-line-rcv.unit-cli post-ord-line-rcv.cli-qnty post-ord-line-rcv.price-rubl post-ord-line-rcv.price-base post-ord-line-rcv.price-cli post-ord-line-rcv.line-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-30 post-ord-line-rcv.cli-qnty ~
post-ord-line-rcv.price-cli ~
post-ord-line-rcv.line-num
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-30 post-ord-line-rcv
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-30 post-ord-line-rcv
&Scoped-define SELF-NAME BROWSE-30
&Scoped-define QUERY-STRING-BROWSE-30 FOR EACH post-ord-line-rcv ~
      where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and ~
            post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock, ~
        each post-goods where   ~
             post-goods.artic  =  post-ord-line-rcv.artic  and    ~
             post-goods.prod-code  =  post-ord-line-rcv.prod-code  and    ~
             post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock ~
             by post-ord-line-rcv.line-num
&Scoped-define OPEN-QUERY-BROWSE-30 OPEN QUERY {&SELF-NAME}  FOR EACH post-ord-line-rcv ~
      where post-ord-line-rcv.rcv-code = loc-doc-rcv.rcv-code and ~
            post-ord-line-rcv.doc-code = loc-doc-rcv.doc-code no-lock, ~
        each post-goods where   ~
             post-goods.artic  =  post-ord-line-rcv.artic  and    ~
             post-goods.prod-code  =  post-ord-line-rcv.prod-code  and    ~
             post-goods.prod-type  =  post-ord-line-rcv.prod-type   no-lock ~
             by post-ord-line-rcv.line-num .
&Scoped-define TABLES-IN-QUERY-BROWSE-30 post-ord-line-rcv Post-goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-30 post-ord-line-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-30 Post-goods


/* Definitions for BROWSE BROWSE-32                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-32 post-ord-line-rcv.artic Post-goods.gds-name Post-goods.unit-base post-ord-line-rcv.qnty ub.doc-line.doc-qnty ub.doc-line.fact-qnty post-ord-line-rcv.unit-cli post-ord-line-rcv.cli-qnty ub.doc-line.cli-qnty post-ord-line-rcv.price-rubl ub.doc-line.price-rubl post-ord-line-rcv.price-base ub.doc-line.price-base post-ord-line-rcv.price-cli ub.doc-line.price-cli post-ord-line-rcv.line-num ub.doc-line.cli-base-rate
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-32 post-ord-line-rcv.cli-qnty ~
post-ord-line-rcv.price-cli ~
post-ord-line-rcv.line-num
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-32 post-ord-line-rcv
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-32 post-ord-line-rcv
&Scoped-define SELF-NAME BROWSE-32
&Scoped-define QUERY-STRING-BROWSE-32 FOR EACH post-ord-line-rcv where loc-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and loc-doc-rcv.doc-code = post-ord-line-rcv.doc-code NO-LOCK, ~
             EACH Post-goods where             Post-goods.artic  =  post-ord-line-rcv.artic  and             Post-goods.prod-code  =  post-ord-line-rcv.prod-code and             Post-goods.prod-type   =  post-ord-line-rcv.prod-type   NO-LOCK, ~
             EACH ub.doc-line WHERE ub.doc-line.artic = post-ord-line-rcv.artic   AND ub.doc-line.prod-code = post-ord-line-rcv.prod-code   AND ub.doc-line.prod-type = post-ord-line-rcv.prod-type   AND ub.doc-line.doc-code = loc-doc-rcv.trn-code OUTER-JOIN NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-32 OPEN QUERY {&SELF-NAME} FOR EACH post-ord-line-rcv where loc-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and loc-doc-rcv.doc-code = post-ord-line-rcv.doc-code NO-LOCK, ~
             EACH Post-goods where             Post-goods.artic  =  post-ord-line-rcv.artic  and             Post-goods.prod-code  =  post-ord-line-rcv.prod-code and             Post-goods.prod-type   =  post-ord-line-rcv.prod-type   NO-LOCK, ~
             EACH ub.doc-line WHERE ub.doc-line.artic = post-ord-line-rcv.artic   AND ub.doc-line.prod-code = post-ord-line-rcv.prod-code   AND ub.doc-line.prod-type = post-ord-line-rcv.prod-type   AND ub.doc-line.doc-code = loc-doc-rcv.trn-code OUTER-JOIN NO-LOCK  .
&Scoped-define TABLES-IN-QUERY-BROWSE-32 post-ord-line-rcv Post-goods ~
doc-line
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-32 post-ord-line-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-32 Post-goods
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-32 ub.doc-line


/* Definitions for BROWSE BROWSE-37                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-37 buf_ord-chain.rel-doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-37
&Scoped-define SELF-NAME BROWSE-37
&Scoped-define QUERY-STRING-BROWSE-37 FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-37 OPEN QUERY {&SELF-NAME} FOR EACH buf_ord-chain NO-LOCK where                                  buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and                                  buf_ord-chain.doc-type = 'rcv'                  and                                  buf_ord-chain.rel-doc-type = 'trn'   INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-37 buf_ord-chain
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-37 buf_ord-chain


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-37}
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH loc-doc-rcv , ~
             EACH loc-line-rcv where       loc-doc-rcv.rcv-code = loc-line-rcv.rcv-code and loc-doc-rcv.doc-code = loc-line-rcv.doc-code  OUTER-JOIN, ~
             EACH post-clients WHERE       loc-doc-rcv.cli-code = post-clients.obj-code and loc-doc-rcv.cli-type = post-clients.obj-type  no-LOCK , ~
             EACH obj-clients WHERE        loc-doc-rcv.obj-code = obj-clients.obj-code and  loc-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK, ~
             each ub.goods where              loc-line-rcv.artic = ub.goods.artic and             loc-line-rcv.prod-code = ub.goods.prod-code and                       loc-line-rcv.prod-type  = ub.goods.prod-type no-lock
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH loc-doc-rcv , ~
             EACH loc-line-rcv where       loc-doc-rcv.rcv-code = loc-line-rcv.rcv-code and loc-doc-rcv.doc-code = loc-line-rcv.doc-code  OUTER-JOIN, ~
             EACH post-clients WHERE       loc-doc-rcv.cli-code = post-clients.obj-code and loc-doc-rcv.cli-type = post-clients.obj-type  no-LOCK , ~
             EACH obj-clients WHERE        loc-doc-rcv.obj-code = obj-clients.obj-code and  loc-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK, ~
             each ub.goods where              loc-line-rcv.artic = ub.goods.artic and             loc-line-rcv.prod-code = ub.goods.prod-code and                       loc-line-rcv.prod-type  = ub.goods.prod-type no-lock.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame loc-doc-rcv loc-line-rcv ~
post-clients obj-clients ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame loc-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame loc-line-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame post-clients
&Scoped-define FOURTH-TABLE-IN-QUERY-Dialog-Frame obj-clients
&Scoped-define FIFTH-TABLE-IN-QUERY-Dialog-Frame ub.goods


/* Definitions for FRAME FRAME-A                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-A ~
    ~{&OPEN-QUERY-BROWSE-30}

/* Definitions for FRAME FRAME-B                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-B ~
    ~{&OPEN-QUERY-BROWSE-32}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS loc-doc-rcv.obj-code loc-doc-rcv.obj-type ~
loc-doc-rcv.ship-date loc-line-rcv.price-cli loc-line-rcv.cli-qnty ~
loc-line-rcv.cli-base-rate loc-doc-rcv.rcv-code loc-doc-rcv.doc-code ~
loc-doc-rcv.base-rate loc-doc-rcv.base-scale loc-doc-rcv.exch-rate ~
loc-doc-rcv.exch-scale loc-line-rcv.artic loc-line-rcv.prod-type ~
loc-line-rcv.prod-code ub.goods.gds-name loc-line-rcv.unit-cli ub.goods.unit-base
&Scoped-define ENABLED-TABLES loc-doc-rcv loc-line-rcv ub.goods
&Scoped-define FIRST-ENABLED-TABLE loc-doc-rcv
&Scoped-define SECOND-ENABLED-TABLE loc-line-rcv
&Scoped-define THIRD-ENABLED-TABLE ub.goods
&Scoped-Define ENABLED-OBJECTS B-OK B-exit B-stop B-delivery B-Help RECT-1 ~
RECT-3 loc-cli-out-code BROWSE-37 B-create-trn B-trn r-obj B-trn-3 ~
l-loc-hour l-loc-min B-trn-2 B-trn-4 r-curr loc-type-doc post_obj-name ~
obj_obj-name abbr-base abbr-cli
&Scoped-Define DISPLAYED-FIELDS loc-doc-rcv.cli-code loc-doc-rcv.cli-type ~
loc-doc-rcv.obj-code loc-doc-rcv.obj-type loc-doc-rcv.ship-date ~
loc-doc-rcv.exch-code loc-line-rcv.price-cli loc-line-rcv.cli-qnty ~
loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty ~
loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc ~
loc-doc-rcv.rcv-code loc-doc-rcv.doc-code loc-doc-rcv.base-rate ~
loc-doc-rcv.base-scale loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale ~
loc-line-rcv.artic loc-line-rcv.prod-type loc-line-rcv.prod-code ~
goods.gds-name loc-line-rcv.unit-cli ub.goods.unit-base
&Scoped-define DISPLAYED-TABLES loc-doc-rcv loc-line-rcv ub.goods
&Scoped-define FIRST-DISPLAYED-TABLE loc-doc-rcv
&Scoped-define SECOND-DISPLAYED-TABLE loc-line-rcv
&Scoped-define THIRD-DISPLAYED-TABLE ub.goods
&Scoped-Define DISPLAYED-OBJECTS loc-cli-out-code l-loc-hour l-loc-min ~
l-loc-hour-2 l-loc-min-2 loc-type-doc post_obj-name obj_obj-name abbr-base ~
abbr-cli

/* Custom List Definitions                                              */
/* doc-list,line-list,trn-list,List-4,List-5,List-6                     */
&Scoped-define doc-list loc-cli-out-code loc-doc-rcv.cli-code ~
loc-doc-rcv.cli-type loc-doc-rcv.obj-code loc-doc-rcv.obj-type ~
loc-doc-rcv.ship-date l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2 ~
loc-doc-rcv.rcv-code loc-type-doc loc-doc-rcv.doc-code post_obj-name ~
obj_obj-name abbr-base loc-doc-rcv.base-rate loc-doc-rcv.base-scale ~
abbr-cli loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale
&Scoped-define line-list loc-cli-out-code loc-line-rcv.price-cli ~
loc-line-rcv.cli-qnty loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl ~
loc-line-rcv.qnty loc-line-rcv.price-base loc-line-rcv.SLT-pc ~
loc-line-rcv.VAT-pc loc-type-doc loc-doc-rcv.doc-code post_obj-name ~
obj_obj-name
&Scoped-define trn-list B-create-trn B-trn B-trn-3 B-trn-2 B-trn-4 ~
l-loc-hour-2 l-loc-min-2

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-export
       MENU-ITEM m___Excel      LABEL "Экспорт в Excel"
       MENU-ITEM m_mobilscn     LABEL "Экспорт в Моб.сканер".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-create-trn  NO-CONVERT-3D-COLORS
     LABEL "Создать накл"
     SIZE 15.5 BY 1 TOOLTIP "Создать накладную по поставке".

DEFINE BUTTON B-delivery
     LABEL "&Доставка"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 11 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-stop AUTO-GO
     LABEL "Стоп&Цикл"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-trn
     LABEL "Просмотр накл"
     SIZE 15.5 BY 1 TOOLTIP "Просмотр накладной".

DEFINE BUTTON B-trn-2
     LABEL "Показать накл"
     SIZE 15.5 BY 1 TOOLTIP "Показать накладную рядом с поставкой".

DEFINE BUTTON B-trn-3
     LABEL "Привязать накл"
     SIZE 15.5 BY 1 TOOLTIP "Привязка накладной".

DEFINE BUTTON B-trn-4
     LABEL "Удал Привязку"
     SIZE 15.5 BY 1 TOOLTIP "Удалить связь с накладной".

DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-obj"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

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
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Факт.время доставки"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE loc-cli-out-code AS CHARACTER FORMAT "X(14)":U
     LABEL "№по пост"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "№ поставки по нумерации Поставщика"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-type-doc AS CHARACTER FORMAT "X(4)":U
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 5.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE obj_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 28.75 BY .88.

DEFINE VARIABLE post_obj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 28.75 BY 1.

DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE .88 BY .67
     BGCOLOR 3 FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE 1.13 BY .67
     BGCOLOR 3 FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.999":U INITIAL 0
      VIEW-AS TEXT
     SIZE .75 BY .67
     BGCOLOR 3 FGCOLOR 3  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.75 BY 13.42.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 6.75.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить строку".

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить строку".

DEFINE BUTTON b-export-2
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт в Excel".

DEFINE BUTTON b-flt
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтр".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр строки".

DEFINE BUTTON b-scl
     LABEL "&Шкала"
     SIZE 10 BY 1 TOOLTIP "Признаки товара".

DEFINE BUTTON b-chg-2
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить строку".

DEFINE BUTTON b-del-2
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить строку".

DEFINE BUTTON b-lkp-2
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр строки".

DEFINE BUTTON b-scl-2
     LABEL "&Шкала"
     SIZE 10 BY 1 TOOLTIP "Признаки товара".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-30 FOR
      post-ord-line-rcv,
      Post-goods SCROLLING.

DEFINE QUERY BROWSE-32 FOR
      post-ord-line-rcv,
      Post-goods,
      ub.doc-line SCROLLING.

DEFINE QUERY BROWSE-37 FOR
      buf_ord-chain SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      loc-doc-rcv,
      loc-line-rcv,
      post-clients,
      obj-clients,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-30
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-30 Dialog-Frame _FREEFORM
  QUERY BROWSE-30 NO-LOCK DISPLAY
      post-ord-line-rcv.artic
      Post-goods.gds-name
      Post-goods.unit-base COLUMN-LABEL "Ед.изм!баз."
      post-ord-line-rcv.qnty COLUMN-LABEL "Кол-во!(баз.ед.изм.)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      post-ord-line-rcv.unit-cli COLUMN-LABEL "Ед.изм!пост."
      post-ord-line-rcv.cli-qnty COLUMN-LABEL "Кол-во!(ед.изм.пост)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      post-ord-line-rcv.price-rubl FORMAT "->>>>>>>>>>>>9.999"
      post-ord-line-rcv.price-base FORMAT "->>>>>>>>>>9.999"
      post-ord-line-rcv.price-cli FORMAT "->>>>>>>>>>9.999" COLUMN-FGCOLOR 1
      post-ord-line-rcv.sub-par    COLUMN-LABEL "Code39"               FORMAT "x(40)" COLUMN-FGCOLOR 1
      post-ord-line-rcv.line-num FORMAT ">>>>>>9" COLUMN-FGCOLOR 1
  ENABLE
      post-ord-line-rcv.cli-qnty
      post-ord-line-rcv.line-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 12.

DEFINE BROWSE BROWSE-32
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-32 Dialog-Frame _FREEFORM
  QUERY BROWSE-32 NO-LOCK DISPLAY
      post-ord-line-rcv.artic
      Post-goods.gds-name
      Post-goods.unit-base COLUMN-LABEL "Ед.изм!баз."
      post-ord-line-rcv.qnty COLUMN-LABEL "Кол-во!(баз.ед.изм.)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      ub.doc-line.doc-qnty LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      ub.doc-line.fact-qnty LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.unit-cli COLUMN-LABEL "Ед.изм!пост"
      post-ord-line-rcv.cli-qnty COLUMN-LABEL "Кол-во!(ед.изм.пост)" FORMAT ">>>>>>>9.<<<"
            COLUMN-FGCOLOR 1
      ub.doc-line.cli-qnty LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.price-rubl FORMAT "->>>>>>>>>>>>9.999"
      ub.doc-line.price-rubl LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.price-base FORMAT "->>>>>>>>>>9.999"
      ub.doc-line.price-base LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.price-cli FORMAT "->>>>>>>>>>9.999" COLUMN-FGCOLOR 1
      ub.doc-line.price-cli LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      post-ord-line-rcv.line-num FORMAT ">>>>>>9" COLUMN-FGCOLOR 1
      ub.doc-line.cli-base-rate
  ENABLE
      post-ord-line-rcv.cli-qnty
      post-ord-line-rcv.line-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 12.

DEFINE BROWSE BROWSE-37
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-37 Dialog-Frame _FREEFORM
  QUERY BROWSE-37 NO-LOCK DISPLAY
      buf_ord-chain.rel-doc-code FORMAT "X(16)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-BOX NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 20.5 BY 5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-exit AT ROW 1 COL 12
     B-stop AT ROW 1 COL 22
     B-delivery AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     loc-cli-out-code AT ROW 2.25 COL 44 COLON-ALIGNED WIDGET-ID 2
     loc-doc-rcv.cli-code AT ROW 3 COL 11 COLON-ALIGNED
          LABEL "Поставщик"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     loc-doc-rcv.cli-type AT ROW 3 COL 21.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     r-clients AT ROW 3 COL 27.63
     BROWSE-37 AT ROW 3 COL 61 WIDGET-ID 100
     B-create-trn AT ROW 3 COL 82.25
     B-trn AT ROW 4 COL 82.25
     loc-doc-rcv.obj-code AT ROW 4.21 COL 11 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     loc-doc-rcv.obj-type AT ROW 4.21 COL 21.63 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     r-obj AT ROW 4.21 COL 27.63
     B-trn-3 AT ROW 5 COL 82.25
     loc-doc-rcv.ship-date AT ROW 5.42 COL 15.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11.25 BY 1 TOOLTIP "Планируемая дата доставки"
     l-loc-hour AT ROW 5.5 COL 34 COLON-ALIGNED
     l-loc-min AT ROW 5.5 COL 39 COLON-ALIGNED NO-LABEL
     B-trn-2 AT ROW 6 COL 82.25
     B-trn-4 AT ROW 7 COL 82.25 WIDGET-ID 4
     loc-doc-rcv.exch-code AT ROW 7.96 COL 18 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "код валюты поставщика"
     l-loc-hour-2 AT ROW 7.96 COL 87.88 COLON-ALIGNED
     l-loc-min-2 AT ROW 7.96 COL 92.88 COLON-ALIGNED NO-LABEL
     r-curr AT ROW 8.04 COL 24.25
     loc-line-rcv.price-cli AT ROW 11.17 COL 75.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21.25 BY 1
     loc-line-rcv.cli-qnty AT ROW 11.63 COL 17.88 COLON-ALIGNED
          LABEL "Кол-во в ед.пост"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     loc-line-rcv.cli-base-rate AT ROW 12.17 COL 40.88 COLON-ALIGNED
          LABEL "К/т"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     loc-line-rcv.price-rubl AT ROW 12.21 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 21.5 BY 1
     loc-line-rcv.qnty AT ROW 12.83 COL 17.88 COLON-ALIGNED
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     loc-line-rcv.price-base
          FORMAT ">>>>>>>>>>9.999<<<<"
          AT ROW 13.25 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     loc-line-rcv.SLT-pc AT ROW 14.25 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     loc-line-rcv.VAT-pc AT ROW 15.25 COL 75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     loc-doc-rcv.rcv-code AT ROW 1.25 COL 45.5 COLON-ALIGNED
          LABEL "№ Пост-ки"
           VIEW-AS TEXT
          SIZE 11.5 BY .67
          FGCOLOR 4
     loc-type-doc AT ROW 2.25 COL 4 COLON-ALIGNED
     loc-doc-rcv.doc-code AT ROW 2.25 COL 18.5 COLON-ALIGNED
          LABEL "Заказ №"
           VIEW-AS TEXT
          SIZE 15 BY .63
          FGCOLOR 4
     post_obj-name AT ROW 3 COL 29.25 COLON-ALIGNED NO-LABEL
     obj_obj-name AT ROW 4.17 COL 29.25 COLON-ALIGNED NO-LABEL
     abbr-base AT ROW 7 COL 10.5 COLON-ALIGNED
     loc-doc-rcv.base-rate AT ROW 7 COL 15 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     loc-doc-rcv.base-scale AT ROW 7 COL 27.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     abbr-cli AT ROW 8.17 COL 25.75 COLON-ALIGNED NO-LABEL
     loc-doc-rcv.exch-rate AT ROW 8.17 COL 30.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12 BY .67 TOOLTIP "курс"
     loc-doc-rcv.exch-scale AT ROW 8.17 COL 43.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5 BY .67 TOOLTIP "масштаб"
     loc-line-rcv.artic AT ROW 10.13 COL 1 NO-LABEL
           VIEW-AS TEXT
          SIZE 14.75 BY 1
          BGCOLOR 3 FGCOLOR 15
     loc-line-rcv.prod-type AT ROW 10.13 COL 14 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4.63 BY 1
          BGCOLOR 3 FGCOLOR 15
     loc-line-rcv.prod-code AT ROW 10.13 COL 18.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY 1
          BGCOLOR 3 FGCOLOR 15
    ub.goods.gds-name AT ROW 10.13 COL 29.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 66.88 BY 1
          BGCOLOR 3 FGCOLOR 15
     tot-cli AT ROW 10.17 COL 95.13 COLON-ALIGNED NO-LABEL
     tot-rubl AT ROW 10.21 COL 94.75 COLON-ALIGNED NO-LABEL
     tot-base AT ROW 10.33 COL 95.13 COLON-ALIGNED NO-LABEL
     loc-line-rcv.unit-cli AT ROW 11.88 COL 31.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
    ub.goods.unit-base AT ROW 12.92 COL 31.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     " НАКЛАДНАЯ" VIEW-AS TEXT
          SIZE 11.5 BY .67 AT ROW 2.25 COL 73.5
          BGCOLOR 3 FGCOLOR 15
     ":" VIEW-AS TEXT
          SIZE 1.25 BY 1 AT ROW 5.5 COL 39.25
          FGCOLOR 1
     ":" VIEW-AS TEXT
          SIZE 1.25 BY 1 AT ROW 7.96 COL 93.13
          FGCOLOR 1
     RECT-1 AT ROW 10.04 COL 1.13
     RECT-3 AT ROW 2.25 COL 60.5
     SPACE(0.11) SKIP(14.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поставка по заказу".

DEFINE FRAME FRAME-A
     b-chg AT ROW 1 COL 1
     b-lkp AT ROW 1 COL 11
     b-del AT ROW 1 COL 21
     b-scl AT ROW 1 COL 31
     b-export-2 AT ROW 1 COL 41
     b-flt AT ROW 1 COL 54.5
     BROWSE-30 AT ROW 2 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 9
         SIZE 98 BY 14.21
         TITLE "Строки поставки".

DEFINE FRAME FRAME-B
     b-chg-2 AT ROW 1 COL 1
     b-lkp-2 AT ROW 1 COL 11
     b-del-2 AT ROW 1 COL 21
     b-scl-2 AT ROW 1 COL 31
     BROWSE-32 AT ROW 2 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 9
         SIZE 98 BY 14.33
         TITLE "Строки поставки и накладной".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_ord-chain B "?" ? ub ord-chain
      TABLE: loc-doc-rcv T "?" NO-UNDO ub ub.ord-doc-rcv
      TABLE: loc-line-rcv T "?" NO-UNDO ub ub.ord-line-rcv
      TABLE: Obj-clients B "?" ? ub ub.clients
      TABLE: Post-clients B "?" ? ub ub.clients
      TABLE: Post-goods B "?" ? ub ub.goods
      TABLE: post-ord-line-rcv B "?" ? ub ub.ord-line-rcv
      TABLE: rcv_goods B "?" ? ub ub.goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-37 r-clients Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN abbr-base IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN abbr-cli IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc-line-rcv.artic IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR BUTTON B-create-trn IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON B-trn IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON B-trn-2 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON B-trn-3 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON B-trn-4 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR FILL-IN loc-doc-rcv.base-rate IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc-doc-rcv.base-scale IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc-line-rcv.cli-base-rate IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN loc-doc-rcv.cli-code IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN loc-line-rcv.cli-qnty IN FRAME Dialog-Frame
   2 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN loc-doc-rcv.cli-type IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN loc-doc-rcv.doc-code IN FRAME Dialog-Frame
   1 2 EXP-LABEL                                                        */
/* SETTINGS FOR FILL-IN loc-doc-rcv.exch-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN loc-doc-rcv.exch-rate IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc-doc-rcv.exch-scale IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-hour IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-hour-2 IN FRAME Dialog-Frame
   NO-ENABLE 1 3                                                        */
/* SETTINGS FOR FILL-IN l-loc-min IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min-2 IN FRAME Dialog-Frame
   NO-ENABLE 1 3                                                        */
/* SETTINGS FOR FILL-IN loc-cli-out-code IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN loc-type-doc IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN loc-doc-rcv.obj-code IN FRAME Dialog-Frame
   1 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN loc-doc-rcv.obj-type IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN obj_obj-name IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN post_obj-name IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN loc-line-rcv.price-base IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN loc-line-rcv.price-cli IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN loc-line-rcv.price-rubl IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN loc-line-rcv.qnty IN FRAME Dialog-Frame
   NO-ENABLE 2 EXP-LABEL                                                */
/* SETTINGS FOR BUTTON r-clients IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-clients:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN loc-doc-rcv.rcv-code IN FRAME Dialog-Frame
   1 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN loc-doc-rcv.ship-date IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN loc-line-rcv.SLT-pc IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN tot-base IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tot-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tot-cli IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tot-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tot-rubl IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tot-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN loc-line-rcv.VAT-pc IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FRAME FRAME-A
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-30 b-flt FRAME-A */
ASSIGN
       FRAME FRAME-A:HIDDEN           = TRUE.

ASSIGN
       b-export-2:POPUP-MENU IN FRAME FRAME-A       = MENU m-export:HANDLE.

/* SETTINGS FOR BUTTON b-flt IN FRAME FRAME-A
   NO-ENABLE                                                            */
ASSIGN
       b-flt:HIDDEN IN FRAME FRAME-A           = TRUE.

ASSIGN
       BROWSE-30:NUM-LOCKED-COLUMNS IN FRAME FRAME-A     = 2.

/* SETTINGS FOR FRAME FRAME-B
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-32 b-scl-2 FRAME-B */
ASSIGN
       FRAME FRAME-B:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-30
/* Query rebuild information for BROWSE BROWSE-30
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH post-ord-line-rcv
           where loc-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and
           loc-doc-rcv.doc-code = post-ord-line-rcv.doc-code              NO-LOCK,
      EACH Post-goods where
      Post-goods.artic  =  post-ord-line-rcv.artic  and
   Post-goods.prod-code  =  post-ord-line-rcv.prod-code  and
   Post-goods.prod-type  =  post-ord-line-rcv.prod-type
      NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ","
     _Query            is OPENED
*/  /* BROWSE BROWSE-30 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-32
/* Query rebuild information for BROWSE BROWSE-32
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH post-ord-line-rcv
where loc-doc-rcv.rcv-code = post-ord-line-rcv.rcv-code and
loc-doc-rcv.doc-code = post-ord-line-rcv.doc-code
NO-LOCK,
      EACH Post-goods where
            Post-goods.artic  =  post-ord-line-rcv.artic  and
            Post-goods.prod-code  =  post-ord-line-rcv.prod-code and
            Post-goods.prod-type   =  post-ord-line-rcv.prod-type   NO-LOCK,
      EACH ub.doc-line WHERE ub.doc-line.artic = post-ord-line-rcv.artic
  AND ub.doc-line.prod-code = post-ord-line-rcv.prod-code
  AND ub.doc-line.prod-type = post-ord-line-rcv.prod-type
  AND ub.doc-line.doc-code = loc-doc-rcv.trn-code OUTER-JOIN NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",, OUTER"
     _JoinCode[3]      = "ub.doc-line.artic = post-ord-line-rcv.artic
  AND ub.doc-line.prod-code = post-ord-line-rcv.prod-code
  AND ub.doc-line.prod-type = post-ord-line-rcv.prod-type
  AND ub.doc-line.doc-code = post-ord-line-rcv.doc-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-32 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-37
/* Query rebuild information for BROWSE BROWSE-37
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_ord-chain NO-LOCK where
                                 buf_ord-chain.doc-code = loc-doc-rcv.rcv-code and
                                 buf_ord-chain.doc-type = 'rcv'                  and
                                 buf_ord-chain.rel-doc-type = 'trn'


INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-37 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH loc-doc-rcv ,
      EACH loc-line-rcv where
      loc-doc-rcv.rcv-code = loc-line-rcv.rcv-code and
      loc-doc-rcv.doc-code = loc-line-rcv.doc-code
 OUTER-JOIN,
      EACH post-clients WHERE
                      loc-doc-rcv.cli-code = post-clients.obj-code and
                      loc-doc-rcv.cli-type = post-clients.obj-type  no-LOCK ,
      EACH obj-clients WHERE
                      loc-doc-rcv.obj-code = obj-clients.obj-code and
                      loc-doc-rcv.obj-type = obj-clients.obj-type  no-LOCK,
      each ub.goods where
                      loc-line-rcv.artic = ub.goods.artic and
                      loc-line-rcv.prod-code = ub.goods.prod-code and
                      loc-line-rcv.prod-type  = ub.goods.prod-type no-lock.
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
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME FRAME-A /* Изменить */
DO:

define variable  L-RECID AS RECID NO-UNDO.
find current post-ord-line-rcv no-lock  no-error.
  if avail post-ord-line-rcv then do:
    L-RECID = RECID(post-ord-line-rcv) .
    run cus/or-obj.w
    ( parParentProc
    , p-host-code
    , recid(post-ord-line-rcv)
    , 2
    , {&update}
    , {&update}
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

    g#log =  BROWSE-30:refresh() .
  end.
END.

&scop frame-name frame-a
&scop browse-name browse-30
{ gbl/f2.i browse-30 }
&scop frame-name dialog-frame
assign
  loc-cli-base-rate = if available loc-line-rcv then loc-line-rcv.cli-base-rate else 1.
{ cus/ord-lib.i leave-qnty loc-line-rcv }
&scop frame-name dialog-frame
on F2 of frame dialog-frame anywhere do:
return no-apply.
end.

ON LEAVE OF loc-line-rcv.cli-base-rate IN FRAME dialog-frame  do:
   apply 'LEAVE' to loc-line-rcv.cli-qnty in frame dialog-frame .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME b-chg-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-2 Dialog-Frame
ON CHOOSE OF b-chg-2 IN FRAME FRAME-B /* Изменить */
DO:
DEF VAR L-RECID AS RECID NO-UNDO.
find current post-ord-line-rcv no-error.
    if avail post-ord-line-rcv then do:
    L-RECID = RECID(post-ord-line-rcv) .
   run cus/or-obj.w
   (  parParentProc
    , p-host-code
    , recid(post-ord-line-rcv)
    , 2
    , {&update}
    , {&update}
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
    g#log =  BROWSE-32:refresh() .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME B-create-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-create-trn Dialog-Frame
ON CHOOSE OF B-create-trn IN FRAME Dialog-Frame /* Создать накл */
DO:
/*ddd*/
 define variable g-log as logical   no-undo .
 define variable v-obj-db-num as integer   no-undo .

 define buffer b_ord-doc-rcv for  ub.ord-doc-rcv .
 define buffer buf_ord-doc   for  ub.ord-doc     .
 define buffer buf_doc-line  for  ub.doc-line    .

 define variable v-ord-type as character no-undo .
 define variable v-empty-trn as logical   no-undo .
 define variable v-current-trn as character no-undo .
 define variable varchip-code  as integer   no-undo .

 find first b_ord-doc-rcv no-lock  where b_ord-doc-rcv.rcv-code = loc-doc-rcv.rcv-code  no-error .
 if not available b_ord-doc-rcv then return .

 find first buf_ord-doc no-lock where buf_ord-doc.doc-code   = b_ord-doc-rcv.doc-code no-error .
 if available buf_ord-doc then  v-ord-type = buf_ord-doc.doc-type .
      { gbl/objdbnum.i
        b_ord-doc-rcv.obj-type
        b_ord-doc-rcv.obj-code
        v-obj-db-num }
      if v-cntxt-db-num <> v-obj-db-num then do:
        message "Создание накладных по заказу ОП возможно на БД №" v-obj-db-num view-as alert-box information .
        return .
      end.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_h-wbill':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .
     if avail b_ord-doc-rcv then do:
        if b_ord-doc-rcv.status_ <> {&ord-rcv} then do:
          message "Нельзя сделать накладную на поставку в статусе " caps(b_ord-doc-rcv.status_) view-as alert-box .
          return no-apply.
        end.

        define variable v-is-limit as logical   no-undo .
        run ver-qnty-trn-from-rcv ( input b_ord-doc-rcv.rcv-code , output v-is-limit ) .
        if v-is-limit then do:
            message "Нельзя делать Накладную на Поставку. Система настроена на работу 1:1."
                    view-as alert-box information .
            return no-apply.
        end.

        if b_ord-doc-rcv.doc-type = "in":U and
          ( b_ord-doc-rcv.obj-code = store-code and
            b_ord-doc-rcv.obj-type = store-type )
            then do:
                message "Нельзя сделать накладную на поставку " caps(b_ord-doc-rcv.rcv-code) skip
                "Здесь может быть только внутренний приход"
                view-as alert-box .
                return no-apply.
            end.
        run cus/ord-trn.p ( parParentProc ,  recid(b_ord-doc-rcv) , yes ) no-error .
        assign
          v-current-trn = string(current-value (s-trn-doc, {&db-name_schema})) + "-" +
          (if v-cntxt-db-num-obj = 0 then "" else (string(v-cntxt-obj-code) + substring(v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1))) .
          v-empty-trn   = yes.
        .
        find first buf_trn-doc
             where buf_trn-doc.doc-code = v-current-trn
             no-error .
        if available buf_trn-doc then do:
          for each buf_doc-line
             where buf_doc-line.doc-code = buf_trn-doc.doc-code
             no-lock :
                assign v-empty-trn = no .
             end.
           if v-empty-trn then do:
              message "Созданная накладная не содержит линий и будет удалена!"
              view-as alert-box information title "Внимание!" .
              run str/del-doc.p
                ( input  parParentProc,
                  input  buf_trn-doc.doc-code,
                  input  v-cntxt-db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  v-cntxt-userid,
                  input  buf_trn-doc.doc-code,
                  input  ?,
                  output varchip-code ) .
           end.
        end.
        {&OPEN-QUERY-BROWSE-37}
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME FRAME-A /* Удалить */
DO:
 if avail post-ord-line-rcv then do:
                message "Удалить строку в поставке №" post-ord-line-rcv.rcv-code
                skip
                " По товару "
                post-ord-line-rcv.artic
                post-ord-line-rcv.prod-type
                post-ord-line-rcv.prod-code
                view-as alert-box
                        question buttons yes-no title "Вопрос" update g#log.
                    if g#log then do:
                            find current post-ord-line-rcv exclusive-lock .
                             delete post-ord-line-rcv .
                            {&OPEN-QUERY-{&BROWSE-NAME}}
                     end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME b-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-2 Dialog-Frame
ON CHOOSE OF b-del-2 IN FRAME FRAME-B /* Удалить */
DO:
 if avail post-ord-line-rcv then do:
                message "Удалить строку в поставке №" post-ord-line-rcv.rcv-code
                skip
                " По товару "
                post-ord-line-rcv.artic
                post-ord-line-rcv.prod-type
                post-ord-line-rcv.prod-code
                view-as alert-box
                        question buttons yes-no title "Вопрос" update g#log.
                    if g#log then do:
                            find current post-ord-line-rcv exclusive-lock.
                             delete post-ord-line-rcv .
                            {&OPEN-QUERY-{&BROWSE-NAME}}
                     end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME B-delivery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delivery Dialog-Frame
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame /* Доставка */
DO:
define buffer buf_ord-doc for ub.ord-doc  .
define variable type-mode as character no-undo .

if loc-doc-rcv.doc-type = "in" then type-mode = "rcv" + {&o-o} .
else do:
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = loc-doc-rcv.doc-code no-error .
    if not available buf_ord-doc  then do:
       type-mode = "ord" + {&o-o} .
    end.
    else do:
      type-mode = "ord" + buf_ord-doc.doc-type .
      if buf_ord-doc.doc-type = {&f-p} then do:
         type-mode = "rcv" + buf_ord-doc.doc-type .
      end.
    end.
end.

    run cus/pardeliv.w
      (input        parParentproc
      ,input        doc-mode
      ,input        type-mode
      ,input        loc-doc-rcv.obj-type
      ,input        loc-doc-rcv.obj-code
      ,input        loc-doc-rcv.cli-type
      ,input        loc-doc-rcv.cli-code
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


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Отмена */
DO:
 doc-mode = "cancel":U.
 x-make-avto = 2 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME b-export-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export-2 Dialog-Frame
ON CHOOSE OF b-export-2 IN FRAME FRAME-A /* Экспорт */
DO:
   run cus/z-tot3.p ( parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME FRAME-A /* Просмотр */
DO:
  find current post-ord-line-rcv no-error.
  if avail post-ord-line-rcv then do:
    run cus/or-obj.w
    ( parParentProc
    , p-host-code
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


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME b-lkp-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp-2 Dialog-Frame
ON CHOOSE OF b-lkp-2 IN FRAME FRAME-B /* Просмотр */
DO:
  find current post-ord-line-rcv no-error.
  if avail post-ord-line-rcv then do:
    run cus/or-obj.w
    ( parParentProc
    , p-host-code
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


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Ввод */
DO:
define variable  l-ok as logical no-undo .
  x-make-avto = 2 .
  if type-pr <> ? then do:
     case  type-pr:screen-value :
     when "1" then x-make-avto = 1 .
     when "4" then x-make-avto = 4 .
     when "2" then x-make-avto = 2  .
     when "3" then x-make-avto = 3 .
     end case.
  end .

  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
       message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
       return no-apply.
     end.

if p-mode = 1 then do:
  assign frame  {&frame-name} {&doc-list}.
      BUFFER-COPY loc-doc-rcv to ub.ord-doc-rcv.
      ub.ord-doc-rcv.ship-time = ( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 ) .
      ub.ord-doc-rcv.fact-ship-time = ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 ) .
      ub.ord-doc-rcv.sub-par        = trim(loc-cli-out-code) + {&delim-par} + trim(vat_type) + {&delim-par} .
end.

if p-mode = 2 then  do:
    run ver-value in this-procedure no-error .
    if error-status :error then return no-apply.
    assign frame  {&frame-name} {&line-list}.
    buffer-copy loc-line-rcv to ub.ord-line-rcv.
end.

if p-mode = 3 then do:
  assign frame  {&frame-name} {&doc-list}.
      BUFFER-COPY loc-doc-rcv to ub.ord-doc-rcv.
      ub.ord-doc-rcv.ship-time = ( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 ) .
      ub.ord-doc-rcv.fact-ship-time = ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 ) .
      ub.ord-doc-rcv.sub-par          = trim(loc-cli-out-code) + {&delim-par} + trim(vat_type) + {&delim-par}  .

      if can-find (first post-ord-line-rcv where
          post-ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
          post-ord-line-rcv.qnty = 0) then do:
          l-ok = false .
          message "Есть нулевые строки в поставке! Удалять их ?" view-as alert-box question buttons yes-no update
          l-ok  .
          if l-ok = true  then do:
             for each post-ord-line-rcv exclusive-lock where
                      post-ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
                      post-ord-line-rcv.qnty = 0 :
             delete post-ord-line-rcv.
             end.
          end.
          end.
      if not can-find (first post-ord-line-rcv where
          post-ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code ) then do:

          find current ub.ord-doc-rcv  exclusive-lock   no-error .
          if available ub.ord-doc-rcv then do:
             message "Нeт ни одной записи в поставке! Удаляем ее" view-as alert-box information .
             delete ub.ord-doc-rcv.
             end.

          end.
end.
if available ub.ord-doc-rcv then do:
ASSIGN
    ub.ord-doc-rcv.deliv-type-code    = v-deliv-type-code
    ub.ord-doc-rcv.obj-point-code     = v-point-obj-code
    ub.ord-doc-rcv.cli-point-code     = v-point-cli-code
    ub.ord-doc-rcv.obj-point-db-num   = v-point-obj-db-num
    ub.ord-doc-rcv.cli-point-db-num   = v-point-cli-db-num
    ub.ord-doc-rcv.transport-host-code= v-transport-host-code
    ub.ord-doc-rcv.transport-cli-type = v-transport-cli-type
    ub.ord-doc-rcv.transport-cli-code = v-transport-cli-code
    ub.ord-doc-rcv.transport-contract = v-transport-contract
    ub.ord-doc-rcv.transport-condition= v-transport-condition
    ub.ord-doc-rcv.transport-value    = v-transport-value
    ub.ord-doc-rcv.sum-ship           = v-transport-sum
    ub.ord-doc-rcv.transport-vat      = v-transport-vat
  .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME b-scl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scl Dialog-Frame
ON CHOOSE OF b-scl IN FRAME FRAME-A /* Шкала */
OR CHOOSE OF B-SCL-2 IN FRAME FRAME-B
DO:
  message "Режим недоступен" view-as alert-box information .
  return .
  /*
  run cus/rcv-p.p
      (parParentProc
      , ?
      , recid ( post-ord-line-rcv)
      , recid ( Post-goods)
      , (If line-mode = {&update}  then  {&prt-def}  else  {&Lookup}  )
      , input post-ord-line-rcv.qnty
      , input post-ord-line-rcv.cli-qnty )
      no-error  .

    if error-status:error then  do:
       message
         vss-workfile vss-revision vss-description skip
         error-status:get-message(1)
         "Ошибка при вызове rcv-pn.p"
         view-as alert-box error .
     end.
     */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME B-stop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-stop Dialog-Frame
ON CHOOSE OF B-stop IN FRAME Dialog-Frame /* СтопЦикл */
DO:
doc-mode = "stopcycle":U.
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


&Scoped-define SELF-NAME B-trn-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-2 Dialog-Frame
ON CHOOSE OF B-trn-2 IN FRAME Dialog-Frame /* Показать накл */
DO:
if not available buf_ord-chain then return .

find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code no-error .
      if available   buf_trn-doc   then DO:
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_lookup':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g#log
                }
              end.
              when {&expense}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_lookup':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g#log
                }
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_lookup':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g#log
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_lookup':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g#log
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_lookup':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  g#log
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return no-apply .
              end.
            end case .
            if not g#log then   return no-apply.
            run look-trn-all in this-procedure no-error.
      end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-3 Dialog-Frame
ON CHOOSE OF B-trn-3 IN FRAME Dialog-Frame /* Привязать накл */
DO:

define buffer b_ord-doc-rcv for  ub.ord-doc-rcv .
define buffer buf_ord-doc   for  ub.ord-doc     .
define variable v-ord-type as character no-undo .
define variable v-obj-db-num as integer   no-undo .

 find first b_ord-doc-rcv no-lock  where b_ord-doc-rcv.rcv-code = loc-doc-rcv.rcv-code  no-error .
 if not available b_ord-doc-rcv then return .

 find first buf_ord-doc no-lock where buf_ord-doc.doc-code   = b_ord-doc-rcv.doc-code no-error .
 if available buf_ord-doc then  v-ord-type = buf_ord-doc.doc-type .

      { gbl/objdbnum.i
        b_ord-doc-rcv.obj-type
        b_ord-doc-rcv.obj-code
        v-obj-db-num }

      if v-cntxt-db-num <> v-obj-db-num then do:
        message "Привязка накладных к заказу возможно на БД №" v-obj-db-num view-as alert-box information .
        return .
      end.


      define variable  v-is-limit as logical   no-undo .
      run ver-qnty-trn-from-rcv ( input b_ord-doc-rcv.rcv-code , output v-is-limit ) .
      if v-is-limit then do:
          message "Нельзя делать Накладную на Поставку. Система настроена на работу 1:1."
                  view-as alert-box information .
          return .
      end.

  run att-trn in this-procedure (recid(b_ord-doc-rcv)) no-error .

{&OPEN-QUERY-BROWSE-37}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-4 Dialog-Frame
ON CHOOSE OF B-trn-4 IN FRAME Dialog-Frame /* Удал Привязку */
DO:

if not available buf_ord-chain then return .

define buffer b_ord-doc-rcv for  ub.ord-doc-rcv .
define buffer buf_ord-doc   for  ub.ord-doc     .
define variable v-ord-type as character no-undo .
define variable v-obj-db-num as integer   no-undo .

 find first b_ord-doc-rcv no-lock  where b_ord-doc-rcv.rcv-code = loc-doc-rcv.rcv-code  no-error .
 if not available b_ord-doc-rcv then return .

 find first buf_ord-doc no-lock where buf_ord-doc.doc-code   = b_ord-doc-rcv.doc-code no-error .
 if available buf_ord-doc then  v-ord-type = buf_ord-doc.doc-type .

      { gbl/objdbnum.i
        b_ord-doc-rcv.obj-type
        b_ord-doc-rcv.obj-code
        v-obj-db-num }

      if v-cntxt-db-num <> v-obj-db-num then do:
        message "Удаление Привязки накладных к заказу ОП возможно да БД №" v-obj-db-num view-as alert-box information .
        return .
      end.
 if buf_ord-chain.rel-doc-type = 'trn' then do:
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code   = buf_ord-chain.rel-doc-code no-error .
   if available buf_trn-doc and  buf_trn-doc.status_ = {&fact} then do:
      message 'Накладная' buf_trn-doc.doc-code 'уже закрыта на ФАКТ ! Если удалите сейчас привязку, эту накладную уже нельзя будет привязать к поставке' skip
      'Удаляем привязку ?'
      view-as alert-box question
      buttons yes-no
      update v-ok as log

      .
      if v-ok = false then return .
   end.
 end.

  find current buf_ord-chain exclusive-lock .
  delete buf_ord-chain .
  {&OPEN-QUERY-BROWSE-37}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-30
&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME BROWSE-30
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-30 Dialog-Frame
on leave of post-ord-line-rcv.cli-qnty in browse BROWSE-30 do:
  if decimal( post-ord-line-rcv.cli-qnty :screen-value in browse BROWSE-30 ) <> post-ord-line-rcv.cli-qnty then do:
     assign post-ord-line-rcv.cli-qnty.
     post-ord-line-rcv.qnty     = post-ord-line-rcv.cli-qnty  * post-ord-line-rcv.cli-base-rate .
     post-ord-line-rcv.sum-base = post-ord-line-rcv.qnty      * post-ord-line-rcv.price-base .
     post-ord-line-rcv.sum-cli  = post-ord-line-rcv.cli-qnty  * post-ord-line-rcv.price-cli  .
     post-ord-line-rcv.sum-rubl = post-ord-line-rcv.qnty      * post-ord-line-rcv.price-rubl .

   display post-ord-line-rcv.cli-qnty
           post-ord-line-rcv.qnty
   with browse BROWSE-30.
   apply "LEAVE" to BROWSE-30 IN FRAME FRAME-A .
   end.
END.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-32
&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME BROWSE-32
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-32 Dialog-Frame
ON ROW-LEAVE OF BROWSE-32 IN FRAME FRAME-B
DO:
  message 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME l-loc-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame /* Время */
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour-2 IN FRAME Dialog-Frame /* Факт.время доставки */
DO:
  assign  frame {&frame-name} l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 -  1.
  if l-loc-hour-2 < 0 then return no-apply.
  display l-loc-hour-2 with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON CURSOR-UP OF l-loc-hour-2 IN FRAME Dialog-Frame /* Факт.время доставки */
DO:
  assign  frame {&frame-name} l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 +  1.
  if l-loc-hour-2 > 24 then return no-apply.
  display l-loc-hour-2 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON LEAVE OF l-loc-hour-2 IN FRAME Dialog-Frame /* Факт.время доставки */
DO:

  assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 -  1.
  if l-loc-min-2 < 0 then return no-apply.
  display l-loc-min-2 with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON CURSOR-UP OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 +  1.
  if l-loc-min-2 > 59 then return no-apply.
  display l-loc-min-2 with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON LEAVE OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_mobilscn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mobilscn Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mobilscn /* Экспорт в Моб.сканер */
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot2.p (input parparentproc , input "rcv" , input "" ,input  ub.ord-doc-rcv.rcv-code ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m___Excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m___Excel Dialog-Frame
ON CHOOSE OF MENU-ITEM m___Excel /* Экспорт в Excel */
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/z-tot3.p ( input parParentProc , input ub.ord-doc-rcv.rcv-code , input ub.ord-doc-rcv.doc-code ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-doc-rcv.obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-doc-rcv.obj-code Dialog-Frame
ON LEAVE OF loc-doc-rcv.obj-code IN FRAME Dialog-Frame /* Объект */
DO:
  assign loc-doc-rcv.obj-code loc-doc-rcv.obj-type .
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
     return no-apply.
     end.
    find first obj-clients  no-lock where
               obj-clients.obj-code = loc-doc-rcv.obj-code and
               obj-clients.obj-type = loc-doc-rcv.obj-type
               no-error.

              obj_obj-name = obj-clients.obj-name.
              if avail obj-clients then  display obj_obj-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-doc-rcv.obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-doc-rcv.obj-type Dialog-Frame
ON LEAVE OF loc-doc-rcv.obj-type IN FRAME Dialog-Frame /* obj-type */
DO:
 apply "LEAVE":U to loc-doc-rcv.obj-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-clients Dialog-Frame
ON CHOOSE OF r-clients IN FRAME Dialog-Frame /* r-cli */
DO:
  run r-clients-ch in this-procedure  no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-curr Dialog-Frame
ON CHOOSE OF r-curr IN FRAME Dialog-Frame
DO:
  run r-cur in this-procedure no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj Dialog-Frame
ON CHOOSE OF r-obj IN FRAME Dialog-Frame /* r-obj */
DO:
  run r-clients-ob in this-procedure no-error .
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


/*{ gbl/app_help.i &disable_diasize_init=true   &browse-name="Browse-30" } */

{ gbl/app_help.i }
{ gbl/ed_date.i loc-doc-rcv.ship-date}
{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "frame-A"
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
  &open-query     = "run openbr."
  &open-query-otherwise = "run openbr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }

ASSIGN
  b-export-2:POPUP-MENU IN FRAME Frame-A       = MENU m-export:HANDLE
  b-export-2:MENU-MOUSE = 1.


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if p-mode = 1 or p-mode = 3  then do:
       find first ub.ord-doc-rcv  exclusive-lock   where recid(ub.ord-doc-rcv) = p-ord-rec  .
    end.
    if p-mode = 2 then do:
      find first ub.ord-line-rcv no-lock        where recid(ub.ord-line-rcv)  = p-ord-rec  no-error .
      find first ub.ord-doc-rcv  exclusive-lock where ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code no-error .
      find first b-ord-line   no-lock        where recid(b-ord-line)    = p-ord-rec no-error .
    end.
 ASSIGN
  v-deliv-type-code     =  ub.ord-doc-rcv.deliv-type-code
  v-point-obj-code      =  ub.ord-doc-rcv.obj-point-code
  v-point-cli-code      =  ub.ord-doc-rcv.cli-point-code
  v-point-obj-db-num    =  ub.ord-doc-rcv.obj-point-db-num
  v-point-cli-db-num    =  ub.ord-doc-rcv.cli-point-db-num
  v-transport-host-code      =  ub.ord-doc-rcv.transport-host-code
  v-transport-cli-code  =  ub.ord-doc-rcv.transport-cli-code
  v-transport-cli-type  =  ub.ord-doc-rcv.transport-cli-type
  v-transport-contract  =  ub.ord-doc-rcv.transport-contract
  v-transport-condition =  ub.ord-doc-rcv.transport-condition
  v-transport-value     =  ub.ord-doc-rcv.transport-value
  v-transport-sum       =  ub.ord-doc-rcv.sum-ship
  v-transport-vat       =  ub.ord-doc-rcv.transport-vat
  loc-cli-out-code      =  entry(1,ord-doc-rcv.sub-par,{&delim-par})
  .
  vat_type = entry(2,ord-doc-rcv.sub-par,{&delim-par}) no-error
  .
  Post-goods.gds-name:resizable in browse browse-30 = true .
  Post-goods.gds-name:resizable in browse browse-32 = true .
  post-ord-line-rcv.artic:resizable in browse browse-30 = true .
  post-ord-line-rcv.artic:resizable in browse browse-32 = true .
  run enable_UI in this-procedure no-error .
  run input-p in this-procedure no-error .
  { gbl/mv-clmn.i
  &ext-col = 10
  &frame-name = "frame-A"
  &browse-name = "{&BROWSE-NAME}"
  &start-column = "2"
  }

hide b-trn-2 in frame dialog-frame.
if p-mode = 1   then do:
 run create-ch-box in this-procedure .
 WAIT-FOR GO OF FRAME dialog-frame focus  loc-doc-rcv.cli-code .
end.
if p-mode = 3  then do:
  {&OPEN-QUERY-BROWSE-37}
  WAIT-FOR GO OF FRAME  dialog-frame /* frame-a focus {&browse-name}  */ .
end.
if p-mode = 2 then do:
hide b-trn b-trn-3 B-trn-4 b-trn-2 b-create-trn in frame dialog-frame.
 if loc-line-rcv.cli-qnty:sensitive in frame dialog-frame then
     WAIT-FOR GO OF FRAME dialog-FRAME focus  loc-line-rcv.cli-qnty .
  else
     WAIT-FOR GO OF FRAME dialog-FRAME focus  loc-line-rcv.qnty .
end.

  /*888*/
END.
run disable_UI  in this-procedure no-error .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE att-trn Dialog-Frame
PROCEDURE att-trn :
do
 on error undo, return error return-value
 :
define input parameter b-recid as recid no-undo .

define variable loc-ref-list as character no-undo .
define variable v-input-output as character no-undo .
define variable p-trn-code as character no-undo .

define buffer bub_ord-doc-rcv      for ub.ord-doc-rcv .
define buffer buf_ord-doc          for ub.ord-doc .
define buffer loc_buf_ord-line-rcv for ub.ord-line-rcv .
define buffer loc_buf_doc-line     for ub.doc-line .
define variable v-type-ord as character no-undo init "".

find first bub_ord-doc-rcv no-lock  where recid( bub_ord-doc-rcv)  = b-recid no-error .
if not avail bub_ord-doc-rcv then do:
  message  "Не выбрана поставка !!! " view-as alert-box .
  return .
end.

if bub_ord-doc-rcv.status_ <> {&ord-rcv} then do:
  message "Нельзя сделать накладную на поставку в статусе " caps(bub_ord-doc-rcv.status_) view-as alert-box .
  return.
end.
find first buf_ord-doc no-lock where buf_ord-doc.doc-code = bub_ord-doc-rcv.doc-code no-error .
if available buf_ord-doc then v-type-ord = buf_ord-doc.doc-type .
doc-rec = ?  .
/*если ОП и ФП то только приходы */
if v-type-ord = {&o-p} or v-type-ord = {&f-p} then do:
    run str/all-docs.w
   ( input  parparentproc
    ,input   bub_ord-doc-rcv.host-code /*host-code*/
    ,input   bub_ord-doc-rcv.obj-type  /*obj-type*/
    ,input   bub_ord-doc-rcv.obj-code  /*obj-code*/
    ,input  'status-all-hold'
    ,input  ?
    ,input  {&income}
    ,input  ?
    ,input  no
    ,input  "b-sel":U
    ,input  {&TDEDT_Pri_Vnesh}
    ,input  ?
    ,input  ?
    ,output loc-ref-list
    ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
end.
else do:
    run str/all-docs.w
    ( input  parparentproc
    ,input   bub_ord-doc-rcv.host-code /*host-code*/
    ,input   bub_ord-doc-rcv.obj-type  /*obj-type*/
    ,input   bub_ord-doc-rcv.obj-code  /*obj-code*/
    ,input   {&g___object}
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  "b-sel":U
    ,input  ?
    ,input  ?
    ,input  ?
    ,output loc-ref-list
    ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
end.
if loc-ref-list = ? then return.

  find first   buf_trn-doc no-lock where recid(buf_trn-doc) = int(loc-ref-list) no-error .
  if available buf_trn-doc
     then
      assign
        p-trn-code    = buf_trn-doc.doc-code
      .
    else do:
      assign
        p-trn-code    = ?
      .
      return .
    end.

/* Проверка состава поставки и накладной */
define variable  j-trn as integer no-undo .
define variable  j-rcv as integer no-undo .

 j-trn = 0.
 j-rcv = 0.
 for each loc_buf_ord-line-rcv no-lock where
          loc_buf_ord-line-rcv.doc-code =  bub_ord-doc-rcv.doc-code and
          loc_buf_ord-line-rcv.rcv-code =  bub_ord-doc-rcv.rcv-code
          :
    j-rcv = j-rcv + 1.
    if can-find (first loc_buf_doc-line where
                       loc_buf_doc-line.doc-code   = buf_trn-doc.doc-code and
                       loc_buf_ord-line-rcv.artic  = loc_buf_doc-line.artic and
                       loc_buf_ord-line-rcv.prod-type =  loc_buf_doc-line.prod-type and
                       loc_buf_ord-line-rcv.prod-code =  loc_buf_doc-line.prod-code no-lock  ) Then j-trn = j-trn + 1.


 end.
 if j-rcv > j-trn then do:
    message  "Совпадение списка товаров  в выбранной накладной " (J-trn / j-rcv ) * 100  " %  ! "
      skip "Делаем привязку ?"
      view-as alert-box  Question
      buttons yes-no update g#log .
      if not g#log  then return .
  end.

  if not ( bub_ord-doc-rcv.cli-code = buf_trn-doc.cli-code and
           bub_ord-doc-rcv.cli-type = buf_trn-doc.cli-type )
  then do:
    message  "Не совпадает Поставщик в Накладной и Поставке  ! "
      skip "Делаем привязку ?"
      view-as alert-box  Question
      buttons yes-no update g#log .
      if not g#log  then return .
  end.
  if not ( bub_ord-doc-rcv.obj-code = buf_trn-doc.obj-code and
           bub_ord-doc-rcv.obj-type = buf_trn-doc.obj-type )
  then do:
    message  "Не совпадает объект доставки  в Накладной и Поставке  ! "
      skip "Делаем привязку ?"
      view-as alert-box  Question
      buttons yes-no update g#log .
      if not g#log  then return .
  end.

  run create-chain in this-procedure (
      bub_ord-doc-rcv.rcv-code,
      'rcv'      ,
      p-trn-code ,
      'trn' ,
      ''    ,
      '' )  no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "create-chain"
        view-as alert-box error
      .

    if v-cntxt-db-num > 0 then do:
        find first buf_trn-doc no-lock where recid(buf_trn-doc) = int(loc-ref-list) no-error .
        for each  buf_ord-chain where
                  buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and
                  buf_ord-chain.rel-doc-type = 'trn'
                  :
           run nws/cr-route.p ( input {&send-tbl}, input {&table_ord-chain}, input ( buffer buf_ord-chain:handle) , input "0" ) no-error.
        end.
    end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-ch-box Dialog-Frame
PROCEDURE create-ch-box :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
     define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_h-wbill':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g-log
  }

   create RADIO-SET type-pr
   assign
    row    = 10.5
    column = 2
    RADIO-BUTTONS = "Формировать строки автоматически без подтверждения,1,Формировать строки автоматически c подтверждением,2,Импорт из файла мобильного сканера,3" +
( if g-log then ",Закрыть поставку и создать накладную,4" else "" )

    frame  = frame {&frame-name}:handle
 .

if valid-handle(type-pr) = false then do:
    message "не могу создать radio-button !!!" skip
    view-as alert-box information .
    return error.
 end.
  type-pr:sensitive = yes  .
  type-pr:visible   = yes  .

  hide {&line-list}
 ub.goods.gds-name
 ub.goods.unit-base
  loc-line-rcv.artic
  loc-line-rcv.prod-type
  loc-line-rcv.prod-code
  in frame {&frame-name} .
     frame {&frame-name}:title  = "Формирование поставки по заказу" .
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
  HIDE FRAME FRAME-A.
  HIDE FRAME FRAME-B.
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
  DISPLAY loc-cli-out-code l-loc-hour l-loc-min l-loc-hour-2 l-loc-min-2
          loc-type-doc post_obj-name obj_obj-name abbr-base abbr-cli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name ub.goods.unit-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE loc-doc-rcv THEN
    DISPLAY loc-doc-rcv.cli-code loc-doc-rcv.cli-type loc-doc-rcv.obj-code
          loc-doc-rcv.obj-type loc-doc-rcv.ship-date loc-doc-rcv.exch-code
          loc-doc-rcv.rcv-code loc-doc-rcv.doc-code loc-doc-rcv.base-rate
          loc-doc-rcv.base-scale loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale
      WITH FRAME Dialog-Frame.
  IF AVAILABLE loc-line-rcv THEN
    DISPLAY loc-line-rcv.price-cli loc-line-rcv.cli-qnty
          loc-line-rcv.cli-base-rate loc-line-rcv.price-rubl loc-line-rcv.qnty
          loc-line-rcv.price-base loc-line-rcv.SLT-pc loc-line-rcv.VAT-pc
          loc-line-rcv.artic loc-line-rcv.prod-type loc-line-rcv.prod-code
          loc-line-rcv.unit-cli
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-exit B-stop B-delivery B-Help RECT-1 RECT-3 loc-cli-out-code
         BROWSE-37 B-create-trn B-trn loc-doc-rcv.obj-code loc-doc-rcv.obj-type
         r-obj B-trn-3 loc-doc-rcv.ship-date l-loc-hour l-loc-min B-trn-2
         B-trn-4 r-curr loc-line-rcv.price-cli loc-line-rcv.cli-qnty
         loc-line-rcv.cli-base-rate loc-doc-rcv.rcv-code loc-type-doc
         loc-doc-rcv.doc-code post_obj-name obj_obj-name abbr-base
         loc-doc-rcv.base-rate loc-doc-rcv.base-scale abbr-cli
         loc-doc-rcv.exch-rate loc-doc-rcv.exch-scale loc-line-rcv.artic
         loc-line-rcv.prod-type loc-line-rcv.prod-code ub.goods.gds-name
         loc-line-rcv.unit-cli ub.goods.unit-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  ENABLE b-chg b-lkp b-del b-scl b-export-2 BROWSE-30
      WITH FRAME FRAME-A.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  ENABLE b-chg-2 b-lkp-2 b-del-2 b-scl-2 BROWSE-32
      WITH FRAME FRAME-B.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-B}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE input-p Dialog-Frame
PROCEDURE input-p :
do
 on error undo, return error return-value
 :

define buffer b_trn-doc for ub.trn-doc .
define variable s-doc-mode as character no-undo .
HIDE FRAME FRAME-B.
find first  loc-doc-rcv  exclusive-lock   .
find first post-clients no-lock where
           post-clients.obj-code = loc-doc-rcv.cli-code   and
           post-clients.obj-type = loc-doc-rcv.cli-type
           no-error .
           if error-status :error then return error return-value .
           post_obj-name = post-clients.obj-name.

find first obj-clients no-lock where
           loc-doc-rcv.obj-code = obj-clients.obj-code and
           loc-doc-rcv.obj-type = obj-clients.obj-type
           no-error .
           if error-status :error then return error return-value .
           obj_obj-name = obj-clients.obj-name.

find first ub.currency no-lock   where ub.currency.curr-code = loc-doc-rcv.EXCH-CODE no-error.
if available ub.currency then abbr-cli = ub.currency.curr-abbr .

define variable   p-exch-rate  as decimal   no-undo .
define variable   p-exch-scale as decimal   no-undo .
{ gbl/exchrate.i
  base-code
  today
  p-exch-rate
  p-exch-scale
  abbr-base }

s-doc-mode = line-mode .

display  abbr-base abbr-cli loc-doc-rcv.EXCH-CODE with frame {&frame-name} .

loc-doc-type = loc-doc-rcv.doc-type.

if p-mode = 2 then do:
find first loc-line-rcv no-error .
find first ub.goods no-lock where
           ub.goods.artic      = loc-line-rcv.artic     and
           ub.goods.prod-code  = loc-line-rcv.prod-code and
           ub.goods.prod-type  = loc-line-rcv.prod-type
            no-error.
   if error-status :error then return error return-value .
   run ass-var  in this-procedure no-error .
end.

define buffer buf_ord-doc for ub.ord-doc  .
find first buf_ord-doc no-lock where
           buf_ord-doc.doc-code = loc-doc-rcv.doc-code no-error .
Assign
   loc-time       = string( loc-doc-rcv.ship-time ,"HH:MM")
   loc-time-2     = string( loc-doc-rcv.fact-ship-time ,"HH:MM")
   l-loc-hour     = integer (entry(1,loc-time,":"))
   l-loc-min      = integer (entry(2,loc-time,":"))
   l-loc-hour-2   = if integer (entry(1,loc-time-2,":")) = 0 then 10 else integer (entry(1,loc-time-2,":"))
   l-loc-min-2    = integer (entry(2,loc-time-2,":"))
   loc-type-doc    = IF (loc-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр")
   loc-cli-out-code   = entry(1,loc-doc-rcv.sub-par,{&delim-par})
   vat_type           = entry(2,ub.ord-doc-rcv.sub-par,{&delim-par})
   loc-base-rate   = loc-doc-rcv.base-rate
   loc-base-scale  = loc-doc-rcv.base-scale
   loc-exch-code   = loc-doc-rcv.exch-code
   loc-exch-rate   = loc-doc-rcv.exch-rate
   loc-exch-scale  = loc-doc-rcv.exch-scale
   no-error . /* !!! */

if p-mode = 1  then do:
   if line-mode = {&update}  then
      enable      {&doc-list} r-obj loc-doc-rcv.exch-code with frame  {&frame-name} .
disable
    loc-doc-rcv.cli-code
    loc-doc-rcv.cli-type
    post_obj-name
    r-clients
    with frame  {&frame-name} .
 if g#type = {&o-p} then
 disable
    loc-doc-rcv.obj-type
    loc-doc-rcv.obj-code
    obj_obj-name
    r-obj
    with frame  {&frame-name} .

  disable  {&line-list} with frame  {&frame-name} .

  display  {&doc-list}  loc-doc-rcv.cli-code loc-doc-rcv.cli-type
    with frame  {&frame-name} .
  hide frame frame-a  .
  hide b-stop in frame {&frame-name}  .
  if doc-mode <> {&add-def} then  hide b-exit in frame {&frame-name} .
  if doc-mode = {&add-def}  then  disable {&trn-list}  with frame {&frame-name} .

  if loc-doc-rcv.doc-type = 'in':U then do:
    disable loc-doc-rcv.base-rate
            loc-doc-rcv.base-scale
            loc-doc-rcv.exch-code
            loc-doc-rcv.exch-rate
            loc-doc-rcv.exch-scale
            r-curr
            with frame {&frame-name} .
  end.

end.

if p-mode = 2 then do:
 assign frame {&frame-name}:title  = "Строка поставки " + loc-doc-rcv.rcv-code + " - " + line-mode  .
  hide frame frame-a  loc-cli-out-code .
  disable  {&doc-list} r-obj r-curr with frame  {&frame-name} .
  if line-mode = {&update}  then  do:
    enable   {&line-list} with frame  {&frame-name} .
  end.
  display  {&line-list} l-loc-hour l-loc-min
           l-loc-hour-2 l-loc-min-2
           with frame  {&frame-name} .
    if  line-mode = "ЦИКЛ":U then  do:
    end .
    else  hide b-stop in frame {&frame-name}  .
  if  line-mode = {&lookup} then  do  :
     disable  {&line-list} {&doc-list} r-obj with frame  {&frame-name} .
     disable   b-trn b-trn-3 b-trn-2 b-create-trn B-trn-4 with frame  {&frame-name} .
     disable   b-chg  b-del  with frame  frame-a .
     disable   b-chg-2  b-del-2 with frame  frame-b .
     hide b-ok in frame {&frame-name}.
     b-exit:label = "Вы&ход".
     b-exit:column = 1.
  end.
     loc-line-rcv.price-cli:label in frame {&frame-name} = "Цена пост. (" + abbr-cli + ")" .
     loc-line-rcv.price-rubl:label in frame {&frame-name} ="Цена ({&abbr_rub}) " .
     loc-line-rcv.price-base:label in frame {&frame-name} ="Цена (" + abbr-base + ")" .
  if  line-mode <> {&lookup} then run ass-var  in this-procedure no-error .
end.

if p-mode = 3 then do:
  disable r-curr loc-doc-rcv.exch-code with frame  {&frame-name} .
  assign frame {&frame-name}:title  = "ПОСТАВКА " + loc-doc-rcv.rcv-code + " - " + line-mode  .
  if loc-doc-rcv.status_ <> {&g___new}  then dO:
     disable  b-chg    b-del   with frame  frame-a .
     disable  b-chg-2  b-del-2 with frame  frame-b .
end.

if doc-mode = {&lookup} OR line-mode = {&lookup}  then do:
     enable   b-trn b-trn-2 b-trn-3 with frame  {&frame-name} .
     disable  {&doc-list}  r-obj with frame  {&frame-name} .
     disable  b-chg  b-del  with frame  frame-a .
     disable  b-chg-2  b-del-2 with frame  frame-b .
     disable  b-create-trn with frame  {&frame-name} .
     disable {&line-list} with frame  {&frame-name} .

     display {&doc-list} {&trn-list}  loc-doc-rcv.cli-code loc-doc-rcv.cli-type with frame  {&frame-name} .
      hide b-ok in frame {&frame-name}
           b-stop in frame {&frame-name}
           .

  assign
    post-ord-line-rcv.cli-qnty:read-only   in browse browse-30 = true
    /*post-ord-line-rcv.price-cli:read-only  in browse browse-30 = true */
    post-ord-line-rcv.line-num:read-only   in browse browse-30 = true.

  if list-mode  = {&ord-rcv}   then do:
     view b-ok in frame {&frame-name}.
     enable  l-loc-min-2  l-loc-hour-2 with frame  {&frame-name} .
     enable b-trn b-trn-2 b-trn-3 B-trn-4 b-create-trn with frame  {&frame-name} .
  end.

end.

else do:
  if line-mode = {&update}  then
     enable  {&doc-list}  r-obj with frame  {&frame-name} .
  if loc-doc-rcv.status_ = {&g___new}  then
     disable {&trn-list}  with frame {&frame-name} .
  disable {&line-list} with frame  {&frame-name} .
  display
     {&doc-list}
     loc-doc-rcv.cli-code
     loc-doc-rcv.cli-type
     r-clients
     with frame {&frame-name} .
  enable r-clients with frame  {&frame-name} .
  hide b-exit in frame {&frame-name}
       b-stop in frame {&frame-name}  .
end.

  if loc-doc-rcv.status_ <> {&g___new}  and
      s-doc-mode = {&update} then do:
      enable {&trn-list}  with frame {&frame-name} .
  end.

if p-mode = 3  then do:
disable
    loc-doc-rcv.cli-code
    loc-doc-rcv.cli-type
    post_obj-name
    r-clients
    with frame  {&frame-name} .
 if g#type = {&o-p} then
 disable
    loc-doc-rcv.obj-type
    loc-doc-rcv.obj-code
    obj_obj-name
    r-obj
    with frame  {&frame-name} .

end.


  view frame frame-a  .
  display  {&browse-name} with frame  frame-a.
  {&OPEN-QUERY-{&BROWSE-NAME}}
  find first ub.goods no-lock where ub.goods.gds-code = Post-goods.gds-code no-error .


end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE look-trn-all Dialog-Frame
PROCEDURE look-trn-all :
do
 on error undo, return error return-value
 :


 if frame FRAME-a:visible then do:
 b-trn-2:LOAD-IMAGE-DOWN ("adeicon\save-d":U) in frame dialog-frame .
 b-trn-2:LOAD-IMAGE-UP ("adeicon\save-u":U) in frame dialog-frame .
 b-trn-2:LOAD-IMAGE-INSENSITIVE ("adeicon\save-i":U) in frame dialog-frame .
 b-trn-2:tooltip = "Свернуть данные накладной" .
 b-trn-2:LABEL = "Свернуть накл".
 DISPLAY b-trn-2 WITH frame dialog-frame .
 view frame frame-b  .
 hide frame frame-a  .
 display  browse-32 with frame  frame-b.
 {&OPEN-QUERY-BROWSE-32}

 end.
 else do:
  b-trn-2:LOAD-IMAGE-DOWN ("adeicon\open-d":U) in frame dialog-frame .
  b-trn-2:LOAD-IMAGE-UP ("adeicon\open-u":U) in frame dialog-frame .
  b-trn-2:LOAD-IMAGE-INSENSITIVE ("adeicon\open-i":U) in frame dialog-frame .
  b-trn-2:tooltip = "Развернуть с накладной" .
  b-trn-2:LABEL = "Показать накл".
 DISPLAY b-trn-2 WITH frame dialog-frame .
 view frame frame-a  .
 hide frame frame-b  .
 display  browse-30 with frame  frame-a.
 {&OPEN-QUERY-BROWSE-30}

end.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE r-clients-ch Dialog-Frame
PROCEDURE r-clients-ch :
do
 on error undo, return error return-value
 :

define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */

  run ref/cli-all.w ( input parParentProc, input "b-sel",{&g___object} , ?, ?, ?, ?, ?, output  rid-list ) no-error .
  if num-entries (rid-list) < 1 then return error return-value .
  find first Post-clients no-lock  WHERE recid (post-clients) = integer(rid-list)  No-ERROR.
  if avail Post-clients then
      Assign
          loc-doc-rcv.cli-code = Post-clients.obj-code
          loc-doc-rcv.cli-type = Post-clients.obj-type
          post_obj-name = post-clients.obj-name.
      .
  Display loc-doc-rcv.cli-code loc-doc-rcv.cli-type Post_obj-name with frame {&frame-name}.
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
     return no-apply.
     end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE r-clients-ob Dialog-Frame
PROCEDURE r-clients-ob :
do
 on error undo, return error return-value
 :

define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
  run ref/cli-all.w ( input parParentProc, input "b-sel", {&g___object}, ?, ?, ?, ?, ?,output  rid-list) no-error .

  find first OBJ-clients no-lock WHERE recid(OBJ-clients) = integer(rid-list) No-ERROR.
  if avail OBJ-clients then do:
      Assign
      loc-doc-rcv.obj-code = OBJ-clients.obj-code
      loc-doc-rcv.obj-type = OBJ-clients.obj-type
      obj_obj-name = obj-clients.obj-name.
      .
  end.
  Display loc-doc-rcv.obj-code loc-doc-rcv.obj-type OBJ_obj-name with frame {&frame-name}.
  if loc-doc-rcv.obj-code = loc-doc-rcv.cli-code and
     loc-doc-rcv.obj-type = loc-doc-rcv.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
     return no-apply.
     end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE r-cur Dialog-Frame
PROCEDURE r-cur :
do
 on error undo, return error return-value
 :

if p-mode <> 1 then return .
define variable ref-rec as recid no-undo .

assign
  ref-rec = ?
  .
run ref/currency.w ( input parParentProc, "b-sel", input-output ref-rec ).
if ref-rec = ? then return no-apply.
find ub.currency where recid ( ub.currency ) = ref-rec no-lock.

if ub.currency.curr-code <> loc-exch-code then do:
   /* изменим doc */
      find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code
           use-index pi no-lock no-error.
      if available ub.curr-accnt then assign
          loc-doc-rcv.exch-rate  = ub.curr-accnt.exch-rate
          loc-doc-rcv.exch-scale  = ub.curr-accnt.exch-scale
          .

   assign
   loc-exch-code         = ub.currency.curr-code
   loc-doc-rcv.exch-code = ub.currency.curr-code
   loc-exch-rate         = loc-doc-rcv.exch-rate
   loc-exch-scale        = loc-doc-rcv.exch-scale
   abbr-cli              = ub.currency.curr-abbr
   .
 display {&doc-list} loc-doc-rcv.exch-code with frame {&frame-name} .
 end.

 end. /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ver-value Dialog-Frame
PROCEDURE ver-value :
do
 on error undo, return error return-value
 :
define buffer bf-units-cli for ub.units.
define buffer bufff-units  for ub.units.

/*-----------------------------------------------------*/
/* Проверка того, что отработали все триггера на leave */
/*-----------------------------------------------------*/
&scop frame-name dialog-frame
&scop ver-trg if ~
 ~{&v-pole}:sensitive in frame ~{&frame-name} and input frame ~{&frame-name} ~{&v-pole}  <> ~{&v-pole}  then apply "leave" to ~{&v-pole}  in frame ~{&frame-name}.

&scop v-pole loc-line-rcv.vat-pc
 {&ver-trg}
&scop v-pole loc-line-rcv.slt-pc
 {&ver-trg}

&scop v-pole loc-line-rcv.cli-base-rate
 {&ver-trg}
&scop v-pole loc-line-rcv.qnty
 {&ver-trg}
 &scop v-pole loc-line-rcv.cli-qnty
 {&ver-trg}
&scop v-pole loc-line-rcv.price-cli
 {&ver-trg}
&scop v-pole loc-line-rcv.price-base
 {&ver-trg}
&scop v-pole loc-line-rcv.price-rubl
 {&ver-trg}


  if loc-line-rcv.cli-qnty:sensitive in frame {&frame-name} and  (loc-line-rcv.cli-qnty = 0 or loc-line-rcv.cli-qnty = ?) /* and loc-status <> {&g___new} */ then do:
    message "Не указано количество в единицах поставщика." view-as alert-box error.
    if loc-line-rcv.cli-qnty:sensitive in frame {&frame-name} then apply "entry" to loc-line-rcv.cli-qnty in frame {&frame-name}.
                                                              else apply "entry" to b-ok              in frame {&frame-name}.
    return error.
  end.
  if loc-line-rcv.qnty:sensitive in frame {&frame-name} and  (loc-line-rcv.qnty = 0 or loc-line-rcv.qnty = ?) /* and loc-status <> {&g___new} */ then do:
    message "Не указано количество  в учетных единицах." view-as alert-box error.
    return error.
  end.

  find bufff-units no-lock  where bufff-units.unit-name = ub.goods.unit-base  no-error.

  if  loc-line-rcv.qnty:sensitive in frame {&frame-name} and
      lookup({&pieces}, bufff-units.type) > 0      and
      trunc(loc-line-rcv.qnty, 0) <> loc-line-rcv.qnty then do:
      message "Базовая единица товара " ub.goods.unit-base " - штучная." skip
              "Кол-во должно быть целым."
      view-as alert-box error buttons ok.
      return error.
  end.

  find bf-units-cli no-lock where bf-units-cli.unit-name = loc-line-rcv.unit-cli no-error.
  if not available bf-units-cli then do:
    message "Неправильная единица измерения." view-as alert-box error.
    return error.
  end.
  /*Если единица поставщика штучная, то кол-во от поставщика должно указываться целым*/
  if  loc-line-rcv.cli-qnty:sensitive in frame {&frame-name} and
      lookup({&pieces}, bf-units-cli.type) > 0  and
      trunc(loc-line-rcv.cli-qnty, 0) <> loc-line-rcv.cli-qnty then do:
      message "Единица поставщика " loc-line-rcv.unit-cli " - штучная." skip
              "Должно быть указано целое количество в единицах поставщика."
      view-as alert-box error buttons ok.
      return error.
  end.
  release bf-units-cli.

  if loc-line-rcv.cli-base-rate:sensitive in frame {&frame-name} and (loc-line-rcv.cli-base-rate = 0 or loc-line-rcv.cli-base-rate = ?) then do:
    message "Не указан коэффициент пересчета единиц измерения." view-as alert-box error.
    return error.
  end.
  if loc-line-rcv.unit-cli = ub.goods.unit-base and
     decimal(loc-line-rcv.cli-base-rate:screen-value)  <> 1 then do:
     message "Коэффициент пересчета единиц измерения должен быть 1, т.к. единицы совпадают." view-as alert-box error.
     return error.
  end.


    if loc-line-rcv.price-cli:sensitive in frame {&frame-name} and ( loc-line-rcv.price-cli = 0 or loc-line-rcv.price-cli = ?) then do:
      message "Не указана цена в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-cli < 0  then do:
      message "Нельзя указаывать отрицательные цены в валюте поставщика." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-base:sensitive in frame {&frame-name} and (loc-line-rcv.price-base = 0 or loc-line-rcv.price-base = ?) then do:
      message "Не указана цена в базовой валюте." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-base < 0  then do:
      message "Отрицательная цена в базовой валюте."  view-as alert-box error.
      return error.
    end.
    /*!!!*/
    if loc-line-rcv.price-base > 5000 and base-code = 1 then
      message "Внимание !!!" skip (2)
              "ВАЛЮТНАЯ цена превышает 5,000 !" skip (2)
              "Вы не ошиблись ?"  view-as alert-box question.

    if loc-line-rcv.price-rubl:sensitive in frame {&frame-name} and (loc-line-rcv.price-rubl = 0 or loc-line-rcv.price-rubl = ?) then do:
      message "Не указана цена в {&abbr_rublyah}." view-as alert-box error.
      return error.
    end.
    if loc-line-rcv.price-rubl < 0 then do:
      message "Отрицательная цена в {&abbr_rublyah}."  view-as alert-box error.
      return error.
    end.
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME