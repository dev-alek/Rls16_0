&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER b-all_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER bb_ord-doc FOR ub.ord-doc.
DEFINE NEW SHARED BUFFER bufs_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_gds-obj FOR ub.gds-obj.
DEFINE BUFFER e_fp_ord-doc FOR ub.ord-doc.
DEFINE BUFFER e_fp_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER e_fp_ord-dtl FOR ub.ord-dtl.
DEFINE BUFFER e_fp_ord-dtl-rcv FOR ub.ord-dtl-rcv.
DEFINE BUFFER l_rcv_gds-dtl FOR ub.gds-dtl.
DEFINE BUFFER l_rcv_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER l_rcv_ord-dtl-rcv FOR ub.ord-dtl-rcv.
DEFINE BUFFER l_rcv_trn-doc FOR ub.trn-doc.
DEFINE TEMP-TABLE my-obj NO-UNDO LIKE ub.clients.
DEFINE BUFFER m_ord-line FOR ub.ord-line.
DEFINE BUFFER new-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER obj_gds-dtl FOR ub.gds-dtl.
DEFINE BUFFER obj_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER obj_ord-dtl-rcv FOR ub.ord-dtl-rcv.
DEFINE BUFFER obj_prt-obj FOR ub.prt-obj.
DEFINE BUFFER obj_trn-doc FOR ub.trn-doc.
DEFINE BUFFER of_ord-doc FOR ub.ord-doc.
DEFINE BUFFER of_ord-dtl FOR ub.ord-dtl.
DEFINE NEW SHARED BUFFER shar-buf_ord-doc FOR ub.ord-doc.
DEFINE TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods
       field nn as int
       field use as log
       field gds-t as char
       field sum-qnty like ub.ord-line.qnty
       field sum-ord like ub.ord-line.qnty
       field sum-rcv like ub.ord-line.qnty
       field sum-rcv-in like ub.ord-line.qnty
       field sum-fact like ub.ord-line.qnty
       field prt-name like ub.gds-prt.f-name
       field all-name like ub.gds-prt.f-name
       field node-code like ub.goods.prt-root
       index i1 nn
       index i2 gds-code
       index i3 artic prod-type prod-code.
DEFINE BUFFER tt-new-doc-line FOR ub.doc-line.
DEFINE BUFFER tt-new-ord-line FOR ub.ord-line.
DEFINE TEMP-TABLE tt-ord-gds NO-UNDO LIKE ub.goods
       field use as log.
DEFINE BUFFER tt-rcv-ex FOR ub.ord-line-rcv.
DEFINE BUFFER tt-rcv-in FOR ub.ord-line-rcv.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Планирование СЗФП

Автор: Чернова Светлана Александровна
Дата создания: 08/12/05
Author: Svetlana Chernova
Creation date: 08/12/05

*/

define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter p-cons-code like ub.ord-cons.cons-code no-undo .
define input  parameter doc-mode as character no-undo .
define input  parameter list-mode as character no-undo . /* obj   */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Планирование СЗФП".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/color.i    }
{ cmp/df-sub.i   }
{ cus/df-zakaz.i new }
{ cus/ord-lib.i last-price }
{ cus/ord-lib.i create-chain }

define temp-table temp-ttt no-undo
field p-recid  as recid
index pi IS UNIQUE PRIMARY p-recid
.

define variable t-of as logical no-undo init false .
define variable t-prt as logical no-undo init false .
define variable dk   as integer no-undo .
define variable v-i-doc as character no-undo .
define variable x-artic like ub.goods.artic no-undo.
define variable x-prod-type like ub.goods.prod-type no-undo.
define variable x-prod-code like ub.goods.prod-code no-undo.
define variable x-node-code as character no-undo .

define variable br-handle as handle no-undo.
define variable bf-handle as handle no-undo.
define new shared  variable next-prev as logical   no-undo .
def new shared var br-rcv-handle as handle no-undo   .
define new shared variable x-make-avto as integer  no-undo .
define variable loc-make-avto as logical no-undo .

define variable obj-code-type as char no-undo.
define variable ttt as character no-undo .
define variable sort-column-name as character no-undo .
define variable user-color-status as integer no-undo init 7 .

define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .

define variable g#type as character no-undo .
define variable doc-rec as recid no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable base-code as integer   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num in parParentProc ( output g#report-num ).
{ gbl/basecode.i g#host-code  base-code }
{ cus/ord-code.i def }

&glob l-out 'out':U
&scop l-28-1 'Поставка'
&scop l-28-2 'Кол-во'
&scop l-28-3 'Куда'
&scop l-28-4 'Цена({&abbr_rub}.)'
&scop l-28-5 'Кол-во(е.и.п)'
&scop l-28-6 'Цена (пост.)'
&scop l-28-7 'Доставка'
&scop l-28-8 'Артикул'
&scop l-28-9 'Заказ'
&scop l-28-10 'Статус'
&scop l-28-11 'Название товара'


&scop c-18-1 mark-string (buffer tt-new-ord-line)
&scop c-18-2 tt-new-ord-line.doc-code
&scop c-18-3 tt-new-ord-line.qnty
&scop c-18-4 string(ub.ord-doc.cli-type + ' ' + string(ub.ord-doc.cli-code))
&scop c-18-5 tt-new-ord-line.cli-qnty
&scop c-18-6 ub.ord-doc.cli-name
&scop c-18-7 (IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close}) THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,'+/-')) ELSE (ub.ord-doc.status_) )
&scop c-18-8 ub.goods.gds-name
&scop c-18-9 tt-new-ord-line.artic

&scop c-28-1  ub.ord-doc-rcv.rcv-code
&scop c-28-2  ub.ord-line-rcv.qnty
&scop c-28-3  (ub.ord-doc-rcv.obj-type + ' ' + string(ub.ord-doc-rcv.obj-code))
&scop c-28-4  ub.ord-line-rcv.price-rubl
&scop c-28-5  ub.ord-line-rcv.cli-qnty
&scop c-28-6  ub.ord-line-rcv.price-cli
&scop c-28-7  ub.ord-doc-rcv.ship-date
&scop c-28-8  ub.ord-line-rcv.artic
&scop c-28-9  ub.ord-doc-rcv.doc-code
&scop c-28-10 (IF (ub.ord-doc-rcv.status_ = ~{&fact} or ub.ord-doc-rcv.status_ = ~{&ord-close}) THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,'+/-')) ELSE (ub.ord-doc-rcv.status_) )
&scop c-28-11 ub.goods.gds-name

&scop c-20-1   ub.ord-line-rcv.rcv-code
&scop c-20-2   ( b-all_ord-doc-rcv.obj-type + ' ' + string(b-all_ord-doc-rcv.obj-code) )
&scop c-20-3   ub.ord-line-rcv.qnty
&scop c-20-4   ub.ord-line-rcv.cli-qnty
&scop c-20-5   ( b-all_ord-doc-rcv.cli-type + ' ' + string(b-all_ord-doc-rcv.cli-code))
&scop c-20-6   ub.ord-line-rcv.price-cli
&scop c-20-7   ub.ord-line-rcv.price-rubl
&scop c-20-8   ub.ord-line-rcv.artic
&scop c-20-9  (IF (b-all_ord-doc-rcv.status_ = ~{&fact} or b-all_ord-doc-rcv.status_ = ~{&ord-close})  THEN (b-all_ord-doc-rcv.status_ + string(b-all_ord-doc-rcv.flag_,"+/-"))  ELSE (b-all_ord-doc-rcv.status_) )

&scop l-20-1   '№ пост-ки'
&scop l-20-2   'Куда'
&scop l-20-3   'Кол-во'
&scop l-20-4   'Кол-во(пост.)'
&scop l-20-5   'С объекта'
&scop l-20-6   'Цена (пост.)'
&scop l-20-7   'Цена ({&abbr_rub})'
&scop l-20-8   'Артикул'
&scop l-20-9  'Статус'

&scop c-29-1       (new-rcv.obj-type + ' ' + string(new-rcv.obj-code) )
&scop c-29-2       ub.ord-line-rcv.qnty
&scop c-29-3       ub.ord-line-rcv.artic
&scop c-29-4       new-rcv.ship-date
&scop c-29-5       new-rcv.fact-date
&scop c-29-6       string(new-rcv.ship-time,'HH:MM')
&scop c-29-7       new-rcv.rcv-code
&scop c-29-8       ( IF (new-rcv.status_ = ~{&fact} or new-rcv.status_ = ~{&ord-close})  THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-"))  ELSE (new-rcv.status_) )
&scop c-29-10      new-rcv.doc-code
&scop c-29-11      ( IF (new-rcv.doc-type = 'in':U) THEN ('внут') ELSE ('внеш') )
&scop c-29-12      bb_ord-doc.cons-code
&scop c-29-13      ub.ord-line-rcv.price-rubl
&scop c-29-14      ub.ord-line-rcv.cli-qnty
&scop c-29-15      ub.ord-line-rcv.price-cli

&scop l-29-1       'Куда'
&scop l-29-2       'Кол-во'
&scop l-29-3       'Артикул'
&scop l-29-4       'Доставка'
&scop l-29-5       'Факт'
&scop l-29-6       'Время'
&scop l-29-7       '№ пост-ки'
&scop l-29-8       'Статус'
&scop l-29-10      '№ заказа'
&scop l-29-11      'Тип'
&scop l-29-12      'Cсылка'
&scop l-29-13      'Цена ({&abbr_rub}.)'
&scop l-29-14      'Кол-во(пост)'
&scop l-29-15      'Цена (пост)'

define variable handle-br-all as character EXTENT 100 no-undo .


&Scoped-define OPEN-QUERY-BROWSE-17-alt OPEN QUERY BROWSE-17 FOR EACH buf_clients ~
 WHERE ( buf_clients.sup-cons = true ~
 OR buf_clients.sup-gds = true ) NO-LOCK, ~
 FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code ~
 AND ub.cli-gds.cli-type = buf_clients.obj-type and ub.cli-gds.host-code = g#host-code and  ~
  ub.cli-gds.artic = x-artic and ~
  ub.cli-gds.prod-type = x-prod-type and ~
  ub.cli-gds.prod-code = x-prod-code ~
 OUTER-JOIN NO-LOCK.


&Scoped-define OPEN-QUERY-BROWSE-29-alt OPEN QUERY BROWSE-29 FOR EACH ub.new-rcv ~
      WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,~
      EACH ub.ord-line-rcv WHERE ~
                      ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND ~
                          ub.ord-line-rcv.doc-code = new-rcv.doc-code NO-LOCK,~
      FIRST ub.bb_ord-doc WHERE bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK .


&Scoped-define OPEN-QUERY-BROWSE-14-alt OPEN QUERY BROWSE-14 ~
FOR EACH my-obj  , ~
    EACH buf_gds-obj ~
        WHERE x-artic = buf_gds-obj.artic     and ~
         x-prod-type  = buf_gds-obj.prod-type and ~
         x-prod-code  = buf_gds-obj.prod-code and ~
         buf_gds-obj.obj-code = my-obj.obj-code and ~
         buf_gds-obj.obj-type = my-obj.obj-type  OUTER-JOIN NO-LOCK.

define new shared variable x-mode as character  no-undo .
define variable mark     as char no-undo.
define variable str-status  as char no-undo.
define variable del-list as char no-undo.
define variable gg-recid as recid no-undo .
define variable loc-num-ord-FP as char no-undo .

&scop status-br-18 (IF (ub.ord-doc.status_ = ~{&fact} or ub.ord-doc.status_ = ~{&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-")) ~
                                                                    ELSE ~(ub.ord-doc.status_) )

&scop for-each-line   if bb_ord-doc.status_ <> ~{&ord-accept} then do: ~
         message "Документ " bb_ord-doc.doc-code "имеет статус" caps(bb_ord-doc.status_) "пропускаем." view-as alert-box .~
         next.~
    end. ~
assign bb_ord-doc.cons-code = loc-ord-cons-code .   ~
for each bb_ord-line where bb_ord-line.doc-code = bb_ord-doc.doc-code no-lock : ~
   if can-find (first bb_ord-gds-cons where bb_ord-gds-cons.cons-code = loc-ord-cons-code       and ~
                                  bb_ord-gds-cons.artic     = bb_ord-line.artic     and ~
                                  bb_ord-gds-cons.prod-code = bb_ord-line.prod-code and ~
                                  bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  no-lock ) then do:   ~
          for each bb_ord-gds-cons where bb_ord-gds-cons.cons-code = loc-ord-cons-code       and ~
                                  bb_ord-gds-cons.artic     = bb_ord-line.artic     and ~
                                  bb_ord-gds-cons.prod-code = bb_ord-line.prod-code and ~
                                  bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  exclusive-lock : ~
                bb_ord-gds-cons.sum-qnty = bb_ord-gds-cons.sum-qnty + bb_ord-line.qnty . ~
          end. ~
    end. ~
    else do: ~
        create bb_ord-gds-cons. ~
        Assign bb_ord-gds-cons.cons-code = loc-ord-cons-code      ~
                bb_ord-gds-cons.artic     = bb_ord-line.artic      ~
                bb_ord-gds-cons.prod-code = bb_ord-line.prod-code  ~
                bb_ord-gds-cons.prod-type = bb_ord-line.prod-type  ~
                bb_ord-gds-cons.sum-qnty  = bb_ord-line.qnty . ~
    end.  ~
   t-rec = recid(bb_ord-gds-cons). ~
end.


&scop OPEN-QUERY-BROWSE-28-alt OPEN QUERY BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE ~
          ub.ord-doc-rcv.cons-code = loc-ord-cons-code and ~
          ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ~
          ub.ord-doc-rcv.doc-type = {&l-out} NO-LOCK,~
        EACH ub.ord-line-rcv WHERE ~
                  ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and~
            ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and~
                  ( T-gds = true or (~
                         ub.ord-line-rcv.artic = tt-goods.artic~
                         and ub.ord-line-rcv.prod-code = tt-goods.prod-code~
                         and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,~
   EACH ub.goods where~
             ub.goods.artic = ub.ord-line-rcv.artic and~
             ub.goods.prod-code = ub.ord-line-rcv.prod-code and~
             ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-12

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-goods ub.ord-gds-cons ub.m_ord-line ~
ub.ord-doc my-obj buf_gds-obj b-all_ord-doc-rcv ub.ord-chain ub.trn-doc ub.doc-line ~
ub.buf_clients ub.cli-gds ub.ord-doc tt-new-ord-line ub.goods ub.ord-line-rcv ~
new-rcv bb_ord-doc ub.ord-doc-rcv ub.shar-buf_ord-doc ub.of_ord-dtl ~
ub.of_ord-doc ub.gds-prt e_fp_ord-dtl e_fp_ord-doc ub.gds-prt e_fp_ord-dtl-rcv ~
e_fp_ord-doc-rcv l_rcv_ord-dtl-rcv l_rcv_ord-doc-rcv l_rcv_gds-dtl ~
l_rcv_trn-doc obj_ord-dtl-rcv obj_ord-doc-rcv obj_prt-obj

/* Definitions for BROWSE BROWSE-12                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-12 tt-goods.use tt-goods.artic tt-goods.gds-name tt-goods.sum-qnty tt-goods.sum-ord tt-goods.sum-rcv tt-goods.sum-rcv-in tt-goods.unit-base tt-goods.unit-cli tt-goods.sum-fact
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-12 tt-goods.artic
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-12 tt-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-12 tt-goods
&Scoped-define SELF-NAME BROWSE-12
&Scoped-define QUERY-STRING-BROWSE-12 FOR EACH tt-goods where tt-goods.gds-t = {&h-goods} NO-LOCK, ~
             EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn
&Scoped-define OPEN-QUERY-BROWSE-12 OPEN QUERY {&SELF-NAME} FOR EACH tt-goods where tt-goods.gds-t = {&h-goods} NO-LOCK, ~
             EACH ub.ord-gds-cons where            ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code  NO-LOCK   by tt-goods.nn.
&Scoped-define TABLES-IN-QUERY-BROWSE-12 tt-goods ub.ord-gds-cons
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-12 tt-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-12 ub.ord-gds-cons


/* Definitions for BROWSE BROWSE-13                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-13 ~
ord-doc.obj-type + " " + STRING (ub.ord-doc.obj-code) m_ord-line.qnty ~
ub.ord-doc.ship-date string(ub.ord-doc.ship-time,"HH:MM") ~
IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) ~
m_ord-line.doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-13
&Scoped-define QUERY-STRING-BROWSE-13 FOR EACH ub.m_ord-line ~
      WHERE x-artic      = m_ord-line.artic and ~
x-prod-type  = m_ord-line.prod-type and ~
x-prod-code  = m_ord-line.prod-code ~
 NO-LOCK, ~
      EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code ~
      AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = {&o-f} NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-13 OPEN QUERY BROWSE-13 FOR EACH ub.m_ord-line ~
      WHERE x-artic      = m_ord-line.artic and ~
x-prod-type  = m_ord-line.prod-type and ~
x-prod-code  = m_ord-line.prod-code ~
 NO-LOCK, ~
      EACH ub.ord-doc WHERE ub.ord-doc.doc-code = m_ord-line.doc-code ~
      AND ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = {&o-f} NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-13 ub.m_ord-line ub.ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-13 ub.m_ord-line
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-13 ub.ord-doc


/* Definitions for BROWSE BROWSE-14                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-14 my-obj.obj-type + " " + STRING (my-obj.obj-code) buf_gds-obj.fact-qnty my-obj.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-14
&Scoped-define SELF-NAME BROWSE-14
&Scoped-define QUERY-STRING-BROWSE-14 FOR EACH my-obj NO-LOCK, ~
             EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-14 OPEN QUERY {&SELF-NAME} FOR EACH my-obj NO-LOCK, ~
             EACH buf_gds-obj where              my-obj.obj-code = buf_gds-obj.obj-code and                       my-obj.obj-type = buf_gds-obj.obj-type and                   x-artic      = buf_gds-obj.artic     and             x-prod-type  = buf_gds-obj.prod-type and             x-prod-code  = buf_gds-obj.prod-code       NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-14 my-obj buf_gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-14 my-obj
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-14 buf_gds-obj


/* Definitions for BROWSE BROWSE-15                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-15 ub.trn-doc.doc-code ub.trn-doc.doc-type ub.doc-line.doc-qnty ub.trn-doc.cli-type + " " + string(trn-doc.cli-code) ub.trn-doc.status_ ub.trn-doc.obj-type + " " + string(trn-doc.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-15 ub.trn-doc.doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-15 ub.trn-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-15 ub.trn-doc
&Scoped-define SELF-NAME BROWSE-15
&Scoped-define QUERY-STRING-BROWSE-15 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK, ~
             EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            , ~
             EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK, ~
             EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-15 OPEN QUERY {&SELF-NAME} FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND             b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK, ~
             EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                    and            ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            , ~
             EACH ub.trn-doc WHERE            ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK, ~
             EACH ub.doc-line WHERE         ub.doc-line.doc-code   = ub.trn-doc.doc-code AND         ub.doc-line.artic      = x-artic and         ub.doc-line.prod-type  = x-prod-type and         ub.doc-line.prod-code  = x-prod-code         NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-15 b-all_ord-doc-rcv ub.ord-chain ~
ub.trn-doc ub.doc-line
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-15 b-all_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-15 ub.ord-chain
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-15 ub.trn-doc
&Scoped-define FOURTH-TABLE-IN-QUERY-BROWSE-15 ub.doc-line


/* Definitions for BROWSE BROWSE-16                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-16 ~
ord-doc.obj-type + " " + string(ub.ord-doc.obj-code) ub.ord-doc.doc-code ~
ub.ord-doc.ship-date string(ub.ord-doc.ship-time,"HH:MM") ~
IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-16
&Scoped-define QUERY-STRING-BROWSE-16 FOR EACH ub.ord-doc ~
      WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = {&O-F} NO-LOCK ~
    BY ub.ord-doc.obj-type ~
       BY ub.ord-doc.obj-code ~
        BY ub.ord-doc.ship-date ~
         BY ub.ord-doc.ship-time ~
          BY ub.ord-doc.doc-code DESCENDING
&Scoped-define OPEN-QUERY-BROWSE-16 OPEN QUERY BROWSE-16 FOR EACH ub.ord-doc ~
      WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = {&O-F} NO-LOCK ~
    BY ub.ord-doc.obj-type ~
       BY ub.ord-doc.obj-code ~
        BY ub.ord-doc.ship-date ~
         BY ub.ord-doc.ship-time ~
          BY ub.ord-doc.doc-code DESCENDING.
&Scoped-define TABLES-IN-QUERY-BROWSE-16 ub.ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-16 ub.ord-doc


/* Definitions for BROWSE BROWSE-17                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-17 ~
buf_clients.obj-type + " " + string(buf_clients.obj-code) ~
ub.cli-gds.price-cli buf_clients.obj-name ub.cli-gds.cancel-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-17
&Scoped-define QUERY-STRING-BROWSE-17 FOR EACH ub.buf_clients ~
      WHERE ( buf_clients.sup-cons = true ~
 OR buf_clients.sup-gds = true ) NO-LOCK, ~
      FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code ~
  AND ub.cli-gds.cli-type = buf_clients.obj-type ~
      AND ub.cli-gds.artic = x-artic and ~
cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and ~
cli-gds.prod-code = x-prod-code  NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-17 OPEN QUERY BROWSE-17 FOR EACH ub.buf_clients ~
      WHERE ( buf_clients.sup-cons = true ~
 OR buf_clients.sup-gds = true ) NO-LOCK, ~
      FIRST ub.cli-gds WHERE ub.cli-gds.cli-code = buf_clients.obj-code ~
  AND ub.cli-gds.cli-type = buf_clients.obj-type ~
      AND ub.cli-gds.artic = x-artic and ~
cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and ~
cli-gds.prod-code = x-prod-code  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-17 ub.buf_clients ub.cli-gds
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-17 ub.buf_clients
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-17 ub.cli-gds


/* Definitions for BROWSE BROWSE-18                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-18 {&c-18-1} @ mark {&c-18-2} {&c-18-3} {&c-18-4} {&c-18-6} {&c-18-7} @ str-status {&c-18-8} {&c-18-9}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-18 {&c-18-3}
&Scoped-define SELF-NAME BROWSE-18
&Scoped-define QUERY-STRING-BROWSE-18 FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = {&f-p}         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK, ~
         EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK, ~
         EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-18 OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc       WHERE ub.ord-doc.cons-code = loc-ord-cons-code         and ub.ord-doc.doc-type = {&f-p}         and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code                      and ub.ord-doc.cli-type = buf_clients.obj-type))         and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))         NO-LOCK, ~
         EACH tt-new-ord-line       WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code         and ( T-gds = true or (                 tt-new-ord-line.artic = tt-goods.artic         and tt-new-ord-line.prod-code = tt-goods.prod-code         and tt-new-ord-line.prod-type = tt-goods.prod-type))         NO-LOCK, ~
         EACH ub.goods where              ub.goods.artic = tt-new-ord-line.artic and              ub.goods.prod-code = tt-new-ord-line.prod-code and              ub.goods.prod-type = tt-new-ord-line.prod-type              NO-LOCK             .
&Scoped-define TABLES-IN-QUERY-BROWSE-18 ub.ord-doc tt-new-ord-line ~
ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-18 ub.ord-doc
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-18 tt-new-ord-line
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-18 ub.goods


/* Definitions for BROWSE BROWSE-20                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-20 {&c-20-1} {&l-20-1} {&c-20-2} {&c-20-3} {&c-20-4} {&l-20-4} {&c-20-5} {&c-20-6} {&l-20-6} {&c-20-7} {&c-20-8} {&c-20-9}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-20 {&c-20-1}
&Scoped-define SELF-NAME BROWSE-20
&Scoped-define QUERY-STRING-BROWSE-20 FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK, ~
       EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-20 OPEN QUERY {&SELF-NAME} FOR EACH b-all_ord-doc-rcv  WHERE b-all_ord-doc-rcv.doc-type     = 'in':U and b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK, ~
       EACH ub.ord-line-rcv WHERE                 b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and         x-artic          = ub.ord-line-rcv.artic and         x-prod-type  = ub.ord-line-rcv.prod-type and         x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-20 b-all_ord-doc-rcv ub.ord-line-rcv
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-20 b-all_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-20 ub.ord-line-rcv


/* Definitions for BROWSE BROWSE-21                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-21 new-rcv.rcv-code new-rcv.doc-code new-rcv.obj-type + " " + string(new-rcv.obj-code) new-rcv.ship-date new-rcv.fact-date string(new-rcv.ship-time,"HH:MM") IF (new-rcv.status_ = {&fact} or new-rcv.status_ = {&ord-close}) THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-")) ELSE (new-rcv.status_) IF (new-rcv.doc-type = "in":U) THEN ("внут") ELSE ("внеш")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-21
&Scoped-define SELF-NAME BROWSE-21
&Scoped-define QUERY-STRING-BROWSE-21 FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK, ~
             EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-21 OPEN QUERY {&SELF-NAME} FOR EACH new-rcv       WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK, ~
             EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code  OUTER-JOIN NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-21 new-rcv bb_ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-21 new-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-21 bb_ord-doc


/* Definitions for BROWSE BROWSE-22                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-22 ub.trn-doc.doc-code ub.trn-doc.doc-date ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) ub.trn-doc.cli-type + string( ub.trn-doc.cli-code) string(trn-doc.fact-time,"HH:MM") ub.trn-doc.fact-date ub.trn-doc.internal ub.trn-doc.out-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-22
&Scoped-define SELF-NAME BROWSE-22
&Scoped-define QUERY-STRING-BROWSE-22 for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn', ~
       EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-22 OPEN QUERY {&SELF-NAME} for each ub.ord-chain no-lock where         ub.ord-chain.doc-code = new-rcv.rcv-code and         ub.ord-chain.doc-type = 'rcv'            and         ub.ord-chain.rel-doc-type = 'trn', ~
       EACH ub.trn-doc       WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK .
&Scoped-define TABLES-IN-QUERY-BROWSE-22 ub.ord-chain ub.trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-22 ub.ord-chain
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-22 ub.trn-doc


/* Definitions for BROWSE BROWSE-23                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-23 ub.ord-doc-rcv.rcv-code ub.ord-doc-rcv.cli-type + " " + string(ub.ord-doc-rcv.cli-code) ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) ub.ord-doc-rcv.doc-date ub.ord-doc-rcv.fact-date ub.ord-doc-rcv.ship-date STRING (ub.ord-doc-rcv.ship-time,"HH:MM") IF (ub.ord-doc-rcv.status_ = {&fact} or ub.ord-doc-rcv.status_ = {&ord-close}) THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,"+/-")) ELSE (ub.ord-doc-rcv.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-23
&Scoped-define SELF-NAME BROWSE-23
&Scoped-define QUERY-STRING-BROWSE-23 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-23 OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-type = 'in'  AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-23 ub.ord-doc-rcv
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-23 ub.ord-doc-rcv


/* Definitions for BROWSE BROWSE-24                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-24 ub.trn-doc.doc-code ub.trn-doc.doc-type ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) ub.trn-doc.cli-type + " " + string(trn-doc.cli-code) ub.trn-doc.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-24
&Scoped-define SELF-NAME BROWSE-24
&Scoped-define QUERY-STRING-BROWSE-24 FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK, ~
             EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK, ~
             EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-24 OPEN QUERY {&SELF-NAME} FOR EACH b-all_ord-doc-rcv       WHERE b-all_ord-doc-rcv.doc-type = 'in' and             b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK, ~
             EACH ub.ord-chain WHERE            ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and            ub.ord-chain.doc-type = 'rcv'                  and            ub.ord-chain.rel-doc-type = 'trn' NO-LOCK, ~
             EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-24 b-all_ord-doc-rcv ub.ord-chain ~
ub.trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-24 b-all_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-24 ub.ord-chain
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-24 ub.trn-doc


/* Definitions for BROWSE BROWSE-26                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-26 ub.ord-doc.doc-code ~
ord-doc.cli-type + " " + string(ub.ord-doc.cli-code) ub.ord-doc.doc-date ~
ub.ord-doc.fact-date ub.ord-doc.ship-date ~
STRING (ub.ord-doc.ship-time,"HH:MM") ub.ord-doc.cli-name ~
IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-26 ub.ord-doc.doc-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-26 ub.ord-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-26 ub.ord-doc
&Scoped-define QUERY-STRING-BROWSE-26 FOR EACH ub.ord-doc ~
      WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ~
ub.ord-doc.doc-type = {&f-p} ~
and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code ~
and ub.ord-doc.cli-type = buf_clients.obj-type)) ~
 NO-LOCK, ~
      FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-26 OPEN QUERY BROWSE-26 FOR EACH ub.ord-doc ~
      WHERE ub.ord-doc.cons-code = loc-ord-cons-code and ~
ub.ord-doc.doc-type = {&f-p} ~
and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code ~
and ub.ord-doc.cli-type = buf_clients.obj-type)) ~
 NO-LOCK, ~
      FIRST ub.shar-buf_ord-doc WHERE shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-26 ub.ord-doc ub.shar-buf_ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-26 ub.ord-doc
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-26 ub.shar-buf_ord-doc


/* Definitions for BROWSE BROWSE-27                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-27 ub.ord-doc-rcv.rcv-code ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) ub.ord-doc-rcv.doc-code ub.ord-doc-rcv.doc-date ub.ord-doc-rcv.ship-date string(ub.ord-doc-rcv.ship-time,"HH:MM") ub.ord-doc-rcv.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-27 ub.ord-doc-rcv.rcv-code
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-27 ub.ord-doc-rcv
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-27 ub.ord-doc-rcv
&Scoped-define SELF-NAME BROWSE-27
&Scoped-define QUERY-STRING-BROWSE-27 FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = {&l-out}       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-27 OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc-rcv       WHERE ub.ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = {&l-out}       and ub.ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-27 ub.ord-doc-rcv
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-27 ub.ord-doc-rcv


/* Definitions for BROWSE BROWSE-28                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-28 ub.ord-doc-rcv.rcv-code ub.ord-line-rcv.qnty ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) ub.ord-line-rcv.price-rubl ub.ord-line-rcv.cli-qnty ub.ord-line-rcv.price-cli ub.ord-doc-rcv.ship-date ub.ord-line-rcv.artic ub.ord-doc-rcv.doc-code IF (ub.ord-doc-rcv.status_ = {&fact} or ub.ord-doc-rcv.status_ = {&ord-close}) THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,"+/-")) ELSE (ub.ord-doc-rcv.status_) ub.goods.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-28 ub.ord-line-rcv.cli-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-28 ub.ord-line-rcv
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-28 ub.ord-line-rcv
&Scoped-define SELF-NAME BROWSE-28
&Scoped-define QUERY-STRING-BROWSE-28 FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = {&l-out} NO-LOCK, ~
           EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK, ~
            EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     ub.goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-28 OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc-rcv WHERE   ub.ord-doc-rcv.cons-code = loc-ord-cons-code and   ub.ord-doc-rcv.doc-type = {&l-out} NO-LOCK, ~
           EACH ub.ord-line-rcv WHERE     ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and     ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and       ( T-gds = true or (     ub.ord-line-rcv.artic = tt-goods.artic     and ub.ord-line-rcv.prod-code = tt-goods.prod-code     and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK, ~
            EACH ub.goods where     ub.goods.artic = ub.ord-line-rcv.artic and     goods.prod-code = ub.ord-line-rcv.prod-code and     ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-28 ub.ord-doc-rcv ub.ord-line-rcv ~
ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-28 ub.ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-28 ub.ord-line-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-28 ub.goods


/* Definitions for BROWSE BROWSE-29                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-29 new-rcv.obj-type + " " + string(new-rcv.obj-code) ub.ord-line-rcv.qnty ub.ord-line-rcv.artic new-rcv.ship-date new-rcv.fact-date string(new-rcv.ship-time,"HH:MM") new-rcv.rcv-code IF (new-rcv.status_ = {&fact} or new-rcv.status_ = {&ord-close}) THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-")) ELSE (new-rcv.status_) new-rcv.doc-code IF (new-rcv.doc-type = 'in':U) THEN ('внут') ELSE ('внеш') ub.ord-line-rcv.price-rubl ub.ord-line-rcv.cli-qnty ub.ord-line-rcv.price-cli
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-29 ub.ord-line-rcv.qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-29 ub.ord-line-rcv
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-29 ub.ord-line-rcv
&Scoped-define SELF-NAME BROWSE-29
&Scoped-define QUERY-STRING-BROWSE-29 FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK, ~
             EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK, ~
             FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-29 OPEN QUERY {&SELF-NAME} FOR       EACH new-rcv WHERE            new-rcv.cons-code = loc-ord-cons-code NO-LOCK, ~
             EACH ub.ord-line-rcv WHERE             ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND             ub.ord-line-rcv.doc-code = new-rcv.doc-code AND             ub.ord-line-rcv.artic = tt-goods.artic and             ub.ord-line-rcv.prod-code = tt-goods.prod-code and             ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK, ~
             FIRST bb_ord-doc WHERE             bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-29 new-rcv ub.ord-line-rcv bb_ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-29 new-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-29 ub.ord-line-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-29 bb_ord-doc


/* Definitions for BROWSE BROWSE-30                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-30 tt-goods.use tt-goods.artic tt-goods.all-name tt-goods.sum-qnty tt-goods.sum-ord tt-goods.sum-rcv tt-goods.sum-rcv-in tt-goods.unit-base tt-goods.unit-cli tt-goods.sum-fact tt-goods.gds-t
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-30 tt-goods.artic
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-30 tt-goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-30 tt-goods
&Scoped-define SELF-NAME BROWSE-30
&Scoped-define QUERY-STRING-BROWSE-30 FOR EACH tt-goods  NO-LOCK, ~
             EACH ub.ord-gds-cons where             ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code   OUTER-JOIN   NO-LOCK     by tt-goods.nn
&Scoped-define OPEN-QUERY-BROWSE-30 OPEN QUERY {&SELF-NAME} FOR EACH tt-goods  NO-LOCK, ~
             EACH ub.ord-gds-cons where             ub.ord-gds-cons.artic = tt-goods.artic   AND ub.ord-gds-cons.prod-code = tt-goods.prod-code   AND ub.ord-gds-cons.prod-type = tt-goods.prod-type   AND ub.ord-gds-cons.cons-code = loc-ord-cons-code   OUTER-JOIN   NO-LOCK     by tt-goods.nn .
&Scoped-define TABLES-IN-QUERY-BROWSE-30 tt-goods ub.ord-gds-cons
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-30 tt-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-30 ub.ord-gds-cons


/* Definitions for BROWSE BROWSE-31                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-31 of_ord-dtl.doc-code ~
ub.gds-prt.f-name of_ord-dtl.qnty ~
of_ord-doc.obj-type + " " + string(of_ord-doc.obj-code) ~
IF (of_ord-doc.status_ = {&fact} or of_ord-doc.status_ = {&ord-close})  THEN (of_ord-doc.status_ + string(of_ord-doc.flag_,"+/-"))  ELSE (of_ord-doc.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-31
&Scoped-define QUERY-STRING-BROWSE-31 FOR EACH ub.of_ord-dtl ~
      WHERE x-artic      = of_ord-dtl.artic and ~
x-prod-type  = of_ord-dtl.prod-type and ~
x-prod-code  = of_ord-dtl.prod-code and ~
string(of_ord-dtl.node-code) MATCHES x-node-code NO-LOCK, ~
      EACH ub.of_ord-doc OF ub.of_ord-dtl ~
      WHERE of_ord-doc.cons-code = loc-ord-cons-code and of_ord-doc.doc-type = {&o-f} NO-LOCK, ~
      EACH ub.gds-prt WHERE ub.gds-prt.node-code = of_ord-dtl.node-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-31 OPEN QUERY BROWSE-31 FOR EACH ub.of_ord-dtl ~
      WHERE x-artic      = of_ord-dtl.artic and ~
x-prod-type  = of_ord-dtl.prod-type and ~
x-prod-code  = of_ord-dtl.prod-code and ~
string(of_ord-dtl.node-code) MATCHES x-node-code NO-LOCK, ~
      EACH ub.of_ord-doc OF ub.of_ord-dtl ~
      WHERE of_ord-doc.cons-code = loc-ord-cons-code and of_ord-doc.doc-type = {&o-f} NO-LOCK, ~
      EACH ub.gds-prt WHERE ub.gds-prt.node-code = of_ord-dtl.node-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-31 ub.of_ord-dtl ub.of_ord-doc ~
ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-31 ub.of_ord-dtl
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-31 ub.of_ord-doc
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-31 ub.gds-prt


/* Definitions for BROWSE BROWSE-32                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-32 e_fp_ord-doc.doc-code ub.gds-prt.f-name e_fp_ord-dtl.qnty e_fp_ord-doc.cli-type + " " + string(e_fp_ord-doc.cli-code) e_fp_ord-doc.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-32
&Scoped-define SELF-NAME BROWSE-32
&Scoped-define QUERY-STRING-BROWSE-32 FOR EACH e_fp_ord-dtl       WHERE x-artic      = e_fp_ord-dtl.artic and x-prod-type  = e_fp_ord-dtl.prod-type and x-prod-code  = e_fp_ord-dtl.prod-code and string(e_fp_ord-dtl.node-code) MATCHES x-node-code NO-LOCK, ~
             EACH e_fp_ord-doc OF e_fp_ord-dtl where                        e_fp_ord-doc.cons-code = loc-ord-cons-code and                        e_fp_ord-doc.doc-type = {&f-p}                       NO-LOCK, ~
             first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl.node-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-32 OPEN QUERY {&SELF-NAME} FOR EACH e_fp_ord-dtl       WHERE x-artic      = e_fp_ord-dtl.artic and x-prod-type  = e_fp_ord-dtl.prod-type and x-prod-code  = e_fp_ord-dtl.prod-code and string(e_fp_ord-dtl.node-code) MATCHES x-node-code NO-LOCK, ~
             EACH e_fp_ord-doc OF e_fp_ord-dtl where                        e_fp_ord-doc.cons-code = loc-ord-cons-code and                        e_fp_ord-doc.doc-type = {&f-p}                       NO-LOCK, ~
             first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl.node-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-32 e_fp_ord-dtl e_fp_ord-doc ~
ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-32 e_fp_ord-dtl
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-32 e_fp_ord-doc
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-32 ub.gds-prt


/* Definitions for BROWSE BROWSE-33                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-33 e_fp_ord-dtl-rcv.rcv-code ub.gds-prt.f-name e_fp_ord-dtl-rcv.qnty e_fp_ord-dtl-rcv.doc-code e_fp_ord-doc-rcv.cli-code e_fp_ord-doc-rcv.cli-type e_fp_ord-doc-rcv.obj-type + " " + string(e_fp_ord-doc-rcv.obj-code) e_fp_ord-doc-rcv.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-33
&Scoped-define SELF-NAME BROWSE-33
&Scoped-define QUERY-STRING-BROWSE-33 FOR EACH e_fp_ord-dtl-rcv               WHERE x-artic      = e_fp_ord-dtl-rcv.artic and                     x-prod-type  = e_fp_ord-dtl-rcv.prod-type and                     x-prod-code  = e_fp_ord-dtl-rcv.prod-code and                     string(e_fp_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK, ~
             EACH e_fp_ord-doc-rcv                              where e_fp_ord-doc-rcv.rcv-code            = e_fp_ord-dtl-rcv.rcv-code and                                               e_fp_ord-doc-rcv.doc-code     = e_fp_ord-dtl-rcv.doc-code and                        e_fp_ord-doc-rcv.cons-code  = loc-ord-cons-code and                        e_fp_ord-doc-rcv.doc-type    = "out":U                       NO-LOCK, ~
             first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl-rcv.node-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-33 OPEN QUERY {&SELF-NAME} FOR EACH e_fp_ord-dtl-rcv               WHERE x-artic      = e_fp_ord-dtl-rcv.artic and                     x-prod-type  = e_fp_ord-dtl-rcv.prod-type and                     x-prod-code  = e_fp_ord-dtl-rcv.prod-code and                     string(e_fp_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK, ~
             EACH e_fp_ord-doc-rcv                              where e_fp_ord-doc-rcv.rcv-code            = e_fp_ord-dtl-rcv.rcv-code and                                               e_fp_ord-doc-rcv.doc-code     = e_fp_ord-dtl-rcv.doc-code and                        e_fp_ord-doc-rcv.cons-code  = loc-ord-cons-code and                        e_fp_ord-doc-rcv.doc-type    = "out":U                       NO-LOCK, ~
             first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl-rcv.node-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-33 e_fp_ord-dtl-rcv e_fp_ord-doc-rcv ~
ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-33 e_fp_ord-dtl-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-33 e_fp_ord-doc-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-33 ub.gds-prt


/* Definitions for BROWSE BROWSE-34                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-34 l_rcv_ord-dtl-rcv.rcv-code IF (l_rcv_ord-doc-rcv.doc-type = "in":U) THEN ("внут") ELSE ("внеш") ub.gds-prt.f-name l_rcv_ord-dtl-rcv.qnty l_rcv_ord-doc-rcv.cli-type + " " + STRING (l_rcv_ord-doc-rcv.cli-code) l_rcv_ord-doc-rcv.obj-type + " " + STRING (l_rcv_ord-doc-rcv.obj-code) IF (l_rcv_ord-doc-rcv.status_ = {&fact} or l_rcv_ord-doc-rcv.status_ = {&ord-close}) THEN (l_rcv_ord-doc-rcv.status_ + string(l_rcv_ord-doc-rcv.flag_,"+/-")) ELSE (l_rcv_ord-doc-rcv.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-34
&Scoped-define SELF-NAME BROWSE-34
&Scoped-define QUERY-STRING-BROWSE-34 FOR EACH l_rcv_ord-dtl-rcv               WHERE x-artic      = l_rcv_ord-dtl-rcv.artic and                     x-prod-type  = l_rcv_ord-dtl-rcv.prod-type and                     x-prod-code  = l_rcv_ord-dtl-rcv.prod-code and                     string(l_rcv_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK, ~
             EACH l_rcv_ord-doc-rcv             where l_rcv_ord-doc-rcv.rcv-code     = l_rcv_ord-dtl-rcv.rcv-code and                    l_rcv_ord-doc-rcv.doc-code   = l_rcv_ord-dtl-rcv.doc-code and                    l_rcv_ord-doc-rcv.cons-code  = loc-ord-cons-code                    NO-LOCK, ~
             first ub.gds-prt WHERE ub.gds-prt.node-code = l_rcv_ord-dtl-rcv.node-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-34 OPEN QUERY {&SELF-NAME} FOR EACH l_rcv_ord-dtl-rcv               WHERE x-artic      = l_rcv_ord-dtl-rcv.artic and                     x-prod-type  = l_rcv_ord-dtl-rcv.prod-type and                     x-prod-code  = l_rcv_ord-dtl-rcv.prod-code and                     string(l_rcv_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK, ~
             EACH l_rcv_ord-doc-rcv             where l_rcv_ord-doc-rcv.rcv-code     = l_rcv_ord-dtl-rcv.rcv-code and                    l_rcv_ord-doc-rcv.doc-code   = l_rcv_ord-dtl-rcv.doc-code and                    l_rcv_ord-doc-rcv.cons-code  = loc-ord-cons-code                    NO-LOCK, ~
             first ub.gds-prt WHERE ub.gds-prt.node-code = l_rcv_ord-dtl-rcv.node-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-34 l_rcv_ord-dtl-rcv ~
l_rcv_ord-doc-rcv ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-34 l_rcv_ord-dtl-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-34 l_rcv_ord-doc-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-34 ub.gds-prt


/* Definitions for BROWSE BROWSE-35                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-35 l_rcv_gds-dtl.doc-code ub.gds-prt.f-name l_rcv_gds-dtl.doc-qnty l_rcv_gds-dtl.fact-qnty l_rcv_trn-doc.obj-type + " " + STRING (l_rcv_trn-doc.obj-code) l_rcv_trn-doc.cli-type + " " + STRING (l_rcv_trn-doc.cli-code) l_rcv_trn-doc.doc-type IF (l_rcv_trn-doc.status_ = {&fact} or l_rcv_trn-doc.status_ = {&ord-close}) THEN (l_rcv_trn-doc.status_ + string(l_rcv_trn-doc.flag_,"+/-")) ELSE (l_rcv_trn-doc.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-35
&Scoped-define SELF-NAME BROWSE-35
&Scoped-define QUERY-STRING-BROWSE-35 FOR EACH l_rcv_gds-dtl     WHERE x-artic      = l_rcv_gds-dtl.artic and           x-prod-type  = l_rcv_gds-dtl.prod-type and           x-prod-code  = l_rcv_gds-dtl.prod-code and           string(l_rcv_gds-dtl.prt-code) MATCHES x-node-code NO-LOCK, ~
             EACH l_rcv_trn-doc where             l_rcv_trn-doc.doc-code   = l_rcv_gds-dtl.doc-code NO-LOCK, ~
             each ub.gds-prt WHERE            ub.gds-prt.node-code = l_rcv_gds-dtl.prt-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-35 OPEN QUERY {&SELF-NAME} FOR EACH l_rcv_gds-dtl     WHERE x-artic      = l_rcv_gds-dtl.artic and           x-prod-type  = l_rcv_gds-dtl.prod-type and           x-prod-code  = l_rcv_gds-dtl.prod-code and           string(l_rcv_gds-dtl.prt-code) MATCHES x-node-code NO-LOCK, ~
             EACH l_rcv_trn-doc where             l_rcv_trn-doc.doc-code   = l_rcv_gds-dtl.doc-code NO-LOCK, ~
             each ub.gds-prt WHERE            ub.gds-prt.node-code = l_rcv_gds-dtl.prt-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-35 l_rcv_gds-dtl l_rcv_trn-doc ~
ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-35 l_rcv_gds-dtl
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-35 l_rcv_trn-doc
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-35 ub.gds-prt


/* Definitions for BROWSE BROWSE-36                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-36 obj_ord-dtl-rcv.rcv-code ub.gds-prt.f-name obj_ord-dtl-rcv.qnty obj_ord-doc-rcv.cli-type + " " + STRING (obj_ord-doc-rcv.cli-code) obj_ord-doc-rcv.obj-type + " " + STRING (obj_ord-doc-rcv.obj-code) IF (obj_ord-doc-rcv.status_ = {&fact} or obj_ord-doc-rcv.status_ = {&ord-close}) THEN (obj_ord-doc-rcv.status_ + string(obj_ord-doc-rcv.flag_,"+/-")) ELSE (obj_ord-doc-rcv.status_)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-36
&Scoped-define SELF-NAME BROWSE-36
&Scoped-define QUERY-STRING-BROWSE-36 FOR EACH obj_ord-dtl-rcv     WHERE x-artic      = obj_ord-dtl-rcv.artic and           x-prod-type  = obj_ord-dtl-rcv.prod-type and           x-prod-code  = obj_ord-dtl-rcv.prod-code and           string(obj_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK, ~
           EACH obj_ord-doc-rcv           where obj_ord-doc-rcv.rcv-code     = obj_ord-dtl-rcv.rcv-code and                   obj_ord-doc-rcv.doc-code   = obj_ord-dtl-rcv.doc-code and                   obj_ord-doc-rcv.doc-type   = 'in' and                   obj_ord-doc-rcv.cons-code  = loc-ord-cons-code                  NO-LOCK, ~
         first ub.gds-prt WHERE ub.gds-prt.node-code = obj_ord-dtl-rcv.node-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-36 OPEN QUERY {&SELF-NAME} FOR EACH obj_ord-dtl-rcv     WHERE x-artic      = obj_ord-dtl-rcv.artic and           x-prod-type  = obj_ord-dtl-rcv.prod-type and           x-prod-code  = obj_ord-dtl-rcv.prod-code and           string(obj_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK, ~
           EACH obj_ord-doc-rcv           where obj_ord-doc-rcv.rcv-code     = obj_ord-dtl-rcv.rcv-code and                   obj_ord-doc-rcv.doc-code   = obj_ord-dtl-rcv.doc-code and                   obj_ord-doc-rcv.doc-type   = 'in' and                   obj_ord-doc-rcv.cons-code  = loc-ord-cons-code                  NO-LOCK, ~
         first ub.gds-prt WHERE ub.gds-prt.node-code = obj_ord-dtl-rcv.node-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-36 obj_ord-dtl-rcv obj_ord-doc-rcv ~
ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-36 obj_ord-dtl-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-36 obj_ord-doc-rcv
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-36 ub.gds-prt


/* Definitions for BROWSE BROWSE-37                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-37 obj_prt-obj.obj-type + " " + STRING (obj_prt-obj.obj-code) ub.gds-prt.f-name obj_prt-obj.fact-qnty obj_prt-obj.free-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-37
&Scoped-define SELF-NAME BROWSE-37
&Scoped-define QUERY-STRING-BROWSE-37 FOR EACH obj_prt-obj               WHERE obj_prt-obj.is-term = true and                           x-artic      = obj_prt-obj.artic and                     x-prod-type  = obj_prt-obj.prod-type and                     x-prod-code  = obj_prt-obj.prod-code and                     string(obj_prt-obj.prt-code) MATCHES x-node-code NO-LOCK, ~
             each ub.gds-prt WHERE ub.gds-prt.node-code = obj_prt-obj.prt-code NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-37 OPEN QUERY {&SELF-NAME} FOR EACH obj_prt-obj               WHERE obj_prt-obj.is-term = true and                           x-artic      = obj_prt-obj.artic and                     x-prod-type  = obj_prt-obj.prod-type and                     x-prod-code  = obj_prt-obj.prod-code and                     string(obj_prt-obj.prt-code) MATCHES x-node-code NO-LOCK, ~
             each ub.gds-prt WHERE ub.gds-prt.node-code = obj_prt-obj.prt-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-37 obj_prt-obj ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-37 obj_prt-obj
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-37 ub.gds-prt


/* Definitions for FRAME FRAME-A                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-A ~
    ~{&OPEN-QUERY-BROWSE-12}

/* Definitions for FRAME FRAME-B                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-B ~
    ~{&OPEN-QUERY-BROWSE-14}

/* Definitions for FRAME FRAME-B-prt                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-B-prt ~
    ~{&OPEN-QUERY-BROWSE-36}~
    ~{&OPEN-QUERY-BROWSE-37}

/* Definitions for FRAME FRAME-C                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-C ~
    ~{&OPEN-QUERY-BROWSE-30}

/* Definitions for FRAME FRAME-D                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-D ~
    ~{&OPEN-QUERY-BROWSE-13}

/* Definitions for FRAME FRAME-d-prt                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-d-prt ~
    ~{&OPEN-QUERY-BROWSE-31}

/* Definitions for FRAME FRAME-E                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-E ~
    ~{&OPEN-QUERY-BROWSE-17}

/* Definitions for FRAME FRAME-E-prt                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-E-prt ~
    ~{&OPEN-QUERY-BROWSE-32}~
    ~{&OPEN-QUERY-BROWSE-33}

/* Definitions for FRAME FRAME-F                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-F ~
    ~{&OPEN-QUERY-BROWSE-16}

/* Definitions for FRAME FRAME-H                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-H ~
    ~{&OPEN-QUERY-BROWSE-15}~
    ~{&OPEN-QUERY-BROWSE-20}

/* Definitions for FRAME FRAME-I                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-I ~
    ~{&OPEN-QUERY-BROWSE-23}~
    ~{&OPEN-QUERY-BROWSE-24}

/* Definitions for FRAME FRAME-J                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-J ~
    ~{&OPEN-QUERY-BROWSE-18}~
    ~{&OPEN-QUERY-BROWSE-28}

/* Definitions for FRAME FRAME-K                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-K ~
    ~{&OPEN-QUERY-BROWSE-26}~
    ~{&OPEN-QUERY-BROWSE-27}

/* Definitions for FRAME FRAME-Post-prt                                 */

/* Definitions for FRAME FRAME-Postavki                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-Postavki ~
    ~{&OPEN-QUERY-BROWSE-21}~
    ~{&OPEN-QUERY-BROWSE-22}~
    ~{&OPEN-QUERY-BROWSE-29}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Help BUTTON-2 R-main BUTTON-3 ~
BUTTON-47 str-good F-post-2 F-post F-obj RECT-3
&Scoped-Define DISPLAYED-OBJECTS R-main str-good F-post-2 F-post F-obj

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc-t-doc_ord-line for tt-new-ord-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-make-post-ex-2
       MENU-ITEM m_J_1          LABEL "Сделать заказ ФП по тек.товару"
       MENU-ITEM m_J_4          LABEL "Сделать заказ ФП по товарам(*)"
       RULE
       MENU-ITEM m_J_2          LABEL "Сделать поставку внешнюю   по тек.товару"
       MENU-ITEM m_k_4          LABEL "Сделать поставку по товарам(+) из заказа".

DEFINE MENU POPUP-MENU-B-make-post-ex-3
       MENU-ITEM m_k_2          LABEL "Сделать заказ ФП по заявке  ОФ"
       RULE
       MENU-ITEM m_k_5          LABEL "Сделать поставку по заказу с учетом заявок"
       MENU-ITEM m_k_3          LABEL "Сделать поставку внешнюю по заказу".

DEFINE MENU POPUP-MENU-B-make-trn
       MENU-ITEM m_cr_post      LABEL "Сделать   ПН/РН по поставке"
       MENU-ITEM m_post_1       LABEL "Привязать ПН/РН к  поставке"
       MENU-ITEM m_d_post       LABEL "Отменить привязку  к  ПН/РН".

DEFINE MENU POPUP-MENU-B-make-trn-2
       MENU-ITEM m_H_0          LABEL "Сделать поставку по тек.товару"
       MENU-ITEM m_H_2          LABEL "Сделать поставку по товарам(*)"
       RULE
       MENU-ITEM m_H_3          LABEL "Сделать   РН по поставке товара".

DEFINE MENU POPUP-MENU-BUTTON-48
       MENU-ITEM m_I_4          LABEL "Сделать поставку по заявке ОФ"
       RULE
       MENU-ITEM m_I_3          LABEL "Сделать   РН по поставке"
       MENU-ITEM m_post_2       LABEL "Привязать РН  к поставке".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 7 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "Выход"
     SIZE 7 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-2
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&1.Перемещ."
     SIZE 14 BY 1.13.

DEFINE BUTTON BUTTON-3
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&2.Заказы"
     SIZE 14 BY 1.13.

DEFINE BUTTON BUTTON-47
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&3.Поставки"
     SIZE 14 BY 1.13.

DEFINE VARIABLE F-obj AS CHARACTER FORMAT "X(12)" INITIAL "&1.Перемещ."
      VIEW-AS TEXT
     SIZE 10.63 BY .54 NO-UNDO.

DEFINE VARIABLE F-post AS CHARACTER FORMAT "X(12)":U INITIAL "&3.Поставки"
      VIEW-AS TEXT
     SIZE 11 BY .54 NO-UNDO.

DEFINE VARIABLE F-post-2 AS CHARACTER FORMAT "X(12)":U INITIAL "&2.Заказы"
      VIEW-AS TEXT
     SIZE 12.38 BY .54 NO-UNDO.

DEFINE VARIABLE loc-ord-cons-code AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "№ СЗФП"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE str-good AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 84.25 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE R-main AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По документам", 1,
"По товарам", 2,
"По признакам", 3
     SIZE 44.63 BY .58 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99.88 BY 11.04
     FGCOLOR 15 .

DEFINE VARIABLE T-gds AS LOGICAL INITIAL no
     LABEL "развернуть"
     VIEW-AS TOGGLE-BOX
     SIZE 13.13 BY .58 TOOLTIP "Паказать все товары документа" NO-UNDO.

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Отметить товары".

DEFINE BUTTON B-mark-3
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".

DEFINE BUTTON B-mark-4
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "отметить все товары".

DEFINE VARIABLE T-obj AS LOGICAL INITIAL no
     LABEL "все"
     VIEW-AS TOGGLE-BOX
     SIZE 6 BY .58 NO-UNDO.

DEFINE BUTTON B-mark-5
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Отметить товары".

DEFINE BUTTON B-mark-6
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".

DEFINE BUTTON B-mark-7
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "отметить все товары".

DEFINE VARIABLE T-cli AS LOGICAL INITIAL no
     LABEL "все"
     VIEW-AS TOGGLE-BOX
     SIZE 6.38 BY .58 TOOLTIP "Показать Все поставщики/поставщики товара" NO-UNDO.

DEFINE VARIABLE T-cli-fp AS LOGICAL INITIAL no
     LABEL "по поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 16.13 BY .58 TOOLTIP "Показать Заказы по поставщику \ все заказы" NO-UNDO.

DEFINE BUTTON B-ins-za
     LABEL "Доб."
     SIZE 8 BY 1 TOOLTIP "Добавить заявку ОФ в СЗФП".

DEFINE BUTTON B-isk
     LABEL "Исключить"
     SIZE 9.63 BY 1 TOOLTIP "Исключить заявку из СЗФП".

DEFINE BUTTON B-reject
     LABEL "Отказать"
     SIZE 8.63 BY 1 TOOLTIP "Отказать заявке ОФ".

DEFINE BUTTON B-za-3
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "просмотр заявки ОФ".

DEFINE BUTTON B-make-trn-2
     LABEL "Сделать"
     SIZE 8 BY 1 TOOLTIP "Сделать документы".

DEFINE BUTTON BUTTON-14
     LABEL "Удал."
     SIZE 7 BY 1 TOOLTIP "Удалить строку накладной".

DEFINE BUTTON BUTTON-15
     LABEL "Изм."
     SIZE 7 BY 1 TOOLTIP "Изменение".

DEFINE BUTTON BUTTON-58
     LABEL "Просм."
     SIZE 7 BY 1 TOOLTIP "Просмотр строки поставки внутренней".

DEFINE BUTTON BUTTON-59
     LABEL "Просм."
     SIZE 7 BY 1 TOOLTIP "Просмотр строки накладной".

DEFINE BUTTON BUTTON-7
     LABEL "Изм."
     SIZE 7 BY 1 TOOLTIP "Изменить строку поставки".

DEFINE BUTTON BUTTON-8
     LABEL "Удал."
     SIZE 7 BY 1 TOOLTIP "Удалить строку поставки".

DEFINE BUTTON BUTTON-17
     LABEL "Изм."
     SIZE 8 BY 1 TOOLTIP "Изменить накладную".

DEFINE BUTTON BUTTON-18
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить накладную".

DEFINE BUTTON BUTTON-20
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить поставку".

DEFINE BUTTON BUTTON-21
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр".

DEFINE BUTTON BUTTON-48
     LABEL "Сделать"
     SIZE 9 BY 1 TOOLTIP "Сделать поставку".

DEFINE BUTTON BUTTON-57
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр внутренней поставки".

DEFINE BUTTON B-make-post-ex-2
     LABEL "Сделать"
     SIZE 8 BY .92 TOOLTIP "Сделать заказ ФП".

DEFINE BUTTON B-mark-2
     LABEL "+"
     SIZE 3 BY .92 TOOLTIP "Отметить товары, которые надо включить в поставку".

DEFINE BUTTON BUTTON-10
     LABEL "Удал."
     SIZE 7 BY .92 TOOLTIP "Удалить строку заказа".

DEFINE BUTTON BUTTON-33
     LABEL "Изм."
     SIZE 7 BY .92 TOOLTIP "Изменить строку поставки".

DEFINE BUTTON BUTTON-34
     LABEL "Удал."
     SIZE 7 BY .92 TOOLTIP "Удалить строку поставки".

DEFINE BUTTON BUTTON-55
     LABEL "Просм."
     SIZE 7 BY .92 TOOLTIP "Просмотр строки заказа".

DEFINE BUTTON BUTTON-56
     LABEL "Просм."
     SIZE 7 BY .92 TOOLTIP "Просмотреть строку поставки".

DEFINE BUTTON BUTTON-9
     LABEL "Изм."
     SIZE 7 BY .92 TOOLTIP "Изменить строку".

DEFINE BUTTON B-make-post-ex-3
     LABEL "Сделать"
     SIZE 8 BY 1 TOOLTIP "Сделать заказ ФП".

DEFINE BUTTON BUTTON-27
     LABEL "Изм."
     SIZE 8 BY 1 TOOLTIP "Изменить заказ".

DEFINE BUTTON BUTTON-28
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить строку заказа".

DEFINE BUTTON BUTTON-30
     LABEL "Изм."
     SIZE 7 BY 1 TOOLTIP "Изменить строку поставки".

DEFINE BUTTON BUTTON-31
     LABEL "Удал."
     SIZE 7 BY 1 TOOLTIP "Удалить строку поставки".

DEFINE BUTTON BUTTON-53
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр заказа".

DEFINE BUTTON BUTTON-54
     LABEL "Просм."
     SIZE 7 BY 1 TOOLTIP "Просмотреть поставку".

DEFINE BUTTON B-make-trn
     LABEL "Сделать"
     SIZE 9 BY 1 TOOLTIP "Сделать ПН по поставке".

DEFINE BUTTON BUTTON-49
     LABEL "Просм."
     SIZE 8 BY 1.

DEFINE BUTTON BUTTON-50
     LABEL "Изм."
     SIZE 8 BY 1.

DEFINE BUTTON BUTTON-51
     LABEL "Удал."
     SIZE 8 BY 1 TOOLTIP "Удалить накладную".

DEFINE BUTTON BUTTON-52
     LABEL "Просм."
     SIZE 8 BY 1 TOOLTIP "Просмотр поставки".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-12 FOR
      tt-goods,
      ub.ord-gds-cons SCROLLING.

DEFINE QUERY BROWSE-13 FOR
      ub.m_ord-line,
      ub.ord-doc SCROLLING.

DEFINE QUERY BROWSE-14 FOR
      my-obj,
      buf_gds-obj SCROLLING.

DEFINE QUERY BROWSE-15 FOR
      b-all_ord-doc-rcv,
      ub.ord-chain,
      ub.trn-doc,
      ub.doc-line SCROLLING.

DEFINE QUERY BROWSE-16 FOR
      ub.ord-doc SCROLLING.

DEFINE QUERY BROWSE-17 FOR
      ub.buf_clients,
      ub.cli-gds SCROLLING.

DEFINE QUERY BROWSE-18 FOR
      ub.ord-doc,
      tt-new-ord-line,
      ub.goods SCROLLING.

DEFINE QUERY BROWSE-20 FOR
      b-all_ord-doc-rcv,
      ub.ord-line-rcv SCROLLING.

DEFINE QUERY BROWSE-21 FOR
      new-rcv,
      bb_ord-doc SCROLLING.

DEFINE QUERY BROWSE-22 FOR
      ub.ord-chain,
      ub.trn-doc SCROLLING.

DEFINE QUERY BROWSE-23 FOR
      ub.ord-doc-rcv SCROLLING.

DEFINE QUERY BROWSE-24 FOR
      b-all_ord-doc-rcv,
      ub.ord-chain,
      ub.trn-doc SCROLLING.

DEFINE QUERY BROWSE-26 FOR
      ub.ord-doc,
      ub.shar-buf_ord-doc SCROLLING.

DEFINE QUERY BROWSE-27 FOR
      ub.ord-doc-rcv SCROLLING.

DEFINE QUERY BROWSE-28 FOR
      ub.ord-doc-rcv,
      ub.ord-line-rcv,
      ub.goods SCROLLING.

DEFINE QUERY BROWSE-29 FOR
      new-rcv,
      ub.ord-line-rcv,
      bb_ord-doc SCROLLING.

DEFINE QUERY BROWSE-30 FOR
      tt-goods,
      ub.ord-gds-cons SCROLLING.

DEFINE QUERY BROWSE-31 FOR
      ub.of_ord-dtl,
      ub.of_ord-doc,
      ub.gds-prt SCROLLING.

DEFINE QUERY BROWSE-32 FOR
      e_fp_ord-dtl,
      e_fp_ord-doc,
      ub.gds-prt SCROLLING.

DEFINE QUERY BROWSE-33 FOR
      e_fp_ord-dtl-rcv,
      e_fp_ord-doc-rcv,
      ub.gds-prt SCROLLING.

DEFINE QUERY BROWSE-34 FOR
      l_rcv_ord-dtl-rcv,
      l_rcv_ord-doc-rcv,
      ub.gds-prt SCROLLING.

DEFINE QUERY BROWSE-35 FOR
      l_rcv_gds-dtl,
      l_rcv_trn-doc,
      ub.gds-prt SCROLLING.

DEFINE QUERY BROWSE-36 FOR
      obj_ord-dtl-rcv,
      obj_ord-doc-rcv,
      ub.gds-prt SCROLLING.

DEFINE QUERY BROWSE-37 FOR
      obj_prt-obj,
      ub.gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-12 Dialog-Frame _FREEFORM
  QUERY BROWSE-12 NO-LOCK DISPLAY
      tt-goods.use COLUMN-LABEL "*" FORMAT "*/"
      tt-goods.artic
      tt-goods.gds-name FORMAT "X(20)"
       tt-goods.sum-qnty COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-ord COLUMN-LABEL "Заказано" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv COLUMN-LABEL "Поставлено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv-in COLUMN-LABEL "Перемещено" FORMAT "->>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.unit-base COLUMN-LABEL "баз."
      tt-goods.unit-cli COLUMN-LABEL "Пост."
      tt-goods.sum-fact COLUMN-LABEL "По ПН" FORMAT ">>>>>>>9.<<<"
  ENABLE
      tt-goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61.5 BY 9
         TITLE "Совокупный заказ".

DEFINE BROWSE BROWSE-13
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-13 Dialog-Frame _STRUCTURED
  QUERY BROWSE-13 NO-LOCK DISPLAY
      ub.ord-doc.obj-type + " " + STRING (ub.ord-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(8)":U
      m_ord-line.qnty COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>9.<<<":U
      ub.ord-doc.ship-date COLUMN-LABEL "Достав." FORMAT "99/99/99":U
      string(ub.ord-doc.ship-time,"HH:MM") COLUMN-LABEL "Время" FORMAT "x(5)":U
      IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
      m_ord-line.doc-code FORMAT "X(14)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.75 BY 9.13
         TITLE "Заявки ОФ по товару".

DEFINE BROWSE BROWSE-14
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-14 Dialog-Frame _FREEFORM
  QUERY BROWSE-14 NO-LOCK DISPLAY
      my-obj.obj-type + " " + STRING (my-obj.obj-code) COLUMN-LABEL "Объект" FORMAT "x(8)"
      buf_gds-obj.fact-qnty FORMAT "->>>>>>>9.<<<"
      my-obj.obj-name COLUMN-LABEL "Наименование" FORMAT "x(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25.38 BY 9.13
         TITLE "Остатки товара по объектам".

DEFINE BROWSE BROWSE-15
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-15 Dialog-Frame _FREEFORM
  QUERY BROWSE-15 NO-LOCK DISPLAY
      ub.trn-doc.doc-code FORMAT "X(14)":U
      ub.trn-doc.doc-type FORMAT "X(3)":U
      ub.doc-line.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
      ub.trn-doc.cli-type + " " + string(trn-doc.cli-code) COLUMN-LABEL "C Объекта" FORMAT "x(10)":U
      ub.trn-doc.status_ FORMAT "X(8)":U
      ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) COLUMN-LABEL "На объект" FORMAT "x(10)":U
  ENABLE
      ub.trn-doc.doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Внутреннее перемещение товара".

DEFINE BROWSE BROWSE-16
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-16 Dialog-Frame _STRUCTURED
  QUERY BROWSE-16 NO-LOCK DISPLAY
      ub.ord-doc.obj-type + " " + string(ub.ord-doc.obj-code) COLUMN-LABEL "Объект"
      ub.ord-doc.doc-code COLUMN-LABEL "Заявка" FORMAT "X(14)":U
      ub.ord-doc.ship-date COLUMN-LABEL "Постав." FORMAT "99/99/99":U
      string(ub.ord-doc.ship-time,"HH:MM") COLUMN-LABEL "Время"
      IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) COLUMN-LABEL "Статус"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.75 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Все Заявки ОФ".

DEFINE BROWSE BROWSE-17
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-17 Dialog-Frame _STRUCTURED
  QUERY BROWSE-17 NO-LOCK DISPLAY
      buf_clients.obj-type + " " + string(buf_clients.obj-code) COLUMN-LABEL "Код"
      ub.cli-gds.price-cli FORMAT ">>>>>>>>>>9.99":U
      buf_clients.obj-name FORMAT "X(40)":U
      ub.cli-gds.cancel-date FORMAT "99/99/99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25.38 BY 9.13
         TITLE "Список поставщиков".

DEFINE BROWSE BROWSE-18
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-18 Dialog-Frame _FREEFORM
  QUERY BROWSE-18 NO-LOCK DISPLAY
      {&c-18-1} @ mark COLUMN-LABEL "+" FORMAT "x(1)"
{&c-18-2} COLUMN-LABEL "№ заказа" FORMAT "X(10)"
{&c-18-3} COLUMN-LABEL "Кол-во " FORMAT ">>>>>>>9.<<<"
{&c-18-4} COLUMN-LABEL "Кому"  FORMAT "x(10)"
{&c-18-6} COLUMN-LABEL "Поставщик" FORMAT "X(20)"
{&c-18-7} @ str-status   COLUMN-LABEL "Статус"  FORMAT "x(8)"
{&c-18-8} FORMAT "X(20)"
{&c-18-9}
enable {&c-18-3}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 37 BY 9.13
         TITLE "Заказы ФП по товару".

DEFINE BROWSE BROWSE-20
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-20 Dialog-Frame _FREEFORM
  QUERY BROWSE-20 NO-LOCK DISPLAY
      {&c-20-1} COLUMN-LABEL     {&l-20-1}
{&c-20-2}    COLUMN-LABEL  {&l-20-2}   FORMAT "x(8)"
{&c-20-3}     COLUMN-LABEL  {&l-20-3}  FORMAT ">>>>>>>9.<<<"
{&c-20-4}    COLUMN-LABEL   {&l-20-4}  FORMAT ">>>>>>>9.<<<"
{&c-20-5}     COLUMN-LABEL  {&l-20-5}  FORMAT "x(10)"
{&c-20-6}     COLUMN-LABEL   {&l-20-6} FORMAT ">>>>>>>>>>9.999"
{&c-20-7}      COLUMN-LABEL {&l-20-7}  FORMAT ">>>>>>>>>>>>9.999"
{&c-20-8}       COLUMN-LABEL {&l-20-8}
{&c-20-9}       COLUMN-LABEL {&l-20-9}    FORMAT "x(8)"
  ENABLE
{&c-20-1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Поставка товара внутренняя".

DEFINE BROWSE BROWSE-21
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-21 Dialog-Frame _FREEFORM
  QUERY BROWSE-21 NO-LOCK DISPLAY
      new-rcv.rcv-code COLUMN-LABEL "№ пост-ки" FORMAT "X(14)":U
      new-rcv.doc-code COLUMN-LABEL "№ заказа" FORMAT "X(14)":U
      new-rcv.obj-type + " " + string(new-rcv.obj-code) COLUMN-LABEL "Куда" FORMAT "x(10)":U
      new-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99":U
      new-rcv.fact-date FORMAT "99/99/99":U
      string(new-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время"
      IF (new-rcv.status_ = {&fact} or new-rcv.status_ = {&ord-close})  THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-"))  ELSE (new-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
      IF (new-rcv.doc-type = "in":U) THEN ("внут") ELSE ("внеш") COLUMN-LABEL "Тип" FORMAT "x(4)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 25.38 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Все Поставки по СЗФП".

DEFINE BROWSE BROWSE-22
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-22 Dialog-Frame _FREEFORM
  QUERY BROWSE-22 NO-LOCK DISPLAY
      ub.trn-doc.doc-code FORMAT "X(14)":U
      ub.trn-doc.doc-date FORMAT "99/99/99":U
      ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(8)":U
      ub.trn-doc.cli-type + string( ub.trn-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(8)":U
      string(trn-doc.fact-time,"HH:MM") COLUMN-LABEL "Время" FORMAT "X(5)":U
      ub.trn-doc.fact-date FORMAT "99/99/99":U
      ub.trn-doc.internal FORMAT "yes/no":U
      ub.trn-doc.out-code FORMAT "X(14)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Приходные накладные".

DEFINE BROWSE BROWSE-23
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-23 Dialog-Frame _FREEFORM
  QUERY BROWSE-23 NO-LOCK DISPLAY
      ub.ord-doc-rcv.rcv-code COLUMN-LABEL "№ пост-ки" FORMAT "X(14)":U
      ub.ord-doc-rcv.cli-type + " " + string(ub.ord-doc-rcv.cli-code) COLUMN-LABEL "С объекта" FORMAT "x(10)":U
      ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) COLUMN-LABEL "На объект" FORMAT "x(10)":U
      ub.ord-doc-rcv.doc-date FORMAT "99/99/99":U
      ub.ord-doc-rcv.fact-date FORMAT "99/99/99":U
      ub.ord-doc-rcv.ship-date FORMAT "99/99/99":U
      STRING (ub.ord-doc-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время доставки" FORMAT "x(8)":U
      IF (ub.ord-doc-rcv.status_ = {&fact} or ub.ord-doc-rcv.status_ = {&ord-close})  THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,"+/-"))  ELSE (ub.ord-doc-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Документы поставки внутренние".

DEFINE BROWSE BROWSE-24
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-24 Dialog-Frame _FREEFORM
  QUERY BROWSE-24 NO-LOCK DISPLAY
      ub.trn-doc.doc-code COLUMN-LABEL "№РН" FORMAT "X(14)":U
      ub.trn-doc.doc-type FORMAT "X(3)":U
      ub.trn-doc.obj-type + " " + string(trn-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)":U
      ub.trn-doc.cli-type + " " + string(trn-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)":U
      ub.trn-doc.status_ FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Документы на внутреннее перемещение".

DEFINE BROWSE BROWSE-26
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-26 Dialog-Frame _STRUCTURED
  QUERY BROWSE-26 NO-LOCK DISPLAY
      ub.ord-doc.doc-code COLUMN-LABEL "Заказ №" FORMAT "X(14)":U
      ub.ord-doc.cli-type + " " + string(ub.ord-doc.cli-code) COLUMN-LABEL "Кому" FORMAT "x(10)":U
      ub.ord-doc.doc-date FORMAT "99/99/99":U
      ub.ord-doc.fact-date FORMAT "99/99/99":U
      ub.ord-doc.ship-date FORMAT "99/99/99":U
      STRING (ub.ord-doc.ship-time,"HH:MM") COLUMN-LABEL "Время"
      ub.ord-doc.cli-name COLUMN-LABEL "Поставщик" FORMAT "X(20)":U
      IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,"+/-"))  ELSE (ub.ord-doc.status_) COLUMN-LABEL "Статус" FORMAT "x(8)":U
  ENABLE
      ub.ord-doc.doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Заказы ФП".

DEFINE BROWSE BROWSE-27
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-27 Dialog-Frame _FREEFORM
  QUERY BROWSE-27 DISPLAY
      ub.ord-doc-rcv.rcv-code COLUMN-LABEL "№ Поставки" FORMAT "X(14)":U
      ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code) COLUMN-LABEL "Куда" FORMAT "x(10)":U
      ub.ord-doc-rcv.doc-code COLUMN-LABEL "Заказ ФП" FORMAT "X(14)":U
      ub.ord-doc-rcv.doc-date FORMAT "99/99/99":U
      ub.ord-doc-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99":U
      string(ub.ord-doc-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время" FORMAT "X(5)":U
      ub.ord-doc-rcv.status_ FORMAT "X(8)":U
  ENABLE
      ub.ord-doc-rcv.rcv-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         BGCOLOR 8
         TITLE BGCOLOR 8 "Поставки по заказу".

DEFINE BROWSE BROWSE-28
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-28 Dialog-Frame _FREEFORM
  QUERY BROWSE-28 NO-LOCK DISPLAY
      ub.ord-doc-rcv.rcv-code COLUMN-LABEL {&l-28-1}
   ub.ord-line-rcv.qnty  COLUMN-LABEL {&l-28-2}
   ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code)  FORMAT "x(10)"  COLUMN-LABEL {&l-28-3}
   ub.ord-line-rcv.price-rubl COLUMN-LABEL {&l-28-4}
   ub.ord-line-rcv.cli-qnty COLUMN-LABEL {&l-28-5}
   ub.ord-line-rcv.price-cli COLUMN-LABEL {&l-28-6}
   ub.ord-doc-rcv.ship-date FORMAT "99/99/99" COLUMN-LABEL {&l-28-7}
   ub.ord-line-rcv.artic COLUMN-LABEL {&l-28-8}
   ub.ord-doc-rcv.doc-code  COLUMN-LABEL {&l-28-9}
   IF (ub.ord-doc-rcv.status_ = {&fact} or ub.ord-doc-rcv.status_ = {&ord-close})  THEN (ub.ord-doc-rcv.status_ + string(ub.ord-doc-rcv.flag_,"+/-"))  ELSE (ub.ord-doc-rcv.status_)  FORMAT "x(8)"
        COLUMN-LABEL {&l-28-10}
   ub.goods.gds-name FORMAT "X(20)"  COLUMN-LABEL {&l-28-11}
 enable ub.ord-line-rcv.cli-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Поставки по строкам".

DEFINE BROWSE BROWSE-29
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-29 Dialog-Frame _FREEFORM
  QUERY BROWSE-29 NO-LOCK DISPLAY
      new-rcv.obj-type + " " + string(new-rcv.obj-code) COLUMN-LABEL "Куда" FORMAT "x(10)"
    ub.ord-line-rcv.qnty FORMAT ">>>>>>>9.<<<"
    ub.ord-line-rcv.artic
    new-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
    new-rcv.fact-date FORMAT "99/99/99"
    string(new-rcv.ship-time,"HH:MM") COLUMN-LABEL "Время"
    new-rcv.rcv-code COLUMN-LABEL "№ пост-ки"
    IF (new-rcv.status_ = {&fact} or new-rcv.status_ = {&ord-close})  THEN (new-rcv.status_ + string(new-rcv.flag_,"+/-"))  ELSE (new-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
    new-rcv.doc-code COLUMN-LABEL "№ заказа"
    IF (new-rcv.doc-type = 'in':U) THEN ('внут') ELSE ('внеш') COLUMN-LABEL "Тип" FORMAT "x(4)"
    ub.ord-line-rcv.price-rubl
    ub.ord-line-rcv.cli-qnty
    ub.ord-line-rcv.price-cli
  ENABLE
    ub.ord-line-rcv.qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37 BY 9.13
         TITLE "Все поставки по товару и заявке".

DEFINE BROWSE BROWSE-30
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-30 Dialog-Frame _FREEFORM
  QUERY BROWSE-30 NO-LOCK DISPLAY
      tt-goods.use COLUMN-LABEL "*" FORMAT "*/"
      tt-goods.artic
      tt-goods.all-name FORMAT "X(30)" COLUMN-LABEL "Товар - Признак"
      tt-goods.sum-qnty COLUMN-LABEL "Запрошено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-ord COLUMN-LABEL "Заказано" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv COLUMN-LABEL "Поставлено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.sum-rcv-in COLUMN-LABEL "Перемещено" FORMAT ">>>>>>>9.<<<"
            LABEL-BGCOLOR 8
      tt-goods.unit-base COLUMN-LABEL "баз."
      tt-goods.unit-cli COLUMN-LABEL "Пост."
      tt-goods.sum-fact COLUMN-LABEL "По ПН" FORMAT ">>>>>>>9.<<<"
      tt-goods.gds-t COLUMN-LABEL "ПРИ" FORMAT "x(3)" LABEL-FGCOLOR 1
  ENABLE
      tt-goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 62 BY 9.13
         TITLE "Совокупный заказ".

DEFINE BROWSE BROWSE-31
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-31 Dialog-Frame _STRUCTURED
  QUERY BROWSE-31 NO-LOCK DISPLAY
      of_ord-dtl.doc-code FORMAT "X(14)":U COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)":U
      of_ord-dtl.qnty FORMAT ">>>>>>>9.<<<":U COLUMN-FGCOLOR 9
      of_ord-doc.obj-type + " " + string(of_ord-doc.obj-code) COLUMN-LABEL "От кого"
            COLUMN-FGCOLOR 9
      IF (of_ord-doc.status_ = {&fact} or of_ord-doc.status_ = {&ord-close})  THEN (of_ord-doc.status_ + string(of_ord-doc.flag_,"+/-"))  ELSE (of_ord-doc.status_)
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.13 BY 9.13
         TITLE "Признаки по заявкам".

DEFINE BROWSE BROWSE-32
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-32 Dialog-Frame _FREEFORM
  QUERY BROWSE-32 NO-LOCK DISPLAY
      e_fp_ord-doc.doc-code COLUMN-LABEL "Заказ"   COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)"                            COLUMN-FGCOLOR 9
      e_fp_ord-dtl.qnty FORMAT ">>>>>>>9.<<<"        COLUMN-FGCOLOR 9
      e_fp_ord-doc.cli-type + " " +  string(e_fp_ord-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)"
                                                                                             COLUMN-FGCOLOR 9
      e_fp_ord-doc.status_                                              COLUMN-FGCOLOR 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.63 BY 10.63
         TITLE "Заказы ФП по признаку".

DEFINE BROWSE BROWSE-33
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-33 Dialog-Frame _FREEFORM
  QUERY BROWSE-33 NO-LOCK DISPLAY
      e_fp_ord-dtl-rcv.rcv-code COLUMN-LABEL "Поставка" COLUMN-FGCOLOR 9
      ub.gds-prt.f-name                         COLUMN-FGCOLOR 9
      e_fp_ord-dtl-rcv.qnty          COLUMN-FGCOLOR 9
      e_fp_ord-dtl-rcv.doc-code COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.cli-code COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.cli-type COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.obj-type + " " + string(e_fp_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект" COLUMN-FGCOLOR 9
      e_fp_ord-doc-rcv.status_  COLUMN-FGCOLOR 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 10.63
         TITLE "Поставки внешние по признаку".

DEFINE BROWSE BROWSE-34
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-34 Dialog-Frame _FREEFORM
  QUERY BROWSE-34 NO-LOCK DISPLAY
      l_rcv_ord-dtl-rcv.rcv-code COLUMN-LABEL "Поставка" COLUMN-FGCOLOR 9
      IF (l_rcv_ord-doc-rcv.doc-type = "in":U) THEN ("внут") ELSE ("внеш") COLUMN-LABEL "Тип" FORMAT "x(4)"  COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)"   COLUMN-FGCOLOR 9
      l_rcv_ord-dtl-rcv.qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>9.<<<"  COLUMN-FGCOLOR 9
      l_rcv_ord-doc-rcv.cli-type + " " + STRING (l_rcv_ord-doc-rcv.cli-code) COLUMN-LABEL "Контрагент"
          COLUMN-FGCOLOR 9
      l_rcv_ord-doc-rcv.obj-type + " " + STRING (l_rcv_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект"
            COLUMN-FGCOLOR 9
      IF (l_rcv_ord-doc-rcv.status_ = {&fact} or l_rcv_ord-doc-rcv.status_ = {&ord-close})  THEN (l_rcv_ord-doc-rcv.status_ + string(l_rcv_ord-doc-rcv.flag_,"+/-"))  ELSE (l_rcv_ord-doc-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
            COLUMN-FGCOLOR 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50 BY 10.46
         TITLE "Поставки по признаку".

DEFINE BROWSE BROWSE-35
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-35 Dialog-Frame _FREEFORM
  QUERY BROWSE-35 NO-LOCK DISPLAY
      l_rcv_gds-dtl.doc-code        COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)"  COLUMN-FGCOLOR 9
      l_rcv_gds-dtl.doc-qnty  COLUMN-FGCOLOR 9
      l_rcv_gds-dtl.fact-qnty  COLUMN-FGCOLOR 9
      l_rcv_trn-doc.obj-type + " " + STRING (l_rcv_trn-doc.obj-code)  COLUMN-LABEL "Объект"  COLUMN-FGCOLOR 9
      l_rcv_trn-doc.cli-type + " " + STRING (l_rcv_trn-doc.cli-code)  COLUMN-LABEL "Контрагент"  COLUMN-FGCOLOR 9
      l_rcv_trn-doc.doc-type  COLUMN-FGCOLOR 9
     IF (l_rcv_trn-doc.status_ = {&fact} or l_rcv_trn-doc.status_ = {&ord-close})  THEN (l_rcv_trn-doc.status_ + string(l_rcv_trn-doc.flag_,"+/-"))  ELSE (l_rcv_trn-doc.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
       COLUMN-FGCOLOR 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.38 BY 10.46
         TITLE "ПН и РН по признакам".

DEFINE BROWSE BROWSE-36
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-36 Dialog-Frame _FREEFORM
  QUERY BROWSE-36 NO-LOCK DISPLAY
      obj_ord-dtl-rcv.rcv-code COLUMN-LABEL "Поставка" COLUMN-FGCOLOR 9
      ub.gds-prt.f-name FORMAT "X(10)" COLUMN-FGCOLOR 9
      obj_ord-dtl-rcv.qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>9.<<<" COLUMN-FGCOLOR 9
      obj_ord-doc-rcv.cli-type + " " + STRING (obj_ord-doc-rcv.cli-code) COLUMN-LABEL "Контрагент"
            COLUMN-FGCOLOR 9
      obj_ord-doc-rcv.obj-type + " " + STRING (obj_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект"
            COLUMN-FGCOLOR 9
      IF (obj_ord-doc-rcv.status_ = {&fact} or obj_ord-doc-rcv.status_ = {&ord-close})  THEN (obj_ord-doc-rcv.status_ + string(obj_ord-doc-rcv.flag_,"+/-"))  ELSE (obj_ord-doc-rcv.status_) COLUMN-LABEL "Статус" FORMAT "x(8)"
            COLUMN-FGCOLOR 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.75 BY 10.5
         TITLE "Поставки внутренние по признаку".

DEFINE BROWSE BROWSE-37
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-37 Dialog-Frame _FREEFORM
  QUERY BROWSE-37 NO-LOCK DISPLAY
      obj_prt-obj.obj-type + " " + STRING (obj_prt-obj.obj-code) COLUMN-LABEL "Объект"
      COLUMN-FGCOLOR 9
gds-prt.f-name FORMAT "X(10)" COLUMN-FGCOLOR 9
obj_prt-obj.fact-qnty FORMAT ">>>>>>>9.<<<" COLUMN-FGCOLOR 9
obj_prt-obj.free-qnty FORMAT ">>>>>>>9.<<<" COLUMN-FGCOLOR 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 10.5
         TITLE "Наличие признака на объектах".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1.04 COL 1
     B-Help AT ROW 1.04 COL 93.88
     BUTTON-2 AT ROW 12.38 COL 1
     R-main AT ROW 12.58 COL 43.13 NO-LABEL
     T-gds AT ROW 12.58 COL 87.75
     BUTTON-3 AT ROW 12.38 COL 15
     BUTTON-47 AT ROW 12.38 COL 29
     str-good AT ROW 1 COL 7 COLON-ALIGNED NO-LABEL
     loc-ord-cons-code AT ROW 1.25 COL 8 COLON-ALIGNED NO-LABEL
     F-post-2 AT ROW 12.67 COL 15.75 NO-LABEL
     F-post AT ROW 12.67 COL 28.38 COLON-ALIGNED NO-LABEL
     F-obj AT ROW 12.75 COL 2.5 NO-LABEL
     RECT-3 AT ROW 13.25 COL 1
     SPACE(0.00) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Планирование заказа"
         DEFAULT-BUTTON B-OK.

DEFINE FRAME FRAME-E
     BROWSE-17 AT ROW 1 COL 1
     T-cli AT ROW 10.25 COL 1
     T-cli-fp AT ROW 10.25 COL 9.13
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         NO-LABELS SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 13.5
         SIZE 99.75 BY 10.67.

DEFINE FRAME FRAME-K
     BROWSE-26 AT ROW 1 COL 1
     BROWSE-27 AT ROW 1 COL 38
     B-make-post-ex-3 AT ROW 10.25 COL 1
     BUTTON-27 AT ROW 10.25 COL 9
     BUTTON-53 AT ROW 10.25 COL 17
     BUTTON-28 AT ROW 10.25 COL 25
     BUTTON-30 AT ROW 10.25 COL 38
     BUTTON-54 AT ROW 10.25 COL 45.13
     BUTTON-31 AT ROW 10.25 COL 52.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.46.

DEFINE FRAME FRAME-J
     BROWSE-18 AT ROW 1 COL 1
     BROWSE-28 AT ROW 1 COL 38
     B-mark-2 AT ROW 10.21 COL 1.13
     B-make-post-ex-2 AT ROW 10.21 COL 4.13
     BUTTON-9 AT ROW 10.21 COL 12.13
     BUTTON-55 AT ROW 10.21 COL 19.13
     BUTTON-10 AT ROW 10.21 COL 26.25
     BUTTON-33 AT ROW 10.21 COL 38.13
     BUTTON-56 AT ROW 10.21 COL 45.13
     BUTTON-34 AT ROW 10.21 COL 52.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.21.

DEFINE FRAME FRAME-E-prt
     BROWSE-32 AT ROW 1 COL 1
     BROWSE-33 AT ROW 1 COL 50.88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.63 BY 10.63.

DEFINE FRAME FRAME-D
     BROWSE-13 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 63 ROW 2
         SIZE 37.88 BY 9.25.

DEFINE FRAME FRAME-C
     BROWSE-30 AT ROW 1 COL 1.13
     B-mark-5 AT ROW 10 COL 1.13
     B-mark-6 AT ROW 10 COL 4.25
     B-mark-7 AT ROW 10 COL 7.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2
         SIZE 62.13 BY 10.

DEFINE FRAME FRAME-Postavki
     BROWSE-21 AT ROW 1 COL 1
     BROWSE-29 AT ROW 1 COL 26.38
     BROWSE-22 AT ROW 1 COL 63.25
     B-make-trn AT ROW 10.21 COL 1.5
     BUTTON-50 AT ROW 10.21 COL 10.5
     BUTTON-52 AT ROW 10.21 COL 18.63
     BUTTON-49 AT ROW 10.21 COL 63.5
     BUTTON-51 AT ROW 10.21 COL 71.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 13.5
         SIZE 99.5 BY 10.6.

DEFINE FRAME FRAME-Post-prt
     BROWSE-34 AT ROW 1 COL 1
     BROWSE-35 AT ROW 1 COL 51
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.38 BY 10.58.

DEFINE FRAME FRAME-B
     BROWSE-14 AT ROW 1 COL 1
     T-obj AT ROW 10.25 COL 1.5
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1.13 ROW 13.54
         SIZE 99.75 BY 10.71.

DEFINE FRAME FRAME-I
     BROWSE-23 AT ROW 1 COL 1
     BROWSE-24 AT ROW 1 COL 38
     BUTTON-48 AT ROW 10.38 COL 1
     BUTTON-17 AT ROW 10.38 COL 10
     BUTTON-57 AT ROW 10.38 COL 18.25
     BUTTON-18 AT ROW 10.38 COL 26.25
     BUTTON-21 AT ROW 10.38 COL 53.75
     BUTTON-20 AT ROW 10.38 COL 61.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.5.

DEFINE FRAME FRAME-H
     B-make-trn-2 AT ROW 10.5 COL 1.38
     BUTTON-58 AT ROW 10.5 COL 16.38
     BUTTON-59 AT ROW 10.5 COL 45.5
     BROWSE-15 AT ROW 1 COL 38
     BROWSE-20 AT ROW 1 COL 1
     BUTTON-7 AT ROW 10.5 COL 9.38
     BUTTON-8 AT ROW 10.5 COL 23.5
     BUTTON-15 AT ROW 10.5 COL 38.38
     BUTTON-14 AT ROW 10.5 COL 52.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 26.25 ROW 1
         SIZE 74.13 BY 10.5.

DEFINE FRAME FRAME-B-prt
     BROWSE-37 AT ROW 1 COL 1
     BROWSE-36 AT ROW 1 COL 50.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.5 BY 10.58.

DEFINE FRAME FRAME-A
     BROWSE-12 AT ROW 1 COL 1
     B-mark AT ROW 10.17 COL 1.13
     B-mark-3 AT ROW 10.17 COL 4.25
     B-mark-4 AT ROW 10.17 COL 7.5
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         PAGE-TOP SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2 SCROLLABLE .

DEFINE FRAME FRAME-F
     BROWSE-16 AT ROW 1 COL 1
     B-ins-za AT ROW 10.25 COL 1
     B-za-3 AT ROW 10.25 COL 9
     B-reject AT ROW 10.25 COL 17
     B-isk AT ROW 10.25 COL 25.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         PAGE-BOTTOM SIDE-LABELS THREE-D
         AT COL 63 ROW 2 SCROLLABLE .

DEFINE FRAME FRAME-d-prt
     BROWSE-31 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 63 ROW 2
         SIZE 37.75 BY 9.5.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: b-all_ord-doc-rcv B "?" ? ub ub.ord-doc-rcv
      TABLE: bb_ord-doc B "?" ? ub ub.ord-doc
      TABLE: bufs_ord-doc-rcv B "NEW SHARED" ? ub ub.ord-doc-rcv
      TABLE: buf_clients B "?" ? ub ub.clients
      TABLE: buf_gds-obj B "?" ? ub ub.gds-obj
      TABLE: e_fp_ord-doc B "?" ? ub ub.ord-doc
      TABLE: e_fp_ord-doc-rcv B "?" ? ub ub.ord-doc-rcv
      TABLE: e_fp_ord-dtl B "?" ? ub ub.ord-dtl
      TABLE: e_fp_ord-dtl-rcv B "?" ? ub ub.ord-dtl-rcv
      TABLE: l_rcv_gds-dtl B "?" ? ub ub.gds-dtl
      TABLE: l_rcv_ord-doc-rcv B "?" ? ub ub.ord-doc-rcv
      TABLE: l_rcv_ord-dtl-rcv B "?" ? ub ub.ord-dtl-rcv
      TABLE: l_rcv_trn-doc B "?" ? ub ub.trn-doc
      TABLE: my-obj T "?" NO-UNDO ub ub.clients
      TABLE: m_ord-line B "?" ? ub ub.ord-line
      TABLE: new-rcv B "?" ? ub ub.ord-doc-rcv
      TABLE: obj_gds-dtl B "?" ? ub ub.gds-dtl
      TABLE: obj_ord-doc-rcv B "?" ? ub ub.ord-doc-rcv
      TABLE: obj_ord-dtl-rcv B "?" ? ub ub.ord-dtl-rcv
      TABLE: obj_prt-obj B "?" ? ub prt-obj
      TABLE: obj_trn-doc B "?" ? ub ub.trn-doc
      TABLE: of_ord-doc B "?" ? ub ub.ord-doc
      TABLE: of_ord-dtl B "?" ? ub ub.ord-dtl
      TABLE: shar-buf_ord-doc B "NEW SHARED" ? ub ub.ord-doc
      TABLE: tt-goods T "?" NO-UNDO ub ub.goods
      ADDITIONAL-FIELDS:
          field nn as int
          field use as log
          field gds-t as char
          field sum-qnty like ub.ord-line.qnty
          field sum-ord like ub.ord-line.qnty
          field sum-rcv like ub.ord-line.qnty
          field sum-rcv-in like ub.ord-line.qnty
          field sum-fact like ub.ord-line.qnty
          field prt-name like ub.gds-prt.f-name
          field all-name like ub.gds-prt.f-name
          field node-code like ub.goods.prt-root
          index i1 nn
          index i2 gds-code
          index i3 artic prod-type prod-code
      END-FIELDS.
      TABLE: tt-new-doc-line B "?" ? ub ub.doc-line
      ADDITIONAL-FIELDS:
          field cli-code like ub.clients.obj-code
          field cli-type like ub.clients.obj-type.

      END-FIELDS.
      TABLE: tt-new-ord-line B "?" ? ub ub.ord-line
      ADDITIONAL-FIELDS:
          field obj-code like ub.clients.obj-code
          field obj-type like ub.clients.obj-type
          field cli-code like ub.clients.obj-code
          field cli-type like ub.clients.obj-type
      END-FIELDS.
      TABLE: tt-ord-gds T "?" NO-UNDO ub ub.goods
      ADDITIONAL-FIELDS:
          field use as log
      END-FIELDS.
      TABLE: tt-rcv-ex B "?" ? ub ub.ord-line-rcv
      ADDITIONAL-FIELDS:
          field obj-code like ub.clients.obj-code
          field obj-type like ub.clients.obj-type
          field cli-code like ub.clients.obj-code
          field cli-type like ub.clients.obj-type
      END-FIELDS.
      TABLE: tt-rcv-in B "?" ? ub ub.ord-line-rcv
      ADDITIONAL-FIELDS:
          field obj-code like ub.clients.obj-code
          field obj-type like ub.clients.obj-type
          field cli-code like ub.clients.obj-code
          field cli-type like ub.clients.obj-type
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME FRAME-A:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-B-prt:FRAME = FRAME FRAME-B:HANDLE
       FRAME FRAME-C:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-D:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-d-prt:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-E:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-E-prt:FRAME = FRAME FRAME-E:HANDLE
       FRAME FRAME-F:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-H:FRAME = FRAME FRAME-B:HANDLE
       FRAME FRAME-I:FRAME = FRAME FRAME-B:HANDLE
       FRAME FRAME-J:FRAME = FRAME FRAME-E:HANDLE
       FRAME FRAME-K:FRAME = FRAME FRAME-E:HANDLE
       FRAME FRAME-Post-prt:FRAME = FRAME FRAME-Postavki:HANDLE
       FRAME FRAME-Postavki:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   NOT-VISIBLE FRAME-NAME Custom                                        */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME FRAME-A:MOVE-AFTER-TAB-ITEM (B-Help:HANDLE IN FRAME Dialog-Frame)
       XXTABVALXX = FRAME FRAME-A:MOVE-BEFORE-TAB-ITEM (R-main:HANDLE IN FRAME Dialog-Frame)
/* END-ASSIGN-TABS */.

ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN F-obj IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F-post-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc-ord-cons-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       loc-ord-cons-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-gds IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-gds:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FRAME FRAME-A
   Size-to-Fit Custom                                                   */
/* BROWSE-TAB BROWSE-12 1 FRAME-A */
ASSIGN
       FRAME FRAME-A:BOX-SELECTABLE   = TRUE
       FRAME FRAME-A:SCROLLABLE       = FALSE.

ASSIGN
       BROWSE-12:NUM-LOCKED-COLUMNS IN FRAME FRAME-A     = 2.

/* SETTINGS FOR FRAME FRAME-B
   NOT-VISIBLE                                                          */
ASSIGN XXTABVALXX = FRAME FRAME-B-prt:MOVE-AFTER-TAB-ITEM (BROWSE-14:HANDLE IN FRAME FRAME-B)
       XXTABVALXX = FRAME FRAME-I:MOVE-BEFORE-TAB-ITEM (T-obj:HANDLE IN FRAME FRAME-B)
       XXTABVALXX = FRAME FRAME-H:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-I:HANDLE)
       XXTABVALXX = FRAME FRAME-B-prt:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-H:HANDLE)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB BROWSE-14 1 FRAME-B */
ASSIGN
       FRAME FRAME-B:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-B-prt
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-37 1 FRAME-B-prt */
/* BROWSE-TAB BROWSE-36 BROWSE-37 FRAME-B-prt */
ASSIGN
       FRAME FRAME-B-prt:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-C
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-30 1 FRAME-C */
ASSIGN
       FRAME FRAME-C:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-mark-5 IN FRAME FRAME-C
   NO-ENABLE                                                            */
ASSIGN
       B-mark-5:HIDDEN IN FRAME FRAME-C           = TRUE.

/* SETTINGS FOR BUTTON B-mark-6 IN FRAME FRAME-C
   NO-ENABLE                                                            */
ASSIGN
       B-mark-6:HIDDEN IN FRAME FRAME-C           = TRUE.

/* SETTINGS FOR BUTTON B-mark-7 IN FRAME FRAME-C
   NO-ENABLE                                                            */
ASSIGN
       B-mark-7:HIDDEN IN FRAME FRAME-C           = TRUE.

/* SETTINGS FOR FRAME FRAME-D
                                                                        */
/* BROWSE-TAB BROWSE-13 1 FRAME-D */
ASSIGN
       FRAME FRAME-D:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-d-prt
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-31 1 FRAME-d-prt */
ASSIGN
       FRAME FRAME-d-prt:BOX-SELECTABLE   = TRUE
       FRAME FRAME-d-prt:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-E
   NOT-VISIBLE                                                          */
ASSIGN XXTABVALXX = FRAME FRAME-E-prt:MOVE-AFTER-TAB-ITEM (BROWSE-17:HANDLE IN FRAME FRAME-E)
       XXTABVALXX = FRAME FRAME-K:MOVE-BEFORE-TAB-ITEM (T-cli:HANDLE IN FRAME FRAME-E)
       XXTABVALXX = FRAME FRAME-J:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-K:HANDLE)
       XXTABVALXX = FRAME FRAME-E-prt:MOVE-BEFORE-TAB-ITEM (FRAME FRAME-J:HANDLE)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB BROWSE-17 1 FRAME-E */
ASSIGN
       FRAME FRAME-E:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-E-prt
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-32 1 FRAME-E-prt */
/* BROWSE-TAB BROWSE-33 BROWSE-32 FRAME-E-prt */
ASSIGN
       FRAME FRAME-E-prt:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-F
   NOT-VISIBLE UNDERLINE Size-to-Fit                                    */
/* BROWSE-TAB BROWSE-16 1 FRAME-F */
ASSIGN
       FRAME FRAME-F:SCROLLABLE       = FALSE
       FRAME FRAME-F:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME FRAME-H
   NOT-VISIBLE Custom                                                   */
/* BROWSE-TAB BROWSE-15 BUTTON-59 FRAME-H */
/* BROWSE-TAB BROWSE-20 BROWSE-15 FRAME-H */
ASSIGN
       FRAME FRAME-H:HIDDEN           = TRUE.

ASSIGN
       B-make-trn-2:POPUP-MENU IN FRAME FRAME-H       = MENU POPUP-MENU-B-make-trn-2:HANDLE.

/* SETTINGS FOR BUTTON BUTTON-15 IN FRAME FRAME-H
   NO-ENABLE                                                            */
ASSIGN
       BUTTON-15:HIDDEN IN FRAME FRAME-H           = TRUE.

/* SETTINGS FOR BUTTON BUTTON-59 IN FRAME FRAME-H
   NO-ENABLE                                                            */
ASSIGN
       BUTTON-59:HIDDEN IN FRAME FRAME-H           = TRUE.

/* SETTINGS FOR FRAME FRAME-I
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-23 1 FRAME-I */
/* BROWSE-TAB BROWSE-24 BROWSE-23 FRAME-I */
ASSIGN
       FRAME FRAME-I:HIDDEN           = TRUE.

ASSIGN
       BUTTON-48:POPUP-MENU IN FRAME FRAME-I       = MENU POPUP-MENU-BUTTON-48:HANDLE.

/* SETTINGS FOR FRAME FRAME-J
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-18 1 FRAME-J */
/* BROWSE-TAB BROWSE-28 BROWSE-18 FRAME-J */
ASSIGN
       FRAME FRAME-J:HIDDEN           = TRUE.

ASSIGN
       B-make-post-ex-2:POPUP-MENU IN FRAME FRAME-J       = MENU POPUP-MENU-B-make-post-ex-2:HANDLE.

/* SETTINGS FOR BUTTON B-mark-2 IN FRAME FRAME-J
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME FRAME-K
   NOT-VISIBLE UNDERLINE                                                */
/* BROWSE-TAB BROWSE-26 1 FRAME-K */
/* BROWSE-TAB BROWSE-27 BROWSE-26 FRAME-K */
ASSIGN
       FRAME FRAME-K:HIDDEN           = TRUE.

ASSIGN
       B-make-post-ex-3:POPUP-MENU IN FRAME FRAME-K       = MENU POPUP-MENU-B-make-post-ex-3:HANDLE.

/* SETTINGS FOR FRAME FRAME-Post-prt
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BROWSE-34 1 FRAME-Post-prt */
/* BROWSE-TAB BROWSE-35 BROWSE-34 FRAME-Post-prt */
ASSIGN
       FRAME FRAME-Post-prt:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE BROWSE-34 IN FRAME FRAME-Post-prt
   NO-ENABLE                                                            */
/* SETTINGS FOR BROWSE BROWSE-35 IN FRAME FRAME-Post-prt
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME FRAME-Postavki
   NOT-VISIBLE                                                          */
ASSIGN XXTABVALXX = FRAME FRAME-Post-prt:MOVE-AFTER-TAB-ITEM (BROWSE-21:HANDLE IN FRAME FRAME-Postavki)
       XXTABVALXX = FRAME FRAME-Post-prt:MOVE-BEFORE-TAB-ITEM (BROWSE-29:HANDLE IN FRAME FRAME-Postavki)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB BROWSE-21 1 FRAME-Postavki */
/* BROWSE-TAB BROWSE-29 FRAME-Post-prt FRAME-Postavki */
/* BROWSE-TAB BROWSE-22 BROWSE-29 FRAME-Postavki */
ASSIGN
       FRAME FRAME-Postavki:HIDDEN           = TRUE.

ASSIGN
       B-make-trn:POPUP-MENU IN FRAME FRAME-Postavki       = MENU POPUP-MENU-B-make-trn:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-12
/* Query rebuild information for BROWSE BROWSE-12
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-goods where tt-goods.gds-t = {&h-goods}
NO-LOCK,
      EACH ub.ord-gds-cons where
           ub.ord-gds-cons.artic = tt-goods.artic
  AND ub.ord-gds-cons.prod-code = tt-goods.prod-code
  AND ub.ord-gds-cons.prod-type = tt-goods.prod-type
  AND ub.ord-gds-cons.cons-code = loc-ord-cons-code
 NO-LOCK   by tt-goods.nn.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", OUTER"
     _JoinCode[2]      = "ub.ord-gds-cons.artic = Temp-Tables.tt-goods.artic
  AND ub.ord-gds-cons.prod-code = Temp-Tables.tt-goods.prod-code
  AND ub.ord-gds-cons.prod-type = Temp-Tables.tt-goods.prod-type
  AND ub.ord-gds-cons.cons-code = loc-ord-cons-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-12 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-13
/* Query rebuild information for BROWSE BROWSE-13
     _TblList          = "ub.m_ord-line,ub.ord-doc WHERE ub.m_ord-line ... ..."
     _Options          = "NO-LOCK"
     _Where[1]         = "x-artic      = m_ord-line.artic and
x-prod-type  = m_ord-line.prod-type and
x-prod-code  = m_ord-line.prod-code
"
     _JoinCode[2]      = "ub.ord-doc.doc-code = m_ord-line.doc-code"
     _Where[2]         = "ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = {&o-f}"
     _FldNameList[1]   > "_<CALC>"
"ord-doc.obj-type + "" "" + STRING (ub.ord-doc.obj-code)" "Объект" "x(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.m_ord-line.qnty
"m_ord-line.qnty" "Запрошено" ">>>>>>>9.<<<" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.ord-doc.ship-date
"ord-doc.ship-date" "Достав." ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"string(ub.ord-doc.ship-time,""HH:MM"")" "Время" "x(5)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,""+/-""))  ELSE (ub.ord-doc.status_)" "Статус" "x(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = Temp-Tables.m_ord-line.doc-code
     _Query            is OPENED
*/  /* BROWSE BROWSE-13 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-14
/* Query rebuild information for BROWSE BROWSE-14
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH my-obj NO-LOCK,
      EACH buf_gds-obj where
             my-obj.obj-code = buf_gds-obj.obj-code and
                      my-obj.obj-type = buf_gds-obj.obj-type and
                  x-artic      = buf_gds-obj.artic     and
            x-prod-type  = buf_gds-obj.prod-type and
            x-prod-code  = buf_gds-obj.prod-code
      NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "x-artic      = buf_gds-obj.artic     and
x-prod-type  = buf_gds-obj.prod-type and
x-prod-code  = buf_gds-obj.prod-code
"
     _Query            is OPENED
*/  /* BROWSE BROWSE-14 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-15
/* Query rebuild information for BROWSE BROWSE-15
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH b-all_ord-doc-rcv
      WHERE b-all_ord-doc-rcv.cons-code = loc-ord-cons-code AND
            b-all_ord-doc-rcv.doc-type = 'in' NO-LOCK,
      EACH ub.ord-chain WHERE
           ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and
           ub.ord-chain.doc-type = 'rcv'                    and
           ub.ord-chain.rel-doc-type = 'trn'    NO-LOCK            ,
      EACH ub.trn-doc WHERE
           ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK,
      EACH ub.doc-line WHERE
        ub.doc-line.doc-code   = ub.trn-doc.doc-code AND
        ub.doc-line.artic      = x-artic and
        ub.doc-line.prod-type  = x-prod-type and
        ub.doc-line.prod-code  = x-prod-code
        NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,,"
     _Where[1]         = "b-all_ord-doc-rcv.cons-code = loc-ord-cons-code
 AND b-all_ord-doc-rcv.doc-type = ""in"":U"
     _JoinCode[2]      = "ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code"
     _JoinCode[3]      = "doc-line.doc-code = ub.trn-doc.doc-code"
     _Where[3]         = "x-artic      = ub.doc-line.artic and
x-prod-type  = ub.doc-line.prod-type and
x-prod-code  = ub.doc-line.prod-code
"
     _Query            is OPENED
*/  /* BROWSE BROWSE-15 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-16
/* Query rebuild information for BROWSE BROWSE-16
     _TblList          = "ub.ord-doc"
     _Options          = "NO-LOCK"
     _OrdList          = "ub.ord-doc.obj-type|yes,ub.ord-doc.obj-code|yes,ub.ord-doc.ship-date|yes,ub.ord-doc.ship-time|yes,ub.ord-doc.doc-code|no"
     _Where[1]         = "ord-doc.cons-code = loc-ord-cons-code and ub.ord-doc.doc-type = {&O-F}"
     _FldNameList[1]   > "_<CALC>"
"ord-doc.obj-type + "" "" + string(ub.ord-doc.obj-code)" "Объект" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.ord-doc.doc-code
"ord-doc.doc-code" "Заявка" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.ord-doc.ship-date
"ord-doc.ship-date" "Постав." ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"string(ub.ord-doc.ship-time,""HH:MM"")" "Время" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,""+/-""))  ELSE (ub.ord-doc.status_)" "Статус" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-16 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-17
/* Query rebuild information for BROWSE BROWSE-17
     _TblList          = "ub.buf_clients,ub.cli-gds WHERE ub.buf_clients ..."
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST"
     _Where[1]         = "( buf_clients.sup-cons = true
 OR buf_clients.sup-gds = true )"
     _JoinCode[2]      = "cli-gds.cli-code = buf_clients.obj-code
  AND ub.cli-gds.cli-type = buf_clients.obj-type"
     _Where[2]         = "cli-gds.artic = x-artic and
cli-gds.prod-type = x-prod-type and ub.cli-gds.host-code = g#host-code and
cli-gds.prod-code = x-prod-code "
     _FldNameList[1]   > "_<CALC>"
"buf_clients.obj-type + "" "" + string(buf_clients.obj-code)" "Код" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.cli-gds.price-cli
"cli-gds.price-cli" ? ">>>>>>>>>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = Temp-Tables.buf_clients.obj-name
     _FldNameList[4]   > ub.cli-gds.cancel-date
"cli-gds.cancel-date" ? "99/99/99" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-17 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-18
/* Query rebuild information for BROWSE BROWSE-18
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc
      WHERE ub.ord-doc.cons-code = loc-ord-cons-code
        and ub.ord-doc.doc-type = {&f-p}
        and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code
                     and ub.ord-doc.cli-type = buf_clients.obj-type))
        and ( T-gds = false or (ub.ord-doc.doc-code = loc-num-ord-FP))
        NO-LOCK,
  EACH tt-new-ord-line
      WHERE tt-new-ord-line.doc-code = ub.ord-doc.doc-code
        and ( T-gds = true or (
                tt-new-ord-line.artic = tt-goods.artic
        and tt-new-ord-line.prod-code = tt-goods.prod-code
        and tt-new-ord-line.prod-type = tt-goods.prod-type))
        NO-LOCK,
  EACH ub.goods where
             ub.goods.artic = tt-new-ord-line.artic and
             ub.goods.prod-code = tt-new-ord-line.prod-code and
             ub.goods.prod-type = tt-new-ord-line.prod-type
             NO-LOCK
            .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",, OUTER"
     _Where[1]         = "ub.ord-doc.cons-code = loc-ord-cons-code
and ub.ord-doc.cli-code = buf_clients.obj-code
and ub.ord-doc.cli-type = buf_clients.obj-type
and ub.ord-doc.doc-type = {&f-p}"
     _Where[2]         = "ub.ord-doc.cons-code = loc-ord-cons-code
and ub.ord-doc.cli-code = buf_clients.obj-code
and ub.ord-doc.cli-type = buf_clients.obj-type"
     _Query            is OPENED
*/  /* BROWSE BROWSE-18 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-20
/* Query rebuild information for BROWSE BROWSE-20
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH b-all_ord-doc-rcv  WHERE
b-all_ord-doc-rcv.doc-type     = 'in':U and
b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code NO-LOCK,
EACH ub.ord-line-rcv WHERE
                b-all_ord-doc-rcv.rcv-code =    ub.ord-line-rcv.rcv-code  and
        x-artic          = ub.ord-line-rcv.artic and
        x-prod-type  = ub.ord-line-rcv.prod-type and
        x-prod-code  = ub.ord-line-rcv.prod-code   NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "b-all_ord-doc-rcv.doc-type = ""in"":U
 AND b-all_ord-doc-rcv.cons-code  = loc-ord-cons-code"
     _JoinCode[2]      = "ub.ord-line-rcv.rcv-code = b-all_ord-doc-rcv.rcv-code"
     _Where[2]         = "x-artic      = ub.ord-line-rcv.artic and
x-prod-type  = ub.ord-line-rcv.prod-type and
x-prod-code  = ub.ord-line-rcv.prod-code
"
     _Query            is OPENED
*/  /* BROWSE BROWSE-20 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-21
/* Query rebuild information for BROWSE BROWSE-21
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH new-rcv
      WHERE new-rcv.cons-code = loc-ord-cons-code NO-LOCK,
      EACH bb_ord-doc WHERE new-rcv.doc-code = bb_ord-doc.doc-code
 OUTER-JOIN NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", OUTER"
     _Where[1]         = "new-rcv.cons-code = loc-ord-cons-code"
     _JoinCode[2]      = "new-rcv.doc-code = bb_ord-doc.doc-code
"
     _Query            is OPENED
*/  /* BROWSE BROWSE-21 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-22
/* Query rebuild information for BROWSE BROWSE-22
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
for each ub.ord-chain no-lock where
        ub.ord-chain.doc-code = new-rcv.rcv-code and
        ub.ord-chain.doc-type = 'rcv'            and
        ub.ord-chain.rel-doc-type = 'trn',
EACH ub.trn-doc
      WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK
.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "new-rcv.trn-code = ub.trn-doc.doc-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-22 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-23
/* Query rebuild information for BROWSE BROWSE-23
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc-rcv
      WHERE ub.ord-doc-rcv.doc-type = 'in'
 AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ord-doc-rcv.doc-type = ""in"":U
 AND ub.ord-doc-rcv.cons-code = loc-ord-cons-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-23 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-24
/* Query rebuild information for BROWSE BROWSE-24
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH b-all_ord-doc-rcv
      WHERE b-all_ord-doc-rcv.doc-type = 'in' and
            b-all_ord-doc-rcv.cons-code = loc-ord-cons-code NO-LOCK,
      EACH ub.ord-chain WHERE
           ub.ord-chain.doc-code = b-all_ord-doc-rcv.rcv-code and
           ub.ord-chain.doc-type = 'rcv'                  and
           ub.ord-chain.rel-doc-type = 'trn' NO-LOCK,
      EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "b-all_ord-doc-rcv.doc-type = ""in"":U and b-all_ord-doc-rcv.cons-code = loc-ord-cons-code"
     _JoinCode[2]      = "ub.trn-doc.doc-code = b-all_ord-doc-rcv.trn-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-24 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-26
/* Query rebuild information for BROWSE BROWSE-26
     _TblList          = "ub.ord-doc,ub.shar-buf_ord-doc WHERE ub.ord-doc ..."
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST"
     _Where[1]         = "ub.ord-doc.cons-code = loc-ord-cons-code and
ub.ord-doc.doc-type = {&f-p}
and ( T-CLI-FP = false or (ub.ord-doc.cli-code = buf_clients.obj-code
and ub.ord-doc.cli-type = buf_clients.obj-type))
"
     _JoinCode[2]      = "shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code"
     _FldNameList[1]   > ub.ord-doc.doc-code
"ord-doc.doc-code" "Заказ №" ? "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"ord-doc.cli-type + "" "" + string(ub.ord-doc.cli-code)" "Кому" "x(10)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.ord-doc.doc-date
"ord-doc.doc-date" ? "99/99/99" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.ord-doc.fact-date
"ord-doc.fact-date" ? "99/99/99" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = ub.ord-doc.ship-date
     _FldNameList[6]   > "_<CALC>"
"STRING (ub.ord-doc.ship-time,""HH:MM"")" "Время" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > ub.ord-doc.cli-name
"ord-doc.cli-name" "Поставщик" "X(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"IF (ub.ord-doc.status_ = {&fact} or ub.ord-doc.status_ = {&ord-close})  THEN (ub.ord-doc.status_ + string(ub.ord-doc.flag_,""+/-""))  ELSE (ub.ord-doc.status_)" "Статус" "x(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-26 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-27
/* Query rebuild information for BROWSE BROWSE-27
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc-rcv
      WHERE
ord-doc-rcv.doc-code = loc-num-ord-FP and
ord-doc-rcv.doc-type = {&l-out}       and
ord-doc-rcv.cons-code = loc-ord-cons-code  NO-LOCK.
     _END_FREEFORM
     _Where[1]         = "ord-doc-rcv.doc-code = loc-num-ord-FP and
ord-doc-rcv.doc-type = {&l-out}       and
ord-doc-rcv.cons-code = loc-ord-cons-code "
     _Query            is OPENED
*/  /* BROWSE BROWSE-27 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-28
/* Query rebuild information for BROWSE BROWSE-28
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-doc-rcv WHERE
  ub.ord-doc-rcv.cons-code = loc-ord-cons-code and
  ub.ord-doc-rcv.doc-type = {&l-out} NO-LOCK,
    EACH ub.ord-line-rcv WHERE
    ub.ord-doc-rcv.doc-code  = ub.ord-line-rcv.doc-code and
    ub.ord-doc-rcv.rcv-code  = ub.ord-line-rcv.rcv-code and
      ( T-gds = true or (
    ub.ord-line-rcv.artic = tt-goods.artic
    and ub.ord-line-rcv.prod-code = tt-goods.prod-code
    and ub.ord-line-rcv.prod-type = tt-goods.prod-type )) NO-LOCK,
     EACH ub.goods where
    ub.goods.artic = ub.ord-line-rcv.artic and
    ub.goods.prod-code = ub.ord-line-rcv.prod-code and
    ub.goods.prod-type = ub.ord-line-rcv.prod-type NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ord-doc-rcv.doc-code = loc-num-ord-FP and ub.ord-doc-rcv.doc-type = ""out"":U"
     _JoinCode[2]      = "ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code
  AND ub.ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code"
     _Where[2]         = "( T-gds = true or (
ord-line-rcv.artic = tt-goods.artic
and ub.ord-line-rcv.prod-code = tt-goods.prod-code
and ub.ord-line-rcv.prod-type = tt-goods.prod-type ))
"
     _Query            is OPENED
*/  /* BROWSE BROWSE-28 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-29
/* Query rebuild information for BROWSE BROWSE-29
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR
      EACH new-rcv WHERE
           new-rcv.cons-code = loc-ord-cons-code NO-LOCK,
      EACH ub.ord-line-rcv WHERE
            ub.ord-line-rcv.rcv-code = new-rcv.rcv-code AND
            ub.ord-line-rcv.doc-code = new-rcv.doc-code AND
            ub.ord-line-rcv.artic = tt-goods.artic and
            ub.ord-line-rcv.prod-code = tt-goods.prod-code and
            ub.ord-line-rcv.prod-type = tt-goods.prod-type NO-LOCK,
      FIRST bb_ord-doc WHERE
            bb_ord-doc.doc-code = new-rcv.doc-code OUTER-JOIN NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",, FIRST OUTER"
     _Where[1]         = "new-rcv.cons-code = loc-ord-cons-code"
     _JoinCode[2]      = "ord-line-rcv.rcv-code = new-rcv.rcv-code AND
  ub.ord-line-rcv.doc-code = new-rcv.doc-code"
     _Where[2]         = "ord-line-rcv.artic = tt-goods.artic
and ub.ord-line-rcv.prod-code = tt-goods.prod-code
and ub.ord-line-rcv.prod-type = tt-goods.prod-type
"
     _JoinCode[3]      = "bb_ord-doc.doc-code = new-rcv.doc-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-29 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-30
/* Query rebuild information for BROWSE BROWSE-30
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-goods  NO-LOCK,
      EACH ub.ord-gds-cons where
            ub.ord-gds-cons.artic = tt-goods.artic
  AND ub.ord-gds-cons.prod-code = tt-goods.prod-code
  AND ub.ord-gds-cons.prod-type = tt-goods.prod-type
  AND ub.ord-gds-cons.cons-code = loc-ord-cons-code
  OUTER-JOIN
  NO-LOCK     by tt-goods.nn
.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", OUTER"
     _JoinCode[2]      = "ub.ord-gds-cons.artic = Temp-Tables.tt-goods.artic
  AND ub.ord-gds-cons.prod-code = Temp-Tables.tt-goods.prod-code
  AND ub.ord-gds-cons.prod-type = Temp-Tables.tt-goods.prod-type
  AND ub.ord-gds-cons.cons-code = loc-ord-cons-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-30 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-31
/* Query rebuild information for BROWSE BROWSE-31
     _TblList          = "ub.of_ord-dtl,ub.of_ord-doc OF ub.of_ord-dtl,ub.gds-prt WHERE ub.of_ord-dtl ..."
     _Options          = "NO-LOCK"
     _Where[1]         = "x-artic      = of_ord-dtl.artic and
x-prod-type  = of_ord-dtl.prod-type and
x-prod-code  = of_ord-dtl.prod-code and
string(of_ord-dtl.node-code) MATCHES x-node-code"
     _Where[2]         = "of_ord-doc.cons-code = loc-ord-cons-code and of_ord-doc.doc-type = {&o-f}"
     _JoinCode[3]      = "gds-prt.node-code = of_ord-dtl.node-code"
     _FldNameList[1]   > Temp-Tables.of_ord-dtl.doc-code
"of_ord-dtl.doc-code" ? ? "character" ? 9 ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.gds-prt.f-name
"gds-prt.f-name" ? "X(10)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.of_ord-dtl.qnty
"of_ord-dtl.qnty" ? ">>>>>>>9.<<<" "decimal" ? 9 ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"of_ord-doc.obj-type + "" "" + string(of_ord-doc.obj-code)" "От кого" ? ? ? 9 ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"IF (of_ord-doc.status_ = {&fact} or of_ord-doc.status_ = {&ord-close})  THEN (of_ord-doc.status_ + string(of_ord-doc.flag_,""+/-""))  ELSE (of_ord-doc.status_)" ? ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-31 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-32
/* Query rebuild information for BROWSE BROWSE-32
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH e_fp_ord-dtl
      WHERE x-artic      = e_fp_ord-dtl.artic and
x-prod-type  = e_fp_ord-dtl.prod-type and
x-prod-code  = e_fp_ord-dtl.prod-code and
string(e_fp_ord-dtl.node-code) MATCHES x-node-code NO-LOCK,
      EACH e_fp_ord-doc OF e_fp_ord-dtl where
                       e_fp_ord-doc.cons-code = loc-ord-cons-code and
                       e_fp_ord-doc.doc-type = {&f-p}
                      NO-LOCK,
      first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl.node-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "x-artic      = e_fp_ord-dtl.artic and
x-prod-type  = e_fp_ord-dtl.prod-type and
x-prod-code  = e_fp_ord-dtl.prod-code and
string(e_fp_ord-dtl.node-code) MATCHES x-node-code"
     _Where[3]         = "ub.gds-prt.node-code = e_fp_ord-doc.node-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-32 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-33
/* Query rebuild information for BROWSE BROWSE-33
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH e_fp_ord-dtl-rcv
              WHERE x-artic      = e_fp_ord-dtl-rcv.artic and
                    x-prod-type  = e_fp_ord-dtl-rcv.prod-type and
                    x-prod-code  = e_fp_ord-dtl-rcv.prod-code and
                    string(e_fp_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,
      EACH e_fp_ord-doc-rcv
                             where e_fp_ord-doc-rcv.rcv-code            = e_fp_ord-dtl-rcv.rcv-code and
                                              e_fp_ord-doc-rcv.doc-code     = e_fp_ord-dtl-rcv.doc-code and
                       e_fp_ord-doc-rcv.cons-code  = loc-ord-cons-code and
                       e_fp_ord-doc-rcv.doc-type    = "out":U
                      NO-LOCK,
      first ub.gds-prt WHERE ub.gds-prt.node-code = e_fp_ord-dtl-rcv.node-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "e_fp_ord-doc-rcv.doc-code = e_fp_ord-dtl-rcv.doc-code
  AND e_fp_ord-doc-rcv.rcv-code = e_fp_ord-dtl-rcv.rcv-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-33 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-34
/* Query rebuild information for BROWSE BROWSE-34
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH l_rcv_ord-dtl-rcv
              WHERE x-artic      = l_rcv_ord-dtl-rcv.artic and
                    x-prod-type  = l_rcv_ord-dtl-rcv.prod-type and
                    x-prod-code  = l_rcv_ord-dtl-rcv.prod-code and
                    string(l_rcv_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,
      EACH l_rcv_ord-doc-rcv
            where l_rcv_ord-doc-rcv.rcv-code     = l_rcv_ord-dtl-rcv.rcv-code and
                   l_rcv_ord-doc-rcv.doc-code   = l_rcv_ord-dtl-rcv.doc-code and
                   l_rcv_ord-doc-rcv.cons-code  = loc-ord-cons-code
                   NO-LOCK,
      first ub.gds-prt WHERE ub.gds-prt.node-code = l_rcv_ord-dtl-rcv.node-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-34 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-35
/* Query rebuild information for BROWSE BROWSE-35
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH l_rcv_gds-dtl
    WHERE x-artic      = l_rcv_gds-dtl.artic and
          x-prod-type  = l_rcv_gds-dtl.prod-type and
          x-prod-code  = l_rcv_gds-dtl.prod-code and
          string(l_rcv_gds-dtl.prt-code) MATCHES x-node-code NO-LOCK,
      EACH l_rcv_trn-doc where
            l_rcv_trn-doc.doc-code   = l_rcv_gds-dtl.doc-code NO-LOCK,
      each ub.gds-prt WHERE
           ub.gds-prt.node-code = l_rcv_gds-dtl.prt-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-35 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-36
/* Query rebuild information for BROWSE BROWSE-36
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH obj_ord-dtl-rcv
    WHERE x-artic      = obj_ord-dtl-rcv.artic and
          x-prod-type  = obj_ord-dtl-rcv.prod-type and
          x-prod-code  = obj_ord-dtl-rcv.prod-code and
          string(obj_ord-dtl-rcv.node-code) MATCHES x-node-code NO-LOCK,
    EACH obj_ord-doc-rcv
          where obj_ord-doc-rcv.rcv-code     = obj_ord-dtl-rcv.rcv-code and
                  obj_ord-doc-rcv.doc-code   = obj_ord-dtl-rcv.doc-code and
                  obj_ord-doc-rcv.doc-type   = 'in' and
                  obj_ord-doc-rcv.cons-code  = loc-ord-cons-code
                 NO-LOCK,
  first ub.gds-prt WHERE ub.gds-prt.node-code = obj_ord-dtl-rcv.node-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",, FIRST"
     _Query            is OPENED
*/  /* BROWSE BROWSE-36 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-37
/* Query rebuild information for BROWSE BROWSE-37
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH obj_prt-obj
              WHERE obj_prt-obj.is-term = true and
                          x-artic      = obj_prt-obj.artic and
                    x-prod-type  = obj_prt-obj.prod-type and
                    x-prod-code  = obj_prt-obj.prod-code and
                    string(obj_prt-obj.prt-code) MATCHES x-node-code NO-LOCK,
      each ub.gds-prt WHERE ub.gds-prt.node-code = obj_prt-obj.prt-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ub.gds-prt.node-code = ub.obj_gds-dtl.node-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-37 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME FRAME-Post-prt
/* Query rebuild information for FRAME FRAME-Post-prt
     _Query            is NOT OPENED
*/  /* FRAME FRAME-Post-prt */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ALT-1 OF FRAME Dialog-Frame /* Планирование заказа */
anywhere
DO:
    apply  "CHOOSE":U   to  button-2 in frame Dialog-frame.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ALT-2 OF FRAME Dialog-Frame /* Планирование заказа */
anywhere
DO:
  apply  "CHOOSE":U   to  button-3 in frame Dialog-frame.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ALT-3 OF FRAME Dialog-Frame /* Планирование заказа */
anywhere
DO:
  apply  "CHOOSE":U   to  button-47 in frame Dialog-frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ALT-7 OF FRAME Dialog-Frame /* Планирование заказа */
DO:

frame  frame-d:selectable = false .
frame  frame-d:resizable = false .
frame  frame-d:movable = false .
frame  frame-d:bgcolor = ? .
browse-13:selectable = false .
browse-13:resizable = false .
browse-13:movable = false .

frame  frame-f:selectable = false .
frame  frame-f:resizable = false .
frame  frame-f:movable = false .
frame  frame-f:bgcolor = ? .
browse-16:selectable = false .
browse-16:resizable = false .
browse-16:movable = false .


frame  frame-a:selectable = false .
frame  frame-a:resizable = false .
frame  frame-a:movable = false .
frame  frame-a:bgcolor = ? .
browse-12:selectable = false .
browse-12:resizable = false .
browse-12:movable = false .

display  browse-16 with frame frame-f .
display  browse-12 with frame frame-a .


END.
ON ALT-8 OF FRAME Dialog-Frame /* Планирование заказа */
DO:
/*
frame  frame-f:selectable = true .
frame  frame-f:resizable = true .
frame  frame-f:movable = true .
frame  frame-f:bgcolor = 1 .
browse-16:selectable = true .
browse-16:resizable = true .
browse-16:movable = true .
frame  frame-d:selectable = true .
frame  frame-d:resizable = true .
frame  frame-d:movable = true .
frame  frame-d:bgcolor = 2 .
browse-13:selectable = true .
browse-13:resizable = true .
browse-13:movable = true .
*/

frame  frame-a:selectable = true .
frame  frame-a:resizable = true .
frame  frame-a:movable = true .
frame  frame-a:bgcolor = 5 .
browse-12:selectable = true .
browse-12:resizable = true .
browse-12:movable = true .


frame frame-d:MOVE-TO-BOTTOM ( )  .
frame frame-f:MOVE-TO-BOTTOM ( )  .

frame frame-a:MOVE-TO-TOP ( )  .
frame frame-a:TOP-ONLY  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Планирование заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-F
&Scoped-define SELF-NAME B-ins-za
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ins-za Dialog-Frame
ON CHOOSE OF B-ins-za IN FRAME FRAME-F /* Доб. */
DO:
  run proc-b-ins-za in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-isk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-isk Dialog-Frame
ON CHOOSE OF B-isk IN FRAME FRAME-F /* Исключить */
DO:
   run status-isk in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME FRAME-A /* * */
OR MOUSE-SELECT-DBLCLICK OF BROWSE-12 IN FRAME frame-A
DO:
  run p-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME B-mark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-2 Dialog-Frame
ON CHOOSE OF B-mark-2 IN FRAME FRAME-J /* + */
OR MOUSE-SELECT-DBLCLICK OF BROWSE-18 IN FRAME frame-J
DO:
  run local-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME B-mark-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-3 Dialog-Frame
ON CHOOSE OF B-mark-3 IN FRAME FRAME-A /* - */
DO:
  run del-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-4 Dialog-Frame
ON CHOOSE OF B-mark-4 IN FRAME FRAME-A /* + */
DO:
  run plus-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-C
&Scoped-define SELF-NAME B-mark-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-5 Dialog-Frame
ON CHOOSE OF B-mark-5 IN FRAME FRAME-C /* * */
OR MOUSE-SELECT-DBLCLICK OF BROWSE-12 IN FRAME frame-A
DO:
  run p-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-6 Dialog-Frame
ON CHOOSE OF B-mark-6 IN FRAME FRAME-C /* - */
DO:
  run del-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-7 Dialog-Frame
ON CHOOSE OF B-mark-7 IN FRAME FRAME-C /* + */
DO:
  run plus-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Выход */
DO:
   run proc-b-ok in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-F
&Scoped-define SELF-NAME B-reject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-reject Dialog-Frame
ON CHOOSE OF B-reject IN FRAME FRAME-F /* Отказать */
DO:
   run status-rej in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-za-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-za-3 Dialog-Frame
ON CHOOSE OF B-za-3 IN FRAME FRAME-F /* Просм. */
DO:
g#type = {&o-f}.
br-handle = browse-13:handle in frame frame-d.

run zayvka in this-procedure ("lkp":U).
if br-handle = ? then reposition browse-13 to recid doc-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-12
&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME BROWSE-12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-12 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-12 IN FRAME FRAME-A /* Совокупный заказ */
DO:
  run proc-row-br-12 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-12 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-12 IN FRAME FRAME-A /* Совокупный заказ */
DO:
 run br-12 in this-procedure .
END.

on F9 of frame dialog-frame anywhere do:
  run show-gds in this-procedure .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-13
&Scoped-define FRAME-NAME FRAME-D
&Scoped-define SELF-NAME BROWSE-13
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-13 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-13 IN FRAME FRAME-D /* Заявки ОФ по товару */
DO:
     if frame FRAME-postavki:visible and avail ub.ord-doc and not T-of  then do:
      BROWSE-29:title = "Арт."  + x-artic  + " заявка "
     + ub.ord-doc.doc-code + " " + ub.ord-doc.obj-type + string(ub.ord-doc.obj-code).
      {&OPEN-QUERY-BROWSE-29}
 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-14
&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME BROWSE-14
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-14 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-14 IN FRAME FRAME-B /* Остатки товара по объектам */
DO:
  run proc-browse-14 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-16
&Scoped-define FRAME-NAME FRAME-F
&Scoped-define SELF-NAME BROWSE-16
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-16 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-16 IN FRAME FRAME-F /* Все Заявки ОФ */
DO:
  run proc-br-16 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-17
&Scoped-define FRAME-NAME FRAME-E
&Scoped-define SELF-NAME BROWSE-17
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-17 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-17 IN FRAME FRAME-E /* Список поставщиков */
DO:
  if ub.cli-gds.price-cli <> 0 then
  buf_clients.obj-name:fgcolor in browse browse-17 = blue_color.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-17 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-17 IN FRAME FRAME-E /* Список поставщиков */
DO:
if frame FRAME-J:visible then do:
   run init-ord-gds in this-procedure  .
  {&OPEN-QUERY-BROWSE-18}
  {&OPEN-QUERY-BROWSE-28}
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-18
&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME BROWSE-18
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-18 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-18 IN FRAME FRAME-J /* Заказы ФП по товару */
DO:
  run proc-color-status in this-procedure ( 18 , {&c-18-7} ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-18 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-18 IN FRAME FRAME-J /* Заказы ФП по товару */
DO:
   run proc-br-18 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-21
&Scoped-define FRAME-NAME FRAME-Postavki
&Scoped-define SELF-NAME BROWSE-21
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-21 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-21 IN FRAME FRAME-Postavki /* Все Поставки по СЗФП */
DO:
    {&OPEN-QUERY-BROWSE-22}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-26
&Scoped-define FRAME-NAME FRAME-K
&Scoped-define SELF-NAME BROWSE-26
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-26 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-26 IN FRAME FRAME-K /* Заказы ФП */
DO:
  run proc-color-status in this-procedure ( 26 , {&c-18-7} ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-26 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-26 IN FRAME FRAME-K /* Заказы ФП */
DO:
run proc-browse-26 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-27
&Scoped-define SELF-NAME BROWSE-27
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-27 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-27 IN FRAME FRAME-K /* Поставки по заказу */
DO:
    run proc-color-status in this-procedure  ( 27 , {&c-28-10} ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-28
&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME BROWSE-28
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-28 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-28 IN FRAME FRAME-J /* Поставки по строкам */
DO:
  run proc-color-status in this-procedure ( 28 ,  {&c-28-10}  ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-29
&Scoped-define FRAME-NAME FRAME-Postavki
&Scoped-define SELF-NAME BROWSE-29
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-29 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-29 IN FRAME FRAME-Postavki /* Все поставки по товару и заявке */
DO:
  {&OPEN-QUERY-BROWSE-22}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-30
&Scoped-define FRAME-NAME FRAME-C
&Scoped-define SELF-NAME BROWSE-30
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-30 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-30 IN FRAME FRAME-C /* Совокупный заказ */
DO:
run proc-color-str in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-30 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-30 IN FRAME FRAME-C /* Совокупный заказ */
DO:
 run br-12 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME BUTTON-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-10 Dialog-Frame
ON CHOOSE OF BUTTON-10 IN FRAME FRAME-J /* Удал. */
DO:
  run proc-but-10 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-H
&Scoped-define SELF-NAME BUTTON-14
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-14 Dialog-Frame
ON CHOOSE OF BUTTON-14 IN FRAME FRAME-H /* Удал. */
DO:
run proc-b-14 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-15
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-15 Dialog-Frame
ON CHOOSE OF BUTTON-15 IN FRAME FRAME-H /* Изм. */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-I
&Scoped-define SELF-NAME BUTTON-17
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-17 Dialog-Frame
ON CHOOSE OF BUTTON-17 IN FRAME FRAME-I /* Изм. */
DO:
  run proc-but-17 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-18
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-18 Dialog-Frame
ON CHOOSE OF BUTTON-18 IN FRAME FRAME-I /* Удал. */
DO:
run proc-but-18 in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 Dialog-Frame
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame /* 1.Перемещ. */
DO:
   run proc-init-button-2 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-I
&Scoped-define SELF-NAME BUTTON-20
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-20 Dialog-Frame
ON CHOOSE OF BUTTON-20 IN FRAME FRAME-I /* Удал. */
DO:
run proc-b-20 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-21
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-21 Dialog-Frame
ON CHOOSE OF BUTTON-21 IN FRAME FRAME-I /* Просм. */
DO:
if available ub.trn-doc
then do:
  case ub.trn-doc.doc-type
  :
    when {&income}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        "Тип документа" ub.trn-doc.doc-type skip
        "Код документа" ub.trn-doc.doc-code skip
        view-as alert-box error .
      undo, return no-apply .
    end.
  end case .

  if not g#log then   return no-apply.
  run chg-trn in this-procedure .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-K
&Scoped-define SELF-NAME BUTTON-27
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-27 Dialog-Frame
ON CHOOSE OF BUTTON-27 IN FRAME FRAME-K /* Изм. */
DO:
  /*Изменить заказ ФП*/
  g#type = {&f-p}.
  run chg-ord-fp in this-procedure .
  g#log =  BROWSE-26:REFRESH() no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-28
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-28 Dialog-Frame
ON CHOOSE OF BUTTON-28 IN FRAME FRAME-K /* Удал. */
DO:
  define variable d-rec as recid no-undo.
    g#log = no.
    find current ub.ord-doc no-lock no-error .
    if avail  ub.ord-doc then do:
          message "Удалить заказ №" ub.ord-doc.doc-code "?   Вы уверены ?"
                  view-as alert-box question buttons OK-Cancel update g#log.
            if g#log = false then return.

        if ub.ord-doc.status_ <> {&g___new} then do:
          message "Удалить можно только в статусе НОВЫЙ! "  view-as alert-box .
          return no-apply.
        end.

            if avail ub.ord-doc then do:
              d-rec = recid (ub.ord-doc).
              run del-zakaz-doc in this-procedure (d-rec) .
                  {&OPEN-QUERY-BROWSE-26}
            end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME BUTTON-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-3 Dialog-Frame
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame /* 2.Заказы */
DO:
run proc-init-button-3 in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-K
&Scoped-define SELF-NAME BUTTON-30
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-30 Dialog-Frame
ON CHOOSE OF BUTTON-30 IN FRAME FRAME-K /* Изм. */
DO:
define variable v-doc-mode as character no-undo .
    if avail  ub.ord-doc-rcv then do:
     if ub.ord-doc-rcv.status_ = {&g___new} then do:
        run cus/or-obj.w
             ( input  parParentProc
             , input  ub.ord-doc-rcv.host-code
             , input  recid(ub.ord-doc-rcv)
             , input  3
             , input  {&update}
             , input  {&update}
             , input-output  v-doc-mode
             ) .

        g#log = BROWSE-27:refresh() no-error .
        run calc-cons-ord in this-procedure .
     end.
     else do:
        if ub.ord-doc-rcv.status_ = {&ord-accept}
            then
                message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя ."
                "Для проставления времени фактической доставки используйте другие режимы ! "
                view-as alert-box .

            else  message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя !  "
                  view-as alert-box .
     end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-31
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-31 Dialog-Frame
ON CHOOSE OF BUTTON-31 IN FRAME FRAME-K /* Удал. */
DO:
run proc-b-31 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME BUTTON-33
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-33 Dialog-Frame
ON CHOOSE OF BUTTON-33 IN FRAME FRAME-J /* Изм. */
DO:
define variable v-doc-mode as character no-undo .
  if avail  ub.ord-line-rcv then do:
     find first ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code and
                                          ub.ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code no-error .

     if available  ub.ord-doc-rcv and ub.ord-doc-rcv.status_ = {&g___new} then do:
        v-doc-mode  = {&update} .
        run cus/or-obj.w
             ( input  parParentProc
             , input  ub.ord-doc-rcv.host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  {&update}
             , input  {&update}
             , input-output  v-doc-mode  ) .
        g#log = BROWSE-28:refresh() no-error .
        run calc-cons-ord in this-procedure .
     end.
     else do:
        if ub.ord-doc-rcv.status_ = {&ord-accept}
            then
                message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя ."
                "Для проставления времени фактической доставки используйте другие режимы ! "
                view-as alert-box .

            else  message "Статус поставки " ub.ord-doc-rcv.status_ ". Корректировать нельзя !  "
                  view-as alert-box .
     end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-34
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-34 Dialog-Frame
ON CHOOSE OF BUTTON-34 IN FRAME FRAME-J /* Удал. */
DO:
  define variable d-rec as recid no-undo.
    g#log = no.
    if avail  ub.ord-line-rcv then do:
    message "Удалить строку в поставке №" ub.ord-line-rcv.rcv-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update g#log.
      if g#log = false then return.


  d-rec = recid (ord-line-rcv).
  run del-post in this-procedure (d-rec) .
     {&OPEN-QUERY-BROWSE-28}

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME BUTTON-47
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-47 Dialog-Frame
ON ALT-3 OF BUTTON-47 IN FRAME Dialog-Frame /* 3.Поставки */
DO:
    apply  "CHOOSE":U   to  {&self-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-47 Dialog-Frame
ON CHOOSE OF BUTTON-47 IN FRAME Dialog-Frame /* 3.Поставки */
DO:
run proc-init-button-47 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-Postavki
&Scoped-define SELF-NAME BUTTON-49
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-49 Dialog-Frame
ON CHOOSE OF BUTTON-49 IN FRAME FRAME-Postavki /* Просм. */
DO:
find current  ub.trn-doc no-lock  no-error .
if avail  ub.trn-doc
then do:
  case ub.trn-doc.doc-type
  :
    when {&income}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
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
        "Тип документа" ub.trn-doc.doc-type skip
        "Код документа" ub.trn-doc.doc-code skip
        view-as alert-box error .
      undo, return no-apply .
    end.
  end case .
  if not g#log then   return no-apply.
  run chg-trn in this-procedure .
End.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-50
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-50 Dialog-Frame
ON CHOOSE OF BUTTON-50 IN FRAME FRAME-Postavki /* Изм. */
DO:
  run proc-50 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-51
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-51 Dialog-Frame
ON CHOOSE OF BUTTON-51 IN FRAME FRAME-Postavki /* Удал. */
DO:
run proc-b-51 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-52
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-52 Dialog-Frame
ON CHOOSE OF BUTTON-52 IN FRAME FRAME-Postavki /* Просм. */
DO:
  run proc-522 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-K
&Scoped-define SELF-NAME BUTTON-53
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-53 Dialog-Frame
ON CHOOSE OF BUTTON-53 IN FRAME FRAME-K /* Просм. */
DO:
  /*lookup заказ ФП*/
  g#type = {&f-p}.
line-mode = {&lookup}.
br-handle = browse-26:handle in frame frame-k.
run zayvka in this-procedure ("lkp":U).
if br-handle = ? then reposition browse-26 to recid doc-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-54
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-54 Dialog-Frame
ON CHOOSE OF BUTTON-54 IN FRAME FRAME-K /* Просм. */
DO:
run proc-b-54 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME BUTTON-55
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-55 Dialog-Frame
ON CHOOSE OF BUTTON-55 IN FRAME FRAME-J /* Просм. */
DO:
 line-mode = {&lookup}.
 run chg-ord-line in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-56
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-56 Dialog-Frame
ON CHOOSE OF BUTTON-56 IN FRAME FRAME-J /* Просм. */
DO:
run proc-b-56 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-I
&Scoped-define SELF-NAME BUTTON-57
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-57 Dialog-Frame
ON CHOOSE OF BUTTON-57 IN FRAME FRAME-I /* Просм. */
DO:
  run proc-52 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-H
&Scoped-define SELF-NAME BUTTON-58
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-58 Dialog-Frame
ON CHOOSE OF BUTTON-58 IN FRAME FRAME-H /* Просм. */
DO:
run proc-b-58 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-59
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-59 Dialog-Frame
ON CHOOSE OF BUTTON-59 IN FRAME FRAME-H /* Просм. */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-7 Dialog-Frame
ON CHOOSE OF BUTTON-7 IN FRAME FRAME-H /* Изм. */
DO:
run proc-b-7 In This-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-8 Dialog-Frame
ON CHOOSE OF BUTTON-8 IN FRAME FRAME-H /* Удал. */
DO:
 run proc-bt-8 in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-J
&Scoped-define SELF-NAME BUTTON-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-9 Dialog-Frame
ON CHOOSE OF BUTTON-9 IN FRAME FRAME-J /* Изм. */
DO:
 line-mode = {&update}.
 run chg-ord-line in this-procedure .
 g#log = BROWSE-18:refresh() in frame frame-j no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cr_post
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cr_post Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cr_post /* Сделать   ПН/РН по поставке */
DO:
  find current new-rcv no-lock no-error .
  if avail new-rcv  and recid(new-rcv) <> ? then do:
    run make-trn in this-procedure  (recid(new-rcv)).
    g#log = BROWSE-21:refresh() in frame frame-postavki no-error .
    {&OPEN-QUERY-BROWSE-22}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_d_post
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_d_post Dialog-Frame
ON CHOOSE OF MENU-ITEM m_d_post /* Отменить привязку  к  ПН/РН */
DO:
  run proc-m_d_post in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_H_0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_H_0 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_H_0 /* Сделать поставку по тек.товару */
DO:
   run post-4-gds in this-procedure  (input "{&SELF-NAME}" ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_H_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_H_2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_H_2 /* Сделать поставку по товарам(*) */
DO:
   run post-4-gds in this-procedure  (input "{&SELF-NAME}" ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_H_3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_H_3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_H_3 /* Сделать   РН по поставке товара */
DO:

find current b-all_ord-doc-rcv no-lock no-error .
  if avail b-all_ord-doc-rcv then do:
    run make-trn in this-procedure  (recid(b-all_ord-doc-rcv)).
    {&OPEN-QUERY-BROWSE-15}

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_I_3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_I_3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_I_3 /* Сделать   РН по поставке */
DO:

find current ub.ord-doc-rcv no-lock no-error .
  if avail ub.ord-doc-rcv then do:
    run make-trn in this-procedure  (recid(ub.ord-doc-rcv)) .
    {&OPEN-QUERY-BROWSE-24}
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_I_4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_I_4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_I_4 /* Сделать поставку по заявке ОФ */
DO:
  run post-4 in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_J_1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_J_1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_J_1 /* Сделать заказ ФП по тек.товару */
DO:
  run zakaz-2 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_J_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_J_2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_J_2 /* Сделать поставку внешнюю   по тек.товару */
DO:
  run post-3 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_J_4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_J_4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_J_4 /* Сделать заказ ФП по товарам(*) */
DO:
   run zakaz-1 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_k_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_k_2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_k_2 /* Сделать заказ ФП по заявке  ОФ */
DO:
  run zakaz-1-of in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_k_3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_k_3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_k_3 /* Сделать поставку внешнюю по заказу */
DO:
  run post-1 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_k_4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_k_4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_k_4 /* Сделать поставку по товарам(+) из заказа */
DO:
  run post-2 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_k_5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_k_5 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_k_5 /* Сделать поставку по заказу с учетом заявок */
DO:
  run post-5 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_post_1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_post_1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_post_1 /* Привязать ПН/РН к  поставке */
DO:

  find current new-rcv no-lock no-error .
  if avail new-rcv then do:
      run att-rcv in this-procedure (recid(new-rcv)) no-error .
      g#log = BROWSE-21:refresh() in frame frame-postavki no-error .
      {&OPEN-QUERY-BROWSE-22}
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_post_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_post_2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_post_2 /* Привязать РН  к поставке */
DO:
find current ub.ord-doc-rcv no-lock no-error .
  if avail ub.ord-doc-rcv then do:
    run att-rcv in this-procedure (recid(ub.ord-doc-rcv)) no-error .
    {&OPEN-QUERY-BROWSE-24}
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME R-main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-main Dialog-Frame
ON VALUE-CHANGED OF R-main IN FRAME Dialog-Frame
DO:
  run pr-main in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-E
&Scoped-define SELF-NAME T-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-cli Dialog-Frame
ON VALUE-CHANGED OF T-cli IN FRAME FRAME-E /* все */
DO:
assign frame frame-e t-cli .
if t-cli then do:
  {&OPEN-QUERY-BROWSE-17-alt}
  end.
  else do:
  {&OPEN-QUERY-BROWSE-17}
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-cli-fp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-cli-fp Dialog-Frame
ON VALUE-CHANGED OF T-cli-fp IN FRAME FRAME-E /* по поставщику */
DO:
assign frame frame-e t-cli-fp .

if frame FRAME-J:visible then do:
   {&OPEN-QUERY-BROWSE-18}
end.
else do:
    {&OPEN-QUERY-BROWSE-26}
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define SELF-NAME T-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-gds Dialog-Frame
ON VALUE-CHANGED OF T-gds IN FRAME Dialog-Frame /* развернуть */
DO:
run proc-t-gds in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-B
&Scoped-define SELF-NAME T-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-obj Dialog-Frame
ON VALUE-CHANGED OF T-obj IN FRAME FRAME-B /* все */
DO:
  assign frame frame-B t-obj .
if t-obj then do:

  {&OPEN-QUERY-BROWSE-14-alt}
    BROWSE-14:title = "Все объекты" .
  end.
  else do:
  BROWSE-14:title = "Остатки товара по объектам" .
  {&OPEN-QUERY-BROWSE-14}
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-12
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

  {&WINDOW-NAME} :KEEP-FRAME-Z-ORDER  = true  .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */


{ gbl/app_help.i }
{ gbl/srt-clmn.i
  &browse-name    = "browse-18"
  &frame-name     = "frame-J"
  &table-name     = "{&first-table-in-query-browse-18}"
  &sort-clmn_1    = "mark"
  &label-clmn_1   = "'+'"
  &sort-clmn_2    = "{&c-18-2}"
  &label-clmn_2   = "'№ заказа'"
  &sort-clmn_3    = "{&c-18-3}"
  &label-clmn_3   = "'Заказать'"
  &sort-clmn_4    = "{&c-18-4}"
  &label-clmn_4   = "'Кому'"
  &sort-clmn_6    = "{&c-18-6}"
  &label-clmn_6   = "'Поставщик'"
  &sort-clmn_7    = "{&c-18-7}"
  &label-clmn_7   = "'Статус'"
  &sort-clmn_8    = "{&c-18-8}"
  &label-clmn_8   = "'Название'"
  &sort-clmn_9    = "{&c-18-9}"
  &label-clmn_9   = "'Артикул'"
  &open-query     = "{&OPEN-QUERY-BROWSE-18}"
  &open-query-otherwise = "{&OPEN-QUERY-BROWSE-18}"
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }

{ gbl/srt-clmn.i
  &browse-name     = "browse-28"
  &frame-name      = "frame-J"
  &table-name      = "{&first-table-in-query-browse-28}"
  &sort-clmn_1     = "{&c-28-1}"
  &label-clmn_1    = "{&l-28-1}"
  &sort-clmn_2     = "{&c-28-2}"
  &label-clmn_2    = "{&l-28-2}"
  &sort-clmn_3     = "{&c-28-3}"
  &label-clmn_3    = "{&l-28-3}"
  &sort-clmn_4     = "{&c-28-4}"
  &label-clmn_4    = "{&l-28-4}"
  &sort-clmn_5     = "{&c-28-5}"
  &label-clmn_5    = "{&l-28-5}"
  &sort-clmn_6     = "{&c-28-6}"
  &label-clmn_6    = "{&l-28-6}"
  &sort-clmn_7     = "{&c-28-7}"
  &label-clmn_7    = "{&l-28-7}"
  &sort-clmn_8     = "{&c-28-8}"
  &label-clmn_8    = "{&l-28-8}"
  &sort-clmn_9     = "{&c-28-9}"
  &label-clmn_9    = "{&l-28-9}"
  &sort-clmn_10    = "{&c-28-10}"
  &label-clmn_10   = "{&l-28-10}"
  &sort-clmn_11    = "{&c-28-11}"
  &label-clmn_11   = "{&l-28-11}"
  &open-query     = "{&OPEN-QUERY-BROWSE-28}"
  &open-query-otherwise = "{&OPEN-QUERY-BROWSE-28}"
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }

{ gbl/srt-clmn.i
  &browse-name     = "browse-29"
  &frame-name      = "FRAME-Postavki"
  &table-name      = "{&first-table-in-query-browse-29}"
  &sort-clmn_1     = "{&c-29-1}"
  &label-clmn_1    = "{&l-29-1}"
  &sort-clmn_2     = "{&c-29-2}"
  &label-clmn_2    = "{&l-29-2}"
  &sort-clmn_3     = "{&c-29-3}"
  &label-clmn_3    = "{&l-29-3}"
  &sort-clmn_4     = "{&c-29-4}"
  &label-clmn_4    = "{&l-29-4}"
  &sort-clmn_5     = "{&c-29-5}"
  &label-clmn_5    = "{&l-29-5}"
  &sort-clmn_6     = "{&c-29-6}"
  &label-clmn_6    = "{&l-29-6}"
  &sort-clmn_7     = "{&c-29-7}"
  &label-clmn_7    = "{&l-29-7}"
  &sort-clmn_8     = "{&c-29-8}"
  &label-clmn_8    = "{&l-29-8}"
  &sort-clmn_10    = "{&c-29-10}"
  &label-clmn_10   = "{&l-29-10}"
  &sort-clmn_11    = "{&c-29-11}"
  &label-clmn_11   = "{&l-29-11}"
  &sort-clmn_12    = "{&c-29-12}"
  &label-clmn_12   = "{&l-29-12}"
  &sort-clmn_13    = "{&c-29-13}"
  &label-clmn_13   = "{&l-29-13}"
  &sort-clmn_14    = "{&c-29-14}"
  &label-clmn_14   = "{&l-29-14}"
  &sort-clmn_15    = "{&c-29-15}"
  &label-clmn_15   = "{&l-29-15}"

  &open-query     = "{&OPEN-QUERY-BROWSE-29}"
  &open-query-otherwise = "{&OPEN-QUERY-BROWSE-29}"
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }


{ gbl/srt-clmn.i
  &browse-name     = "browse-20"
  &frame-name      = "frame-h"
  &table-name      = "{&first-table-in-query-browse-20}"
  &sort-clmn_1     = "{&c-20-1}"
  &label-clmn_1    = "{&l-20-1}"
  &sort-clmn_2     = "{&c-20-2}"
  &label-clmn_2    = "{&l-20-2}"
  &sort-clmn_3     = "{&c-20-3}"
  &label-clmn_3    = "{&l-20-3}"
  &sort-clmn_4     = "{&c-20-4}"
  &label-clmn_4    = "{&l-20-4}"
  &sort-clmn_5     = "{&c-20-5}"
  &label-clmn_5    = "{&l-20-5}"
  &sort-clmn_6     = "{&c-20-6}"
  &label-clmn_6    = "{&l-20-6}"
  &sort-clmn_7     = "{&c-20-7}"
  &label-clmn_7    = "{&l-20-7}"
  &sort-clmn_8     = "{&c-20-8}"
  &label-clmn_8    = "{&l-20-8}"
  &sort-clmn_9    = "{&c-20-9}"
  &label-clmn_9   = "{&l-20-9}"
  &open-query     = "{&OPEN-QUERY-BROWSE-20}"
  &open-query-otherwise = "{&OPEN-QUERY-BROWSE-20}"
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }

{ gbl/srt-clmn.i
  &browse-name     = "browse-12"
  &frame-name      = "frame-a"
  &table-name      = "{&first-table-in-query-browse-12}"
  &sort-clmn_1  = "tt-goods.use"
  &sort-clmn_2  = "tt-goods.artic"
  &sort-clmn_3  = "tt-goods.gds-name"
  &sort-clmn_4  = "tt-goods.sum-qnty"
  &sort-clmn_5  = "tt-goods.sum-ord"
  &sort-clmn_6  = "tt-goods.sum-rcv"
  &sort-clmn_7  = "tt-goods.sum-rcv-in"
  &sort-clmn_8  = "tt-goods.unit-base"
  &sort-clmn_9  = "tt-goods.unit-cli"
  &sort-clmn_10 = "tt-goods.sum-fact"
  &open-query     = "{&OPEN-QUERY-BROWSE-12}"
  &open-query-otherwise = "{&OPEN-QUERY-BROWSE-12}"
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }

  tt-goods.gds-name:resizable in browse BROWSE-12 = true .
  tt-goods.artic:resizable in browse BROWSE-12 = true .

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find  ub.ord-cons exclusive-lock  where ub.ord-cons.cons-code = p-cons-code  .
  run init-proc in this-procedure .
  run enable_UI in this-procedure .
  run init-2 in this-procedure .
  { gbl/mv-clmn.i
  &ext-col = 8
  &frame-name = "frame-j"
  &browse-name = "browse-18"
  &start-column = "1"
  }
  { gbl/mv-clmn.i
  &ext-col = 11
  &frame-name = "frame-j"
  &browse-name = "browse-28"
  &start-column = "1"
  }
  { gbl/mv-clmn.i
  &ext-col = 10
  &frame-name = "frame-a"
  &browse-name = "browse-12"
  &start-column = "2"
  }
  { gbl/mv-clmn.i
  &ext-col = 10
  &frame-name = "frame-h"
  &browse-name = "browse-20"
  &start-column = "1"
  }
  { gbl/mv-clmn.i
  &ext-col = 15
  &frame-name = "frame-postavki"
  &browse-name = "browse-29"
  &start-column = "1"
  }

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE att-rcv Dialog-Frame
PROCEDURE att-rcv :
do
 on error undo, return error return-value
 :

define input parameter b-recid as recid no-undo .
define variable loc-ref-list as character no-undo .
define variable p-trn-code as character no-undo .
define buffer bub_ord-doc-rcv for ub.ord-doc-rcv .
define buffer loc_buf_ord-line-rcv for ub.ord-line-rcv .
define buffer loc_buf_doc-line for ub.doc-line .

find first bub_ord-doc-rcv  no-lock where recid( bub_ord-doc-rcv)  = b-recid no-error .

if not avail bub_ord-doc-rcv then do:
  message  "Не выбрана поставка !!! " view-as alert-box .
  return .
end.

if bub_ord-doc-rcv.status_ <> {&ord-rcv} then do:
  message "Нельзя сделать накладную на поставку в статусе " caps(bub_ord-doc-rcv.status_) view-as alert-box .
  return.
end.

define variable v-input-output as character no-undo .

run str/all-docs.w
 ( input  parparentproc
 ,input   bub_ord-doc-rcv.host-code /*host-code*/
 ,input   bub_ord-doc-rcv.obj-type  /*obj-type*/
 ,input   bub_ord-doc-rcv.obj-code  /*obj-code*/
 ,input  {&company}
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  "b-sel":U
 ,input  ?
 ,input  false
 ,input  ?
 ,output loc-ref-list
 ).


if loc-ref-list = ? or loc-ref-list = ""  then return.

  find first ub.trn-doc no-lock where recid(trn-doc) = int(loc-ref-list) no-error .
  if available ub.trn-doc then  assign
                              p-trn-code = ub.trn-doc.doc-code
                              doc-rec = recid(trn-doc)
                              .
                       else  assign
                             p-trn-code = ?
                       .

/* Проверка состава поставки и накладной */
define variable  j-trn as integer no-undo .
define variable  j-rcv as integer no-undo .

 j-trn = 0.
 j-rcv = 0.
 for each loc_buf_ord-line-rcv no-lock where loc_buf_ord-line-rcv.doc-code =  bub_ord-doc-rcv.doc-code and
                                             loc_buf_ord-line-rcv.rcv-code =  bub_ord-doc-rcv.rcv-code :
    j-rcv = j-rcv + 1.
    if can-find (first loc_buf_doc-line where loc_buf_doc-line.doc-code = ub.trn-doc.doc-code and
                       loc_buf_ord-line-rcv.artic =  loc_buf_doc-line.artic and
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

  run create-chain (
  bub_ord-doc-rcv.rcv-code
  ,'rcv'
  ,p-trn-code
  ,'trn'
  ,''
  ,''
  ).
  run calc-cons-ord In This-procedure .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-12 Dialog-Frame
PROCEDURE br-12 :
do
 on error undo, return error return-value
 :

define variable p-recid as recid no-undo .
if avail tt-goods then do:
    assign
    x-artic       = tt-goods.artic
    x-prod-type   = tt-goods.prod-type
    x-prod-code   = tt-goods.prod-code
    x-node-code    = string(tt-goods.node-code)
    str-good = x-artic + " " + tt-goods.gds-name  + " (" + tt-goods.prt-name + ")"  .

    if tt-goods.gds-t = {&h-goods} then assign
     x-node-code = "*"
     str-good = x-artic + " " + tt-goods.gds-name      .
     p-recid = recid(tt-goods).
 end.

else do:
  message "Совокупная Заявка пуста ! " view-as alert-box .
  return error.
end.

 display str-good with frame Dialog-Frame.
/* все заявки по СЗФП */
 IF frame FRAME-d:visible  Then do:
     {&OPEN-QUERY-BROWSE-13}
     apply "VALUE-CHANGED":U to BROWSE-13 in frame frame-D .
    /*объекты и товары */
      {&OPEN-BROWSERS-IN-QUERY-FRAME-B}
      {&OPEN-BROWSERS-IN-QUERY-FRAME-H}
end.

 IF frame FRAME-d-prt:visible  Then do:
     {&OPEN-QUERY-BROWSE-31}
     apply "VALUE-CHANGED":U to BROWSE-31 in frame frame-D-prt .
end.

/* ПОСТАВКЩИКИ */

IF frame FRAME-E:visible  Then do:
  if t-prt = false then do:
      if not  t-cli then do:
        {&OPEN-BROWSERS-IN-QUERY-FRAME-E}
        {&OPEN-QUERY-BROWSE-17}
        apply "VALUE-CHANGED":U to BROWSE-17 in frame frame-E .
      end.
  end.
  if t-prt = true  then do:
    {&OPEN-BROWSERS-IN-QUERY-FRAME-E-prt}
    reposition browse-30 to recid p-recid no-error .
  end.

end.

IF frame FRAME-J:visible  Then do:
     BROWSE-18:title = "Заказы ФП по товару " + x-artic .
     {&OPEN-QUERY-BROWSE-18}
     apply "VALUE-CHANGED":U to BROWSE-18 in frame frame-J .
     BROWSE-28:title = "Поставки по товару " + x-artic .
     {&OPEN-QUERY-BROWSE-28}

end.
/* ОБЪЕКТЫ */

IF frame FRAME-B:visible  Then do:
  if t-prt = false then do:
      if not  t-obj then do:
        {&OPEN-BROWSERS-IN-QUERY-FRAME-B}
        {&OPEN-QUERY-BROWSE-14}
        apply "VALUE-CHANGED":U to BROWSE-14 in frame frame-B .
      end.
      if  t-obj then do:
        {&OPEN-QUERY-BROWSE-14-alt}
        apply "VALUE-CHANGED":U to BROWSE-14 in frame frame-B .
      end.
  end.
  if t-prt = true then do:
      {&OPEN-BROWSERS-IN-QUERY-FRAME-B-prt}
      reposition browse-30 to recid p-recid no-error .
  end.
end.

IF frame FRAME-H:visible  Then do:
     BROWSE-15:title = "Внутренние ПН по товару " + x-artic .
     {&OPEN-QUERY-BROWSE-15}
     apply "VALUE-CHANGED":U to BROWSE-15 in frame frame-H .
     BROWSE-20:title = "Поставки по товару " + x-artic .
     {&OPEN-QUERY-BROWSE-20}
end.
IF frame FRAME-postavki:visible  Then do:
  if t-prt = true then do:
      {&OPEN-QUERY-BROWSE-34}
      {&OPEN-QUERY-BROWSE-35}
      reposition browse-30 to recid p-recid no-error .
  end.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-cons-ord Dialog-Frame
PROCEDURE calc-cons-ord :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:     Пересчет количеств по совокупному заказу
------------------------------------------------------------------------------*/
define buffer locb-ord-doc  for ub.ord-doc .
define buffer locb-ord-line for ub.ord-line .
define buffer locb-ord-dtl  for ub.ord-dtl .

define buffer locb-rcv-doc  for ub.ord-doc-rcv .
define buffer locb-rcv-line for ub.ord-line-rcv .
define buffer locb-rcv-dtl  for ub.ord-dtl-rcv .

define buffer locb-z-doc    for ub.ord-doc .
define buffer locb-z-line   for ub.ord-line .
define buffer locb-z-dtl    for ub.ord-dtl .

define buffer locb-t-doc    for ub.trn-doc .
define buffer locb-t-line   for ub.doc-line .
define buffer locb-t-dtl    for ub.gds-dtl  .


find current tt-goods no-error .
if avail tt-goods then gg-recid =  recid(tt-goods) .
 /* ---line--- */
      for each tt-goods where tt-goods.gds-t = {&h-goods} :
          tt-goods.sum-ord  = 0.
          for each  locb-ord-doc where locb-ord-doc.cons-code = loc-ord-cons-code   and
                                      locb-ord-doc.doc-type  = {&f-p}
                                      no-lock  ,
              each locb-ord-line where locb-ord-doc.doc-code = locb-ord-line.doc-code  and
                                          tt-goods.artic     = locb-ord-line.artic     and
                                          tt-goods.prod-code = locb-ord-line.prod-code and
                                          tt-goods.prod-type = locb-ord-line.prod-type
                                          no-lock  :
            assign
              tt-goods.sum-ord  = tt-goods.sum-ord + locb-ord-line.qnty
            .
          end.

          tt-goods.sum-rcv  = 0 .
          for each  locb-rcv-doc where locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                      locb-rcv-doc.doc-type  = {&l-out}
                                      no-lock  ,
              each locb-rcv-line where locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                        locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                        tt-goods.artic        = locb-rcv-line.artic     and
                                        tt-goods.prod-code    = locb-rcv-line.prod-code and
                                        tt-goods.prod-type    = locb-rcv-line.prod-type
                                        no-lock  :
            assign
              tt-goods.sum-rcv  = tt-goods.sum-rcv + locb-rcv-line.qnty
            .
          end.

          tt-goods.sum-rcv-in  = 0 .
          for each  locb-z-doc no-lock where
                                      locb-z-doc.cons-code = loc-ord-cons-code   and
                                      locb-z-doc.doc-type  = {&o-f}
                                      ,
              each locb-z-line no-lock where
                                        locb-z-doc.doc-code = locb-z-line.doc-code    and
                                        tt-goods.artic        = locb-z-line.artic     and
                                        tt-goods.prod-code    = locb-z-line.prod-code and
                                        tt-goods.prod-type    = locb-z-line.prod-type
                                        ,
              each  locb-rcv-doc no-lock where
                                      locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                      locb-rcv-doc.doc-type  = "in":U              and
                                      locb-rcv-doc.obj-code  = locb-z-doc.obj-code and
                                      locb-rcv-doc.obj-type  = locb-z-doc.obj-type
                                      ,
              each locb-rcv-line no-lock  where
                                        locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                        locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                        tt-goods.artic        = locb-rcv-line.artic     and
                                        tt-goods.prod-code    = locb-rcv-line.prod-code and
                                        tt-goods.prod-type    = locb-rcv-line.prod-type
                                        :
            assign
              tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in + locb-rcv-line.qnty
            .

          end.


          /* расх */
          for each  locb-z-doc no-lock where
                                      locb-z-doc.cons-code = loc-ord-cons-code   and
                                      locb-z-doc.doc-type  = {&o-f}
                                      ,
              each locb-z-line no-lock where
                                        locb-z-doc.doc-code = locb-z-line.doc-code    and
                                        tt-goods.artic        = locb-z-line.artic     and
                                        tt-goods.prod-code    = locb-z-line.prod-code and
                                        tt-goods.prod-type    = locb-z-line.prod-type
                                        ,
              each  locb-rcv-doc no-lock where
                                      locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                      locb-rcv-doc.doc-type  = "in":U              and
                                      locb-rcv-doc.cli-code  = locb-z-doc.obj-code and
                                      locb-rcv-doc.cli-type  = locb-z-doc.obj-type
                                      ,
              each locb-rcv-line no-lock  where
                                        locb-rcv-doc.doc-code = locb-rcv-line.doc-code  and
                                        locb-rcv-doc.rcv-code = locb-rcv-line.rcv-code  and
                                        tt-goods.artic        = locb-rcv-line.artic     and
                                        tt-goods.prod-code    = locb-rcv-line.prod-code and
                                        tt-goods.prod-type    = locb-rcv-line.prod-type
                                        :
            assign
              tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in - locb-rcv-line.qnty
            .

          end.
          /* По прих накл */
          tt-goods.sum-fact    = 0 .
          for each  locb-rcv-doc no-lock where
                    locb-rcv-doc.cons-code = loc-ord-cons-code   and
                    locb-rcv-doc.doc-type  = {&l-out}
                    ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                  and
                   ub.ord-chain.rel-doc-type = 'trn'
                   ,
              each locb-t-doc no-lock  where
                   locb-t-doc.doc-code = ub.ord-chain.rel-doc-code
                   ,
              each locb-t-line no-lock where
                    locb-t-line.doc-code     = locb-t-doc.doc-code and
                    locb-t-line.artic        = tt-goods.artic     and
                    locb-t-line.prod-code    = tt-goods.prod-code and
                    locb-t-line.prod-type    = tt-goods.prod-type :
            assign
              tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-line.fact-qnty
            .
          end.

          for each  locb-rcv-doc no-lock where
                    locb-rcv-doc.cons-code = loc-ord-cons-code   and
                    locb-rcv-doc.doc-type  = "in":U   ,
              each ub.ord-chain no-lock where
                   ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                   ub.ord-chain.doc-type = 'rcv'                  and
                   ub.ord-chain.rel-doc-type = 'trn'
                   ,
              each locb-t-doc no-lock  where
                    locb-t-doc.doc-code = ub.ord-chain.rel-doc-code  and
                    locb-t-doc.doc-type = {&income}  ,
              each locb-t-line no-lock where
                    locb-t-doc.doc-code = locb-t-line.doc-code    and
                    locb-t-line.artic        = tt-goods.artic     and
                    locb-t-line.prod-code    = tt-goods.prod-code and
                    locb-t-line.prod-type    = tt-goods.prod-type :
            assign
              tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-line.fact-qnty
            .
          end.


       end.
   /* ------- */
          for each tt-goods where tt-goods.gds-t <> {&h-goods} :
              tt-goods.sum-ord  = 0.
              for each  locb-ord-doc where locb-ord-doc.cons-code = loc-ord-cons-code   and
                                          locb-ord-doc.doc-type  = {&f-p}
                                          no-lock  ,
                  each locb-ord-dtl where locb-ord-doc.doc-code = locb-ord-dtl.doc-code   and
                                              tt-goods.node-code = locb-ord-dtl.node-code and
                                              tt-goods.artic     = locb-ord-dtl.artic     and
                                              tt-goods.prod-code = locb-ord-dtl.prod-code and
                                              tt-goods.prod-type = locb-ord-dtl.prod-type
                                              no-lock  :
                assign
                  tt-goods.sum-ord  = tt-goods.sum-ord + locb-ord-dtl.qnty
                .
              end.

              tt-goods.sum-rcv  = 0 .
              for each  locb-rcv-doc where locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                          locb-rcv-doc.doc-type  = {&l-out}
                                          no-lock  ,
                  each locb-rcv-dtl where locb-rcv-doc.doc-code   = locb-rcv-dtl.doc-code  and
                                            locb-rcv-doc.rcv-code = locb-rcv-dtl.rcv-code  and
                                            tt-goods.node-code    = locb-rcv-dtl.node-code and
                                            tt-goods.artic        = locb-rcv-dtl.artic     and
                                            tt-goods.prod-code    = locb-rcv-dtl.prod-code and
                                            tt-goods.prod-type    = locb-rcv-dtl.prod-type
                                            no-lock  :
                assign
                  tt-goods.sum-rcv  = tt-goods.sum-rcv + locb-rcv-dtl.qnty
                .
              end.

              tt-goods.sum-rcv-in  = 0 .

              for each  locb-z-doc no-lock where
                                          locb-z-doc.cons-code = loc-ord-cons-code   and
                                          locb-z-doc.doc-type  = {&o-f}
                                          ,
                  each locb-z-dtl no-lock where
                                            locb-z-doc.doc-code   = locb-z-dtl.doc-code  and
                                            tt-goods.node-code    = locb-z-dtl.node-code and
                                            tt-goods.artic        = locb-z-dtl.artic     and
                                            tt-goods.prod-code    = locb-z-dtl.prod-code and
                                            tt-goods.prod-type    = locb-z-dtl.prod-type
                                            ,
                  each  locb-rcv-doc no-lock where
                                          locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                          locb-rcv-doc.doc-type  = "in":U              and
                                          locb-rcv-doc.obj-code  = locb-z-doc.obj-code and
                                          locb-rcv-doc.obj-type  = locb-z-doc.obj-type
                                          ,
                  each locb-rcv-dtl no-lock  where
                                            locb-rcv-dtl.doc-code  = locb-rcv-doc.doc-code and
                                            locb-rcv-dtl.rcv-code  = locb-rcv-doc.rcv-code and
                                            locb-rcv-dtl.node-code = tt-goods.node-code    and
                                            locb-rcv-dtl.artic     = tt-goods.artic        and
                                            locb-rcv-dtl.prod-code = tt-goods.prod-code    and
                                            locb-rcv-dtl.prod-type = tt-goods.prod-type
                                            :
                assign
                  tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in + locb-rcv-dtl.qnty
                .
              end.
              /* расх */
              for each  locb-z-doc no-lock where
                                          locb-z-doc.cons-code = loc-ord-cons-code   and
                                          locb-z-doc.doc-type  = {&o-f}
                                          ,
                  each locb-z-dtl no-lock where
                                            locb-z-doc.doc-code   = locb-z-dtl.doc-code  and
                                            tt-goods.node-code    = locb-z-dtl.node-code and
                                            tt-goods.artic        = locb-z-dtl.artic     and
                                            tt-goods.prod-code    = locb-z-dtl.prod-code and
                                            tt-goods.prod-type    = locb-z-dtl.prod-type
                                            ,
                  each  locb-rcv-doc no-lock where
                                          locb-rcv-doc.cons-code = loc-ord-cons-code   and
                                          locb-rcv-doc.doc-type  = "in":U              and
                                          locb-rcv-doc.cli-code  = locb-z-doc.obj-code and
                                          locb-rcv-doc.cli-type  = locb-z-doc.obj-type
                                          ,
                  each locb-rcv-dtl no-lock  where
                                            locb-rcv-dtl.doc-code  = locb-rcv-doc.doc-code and
                                            locb-rcv-dtl.rcv-code  = locb-rcv-doc.rcv-code and
                                            locb-rcv-dtl.node-code = tt-goods.node-code    and
                                            locb-rcv-dtl.artic     = tt-goods.artic        and
                                            locb-rcv-dtl.prod-code = tt-goods.prod-code    and
                                            locb-rcv-dtl.prod-type = tt-goods.prod-type
                                            :
                assign
                  tt-goods.sum-rcv-in  = tt-goods.sum-rcv-in - locb-rcv-dtl.qnty
                .
              end.

              /* По прих накл */
              tt-goods.sum-fact    = 0 .

              for each  locb-rcv-doc no-lock where
                        locb-rcv-doc.cons-code = loc-ord-cons-code   and
                        locb-rcv-doc.doc-type  = {&l-out},
                  each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                 and
                        ub.ord-chain.rel-doc-type = 'trn' ,
                  each locb-t-doc no-lock  where
                       locb-t-doc.doc-code = ub.ord-chain.rel-doc-code  ,
                  each locb-t-dtl no-lock where
                        locb-t-dtl.doc-code     = locb-t-doc.doc-code and
                        locb-t-dtl.prt-code     = tt-goods.node-code  and
                        locb-t-dtl.artic        = tt-goods.artic      and
                        locb-t-dtl.prod-code    = tt-goods.prod-code  and
                        locb-t-dtl.prod-type    = tt-goods.prod-type  :
                assign
                  tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-dtl.fact-qnty
                .
              end.
              for each  locb-rcv-doc no-lock where
                        locb-rcv-doc.cons-code = loc-ord-cons-code   and
                        locb-rcv-doc.doc-type  = "in":U   ,
                  each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = locb-rcv-doc.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                 and
                        ub.ord-chain.rel-doc-type = 'trn' ,
                  each locb-t-doc no-lock  where
                       locb-t-doc.doc-code = ub.ord-chain.rel-doc-code  and
                       locb-t-doc.doc-type = {&income} ,
                  each locb-t-dtl no-lock where
                        locb-t-dtl.doc-code     = locb-t-doc.doc-code and
                        locb-t-dtl.prt-code     = tt-goods.node-code  and
                        locb-t-dtl.artic        = tt-goods.artic      and
                        locb-t-dtl.prod-code    = tt-goods.prod-code  and
                        locb-t-dtl.prod-type    = tt-goods.prod-type  :
                assign
                  tt-goods.sum-fact  = tt-goods.sum-fact + locb-t-dtl.fact-qnty
                .
              end.

          end.
   /*--- ----*/
   if not t-prt then
     g#log = BROWSE-12:refresh() in frame frame-a no-error .
   else
     g#log = BROWSE-30:refresh() in frame frame-c no-error .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-ord-fp Dialog-Frame
PROCEDURE chg-ord-fp :
do
 on error undo, return error return-value
 :

find current ub.ord-doc no-lock no-error .
if avail ub.ord-doc and ub.ord-doc.status_ <> {&g___new} then do:
    message  "Нельзя корректировать в статусе" caps(ub.ord-doc.status_) view-as alert-box information .
    return.
    end.

if avail ub.ord-doc and ub.ord-doc.status_ = {&g___new} then do:
    g#type = {&f-p} .
    run zayvka in this-procedure  ("chg":U).
    end.

if not  avail ub.ord-doc then do :
    message "Заказ не выбран !!! " .
    return.
    End.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-ord-line Dialog-Frame
PROCEDURE chg-ord-line :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

 define variable  r-tmp as recid   no-undo .
 define variable r-stop as logical no-undo .
 define variable r-exit as logical no-undo .
 find current tt-new-ord-line no-lock no-error .


 find first ub.ord-doc no-lock where ub.ord-doc.doc-code = tt-new-ord-line.doc-code no-error .
 if avail ub.ord-doc  and ub.ord-doc.status_ <> {&g___new} and line-mode <> {&lookup} then do:
      message "Заказ " ub.ord-doc.doc-code " уже закрыт до статуса " ub.ord-doc.status_ " Изменения невозможны ! " view-as alert-box .
      return.
 end.
 for each TMP#zakaz :
    delete TMP#zakaz .
 end.


   if avail tt-new-ord-line then do:
     find first  tmp#zakaz where
            TMP#zakaz.artic                 = tt-new-ord-line.artic and
            TMP#zakaz.prod-code             = tt-new-ord-line.prod-code and
            TMP#zakaz.prod-type             = tt-new-ord-line.prod-type no-error .
      if not available Tmp#zakaz then do:
          create TMP#zakaz.
          end.
      assign
            TMP#zakaz.SLT-pc                = tt-new-ord-line.SLT-pc
            TMP#zakaz.VAT-pc                = tt-new-ord-line.VAT-pc
            TMP#zakaz.add-cli-qnty          = tt-new-ord-line.add-cli-qnty
            TMP#zakaz.add-qnty              = tt-new-ord-line.add-qnty
            TMP#zakaz.artic                 = tt-new-ord-line.artic
            TMP#zakaz.prod-code             = tt-new-ord-line.prod-code
            TMP#zakaz.prod-type             = tt-new-ord-line.prod-type
            TMP#zakaz.cancel-cli-qnty       = tt-new-ord-line.cancel-cli-qnty
            TMP#zakaz.cancel-date           = tt-new-ord-line.cancel-date
            TMP#zakaz.cancel-qnty           = tt-new-ord-line.cancel-qnty
            TMP#zakaz.cli-art               = tt-new-ord-line.cli-art
            TMP#zakaz.cli-base-rate         = tt-new-ord-line.cli-base-rate
            TMP#zakaz.cli-qnty              = tt-new-ord-line.cli-qnty
            TMP#zakaz.doc-code              = tt-new-ord-line.doc-code
            TMP#zakaz.excise                = tt-new-ord-line.excise
            TMP#zakaz.fact-date             = tt-new-ord-line.fact-date
            TMP#zakaz.initial-cli-qnty      = tt-new-ord-line.initial-cli-qnty
            TMP#zakaz.initial-qnty          = tt-new-ord-line.initial-qnty
            TMP#zakaz.line-num              = tt-new-ord-line.line-num
            TMP#zakaz.order-cli-qnty        = tt-new-ord-line.order-cli-qnty
            TMP#zakaz.order-qnty            = tt-new-ord-line.order-qnty
            TMP#zakaz.other-base            = tt-new-ord-line.other-base
            TMP#zakaz.other-rubl            = tt-new-ord-line.other-rubl
            TMP#zakaz.price-base            = tt-new-ord-line.price-base
            TMP#zakaz.price-cli             = tt-new-ord-line.price-cli
            TMP#zakaz.price-rubl            = tt-new-ord-line.price-rubl
            TMP#zakaz.qnty                  = tt-new-ord-line.qnty
            TMP#zakaz.receive-cli-qnty      = tt-new-ord-line.receive-cli-qnty
            TMP#zakaz.receive-qnty          = tt-new-ord-line.receive-qnty
            TMP#zakaz.road-tax              = tt-new-ord-line.road-tax
            TMP#zakaz.sum-SLT               = tt-new-ord-line.sum-SLT
            TMP#zakaz.sum-VAT               = tt-new-ord-line.sum-VAT
            TMP#zakaz.sum-base              = tt-new-ord-line.sum-base
            TMP#zakaz.sum-cli               = tt-new-ord-line.sum-cli
            TMP#zakaz.sum-excise            = tt-new-ord-line.sum-excise
            TMP#zakaz.sum-other-base        = tt-new-ord-line.sum-other-base
            TMP#zakaz.sum-other-rubl        = tt-new-ord-line.sum-other-rubl
            TMP#zakaz.sum-road-tax          = tt-new-ord-line.sum-road-tax
            TMP#zakaz.sum-rubl              = tt-new-ord-line.sum-rubl
            TMP#zakaz.sum-transport-base    = tt-new-ord-line.sum-transport-base
            TMP#zakaz.sum-transport-rubl    = tt-new-ord-line.sum-transport-rubl
            TMP#zakaz.transport-base        = tt-new-ord-line.transport-base
            TMP#zakaz.transport-rubl        = tt-new-ord-line.transport-rubl
            TMP#zakaz.unit-cli              = tt-new-ord-line.unit-cli
            TMP#zakaz.v-vat                 = tt-new-ord-line.v-vat
        .

    find first TMP#zakaz no-error .
    IF not avail TMP#zakaz then return no-apply.

    assign
      r-tmp = recid ( TMP#zakaz   )
      loc-status     = ub.ord-doc.status_
      doc-date       = ub.ord-doc.doc-date
      loc-date-ship  = ub.ord-doc.ship-date
      date-sale-1    = ub.ord-doc.date-sale-1
      date-sale-2    = ub.ord-doc.date-sale-2
      loc-exch-code  = ub.ord-doc.exch-code
      loc-exch-rate  = ub.ord-doc.exch-rate
      loc-exch-scale = ub.ord-doc.exch-scale
      loc-base-rate  = ub.ord-doc.base-rate
      loc-base-scale = ub.ord-doc.base-scale
      vat_type       = ub.ord-doc.vat-type
      slt_type       = ub.ord-doc.slt-type
      loc-cli-code =   ub.ord-doc.cli-code
      loc-cli-type =   ub.ord-doc.cli-type
      loc-ord-num  =   ub.ord-doc.doc-code
      no-error.
      if error-status :error
      then do:
           message  error-status :get-message(1) skip
           "при присвоении" skip
           .
           end.
    find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-doc.doc-code no-error .

    if loc-make-avto = false then do:
       run cus/ord-frm.w (input Parparentproc,  input r-tmp ,input line-mode , output r-stop, output r-exit ) .
    end.
    if line-mode <> {&lookup}  then do:
       if  r-stop = false and r-exit = false  then do:
       run dop-pr in this-procedure .
        /*изменить заказ по строке */
        run calc-cons-ord in this-procedure .
       end.
    end.
    find current TMP#zakaz no-error  .
    if avail TMP#zakaz then delete TMP#zakaz.
end.
else do:
  message  "Не выбрана строка заказа !" view-as alert-box .
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chg-trn Dialog-Frame
PROCEDURE chg-trn :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if available ub.trn-doc then do:
   run str/showdoc.p
      (input parparentproc
      ,input ub.trn-doc.doc-code
      ,input ""
      ,input ""
      ,input 0
      ,input true
      ) .
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE color-cell Dialog-Frame
PROCEDURE color-cell :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  define input parameter h-cell   as handle    no-undo .
  define input parameter p-color  as integer   no-undo .
  define input parameter h-status as character no-undo .
  define input parameter p-status as character no-undo .

  if  h-cell <> ?   and valid-handle(h-cell)
       then do:

      if h-status = p-status then do:
         h-cell:fgcolor = p-color .
      end.

  end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-dtl-fp Dialog-Frame
PROCEDURE create-dtl-fp :
do
 on error undo, return error return-value
 :

define input parameter p_new-doc-code like ub.ord-doc.doc-code no-undo .
define input parameter p_file         as character no-undo .
define input parameter p_old-doc-code like ub.ord-doc.doc-code no-undo .
define input parameter p_artic     like   ub.ord-line.artic       no-undo .
define input parameter p_prod-type like   ub.ord-line.prod-type  no-undo .
define input parameter p_prod-code like   ub.ord-line.prod-code  no-undo .
define input parameter p-cli-base-rate like   ub.ord-line.cli-base-rate  no-undo .

define buffer new_ord-dtl    for ub.ord-dtl .
define buffer j_ord-dtl      for ub.ord-dtl .
define buffer j_ord-dtl-cons for ub.ord-dtl-cons .
define buffer loc-tt-goods   for tt-goods .

define variable loc-fact-qnty like ub.ord-line.qnty no-undo .


case  p_file  :
when "ord-of"  then do: /* признаки для заказа */
    for each  j_ord-dtl no-lock where
              j_ord-dtl.doc-code   = p_old-doc-code and
              j_ord-dtl.artic      = p_artic        and
              j_ord-dtl.prod-type  = p_prod-type    and
              j_ord-dtl.prod-code  = p_prod-code
              :
       find first loc-tt-goods no-lock   where
                  loc-tt-goods.gds-t <> {&h-goods} and
                  loc-tt-goods.artic      = j_ord-dtl.artic      and
                  loc-tt-goods.node-code  = j_ord-dtl.node-code  and
                  loc-tt-goods.prod-code  = j_ord-dtl.prod-code  and
                  loc-tt-goods.prod-type  = j_ord-dtl.prod-type  no-error .
       if not available loc-tt-goods then  do:  next. end.
          loc-fact-qnty = loc-tt-goods.sum-qnty - (loc-tt-goods.sum-ord + loc-tt-goods.sum-rcv-in) .

       find first new_ord-dtl where
         new_ord-dtl.doc-code             = p_new-doc-code       and
         new_ord-dtl.artic                = j_ord-dtl.artic      and
         new_ord-dtl.node-code            = j_ord-dtl.node-code  and
         new_ord-dtl.prod-code            = j_ord-dtl.prod-code  and
         new_ord-dtl.prod-type            = j_ord-dtl.prod-type   exclusive-lock  no-error .
       if not available new_ord-dtl then  do:  create new_ord-dtl. end.

       assign
         new_ord-dtl.doc-code             = p_new-doc-code
         new_ord-dtl.add-cli-qnty         = j_ord-dtl.add-cli-qnty
         new_ord-dtl.add-qnty             = j_ord-dtl.add-qnty
         new_ord-dtl.artic                = j_ord-dtl.artic
         new_ord-dtl.prod-code            = j_ord-dtl.prod-code
         new_ord-dtl.prod-type            = j_ord-dtl.prod-type
         new_ord-dtl.node-code            = j_ord-dtl.node-code
         new_ord-dtl.cancel-cli-qnty      = j_ord-dtl.cancel-cli-qnty
         new_ord-dtl.cancel-qnty          = j_ord-dtl.cancel-qnty
         new_ord-dtl.initial-cli-qnty     = j_ord-dtl.initial-cli-qnty
         new_ord-dtl.initial-qnty         = j_ord-dtl.initial-qnty
         new_ord-dtl.order-cli-qnty       = j_ord-dtl.order-cli-qnty
         new_ord-dtl.order-qnty           = j_ord-dtl.order-qnty
         new_ord-dtl.price-base           = j_ord-dtl.price-base
         new_ord-dtl.price-cli            = j_ord-dtl.price-cli
         new_ord-dtl.price-rubl           = j_ord-dtl.price-rubl
         new_ord-dtl.receive-cli-qnty     = j_ord-dtl.receive-cli-qnty
         new_ord-dtl.receive-qnty         = j_ord-dtl.receive-qnty

         new_ord-dtl.qnty                 = minimum( j_ord-dtl.qnty , loc-fact-qnty )
         new_ord-dtl.cli-qnty             = new_ord-dtl.qnty / p-cli-base-rate
         new_ord-dtl.sum-base             = new_ord-dtl.qnty * new_ord-dtl.price-base
         new_ord-dtl.sum-cli              = new_ord-dtl.cli-qnty * new_ord-dtl.price-cli
         new_ord-dtl.sum-rubl             = new_ord-dtl.qnty * new_ord-dtl.price-rubl
       .
    end.
end.
when "ord-cons"  then do: /* признаки для заказа */
    for each  j_ord-dtl-cons no-lock  where
              j_ord-dtl-cons.cons-code   = p_old-doc-code and
              j_ord-dtl-cons.artic      = p_artic        and
              j_ord-dtl-cons.prod-type  = p_prod-type    and
              j_ord-dtl-cons.prod-code  = p_prod-code
              :
       find first loc-tt-goods no-lock   where
                  loc-tt-goods.gds-t <> {&h-goods} and
                  loc-tt-goods.artic      = j_ord-dtl.artic      and
                  loc-tt-goods.node-code  = j_ord-dtl.node-code  and
                  loc-tt-goods.prod-code  = j_ord-dtl.prod-code  and
                  loc-tt-goods.prod-type  = j_ord-dtl.prod-type  no-error .
       if not available loc-tt-goods then  do:  next. end.
          loc-fact-qnty = loc-tt-goods.sum-qnty - (loc-tt-goods.sum-ord + loc-tt-goods.sum-rcv-in) .

         find first  new_ord-dtl  exclusive-lock  where
         new_ord-dtl.doc-code             = p_new-doc-code            and
         new_ord-dtl.artic                = j_ord-dtl-cons.artic      and
         new_ord-dtl.node-code            = j_ord-dtl-cons.node-code  and
         new_ord-dtl.prod-code            = j_ord-dtl-cons.prod-code  and
         new_ord-dtl.prod-type            = j_ord-dtl-cons.prod-type no-error .
         if not available new_ord-dtl then do:  create new_ord-dtl. end.

       assign
         new_ord-dtl.doc-code             = p_new-doc-code
         new_ord-dtl.artic                = j_ord-dtl-cons.artic
         new_ord-dtl.node-code            = j_ord-dtl-cons.node-code
         new_ord-dtl.prod-code            = j_ord-dtl-cons.prod-code
         new_ord-dtl.prod-type            = j_ord-dtl-cons.prod-type
         new_ord-dtl.qnty                 = loc-fact-qnty
         new_ord-dtl.cli-qnty             = new_ord-dtl.qnty / p-cli-base-rate

         /* цена ? */
       .
    end.
end.

end case.

end.
END PROCEDURE.

PROCEDURE create-dtl-rcv :
 do
 on error undo, return error return-value
 :

define input parameter p_new-rcv-code like ub.ord-doc-rcv.rcv-code no-undo .
define input parameter p_new-doc-code like ub.ord-doc-rcv.doc-code no-undo .
define input parameter p_file         as character no-undo .
define input parameter p_old-doc-code like  ub.ord-doc-rcv.doc-code    no-undo .
define input parameter p_old-rcv-code like  ub.ord-doc-rcv.rcv-code    no-undo .
define input parameter p_artic        like  ub.ord-line-rcv.artic      no-undo .
define input parameter p_prod-type    like  ub.ord-line-rcv.prod-type  no-undo .
define input parameter p_prod-code    like  ub.ord-line-rcv.prod-code  no-undo .
define buffer new_ord-dtl-rcv   for ub.ord-dtl-rcv  .
define buffer old_ord-dtl-cons  for ub.ord-dtl-cons .
define buffer old_ord-gds-cons  for ub.ord-gds-cons .
define buffer j_ord-dtl         for ub.ord-dtl      .
define buffer j_ord-line        for ub.ord-line     .
define buffer of_ord-dtl        for ub.ord-dtl      .
define buffer of_ord-line       for ub.ord-line     .

define buffer loc-tt-goods   for tt-goods .

define variable loc-fact-qnty    like ub.ord-line.qnty no-undo .
define variable loc-fact-qnty-in like ub.ord-line.qnty no-undo .

case  p_file  :
when "ord-fp"  then do: /* признаки из заказа */
    for each  j_ord-dtl no-lock  where
              j_ord-dtl.doc-code   = p_new-doc-code and
              j_ord-dtl.artic      = p_artic        and
              j_ord-dtl.prod-type  = p_prod-type    and
              j_ord-dtl.prod-code  = p_prod-code
              ,
            first j_ord-line no-lock  where
                j_ord-line.doc-code   = p_new-doc-code and
                j_ord-line.artic      = p_artic        and
                j_ord-line.prod-type  = p_prod-type    and
                j_ord-line.prod-code  = p_prod-code
                :

       find first loc-tt-goods no-lock   where
                  loc-tt-goods.gds-t <> {&h-goods} and
                  loc-tt-goods.artic      = j_ord-dtl.artic      and
                  loc-tt-goods.node-code  = j_ord-dtl.node-code  and
                  loc-tt-goods.prod-code  = j_ord-dtl.prod-code  and
                  loc-tt-goods.prod-type  = j_ord-dtl.prod-type  no-error .
       if not available loc-tt-goods then  do:  next. end.
          loc-fact-qnty = loc-tt-goods.sum-rcv .

       find first  of_ord-dtl  no-lock    where
              of_ord-dtl.doc-code   = p_old-doc-code and
              of_ord-dtl.artic      = p_artic        and
              of_ord-dtl.prod-type  = p_prod-type    and
              of_ord-dtl.prod-code  = p_prod-code   no-error .
              if error-status :error then next. /* найдем заявку */
       find first new_ord-dtl-rcv  exclusive-lock  where
         new_ord-dtl-rcv.rcv-code   = p_new-rcv-code       and
         new_ord-dtl-rcv.doc-code   = j_ord-dtl.doc-code   and
         new_ord-dtl-rcv.artic      = j_ord-dtl.artic      and
         new_ord-dtl-rcv.prod-code  = j_ord-dtl.prod-code  and
         new_ord-dtl-rcv.prod-type  = j_ord-dtl.prod-type  and
         new_ord-dtl-rcv.node-code  = j_ord-dtl.node-code  no-error .

       if not  available new_ord-dtl-rcv then do:
          create new_ord-dtl-rcv.
          end.
       assign
         new_ord-dtl-rcv.rcv-code   = p_new-rcv-code
         new_ord-dtl-rcv.doc-code   = j_ord-dtl.doc-code
         new_ord-dtl-rcv.artic      = j_ord-dtl.artic
         new_ord-dtl-rcv.prod-code  = j_ord-dtl.prod-code
         new_ord-dtl-rcv.prod-type  = j_ord-dtl.prod-type
         new_ord-dtl-rcv.node-code  = j_ord-dtl.node-code
         new_ord-dtl-rcv.price-base = j_ord-dtl.price-base
         new_ord-dtl-rcv.price-cli  = j_ord-dtl.price-cli
         new_ord-dtl-rcv.price-rubl = j_ord-dtl.price-rubl
         new_ord-dtl-rcv.qnty       = MINIMUM(j_ord-dtl.qnty , of_ord-dtl.qnty) - loc-fact-qnty
         new_ord-dtl-rcv.cli-qnty   = new_ord-dtl-rcv.qnty  / j_ord-line.cli-base-rate
         new_ord-dtl-rcv.sum-base   = new_ord-dtl-rcv.price-base * new_ord-dtl-rcv.qnty
         new_ord-dtl-rcv.sum-rubl   = new_ord-dtl-rcv.price-rubl * new_ord-dtl-rcv.qnty
         new_ord-dtl-rcv.sum-cli    = new_ord-dtl-rcv.price-cli  * new_ord-dtl-rcv.cli-qnty
       .
    end.
end.
when "rcv-in"  then do: /* признаки из СЗФП  */
    loc-fact-qnty-in = 0 .
    for each  old_ord-dtl-cons  no-lock where
              old_ord-dtl-cons.cons-code   = loc-ord-cons-code and
              old_ord-dtl-cons.artic       = p_artic        and
              old_ord-dtl-cons.prod-type   = p_prod-type    and
              old_ord-dtl-cons.prod-code   = p_prod-code
              ,
        first old_ord-gds-cons no-lock where
              old_ord-gds-cons.cons-code   = loc-ord-cons-code and
              old_ord-gds-cons.artic       = p_artic        and
              old_ord-gds-cons.prod-type   = p_prod-type    and
              old_ord-gds-cons.prod-code   = p_prod-code
              :

                                  /* признаки в заявке */
       find first  of_ord-dtl no-lock     where
              of_ord-dtl.doc-code   = p_old-doc-code and
              of_ord-dtl.node-code  = old_ord-dtl-cons.node-code    and
              of_ord-dtl.artic      = p_artic        and
              of_ord-dtl.prod-type  = p_prod-type    and
              of_ord-dtl.prod-code  = p_prod-code   no-error .
              if not available of_ord-dtl then do: next. end.
                 /* строка заявки */
       find first  of_ord-line  no-lock    where
              of_ord-line.doc-code   = p_old-doc-code and
              of_ord-line.artic      = p_artic        and
              of_ord-line.prod-type  = p_prod-type    and
              of_ord-line.prod-code  = p_prod-code   no-error .
              if not available of_ord-line then do: next. end.
              loc-fact-qnty = of_ord-line.qnty.

       find first new_ord-dtl-rcv  exclusive-lock  where
         new_ord-dtl-rcv.rcv-code             = p_new-rcv-code           and
         new_ord-dtl-rcv.doc-code             = ""                       and
         new_ord-dtl-rcv.node-code            = of_ord-dtl.node-code     and
         new_ord-dtl-rcv.artic                = of_ord-dtl.artic         and
         new_ord-dtl-rcv.prod-code            = of_ord-dtl.prod-code     and
         new_ord-dtl-rcv.prod-type            = of_ord-dtl.prod-type     no-error .

       if not available new_ord-dtl-rcv then do:
          create new_ord-dtl-rcv.
       end.

       assign
         new_ord-dtl-rcv.rcv-code             = p_new-rcv-code
         new_ord-dtl-rcv.doc-code             = ""
         new_ord-dtl-rcv.node-code            = of_ord-dtl.node-code
         new_ord-dtl-rcv.artic                = of_ord-dtl.artic
         new_ord-dtl-rcv.prod-code            = of_ord-dtl.prod-code
         new_ord-dtl-rcv.prod-type            = of_ord-dtl.prod-type
         new_ord-dtl-rcv.qnty                 = MINIMUM(old_ord-gds-cons.sum-qnty , of_ord-dtl.qnty)
         new_ord-dtl-rcv.cli-qnty             = new_ord-dtl-rcv.qnty  / of_ord-line.cli-base-rate
       .
       loc-fact-qnty-in  = loc-fact-qnty-in + new_ord-dtl-rcv.qnty .
       if loc-fact-qnty < loc-fact-qnty-in then do:
            assign
              new_ord-dtl-rcv.qnty                 = 0
              new_ord-dtl-rcv.cli-qnty             = 0
            .
       end.
    end.
end.

end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-line-fp Dialog-Frame
PROCEDURE create-line-fp :
do
 on error undo, return error return-value
 :

/* Создание строки заказа ФП */
define input parameter n-code as character no-undo .
define output parameter r-tmp as recid no-undo .
define buffer b-ord-cons-gds for tt-goods.
define buffer bq_ord-doc  for ub.ord-doc  .
define buffer bq_ord-line for ub.ord-line .
if not avail tt-goods then do:
   message
   "Не найден товар " skip
   "Ошибка "  error-status :get-message(1) .
   return error.
   end.

find first  b-ord-cons-gds no-lock  where b-ord-cons-gds.artic      = tt-goods.artic and
                                 b-ord-cons-gds.prod-code  = tt-goods.prod-code and
                                 b-ord-cons-gds.prod-type  = tt-goods.prod-type
                                no-error .
if not can-find  (first ub.ord-line where ub.ord-line.doc-code   = n-code and
                                     ub.ord-line.artic      = tt-goods.artic and
                                     ub.ord-line.prod-code  = tt-goods.prod-code and
                                     ub.ord-line.prod-type  = tt-goods.prod-type no-lock ) then do:

define variable local-fact-ord like ub.ord-line.qnty no-undo .
define variable local-rcv-in   like ub.ord-line.qnty no-undo .
define variable sum-fact-ord like ub.ord-line.qnty no-undo .
    sum-fact-ord = 0.
    /* проверка заказанного количества */
    assign
        /* уже заказано по ФП */
          local-fact-ord = tt-goods.sum-ord
        /*  + уже перемещено внутренними поставками */
          local-rcv-in  = tt-goods.sum-rcv-in
    .

    sum-fact-ord = b-ord-cons-gds.sum-qnty - ( local-fact-ord + local-rcv-in ).
    if sum-fact-ord <= 0 then dO:
       message "По товару    :" tt-goods.gds-name skip
               "артикул      :" tt-goods.artic    skip
               "Уже заказано :" local-fact-ord    skip
               "Уже перемещено :" local-rcv-in    skip
               "Запрошено    :" b-ord-cons-gds.sum-qnty    skip
               "Заказывать еще ?"
               view-as alert-box question buttons OK-Cancel update g#log.
               if g#log = false then return.

    end.
    create  ub.ord-line.
      assign
        ub.ord-line.gds-code       = tt-goods.gds-code
        ub.ord-line.artic          = b-ord-cons-gds.artic
        ub.ord-line.cli-base-rate  = b-ord-cons-gds.cli-base-rate
        ub.ord-line.prod-code      = b-ord-cons-gds.prod-code
        ub.ord-line.prod-type      = b-ord-cons-gds.prod-type
        ub.ord-line.doc-code  = n-code
        ub.ord-line.line-num  = 1
        ub.ord-line.qnty      = (if sum-fact-ord < 0 then 0 else sum-fact-ord )
        ub.ord-line.unit-cli      = tt-goods.unit-cli
        ub.ord-line.cli-base-rate = tt-goods.cli-base-rate
        ub.ord-line.cli-qnty      = ub.ord-line.qnty / ub.ord-line.cli-base-rate
    .

 run last-price  in this-procedure
 (    input  g#host-code        ,
      input  ub.ord-line.artic     ,
      input  ub.ord-line.prod-type ,
      input  ub.ord-line.prod-code ,
      input  ub.ord-doc.cli-code   ,
      input  ub.ord-doc.cli-type   ,
      input  ub.ord-line.cli-base-rate  ,
      input  ub.ord-doc.exch-code  ,
      output ub.ord-line.price-base,
      output ub.ord-line.price-rubl,
      output ub.ord-line.price-cli )
      no-error  .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
    assign
      ub.ord-line.sum-base = ub.ord-line.price-base * ub.ord-line.qnty
      ub.ord-line.sum-rubl = ub.ord-line.price-rubl * ub.ord-line.qnty
      ub.ord-line.sum-cli  = ub.ord-line.price-cli  * ub.ord-line.cli-qnty
    .

/* Налоги текущие на сейчас */
{ gbl/pftxvalg.i tt-goods.gds-code {&vat-tax-code} ? g#host-code store-type store-code ub.ord-line.vat-pc no-error }
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.

end.
line-rec = recid(ord-line) .
find first  tmp#zakaz where
            TMP#zakaz.artic                 = ub.ord-line.artic and
            TMP#zakaz.prod-code             = ub.ord-line.prod-code and
            TMP#zakaz.prod-type             = ub.ord-line.prod-type no-error .
      if not available Tmp#zakaz then do:
          create TMP#zakaz.
          end.
      assign
            TMP#zakaz.SLT-pc                = ub.ord-line.SLT-pc
            TMP#zakaz.VAT-pc                = ub.ord-line.VAT-pc
            TMP#zakaz.add-cli-qnty          = ub.ord-line.add-cli-qnty
            TMP#zakaz.add-qnty              = ub.ord-line.add-qnty
            TMP#zakaz.artic                 = ub.ord-line.artic
            TMP#zakaz.prod-code             = ub.ord-line.prod-code
            TMP#zakaz.prod-type             = ub.ord-line.prod-type
            TMP#zakaz.cancel-cli-qnty       = ub.ord-line.cancel-cli-qnty
            TMP#zakaz.cancel-date           = ub.ord-line.cancel-date
            TMP#zakaz.cancel-qnty           = ub.ord-line.cancel-qnty
            TMP#zakaz.cli-art               = ub.ord-line.cli-art
            TMP#zakaz.cli-base-rate         = ub.ord-line.cli-base-rate
            TMP#zakaz.cli-qnty              = ub.ord-line.cli-qnty
            TMP#zakaz.doc-code              = ub.ord-line.doc-code
            TMP#zakaz.excise                = ub.ord-line.excise
            TMP#zakaz.fact-date             = ub.ord-line.fact-date
            TMP#zakaz.initial-cli-qnty      = ub.ord-line.initial-cli-qnty
            TMP#zakaz.initial-qnty          = ub.ord-line.initial-qnty
            TMP#zakaz.line-num              = ub.ord-line.line-num
            TMP#zakaz.order-cli-qnty        = ub.ord-line.order-cli-qnty
            TMP#zakaz.order-qnty            = ub.ord-line.order-qnty
            TMP#zakaz.other-base            = ub.ord-line.other-base
            TMP#zakaz.other-rubl            = ub.ord-line.other-rubl
            TMP#zakaz.price-base            = ub.ord-line.price-base
            TMP#zakaz.price-cli             = ub.ord-line.price-cli
            TMP#zakaz.price-rubl            = ub.ord-line.price-rubl
            TMP#zakaz.qnty                  = ub.ord-line.qnty
            TMP#zakaz.receive-cli-qnty      = ub.ord-line.receive-cli-qnty
            TMP#zakaz.receive-qnty          = ub.ord-line.receive-qnty
            TMP#zakaz.road-tax              = ub.ord-line.road-tax
            TMP#zakaz.sum-SLT               = ub.ord-line.sum-SLT
            TMP#zakaz.sum-VAT               = ub.ord-line.sum-VAT
            TMP#zakaz.sum-base              = ub.ord-line.sum-base
            TMP#zakaz.sum-cli               = ub.ord-line.sum-cli
            TMP#zakaz.sum-excise            = ub.ord-line.sum-excise
            TMP#zakaz.sum-other-base        = ub.ord-line.sum-other-base
            TMP#zakaz.sum-other-rubl        = ub.ord-line.sum-other-rubl
            TMP#zakaz.sum-road-tax          = ub.ord-line.sum-road-tax
            TMP#zakaz.sum-rubl              = ub.ord-line.sum-rubl
            TMP#zakaz.sum-transport-base    = ub.ord-line.sum-transport-base
            TMP#zakaz.sum-transport-rubl    = ub.ord-line.sum-transport-rubl
            TMP#zakaz.transport-base        = ub.ord-line.transport-base
            TMP#zakaz.transport-rubl        = ub.ord-line.transport-rubl
            TMP#zakaz.unit-cli              = ub.ord-line.unit-cli
            TMP#zakaz.v-vat                 = ub.ord-line.v-vat
        .

    find first TMP#zakaz no-error .
    IF not avail TMP#zakaz then return no-apply.
    assign
      r-tmp = recid ( TMP#zakaz   )  .

run ord-detale in this-procedure no-error .
   if error-status :error then return error .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-line-rcv Dialog-Frame
PROCEDURE create-line-rcv :
do
 on error undo, return error return-value
 :

/* Создание строки внешней поставки */
define input parameter n-code as character no-undo .
define input parameter z-recid as recid no-undo .
define input parameter fp-recid as recid no-undo .
define input parameter p-ks as int  no-undo .
define output parameter l-rec as recid no-undo .

define buffer buf-fp_ord-line for ub.ord-line .
define buffer b-of_ord-line   for ub.ord-line .
define buffer b-of_ord-doc    for ub.ord-doc  .
define buffer b-rcv_ord-doc-rcv   for ub.ord-doc-rcv  .
define buffer buf-tt-goods     for tt-goods.
define buffer p_ord-line-rcv-i for ub.ord-line-rcv .
define buffer p_ord-doc-rcv-i  for ub.ord-doc-rcv  .

define variable  loc-var-qnty  like ub.ord-line-rcv.qnty no-undo.
define variable  loc-all-rcv   as decimal no-undo .

define variable  loc-new as recid no-undo .
define variable v-doc-mode as character no-undo .

/* нужная строка в заказе */
find first  buf-fp_ord-line    no-lock where recid(buf-fp_ord-line) = z-recid    no-error .

find first  b-rcv_ord-doc-rcv  no-lock where b-rcv_ord-doc-rcv.rcv-code = n-code no-error .

if avail buf-fp_ord-line then do:
  if not can-find  (first ub.ord-line-rcv where
                ub.ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                ub.ord-line-rcv.rcv-code  = n-code and
                ub.ord-line-rcv.artic     = buf-fp_ord-line.artic and
                ub.ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                ub.ord-line-rcv.prod-type = buf-fp_ord-line.prod-type no-lock ) then do:
    run proc-create-rcv-line in this-procedure
    (  input buf-fp_ord-line.SLT-pc
      ,input buf-fp_ord-line.VAT-pc
      ,input buf-fp_ord-line.artic
      ,input buf-fp_ord-line.cli-base-rate
      ,input buf-fp_ord-line.cli-qnty
      ,input buf-fp_ord-line.doc-code
      ,input buf-fp_ord-line.excise
      ,input buf-fp_ord-line.gds-code
      ,input p-ks
      ,input buf-fp_ord-line.other-base
      ,input buf-fp_ord-line.other-rubl
      ,input buf-fp_ord-line.price-base
      ,input buf-fp_ord-line.price-cli
      ,input buf-fp_ord-line.price-rubl
      ,input buf-fp_ord-line.prod-code
      ,input buf-fp_ord-line.prod-type
      ,input buf-fp_ord-line.qnty
      ,input n-code
      ,input buf-fp_ord-line.road-tax
      ,input buf-fp_ord-line.sum-SLT
      ,input buf-fp_ord-line.sum-VAT
      ,input buf-fp_ord-line.sum-base
      ,input buf-fp_ord-line.sum-cli
      ,input buf-fp_ord-line.sum-excise
      ,input buf-fp_ord-line.sum-other-base
      ,input buf-fp_ord-line.sum-other-rubl
      ,input buf-fp_ord-line.sum-road-tax
      ,input buf-fp_ord-line.sum-rubl
      ,input buf-fp_ord-line.sum-transport-base
      ,input buf-fp_ord-line.sum-transport-rubl
      ,input buf-fp_ord-line.transport-base
      ,input buf-fp_ord-line.transport-rubl
      ,input buf-fp_ord-line.unit-cli
      ,input buf-fp_ord-line.v-vat
      ).

    if fp-recid <> ? then do:
          /* нужная строка в заказе */
          for each  b-of_ord-doc no-lock  where  recid(b-of_ord-doc) = fp-recid  ,
              first  b-of_ord-line no-lock where
                    b-of_ord-line.doc-code  = b-of_ord-doc.doc-code and
                    b-of_ord-line.artic     = buf-fp_ord-line.artic and
                    b-of_ord-line.prod-code = buf-fp_ord-line.prod-code and
                    b-of_ord-line.prod-type = buf-fp_ord-line.prod-type
                    :

              assign
                loc-var-qnty           = b-of_ord-line.qnty
              .
              leave.
          end.

       find first buf-tt-goods  where
               buf-tt-goods.gds-t     = {&h-goods}           and
               buf-tt-goods.artic     = buf-fp_ord-line.artic and
               buf-tt-goods.prod-code = buf-fp_ord-line.prod-code and
               buf-tt-goods.prod-type = buf-fp_ord-line.prod-type no-lock no-error .


       define variable l-all-rcv-fp as decimal no-undo .

       /* уже поставлено по этому заказу по всем типам и объектам  */
       l-all-rcv-fp = 0 .
       for each p_ord-line-rcv-i no-lock where
                p_ord-line-rcv-i.doc-code  = buf-fp_ord-line.doc-code and
                p_ord-line-rcv-i.artic     = buf-fp_ord-line.artic and
                p_ord-line-rcv-i.prod-code = buf-fp_ord-line.prod-code and
                p_ord-line-rcv-i.prod-type = buf-fp_ord-line.prod-type ,
             first p_ord-doc-rcv-i no-lock where
                  p_ord-doc-rcv-i.doc-code  = p_ord-line-rcv-i.doc-code and
                  p_ord-doc-rcv-i.rcv-code  = p_ord-line-rcv-i.rcv-code and
                  p_ord-doc-rcv-i.obj-type  = b-of_ord-doc.obj-type  and
                  p_ord-doc-rcv-i.obj-code  = b-of_ord-doc.obj-code  and
                  p_ord-line-rcv-i.rcv-code  <> ub.ord-line-rcv.rcv-code  and
                  p_ord-doc-rcv-i.cons-code = loc-ord-cons-code
        :
        l-all-rcv-fp = l-all-rcv-fp + p_ord-line-rcv-i.qnty .

       end.

        loc-all-rcv =  buf-fp_ord-line.qnty -  l-all-rcv-fp .
        loc-all-rcv = if  loc-all-rcv < 0 then 0 else loc-all-rcv.

       /* заявлено по всем заявкам данного объекта */
       define variable loc-var-qnty-rcv as decimal no-undo .
       define buffer loc_zz_ord-line for ub.ord-line .
       define buffer loc_zz_ord-doc for  ub.ord-doc .
       loc-var-qnty-rcv = 0 .
       for each loc_zz_ord-line no-lock where
                loc_zz_ord-line.artic     = buf-fp_ord-line.artic and
                loc_zz_ord-line.prod-code = buf-fp_ord-line.prod-code and
                loc_zz_ord-line.prod-type = buf-fp_ord-line.prod-type ,
             first loc_zz_ord-doc no-lock where
                  loc_zz_ord-doc.doc-code  = loc_zz_ord-line.doc-code and
                  loc_zz_ord-doc.obj-type  = b-of_ord-doc.obj-type  and
                  loc_zz_ord-doc.obj-code  = b-of_ord-doc.obj-code  and
                  loc_zz_ord-doc.cons-code = loc-ord-cons-code
        :

       loc-var-qnty-rcv = loc-var-qnty-rcv + loc_zz_ord-line.qnty .
       end.

       /* уже поставлено по этому объекту */
       define variable p_fp0 as decimal no-undo .
       p_fp0 = 0 .
       for each p_ord-line-rcv-i no-lock where
                p_ord-line-rcv-i.artic     = buf-fp_ord-line.artic and
                p_ord-line-rcv-i.prod-code = buf-fp_ord-line.prod-code and
                p_ord-line-rcv-i.prod-type = buf-fp_ord-line.prod-type ,
             first p_ord-doc-rcv-i no-lock where
                  p_ord-doc-rcv-i.doc-code  = p_ord-line-rcv-i.doc-code and
                  p_ord-doc-rcv-i.rcv-code  = p_ord-line-rcv-i.rcv-code and
                  p_ord-doc-rcv-i.obj-type  = b-of_ord-doc.obj-type  and
                  p_ord-doc-rcv-i.obj-code  = b-of_ord-doc.obj-code  and
                  p_ord-line-rcv-i.rcv-code  <> ub.ord-line-rcv.rcv-code  and
                  p_ord-doc-rcv-i.cons-code = loc-ord-cons-code

        :

       p_fp0 = p_fp0 + p_ord-line-rcv-i.qnty .
       end.


      loc-var-qnty-rcv = loc-var-qnty-rcv - p_fp0 .
      loc-var-qnty-rcv = if  loc-var-qnty-rcv < 0 then 0 else loc-var-qnty-rcv.
/*
       message  buf-fp_ord-line.artic
       "минимум из заявки и заказа  из  " b-of_ord-line.qnty  buf-fp_ord-line.qnty  skip
       "из миним вычли что уже поставлено по заказу  " loc-var-qnty skip
       "Разница всего заказано - всего поставлено " loc-all-rcv     skip
       .

        message loc-var-qnty skip
                loc-all-rcv  skip
                loc-var-qnty-rcv .
                */
        assign
          ub.ord-line-rcv.qnty      = min (loc-var-qnty , loc-all-rcv , loc-var-qnty-rcv)
          ub.ord-line-rcv.qnty      = if ub.ord-line-rcv.qnty < 0 then 0 else ub.ord-line-rcv.qnty
          ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate
          .

    end.
    else do:
    /* нужная строка в СЗФП  */
       find first buf-tt-goods  where
               buf-tt-goods.gds-t     = {&h-goods}           and
               buf-tt-goods.artic     = buf-fp_ord-line.artic and
               buf-tt-goods.prod-code = buf-fp_ord-line.prod-code and
               buf-tt-goods.prod-type = buf-fp_ord-line.prod-type no-lock no-error .

               loc-all-rcv = if  buf-tt-goods.sum-ord - buf-tt-goods.sum-rcv < 0 then 0 else (buf-tt-goods.sum-ord - buf-tt-goods.sum-rcv ) .
       /* уже поставлено по этому заказу */

       define buffer p_ord-line-rcv for ub.ord-line-rcv .
       define buffer p_ord-doc-rcv  for ub.ord-doc-rcv  .
       define variable p_fp as decimal no-undo .
       p_fp = 0.
       for each p_ord-line-rcv no-lock where
                p_ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                p_ord-line-rcv.artic     = buf-fp_ord-line.artic and
                p_ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                p_ord-line-rcv.prod-type = buf-fp_ord-line.prod-type,
             first p_ord-doc-rcv no-lock where
                                         p_ord-line-rcv.doc-code  = p_ord-doc-rcv.doc-code  and
                                         p_ord-line-rcv.rcv-code  = p_ord-doc-rcv.rcv-code  and
                                         p_ord-line-rcv.rcv-code  <> ub.ord-line-rcv.rcv-code  and
                                         p_ord-doc-rcv.cons-code = loc-ord-cons-code

       :
       p_fp = p_fp + p_ord-line-rcv.qnty .
       /*
       message buf-fp_ord-line.qnty skip
               p_ord-line-rcv.doc-code p_ord-line-rcv.rcv-code p_ord-line-rcv.qnty.
               */
       end.

        assign
          ub.ord-line-rcv.qnty      = minimum ( (buf-fp_ord-line.qnty  - p_fp) , loc-all-rcv)
          ub.ord-line-rcv.qnty      = if ub.ord-line-rcv.qnty < 0 then 0 else ub.ord-line-rcv.qnty
          ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate
          .

    end.


    loc-new = recid(ord-line-rcv) .
    if avail b-of_ord-doc then do:
    run create-dtl-rcv  in this-procedure
    (     input  ub.ord-line-rcv.rcv-code ,
          input  ub.ord-line-rcv.doc-code ,
          input  "ord-fp"              ,
          input  b-of_ord-doc.doc-code ,
          input  ?                     ,
          input  ub.ord-line-rcv.artic    ,
          input  ub.ord-line-rcv.prod-type,
          input  ub.ord-line-rcv.prod-code
          ).
    end.


if loc-make-avto = false then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  {&update}
             , input  "ЦИКЛ":U
             , input-output  v-doc-mode  ) .


    if v-doc-mode = "stopcycle":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                  ub.ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                  ub.ord-line-rcv.rcv-code  = n-code and
                  ub.ord-line-rcv.artic     = buf-fp_ord-line.artic and
                  ub.ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                  ub.ord-line-rcv.prod-type = buf-fp_ord-line.prod-type no-error .
       delete ub.ord-line-rcv.
       return error  .
    end.

    if v-doc-mode = "cancel":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                    ub.ord-line-rcv.doc-code  = buf-fp_ord-line.doc-code and
                    ub.ord-line-rcv.rcv-code  = n-code and
                    ub.ord-line-rcv.artic     = buf-fp_ord-line.artic and
                    ub.ord-line-rcv.prod-code = buf-fp_ord-line.prod-code and
                    ub.ord-line-rcv.prod-type = buf-fp_ord-line.prod-type no-error .
       delete ub.ord-line-rcv.
    end.

    l-rec = recid(ord-line-rcv).
    end.
 end.
end.
run calc-cons-ord in this-procedure .
end.
END PROCEDURE.

PROCEDURE create-line-rcv-in :
 do
 on error undo, return error return-value
 :

/* Создание строки вн поставки */
define input parameter n-code  as   character no-undo .
define input parameter z-recid as   recid no-undo .
define input parameter p-ks    as   int  no-undo .
define input parameter p-qnty  like ub.ord-line-rcv.qnty   no-undo .
define output parameter l-rec  as   recid no-undo .

define buffer b-gds_ord-line for ub.ord-line .
define buffer b-of_ord-line  for ub.ord-line .
define buffer b-of_ord-doc   for ub.ord-doc  .
define buffer b-rcv_ord-doc-rcv   for ub.ord-doc-rcv  .
define buffer b-tt-goods          for tt-goods .
define variable loc-fact-qnty as decimal no-undo .
define variable v-doc-mode as character no-undo .

/* нужная строка в заявке */

find first  b-gds_ord-line    no-lock  where recid(b-gds_ord-line) = z-recid       no-error .
find first  b-rcv_ord-doc-rcv no-lock  where b-rcv_ord-doc-rcv.rcv-code = n-code   no-error .
if avail b-gds_ord-line then do:
  if not can-find  (first ub.ord-line-rcv where
                ub.ord-line-rcv.rcv-code  = n-code and
                ub.ord-line-rcv.artic     = b-gds_ord-line.artic and
                ub.ord-line-rcv.prod-code = b-gds_ord-line.prod-code and
                ub.ord-line-rcv.prod-type = b-gds_ord-line.prod-type no-lock ) then do:
    find first b-tt-goods where
               b-tt-goods.gds-t     = {&h-goods} and
               b-tt-goods.artic     = b-gds_ord-line.artic and
               b-tt-goods.prod-code = b-gds_ord-line.prod-code and
               b-tt-goods.prod-type = b-gds_ord-line.prod-type no-lock  .

     loc-fact-qnty = b-tt-goods.sum-qnty - ( b-tt-goods.sum-ord + b-tt-goods.sum-rcv-in) .

    define variable pp-qnty as decimal no-undo .
    define variable pp-cli-qnty as decimal no-undo .

    assign
      pp-qnty      = if p-qnty > 0 then   minimum ( p-qnty , b-gds_ord-line.qnty , loc-fact-qnty ) else minimum ( b-gds_ord-line.qnty , loc-fact-qnty )
      pp-qnty      = if pp-qnty < 0 then   0 else pp-qnty
      pp-cli-qnty  = pp-qnty / b-gds_ord-line.cli-base-rate
    .
    run proc-create-rcv-line  in this-procedure
    (  input b-gds_ord-line.SLT-pc
      ,input b-gds_ord-line.VAT-pc
      ,input b-gds_ord-line.artic
      ,input b-gds_ord-line.cli-base-rate
      ,input pp-cli-qnty
      ,input ""
      ,input b-gds_ord-line.excise
      ,input b-gds_ord-line.gds-code
      ,input p-ks
      ,input b-gds_ord-line.other-base
      ,input b-gds_ord-line.other-rubl
      ,input b-gds_ord-line.price-base
      ,input b-gds_ord-line.price-cli
      ,input b-gds_ord-line.price-rubl
      ,input b-gds_ord-line.prod-code
      ,input b-gds_ord-line.prod-type
      ,input pp-qnty
      ,input n-code
      ,input b-gds_ord-line.road-tax
      ,input b-gds_ord-line.sum-SLT
      ,input b-gds_ord-line.sum-VAT
      ,input b-gds_ord-line.sum-base
      ,input b-gds_ord-line.sum-cli
      ,input b-gds_ord-line.sum-excise
      ,input b-gds_ord-line.sum-other-base
      ,input b-gds_ord-line.sum-other-rubl
      ,input b-gds_ord-line.sum-road-tax
      ,input b-gds_ord-line.sum-rubl
      ,input b-gds_ord-line.sum-transport-base
      ,input b-gds_ord-line.sum-transport-rubl
      ,input b-gds_ord-line.transport-base
      ,input b-gds_ord-line.transport-rubl
      ,input b-gds_ord-line.unit-cli
      ,input b-gds_ord-line.v-vat
      ) no-error .
    if not error-status :error then do:
    run create-dtl-rcv in this-procedure
    (     input  ub.ord-line-rcv.rcv-code ,
          input  ub.ord-line-rcv.doc-code ,
          input  "rcv-in"              ,
          input  b-gds_ord-line.doc-code ,
          input  ?                     ,
          input  ub.ord-line-rcv.artic    ,
          input  ub.ord-line-rcv.prod-type,
          input  ub.ord-line-rcv.prod-code ).
     end.

if loc-make-avto = false then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  {&update}
             , input  "ЦИКЛ":U
             , input-output  v-doc-mode  ) .

    if v-doc-mode = "stopcycle":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                    ub.ord-line-rcv.rcv-code  = n-code and
                    ub.ord-line-rcv.artic     = b-gds_ord-line.artic and
                    ub.ord-line-rcv.prod-code = b-gds_ord-line.prod-code and
                    ub.ord-line-rcv.prod-type = b-gds_ord-line.prod-type no-error .

      delete ub.ord-line-rcv.
      return error.
      end.
    if v-doc-mode = "cancel":U  then do:
        find first ub.ord-line-rcv  exclusive-lock  where
                    ub.ord-line-rcv.rcv-code  = n-code and
                    ub.ord-line-rcv.artic     = b-gds_ord-line.artic and
                    ub.ord-line-rcv.prod-code = b-gds_ord-line.prod-code and
                    ub.ord-line-rcv.prod-type = b-gds_ord-line.prod-type no-error .

      delete ub.ord-line-rcv.
      end.

    l-rec = recid(ord-line-rcv).
    end.
 end.
end.
run calc-cons-ord in this-procedure .

end.
END PROCEDURE.


procedure del-zakaz-doc:
 do
 on error undo, return error return-value
 :

def input param d-recid as recid no-undo.
find first  ub.ord-doc no-lock  where recid(ub.ord-doc) = d-recid no-error .
if ub.ord-doc.status_ <> {&g___new} then do:
  message "Нельзя удалить документ в статусе " ub.ord-doc.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
  return.
end.

for each ub.ord-doc  exclusive-lock  where recid(ub.ord-doc) = d-recid  :
    delete ub.ord-doc.
end.

run calc-cons-ord in this-procedure  .

end.
END PROCEDURE.

procedure del-zakaz:
 do
 on error undo, return error return-value
 :

def input param d-recid as recid no-undo.

find first  ub.ord-line no-lock  where recid(ord-line) = d-recid no-error .
find first  ub.ord-doc   exclusive-lock   where ub.ord-doc.doc-code = ub.ord-line.doc-code no-error .
if ub.ord-doc.status_ <> {&g___new} then do:
  message "Нельзя удалить документ в статусе " ub.ord-doc.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
  return.
end.

for each ub.ord-line  exclusive-lock  where recid(ord-line) = d-recid  :
   delete ub.ord-line.
end.

find first  ub.ord-line no-lock  where ub.ord-doc.doc-code = ub.ord-line.doc-code  no-error .
if not available  ub.ord-line then do:
    message "Теперь в заказе " ub.ord-doc.doc-code "нет ни одной строки ! Удаляем его ."
            view-as alert-box information .
    delete  ub.ord-doc no-error .
end.

run calc-cons-ord in this-procedure  .

end .
END PROCEDURE.

procedure del-post:
 do
 on error undo, return error return-value
 :

def input param d-recid as recid no-undo.
find first  ub.ord-line-rcv no-lock  where recid(ord-line-rcv) = d-recid no-error .
find first  ub.ord-doc-rcv   exclusive-lock    where ub.ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code
                                    and ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code   no-error .
    if available ub.ord-doc-rcv then do:
      if ub.ord-doc-rcv.status_ <> {&g___new} then do:
        message "Нельзя удалить поставку в статусе " ub.ord-doc-rcv.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
        return.
      end.

      for each ub.ord-line-rcv exclusive-lock where recid(ord-line-rcv) = d-recid  :
        delete ub.ord-line-rcv.
      end.


      find first  ub.ord-line-rcv no-lock  where ub.ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code
                                        and ub.ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code   no-error .
      if not available  ub.ord-line-rcv then do:
         message "Теперь в поставке " ub.ord-doc-rcv.rcv-code "нет ни одной строки ! Удаляем ее ." view-as alert-box information .
         delete  ub.ord-doc-rcv   no-error .
      end.
      run calc-cons-ord in this-procedure  .
    end.
end.
END PROCEDURE.

procedure del-post-doc:
 do
 on error undo, return error return-value
 :

def input param d-recid as recid no-undo.

find first  ub.ord-doc-rcv no-lock where recid(ub.ord-doc-rcv) = d-recid no-error .
if ub.ord-doc-rcv.status_ <> {&g___new} then do:
  message "Нельзя удалить поставку в статусе " ub.ord-doc-rcv.status_ "! Можно только в статусе НОВЫЙ " view-as alert-box error .
  return.
end.
for each ub.ord-doc-rcv  exclusive-lock   where recid(ub.ord-doc-rcv) = d-recid  :
   delete ub.ord-doc-rcv.
end.
run calc-cons-ord in this-procedure  .

end.
END PROCEDURE.

procedure del-nacl:
 do
 on error undo, return error return-value
 :
define variable dd as character no-undo .

def input param d-recid as recid no-undo.

for each ub.doc-line  exclusive-lock  where recid(doc-line) = d-recid :
    dd = ub.doc-line.doc-code.
   if ub.doc-line.status_ <> {&wayb} then leave.
   delete ub.doc-line.
end.

find first  ub.doc-line no-lock  where ub.doc-line.doc-code = dd  no-error .
if not available  ub.doc-line then do:
    message "Теперь в накладной " dd " нет ни одной строки ! Удаляем ее ."
            view-as alert-box information .
    find first ub.trn-doc  exclusive-lock  where ub.trn-doc.doc-code = dd no-error .
      if available ub.trn-doc then   delete  ub.trn-doc no-error .
end.

run calc-cons-ord in this-procedure  .

end.
END PROCEDURE.

procedure del-nacl-doc:
 do
 on error undo, return error return-value
 :


def input param d-recid as recid no-undo.
for each ub.trn-doc  exclusive-lock   where recid(trn-doc) = d-recid :
   if ub.trn-doc.status_ <> {&wayb} then leave.
   delete ub.trn-doc.
end.
run calc-cons-ord in this-procedure  .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-mark Dialog-Frame
PROCEDURE del-mark :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable  pp-rec as recid no-undo .
pp-rec = recid (tt-goods) .

for each tt-goods  exclusive-lock  :
   tt-goods.use = false.
end.

{&OPEN-QUERY-BROWSE-12}
reposition BROWSE-12 to recid pp-rec no-error .

end.
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
  HIDE FRAME FRAME-B-prt.
  HIDE FRAME FRAME-C.
  HIDE FRAME FRAME-D.
  HIDE FRAME FRAME-d-prt.
  HIDE FRAME FRAME-E.
  HIDE FRAME FRAME-E-prt.
  HIDE FRAME FRAME-F.
  HIDE FRAME FRAME-H.
  HIDE FRAME FRAME-I.
  HIDE FRAME FRAME-J.
  HIDE FRAME FRAME-K.
  HIDE FRAME FRAME-Post-prt.
  HIDE FRAME FRAME-Postavki.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dop-pr Dialog-Frame
PROCEDURE dop-pr :
do
 on error undo, return error return-value
 :

define buffer tt-new-ord-line-2  for  ub.ord-line.
    find first tt-new-ord-line-2  exclusive-lock   where recid(tt-new-ord-line-2) = recid(tt-new-ord-line) no-error .
assign
tt-new-ord-line-2.SLT-pc               = TMP#zakaz.SLT-pc
tt-new-ord-line-2.VAT-pc               = TMP#zakaz.VAT-pc
tt-new-ord-line-2.add-cli-qnty         = TMP#zakaz.add-cli-qnty
tt-new-ord-line-2.add-qnty             = TMP#zakaz.add-qnty
tt-new-ord-line-2.artic                = TMP#zakaz.artic
tt-new-ord-line-2.cancel-cli-qnty      = TMP#zakaz.cancel-cli-qnty
tt-new-ord-line-2.cancel-date          = TMP#zakaz.cancel-date
tt-new-ord-line-2.cancel-qnty          = TMP#zakaz.cancel-qnty
tt-new-ord-line-2.cli-art              = TMP#zakaz.cli-art
tt-new-ord-line-2.cli-base-rate        = TMP#zakaz.cli-base-rate
tt-new-ord-line-2.cli-qnty             = TMP#zakaz.cli-qnty
tt-new-ord-line-2.doc-code             = TMP#zakaz.doc-code
tt-new-ord-line-2.excise               = TMP#zakaz.excise
tt-new-ord-line-2.fact-date            = TMP#zakaz.fact-date
tt-new-ord-line-2.initial-cli-qnty     = TMP#zakaz.initial-cli-qnty
tt-new-ord-line-2.initial-qnty         = TMP#zakaz.initial-qnty
tt-new-ord-line-2.line-num             = TMP#zakaz.line-num
tt-new-ord-line-2.order-cli-qnty       = TMP#zakaz.order-cli-qnty
tt-new-ord-line-2.order-qnty           = TMP#zakaz.order-qnty
tt-new-ord-line-2.other-base           = TMP#zakaz.other-base
tt-new-ord-line-2.other-rubl           = TMP#zakaz.other-rubl
tt-new-ord-line-2.price-base           = TMP#zakaz.price-base
tt-new-ord-line-2.price-cli            = TMP#zakaz.price-cli
tt-new-ord-line-2.price-rubl           = TMP#zakaz.price-rubl
tt-new-ord-line-2.prod-code            = TMP#zakaz.prod-code
tt-new-ord-line-2.prod-type            = TMP#zakaz.prod-type
tt-new-ord-line-2.qnty                 = TMP#zakaz.qnty
tt-new-ord-line-2.receive-cli-qnty     = TMP#zakaz.receive-cli-qnty
tt-new-ord-line-2.receive-qnty         = TMP#zakaz.receive-qnty
tt-new-ord-line-2.road-tax             = TMP#zakaz.road-tax
tt-new-ord-line-2.sum-SLT              = TMP#zakaz.sum-SLT
tt-new-ord-line-2.sum-VAT              = TMP#zakaz.sum-VAT
tt-new-ord-line-2.sum-base             = TMP#zakaz.sum-base
tt-new-ord-line-2.sum-cli              = TMP#zakaz.sum-cli
tt-new-ord-line-2.sum-excise           = TMP#zakaz.sum-excise
tt-new-ord-line-2.sum-other-base       = TMP#zakaz.sum-other-base
tt-new-ord-line-2.sum-other-rubl       = TMP#zakaz.sum-other-rubl
tt-new-ord-line-2.sum-road-tax         = TMP#zakaz.sum-road-tax
tt-new-ord-line-2.sum-rubl             = TMP#zakaz.sum-rubl
tt-new-ord-line-2.sum-transport-base   = TMP#zakaz.sum-transport-base
tt-new-ord-line-2.sum-transport-rubl   = TMP#zakaz.sum-transport-rubl
tt-new-ord-line-2.transport-base       = TMP#zakaz.transport-base
tt-new-ord-line-2.transport-rubl       = TMP#zakaz.transport-rubl
tt-new-ord-line-2.unit-cli             = TMP#zakaz.unit-cli
tt-new-ord-line-2.v-vat                = TMP#zakaz.v-vat
.


end.
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
  DISPLAY R-main str-good F-post-2 F-post F-obj
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Help BUTTON-2 R-main BUTTON-3 BUTTON-47 str-good F-post-2
         F-post F-obj RECT-3
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  {&OPEN-BROWSERS-IN-QUERY-FRAME-Post-prt}
  ENABLE BROWSE-37 BROWSE-36
      WITH FRAME FRAME-B-prt.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-B-prt}
  ENABLE BROWSE-32 BROWSE-33
      WITH FRAME FRAME-E-prt.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-E-prt}
  ENABLE BROWSE-26 BROWSE-27 B-make-post-ex-3 BUTTON-27 BUTTON-53 BUTTON-28
         BUTTON-30 BUTTON-54 BUTTON-31
      WITH FRAME FRAME-K.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-K}
  ENABLE BROWSE-18 BROWSE-28 B-make-post-ex-2 BUTTON-9 BUTTON-55 BUTTON-10
         BUTTON-33 BUTTON-56 BUTTON-34
      WITH FRAME FRAME-J.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-J}
  ENABLE BROWSE-23 BROWSE-24 BUTTON-48 BUTTON-17 BUTTON-57 BUTTON-18 BUTTON-21
         BUTTON-20
      WITH FRAME FRAME-I.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-I}
  ENABLE B-make-trn-2 BUTTON-58 BROWSE-15 BROWSE-20 BUTTON-7 BUTTON-8 BUTTON-14
      WITH FRAME FRAME-H.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-H}
  ENABLE BROWSE-30
      WITH FRAME FRAME-C.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-C}
  ENABLE BROWSE-12 B-mark B-mark-3 B-mark-4
      WITH FRAME FRAME-A.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  ENABLE BROWSE-16 B-ins-za B-za-3 B-reject B-isk
      WITH FRAME FRAME-F.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-F}
  ENABLE BROWSE-31
      WITH FRAME FRAME-d-prt.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-d-prt}
  ENABLE BROWSE-13
      WITH FRAME FRAME-D.
  VIEW FRAME FRAME-D.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-D}
  DISPLAY T-cli T-cli-fp
      WITH FRAME FRAME-E.
  ENABLE BROWSE-17 T-cli T-cli-fp
      WITH FRAME FRAME-E.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-E}
  ENABLE BROWSE-21 BROWSE-29 BROWSE-22 B-make-trn BUTTON-50 BUTTON-52 BUTTON-49
         BUTTON-51
      WITH FRAME FRAME-Postavki.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-Postavki}
  DISPLAY T-obj
      WITH FRAME FRAME-B.
  ENABLE BROWSE-14 T-obj
      WITH FRAME FRAME-B.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-B}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-all-button Dialog-Frame
PROCEDURE hide-all-button :
do
 on error undo, return error return-value
 :

Hide b-mark  in frame frame-A
     b-mark-3 in frame frame-A
     b-mark-4 in frame frame-A .

  hide  b-ins-za  in frame frame-F
        b-reject in frame frame-F
        b-isk    in frame frame-F
        .

  hide
    button-7 in frame frame-H
    button-8 in frame frame-H
    button-15 in frame frame-H
    button-14 in frame frame-H
    b-make-trn-2 in frame frame-h .
     .

   hide
    button-17 in frame frame-I
    button-18 in frame frame-I
    button-20 in frame frame-I
    button-48 in frame frame-I
    .
  hide
    button-51 in frame frame-postavki
    button-50 in frame frame-postavki
    b-make-trn in frame frame-postavki .

  hide
    button-27  in frame frame-k
    button-28 in frame frame-k
    button-30 in frame frame-k
    button-31 in frame frame-k
    b-make-post-ex-3 in frame frame-k .

  hide
    button-9  in frame frame-J
    button-10 in frame frame-J
    button-33 in frame frame-J
    button-34 in frame frame-J
    B-mark-2  in frame frame-J
    b-make-post-ex-2 in frame frame-J.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-create-button Dialog-Frame
PROCEDURE hide-create-button :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
hide
  b-make-trn-2 in frame frame-h .
    .

  hide
  button-48 in frame frame-I
  .
hide
  b-make-trn in frame frame-postavki .

hide
  b-make-post-ex-3 in frame frame-k .

hide
  b-make-post-ex-2 in frame frame-J.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-2 Dialog-Frame
PROCEDURE init-2 :
do
 on error undo, return error return-value
 :

define buffer bf_ord-cons for ub.ord-cons .
   apply "CHOOSE":U to BUTTON-2 in frame {&frame-name}.
 if list-mode = "obj":U then do:
   apply "CHOOSE":U to BUTTON-47 in frame {&frame-name}.
   end.


VIEW FRAME FRAME-A.
apply "VALUE-CHANGED":U to BROWSE-12 IN FRAME FRAME-A.
VIEW FRAME FRAME-D.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-D}

if doc-mode = {&lookup} then do:
   run hide-all-button in this-procedure .
end.


find first bf_ord-cons no-lock  where bf_ord-cons.cons-code = loc-ord-cons-code no-error .
if not avail bf_ord-cons then return error.
/*  В оФФИСЕ */
if doc-mode = {&update} and bf_ord-cons.status_ <>  {&g___new}  and list-mode <> "obj":U  then do:
   disable b-ins-za B-reject b-isk with frame FRAME-F.
end.
if doc-mode = {&update} and bf_ord-cons.status_ =  {&ord-close}  and list-mode <> "obj":U  then do:
   run hide-all-button in this-procedure .
end.

if doc-mode = {&update} and bf_ord-cons.status_ =  {&g___new}  and list-mode <> "obj":U then do:
   run hide-create-button in this-procedure .
end.

/* на складе*/
if doc-mode = {&update} and ( bf_ord-cons.status_ =  {&g___new}  )
                        and list-mode = "obj":U  then do:
   run hide-all-button in this-procedure .
end.

if doc-mode = {&update} and ( bf_ord-cons.status_ =  {&ord-close}  OR bf_ord-cons.status_ =  {&ord-alloc}  )
                        and list-mode = "obj":U  then do:
   run hide-all-button in this-procedure .
   view b-make-trn in frame frame-postavki .
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-ord-gds Dialog-Frame
PROCEDURE init-ord-gds :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable t-ret as logical no-undo .

 t-ret =  session:SET-WAIT-STATE("GENERAL") .
  for each tt-ord-gds  exclusive-lock  :
    delete tt-ord-gds.
  end.

t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
do
 on error undo, return error return-value
 :

define variable t-ret as logical no-undo .
{ cmp/df-sub.i pr }
 t-ret =  session:SET-WAIT-STATE("GENERAL") .
assign
  loc-ord-cons-code = p-cons-code
  x-mode = "constype":U
  .

  {&ENABLED-FIELDS-IN-QUERY-BROWSE-12} :read-only in browse browse-12 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-15} :read-only in browse browse-15 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-18} :read-only in browse browse-18 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-20} :read-only in browse browse-20 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-26} :read-only in browse browse-26 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-27} :read-only in browse browse-27 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-30} :read-only in browse browse-30 = true .
  {&ENABLED-FIELDS-IN-QUERY-BROWSE-29} :read-only in browse browse-29 = true .

  for each  ub.ord-gds-cons no-lock  where
            ub.ord-gds-cons.cons-code = loc-ord-cons-code
            ,
    first ub.goods no-lock where
          ub.goods.artic     = ub.ord-gds-cons.artic and
          ub.goods.prod-code = ub.ord-gds-cons.prod-code and
          ub.goods.prod-type = ub.ord-gds-cons.prod-type
          :
      dk = dk + 1.
      create tt-goods.
      buffer-copy ub.goods to tt-goods
      assign
        tt-goods.nn        = dk
        tt-goods.gds-t     = {&h-goods}
        tt-goods.sum-qnty  = ub.ord-gds-cons.sum-qnty
        tt-goods.prt-name  = ""
        tt-goods.all-name  = tt-goods.gds-name
        tt-goods.node-code = 0
      .

      for each ub.ord-dtl-cons no-lock where
               ub.ord-dtl-cons.cons-code = loc-ord-cons-code and
               ub.ord-dtl-cons.artic     = ub.ord-gds-cons.artic and
               ub.ord-dtl-cons.prod-code = ub.ord-gds-cons.prod-code and
               ub.ord-dtl-cons.prod-type = ub.ord-gds-cons.prod-type  :

               find first ub.gds-prt no-lock  where ub.gds-prt.node-code =  ub.ord-dtl-cons.node-code no-error .
               if error-status :error then next.
               dk = dk + 1.
              create tt-goods.
              buffer-copy ub.goods to tt-goods
              assign
                tt-goods.nn = dk
                tt-goods.gds-t = {&h-property}
                tt-goods.sum-qnty = ub.ord-dtl-cons.sum-qnty
                tt-goods.prt-name = ub.gds-prt.f-name
                tt-goods.all-name = "- "  +  ub.gds-prt.f-name
                tt-goods.node-code =  ub.ord-dtl-cons.node-code
              .
      end.
  end.

for each ub.shop  no-lock where ub.shop.host-code = g#host-code  :
    find first ub.clients no-lock where
               ub.clients.obj-code = ub.shop.obj-code and
               ub.clients.obj-type = {&shop}
               no-error .
    if available  ub.shop and available ub.clients then do :
        create my-obj .
        assign
          my-obj.obj-code = ub.shop.obj-code
          my-obj.obj-type = {&shop}
          my-obj.obj-name = ub.clients.obj-name
          .
     end.
end.

for each ub.store no-lock where ub.store.host-code = g#host-code :
    find first ub.clients no-lock  where
               ub.clients.obj-code = ub.store.obj-code and
               ub.clients.obj-type = {&stock}
               no-error .
    if available  ub.store and available ub.clients then do:
        create  my-obj .
        assign  my-obj.obj-code = ub.store.obj-code
                my-obj.obj-type = {&stock}
                my-obj.obj-name = ub.clients.obj-name
        .
     end.
end.
ttt = "Планирование СОВОКУПНОЙ ЗАЯВКИ "  + p-cons-code  + " - " + doc-mode.

frame {&frame-name}:title = ttt.

ASSIGN B-make-post-ex-3:POPUP-MENU IN FRAME frame-k = MENU POPUP-MENU-B-make-post-ex-3:HANDLE.
ASSIGN B-make-post-ex-3:MENU-MOUSE = 1.

ASSIGN B-make-post-ex-2:POPUP-MENU IN FRAME frame-j = MENU POPUP-MENU-B-make-post-ex-2:HANDLE.
ASSIGN B-make-post-ex-2:MENU-MOUSE = 1.

ASSIGN B-make-trn-2:POPUP-MENU IN FRAME frame-H = MENU POPUP-MENU-B-make-trn-2:HANDLE.
ASSIGN B-make-trn-2:MENU-MOUSE = 1.

ASSIGN B-make-trn:POPUP-MENU IN FRAME frame-Postavki = MENU POPUP-MENU-B-make-trn:HANDLE.
ASSIGN B-make-trn:MENU-MOUSE = 1.


ASSIGN BUTTON-48:POPUP-MENU IN FRAME frame-I = MENU POPUP-MENU-BUTTON-48:HANDLE.
ASSIGN BUTTON-48:MENU-MOUSE = 1.

/* сбор handls browses */

define variable t-h as character no-undo .

&scop run_read-handle  run read-handle in this-procedure (input browse-~{&s-num}:handle , ~
                       output t-h ) . ~
                       handle-br-all[~{&s-num}] = t-h .

 &scop s-num 18
{&run_read-handle}

&scop s-num 28
{&run_read-handle}

&scop s-num 26
{&run_read-handle}

&scop s-num 27
{&run_read-handle}

&scop s-num 20
{&run_read-handle}

&scop s-num 15
{&run_read-handle}

&scop s-num 23
{&run_read-handle}

&scop s-num 24
{&run_read-handle}


run calc-cons-ord in this-procedure .

t-ret =  session:SET-WAIT-STATE("") .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame
PROCEDURE local-mark :
do
 on error undo, return error return-value
 :

if not available tt-new-ord-line then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.

  { gbl/markstrn.i tt-new-ord-line del-list }
  if lookup(string( recid(tt-new-ord-line) ), del-list ) > 0
      then disp "" @ mark with browse browse-18.
      else disp "+" @ mark with browse browse-18.

  apply "VALUE-CHANGED" to browse-18 in frame frame-J.
  g#log = browse-18:select-next-row ().

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-fp Dialog-Frame
PROCEDURE make-fp :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose: генерация заказов ФП
-------------------------------------------------------------*/
define input  parameter l-mod as character no-undo .
define output parameter o-rec as recid no-undo.

define variable ks as integer no-undo .
define variable v-num-OF as character no-undo .
define variable g-recid as recid no-undo .
define buffer nbn_ord-line for ub.ord-line .
ks = 0.

find current buf_clients no-lock no-error .
if not available  buf_clients then do:
   message "Не выбран Поставщик !!! " .
   return.
end.

if l-mod = "1" then do:
    find current tt-goods no-lock no-error .
    if not available  tt-goods then do:
      message "Не выбран Товар !!! " .
      return.
    end.
end.

if l-mod = "2" then do:
    find current tt-goods no-lock no-error .
    if not available  tt-goods then do:
      message "Не выбран Товар !!! " .
      return.
    end.
    g-recid = recid(tt-goods) .
end.


if l-mod = "3" then do:
/* br-16 */
define variable doc-code-z as character no-undo .

  doc-code-z  = ub.ord-doc.doc-code:screen-value in browse browse-16  .
  if doc-code-z = ? then return.
end.

  v-num-OF = doc-code-z  .

{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-ord-num
    }


/* Шапка заказа */
define variable vvv as logical no-undo .
define buffer b-ord-doc for ub.ord-doc .
  vvv = false  .
find first  ub.ord-doc  exclusive-lock   where
     ub.ord-doc.cli-code  = buf_clients.obj-code and
     ub.ord-doc.cli-type  = buf_clients.obj-type and
     ub.ord-doc.cons-code = p-cons-code and
     ub.ord-doc.host-code = g#host-code and
     ub.ord-doc.doc-type  = {&f-p}
     no-error .

if not available ub.ord-doc then do:
   vvv = true .
   create ub.ord-doc.
   assign
      ub.ord-doc.doc-code  = loc-ord-num
      ub.ord-doc.cli-code  = buf_clients.obj-code
      ub.ord-doc.cli-type  = buf_clients.obj-type
      ub.ord-doc.cli-name  = buf_clients.obj-name
      ub.ord-doc.cons-code = p-cons-code
      ub.ord-doc.host-code = g#host-code
      ub.ord-doc.obj-code  = store-code
      ub.ord-doc.obj-type  = store-type
      ub.ord-doc.doc-type  = {&f-p}
      ub.ord-doc.status_   = {&g___new}
      ub.ord-doc.start-date = to-day - 7
      ub.ord-doc.end-date   = to-day
      ub.ord-doc.doc-date  = to-day
      ub.ord-doc.ship-date = to-day + 1
      ub.ord-doc.date-sale-1 = to-day + 1
      ub.ord-doc.date-sale-2 = to-day + 2
      ub.ord-doc.ship-time = 0
       .

      /* Валюта поставщика */
      ub.ord-doc.exch-code = 0 .
      find ub.currency no-lock  where ub.currency.curr-code = ub.ord-doc.exch-code no-error.
        if available ub.currency then do:
            find last ub.curr-accnt no-lock   where ub.curr-accnt.curr-code = ub.currency.curr-code  use-index pi no-error.
              if available ub.curr-accnt then assign
                ub.ord-doc.exch-rate = ub.curr-accnt.exch-rate
                ub.ord-doc.exch-scale = ub.curr-accnt.exch-scale.

            /* Базовая валюта */
            find last ub.curr-accnt no-lock  where ub.curr-accnt.curr-code = base-code  use-index pi no-error .
            assign
              ub.ord-doc.base-rate  = ub.curr-accnt.exch-rate
              ub.ord-doc.base-scale = ub.curr-accnt.exch-scale
              .
       end.

       ub.ord-doc.vat-type = {&inc-vat} .
       ub.ord-doc.slt-type = {&without-slt} .


 x-make-avto = 2 .

 run cus/or-head.w ( parParentProc, input loc-ord-num , input vvv , output doc-mode ) . /*корректировка шапки */

 if available ord-doc then do:
    loc-ord-num = ord-doc.doc-code.
 end.
  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case.

end.
else do:
   message "Уже существует заказ ФП " ub.ord-doc.doc-code  skip
            "Контрагент -код: " ub.ord-doc.cli-code        skip
            "Контрагент -тип: " ub.ord-doc.cli-type        skip
            "Контрагент -имя: " ub.ord-doc.cli-name        skip
            "Будем делать новый заказ ?"  view-as alert-box question buttons yes-no update g#lok as logical.
   if g#lok = false  then do:
        assign loc-ord-num = ub.ord-doc.doc-code .
      end.
      else do:
        BUFFER-COPY ub.ord-doc to b-ord-doc
        assign b-ord-doc.doc-code = loc-ord-num
               b-ord-doc.status_   = {&g___new}
        .
        x-make-avto = 2 .
        run cus/or-head.w (parParentProc,input loc-ord-num , true , output doc-mode ) . /* корректировка шапки */

  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .

      end.
end.



 define variable ll-d as character no-undo .

 ll-d = loc-ord-num .

 if doc-mode = "cancel":U then return.
 ks = 0 .

line-mode = {&update} . /* Нельзя на первой же записи делать СТОПЦИКЛ - сразу падает приложение  */

doc-rec = recid(ub.ord-doc) .

case l-mod :
when "1" then do: /* текущий товар в совокупке */
define variable r-tmp as recid no-undo.
define variable r-stop as log no-undo.
define variable r-exit  as log no-undo.
define variable ii as integer no-undo .
  for each tt-goods no-lock  where
           tt-goods.use = true :
      run create-line-fp  in this-procedure ( input loc-ord-num , output r-tmp) no-error .
          if error-status :error then leave.
          r-tmp = line-rec.
      run create-dtl-fp in this-procedure
                        ( input loc-ord-num,
                          input "ord-cons",
                          input loc-ord-cons-code,
                          input tt-goods.artic,
                          input tt-goods.prod-type,
                          input tt-goods.prod-code ,
                          input tt-goods.cli-base-rate ).
       ks = ks + 1 .
       end.
  end.
when "2" then do: /* отмеченные товары в совокупке */
  for each tt-goods no-lock  where recid(tt-goods)  = g-recid :
      run create-line-fp in this-procedure ( input loc-ord-num , output r-tmp ) no-error .
      if error-status :error then leave.
      run create-dtl-fp in this-procedure
                        ( input loc-ord-num,
                          input "ord-cons",
                          input loc-ord-cons-code,
                          input tt-goods.artic,
                          input tt-goods.prod-type,
                          input tt-goods.prod-code ,
                          input tt-goods.cli-base-rate ).
       ks = ks + 1 .
  end.
end.
when "3" then do: /* по заявке состав и кол-во */
    for each m_ord-line no-lock  where
             m_ord-line.doc-code = v-num-OF :
        ks = ks + 1 .
        find first nbn_ord-line no-lock where
              nbn_ord-line.doc-code   = loc-ord-num and
              nbn_ord-line.artic      = m_ord-line.artic and
              nbn_ord-line.prod-code  = m_ord-line.prod-code and
              nbn_ord-line.prod-type  = m_ord-line.prod-type
              no-error .
        if not available nbn_ord-line then do:
            create  nbn_ord-line.
            BUFFER-COPY m_ord-line to nbn_ord-line
            assign
              nbn_ord-line.doc-code           = loc-ord-num
              nbn_ord-line.line-num           = ks
            .
          run last-price  in this-procedure
          (     input  g#host-code        ,
                input  nbn_ord-line.artic     ,
                input  nbn_ord-line.prod-type ,
                input  nbn_ord-line.prod-code ,
                input  ub.ord-doc.cli-code   ,
                input  ub.ord-doc.cli-type   ,
                input  nbn_ord-line.cli-base-rate  ,
                input  ub.ord-doc.exch-code  ,
                output nbn_ord-line.price-base,
                output nbn_ord-line.price-rubl,
                output nbn_ord-line.price-cli  )
                no-error  .
                if error-status :error then message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка last-price"
                  view-as alert-box error
                .
                assign
                  nbn_ord-line.sum-base = nbn_ord-line.price-base * nbn_ord-line.qnty
                  nbn_ord-line.sum-rubl = nbn_ord-line.price-rubl * nbn_ord-line.qnty
                  nbn_ord-line.sum-cli  = nbn_ord-line.price-cli  * nbn_ord-line.cli-qnty
                .
          /* Налоги текущие на сейчас */
          { gbl/pftxvalg.i nbn_ord-line.gds-code {&vat-tax-code} ? g#host-code store-type store-code nbn_ord-line.vat-pc no-error }
                if error-status :error then message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка определения НДС"
                  view-as alert-box error
                .

          find first  tmp#zakaz where
                      TMP#zakaz.artic     = nbn_ord-line.artic and
                      TMP#zakaz.prod-code = nbn_ord-line.prod-code and
                      TMP#zakaz.prod-type = nbn_ord-line.prod-type  no-error .
          if not available Tmp#zakaz then do:
              create TMP#zakaz.
          end.
              assign
                    TMP#zakaz.SLT-pc                = nbn_ord-line.SLT-pc
                    TMP#zakaz.VAT-pc                = nbn_ord-line.VAT-pc
                    TMP#zakaz.add-cli-qnty          = nbn_ord-line.add-cli-qnty
                    TMP#zakaz.add-qnty              = nbn_ord-line.add-qnty
                    TMP#zakaz.artic                 = nbn_ord-line.artic
                    TMP#zakaz.prod-code             = nbn_ord-line.prod-code
                    TMP#zakaz.prod-type             = nbn_ord-line.prod-type
                    TMP#zakaz.gds-code              = nbn_ord-line.gds-code
                    TMP#zakaz.cancel-cli-qnty       = nbn_ord-line.cancel-cli-qnty
                    TMP#zakaz.cancel-date           = nbn_ord-line.cancel-date
                    TMP#zakaz.cancel-qnty           = nbn_ord-line.cancel-qnty
                    TMP#zakaz.cli-art               = nbn_ord-line.cli-art
                    TMP#zakaz.cli-base-rate         = nbn_ord-line.cli-base-rate
                    TMP#zakaz.cli-qnty              = nbn_ord-line.cli-qnty
                    TMP#zakaz.doc-code              = nbn_ord-line.doc-code
                    TMP#zakaz.excise                = nbn_ord-line.excise
                    TMP#zakaz.fact-date             = nbn_ord-line.fact-date
                    TMP#zakaz.initial-cli-qnty      = nbn_ord-line.initial-cli-qnty
                    TMP#zakaz.initial-qnty          = nbn_ord-line.initial-qnty
                    TMP#zakaz.line-num              = nbn_ord-line.line-num
                    TMP#zakaz.order-cli-qnty        = nbn_ord-line.order-cli-qnty
                    TMP#zakaz.order-qnty            = nbn_ord-line.order-qnty
                    TMP#zakaz.other-base            = nbn_ord-line.other-base
                    TMP#zakaz.other-rubl            = nbn_ord-line.other-rubl
                    TMP#zakaz.price-base            = nbn_ord-line.price-base
                    TMP#zakaz.price-cli             = nbn_ord-line.price-cli
                    TMP#zakaz.price-rubl            = nbn_ord-line.price-rubl
                    TMP#zakaz.qnty                  = nbn_ord-line.qnty
                    TMP#zakaz.receive-cli-qnty      = nbn_ord-line.receive-cli-qnty
                    TMP#zakaz.receive-qnty          = nbn_ord-line.receive-qnty
                    TMP#zakaz.road-tax              = nbn_ord-line.road-tax
                    TMP#zakaz.sum-SLT               = nbn_ord-line.sum-SLT
                    TMP#zakaz.sum-VAT               = nbn_ord-line.sum-VAT
                    TMP#zakaz.sum-base              = nbn_ord-line.sum-base
                    TMP#zakaz.sum-cli               = nbn_ord-line.sum-cli
                    TMP#zakaz.sum-excise            = nbn_ord-line.sum-excise
                    TMP#zakaz.sum-other-base        = nbn_ord-line.sum-other-base
                    TMP#zakaz.sum-other-rubl        = nbn_ord-line.sum-other-rubl
                    TMP#zakaz.sum-road-tax          = nbn_ord-line.sum-road-tax
                    TMP#zakaz.sum-rubl              = nbn_ord-line.sum-rubl
                    TMP#zakaz.sum-transport-base    = nbn_ord-line.sum-transport-base
                    TMP#zakaz.sum-transport-rubl    = nbn_ord-line.sum-transport-rubl
                    TMP#zakaz.transport-base        = nbn_ord-line.transport-base
                    TMP#zakaz.transport-rubl        = nbn_ord-line.transport-rubl
                    TMP#zakaz.unit-cli              = nbn_ord-line.unit-cli
                    TMP#zakaz.v-vat                 = nbn_ord-line.v-vat
                .

            run create-dtl-fp in this-procedure
                              ( input loc-ord-num,
                                input "ord-of",
                                input m_ord-line.doc-code,
                                input m_ord-line.artic,
                                input m_ord-line.prod-type,
                                input m_ord-line.prod-code ,
                                input m_ord-line.cli-base-rate ) no-error .
            if error-status :error then do:
               message
                 vss-workfile vss-revision vss-description skip
                 error-status :get-message(1) skip
                 return-value skip
                 "Ошибка create-dtl-fp"
                 view-as alert-box error
               .
            end.
            run ord-detale in this-procedure  no-error .
            if error-status :error then do:
               message
                 vss-workfile vss-revision vss-description skip
                 error-status :get-message(1) skip
                 return-value skip
                 "Ошибка ord-detale"
                 view-as alert-box error
               .
                leave.
            end.
            /* line-mode = "ЦИКЛ":U. */
            line-mode = {&update} .

       if loc-make-avto = false then do:
            assign
              doc-rec = recid (ub.ord-doc)
              r-tmp = recid ( TMP#zakaz   )
              loc-status     = ub.ord-doc.status_
              doc-date       = ub.ord-doc.doc-date
              loc-date-ship  = ub.ord-doc.ship-date
              date-sale-1    = ub.ord-doc.date-sale-1
              date-sale-2    = ub.ord-doc.date-sale-2
              loc-exch-code  = ub.ord-doc.exch-code
              loc-exch-rate  = ub.ord-doc.exch-rate
              loc-exch-scale = ub.ord-doc.exch-scale
              loc-base-rate  = ub.ord-doc.base-rate
              loc-base-scale = ub.ord-doc.base-scale
              vat_type       = ub.ord-doc.vat-type
              slt_type       = ub.ord-doc.slt-type
              loc-cli-code =   ub.ord-doc.cli-code
              loc-cli-type =   ub.ord-doc.cli-type
              loc-ord-num  = ll-d
              .
          find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-doc.doc-code no-error .
          run cus/ord-frm.w
              (input Parparentproc,
               input recid (TMP#zakaz) ,
               input line-mode    ,
               output r-stop      ,
               output r-exit      )
               no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "cus/ord-frm.w"
                  view-as alert-box error
                .
                  return.
              end.
          end.
        end.
    end.
end.
end case.
if ks > 0 then do :
    find first ub.ord-doc  exclusive-lock   where ub.ord-doc.doc-code  = loc-ord-num  .
    ub.ord-doc.sys-time-int = time.
    o-rec = recid(ub.ord-doc) .
    message "Сделан заказ № " loc-ord-num .
    run calc-cons-ord in this-procedure  .
end.
else do:
   find first ub.ord-doc  exclusive-lock   where ub.ord-doc.doc-code  = loc-ord-num  .
   delete ub.ord-doc .
   o-rec = ?.
end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-fp-rcv Dialog-Frame
PROCEDURE make-fp-rcv :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose: генерация поставок ФП  внешних по заказу
-------------------------------------------------------------*/
def input  param l-mod as character no-undo .
def output param o-rec as recid no-undo .
def output param l-rec as recid no-undo .

define variable ks as integer no-undo .
define variable loc-ord-num as character no-undo .
define variable ii as integer no-undo .
define buffer b-goods for ub.goods .
define buffer bfp-ord-doc for ub.ord-doc .
define buffer z-ord-doc   for ub.ord-doc .
define buffer z-ord-line  for ub.ord-line .
define variable doc-code-fp as character no-undo .
define variable doc-code-z as character no-undo .
define variable v-doc-mode as character no-undo .

ks = 0.

{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-ord-num
    }


if caps(l-mod) = "1"  or caps(l-mod) = "4"  then do:

  doc-code-z  = ub.ord-doc.doc-code:screen-value in browse browse-16  .
  doc-code-fp = ub.ord-doc.doc-code:screen-value in browse browse-26  .

  find first ub.ord-doc  where ub.ord-doc.doc-code = doc-code-fp no-lock  no-error .
  if avail ub.ord-doc and  ub.ord-doc.doc-type <> {&f-p}  then do:
     message "Подтвердите по какому заказу ФП будет сформирована поставка " view-as alert-box .
     return.
  end.

  find first bfp-ord-doc no-lock  where bfp-ord-doc.doc-code = ub.ord-doc.doc-code no-error.
  if error-status :error  then return.

  find first z-ord-doc no-lock  where z-ord-doc.doc-code = doc-code-z no-error.
  if error-status :error  then do:
     message "Не выбрана заявка! " view-as alert-box .
     return.
     end.

end.

if caps(l-mod) = "2"  then do:
      if num-entries(del-list) < 1  then do:
        message "Товар в заказе не отмечен '+' !!! " .
        return.
      end.
      find first tt-new-ord-line no-lock  where recid(tt-new-ord-line) = integer(entry(1,del-list))  no-error .
          if error-status :error  then return.

      find first bfp-ord-doc no-lock where bfp-ord-doc.doc-code = tt-new-ord-line.doc-code no-error.
end.

if caps(l-mod) = "3"  then do:

  doc-code-z  = m_ord-line.doc-code:screen-value in browse browse-13  .
  find first z-ord-doc no-lock  where z-ord-doc.doc-code = doc-code-z no-error.
  if error-status :error  then do:
     message "Не выбрана заявка! " view-as alert-box .
     return.
     end.

    find current  tt-new-ord-line  no-lock no-error .
          if not avail tt-new-ord-line or  error-status :error  then do:
          message "Нет заказа по текущему товару !!! "  view-as alert-box information .
          return.
          end.
      find first bfp-ord-doc no-lock  where bfp-ord-doc.doc-code = tt-new-ord-line.doc-code no-error.
end.

if bfp-ord-doc.status_ <> {&ord-rcv}  then do:
     message "Нельзя создать поставку на заказ в статусе " bfp-ord-doc.status_ view-as alert-box .
     return.
   end.

/* Шапка поставки */
run proc-create-rcv-doc in this-procedure
( input bfp-ord-doc.PS
 ,input bfp-ord-doc.base-rate
 ,input bfp-ord-doc.base-scale
 ,input bfp-ord-doc.cli-code
 ,input bfp-ord-doc.cli-type
 ,input bfp-ord-doc.cons-code
 ,input v-cntxt-userid
 ,input bfp-ord-doc.cycle-day
 ,input bfp-ord-doc.date-pay
 ,input bfp-ord-doc.doc-code
 ,input to-day
 ,input {&l-out}
 ,input bfp-ord-doc.exch-code
 ,input bfp-ord-doc.exch-date
 ,input bfp-ord-doc.exch-rate
 ,input bfp-ord-doc.exch-scale
 ,input bfp-ord-doc.fact-date
 ,input bfp-ord-doc.fact-num
 ,input bfp-ord-doc.fact-order
 ,input 0
 ,input bfp-ord-doc.fact-time
 ,input bfp-ord-doc.flag_
 ,input bfp-ord-doc.host-code
 ,input ( if avail z-ord-doc then z-ord-doc.obj-code else 0   )
 ,input ( if avail z-ord-doc then  z-ord-doc.obj-type else "" )
 ,input bfp-ord-doc.order-type
 ,input loc-ord-num
 ,input bfp-ord-doc.shift-date
 ,input bfp-ord-doc.shift-num
 ,input bfp-ord-doc.shift-name
 ,input bfp-ord-doc.ship-date
 ,input bfp-ord-doc.ship-time
 ,input {&g___new}
 ,input bfp-ord-doc.sum-service
 ,input bfp-ord-doc.sum-ship
 ,input bfp-ord-doc.sys-date
 ,input bfp-ord-doc.sys-time-int
 ,input bfp-ord-doc.sys-time
 ,input bfp-ord-doc.tot-lines
 ,input ""
 ,input bfp-ord-doc.user-db-num
 ,input bfp-ord-doc.user-name
 ).

v-doc-mode = {&add-def}.
x-make-avto = 2 .
  run cus/or-obj.w
  (       input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  {&update}
        , input  {&update}
        , input-output  v-doc-mode  ) .


  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .


if v-doc-mode = "cancel":U then do:
    find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num  no-error .
    delete ub.ord-doc-rcv.
   return.
 end.

if caps(l-mod) = "1"  then do:
   for each tt-new-ord-line no-lock where tt-new-ord-line.doc-code = bfp-ord-doc.doc-code :

        find first b-goods no-lock   where
                  tt-new-ord-line.artic    = b-goods.artic     and
                  tt-new-ord-line.prod-type = b-goods.prod-type and
                  tt-new-ord-line.prod-code = b-goods.prod-code no-error .
        if available b-goods  and
          not can-find ( first  tt-ord-gds where tt-ord-gds.gds-code = b-goods.gds-code no-lock )
          then do:
            create tt-ord-gds .
            buffer-copy b-goods to tt-ord-gds .
            end.

        ks = ks + 1 .
        run create-line-rcv in this-procedure
           ( input loc-ord-num ,
             input recid (tt-new-ord-line),
             input ? ,
             input  ks ,
             output l-rec) no-error .
        if error-status :error then leave.
    end.

end.

if caps(l-mod) = "2"  then do:
define variable v-nn as integer   no-undo .
v-nn = num-entries(del-list) .
    do ii = 1 to v-nn :
        find first tt-new-ord-line no-lock  where recid(tt-new-ord-line) = integer(entry(ii,del-list)) no-error .
        if available tt-new-ord-line then
        find first b-goods no-lock where tt-new-ord-line.artic     = b-goods.artic and
                                tt-new-ord-line.prod-type = b-goods.prod-type and
                                tt-new-ord-line.prod-code = b-goods.prod-code no-error .
        if available b-goods  and
          not can-find ( first  tt-ord-gds where tt-ord-gds.gds-code = b-goods.gds-code no-lock )
          then do:
            create tt-ord-gds .
            buffer-copy b-goods to tt-ord-gds .
            end.

        ks = ks + 1 .
        run create-line-rcv in this-procedure ( input loc-ord-num , recid(tt-new-ord-line),  ? ,input  ks , output l-rec) no-error .
        if error-status :error then leave.
    end.
end.

if caps(l-mod) = "3"  then do:
        if available tt-new-ord-line then
        find first b-goods no-lock  where tt-new-ord-line.artic     = b-goods.artic and
                                tt-new-ord-line.prod-type = b-goods.prod-type and
                                tt-new-ord-line.prod-code = b-goods.prod-code no-error .
        if available b-goods  and
          not can-find ( first  tt-ord-gds where tt-ord-gds.gds-code = b-goods.gds-code no-lock )
          then do:
            create tt-ord-gds .
            buffer-copy b-goods to tt-ord-gds .
            end.

        ks = ks + 1 .
        run create-line-rcv in this-procedure ( input loc-ord-num , recid(tt-new-ord-line),  ? ,input  ks , output l-rec) no-error .
end.
if caps(l-mod) = "4"  then do:
   for each tt-new-ord-line no-lock where tt-new-ord-line.doc-code = bfp-ord-doc.doc-code :
        find first z-ord-line no-lock where
                              z-ord-line.doc-code  = doc-code-z  and
                              z-ord-line.artic     = tt-new-ord-line.artic  and
                              z-ord-line.prod-type = tt-new-ord-line.prod-type  and
                              z-ord-line.prod-code = tt-new-ord-line.prod-code
                              no-error .
          if available z-ord-line then do :
              if not  can-find ( first  tt-ord-gds where
                                        tt-ord-gds.artic     = z-ord-line.artic      and
                                        tt-ord-gds.prod-type = z-ord-line.prod-type  and
                                        tt-ord-gds.prod-code = z-ord-line.prod-code  no-lock )
              then do:
                  find first b-goods no-lock where z-ord-line.artic     = b-goods.artic and
                                          z-ord-line.prod-type = b-goods.prod-type and
                                          z-ord-line.prod-code = b-goods.prod-code no-error .
                  create tt-ord-gds .
                  buffer-copy b-goods to tt-ord-gds .
                  end.
              ks = ks + 1 .
              run create-line-rcv in this-procedure ( input loc-ord-num , recid(tt-new-ord-line), recid(z-ord-doc) , input  ks , output l-rec) no-error .
              if error-status :error then leave .
          end.
   end.
end.

/* перепроверяем кол-во */
ks = 0  .
for each ub.ord-line-rcv where  ub.ord-line-rcv.rcv-code =   loc-ord-num no-lock :
  ks = ks + 1.
  leave.
end.

if ks > 0 then do:
    o-rec = recid(ub.ord-doc-rcv).
    message "Сделана поставка № " loc-ord-num.
    run calc-cons-ord in this-procedure .
   end.
 else do:
   find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num .
   delete ub.ord-doc-rcv .
   o-rec = ?.
   l-rec = ?.
end.

for each tt-ord-gds :
 delete tt-ord-gds.
end.

del-list = '' .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-post-in Dialog-Frame
PROCEDURE make-post-in :
def output param o-rec  as recid no-undo.
def output param l-rec  as recid no-undo.

do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose: генерация поставок первичных и вторичных in
-------------------------------------------------------------*/


define variable ks as integer no-undo .
define variable loc-ord-num as character no-undo .
define variable ii as integer no-undo .
define buffer b-goods for ub.goods .
define buffer bfp-ord-doc for ub.ord-doc .  /* заявки */


find current ub.ord-doc no-lock no-error .
if not available  ub.ord-doc then do:
   message "Не выбрана заявка !!! " .
   return.
end.
if  ub.ord-doc.doc-type <> {&o-f} then do:
   message "Не выбрана ЗАЯВКА !!! " .
   return.
end.

find current my-obj no-lock no-error .
if not available my-obj then do:
   message "Не выбран объект !!! " .
   return.
end.

/* заявка */
find first bfp-ord-doc no-lock  where bfp-ord-doc.doc-code = ub.ord-doc.doc-code no-error.
     if error-status :error  then return.

ks = 0.
{ cus/ord-code.i
  'main'
  v-cntxt-db-num
  v-cntxt-obj-type
  v-cntxt-obj-code
  v-i-doc
  loc-ord-num
  }


/* Шапка поставки */
   create ub.ord-doc-rcv.
   BUFFER-COPY bfp-ord-doc to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-code  = ""
      ub.ord-doc-rcv.cli-code  = my-obj.obj-code
      ub.ord-doc-rcv.cli-type  = my-obj.obj-type
      ub.ord-doc-rcv.obj-code  = bfp-ord-doc.obj-code
      ub.ord-doc-rcv.obj-type  = bfp-ord-doc.obj-type
      ub.ord-doc-rcv.host-code = bfp-ord-doc.host-code
      ub.ord-doc-rcv.cons-code = loc-ord-cons-code
      ub.ord-doc-rcv.doc-type  = "in":U
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.status_   = {&g___new}
   .

define variable v-doc-mode as character no-undo .
v-doc-mode = {&add-def}.
   o-rec = recid(ord-doc-rcv).
   x-make-avto = 2 .
  run cus/or-obj.w
      (   input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  {&update}
        , input  {&update}
        , input-output  v-doc-mode  ) .

  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .

if v-doc-mode = "cancel":U then do:
    find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num  no-error .
    delete ub.ord-doc-rcv.
   return.
 end.

 for each m_ord-line no-lock  where
          m_ord-line.doc-code   = bfp-ord-doc.doc-code
          :
    find first b-goods no-lock  where
                m_ord-line.artic     = b-goods.artic     and
                m_ord-line.prod-type = b-goods.prod-type and
                m_ord-line.prod-code = b-goods.prod-code
                no-error .
     find first ub.gds-obj no-lock  where
                ub.gds-obj.obj-code    = my-obj.obj-code and
                ub.gds-obj.obj-type    = my-obj.obj-type and
                ub.gds-obj.artic       = b-goods.artic   and
                ub.gds-obj.prod-code   = b-goods.prod-code and
                ub.gds-obj.prod-code   = b-goods.prod-code
                no-error .

       if avail ub.gds-obj then do:
          ks = ks + 1 .
          run create-line-rcv-in in this-procedure
          ( input loc-ord-num ,
            recid(m_ord-line),
            input  ks ,
            input ub.gds-obj.fact-qnty ,
            output l-rec
            ) no-error .
          if error-status :error then leave.
       end.
       if not avail ub.gds-obj then do:
          message "Товара "skip
          b-goods.artic      skip
          b-goods.prod-type  skip
          b-goods.prod-code  skip
          "нет на объекте " skip
          my-obj.obj-code    skip
          my-obj.obj-type skip
          skip
          "Делать поставку ? " update g#log view-as alert-box question buttons yes-no.
          if g#log = true then do:
              ks = ks + 1 .
              run create-line-rcv-in  in this-procedure ( input loc-ord-num , recid(m_ord-line), input  ks , input 0 , output l-rec ) no-error .
              if error-status :error then leave.
          end.
       end.

 end.

/* перепроверяем кол-во */
ks = 0 .
for each ub.ord-line-rcv where  ub.ord-line-rcv.rcv-code =   loc-ord-num no-lock :
  ks = ks + 1.
  leave.
end.


if ks > 0 then do:
    l-rec = recid(m_ord-line).
    message "Поставка № " loc-ord-num " сделана"  .
    run calc-cons-ord in this-procedure .
   end.
 else do:
   find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num .
   delete ub.ord-doc-rcv .
   o-rec = ?.
   l-rec = ?.
end.


end.
END PROCEDURE.

PROCEDURE make-post-gds-in :
 do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose: генерация поставок первичных и вторичных по tt-goods
-------------------------------------------------------------*/
define input parameter l-mod as integer no-undo .
def output param o-rec  as recid no-undo.
def output param l-rec  as recid no-undo.

define variable ks as integer no-undo .
define variable loc-ord-num as character no-undo .

define variable m-obj-code like ub.clients.obj-code no-undo .
define variable m-obj-type like ub.clients.obj-type no-undo .
define buffer mm_ord-doc  for ub.ord-doc  .
define buffer mm_ord-line for ub.ord-line  .

{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-ord-num
    }

for each temp-ttt :
   delete temp-ttt.
end.

ks = 0.
if l-mod = 1 then do:
    find current tt-goods  no-error.
      if  avail tt-goods then  do:
          ks = ks + 1.
          create temp-ttt.
          assign temp-ttt.p-recid = recid(tt-goods) .
        end.
        else do:
              message "Товар не выбран !!! "  view-as alert-box  .
              return.
              end.
 end.

if l-mod = 2 then do:
    for each tt-goods no-lock  where tt-goods.use = true :
        ks = ks + 1.
          create temp-ttt.
          assign temp-ttt.p-recid = recid(tt-goods) .
    end.
end.

if ks <= 0 then do:
  message "Товар не выбран !!! "  view-as alert-box  .
  return.
end.


if frame FRAME-D:visible then do:
   apply "VALUE-CHANGED":U to browse-13 in frame frame-d.
end.

    find current m_ord-line no-lock no-error .
    if not available  m_ord-line  then do:
      message "Не выбрана заявка !!! " .
      return.
    end.
 find first mm_ord-doc where mm_ord-doc.doc-code = m_ord-line.doc-code no-lock no-error .

    assign
        m-obj-code = mm_ord-doc.obj-code
        m-obj-type = mm_ord-doc.obj-type
        .


find current my-obj no-lock no-error .
if not available  my-obj then do:
   message "Не выбран объект !!! " .
   return.
end.

/* Шапка поставки */
   create ub.ord-doc-rcv.
   BUFFER-COPY mm_ord-doc to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-code  = ""
      ub.ord-doc-rcv.cli-code  = my-obj.obj-code
      ub.ord-doc-rcv.cli-type  = my-obj.obj-type
      ub.ord-doc-rcv.obj-code  = m-obj-code
      ub.ord-doc-rcv.obj-type  = m-obj-type
      ub.ord-doc-rcv.host-code = g#host-code
      ub.ord-doc-rcv.cons-code = loc-ord-cons-code
      ub.ord-doc-rcv.doc-type  = "in":U
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.status_   = {&g___new}
   .
define variable v-doc-mode as character no-undo .
v-doc-mode = {&add-def}.
x-make-avto = 2 .
  run cus/or-obj.w
        ( input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  {&update}
        , input  {&update}
        , input-output  v-doc-mode  ) .


  case x-make-avto :
    when 1 then loc-make-avto = true  .
    when 4 then loc-make-avto = true  .
    when 2 then loc-make-avto = false  .
    when 3 then loc-make-avto = ? .
  end case .

ks = 0.
if v-doc-mode = "cancel":U then do:
    find first ub.ord-doc-rcv  exclusive-lock    where ub.ord-doc-rcv.rcv-code  = loc-ord-num no-error .
    delete ub.ord-doc-rcv.
   return.
end.
 for each temp-ttt   :
    find first  tt-goods no-lock  where recid(tt-goods) = temp-ttt.p-recid no-error .
    find first  ub.gds-obj  no-lock  where
                ub.gds-obj.obj-code  = my-obj.obj-code and
                ub.gds-obj.obj-type  = my-obj.obj-type and
                ub.gds-obj.artic     = tt-goods.artic   and
                ub.gds-obj.prod-code = tt-goods.prod-code and
                ub.gds-obj.prod-code = tt-goods.prod-code
                no-error .
   find first mm_ord-line no-lock where
                  mm_ord-line.doc-code  = mm_ord-doc.doc-code and
                  mm_ord-line.artic     = tt-goods.artic      and
                  mm_ord-line.prod-code = tt-goods.prod-code  and
                  mm_ord-line.prod-code = tt-goods.prod-code
                  no-error .

       if not avail  mm_ord-line then do :
          message "Товара "skip
              tt-goods.artic      skip
              tt-goods.prod-type  skip
              tt-goods.prod-code  skip
              "не требуется по заявке "  mm_ord-doc.doc-code skip
              "Пропускаем его " view-as alert-box .
              next.
       end.

       if available ub.gds-obj then do:
          ks = ks + 1 .
          run create-line-rcv-in in this-procedure ( input loc-ord-num , recid(mm_ord-line), input  ks , input ub.gds-obj.fact-qnty , output l-rec ).
       end.
       if not avail ub.gds-obj then do:
          message "Товара "skip
          tt-goods.artic      skip
          tt-goods.prod-type  skip
          tt-goods.prod-code  skip
          "нет на объекте " skip
          my-obj.obj-code    skip
          my-obj.obj-type skip
          skip
          "Делать поставку ? " update g#log view-as alert-box question buttons yes-no.
          if g#log = true then do:
              ks = ks + 1 .
              run create-line-rcv-in in this-procedure (input loc-ord-num , recid(mm_ord-line), input  ks , input 0 , output l-rec ).
          end.
       end.
 end.

if ks > 0 then do:
    l-rec = recid(m_ord-line).
    message "Поставка № " loc-ord-num " сделана"  .
    run calc-cons-ord in this-procedure .
   end.
 else do:
   find first ub.ord-doc-rcv  exclusive-lock   where ub.ord-doc-rcv.rcv-code  = loc-ord-num  .
   delete ub.ord-doc-rcv .
   o-rec = ?.
   l-rec = ?.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-trn Dialog-Frame
PROCEDURE make-trn :
do
 on error undo, return error return-value
 :

define input parameter tp-rec as recid no-undo .
    run cus/ord-trn.p
    ( parParentProc ,
      input tp-rec ,
      input no
      ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE new-zayvka Dialog-Frame
PROCEDURE new-zayvka :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:   добавление в совокупный заказ новой оф
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define buffer bb_ord-doc for ub.ord-doc.
define buffer bb_ord-line for ub.ord-line.
define buffer bb_ord-gds-cons for ub.ord-gds-cons.
define variable ii as integer no-undo .
define variable s-del-list as char no-undo.
define variable t-ret as logical no-undo .
define variable t-rec as recid no-undo .
define variable loc-gds-code like ub.goods.gds-code no-undo .

run ref/all-zakz.w
   ( input   parParentProc
    ,input   {&o-f}
    ,input   ?
    ,input   "firm"
    ,input   p-cons-code
    ,input   "b-sel,b-mark,b-lkp,nob-exec,nob-copy"
    ,input   ""
    ,output  s-del-list ) .


t-ret =  session:SET-WAIT-STATE("GENERAL") .
ii = 0 .
define variable v-nn as integer   no-undo .
v-nn = num-entries(s-del-list).
 DO ii = 1  to v-nn :
    find first bb_ord-doc  exclusive-lock   where recid(bb_ord-doc) = integer(entry(ii,s-del-list))  no-error .
    if available bb_ord-doc then do:
    {&for-each-line}
    end.
 end.

 if ii = 0 or v-nn = 0  then do:
     DO ii = 1  to 1 :
     ii = 1 .
     find first bb_ord-doc  exclusive-lock   where recid(bb_ord-doc) = doc-rec no-error .
     if available bb_ord-doc then do:
    {&for-each-line}
     end.
    end.
 end.

 run init-proc in this-procedure .
{&OPEN-QUERY-BROWSE-12}
{&OPEN-QUERY-BROWSE-16}
 run calc-cons-ord in this-procedure .
 t-ret =  session:SET-WAIT-STATE("") .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ord-detale Dialog-Frame
PROCEDURE ord-detale :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define variable  r-tmp as recid   no-undo .
 define variable r-stop as logical no-undo .
 define variable r-exit as logical no-undo .
 define variable ii as integer no-undo .
 find current ub.ord-line no-lock no-error .
  if avail ub.ord-line then do:
     find first  tmp#zakaz where
            TMP#zakaz.artic                 = ub.ord-line.artic and
            TMP#zakaz.prod-code             = ub.ord-line.prod-code and
            TMP#zakaz.prod-type             = ub.ord-line.prod-type no-error .
      if not available Tmp#zakaz then do:
          create TMP#zakaz.
          end.
      assign
        TMP#zakaz.SLT-pc                = ub.ord-line.SLT-pc
        TMP#zakaz.VAT-pc                = ub.ord-line.VAT-pc
        TMP#zakaz.add-cli-qnty          = ub.ord-line.add-cli-qnty
        TMP#zakaz.add-qnty              = ub.ord-line.add-qnty
        TMP#zakaz.artic                 = ub.ord-line.artic
        TMP#zakaz.cancel-cli-qnty       = ub.ord-line.cancel-cli-qnty
        TMP#zakaz.cancel-date           = ub.ord-line.cancel-date
        TMP#zakaz.cancel-qnty           = ub.ord-line.cancel-qnty
        TMP#zakaz.cli-art               = ub.ord-line.cli-art
        TMP#zakaz.cli-base-rate         = ub.ord-line.cli-base-rate
        TMP#zakaz.cli-qnty              = ub.ord-line.cli-qnty
        TMP#zakaz.doc-code              = ub.ord-line.doc-code
        TMP#zakaz.excise                = ub.ord-line.excise
        TMP#zakaz.fact-date             = ub.ord-line.fact-date
        TMP#zakaz.initial-cli-qnty      = ub.ord-line.initial-cli-qnty
        TMP#zakaz.initial-qnty          = ub.ord-line.initial-qnty
        TMP#zakaz.line-num              = ub.ord-line.line-num
        TMP#zakaz.order-cli-qnty        = ub.ord-line.order-cli-qnty
        TMP#zakaz.order-qnty            = ub.ord-line.order-qnty
        TMP#zakaz.other-base            = ub.ord-line.other-base
        TMP#zakaz.other-rubl            = ub.ord-line.other-rubl
        TMP#zakaz.price-base            = ub.ord-line.price-base
        TMP#zakaz.price-cli             = ub.ord-line.price-cli
        TMP#zakaz.price-rubl            = ub.ord-line.price-rubl
        TMP#zakaz.prod-code             = ub.ord-line.prod-code
        TMP#zakaz.prod-type             = ub.ord-line.prod-type
        TMP#zakaz.qnty                  = ub.ord-line.qnty
        TMP#zakaz.receive-cli-qnty      = ub.ord-line.receive-cli-qnty
        TMP#zakaz.receive-qnty          = ub.ord-line.receive-qnty
        TMP#zakaz.road-tax              = ub.ord-line.road-tax
        TMP#zakaz.sum-SLT               = ub.ord-line.sum-SLT
        TMP#zakaz.sum-VAT               = ub.ord-line.sum-VAT
        TMP#zakaz.sum-base              = ub.ord-line.sum-base
        TMP#zakaz.sum-cli               = ub.ord-line.sum-cli
        TMP#zakaz.sum-excise            = ub.ord-line.sum-excise
        TMP#zakaz.sum-other-base        = ub.ord-line.sum-other-base
        TMP#zakaz.sum-other-rubl        = ub.ord-line.sum-other-rubl
        TMP#zakaz.sum-road-tax          = ub.ord-line.sum-road-tax
        TMP#zakaz.sum-rubl              = ub.ord-line.sum-rubl
        TMP#zakaz.sum-transport-base    = ub.ord-line.sum-transport-base
        TMP#zakaz.sum-transport-rubl    = ub.ord-line.sum-transport-rubl
        TMP#zakaz.transport-base        = ub.ord-line.transport-base
        TMP#zakaz.transport-rubl        = ub.ord-line.transport-rubl
        TMP#zakaz.unit-cli              = ub.ord-line.unit-cli
        TMP#zakaz.v-vat                 = ub.ord-line.v-vat
    .

    find current TMP#zakaz no-error .
    find first ub.ord-doc no-lock  where ub.ord-doc.doc-code = ub.ord-line.doc-code no-error .
    find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-line.doc-code no-error .
    assign
      /* line-mode = {&update} */
      line-mode = "ЦИКЛ":U
      r-tmp = recid ( TMP#zakaz   )
      loc-status     = ub.ord-doc.status_
      doc-date       = ub.ord-doc.doc-date
      loc-date-ship  = ub.ord-doc.ship-date
      date-sale-1    = ub.ord-doc.date-sale-1
      date-sale-2    = ub.ord-doc.date-sale-2
      loc-exch-code  = ub.ord-doc.exch-code
      loc-exch-rate  = ub.ord-doc.exch-rate
      loc-exch-scale = ub.ord-doc.exch-scale
      loc-base-rate  = ub.ord-doc.base-rate
      loc-base-scale = ub.ord-doc.base-scale
      vat_type       = ub.ord-doc.vat-type
      slt_type       = ub.ord-doc.slt-type
      loc-cli-code   = ub.ord-doc.cli-code
      loc-cli-type   = ub.ord-doc.cli-type
      loc-ord-num    = ub.ord-doc.doc-code
      .
    find first shar_ord-doc no-lock  where shar_ord-doc.doc-code = ord-doc.doc-code no-error .
    if loc-make-avto = false then do:
       run cus/ord-frm.w (input Parparentproc  , input r-tmp , input line-mode , output r-stop, output r-exit ) .
    end.
    if r-stop = true  then do:
        run p-delete in this-procedure ( r-tmp ,input-output ii ) .
        return error.
    end.
    if r-exit = true  then do:
        run p-delete in this-procedure ( r-tmp ,input-output ii ) .
    end.
    if r-stop = false and r-exit = false  then do:
        find current ub.ord-line  exclusive-lock  no-error .
        BUFFER-COPY   TMP#zakaz to ub.ord-line.
    end.
end.
else do:
  /* message 1 "Не выбрана строка заказа !" view-as alert-box . */
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ord-header Dialog-Frame
PROCEDURE ord-header :
do
 on error undo, return error return-value
 :
find first shar-buf_ord-doc no-lock   where shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code no-error  .
    run cus/ord-zakz.p
    (     INPUT   PARPARENTPROC ,
          INPUT   {&update}      ,
          input   shar-buf_ord-doc.doc-type,
          OUTPUT  DOC-REC ,
          input-output  br-handle ,
          input-output  bf-handle ,
          input-output  next-prev

          ) .

end.
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
 on error undo, return error return-value
 :
    define input parameter tmp-recid as recid no-undo .
    define input-output parameter ii as integer no-undo . .
    define buffer buf_doc-line for ub.ord-line .
    find first tmp#zakaz where recid(tmp#zakaz) = tmp-recid no-error .
    if not avail tmp#zakaz then return error.

    find first buf_doc-line  exclusive-lock    where
        buf_doc-line.doc-code        = loc-ord-num    and
        buf_doc-line.prod-type       = tmp#zakaz.prod-type and
        buf_doc-line.prod-code       = tmp#zakaz.prod-code and
        buf_doc-line.artic           = tmp#zakaz.artic     no-error.
    if not available buf_doc-line  then  return error .
    delete buf_doc-line .
    delete tmp#zakaz .
    ii = ii - 1 .

 end. /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-mark Dialog-Frame
PROCEDURE p-mark :
do
 on error undo, return error return-value
 :

find current tt-goods no-error .
find current ub.ord-gds-cons no-error .
if not available tt-goods then do:
     message "Неправильный выбор строки.".
     return no-apply.
     end.

    IF    tt-goods.use = true THEN DO:
          tt-goods.use = false.
          disp "" @ tt-goods.use with browse browse-12.
      End.
      Else DO:
           tt-goods.use = true.
           disp "+" @ tt-goods.use with browse browse-12.
      End.

     apply "VALUE-CHANGED" to browse-12 in frame frame-A.
     gg-recid = recid(tt-goods) .
     g#log = browse-12:select-next-row ().

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE plus-mark Dialog-Frame
PROCEDURE plus-mark :
do
 on error undo, return error return-value
 :

define variable  pp-rec as recid no-undo .
pp-rec = recid (tt-goods) .
for each tt-goods  exclusive-lock  :
   tt-goods.use = true.
end.
{&OPEN-QUERY-BROWSE-12}
reposition BROWSE-12 to recid pp-rec no-error .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post-1 Dialog-Frame
PROCEDURE post-1 :
do
 on error undo, return error return-value
 :

/* генерация поставок от поставщика по всему заказу  */
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.

  run make-fp-rcv in this-procedure ( input "1" ,output o-rec, output l-rec) .
  {&OPEN-QUERY-BROWSE-27}
  reposition BROWSE-27 to recid o-rec  no-error .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post-2 Dialog-Frame
PROCEDURE post-2 :
do
 on error undo, return error return-value
 :

/* генерация поставок от поставщика */
  if not t-gds then do:
      message "Создание по (+) возможно только в режиме 'развернуть'. "
              "Воидете в режим ПО ДОКУМЕНТАМ и включите переключатель РАЗВЕРНУТЬ ." view-as alert-box .
      return .
  end.

  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.
  run make-fp-rcv in this-procedure ( input "2", output o-rec, output l-rec) .
  {&OPEN-QUERY-BROWSE-18}
  reposition BROWSE-18 to recid l-rec no-error.
  {&OPEN-QUERY-BROWSE-28}
end.
END PROCEDURE.


PROCEDURE post-3 :
 do
 on error undo, return error return-value
 :

 if t-gds then do:
    message "Нельзя внутри развернутого заказа делать поставку по текущему товару ."
            "Перейдите в режим ПО ТОВАРАМ ."
            view-as alert-box information .
    return.
 end.
/* генерация поставок от поставщика */
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.
  run make-fp-rcv in this-procedure ( input "3", output o-rec, output l-rec) .
  {&OPEN-QUERY-BROWSE-18}
  reposition BROWSE-18 to recid l-rec no-error.
  {&OPEN-QUERY-BROWSE-28}

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post-4 Dialog-Frame
PROCEDURE post-4 :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose: Создание поставки внутренней
------------------------------------------------------------------------------*/
define variable  o-rec as recid no-undo.
define variable  l-rec as recid no-undo.

run make-post-in in this-procedure ( output o-rec , output l-rec) .
    {&OPEN-QUERY-BROWSE-23}
    .
    reposition BROWSE-23 to recid o-rec no-error.
end.
END PROCEDURE.

PROCEDURE post-4-gds :
 do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose: Создание поставки внутренней
------------------------------------------------------------------------------*/
define input parameter l-mod as character no-undo .
define variable  o-rec as recid no-undo.
define variable  l-rec as recid no-undo.
if caps(l-mod) = "M_H_0" then
   run make-post-gds-in in this-procedure ( 1, output o-rec , output l-rec ) .
 else
   run make-post-gds-in in this-procedure ( 2, output o-rec , output l-rec ) .

   {&OPEN-QUERY-BROWSE-20}
   reposition BROWSE-20 to recid l-rec no-error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post-5 Dialog-Frame
PROCEDURE post-5 :
do
 on error undo, return error return-value
 :

/* генерация поставок от поставщика по всему заказу  */
  define variable  o-rec as recid no-undo.
  define variable  l-rec as recid no-undo.

  run make-fp-rcv in this-procedure ( input "4" ,output o-rec, output l-rec).
  {&OPEN-QUERY-BROWSE-27}
  reposition BROWSE-27 to recid o-rec no-error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pr-main Dialog-Frame
PROCEDURE pr-main :
do
 on error undo, return error return-value
 :

define variable p-recid as recid no-undo .
define buffer l_tt-goods for tt-goods .

p-recid =  ? .
assign frame dialog-frame  r-main .

find first l_tt-goods where
  l_tt-goods.artic = x-artic and
  l_tt-goods.prod-type = x-prod-type and
  l_tt-goods.prod-code = x-prod-code and
  l_tt-goods.gds-t     = {&h-goods} no-error .
  if avail   l_tt-goods then   p-recid = recid(l_tt-goods).
case r-main :
when 1 then
 do:
   t-prt = false.
   T-of = true.
   run proc-prt in this-procedure .
   run proc-t-of in this-procedure .
   reposition browse-12 to recid p-recid no-error .
   run br-12 in this-procedure .
 end.
when 2 then
   do:
     T-of = false.
     t-prt = false.
     run proc-prt in this-procedure .
     run proc-t-of in this-procedure .
     reposition browse-12 to recid p-recid no-error  .
     run br-12 in this-procedure .
   end.
when 3 then
   do:
      t-prt = true.
      T-of  = false.
      run proc-t-of in this-procedure .
      run proc-prt in this-procedure .
      reposition browse-30 to recid p-recid no-error  .
      run br-12 in this-procedure .
   end.
end case.
/* display str-good with frame Dialog-Frame. */
frame frame-d:MOVE-TO-BOTTOM ( )  .
frame frame-f:MOVE-TO-BOTTOM ( )  .

frame frame-a:MOVE-TO-TOP ( )  .
frame frame-a:TOP-ONLY  .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-50 Dialog-Frame
PROCEDURE proc-50 :
do
 on error undo, return error return-value
 :

define variable ll-rec as recid no-undo .
define variable v-doc-mode as character no-undo .

  find current ub.ord-line-rcv no-lock  no-error .
  find current new-rcv no-lock  no-error .
  if avail  new-rcv then do:
     ll-rec = recid ( new-rcv ) .
     if  new-rcv.status_ = {&g___new} then do:
          run cus/or-obj.w
                ( input  parParentProc
                , input  g#host-code
                , input  recid(new-rcv)
                , input  3
                , input  {&update}
                , input  {&update}
                , input-output  v-doc-mode  ) .

          g#log = BROWSE-21:refresh() in frame frame-postavki  no-error .
          run calc-cons-ord in this-procedure .
     end.
     else do:
        if new-rcv.status_ = {&ord-accept}
            then
                message "Статус поставки " new-rcv.status_ ". Корректировать нельзя ."
                "Для проставления времени фактической доставки используйте другие режимы ! "
                view-as alert-box .
            else  message "Статус поставки " new-rcv.status_ ". Корректировать нельзя !  "
                  view-as alert-box .
     end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-52 Dialog-Frame
PROCEDURE proc-52 :
do
 on error undo, return error return-value
 :
 define variable v-recid as recid no-undo .
  find current ub.ord-line-rcv no-lock  no-error .
  if avail ub.ord-doc-rcv  then do:
     v-recid = recid(ub.ord-doc-rcv) .
     run cus/lkp-rcv.w ( parParentProc, input-output v-recid) .
  end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-522 Dialog-Frame
PROCEDURE proc-522 :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-recid as recid no-undo .
  find current new-rcv no-lock  no-error .
  if avail new-rcv then do :
     v-recid = recid(new-rcv) .
     run cus/lkp-rcv.w ( parParentProc, input-output v-recid ) .
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-14 Dialog-Frame
PROCEDURE proc-b-14 :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable d-rec as recid no-undo.
if avail  ub.doc-line then do:
  g#log = no.
  message "Удалить строку в накладной №" ub.doc-line.doc-code "?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update g#log.
    if g#log = false then return.
    d-rec = recid (doc-line).
    run del-nacl in this-procedure (d-rec).
    {&OPEN-QUERY-BROWSE-15}
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-20 Dialog-Frame
PROCEDURE proc-b-20 :
do
 on error undo, return error return-value
 :

define variable d-rec as recid no-undo.
if avail  ub.trn-doc then do:
  g#log = no.
  message "Удалить накладную №" ub.trn-doc.doc-code "?   Вы уверены ?"
  view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.
  if avail  ub.trn-doc then do:
  d-rec = recid (trn-doc).
  run del-nacl-doc in this-procedure (d-rec).
  {&OPEN-QUERY-BROWSE-24}
end.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-31 Dialog-Frame
PROCEDURE proc-b-31 :
do
 on error undo, return error return-value
 :

define variable d-rec as recid no-undo.
g#log = no.
find current ub.ord-doc-rcv no-lock no-error .
if avail  ub.ord-doc-rcv then do:
  message "Удалить поставку №" ub.ord-doc-rcv.rcv-code "?   Вы уверены ?"
  view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.
  d-rec = recid (ub.ord-doc-rcv).
  run del-post-doc in this-procedure (d-rec).
  {&OPEN-QUERY-BROWSE-27}
  end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-51 Dialog-Frame
PROCEDURE proc-b-51 :
do
 on error undo, return error return-value
 :
if not available ub.trn-doc then return .
  g#log = no.
  message "Удалить накладную №" ub.trn-doc.doc-code "?   Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update g#log.
        if g#log = false then return.

  find first  ub.ord-chain exclusive-lock where
        ub.ord-chain.rel-doc-code = ub.trn-doc.doc-code and
        ub.ord-chain.doc-type = 'rcv'                and
        ub.ord-chain.rel-doc-type = 'trn'
  no-error .
  if available ub.ord-chain then delete ub.ord-chain .
  run del-nacl-doc in this-procedure ( recid (trn-doc) ).
  {&OPEN-QUERY-BROWSE-22}
  {&OPEN-QUERY-BROWSE-21}

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-54 Dialog-Frame
PROCEDURE proc-b-54 :
do
 on error undo, return error return-value
 :
 define variable v-recid as recid no-undo .

 if avail  ub.ord-doc-rcv then do:
     v-recid =  recid(ub.ord-doc-rcv) .
     run cus/lkp-rcv.w ( parParentProc, input-output v-recid ) .
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-56 Dialog-Frame
PROCEDURE proc-b-56 :
do
 on error undo, return error return-value
 :
 define variable v-doc-mode as character no-undo .

  if avail  ub.ord-line-rcv then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  {&update}
             , input  {&lookup}
             , input-output  v-doc-mode  ) .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-58 Dialog-Frame
PROCEDURE proc-b-58 :
do
 on error undo, return error return-value
 :
define variable v-doc-mode as character no-undo .
define variable ll-rec as recid no-undo .

find current ub.ord-line-rcv no-lock  no-error .

    if available ub.ord-line-rcv  then do:
     ll-rec = recid(ord-line-rcv) .
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  {&update}
             , input  {&lookup}
             , input-output  v-doc-mode  ) .

     end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-7 Dialog-Frame
PROCEDURE proc-b-7 :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
define variable ll-rec as recid no-undo .
define variable v-doc-mode as character no-undo .
  find current ub.ord-line-rcv no-lock  no-error .
    if avail  ub.ord-line-rcv then do:
     find first buf_ord-doc-rcv no-lock where
                buf_ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code and
                buf_ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code no-error .

     if buf_ord-doc-rcv.status_ <> {&g___new}   then do:
        message "Нельзя корректировать поставку в статусе " caps(buf_ord-doc-rcv.status_) view-as alert-box information .
        return.
     end.
     ll-rec = recid(b-all_ord-doc-rcv) .
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ord-line-rcv)
             , input  2
             , input  {&update}
             , input  {&update}
             , input-output  v-doc-mode  ) .

     g#log = BROWSE-20:refresh() in frame frame-h  no-error .
     run calc-cons-ord in this-procedure .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ins-za Dialog-Frame
PROCEDURE proc-b-ins-za :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

for each tt-goods :
  delete tt-goods.
end.
for each my-obj :
  delete my-obj.
end.
run new-zayvka in this-procedure .


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ok Dialog-Frame
PROCEDURE proc-b-ok :
do
 on error undo, return error return-value
 :

    if not can-find( first tt-goods no-lock  ) then do:
      message "В совокупной заявке нет ни одного товара ! Удаляем заявку ?"
        view-as alert-box question
        buttons yes-no
        update g#log
      .
      if g#log then  do:
          find first ub.ord-cons  exclusive-lock  where ub.ord-cons.cons-code = loc-ord-cons-code no-error .
          if error-status :error then do:
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)  .
              return.
              end.

          delete ub.ord-cons.
          end.
    end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-16 Dialog-Frame
PROCEDURE proc-br-16 :
do
 on error undo, return error return-value
 :
if frame FRAME-postavki:visible and avail ub.ord-doc and T-of then do:
  {&OPEN-QUERY-BROWSE-21}
  BROWSE-29:title = "По заявке № "  + ub.ord-doc.doc-code. .
  {&OPEN-QUERY-BROWSE-29-alt}
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-18 Dialog-Frame
PROCEDURE proc-br-18 :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
find current tt-new-ord-line no-lock no-error.
if avail tt-new-ord-line then do:
      loc-num-ord-FP = tt-new-ord-line.doc-code .
      if not t-gds then do:
          {&OPEN-QUERY-BROWSE-28}
          end.
      else do:
          {&OPEN-QUERY-BROWSE-28-alt}
          browse-28:Title in frame frame-j = "Поставки по Заказу "  + loc-num-ord-FP.
      end.
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-browse-14 Dialog-Frame
PROCEDURE proc-browse-14 :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if frame FRAME-H:visible then do:
  {&OPEN-QUERY-BROWSE-15}
  {&OPEN-QUERY-BROWSE-20}

  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-browse-26 Dialog-Frame
PROCEDURE proc-browse-26 :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
find current ub.ord-doc no-lock no-error.
if avail ub.ord-doc then do:
  loc-num-ord-FP = ub.ord-doc.doc-code .
  BROWSE-27:title in frame frame-k = "Поставки по заказу ФП № " + ub.ord-doc.doc-code .
  {&OPEN-QUERY-BROWSE-27}
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-bt-8 Dialog-Frame
PROCEDURE proc-bt-8 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :


define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define variable d-rec as recid no-undo.

  find current ub.ord-line-rcv no-lock no-error .
  if avail  ub.ord-line-rcv then do:
    g#log = no.
    message "Удалить строку в поставке №" ub.ord-line-rcv.rcv-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update g#log.
      if g#log = false then return.


     find first buf_ord-doc-rcv no-lock where
                buf_ord-doc-rcv.doc-code = ub.ord-line-rcv.doc-code and
                buf_ord-doc-rcv.rcv-code = ub.ord-line-rcv.rcv-code no-error .
     if avail  buf_ord-doc-rcv then do:
        if buf_ord-doc-rcv.status_ <> {&g___new}   then do:
            message "Нельзя Удалять поставку в статусе " caps(buf_ord-doc-rcv.status_) view-as alert-box information .
            return.
            end.
     end.
  d-rec = recid (ord-line-rcv).
  run del-post in this-procedure ( d-rec ).
  {&OPEN-QUERY-BROWSE-20}
end.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-but-10 Dialog-Frame
PROCEDURE proc-but-10 :
do
 on error undo, return error return-value
 :

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

 define variable d-rec as recid no-undo.
  if avail  tt-new-ord-line then do:
    g#log = no.
    message "Удалить строку в  заказе №" tt-new-ord-line.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update g#log.
      if g#log = false then return.
  d-rec = recid (tt-new-ord-line).
  run del-zakaz in this-procedure (d-rec).
    {&OPEN-QUERY-BROWSE-18}
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-but-17 Dialog-Frame
PROCEDURE proc-but-17 :
do
 on error undo, return error return-value
 :
define variable v-doc-mode as character no-undo .
v-doc-mode  = {&update} .
 if avail  ub.ord-doc-rcv  and ub.ord-doc-rcv.doc-type = "in":u  then do:
        run cus/or-obj.w
        (      input  parParentProc
             , input  g#host-code
             , input  recid(ub.ord-doc-rcv)
             , input  3
             , input  {&update}
             , input  {&update}
             , input-output  v-doc-mode  ) .
     g#log = BROWSE-23:refresh() in frame frame-i no-error .
     run calc-cons-ord in this-procedure .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-but-18 Dialog-Frame
PROCEDURE proc-but-18 :
do
 on error undo, return error return-value
 :

define variable d-rec as recid no-undo.
g#log = no.
find current ub.ord-doc-rcv no-lock no-error .
if avail  ub.ord-doc-rcv then do:
message "Удалить поставку №" ub.ord-doc-rcv.doc-code "?   Вы уверены ?"
                 view-as alert-box question buttons OK-Cancel update g#log.

if g#log = false then return.
  d-rec = recid (ub.ord-doc-rcv).
  run del-post-doc in this-procedure (d-rec).
  {&OPEN-QUERY-BROWSE-23}
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-color-status Dialog-Frame
PROCEDURE proc-color-status :
do
 on error undo, return error return-value
 :
define input parameter num-m    as integer no-undo .
define input parameter p-status as character no-undo .
define variable h-cell    as handle no-undo .
define variable kk as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries( handle-br-all [num-m] ).
 do kk =  1 to v-nn :
     h-cell =  WIDGET-HANDLE(entry(kk, handle-br-all [num-m] )) .
     run color-cell in this-procedure ( h-cell, user-color-status , p-status , {&g___new}) .
 end.

end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-color-str Dialog-Frame
PROCEDURE proc-color-str :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if tt-goods.gds-t = {&h-property} then
     assign
       tt-goods.artic      :fgcolor in browse browse-30 = blue_color
       tt-goods.all-name   :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-qnty   :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-ord    :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-rcv    :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-rcv-in :fgcolor in browse browse-30 = blue_color
       tt-goods.unit-base  :fgcolor in browse browse-30 = blue_color
       tt-goods.unit-cli   :fgcolor in browse browse-30 = blue_color
       tt-goods.sum-fact   :fgcolor in browse browse-30 = blue_color
       tt-goods.gds-t      :fgcolor in browse browse-30 = blue_color
        .
     else
      assign
       tt-goods.artic      :fgcolor in browse browse-30 = ?
       tt-goods.all-name   :fgcolor in browse browse-30 = ?
       tt-goods.sum-qnty   :fgcolor in browse browse-30 = ?
       tt-goods.sum-ord    :fgcolor in browse browse-30 = ?
       tt-goods.sum-rcv    :fgcolor in browse browse-30 = ?
       tt-goods.sum-rcv-in :fgcolor in browse browse-30 = ?
       tt-goods.unit-base  :fgcolor in browse browse-30 = ?
       tt-goods.unit-cli   :fgcolor in browse browse-30 = ?
       tt-goods.sum-fact   :fgcolor in browse browse-30 = ?
       tt-goods.gds-t      :fgcolor in browse browse-30 = ?
     .
/* проверки корректноти заполнения */
  if tt-goods.sum-qnty - (tt-goods.sum-ord + tt-goods.sum-rcv-in) < 0 then do:
     tt-goods.sum-ord       :fgcolor in browse browse-30 = 12 .
     tt-goods.sum-rcv-in    :fgcolor in browse browse-30 = 12 .
  end.
  if tt-goods.sum-ord < tt-goods.sum-rcv then do:
     tt-goods.sum-rcv       :fgcolor in browse browse-30 = 12 .
  end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-create-rcv-doc Dialog-Frame
PROCEDURE proc-create-rcv-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define input parameter p-PS               like ub.ord-doc-rcv.PS            no-undo .
define input parameter p-base-rate        like ub.ord-doc-rcv.base-rate     no-undo .
define input parameter p-base-scale       like ub.ord-doc-rcv.base-scale    no-undo .
define input parameter p-cli-code         like ub.ord-doc-rcv.cli-code      no-undo .
define input parameter p-cli-type         like ub.ord-doc-rcv.cli-type      no-undo .
define input parameter p-cons-code        like ub.ord-doc-rcv.cons-code     no-undo .
define input parameter p-creid            like ub.ord-doc-rcv.creid         no-undo .
define input parameter p-cycle-day        like ub.ord-doc-rcv.cycle-day     no-undo .
define input parameter p-date-pay         like ub.ord-doc-rcv.date-pay      no-undo .
define input parameter p-doc-code         like ub.ord-doc-rcv.doc-code      no-undo .
define input parameter p-doc-date         like ub.ord-doc-rcv.doc-date      no-undo .
define input parameter p-doc-type         like ub.ord-doc-rcv.doc-type      no-undo .
define input parameter p-exch-code        like ub.ord-doc-rcv.exch-code     no-undo .
define input parameter p-exch-date        like ub.ord-doc-rcv.exch-date     no-undo .
define input parameter p-exch-rate        like ub.ord-doc-rcv.exch-rate     no-undo .
define input parameter p-exch-scale       like ub.ord-doc-rcv.exch-scale    no-undo .
define input parameter p-fact-date        like ub.ord-doc-rcv.fact-date     no-undo .
define input parameter p-fact-num         like ub.ord-doc-rcv.fact-num      no-undo .
define input parameter p-fact-order       like ub.ord-doc-rcv.fact-order    no-undo .
define input parameter p-fact-ship-time   like ub.ord-doc-rcv.fact-ship-time  no-undo .
define input parameter p-fact-time        like ub.ord-doc-rcv.fact-time       no-undo .
define input parameter p-flag_            like ub.ord-doc-rcv.flag_           no-undo .
define input parameter p-host-code        like ub.ord-doc-rcv.host-code       no-undo .
define input parameter p-obj-code         like ub.ord-doc-rcv.obj-code        no-undo .
define input parameter p-obj-type         like ub.ord-doc-rcv.obj-type        no-undo .
define input parameter p-order-type       like ub.ord-doc-rcv.order-type      no-undo .
define input parameter p-rcv-code         like ub.ord-doc-rcv.rcv-code        no-undo .
define input parameter p-shift-date       like ub.ord-doc-rcv.shift-date      no-undo .
define input parameter p-shift-num        like ub.ord-doc-rcv.shift-num       no-undo .
define input parameter p-shift-name       like ub.ord-doc-rcv.shift-name      no-undo .
define input parameter p-ship-date        like ub.ord-doc-rcv.ship-date       no-undo .
define input parameter p-ship-time        like ub.ord-doc-rcv.ship-time       no-undo .
define input parameter p-status_          like ub.ord-doc-rcv.status_         no-undo .
define input parameter p-sum-service      like ub.ord-doc-rcv.sum-service     no-undo .
define input parameter p-sum-ship         like ub.ord-doc-rcv.sum-ship        no-undo .
define input parameter p-sys-date         like ub.ord-doc-rcv.sys-date        no-undo .
define input parameter p-sys-time-int     like ub.ord-doc-rcv.sys-time-int    no-undo .
define input parameter p-sys-time         like ub.ord-doc-rcv.sys-time        no-undo .
define input parameter p-tot-lines        like ub.ord-doc-rcv.tot-lines       no-undo .
define input parameter p-trn-code         like ub.ord-doc-rcv.trn-code        no-undo .
define input parameter p-user-db-num      like ub.ord-doc-rcv.user-db-num     no-undo .
define input parameter p-user-name        like ub.ord-doc-rcv.user-name       no-undo .
create ub.ord-doc-rcv.
assign
 ub.ord-doc-rcv.PS                =  p-PS
 ub.ord-doc-rcv.base-rate         =  p-base-rate
 ub.ord-doc-rcv.base-scale        =  p-base-scale
 ub.ord-doc-rcv.cli-code          =  p-cli-code
 ub.ord-doc-rcv.cli-type          =  p-cli-type
 ub.ord-doc-rcv.cons-code         =  p-cons-code
 ub.ord-doc-rcv.creid             =  p-creid
 ub.ord-doc-rcv.cycle-day         =  p-cycle-day
 ub.ord-doc-rcv.date-pay          =  p-date-pay
 ub.ord-doc-rcv.doc-code          =  p-doc-code
 ub.ord-doc-rcv.doc-date          =  p-doc-date
 ub.ord-doc-rcv.doc-type          =  p-doc-type
 ub.ord-doc-rcv.exch-code         =  p-exch-code
 ub.ord-doc-rcv.exch-date         =  p-exch-date
 ub.ord-doc-rcv.exch-rate         =  p-exch-rate
 ub.ord-doc-rcv.exch-scale        =  p-exch-scale
 ub.ord-doc-rcv.fact-date         =  p-fact-date
 ub.ord-doc-rcv.fact-num          =  p-fact-num
 ub.ord-doc-rcv.fact-order        =  p-fact-order
 ub.ord-doc-rcv.fact-ship-time    =  p-fact-ship-time
 ub.ord-doc-rcv.fact-time         =  p-fact-time
 ub.ord-doc-rcv.flag_             =  p-flag_
 ub.ord-doc-rcv.host-code         =  p-host-code
 ub.ord-doc-rcv.obj-code          =  p-obj-code
 ub.ord-doc-rcv.obj-type          =  p-obj-type
 ub.ord-doc-rcv.order-type        =  p-order-type
 ub.ord-doc-rcv.rcv-code          =  p-rcv-code
 ub.ord-doc-rcv.shift-date        =  p-shift-date
 ub.ord-doc-rcv.shift-num         =  p-shift-num
 ub.ord-doc-rcv.shift-name        =  p-shift-name
 ub.ord-doc-rcv.ship-date         =  p-ship-date
 ub.ord-doc-rcv.ship-time         =  p-ship-time
 ub.ord-doc-rcv.status_           =  p-status_
 ub.ord-doc-rcv.sum-service       =  p-sum-service
 ub.ord-doc-rcv.sum-ship          =  p-sum-ship
 ub.ord-doc-rcv.sys-date          =  p-sys-date
 ub.ord-doc-rcv.sys-time-int      =  p-sys-time-int
 ub.ord-doc-rcv.sys-time          =  p-sys-time
 ub.ord-doc-rcv.tot-lines         =  p-tot-lines
 /*ord-doc-rcv.trn-code          =  p-trn-code */
 ub.ord-doc-rcv.user-db-num       =  p-user-db-num
 ub.ord-doc-rcv.user-name         =  p-user-name
.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-create-rcv-line Dialog-Frame
PROCEDURE proc-create-rcv-line :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define input parameter p-SLT-pc            like ub.ord-line-rcv.SLT-pc                 no-undo .
define input parameter p-VAT-pc            like ub.ord-line-rcv.VAT-pc                 no-undo .
define input parameter p-artic             like ub.ord-line-rcv.artic                  no-undo .
define input parameter p-cli-base-rate     like ub.ord-line-rcv.cli-base-rate          no-undo .
define input parameter p-cli-qnty          like ub.ord-line-rcv.cli-qnty               no-undo .
define input parameter p-doc-code          like ub.ord-line-rcv.doc-code               no-undo .
define input parameter p-excise            like ub.ord-line-rcv.excise                 no-undo .
define input parameter p-gds-code          like ub.ord-line-rcv.gds-code               no-undo .
define input parameter p-line-num          like ub.ord-line-rcv.line-num               no-undo .
define input parameter p-other-base        like ub.ord-line-rcv.other-base             no-undo .
define input parameter p-other-rubl        like ub.ord-line-rcv.other-rubl             no-undo .
define input parameter p-price-base        like ub.ord-line-rcv.price-base             no-undo .
define input parameter p-price-cli         like ub.ord-line-rcv.price-cli              no-undo .
define input parameter p-price-rubl        like ub.ord-line-rcv.price-rubl             no-undo .
define input parameter p-prod-code         like ub.ord-line-rcv.prod-code              no-undo .
define input parameter p-prod-type         like ub.ord-line-rcv.prod-type              no-undo .
define input parameter p-qnty              like ub.ord-line-rcv.qnty                   no-undo .
define input parameter p-rcv-code          like ub.ord-line-rcv.rcv-code               no-undo .
define input parameter p-road-tax          like ub.ord-line-rcv.road-tax               no-undo .
define input parameter p-sum-SLT           like ub.ord-line-rcv.sum-SLT                no-undo .
define input parameter p-sum-VAT           like ub.ord-line-rcv.sum-VAT                no-undo .
define input parameter p-sum-base          like ub.ord-line-rcv.sum-base               no-undo .
define input parameter p-sum-cli           like ub.ord-line-rcv.sum-cli                no-undo .
define input parameter p-sum-excise        like ub.ord-line-rcv.sum-excise             no-undo .
define input parameter p-sum-other-base    like ub.ord-line-rcv.sum-other-base         no-undo .
define input parameter p-sum-other-rubl    like ub.ord-line-rcv.sum-other-rubl         no-undo .
define input parameter p-sum-road-tax      like ub.ord-line-rcv.sum-road-tax           no-undo .
define input parameter p-sum-rubl          like ub.ord-line-rcv.sum-rubl               no-undo .
define input parameter p-sum-transport-base like ub.ord-line-rcv.sum-transport-base    no-undo .
define input parameter p-sum-transport-rubl like ub.ord-line-rcv.sum-transport-rubl    no-undo .
define input parameter p-transport-base    like ub.ord-line-rcv.transport-base         no-undo .
define input parameter p-transport-rubl    like ub.ord-line-rcv.transport-rubl         no-undo .
define input parameter p-unit-cli          like ub.ord-line-rcv.unit-cli               no-undo .
define input parameter p-v-vat             like ub.ord-line-rcv.v-vat                  no-undo .

    create  ub.ord-line-rcv.
    assign
      ub.ord-line-rcv.doc-code            = p-doc-code
      ub.ord-line-rcv.rcv-code            = p-rcv-code
      ub.ord-line-rcv.SLT-pc              = p-SLT-pc
      ub.ord-line-rcv.VAT-pc              = p-VAT-pc
      ub.ord-line-rcv.artic               = p-artic
      ub.ord-line-rcv.cli-base-rate       = p-cli-base-rate
      ub.ord-line-rcv.cli-qnty            = p-cli-qnty
      ub.ord-line-rcv.excise              = p-excise
      ub.ord-line-rcv.gds-code            = p-gds-code
      ub.ord-line-rcv.line-num            = p-line-num
      ub.ord-line-rcv.other-base          = p-other-base
      ub.ord-line-rcv.other-rubl          = p-other-rubl
      ub.ord-line-rcv.price-base          = p-price-base
      ub.ord-line-rcv.price-cli           = p-price-cli
      ub.ord-line-rcv.price-rubl          = p-price-rubl
      ub.ord-line-rcv.prod-code           = p-prod-code
      ub.ord-line-rcv.prod-type           = p-prod-type
      ub.ord-line-rcv.qnty                = p-qnty
      ub.ord-line-rcv.road-tax            = p-road-tax
      ub.ord-line-rcv.sum-SLT             = p-sum-SLT
      ub.ord-line-rcv.sum-VAT             = p-sum-VAT
      ub.ord-line-rcv.sum-base            = p-sum-base
      ub.ord-line-rcv.sum-cli             = p-sum-cli
      ub.ord-line-rcv.sum-excise          = p-sum-excise
      ub.ord-line-rcv.sum-other-base      = p-sum-other-base
      ub.ord-line-rcv.sum-other-rubl      = p-sum-other-rubl
      ub.ord-line-rcv.sum-road-tax        = p-sum-road-tax
      ub.ord-line-rcv.sum-rubl            = p-sum-rubl
      ub.ord-line-rcv.sum-transport-base  = p-sum-transport-base
      ub.ord-line-rcv.sum-transport-rubl  = p-sum-transport-rubl
      ub.ord-line-rcv.transport-base      = p-transport-base
      ub.ord-line-rcv.transport-rubl      = p-transport-rubl
      ub.ord-line-rcv.unit-cli            = p-unit-cli
      ub.ord-line-rcv.v-vat               = p-v-vat
   .


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-button-2 Dialog-Frame
PROCEDURE proc-init-button-2 :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

 button-2:LOAD-IMAGE-UP("adeicon\ts-up":U)           in frame {&frame-name} .
 F-obj:fgcolor = 1   .

 button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
 button-47:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name}.
 f-post:fgcolor = ? .
 f-post-2:fgcolor = ?.

  if t-prt then do:
            VIEW FRAME FRAME-b.
            {&OPEN-BROWSERS-IN-QUERY-FRAME-b-prt}
            hide FRAME FRAME-e-prt.
            hide FRAME FRAME-postavki-prt.
            hide FRAME FRAME-e.
            hide FRAME FRAME-postavki.
            run proc-prt in this-procedure   .
     end.
     else  do:
            hide FRAME FRAME-b-prt.
            VIEW FRAME FRAME-b.
            VIEW FRAME FRAME-H.
            {&OPEN-BROWSERS-IN-QUERY-FRAME-b}
            {&OPEN-BROWSERS-IN-QUERY-FRAME-h}
            {&OPEN-QUERY-BROWSE-14}
            hide FRAME FRAME-e.
            hide FRAME FRAME-e-prt.
            hide FRAME FRAME-pos-prt.
           run proc-t-of in this-procedure  .
     end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-button-3 Dialog-Frame
PROCEDURE proc-init-button-3 :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 button-3:LOAD-IMAGE-UP("adeicon\ts-up":U)      in frame {&frame-name} .
 F-post-2:fgcolor = 1 .

 button-2:LOAD-IMAGE-Up ("adeicon\ts-down":U)   in frame {&frame-name} .
 button-47:LOAD-IMAGE-Up("adeicon\ts-down":U)   in frame {&frame-name} .
 f-obj:fgcolor  = ? .
 f-post:fgcolor = ? .


  if t-prt then do:
            VIEW FRAME FRAME-e.

            {&OPEN-BROWSERS-IN-QUERY-FRAME-e-prt}
            run br-12 in this-procedure .
            hide FRAME FRAME-b.
            hide FRAME FRAME-b-prt.
            hide FRAME FRAME-postavki.
            hide FRAME FRAME-pos-prt.
            run proc-prt in this-procedure   .
           end.
     else  do:
            VIEW FRAME FRAME-e.
            {&OPEN-BROWSERS-IN-QUERY-FRAME-e}
            apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
            hide FRAME FRAME-e-prt.
            hide FRAME FRAME-b.
            {&OPEN-BROWSERS-IN-QUERY-FRAME-b}
            hide FRAME FRAME-postavki.
            {&OPEN-BROWSERS-IN-QUERY-FRAME-postavki}
           run proc-t-of in this-procedure  .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-button-47 Dialog-Frame
PROCEDURE proc-init-button-47 :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 button-47:LOAD-IMAGE-UP("adeicon\ts-up":U)           in frame {&frame-name} .
 F-post:fgcolor = 1   .
 button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name} .
 button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame {&frame-name}.
 f-obj:fgcolor    = ? .
 f-post-2:fgcolor = ?.

  if t-prt then do:
          VIEW FRAME FRAME-postavki.
          {&OPEN-BROWSERS-IN-QUERY-FRAME-postavki}
          hide FRAME FRAME-b .
          hide FRAME FRAME-e .
          hide FRAME FRAME-b-prt .
          hide FRAME FRAME-e-prt .
          run proc-prt in this-procedure   .
     end.
     else  do:
          VIEW FRAME FRAME-postavki.
          {&OPEN-BROWSERS-IN-QUERY-FRAME-postavki}
          hide FRAME FRAME-b.
          hide FRAME FRAME-post-prt.
          {&OPEN-BROWSERS-IN-QUERY-FRAME-b}
          hide FRAME FRAME-e.
          {&OPEN-BROWSERS-IN-QUERY-FRAME-e}
          run proc-t-of in this-procedure  .
     end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_d_post Dialog-Frame
PROCEDURE proc-m_d_post :
do
 on error undo, return error return-value
 :
message 'TODO' .
/* Отвязка */
find current new-rcv no-lock   no-error .
if avail new-rcv and new-rcv.trn-code <> "" then do:

  message  "Отменить ссылку на накладную " new-rcv.trn-code " у  поставки № " new-rcv.rcv-code  " ? "
    view-as alert-box  Question
    buttons yes-no update g#log .
  if not g#log  then return .

find current new-rcv  exclusive-lock  no-error .
  new-rcv.trn-code = "" .
  g#log = BROWSE-21:refresh() in frame frame-postavki no-error .
  {&OPEN-QUERY-BROWSE-22}
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-prt Dialog-Frame
PROCEDURE proc-prt :
do
 on error undo, return error return-value
 :

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:       ПРИЗНАКИ
------------------------------------------------------------------------------*/
define variable p-recid as recid no-undo .

   if t-prt then do:
   frame Dialog-Frame:title = ttt + "(по признакам)" .
      view FRAME FRAME-C.
      view FRAME FRAME-D-prt.
      hide FRAME FRAME-A.
      hide FRAME FRAME-D.
      if avail tt-goods then p-recid = recid(tt-goods) .
      {&OPEN-BROWSERS-IN-QUERY-FRAME-C}
      reposition browse-30 to recid p-recid no-error .
      run br-12 in this-procedure .

      if frame  frame-b:visible  then do:
        view FRAME FRAME-b-prt.
      end.

      if frame  frame-e:visible  then do:
        view FRAME FRAME-e-prt.
      end.

      if frame frame-postavki:visible  then do:
        view FRAME FRAME-post-prt.
      end.


   end.
   if not t-prt then do:
      view FRAME FRAME-A.
      view FRAME FRAME-D.
      hide FRAME FRAME-C.
      hide FRAME FRAME-D-prt.
      hide FRAME FRAME-post-prt.
      hide FRAME FRAME-e-prt.
      hide FRAME FRAME-b-prt.
      {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
   end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-br-12 Dialog-Frame
PROCEDURE proc-row-br-12 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

/* проверки корректноти заполнения */
  if tt-goods.sum-qnty - (tt-goods.sum-ord + tt-goods.sum-rcv-in) < 0 then do:
     tt-goods.sum-ord       :fgcolor in browse browse-12 = 12 .
     tt-goods.sum-rcv-in    :fgcolor in browse browse-12 = 12 .
  end.
  if tt-goods.sum-ord < tt-goods.sum-rcv then do:
     tt-goods.sum-rcv    :fgcolor in browse browse-12 = 12 .
  end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-t-gds Dialog-Frame
PROCEDURE proc-t-gds :
do
 on error undo, return error return-value
 :

assign frame  Dialog-Frame t-gds.
if t-gds then do :
 message "Развернуть Заказ ФП № " + loc-num-ord-FP "?"
  view-as alert-box question BUTTONS yes-no
  update g#log
  .
  if g#log <> true then do:
  t-gds = false.
  return no-apply.
  end.
      if frame FRAME-E:visible then do:
            view FRAME FRAME-j.
            enable   B-mark-2 with frame frame-J .
            {&OPEN-QUERY-BROWSE-18}
            {&OPEN-QUERY-BROWSE-28-alt}
            browse-18:Title = "Заказ ФП № "  + loc-num-ord-FP.
            apply "VALUE-CHANGED":U to BROWSE-18 in frame frame-J .
            browse-28:Title = "Поставки по Заказу "  + loc-num-ord-FP.
            hide FRAME FRAME-k.
            {&OPEN-BROWSERS-IN-QUERY-FRAME-k}
        end.
  end.
else do:
  if frame FRAME-B:visible then do:
           disable  B-mark-2 with frame frame-J .
           hide FRAME FRAME-H.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-H}

           view FRAME FRAME-i.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-i}
 end.
  if frame FRAME-E:visible then do:
           hide FRAME FRAME-j.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-j}
           view FRAME FRAME-k.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-k}
  end.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-t-of Dialog-Frame
PROCEDURE proc-t-of :
do
 on error undo, return error return-value
 :

if t-of then do :
    hide t-gds in frame Dialog-Frame.
    disable t-gds with frame Dialog-Frame.
    t-gds = false.

/*по документам*/
frame Dialog-Frame:title = ttt + "(по документам)" .
 str-good = "" .
 str-good:Bgcolor = ?.
 str-good:fgcolor = ?.

 display str-good with frame Dialog-Frame.
           view FRAME FRAME-F.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-F}

           hide FRAME FRAME-D.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-D}

  if frame FRAME-B:visible then do:

           hide FRAME FRAME-H.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-H}

           view FRAME FRAME-i.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-i}
 end.

  if frame FRAME-E:visible then do:
     view t-gds in frame {&frame-name}.
     enable t-gds with frame {&frame-name}.
     display t-gds with frame {&frame-name}.
           hide FRAME FRAME-j.
           /* {&OPEN-BROWSERS-IN-QUERY-FRAME-j} */

           view FRAME FRAME-k.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-k}


           apply "VALUE-CHANGED":U to BROWSE-26 in frame frame-K .
  end.

  if frame FRAME-b:visible then do:

           hide FRAME FRAME-h.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-h}

           view FRAME FRAME-i.
           {&OPEN-BROWSERS-IN-QUERY-FRAME-i}
  end.

  if frame FRAME-postavki:visible and avail ub.ord-doc then do:
     {&OPEN-QUERY-BROWSE-21}
     {&OPEN-QUERY-BROWSE-29}
     apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
     apply "VALUE-CHANGED":U to BROWSE-16 in frame frame-f.
  end.
end.
else do:

/* по товару */
 find current tt-goods no-lock no-error .
 if avail tt-goods then
    str-good = x-artic + " " + tt-goods.gds-name .
else DO:
find first tt-goods no-lock no-error .
if not avail tt-goods then return error.
    str-good = x-artic + " " + tt-goods.gds-name .
end.
 str-good:fgcolor = 15.
 str-good:bgcolor = 3.
 display str-good with frame Dialog-Frame.


frame {&frame-name}:title = ttt + " (по товарам)" .
    hide t-gds in frame {&frame-name}.
    disable t-gds with frame {&frame-name}.
    t-gds = false.

        view FRAME FRAME-D.
         {&OPEN-BROWSERS-IN-QUERY-FRAME-D}
        if frame FRAME-B:visible then do:
                view FRAME FRAME-H.
               {&OPEN-BROWSERS-IN-QUERY-FRAME-H}
        end.
        if frame FRAME-E:visible then do:
                view FRAME FRAME-j.
                disable b-mark-2 with frame FRAME-j.
               {&OPEN-BROWSERS-IN-QUERY-FRAME-j}
                hide FRAME FRAME-k.
               {&OPEN-BROWSERS-IN-QUERY-FRAME-k}
               apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
                end.
        if frame FRAME-b:visible then do:
                view FRAME FRAME-h.
               {&OPEN-BROWSERS-IN-QUERY-FRAME-h}
                hide FRAME FRAME-i.
               {&OPEN-BROWSERS-IN-QUERY-FRAME-i}
        end.

        if frame FRAME-postavki:visible then do:
                 BROWSE-21:title = "Все Поставки по СЗФП" .
                  {&OPEN-QUERY-BROWSE-21}
                /*  BROWSE-29:title = "Поставки по товару и завке" . */
                  {&OPEN-QUERY-BROWSE-29}
              apply "VALUE-CHANGED":U to BROWSE-12 in frame frame-a.
              apply "VALUE-CHANGED":U to BROWSE-13 in frame frame-d.
        end.


end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-handle Dialog-Frame
PROCEDURE read-handle :
/*  сбор handle */
 do
 on error undo, return error return-value
 :
define input parameter  h-browse as handle no-undo .
define output parameter str-summh as character no-undo .

define variable   h-temp as handle no-undo .
define variable h-l as handle no-undo .
define variable kk as integer no-undo .

 h-temp  =  h-browse:first-column no-error . /* 1 колонка */

  if  h-browse <> ?   and valid-handle(h-browse) and
      h-temp   <> ?   and valid-handle(h-temp)
     then do:

    str-summh =  string( h-temp  )  + "," .
    do kk = 2 to ( h-browse:NUM-COLUMNS  )   :
        str-summh = str-summh + string( h-temp:next-column  )  + ","  no-error .
        if error-status :error then message "Ошибка 1 " error-status :get-message(1) .
        if h-temp:next-column <> ? then do:
            h-temp = h-temp:next-column no-error .
            if error-status :error then message  "Ошибка 2 " error-status :get-message(1) .
        end.
    end.
 end.
end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-gds Dialog-Frame
PROCEDURE show-gds :
do
 on error undo, return error return-value
 :

  define buffer buf_goods for ub.goods.
  if not available tt-goods then  return no-apply.
  find first buf_goods where buf_goods.gds-code = tt-goods.gds-code no-lock no-error .
  if not available buf_goods then  return no-apply.
  run str/showgds.p ( input parparentproc
                     ,input ? /*p-call-handle*/
                     ,input  buf_goods.gds-code
                     ,input  {&lookup} ).
  apply "entry" to browse-12 in frame frame-a.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE status-isk Dialog-Frame
PROCEDURE status-isk :
do
 on error undo, return error return-value
 :

define variable t-rec as recid no-undo.
define buffer b_ord-line for ub.ord-line.
define buffer b_tt-goods for tt-goods.
define buffer b_ord-gds-cons for ub.ord-gds-cons.
define variable tt-qnty like tt-goods.sum-qnty  no-undo.
define variable t-ret as logical no-undo .
find current  ub.ord-doc no-lock no-error .
  if NOT available  ub.ord-doc Then do:
      message "Не выбрана заявка !!!" .
      return.
      end.

  g#log = no.
  message "Исключить заявку №" ub.ord-doc.doc-code "?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.

  t-ret =  session:SET-WAIT-STATE("GENERAL") .

  find current ub.ord-doc exclusive-lock.
      assign
      ub.ord-doc.cons-code = ""
      ub.ord-doc.status_= {&ord-accept}
      ub.ord-doc.fact-date = ?
    .
  find current ub.ord-doc no-lock .

      for each b_ord-line no-lock  where
               b_ord-line.doc-code = ub.ord-doc.doc-code
               :
          for each b_tt-goods  exclusive-lock  where
                  b_tt-goods.artic     = b_ord-line.artic     and
                  b_tt-goods.prod-code = b_ord-line.prod-code and
                  b_tt-goods.prod-type = b_ord-line.prod-type
                  :
              find first b_ord-gds-cons  exclusive-lock  where
                        b_ord-gds-cons.cons-code = loc-ord-cons-code    and
                        b_ord-gds-cons.artic     = b_ord-line.artic     and
                        b_ord-gds-cons.prod-code = b_ord-line.prod-code and
                        b_ord-gds-cons.prod-type = b_ord-line.prod-type
                        no-error .

              tt-qnty = b_tt-goods.sum-qnty - b_ord-line.qnty.
              if tt-qnty <= 0 then do:
                                   delete b_tt-goods.
                                   delete b_ord-gds-cons.
                                   end.
                              else do:
                               assign
                                  b_ord-gds-cons.sum-qnty = tt-qnty
                                  b_tt-goods.sum-qnty = tt-qnty
                                  t-rec = recid(b_tt-goods)
                                .
                                end.
          end.
      end.

    {&OPEN-QUERY-BROWSE-16}
    {&OPEN-QUERY-BROWSE-12}
    reposition BROWSE-12 to recid t-rec no-error.
    t-ret =  session:SET-WAIT-STATE("") .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE status-rej Dialog-Frame
PROCEDURE status-rej :
do
 on error undo, return error return-value
 :

define variable t-rec as recid no-undo.
define buffer b_ord-line for ub.ord-line.
define buffer b_tt-goods for tt-goods.
define buffer b_ord-gds-cons for ub.ord-gds-cons.
define variable tt-qnty like tt-goods.sum-qnty  no-undo.
define variable t-ret as logical no-undo .
find current  ub.ord-doc no-lock no-error .
  if NOT available  ub.ord-doc Then do:
      message "Не выбрана заявка !!!" .
      return.
      end.

  g#log = no.
  message "Отказать заявке №" ub.ord-doc.doc-code "?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update g#log.
  if g#log = false then return.

  t-ret =  session:SET-WAIT-STATE("GENERAL") .

  find current ub.ord-doc exclusive-lock.
      assign
      ub.ord-doc.cons-code = ub.ord-doc.cons-code + {&ord-rejection}
      ub.ord-doc.status_= {&ord-rejection}
      ub.ord-doc.fact-date = to-day
    .
  find current ub.ord-doc no-lock .

      for each b_ord-line no-lock  where
               b_ord-line.doc-code = ub.ord-doc.doc-code
               :
          for each b_tt-goods  exclusive-lock  where
                  b_tt-goods.artic     = b_ord-line.artic     and
                  b_tt-goods.prod-code = b_ord-line.prod-code and
                  b_tt-goods.prod-type = b_ord-line.prod-type
                  :
              find first b_ord-gds-cons  exclusive-lock  where
                        b_ord-gds-cons.cons-code = loc-ord-cons-code    and
                        b_ord-gds-cons.artic     = b_ord-line.artic     and
                        b_ord-gds-cons.prod-code = b_ord-line.prod-code and
                        b_ord-gds-cons.prod-type = b_ord-line.prod-type
                        no-error .

              tt-qnty = b_tt-goods.sum-qnty - b_ord-line.qnty.
              if tt-qnty <= 0 then do:
                                   delete b_tt-goods.
                                   delete b_ord-gds-cons.
                                   end.
                              else do:
                               assign
                                  b_ord-gds-cons.sum-qnty = tt-qnty
                                  b_tt-goods.sum-qnty = tt-qnty
                                  t-rec = recid(b_tt-goods)
                                .
                                end.
          end.
      end.

    {&OPEN-QUERY-BROWSE-16}
    {&OPEN-QUERY-BROWSE-12}
    reposition BROWSE-12 to recid t-rec no-error.
    t-ret =  session:SET-WAIT-STATE("") .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE zakaz-1 Dialog-Frame
PROCEDURE zakaz-1 :
do
 on error undo, return error return-value
 :

/* Генерация заказа поставщикам */
  define variable  o-rec as recid no-undo.
   run make-fp in this-procedure ( input "1" , output o-rec ) no-error .

     if BROWSE-18:visible   in frame frame-j then do: {&OPEN-QUERY-BROWSE-18} end.
     if BROWSE-26:visible   in frame frame-k then do: {&OPEN-QUERY-BROWSE-26} end.

     If o-rec <> ? then dO:
       if BROWSE-26:visible   in frame frame-k then do: reposition BROWSE-26 to recid o-rec no-error . end.
       if BROWSE-18:visible   in frame frame-j then do: reposition BROWSE-18 to recid o-rec no-error . end.
   end.

 end.
END PROCEDURE.

PROCEDURE zakaz-1-of :
 do
 on error undo, return error return-value
 :

define buffer bbb_ord-line for ub.ord-line .
define buffer bbb_ord-doc  for ub.ord-doc .
/* Генерация заказа поставщикам */
  define variable  o-rec as recid no-undo.
  run make-fp in this-procedure ( input "3" , output o-rec).
  {&OPEN-QUERY-BROWSE-26}
  reposition BROWSE-26 to recid o-rec no-error .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE zakaz-2 Dialog-Frame
PROCEDURE zakaz-2 :
do
 on error undo, return error return-value
 :

define variable  o-rec as recid no-undo.
  run make-fp in this-procedure ( input "2", output o-rec ).
  {&OPEN-QUERY-BROWSE-18}
  reposition BROWSE-18 to recid o-rec no-error .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE zayvka Dialog-Frame
PROCEDURE zayvka :
define input parameter  t-type as character no-undo .
do
 on error undo, return error return-value
 :
define variable v-par-prt as logical no-undo .
define variable P-ACTION as character no-undo .

find current ub.ord-doc exclusive-lock no-error .
if available  ub.ord-doc and ub.ord-doc.doc-type = g#type Then do:
    find first shar-buf_ord-doc no-lock   where shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code no-error  .
      bf-handle = buffer shar-buf_ord-doc:handle .
      if t-type <> "lkp" then do:
         if t-type = "add" then P-ACTION = {&add-def} .
                           else P-ACTION = {&update} .
          run cus/ord-zakz.p
          (     input   parparentproc ,
                input   p-action      ,
                input   g#type ,
                output  doc-rec      ,
                input-output  br-handle ,
                input-output  bf-handle ,
                input-output  next-prev
                    ) .
          run calc-cons-ord in this-procedure .
      end.
      else do:
          next-prev = no.
          do while next-prev <> ?:
            if not available ub.ord-doc then do:
              message "Неправильный выбор документа.".
              return no-apply.
            end.
            run cus/ord-zakz.p
            (   input   parparentproc ,
                input   {&lookup}     ,
                input   g#type        ,
                output  doc-rec       ,
                input-output  br-handle ,
                input-output  bf-handle ,
                input-output  next-prev

                ) .
          end.
      end.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc-t-doc_ord-line for tt-new-ord-line ) :
  if can-do (del-list, string (recid (loc-t-doc_ord-line))) then RETURN "+".
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME