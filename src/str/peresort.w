&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документ пересортица

Автор: Чернова Светлана Александровна
Дата создания: 09/12/07
Author: Svetlana Chernova
Creation date: 09/12/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/13/06


*/

define input        parameter parparentproc    as handle    no-undo.
define input-output parameter pardoc-rec       as recid     no-undo.
define input        parameter pardoc-mode      as character no-undo.
define input        parameter parext-doc-type  as character no-undo.
define input-output parameter parnext-prev     as logical   no-undo.
define input-output parameter line-rec         as recid     no-undo.
define input        parameter br-handle        as handle    no-undo.
define input        parameter bf-handle        as handle    no-undo.
define input        parameter parobj-type      as character no-undo.
define input        parameter parobj-code      as integer   no-undo.
define input        parameter parcli-type      as character no-undo.
define input        parameter parcli-code      as integer   no-undo.
define input        parameter parold-supp-cntr as logical   no-undo.
define input        parameter parcontract-code as integer   no-undo.

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Документ пересортица":U .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ str/trdcalib.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/clcprtsl.i }
{ gbl/waitfram.i noprocess }
{ gbl/getcntxt.i def }
{ str/doc-code.i }
{ trg/holdprts.i }
{ trg/factord.i  }
{ str/peresort.i }
{ cmp/strcodec.i }
{ gbl/getsect.i  def }

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define buffer bf_trn-doc         for ub.trn-doc.
define buffer bf_doc-line        for ub.doc-line.
define buffer bf_goods           for ub.goods.
define buffer bf-plus_doc-line   for ub.doc-line.
define buffer bf-plus_goods      for ub.goods.
define buffer bf_parts           for ub.parts.
define buffer bf-plus_parts      for ub.parts.
define buffer bf_parts-root      for ub.parts-root.
define buffer bf_sysconf         for ub.sysconf.
define buffer bf-obj_clients     for ub.clients.
define buffer bf-host_clients    for ub.clients.

define variable varmark                      as character no-undo.
define variable varwrite-off-qnty            as decimal   no-undo.
define variable varwrite-off-sum-rubl        as decimal   no-undo.
define variable varwrite-off-sum-base        as decimal   no-undo.
define variable varwrite-off-vat-rubl        as decimal   no-undo.
define variable varwrite-off-vat-base        as decimal   no-undo.
define variable varincome-qnty               as decimal   no-undo.
define variable varincome-sum-rubl           as decimal   no-undo.
define variable varincome-sum-base           as decimal   no-undo.
define variable varincome-vat-rubl           as decimal   no-undo.
define variable varincome-vat-base           as decimal   no-undo.
define variable vardeviation-percent         as decimal   no-undo.
define variable vardeviation-abs-rub         as decimal   no-undo.
define variable vardeviation-abs-base        as decimal   no-undo.
define variable varwrite-off-for-income-qnty as decimal   no-undo.
define variable list-mode                    as character no-undo.
define variable g#log                        as logical   no-undo.
define variable prt-rec                      as recid     no-undo.
define variable varconf-attr                 as character no-undo.
define variable varpar-type                  as character no-undo.
define variable varlog                       as logical   no-undo.
define variable varprice                     as decimal   no-undo.
define variable varprice-plus                as decimal   no-undo.
define variable varr-b                       as character no-undo.

define variable varoldfact-qnty-exp           like ub.doc-line-sum.fact-qnty           no-undo.
define variable varoldcost-sum-base-exp       like ub.doc-line-sum.cost-sum-base       no-undo.
define variable varoldcost-sum-rubl-exp       like ub.doc-line-sum.cost-sum-rubl       no-undo.
define variable varoldcost-vat-base-exp       like ub.doc-line-sum.cost-vat-base       no-undo.
define variable varoldcost-vat-rubl-exp       like ub.doc-line-sum.cost-vat-rubl       no-undo.
define variable varoldcost-slt-base-exp       like ub.doc-line-sum.cost-slt-base       no-undo.
define variable varoldcost-slt-rubl-exp       like ub.doc-line-sum.cost-slt-rubl       no-undo.
define variable varoldcost-road-tax-base-exp  like ub.doc-line-sum.cost-road-tax-base  no-undo.
define variable varoldcost-road-tax-rubl-exp  like ub.doc-line-sum.cost-road-tax-rubl  no-undo.
define variable varoldcost-excise-base-exp    like ub.doc-line-sum.cost-excise-base    no-undo.
define variable varoldcost-excise-rubl-exp    like ub.doc-line-sum.cost-excise-rubl    no-undo.
define variable varoldcost-transport-base-exp like ub.doc-line-sum.cost-transport-base no-undo.
define variable varoldcost-transport-rubl-exp like ub.doc-line-sum.cost-transport-rubl no-undo.
define variable varoldcost-other-base-exp     like ub.doc-line-sum.cost-other-base     no-undo.
define variable varoldcost-other-rubl-exp     like ub.doc-line-sum.cost-other-rubl     no-undo.
define variable varoldsale-sum-base-exp       like ub.doc-line-sum.sale-sum-base       no-undo.
define variable varoldsale-sum-rubl-exp       like ub.doc-line-sum.sale-sum-rubl       no-undo.
define variable varoldsale-vat-base-exp       like ub.doc-line-sum.sale-vat-base       no-undo.
define variable varoldsale-vat-rubl-exp       like ub.doc-line-sum.sale-vat-rubl       no-undo.
define variable varoldsale-slt-base-exp       like ub.doc-line-sum.sale-slt-base       no-undo.
define variable varoldsale-slt-rubl-exp       like ub.doc-line-sum.sale-slt-rubl       no-undo.
define variable varoldsale-road-tax-base-exp  like ub.doc-line-sum.sale-road-tax-base  no-undo.
define variable varoldsale-road-tax-rubl-exp  like ub.doc-line-sum.sale-road-tax-rubl  no-undo.
define variable varoldsale-excise-base-exp    like ub.doc-line-sum.sale-excise-base    no-undo.
define variable varoldsale-excise-rubl-exp    like ub.doc-line-sum.sale-excise-rubl    no-undo.
define variable varoldsale-transport-base-exp like ub.doc-line-sum.sale-transport-base no-undo.
define variable varoldsale-transport-rubl-exp like ub.doc-line-sum.sale-transport-rubl no-undo.
define variable varoldsale-other-base-exp     like ub.doc-line-sum.sale-other-base     no-undo.
define variable varoldsale-other-rubl-exp     like ub.doc-line-sum.sale-other-rubl     no-undo.

define variable varoldfact-qnty-inp           like ub.doc-line-sum.fact-qnty           no-undo.
define variable varoldcost-sum-base-inp       like ub.doc-line-sum.cost-sum-base       no-undo.
define variable varoldcost-sum-rubl-inp       like ub.doc-line-sum.cost-sum-rubl       no-undo.
define variable varoldcost-vat-base-inp       like ub.doc-line-sum.cost-vat-base       no-undo.
define variable varoldcost-vat-rubl-inp       like ub.doc-line-sum.cost-vat-rubl       no-undo.
define variable varoldcost-slt-base-inp       like ub.doc-line-sum.cost-slt-base       no-undo.
define variable varoldcost-slt-rubl-inp       like ub.doc-line-sum.cost-slt-rubl       no-undo.
define variable varoldcost-road-tax-base-inp  like ub.doc-line-sum.cost-road-tax-base  no-undo.
define variable varoldcost-road-tax-rubl-inp  like ub.doc-line-sum.cost-road-tax-rubl  no-undo.
define variable varoldcost-excise-base-inp    like ub.doc-line-sum.cost-excise-base    no-undo.
define variable varoldcost-excise-rubl-inp    like ub.doc-line-sum.cost-excise-rubl    no-undo.
define variable varoldcost-transport-base-inp like ub.doc-line-sum.cost-transport-base no-undo.
define variable varoldcost-transport-rubl-inp like ub.doc-line-sum.cost-transport-rubl no-undo.
define variable varoldcost-other-base-inp     like ub.doc-line-sum.cost-other-base     no-undo.
define variable varoldcost-other-rubl-inp     like ub.doc-line-sum.cost-other-rubl     no-undo.
define variable varoldsale-sum-base-inp       like ub.doc-line-sum.sale-sum-base       no-undo.
define variable varoldsale-sum-rubl-inp       like ub.doc-line-sum.sale-sum-rubl       no-undo.
define variable varoldsale-vat-base-inp       like ub.doc-line-sum.sale-vat-base       no-undo.
define variable varoldsale-vat-rubl-inp       like ub.doc-line-sum.sale-vat-rubl       no-undo.
define variable varoldsale-slt-base-inp       like ub.doc-line-sum.sale-slt-base       no-undo.
define variable varoldsale-slt-rubl-inp       like ub.doc-line-sum.sale-slt-rubl       no-undo.
define variable varoldsale-road-tax-base-inp  like ub.doc-line-sum.sale-road-tax-base  no-undo.
define variable varoldsale-road-tax-rubl-inp  like ub.doc-line-sum.sale-road-tax-rubl  no-undo.
define variable varoldsale-excise-base-inp    like ub.doc-line-sum.sale-excise-base    no-undo.
define variable varoldsale-excise-rubl-inp    like ub.doc-line-sum.sale-excise-rubl    no-undo.
define variable varoldsale-transport-base-inp like ub.doc-line-sum.sale-transport-base no-undo.
define variable varoldsale-transport-rubl-inp like ub.doc-line-sum.sale-transport-rubl no-undo.
define variable varoldsale-other-base-inp     like ub.doc-line-sum.sale-other-base     no-undo.
define variable varoldsale-other-rubl-inp     like ub.doc-line-sum.sale-other-rubl     no-undo.

define variable vartot-docold                  like ub.trn-doc.tot-doc                    no-undo.
define variable vartot-rublold                 like ub.trn-doc.tot-rubl                   no-undo.
define variable vartotal-doc-line_tot-ovold    like ub.trn-doc.tot-ov                     no-undo.
define variable vartotal-doc-line_fact-rublold like ub.trn-doc.fact-rubl                  no-undo.
define variable vartotal-doc-line_fact-baseold like ub.trn-doc.fact-base                  no-undo.
define variable vartotal-doc-line_fact-qntyold like ub.trn-doc.fact-qnty                  no-undo.
define variable vartotal-doc-line_doc-qntyold  like ub.trn-doc.doc-qnty                   no-undo.
define variable vartotal-doc-line_cli-qntyold  like ub.trn-doc.cli-qnty                   no-undo.
define variable vartotal-parts_fact-baseold    as   decimal                               no-undo.
define variable vartotal-parts_fact-rublold    as   decimal                               no-undo.
define variable vartotal-parts_fact-qntyold    as   decimal                               no-undo.
define variable parext-doc-mode                as   character                             no-undo.


define variable varpstunqtn as character no-undo.

define variable varpstunqtn-log as logical no-undo.
define variable varmxpcicp-dec  as decimal no-undo.
define variable varmxpcdcp-dec  as decimal no-undo.
define variable varmxsmicp-dec  as decimal no-undo.
define variable varmxsmdcp-dec  as decimal no-undo.
define variable vargrp-is-eq    as logical no-undo.
define variable varpstunit      as logical no-undo.

define temp-table tt-del-list no-undo
field rec-id as recid
index rec-id is unique primary rec-id.

define temp-table tt-doc-line-cashe no-undo
field doc-code  like ub.doc-line.doc-code
field artic     like ub.doc-line.artic
field prod-type like ub.doc-line.prod-type
field prod-code like ub.doc-line.prod-code
field qnty      as   decimal
field sum-rubl  as   decimal
field sum-base  as   decimal
field vat-rubl  as   decimal
field vat-base  as   decimal
index pi is unique primary doc-code artic prod-type prod-code.

define temp-table tt-doc-line-cashe-plus no-undo
field doc-code     like ub.doc-line.doc-code
field wf-artic     like ub.doc-line.artic
field wf-prod-type like ub.doc-line.prod-type
field wf-prod-code like ub.doc-line.prod-code
field artic     like ub.doc-line.artic
field prod-type like ub.doc-line.prod-type
field prod-code like ub.doc-line.prod-code
field qnty               as decimal
field sum-rubl           as decimal
field sum-base           as decimal
field vat-rubl           as decimal
field vat-base           as decimal
FIELD write-off-qnty     AS DECIMAL
FIELD write-off-sum-rubl AS DECIMAL
FIELD write-off-sum-base AS DECIMAL
index pi is unique primary doc-code wf-artic wf-prod-type wf-prod-code artic prod-type prod-code.


define temp-table tt-recalc-line no-undo like ub.doc-line.
&scop browse-name-b-      b-goods-
&scop label-clmn_1-b-     '*'
&scop sort-clmn_1-b-      get-mark (buffer bf_doc-line)
&scop label-clmn_2-b-     'Артикул'
&scop sort-clmn_2-b-      bf_doc-line.artic
&scop label-clmn_3-b-     'Название товара'
&scop sort-clmn_3-b-      bf_goods.gds-name
&scop label-clmn_4-b-     'Тип'
&scop sort-clmn_4-b-      bf_doc-line.prod-type
&scop label-clmn_5-b-     'Код произ'
&scop sort-clmn_5-b-      bf_doc-line.prod-code
&scop label-clmn_6-b-     'Цена'
&scop sort-clmn_6-b-      get-price (buffer bf_goods)
&scop label-clmn_7-b-     'Спис. кол-во'
&scop sort-clmn_7-b-      get-write-off-qnty (BUFFER bf_doc-line)
&scop label-clmn_8-b-     'Спис. сумма ({&abbr_rub})'
&scop sort-clmn_8-b-      get-write-off-sum-rubl (BUFFER bf_doc-line)
&scop label-clmn_9-b-     'Спис. сумма (вал)'
&scop sort-clmn_9-b-      get-write-off-sum-base (BUFFER bf_doc-line)
&scop label-clmn_10-b-    'Спис. НДС ({&abbr_rub})'
&scop sort-clmn_10-b-     get-write-off-vat-rubl (BUFFER bf_doc-line)
&scop label-clmn_11-b-    'Спис. НДС (вал)'
&scop sort-clmn_11-b-     get-write-off-vat-base (BUFFER bf_doc-line)

&scop browse-name-b        b-goods
&scop label-clmn_1-b      'Артикул'
&scop sort-clmn_1-b       bf-plus_doc-line.artic
&scop label-clmn_2-b      'Название товара'
&scop sort-clmn_2-b       bf-plus_goods.gds-name
&scop label-clmn_3-b      'Тип'
&scop sort-clmn_3-b       bf-plus_doc-line.prod-type
&scop label-clmn_4-b      'Код произ'
&scop sort-clmn_4-b       bf-plus_doc-line.prod-code
&scop label-clmn_5-b      'Цена'
&scop sort-clmn_5-b       get-price (buffer bf-plus_goods)
&scop label-clmn_6-b      'Оприх.кол-во'
&scop sort-clmn_6-b       get-income-qnty (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_7-b      'Оприх. сумма ({&abbr_rub})'
&scop sort-clmn_7-b       get-income-sum-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_8-b      'Оприх. сумма (вал)'
&scop sort-clmn_8-b       get-income-sum-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_9-b      'Оприх. НДС ({&abbr_rub})'
&scop sort-clmn_9-b       get-income-vat-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_10-b     'Оприх. НДС (вал)'
&scop sort-clmn_10-b      get-income-vat-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_11-b     'Отклонение %'
&scop sort-clmn_11-b      get-deviation-percent (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_12-b     'Отклонение ({&abbr_rub})'
&scop sort-clmn_12-b      get-deviation-abs-rubl (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_13-b     'Отклонение (вал)'
&scop sort-clmn_13-b      get-deviation-abs-base (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)
&scop label-clmn_14-b     'Спис. кол-во для оприх.кол-ва'
&scop sort-clmn_14-b      get-write-off-for-income-qnty (BUFFER bf_doc-line, BUFFER bf-plus_doc-line)

{ gbl/getcntxt.i get }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bf-plus_doc-line bf-plus_goods bf_parts-root ~
bf_doc-line bf_goods bf_parts

/* Definitions for BROWSE b-goods                                       */
&Scoped-define FIELDS-IN-QUERY-b-goods {&sort-clmn_1-b} {&sort-clmn_2-b} {&sort-clmn_3-b} {&sort-clmn_4-b} {&sort-clmn_5-b} @ varprice-plus {&sort-clmn_6-b} @ varincome-qnty {&sort-clmn_7-b} @ varincome-sum-rubl {&sort-clmn_8-b} @ varincome-sum-base {&sort-clmn_9-b} @ varincome-vat-rubl {&sort-clmn_10-b} @ varincome-vat-base {&sort-clmn_11-b} @ vardeviation-percent {&sort-clmn_12-b} @ vardeviation-abs-rub {&sort-clmn_13-b} @ vardeviation-abs-base {&sort-clmn_14-b} @ varwrite-off-for-income-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-goods
&Scoped-define SELF-NAME b-goods
&Scoped-define QUERY-STRING-b-goods FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK, ~
           FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK, ~
           FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK
&Scoped-define OPEN-QUERY-b-goods OPEN QUERY {&SELF-NAME} FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK, ~
           FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND                               bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND                               bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK, ~
           FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND                               bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND                               bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-goods bf-plus_doc-line bf-plus_goods ~
bf_parts-root
&Scoped-define FIRST-TABLE-IN-QUERY-b-goods bf-plus_doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-b-goods bf-plus_goods
&Scoped-define THIRD-TABLE-IN-QUERY-b-goods bf_parts-root


/* Definitions for BROWSE b-goods-                                      */
&Scoped-define FIELDS-IN-QUERY-b-goods- {&sort-clmn_1-b-} @ varmark {&sort-clmn_2-b-} {&sort-clmn_3-b-} {&sort-clmn_4-b-} {&sort-clmn_5-b-} {&sort-clmn_6-b-} @ varprice {&sort-clmn_7-b-} @ varwrite-off-qnty {&sort-clmn_8-b-} @ varwrite-off-sum-rubl {&sort-clmn_9-b-} @ varwrite-off-sum-base {&sort-clmn_10-b-} @ varwrite-off-vat-rubl {&sort-clmn_11-b-} @ varwrite-off-vat-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-goods-
&Scoped-define SELF-NAME b-goods-
&Scoped-define QUERY-STRING-b-goods- FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK, ~
          FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK, ~
          FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK
&Scoped-define OPEN-QUERY-b-goods- OPEN QUERY {&SELF-NAME} FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK, ~
          FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND                          bf_goods.prod-type = bf_doc-line.prod-type AND                          bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK, ~
          FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND                          bf_parts.obj-type  = bf_doc-line.obj-type  AND                          bf_parts.obj-code  = bf_doc-line.obj-code  AND                          bf_parts.artic     = bf_doc-line.artic     AND                          bf_parts.prod-type = bf_doc-line.prod-type AND                          bf_parts.prod-code = bf_doc-line.prod-code AND                          bf_parts.fact-qnty < 0 NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-goods- bf_doc-line bf_goods bf_parts
&Scoped-define FIRST-TABLE-IN-QUERY-b-goods- bf_doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-b-goods- bf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-b-goods- bf_parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-goods}~
    ~{&OPEN-QUERY-b-goods-}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-prev b-next b-sum-doc b-arch ~
b-notes b-cnt b-history b-help b-lkp b-parts b-parts-plus b-sum-goods ~
b-sum-goods-plus b-goods- b-goods
&Scoped-Define DISPLAYED-OBJECTS varwrkr varwrkr-name vardoc-date varagnt ~
varagnt-name varfact-date varboss varboss-name varshift-date varshift-name ~
varshift-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-deviation-abs-base Dialog-Frame
FUNCTION get-deviation-abs-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-deviation-abs-rubl Dialog-Frame
FUNCTION get-deviation-abs-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-deviation-percent Dialog-Frame
FUNCTION get-deviation-percent RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-income-qnty Dialog-Frame
FUNCTION get-income-qnty RETURNS DECIMAL
  ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-income-sum-base Dialog-Frame
FUNCTION get-income-sum-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-income-sum-rubl Dialog-Frame
FUNCTION get-income-sum-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-income-vat-base Dialog-Frame
FUNCTION get-income-vat-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-income-vat-rubl Dialog-Frame
FUNCTION get-income-vat-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  (buffer local-doc-line for ub.doc-line)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-price Dialog-Frame
FUNCTION get-price RETURNS DECIMAL
(BUFFER local-goods FOR ub.goods) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-write-off-for-income-qnty Dialog-Frame
FUNCTION get-write-off-for-income-qnty RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-write-off-qnty Dialog-Frame
FUNCTION get-write-off-qnty RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-write-off-sum-base Dialog-Frame
FUNCTION get-write-off-sum-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-write-off-sum-rubl Dialog-Frame
FUNCTION get-write-off-sum-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-write-off-vat-base Dialog-Frame
FUNCTION get-write-off-vat-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-write-off-vat-rubl Dialog-Frame
FUNCTION get-write-off-vat-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-arch
     LABEL "&Учет"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-cnt
     LABEL "&ДогП"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history
     LABEL "&История"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 3 BY 1.

DEFINE BUTTON b-notes
     LABEL "При&меч"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-parts
     LABEL "&ПартСпис"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-parts-plus
     LABEL "&ПартОприх"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 3 BY 1.

DEFINE BUTTON b-sum-doc
     LABEL "&СумДок"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sum-goods
     LABEL "&СумТовСп"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sum-goods-plus
     LABEL "&СумТовОп"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-reas
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE varagnt AS INTEGER FORMAT "999999999" INITIAL ?
     LABEL "И&сп"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varagnt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE varboss AS INTEGER FORMAT "999999999" INITIAL ?
     LABEL "&М-р"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varboss-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "&Поставщик"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 36.5 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varcontract-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 68.5 BY 1 NO-UNDO.

DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(16)":U INITIAL "БЕЗ ДОГОВОРА"
     LABEL "&Договор"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE vardoc-date AS DATE FORMAT "99/99/99":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varfact-date AS DATE FORMAT "99/99/99":U
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varinformation AS CHARACTER FORMAT "X(256)":U INITIAL "ПО ТЕМ ЖЕ ПОСТАВЩИКАМ и ДОГОВОРАМ"
     VIEW-AS FILL-IN
     SIZE 34.5 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE varreason-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Код основания"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE varreason-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
      SIZE 42 BY .67
      FGCOLOR 3
      NO-UNDO.

DEFINE VARIABLE varshift-date AS DATE FORMAT "99/99/99":U
     LABEL "Смена"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varshift-name AS CHARACTER FORMAT "X(2)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE varshift-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "П"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE varwrkr AS INTEGER FORMAT "999999999" INITIAL ?
     LABEL "К&л-к"
     VIEW-AS FILL-IN
     SIZE 10 BY 1.

DEFINE VARIABLE varwrkr-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-goods FOR
      bf-plus_doc-line,
      bf-plus_goods,
      bf_parts-root SCROLLING.

DEFINE QUERY b-goods- FOR
      bf_doc-line,
      bf_goods,
      bf_parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-goods Dialog-Frame _FREEFORM
  QUERY b-goods DISPLAY
      {&sort-clmn_1-b}                                   column-label {&label-clmn_1-b}
  {&sort-clmn_2-b}                                   column-label {&label-clmn_2-b} format "x(48)"
  {&sort-clmn_3-b}                                   column-label {&label-clmn_3-b} format "x(3)"
  {&sort-clmn_4-b}                                   column-label {&label-clmn_4-b}
  {&sort-clmn_5-b}    @ varprice-plus                column-label {&label-clmn_5-b} FORMAT ">,>>>,>>9.999"
  {&sort-clmn_6-b}    @ varincome-qnty               column-label {&label-clmn_6-b}
  {&sort-clmn_7-b}    @ varincome-sum-rubl           column-label {&label-clmn_7-b}     FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_8-b}    @ varincome-sum-base           column-label {&label-clmn_8-b}     FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_9-b}    @ varincome-vat-rubl           column-label {&label-clmn_9-b}     FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_10-b}   @ varincome-vat-base           column-label {&label-clmn_10-b}    FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_11-b}   @ vardeviation-percent         COLUMN-LABEL {&label-clmn_11-b}
  {&sort-clmn_12-b}   @ vardeviation-abs-rub         COLUMN-LABEL {&label-clmn_12-b}
  {&sort-clmn_13-b}   @ vardeviation-abs-base        COLUMN-LABEL {&label-clmn_13-b}
  {&sort-clmn_14-b}   @ varwrite-off-for-income-qnty COLUMN-LABEL {&label-clmn_14-b}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7
         TITLE "Оприходованные товары" EXPANDABLE.

DEFINE BROWSE b-goods-
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-goods- Dialog-Frame _FREEFORM
  QUERY b-goods- DISPLAY
      {&sort-clmn_1-b-}    @ varmark               column-label {&label-clmn_1-b-} format "x(1)"
  {&sort-clmn_2-b-}                            column-label {&label-clmn_2-b-}
  {&sort-clmn_3-b-}                            column-label {&label-clmn_3-b-} format "x(48)"
  {&sort-clmn_4-b-}                            column-label {&label-clmn_4-b-} format "x(3)"
  {&sort-clmn_5-b-}                            column-label {&label-clmn_5-b-}
  {&sort-clmn_6-b-}    @ varprice              column-label {&label-clmn_6-b-} FORMAT ">,>>>,>>9.999"
  {&sort-clmn_7-b-}    @ varwrite-off-qnty     column-label {&label-clmn_7-b-}
  {&sort-clmn_8-b-}    @ varwrite-off-sum-rubl column-label {&label-clmn_8-b-}    FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_9-b-}    @ varwrite-off-sum-base column-label {&label-clmn_9-b-}    FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_10-b-}   @ varwrite-off-vat-rubl column-label {&label-clmn_10-b-}   FORMAT ">>,>>>,>>>,>>9.99"
  {&sort-clmn_11-b-}   @ varwrite-off-vat-base column-label {&label-clmn_11-b-}   FORMAT ">>,>>>,>>>,>>9.99"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7
         TITLE "Списанные товары" EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 14
     b-sum-doc AT ROW 1 COL 17
     b-arch AT ROW 1 COL 27
     b-notes AT ROW 1 COL 37
     b-cnt AT ROW 1 COL 47
     b-history AT ROW 1 COL 57
     b-help AT ROW 1 COL 87
     b-mark AT ROW 2 COL 14
     b-add AT ROW 2 COL 17
     b-lkp AT ROW 2 COL 27
     b-chg AT ROW 2 COL 37
     b-del AT ROW 2 COL 47
     b-parts AT ROW 2 COL 57
     b-parts-plus AT ROW 2 COL 67
     b-sum-goods AT ROW 2 COL 77
     b-sum-goods-plus AT ROW 2 COL 87
     varcli-code AT ROW 3 COL 10 COLON-ALIGNED
     varcli-type AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     varcli-name AT ROW 3 COL 25 COLON-ALIGNED NO-LABEL
     varinformation AT ROW 3 COL 63.5 NO-LABEL
     varcontract-prn-code AT ROW 4 COL 10 COLON-ALIGNED
     varcontract-name AT ROW 4 COL 27.5 COLON-ALIGNED NO-LABEL
     varwrkr AT ROW 5 COL 5 COLON-ALIGNED
     varwrkr-name AT ROW 5 COL 15 COLON-ALIGNED NO-LABEL
     r-wrkr AT ROW 5 COL 35.5
     vardoc-date AT ROW 5 COL 43.5 COLON-ALIGNED
     r-reas AT ROW 5 COL 82
     varagnt AT ROW 6 COL 5 COLON-ALIGNED
     varagnt-name AT ROW 6 COL 15 COLON-ALIGNED NO-LABEL
     r-agnt AT ROW 6 COL 35.5
     varfact-date AT ROW 6 COL 43.5 COLON-ALIGNED
     varboss AT ROW 7 COL 5 COLON-ALIGNED
     varboss-name AT ROW 7 COL 15 COLON-ALIGNED NO-LABEL
     r-boss AT ROW 7 COL 35.5
     varshift-date AT ROW 7 COL 43.5 COLON-ALIGNED
     varshift-name AT ROW 7 COL 57.5 COLON-ALIGNED
     varshift-num AT ROW 7 COL 64 COLON-ALIGNED
     r-sht AT ROW 7 COL 69
     b-goods- AT ROW 8 COL 1
     b-goods AT ROW 15 COL 1
     varreason-code AT ROW 5 COL 69 COLON-ALIGNED
     varreason-name AT ROW 6 COL 54 COLON-ALIGNED NO-LABEL
     SPACE(0.50) SKIP(15.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB b-goods- r-sht Dialog-Frame */
/* BROWSE-TAB b-goods b-goods- Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-agnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-boss IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-reas IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-sht IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-wrkr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varagnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varagnt-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varboss IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varboss-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcli-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcli-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcli-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcli-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcli-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcli-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcontract-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcontract-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcontract-prn-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcontract-prn-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN vardoc-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfact-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varinformation IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       varinformation:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varreason-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varreason-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varshift-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varshift-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varshift-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwrkr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwrkr-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-goods
/* Query rebuild information for BROWSE b-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bf-plus_doc-line WHERE bf-plus_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,
    FIRST bf-plus_goods WHERE bf-plus_goods.artic     = bf-plus_doc-line.artic     AND
                              bf-plus_goods.prod-type = bf-plus_doc-line.prod-type AND
                              bf-plus_goods.prod-code = bf-plus_doc-line.prod-code NO-LOCK,
    FIRST bf_parts-root WHERE bf_parts-root.doc-code      = bf-plus_doc-line.doc-code AND
                              bf_parts-root.gds-code      = bf-plus_goods.gds-code    AND
                              bf_parts-root.orig-gds-code = bf_goods.gds-code   NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-goods-
/* Query rebuild information for BROWSE b-goods-
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bf_doc-line WHERE bf_doc-line.doc-code = bf_trn-doc.doc-code NO-LOCK,
   FIRST bf_goods WHERE bf_goods.artic     = bf_doc-line.artic     AND
                         bf_goods.prod-type = bf_doc-line.prod-type AND
                         bf_goods.prod-code = bf_doc-line.prod-code NO-LOCK,
   FIRST bf_parts WHERE bf_parts.out-code  = bf_doc-line.doc-code  AND
                         bf_parts.obj-type  = bf_doc-line.obj-type  AND
                         bf_parts.obj-code  = bf_doc-line.obj-code  AND
                         bf_parts.artic     = bf_doc-line.artic     AND
                         bf_parts.prod-type = bf_doc-line.prod-type AND
                         bf_parts.prod-code = bf_doc-line.prod-code AND
                         bf_parts.fact-qnty < 0 NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-goods- */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON end-error OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  apply "choose" to b-exit in frame {&FRAME-NAME}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  run proc-exit in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON stop OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  apply "choose" to b-exit in frame {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  run local-add in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при добавлении строк пересортицы." skip
    return-value
    view-as alert-box error.
    return no-apply.
  end.
  run ui-on in this-procedure ("":u) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch Dialog-Frame
ON CHOOSE OF b-arch IN FRAME Dialog-Frame /* Учет */
DO:
  { gbl/stdbtn.i }

  define variable varlog as logical no-undo.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    bf_trn-doc.host-code
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if not varlog then do:
    return no-apply.
  end.
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid( bf_trn-doc )
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  { gbl/stdbtn.i }
  define variable varis-petrol      as logical no-undo.
  define variable varis-pieces      as logical no-undo.
  define variable varis-petrol-plus as logical no-undo.
  define variable varis-pieces-plus as logical no-undo.
  define buffer bf-trb_parts      for ub.parts.
  define buffer bf-trb_parts-root for ub.parts-root.
  define buffer bf_gds-prt      for ub.gds-prt.
  define buffer bf-plus_gds-prt for ub.gds-prt.
  define variable varhave-another-goods as logical no-undo.
  if not available bf_goods then do:
    message "Не выбрана линия списываемого товара." view-as alert-box.
    return no-apply.
  end.
  if not available bf-plus_goods then do:
    message "Не выбрана линия оприходуемого товара." view-as alert-box.
    return no-apply.
  end.

  { str/is-petrl.i
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    varis-petrol
    varis-pieces
  }
  { str/is-petrl.i
    bf-plus_goods.artic
    bf-plus_goods.prod-type
    bf-plus_goods.prod-code
    varis-petrol-plus
    varis-pieces-plus
  }
  if varis-petrol and
     not varis-pieces then do:
    message "Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " - топливо." skip
            "Редактирование возможно через удаление и добавление."
    view-as alert-box.
    return no-apply.
  end.
  if varis-petrol-plus and
     not varis-pieces-plus then do:
    message "По топливу " bf-plus_goods.artic " " bf-plus_goods.prod-type " " bf-plus_goods.prod-code " " bf-plus_goods.gds-name " -топливо." skip
            "Редактирование возможно через удаление и добавление."
    view-as alert-box.
    return no-apply.
  end.

  find first bf_gds-prt where bf_gds-prt.upper-code = bf_goods.prt-root no-lock.
  if bf_gds-prt.node-name <> {&empty-scale} then do:
    find first bf-trb_parts where bf-trb_parts.out-code  = bf_trn-doc.doc-code and
                                  bf-trb_parts.obj-type  = bf_trn-doc.obj-type and
                                  bf-trb_parts.obj-code  = bf_trn-doc.obj-code and
                                  bf-trb_parts.artic     = bf_goods.artic      and
                                  bf-trb_parts.prod-type = bf_goods.prod-type  and
                                  bf-trb_parts.prod-code = bf_goods.prod-code  and
                                  bf-trb_parts.fact-qnty > 0                   no-error.
    if available bf-trb_parts then do:
      message "По товару с признаками " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " есть оприходования." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
    assign
      varhave-another-goods =no.
    for each bf-trb_parts-root where bf-trb_parts-root.doc-code      = bf_trn-doc.doc-code    and
                                     bf-trb_parts-root.orig-gds-code = bf_goods.gds-code      and
                                     bf-trb_parts-root.gds-code     <> bf-plus_goods.gds-code on error undo, return no-apply return-value :
      assign
        varhave-another-goods = yes.
    end.
    if varhave-another-goods then do:
      message "По товару с признаками " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " есть списания в связке с другим товарам." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
  end.
  find first bf-plus_gds-prt where bf-plus_gds-prt.upper-code = bf-plus_goods.prt-root no-lock.
  if bf_gds-prt.node-name <> {&empty-scale} then do:
    find first bf-trb_parts where bf-trb_parts.out-code  = bf_trn-doc.doc-code      and
                                  bf-trb_parts.obj-type  = bf_trn-doc.obj-type      and
                                  bf-trb_parts.obj-code  = bf_trn-doc.obj-code      and
                                  bf-trb_parts.artic     = bf-plus_goods.artic      and
                                  bf-trb_parts.prod-type = bf-plus_goods.prod-type  and
                                  bf-trb_parts.prod-code = bf-plus_goods.prod-code  and
                                  bf-trb_parts.fact-qnty < 0                        no-error.
    if available bf-trb_parts then do:
      message "По товару с признаками " bf-plus_goods.artic " " bf-plus_goods.prod-type " " bf-plus_goods.prod-code " " bf-plus_goods.gds-name " есть списания." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
    assign
      varhave-another-goods =no.
    for each bf-trb_parts-root where bf-trb_parts-root.doc-code       = bf_trn-doc.doc-code    and
                                     bf-trb_parts-root.gds-code       = bf-plus_goods.gds-code and
                                     bf-trb_parts-root.orig-gds-code <> bf_goods.gds-code      on error undo, return no-apply return-value :
      assign
        varhave-another-goods = yes.
    end.
    if varhave-another-goods then do:
      message "По товару с признаками " bf-plus_goods.artic " " bf-plus_goods.prod-type " " bf-plus_goods.prod-code " " bf-plus_goods.gds-name " есть оприходования в связке другим товарам." skip
              "Редактирование возможно через удаление и добавление."
      view-as alert-box.
      return no-apply.
    end.
  end.
  run local-chg in this-procedure no-error.
  if error-status:error then do:
    message "Ошибка при изменении строк пересортицы." skip
    return-value
    view-as alert-box error.
    return no-apply.
  end.
  run proc-get-write-off in this-procedure (buffer bf_doc-line).
  run ui-on in this-procedure ("":u) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cnt Dialog-Frame
ON CHOOSE OF b-cnt IN FRAME Dialog-Frame /* ДогП */
DO:
  { gbl/stdbtn.i }
  define variable varlog as logical no-undo.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    bf_trn-doc.host-code
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if not varlog then do:
    return no-apply.
  end.
  run str/scntdoc.w ( input bf_trn-doc.doc-code, input ( v-cntxt-db-num = bf_sysconf.firm-db-num ) ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
define variable varrep-rec as recid no-undo.
run local-del in this-procedure (output varrep-rec) no-error.
if error-status:error then do:
  message
  "Ошибка при удалении строк пересортицы."  skip
  return-value
  view-as alert-box error.
  return no-apply.
end.
run ui-on IN THIS-PROCEDURE ("":u).
apply "entry" to b-goods- in frame {&frame-name} .
if varrep-rec <> ? then do:
  reposition b-goods- to recid varrep-rec no-error.
end.
APPLY "value-changed" TO b-goods- IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }
    parnext-prev = ? .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-goods
&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON F9 OF b-goods IN FRAME Dialog-Frame /* Оприходованные товары */
DO:
  define buffer bfl_goods for ub.goods.
  if not available bf-plus_doc-line THEN do:
    return no-apply.
  END.
  find first bfl_goods where bfl_goods.artic     = bf-plus_doc-line.artic     and
                             bfl_goods.prod-type = bf-plus_doc-line.prod-type and
                             bfl_goods.prod-code = bf-plus_doc-line.prod-code no-lock.
  run str/showgds.p
    (input parparentproc
    ,input ?
    ,input bfl_goods.gds-code
    ,input {&lookup}
    ).
  apply "entry" to b-goods- in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-goods-
&Scoped-define SELF-NAME b-goods-
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods- Dialog-Frame
ON F9 OF b-goods- IN FRAME Dialog-Frame /* Списанные товары */
DO:
  define buffer bfl_goods for ub.goods.
  if not available bf_doc-line THEN do:
    return no-apply.
  END.
  find first bfl_goods where bfl_goods.artic     = bf_doc-line.artic     and
                             bfl_goods.prod-type = bf_doc-line.prod-type and
                             bfl_goods.prod-code = bf_doc-line.prod-code no-lock.
  run str/showgds.p
    (input parparentproc
    ,input ?
    ,input bfl_goods.gds-code
    ,input {&lookup}
    ).
  apply "entry" to b-goods- in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods- Dialog-Frame
ON VALUE-CHANGED OF b-goods- IN FRAME Dialog-Frame /* Списанные товары */
DO:
  {&open-query-b-goods}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable varoutgds-code      like ub.goods.gds-code no-undo.
define variable varoutgds-code-plus like ub.goods.gds-code no-undo.
define variable varqnty             as   decimal           no-undo.
define variable varqnty-kg          as   decimal           no-undo.
define variable varqnty-plus        as   decimal           no-undo.
define variable varqnty-kg-plus     as   decimal           no-undo.
define variable varoutqnty          as   decimal           no-undo.
define variable varoutqnty-plus     as   decimal           no-undo.
define variable varoutqnty-kg       as   decimal           no-undo.
define variable varoutqnty-kg-plus  as   decimal           no-undo.
define variable varset              as   logical           no-undo.
DEFINE BUFFER bf_parts-root FOR ub.parts-root.
DEFINE BUFFER bf_parts FOR ub.parts.
IF NOT AVAILABLE bf_goods THEN DO:
  MESSAGE "Не выбрана линия списываемого товара." VIEW-AS ALERT-BOX.
  RETURN NO-APPLY.
END.
IF NOT AVAILABLE bf-plus_goods THEN DO:
  MESSAGE "Не выбрана линия оприходуемого товара." VIEW-AS ALERT-BOX.
  RETURN NO-APPLY.
END.
ASSIGN
  varqnty      = 0.00
  varqnty-plus = 0.00.
FOR EACH bf_parts-root WHERE bf_parts-root.doc-code      = bf_trn-doc.doc-code AND
                             bf_parts-root.orig-gds-code = bf_goods.gds-code   AND
                             bf_parts-root.gds-code      = bf-plus_goods.gds-code
                             USE-INDEX pi ON ERROR UNDO, RETURN NO-APPLY RETURN-VALUE :
  FIND FIRST bf_parts WHERE bf_parts.obj-type  = bf_trn-doc.obj-type      AND
                            bf_parts.obj-code  = bf_trn-doc.obj-code      AND
                            bf_parts.artic     = bf-plus_goods.artic      AND
                            bf_parts.prod-type = bf-plus_goods.prod-type  AND
                            bf_parts.prod-code = bf-plus_goods.prod-code  AND
                            bf_parts.in-code   = bf_parts-root.in-code    AND
                            bf_parts.out-code  = bf_parts-root.doc-code   AND
                            bf_parts.part-code = bf_parts-root.part-code  .
  ASSIGN
    varqnty      = varqnty      + bf_parts.real-qnty
    varqnty-plus = varqnty-plus + bf_parts.fact-qnty.
END.
run str/prst-gds.w (input  parparentproc,
                input  bf_trn-doc.doc-code,
                input  {&LOOKUP},
                input  bf_trn-doc.obj-type,
                input  bf_trn-doc.obj-code,
                input  bf_goods.gds-code,
                input  bf-plus_goods.gds-code,
                input  varqnty,
                input  ?,
                input  varqnty-plus,
                input  ?,
                input  varpstunqtn-log,
                input  varpstunit,
                input  varmxpcicp-dec,
                input  varmxpcdcp-dec,
                input  varmxsmicp-dec,
                input  varmxsmdcp-dec,
                output varoutgds-code,
                output varoutgds-code-plus,
                output table tt-gds-dtl,
                output table tt-pl-qty,
                output varoutqnty,
                output varoutqnty-plus,
                output varoutqnty-kg,
                output varoutqnty-kg-plus,
                output table tt-gds-dtl-plus,
                output table tt-pl-qty-plus,
                output varset).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
  { gbl/stdbtn.i }
  run proc-history in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  run mark-list in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-notes Dialog-Frame
ON CHOOSE OF b-notes IN FRAME Dialog-Frame /* Примеч */
DO:
  { gbl/stdbtn.i }
  run notes-tr in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts Dialog-Frame
ON CHOOSE OF b-parts IN FRAME Dialog-Frame /* ПартСпис */
DO:
  DEFINE VARIABLE varprt-rec AS RECID NO-UNDO.
  if not available bf_doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return NO-APPLY.
  end.
  assign
    line-rec = recid( bf_doc-line )
  .
  run str/parts-l.w
    (  input parparentproc
    ,  input bf_trn-doc.obj-type
    ,  input bf_trn-doc.obj-code
    ,  input bf_goods.gds-code
    ,  input bf_doc-line.doc-code
    ,  input {&LOOKUP} /*pardoc-mode  BTS-2570  */            /* p-edit-mode  */
    ,  input {&parts-l_parts-document} /* p-r-parts    */
    ,  input {&parts-l_object-current} /* p-one-all    */
    , input {&parts-l_call-document}
    , output varprt-rec
    ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts-plus Dialog-Frame
ON CHOOSE OF b-parts-plus IN FRAME Dialog-Frame /* ПартОприх */
DO:
  DEFINE VARIABLE varprt-rec AS RECID NO-UNDO.
  if not available bf-plus_doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return NO-APPLY.
  end.
  assign
    line-rec = recid( bf-plus_doc-line )
  .
  run str/parts-l.w
    (  input parparentproc
    ,  input bf_trn-doc.obj-type
    ,  input bf_trn-doc.obj-code
    ,  input bf-plus_goods.gds-code
    ,  input bf-plus_doc-line.doc-code
    ,  input {&LOOKUP}                 /* p-edit-mode  */
    ,  input {&parts-l_parts-document} /* p-r-parts    */
    ,  input {&parts-l_object-current} /* p-one-all    */
    ,  input {&parts-l_call-document}  /* p-call-point */
    , output varprt-rec
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sum-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sum-doc Dialog-Frame
ON CHOOSE OF b-sum-doc IN FRAME Dialog-Frame /* СумДок */
DO:
  run str/vsumtype.w ( input yes, input bf_trn-doc.doc-code, input ? ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sum-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sum-goods Dialog-Frame
ON CHOOSE OF b-sum-goods IN FRAME Dialog-Frame /* СумТовСп */
DO:

  if available bf_goods then do:
    run str/vsumtype.w ( input no, input bf_trn-doc.doc-code, input bf_goods.gds-code ).
  end.
  ELSE DO:
    MESSAGE "Не выбрана строка списываемого товара." VIEW-AS ALERT-BOX.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sum-goods-plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sum-goods-plus Dialog-Frame
ON CHOOSE OF b-sum-goods-plus IN FRAME Dialog-Frame /* СумТовОп */
DO:
  if available bf-plus_goods then do:
    run str/vsumtype.w ( input no, input bf_trn-doc.doc-code, input bf-plus_goods.gds-code ).
  end.
  ELSE DO:
    MESSAGE "Не выбрана строка оприходуемого товара." VIEW-AS ALERT-BOX.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-agnt Dialog-Frame
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ("agnt", "button").
  apply "entry" to varboss in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-boss Dialog-Frame
ON CHOOSE OF r-boss IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ("boss", "button").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-reas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-reas Dialog-Frame
ON CHOOSE OF r-reas IN FRAME Dialog-Frame
DO:
  run select-reason in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sht
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sht Dialog-Frame
ON CHOOSE OF r-sht IN FRAME Dialog-Frame
DO:
  define buffer bf-chk_doc-line for ub.doc-line.
  find first bf-chk_doc-line where bf-chk_doc-line.doc-code = bf_trn-doc.doc-code no-error.
  if available bf-chk_doc-line then do:
    message "В документе уже есть строки. Не допускается изменение фактической даты." view-as alert-box.
    return no-apply.
  end.
  run proc-shift-num in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  run proc-sht in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr Dialog-Frame
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO:
  run local-psn-chk in this-procedure ("wrkr", "button").
  apply "entry" to varagnt in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varagnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varagnt Dialog-Frame
ON LEAVE OF varagnt IN FRAME Dialog-Frame /* Исп */
DO:
  if input frame {&frame-name} varagnt <> varagnt then do:
    run local-psn-chk in this-procedure ("agnt", "leave").
    apply "entry" to varboss in frame {&frame-name}.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varagnt Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varagnt IN FRAME Dialog-Frame /* Исп */
DO:
    run local-psn-chk in this-procedure ("agnt", "ret-mouse").
    apply "entry" to varboss in frame {&frame-name}.
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varagnt Dialog-Frame
ON return OF varagnt IN FRAME Dialog-Frame /* Исп */
DO:
  run local-psn-chk in this-procedure ("agnt", "ret-mouse").
  apply "entry" to varboss in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varboss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varboss Dialog-Frame
ON LEAVE OF varboss IN FRAME Dialog-Frame /* М-р */
DO:
  if input frame {&frame-name} varboss <> varboss then do:
    run local-psn-chk in this-procedure ("boss", "leave").
    apply "entry" to b-exit in frame {&frame-name}.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varboss Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varboss IN FRAME Dialog-Frame /* М-р */
DO:
  RUN local-psn-chk in this-procedure ("boss", "ret-mouse").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varboss Dialog-Frame
ON RETURN OF varboss IN FRAME Dialog-Frame /* М-р */
DO:
    RUN local-psn-chk in this-procedure ("boss", "ret-mouse").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varfact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varfact-date Dialog-Frame
ON LEAVE OF varfact-date IN FRAME Dialog-Frame /* Факт */
DO:
  run chk-upd-date IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varshift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-date Dialog-Frame
ON LEAVE OF varshift-date IN FRAME Dialog-Frame /* Смена */
DO:
  define buffer bf-chk_doc-line for ub.doc-line.
  if input frame {&frame-name} varshift-date <> varshift-date then do:
    /*
    find first bf-chk_doc-line where bf-chk_doc-line.doc-code = bf_trn-doc.doc-code no-error.
    if available bf-chk_doc-line then do:
      message "В документе уже есть строки. Не допускается изменение фактической даты." view-as alert-box.
      display varshift-date with frame {&frame-name}.
      apply "entry" to browse {&browse-name}.
      return no-apply.
    end.
    */
    assign
      varshift-name   = ""
      bf_trn-doc.shift-num = 0.
    display varshift-name bf_trn-doc.shift-num @ varshift-num with frame {&frame-name}.
    apply "entry" to varshift-name in frame {&frame-name}.
    return no-apply.
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-date Dialog-Frame
ON return OF varshift-date IN FRAME Dialog-Frame /* Смена */
DO:
  apply "entry" to varshift-name in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varshift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-name Dialog-Frame
ON LEAVE OF varshift-name IN FRAME Dialog-Frame /* № */
DO:
  DEFINE BUFFER bf-chk_doc-line FOR ub.doc-line.
  IF INPUT FRAME {&FRAME-NAME} varshift-name <> varshift-name THEN DO:
    /*
    FIND FIRST bf-chk_doc-line WHERE bf-chk_doc-line.doc-code = bf_trn-doc.doc-code NO-ERROR.
    IF AVAILABLE bf-chk_doc-line THEN DO:
      MESSAGE "В документе уже есть строки. Не допускается изменение фактической даты." VIEW-AS ALERT-BOX.
      DISPLAY varshift-name WITH FRAME {&FRAME-NAME}.
      APPLY "entry" TO BROWSE {&browse-name}.
      RETURN NO-APPLY.
    END.
    */
    run proc-shift-name in this-procedure no-error.
    if error-status:error then do:
      return no-apply.
    end.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-name Dialog-Frame
ON return OF varshift-name IN FRAME Dialog-Frame /* № */
DO:
    apply "entry" to b-add in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varshift-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-num Dialog-Frame
ON LEAVE OF varshift-num IN FRAME Dialog-Frame /* П */
DO:
define buffer bf-chk_doc-line for ub.doc-line.
if input frame {&frame-name} varshift-num <> varshift-num then do:
  /*
  find first bf-chk_doc-line where bf-chk_doc-line.doc-code = bf_trn-doc.doc-code no-error.
  if available bf-chk_doc-line then do:
    message "В документе уже есть строки. Не допускается изменение фактической даты." view-as alert-box.
    display varshift-num with frame {&frame-name}.
    apply "entry" to browse {&browse-name}.
    return no-apply.
  end.
  */
  run proc-shift-num in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varshift-num Dialog-Frame
ON return OF varshift-num IN FRAME Dialog-Frame /* П */
DO:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varwrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwrkr Dialog-Frame
ON LEAVE OF varwrkr IN FRAME Dialog-Frame /* Кл-к */
DO:
  if input frame {&frame-name} varwrkr <> varwrkr then do:
    run local-psn-chk in this-procedure ("wrkr", "leave").
    apply "entry" to varagnt in frame {&frame-name}.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwrkr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF varwrkr IN FRAME Dialog-Frame /* Кл-к */
DO:
    RUN local-psn-chk in this-procedure ("wrkr", "ret-mouse").
  apply "entry" to varagnt in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwrkr Dialog-Frame
ON RETURN OF varwrkr IN FRAME Dialog-Frame /* Кл-к */
DO:
    RUN local-psn-chk in this-procedure ("wrkr", "ret-mouse").
  apply "entry" to varagnt in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
assign
  r-reas         :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа. Вызов справочника"
  varreason-code :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа. Ввод кода"
  varreason-name :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
.

{ gbl/mv-clmn.i
  &ext-col      = 11
  &frame-name   = {&frame-name}
  &browse-name  = b-goods-
  &start-column = 3
}

{ gbl/mv-clmn.i
  &ext-col      = 14
  &frame-name   = {&frame-name}
  &browse-name  = b-goods
  &start-column = 2
}

{ gbl/srt-clmn.i
  &browse-name   = b-goods-
  &frame-name    = {&frame-name}
  &table-name    = "bf_doc-line"
  &ext-col       = 11
  &start-column  = 3
  &label-clmn_1  = "{&label-clmn_1-b-}"
  &sort-clmn_1   = "{&sort-clmn_1-b-}"
  &label-clmn_2  = "{&label-clmn_2-b-}"
  &sort-clmn_2   = "{&sort-clmn_2-b-}"
  &label-clmn_3  = "{&label-clmn_3-b-}"
  &sort-clmn_3   = "{&sort-clmn_3-b-}"
  &label-clmn_4  = "{&label-clmn_4-b-}"
  &sort-clmn_4   = "{&sort-clmn_4-b-}"
  &label-clmn_5  = "{&label-clmn_5-b-}"
  &sort-clmn_5   = "{&sort-clmn_5-b-}"
  &label-clmn_6  = "{&label-clmn_6-b-}"
  &sort-clmn_6   = "{&sort-clmn_6-b-}"
  &label-clmn_7  = "{&label-clmn_7-b-}"
  &sort-clmn_7   = "{&sort-clmn_7-b-}"
  &label-clmn_8  = "{&label-clmn_8-b-}"
  &sort-clmn_8   = "{&sort-clmn_8-b-}"
  &label-clmn_9  = "{&label-clmn_9-b-}"
  &sort-clmn_9   = "{&sort-clmn_9-b-}"
  &label-clmn_10 = "{&label-clmn_10-b-}"
  &sort-clmn_10   = "{&sort-clmn_10-b-}"
  &label-clmn_11 = "{&label-clmn_11-b-}"
  &sort-clmn_11   = "{&sort-clmn_11-b-}"
  &open-query = "open query b-goods- {&query-string-b-goods-} by ~{&sort-clmn_~{&clmn_num~}~} ."
  &open-query-otherwise = "{&open-query-b-goods-}"
  &re-move-clmn = "yes"
  &mv-brw-default = "yes"
}
{ gbl/srt-clmn.i
  &browse-name   = b-goods
  &frame-name    = {&frame-name}
  &table-name    = "bf-plus_doc-line"
  &ext-col       = 14
  &start-column  = 2
  &label-clmn_1  = "{&label-clmn_1-b}"
  &sort-clmn_1   = "{&sort-clmn_1-b}"
  &label-clmn_2  = "{&label-clmn_2-b}"
  &sort-clmn_2   = "{&sort-clmn_2-b}"
  &label-clmn_3  = "{&label-clmn_3-b}"
  &sort-clmn_3   = "{&sort-clmn_3-b}"
  &label-clmn_4  = "{&label-clmn_4-b}"
  &sort-clmn_4   = "{&sort-clmn_4-b}"
  &label-clmn_5  = "{&label-clmn_5-b}"
  &sort-clmn_5   = "{&sort-clmn_5-b}"
  &label-clmn_6  = "{&label-clmn_6-b}"
  &sort-clmn_6   = "{&sort-clmn_6-b}"
  &label-clmn_7  = "{&label-clmn_7-b}"
  &sort-clmn_7   = "{&sort-clmn_7-b}"
  &label-clmn_8  = "{&label-clmn_8-b}"
  &sort-clmn_8   = "{&sort-clmn_8-b}"
  &label-clmn_9  = "{&label-clmn_9-b}"
  &sort-clmn_9   = "{&sort-clmn_9-b}"
  &label-clmn_10 = "{&label-clmn_10-b}"
  &sort-clmn_10  = "{&sort-clmn_10-b}"
  &label-clmn_11 = "{&label-clmn_11-b}"
  &sort-clmn_11  = "{&sort-clmn_11-b}"
  &label-clmn_12 = "{&label-clmn_12-b}"
  &sort-clmn_12  = "{&sort-clmn_12-b}"
  &label-clmn_13 = "{&label-clmn_13-b}"
  &sort-clmn_13  = "{&sort-clmn_13-b}"
  &label-clmn_14 = "{&label-clmn_14-b}"
  &sort-clmn_14  = "{&sort-clmn_14-b}"
  &open-query = "open query b-goods {&query-string-b-goods} by ~{&sort-clmn_~{&clmn_num~}~} ."
  &open-query-otherwise = "{&open-query-b-goods}"
  &re-move-clmn = "yes"
  &mv-brw-default = "yes"
}

{ gbl/hot-key.i b-lkp  }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
{ gbl/hot-key.i b-mark }
{ gbl/ed_date.i varfact-date  }
{ gbl/ed_date.i varshift-date }
{ str/n-p-l.i
  &bf-trn-doc = "bf_trn-doc"
  &doc-rec    = "pardoc-rec"
}
assign
  b-goods-:allow-column-searching in frame  {&frame-name}  = yes
  b-goods:allow-column-searching  in frame  {&frame-name}  = yes
  b-goods-:num-locked-columns     in frame  {&frame-name}  = 2
  b-goods:num-locked-columns      in frame  {&frame-name}  = 1
  {&sort-clmn_3-b-}:resizable     in browse b-goods-       = yes
  {&sort-clmn_3-b-}:width-chars   in browse b-goods-       = 20
  {&sort-clmn_2-b}:resizable      in browse b-goods        = yes
  {&sort-clmn_2-b}:width-chars    in browse b-goods        = 20
  frame {&frame-name}:scrollable                           = false
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '{&delim-flt}':U ) > 1 then entry( 2, pardoc-mode, '{&delim-flt}':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '{&delim-flt}':U )
.

.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/* зацикливание формы */
assign parnext-prev = yes.
n-p:
do while parnext-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curr-r-b.i varr-b }
  find first bf-obj_clients where bf-obj_clients.obj-type = parobj-type and
                                  bf-obj_clients.obj-code = parobj-code no-lock.
  find first bf-host_clients where bf-host_clients.obj-type = {&cmp}                   and
                                   bf-host_clients.obj-code = bf-obj_clients.host-code no-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf-obj_clients.host-code no-lock.
  run mode-on in this-procedure no-error.
  if error-status:error then do:
    assign
      parnext-prev = no.
    return error.
  end.
  run ui-on in this-procedure ( input "":U ) no-error.
  if error-status:error then do:
    assign
      parnext-prev = no.
    return error.
  end.
  run enable_ui no-error.
  if error-status:error then do:
    assign
      parnext-prev = no.
    return error.
  end.

    { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'pstgrp' then vargrp-is-eq = thbjattr_thbj-attr.property-value-logical.
        if thbjattr_thbj-attr.prop-code = 'pstunit' then varpstunit = thbjattr_thbj-attr.property-value-logical.
        if thbjattr_thbj-attr.prop-code = 'pstunqtn' then varpstunqtn-log = thbjattr_thbj-attr.property-value-logical.
        if thbjattr_thbj-attr.prop-code = 'mxpcicp' then varmxpcicp-dec = thbjattr_thbj-attr.property-value-decimal.
        if thbjattr_thbj-attr.prop-code = 'mxpcdcp' then varmxpcdcp-dec = thbjattr_thbj-attr.property-value-decimal.
        if thbjattr_thbj-attr.prop-code = 'mxsmicp' then varmxsmicp-dec = thbjattr_thbj-attr.property-value-decimal.
        if thbjattr_thbj-attr.prop-code = 'mxsmdcp' then varmxsmdcp-dec = thbjattr_thbj-attr.property-value-decimal.
    end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-doc Dialog-Frame
PROCEDURE add-doc :
define output parameter parrecid as recid no-undo.
define variable vardoc-code   like ub.trn-doc.doc-code    no-undo.
define variable v-today       as date                     no-undo.
define variable varbase-rate  as decimal no-undo.
define variable varbase-scale as decimal no-undo.
define variable varsupp-code  as integer   no-undo.
define variable varsupp-type  as character no-undo.
define variable varsupp-name  as character no-undo.
define buffer bf_pay-type     for ub.pay-type.
define buffer bf-supp_clients for ub.clients.
define buffer bf_sys-ctrl     for ub.sys-ctrl.
define buffer bf_store for ub.store.
define buffer bf_shop  for ub.shop.

do on error undo, return error RETURN-VALUE :
  if not parold-supp-cntr then do:
    FIND FIRST bf-supp_clients WHERE bf-supp_clients.obj-type = parcli-type AND
                                     bf-supp_clients.obj-code = parcli-code NO-LOCK.
    ASSIGN
      varcli-type = bf-supp_clients.obj-type
      varcli-code = bf-supp_clients.obj-code
      varcli-name = bf-supp_clients.obj-name.
  end.
  if bf-obj_clients.obj-type = {&shop} then do:
    find first bf_shop where bf_shop.obj-code = bf-obj_clients.obj-code no-lock.
    FIND FIRST bf_pay-type where bf_pay-type.obj-code = bf_shop.inv-pay NO-LOCK NO-ERROR.
  end.
  else do:
    find first bf_store where bf_store.obj-code = bf-obj_clients.obj-code no-lock.
    FIND FIRST bf_pay-type where bf_pay-type.obj-code = bf_store.inv-pay NO-LOCK NO-ERROR.
  end.
  if not AVAILABLE bf_pay-type then do:
    message "Не задан код оплаты для инвентаризации в настройках по текущему объекту." VIEW-AS ALERT-BOX.
    return error.
  end.
  find first bf_sys-ctrl no-lock.
  run doc-code in this-procedure
  (input  "main",
   input  parobj-type,
   input  parobj-code,
   input  ?,
   output vardoc-code ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при генерации номера документа." skip
      return-value skip
      view-as alert-box error.
    undo, return error .
  end.
  { gbl/curobjdt.i parobj-type parobj-code v-today NO-ERROR }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении даты объекта." skip
      return-value skip
      view-as alert-box error.
    undo, return error .
  end.
  { gbl/baserate.i bf-obj_clients.host-code v-today varbase-rate varbase-scale NO-ERROR }
  if not parold-supp-cntr then do:
    assign
      varsupp-code = bf-supp_clients.obj-code
      varsupp-type = bf-supp_clients.obj-type
      varsupp-name = bf-supp_clients.obj-name
    .
  end.
  else do:
    assign
      varsupp-code = bf-host_clients.obj-code
      varsupp-type = bf-host_clients.obj-type
      varsupp-name = bf-host_clients.obj-name
    .
  end.
  { str/crtrndoc.i
    ?
    ?
    varbase-rate
    varbase-scale
    varsupp-code
    varsupp-type
    varsupp-name
    v-cntxt-db-num
    v-cntxt-userid
    "' '"
    vardoc-code
    v-today
    {&inventory}
    no
    bf-host_clients.obj-code
    no
    parobj-code
    parobj-type
    no
    bf_pay-type.obj-code
    "'@  '"
    no
    "{&without-slt}"
    {&wayb}
    "{&inc-vat}"
    {&TDEDT_Peresort}
    ?
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка создания документа." skip
      return-value skip
      view-as alert-box error.
    undo, return error .
  end.
  find bf_trn-doc where bf_trn-doc.doc-code = vardoc-code EXCLUSIVE-LOCK.
  if not parold-supp-cntr then do:
    ASSIGN
      bf_trn-doc.contract-code = parcontract-code.
  end.
  else do:
    assign
      bf_trn-doc.contract-code = 0.
    { str/tdat-wrt.i
       bf_trn-doc.doc-code
      {&trdcattr-oldsuppcntr}
      "'yes'"
      }
  end.
  assign
    pardoc-rec  = recid( bf_trn-doc )
    pardoc-mode = {&update}.
  assign parrecid = recid( bf_trn-doc ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-upd-date Dialog-Frame
PROCEDURE chk-upd-date :
define variable vartoday as date      no-undo.
define variable vartime  as integer   no-undo.
DEFINE VARIABLE varlog   AS LOGICAL   NO-UNDO.
if input frame {&frame-name} varfact-date  <> varfact-date then do:
  { gbl/curobjdt.i bf_trn-doc.obj-type bf_trn-doc.obj-code vartoday }
  if input frame {&frame-name} varfact-date > vartoday then do:
     message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
     display varfact-date with frame {&frame-name}.
     return error.
  end.
  if input frame {&frame-name} varfact-date < vartoday - 7 then do:
     ASSIGN
       varlog = yes.
     message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
             "Отказаться от заведения даты?" view-as alert-box question
             buttons yes-no update varlog.
     if varlog then do:
        display varfact-date with frame {&frame-name}.
        return error.
     end.
  end.

define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .

      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input {&attr-nakl_par}
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display varfact-date with frame {&frame-name}.
      return error.
    end.

  assign
    varlog = no
  .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_tdedt-peresort_add-back-date':u
    {&cntxt-object}
    bf_trn-doc.host-code
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    0
    0
    0
    true
    varlog
  }

  if varlog <> YES then do:
     display varfact-date with frame {&frame-name}.
     return error.
  end.
  ASSIGN
    varlog = no.
  message "Вы хотите изменить фактическую дату?" skip
          "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
  view-as alert-box question buttons yes-no update varlog.
  if not varlog then do:
    display varfact-date with frame {&frame-name}.
    return error.
  end.
  assign frame {&frame-name}
    varfact-date.
  assign
    bf_trn-doc.fact-date = varfact-date
    bf_trn-doc.fact-time = (24 * 60 * 60).
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
  DISPLAY varwrkr varwrkr-name vardoc-date varagnt varagnt-name varfact-date
          varboss varboss-name varshift-date varshift-name varshift-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-prev b-next b-sum-doc b-arch b-notes b-cnt b-history b-help
         b-lkp b-parts b-parts-plus b-sum-goods b-sum-goods-plus b-goods-
         b-goods
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-add Dialog-Frame
PROCEDURE local-add :
define variable varrec-minus-line as recid no-undo.
define variable varrec-plus-line  as recid no-undo.
define variable varadd as logical no-undo.
define buffer bf-add_doc-line      for ub.doc-line.
define buffer bf-add-plus_doc-line for ub.doc-line.
run str/pstlnadd.p
  (input  parparentproc,
   input  this-procedure,
   input  bf_trn-doc.doc-code,
   input  parold-supp-cntr,
   input  varpstunqtn-log,
   input  varmxpcicp-dec,
   input  varmxpcdcp-dec,
   input  varmxsmicp-dec,
   input  varmxsmdcp-dec,
   input  vargrp-is-eq,
   input  varpstunit,
   output varrec-minus-line,
   output varrec-plus-line,
   output varadd)         no-error.
if error-status:error then do:
  return error return-value.
end.
if varadd = yes then do:
  for each tt-recalc-line on error undo, return error return-value :
    delete tt-recalc-line.
  end.
  find first bf-add_doc-line      where recid(bf-add_doc-line)      = varrec-minus-line.
  run proc-get-write-off in this-procedure (buffer bf-add_doc-line).
  create tt-recalc-line.
  buffer-copy bf-add_doc-line to tt-recalc-line.
  find first bf-add-plus_doc-line where recid(bf-add-plus_doc-line) = varrec-plus-line.
  run proc-get-write-off in this-procedure (buffer bf-add-plus_doc-line).
  create tt-recalc-line.
  buffer-copy bf-add-plus_doc-line to tt-recalc-line.
  run recalc-line in this-procedure no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при пересчете строк документа: ", return-value).
  end.
  run ui-on in this-procedure ("":u) .
  reposition b-goods- to recid varrec-minus-line.
  APPLY "value-changed" TO b-goods- IN FRAME {&FRAME-NAME}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-chg Dialog-Frame
PROCEDURE local-chg :
define variable varchg as logical no-undo.
do on error undo, return error return-value :
run str/pstlnupd.p
  (input  parparentproc,
   input  this-procedure,
   input  bf_trn-doc.doc-code,
   input  parold-supp-cntr,
   input  varpstunqtn-log,
   input  varpstunit,
   input  varmxpcicp-dec,
   input  varmxpcdcp-dec,
   input  varmxsmicp-dec,
   input  varmxsmdcp-dec,
   input  recid(bf_doc-line),
   input  recid(bf-plus_doc-line),
   output varchg) no-error.
if error-status:error then do:
  return error return-value.
end.
if varchg = yes then do:
  for each tt-recalc-line on error undo, return error return-value :
    delete tt-recalc-line.
  end.
  create tt-recalc-line.
  buffer-copy bf_doc-line to tt-recalc-line.
  create tt-recalc-line.
  buffer-copy bf-plus_doc-line to tt-recalc-line.
  run recalc-line in this-procedure no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при пересчете строк документа: ", return-value).
  end.
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-del Dialog-Frame
PROCEDURE local-del :
do on error undo, return error return-value :
  { str/pstlndel.i }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-line-delete Dialog-Frame
PROCEDURE local-line-delete :
define input parameter parrec-line as recid no-undo.
define buffer bf_doc-line for ub.doc-line.
DEFINE BUFFER bf_gds-dtl  FOR ub.gds-dtl.
define variable l-inv-on as logical no-undo.
do on error undo, return error return-value :
find first bf_doc-line where recid(bf_doc-line) = parrec-line.
FOR EACH bf_gds-dtl WHERE bf_gds-dtl.doc-code  = bf_doc-line.doc-code  AND
                          bf_gds-dtl.artic     = bf_doc-line.artic     AND
                          bf_gds-dtl.prod-type = bf_doc-line.prod-type AND
                          bf_gds-dtl.prod-code = bf_doc-line.prod-code EXCLUSIVE-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  DELETE bf_gds-dtl.
END.
{ gbl/gdsobjat.i
  bf_doc-line.obj-type
  bf_doc-line.obj-code
  bf_doc-line.artic
  bf_doc-line.prod-type
  bf_doc-line.prod-code
  "'inv-on=false'"
  l-inv-on
  no-error
}
if error-status :error then do:
  undo, return error SUBSTITUTE ("Ошибка установки атрибута товара на объекте. Документ &1. Объект &2 &3. Артикул &4 &5 &6. Признак товара в инвентаризации &7.",
                                 bf_doc-line.doc-code, bf_doc-line.obj-type, bf_doc-line.obj-code, bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code, l-inv-on).
end.
find first tt-recalc-line where tt-recalc-line.doc-code  = bf_doc-line.doc-code  and
                                tt-recalc-line.artic     = bf_doc-line.artic     and
                                tt-recalc-line.prod-type = bf_doc-line.prod-type and
                                tt-recalc-line.prod-code = bf_doc-line.prod-code no-error.
if available tt-recalc-line then do:
  delete tt-recalc-line.
end.
delete bf_doc-line.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk Dialog-Frame
PROCEDURE local-psn-chk :
define input parameter parman    as character no-undo.
define input parameter paraction as character no-undo.
DEFINE BUFFER cli-buf FOR ub.clients.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.

&SCOPED-DEFINE choose-cli-buf ~
  if not available cli-buf or ( NOT can-do( {&prs}, cli-buf.obj-type ) ) then do: ~
    if input frame {&frame-name} ~{&work-entity~} <> ""                             ~
         and input frame {&frame-name} ~{&work-entity~} <> ? THEN DO:               ~
            message "Из справочника клиентов Вы должны выбрать человека.".          ~
    END.                                                                            ~
    run ref/cli-all.w (  input parparentproc                                            ~
                      ,  input "b-sel"                                                  ~
                      ,  input {&prs}                                                   ~
                      ,  input ?                                                        ~
                      ,  input ?                                                        ~
                      ,  input ref-rec                                                  ~
                      ,  input ?                                                        ~
                      ,  input ?                                                        ~
                      , output ref-list ) .                                             ~
    assign ref-rec = integer (ref-list).                                            ~
    find cli-buf where recid (cli-buf) = ref-rec no-lock no-error.                  ~
    if not available cli-buf or ( NOT can-do( {&prs}, cli-buf.obj-type ) ) then do:    ~
        find cli-buf where cli-buf.obj-code = input frame {&frame-name} ~{&work-entity~}     ~
                             and cli-buf.obj-type = {&prs} no-lock no-error.                 ~
    end.                                                                                     ~
  end.

&scoped-define find-cli-buf      find cli-buf where cli-buf.obj-code = input frame {&frame-name} ~{&work-entity~} ~
                                                and cli-buf.obj-type = {&prs} no-lock no-error.

&SCOPED-DEFINE button-cli-buf    find FIRST cli-buf where cli-buf.obj-code = input frame {&frame-name} ~{&work-entity~} ~
                                                      and cli-buf.obj-type = {&prs} no-lock no-error.                   ~
               assign ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).                                  ~
               release cli-buf.

&SCOPED-DEFINE display-cli-buf    if available cli-buf and can-do({&prs}, cli-buf.obj-type) then do:                                                            ~
                                     disp cli-buf.obj-code @ ~{&work-entity~} cli-buf.obj-name @ ~{&work-entity~}-name with frame {&frame-name}. ~
                                     assign frame {&frame-name} ~{&work-entity~}.    ~
                                     DO TRANSACTION ON ERROR UNDO, RETURN ERROR RETURN-VALUE : ~
                                       ASSIGN ~
                                        ~{&db-entity~} = ~{&work-entity~}. ~
                                     END. ~
                                  end.                                                                                     ~
                                  else do:                                                                                 ~
                                    disp ? @ ~{&work-entity~} ? @ ~{&work-entity~}-name with frame {&frame-name}.          ~
                                  END.

&SCOPED-DEFINE db-entity   bf_trn-doc.agnt
&SCOPED-DEFINE work-entity varagnt
if parman = "agnt" and paraction = "ret-mouse" then do:
  {&find-cli-buf}
  {&choose-cli-buf}
  {&display-cli-buf}
end.
if parman = "agnt" and paraction = "button" then do:
  {&button-cli-buf}
  {&choose-cli-buf}
  {&display-cli-buf}
end.
if parman = "agnt" and paraction = "leave" then do:
  {&find-cli-buf}
  {&display-cli-buf}
end.
&SCOPED-DEFINE db-entity   bf_trn-doc.boss
&SCOPED-DEFINE work-entity varboss
if parman = "boss" and paraction = "ret-mouse" then do:
  {&find-cli-buf}
  {&choose-cli-buf}
  {&display-cli-buf}
end.
if parman = "boss" and paraction = "button" then do:
  {&button-cli-buf}
  {&choose-cli-buf}
  {&display-cli-buf}
end.
if parman = "boss" and paraction = "leave" then do:
  {&find-cli-buf}
  {&display-cli-buf}
end.
&SCOPED-DEFINE db-entity   bf_trn-doc.wrkr
&SCOPED-DEFINE work-entity varwrkr
if parman = "wrkr" and paraction = "ret-mouse" then do:
  {&find-cli-buf}
  {&choose-cli-buf}
  {&display-cli-buf}
end.
if parman = "wrkr" and paraction = "button" then do:
  {&button-cli-buf}
  {&choose-cli-buf}
  {&display-cli-buf}
end.
if parman = "wrkr" and paraction = "leave" then do:
  {&find-cli-buf}
  {&display-cli-buf}
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-recalc Dialog-Frame
PROCEDURE local-recalc :
{ str/prst-lrc.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-list Dialog-Frame
PROCEDURE mark-list :
DEFINE VARIABLE varlog AS LOGICAL NO-UNDO.
do on error undo, return error return-value :
if not available bf_doc-line then do:
  message "Неправильный выбор строки.".
  return ERROR.
end.
find first tt-del-list where tt-del-list.rec-id = recid( bf_doc-line ) no-error.
if available tt-del-list then do:
  delete tt-del-list.
end.
else do:
  create tt-del-list.
  assign
    tt-del-list.rec-id = recid( bf_doc-line ).
end.
b-goods-:refresh() in frame {&frame-name}.
varlog = b-goods-:select-next-row () in frame {&frame-name}.
apply "entry" to b-goods- in frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mode-on Dialog-Frame
PROCEDURE mode-on :
define variable varrecid as recid no-undo.
do on error undo, return error :
if pardoc-mode = {&add-def} then do:
   RUN add-doc in this-procedure ( output varrecid ) no-error.
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при добавлении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       view-as alert-box error.
     undo, return error .
   end.
end.
else do:
  find first bf_trn-doc where recid(bf_trn-doc) = pardoc-rec no-lock.
  if available bf_trn-doc then do:
    if pardoc-mode = {&update} then do:
      if bf_trn-doc.status_ <> {&wayb} then do:
        message "Документ закрыт." skip (1)
                "Редактирование невозможно."
                view-as alert-box error.
        return error.
      end.
      else do:
        if v-cntxt-db-num <> bf-obj_clients.db-num then do:
          message
            vss-workfile vss-revision vss-description skip
            "Редактирование документа возможно только на активной стороне." skip
            return-value skip
            trim(error-status :get-message(1))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
  end.
  else do:
    message "Неправильный выбор документа.".
    return error.
  end.
end.
end. /*do*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE notes-tr Dialog-Frame
PROCEDURE notes-tr :
define variable varnotes as character no-undo.
assign
  varnotes = bf_trn-doc.PS.

run gbl/d-prompt.w (
    'title=Примечание\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + (if pardoc-mode = {&lookup} then 'readonly=yes\' else '':U)
  , input-output varnotes).
if pardoc-mode <> {&lookup} then do:
  if return-value = 'false':u
  then do:
    return .
  end.
  if bf_trn-doc.PS <> varnotes then do:
    do transaction on error undo, return error return-value :
      find CURRENT bf_trn-doc exclusive-lock.
      assign
        bf_trn-doc.PS = varnotes.
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-exit Dialog-Frame
PROCEDURE proc-exit :
DEFINE BUFFER bf-f_doc-line FOR ub.doc-line.
DEFINE VARIABLE varlog AS LOGICAL NO-UNDO.


if pardoc-mode = {&update} or pardoc-mode = {&add-def} then do:
  parnext-prev = ?.
  if not can-find (first bf-f_doc-line where bf-f_doc-line.doc-code = bf_trn-doc.doc-code no-lock) then do:
    varlog = yes.
    message "В документе нет строк, поэтому он удаляется." view-as alert-box
      question buttons OK-Cancel update varlog.
    if varlog then do:
      delete bf_trn-doc.
      assign pardoc-rec = ?.
      return.
    end.
    else do:
      return error.
    end.
  end.
  else do:
    assign
      bf_trn-doc.reason-code = varreason-code
      bf_trn-doc.wrkr = varwrkr
      bf_trn-doc.agnt = varagnt
      bf_trn-doc.boss = varboss.
   end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-get-write-off Dialog-Frame
PROCEDURE proc-get-write-off :
DEFINE PARAMETER BUFFER bf-loc_doc-line FOR ub.doc-line.
DEFINE BUFFER bf-loc-plus_doc-line FOR ub.doc-line.
DEFINE BUFFER bf-loc_parts         FOR ub.parts.
DEFINE BUFFER bf-loc_parts-root    FOR ub.parts-root.
DEFINE BUFFER bf-loc-plus_parts    FOR ub.parts.
DEFINE BUFFER bf-loc_goods         FOR ub.goods.
DEFINE BUFFER bf-loc-plus_goods    FOR ub.goods.
DEFINE VARIABLE varprice-rubl-parts AS DECIMAL NO-UNDO.
DEFINE VARIABLE varprice-base-parts AS DECIMAL NO-UNDO.
FIND FIRST bf-loc_goods WHERE bf-loc_goods.artic     = bf-loc_doc-line.artic     AND
                              bf-loc_goods.prod-type = bf-loc_doc-line.prod-type AND
                              bf-loc_goods.prod-code = bf-loc_doc-line.prod-code NO-LOCK.
FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = bf-loc_doc-line.doc-code  AND
                                   tt-doc-line-cashe.artic     = bf-loc_doc-line.artic     AND
                                   tt-doc-line-cashe.prod-type = bf-loc_doc-line.prod-type AND
                                   tt-doc-line-cashe.prod-code = bf-loc_doc-line.prod-code NO-ERROR.
IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
  CREATE tt-doc-line-cashe.
  ASSIGN
    tt-doc-line-cashe.doc-code  = bf-loc_doc-line.doc-code
    tt-doc-line-cashe.artic     = bf-loc_doc-line.artic
    tt-doc-line-cashe.prod-type = bf-loc_doc-line.prod-type
    tt-doc-line-cashe.prod-code = bf-loc_doc-line.prod-code .
END.
ELSE DO:
  ASSIGN
    tt-doc-line-cashe.qnty     = 0.00
    tt-doc-line-cashe.sum-rubl = 0.00
    tt-doc-line-cashe.sum-base = 0.00
    tt-doc-line-cashe.vat-rubl = 0.00
    tt-doc-line-cashe.vat-base = 0.00.
  FOR EACH tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code  AND
                                        tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic     AND
                                        tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type AND
                                        tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code :
    DELETE tt-doc-line-cashe-plus.
  END.
END.
FOR EACH bf-loc_parts WHERE bf-loc_parts.out-code  = bf-loc_doc-line.doc-code  AND
                            bf-loc_parts.obj-type  = bf-loc_doc-line.obj-type  AND
                            bf-loc_parts.obj-code  = bf-loc_doc-line.obj-code  AND
                            bf-loc_parts.artic     = bf-loc_doc-line.artic     AND
                            bf-loc_parts.prod-type = bf-loc_doc-line.prod-type AND
                            bf-loc_parts.prod-code = bf-loc_doc-line.prod-code AND
                            bf-loc_parts.fact-qnty < 0 NO-LOCK :
  FOR EACH tt-clcparts :
    DELETE tt-clcparts.
  END.
  CREATE tt-clcparts.
  BUFFER-COPY bf-loc_parts TO tt-clcparts.
  run clcprtsl_calc-parts in this-procedure (
                                  input recid( tt-clcparts )
                                , input yes
                                , input no
                                , input bf-loc_doc-line.road-tax     /* parroad-tax      */
                                , input bf-loc_doc-line.excise       /* parexcise        */
                                , input bf-loc_doc-line.VAT-pc       /* parvat-pc        */
                                , input bf-loc_doc-line.cons-vat-pc  /* parcons-vat-pc   */
                                , input bf-loc_doc-line.SLT-pc       /* parslt-pc        */
                                , input bf_trn-doc.base-rate         /* parbase-rate     */
                                , input bf_trn-doc.base-scale        /* parbase-scale    */
                                , input "":U                         /* parr-b           */
                                , input 0.0                          /* parcur-base      */
                                , input 0.0                          /* parcurroad-tax   */
                                , input 0.0                          /* parcurexcise     */
                                , input 0.0                          /* parcurvat-pc     */
                                , input 0.0                          /* parcurcons-vat-pc*/
                                , input 0.0                          /* parcurslt-pc     */
                            ).
  FIND FIRST tt-allsum WHERE tt-allsum.sum-type = {&sum-general} NO-ERROR.
  if available tt-allsum then do:
    ASSIGN
      tt-doc-line-cashe.qnty     = tt-doc-line-cashe.qnty     - tt-allsum.fact-qnty
      tt-doc-line-cashe.sum-rubl = tt-doc-line-cashe.sum-rubl - tt-allsum.sum-dsc-rubl-doc
      tt-doc-line-cashe.sum-base = tt-doc-line-cashe.sum-base - tt-allsum.sum-dsc-base-doc
      tt-doc-line-cashe.vat-rubl = tt-doc-line-cashe.vat-rubl - tt-allsum.vat-rubl-doc
      tt-doc-line-cashe.vat-base = tt-doc-line-cashe.vat-base - tt-allsum.vat-base-doc.
    ASSIGN
      varprice-rubl-parts = tt-allsum.sum-dsc-rubl-doc / tt-allsum.fact-qnty
      varprice-base-parts = tt-allsum.sum-dsc-base-doc / tt-allsum.fact-qnty.
    FOR EACH bf-loc_parts-root WHERE bf-loc_parts-root.doc-code       = bf-loc_parts.out-code   AND
                                     bf-loc_parts-root.orig-in-code   = bf-loc_parts.in-code    AND
                                     bf-loc_parts-root.orig-gds-code  = bf-loc_goods.gds-code   AND
                                     bf-loc_parts-root.orig-part-code = bf-loc_parts.part-code  NO-LOCK :
      FIND FIRST bf-loc-plus_goods WHERE bf-loc-plus_goods.gds-code  = bf-loc_parts-root.gds-code NO-LOCK.
      FIND FIRST bf-loc-plus_parts WHERE bf-loc-plus_parts.obj-type  = bf-loc_doc-line.obj-type    AND
                                         bf-loc-plus_parts.obj-code  = bf-loc_doc-line.obj-code    AND
                                         bf-loc-plus_parts.artic     = bf-loc-plus_goods.artic     AND
                                         bf-loc-plus_parts.prod-type = bf-loc-plus_goods.prod-type AND
                                         bf-loc-plus_parts.prod-code = bf-loc-plus_goods.prod-code AND
                                         bf-loc-plus_parts.in-code   = bf-loc_parts-root.in-code   AND
                                         bf-loc-plus_parts.out-code  = bf-loc_doc-line.doc-code    AND
                                         bf-loc-plus_parts.part-code = bf-loc_parts-root.part-code NO-LOCK.
      FIND FIRST bf-loc-plus_doc-line WHERE bf-loc-plus_doc-line.doc-code  = bf-loc-plus_parts.out-code  AND
                                            bf-loc-plus_doc-line.artic     = bf-loc-plus_parts.artic     AND
                                            bf-loc-plus_doc-line.prod-type = bf-loc-plus_parts.prod-type AND
                                            bf-loc-plus_doc-line.prod-code = bf-loc-plus_parts.prod-code .
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code  AND
                                              tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic     AND
                                              tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type AND
                                              tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code AND
                                              tt-doc-line-cashe-plus.artic        = bf-loc-plus_goods.artic      AND
                                              tt-doc-line-cashe-plus.prod-type    = bf-loc-plus_goods.prod-type  AND
                                              tt-doc-line-cashe-plus.prod-code    = bf-loc-plus_goods.prod-code  NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
        create tt-doc-line-cashe-plus.
        ASSIGN
          tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code
          tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic
          tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type
          tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code
          tt-doc-line-cashe-plus.artic        = bf-loc-plus_goods.artic
          tt-doc-line-cashe-plus.prod-type    = bf-loc-plus_goods.prod-type
          tt-doc-line-cashe-plus.prod-code    = bf-loc-plus_goods.prod-code .
      END.
      FOR EACH tt-clcparts :
        DELETE tt-clcparts.
      END.
      CREATE tt-clcparts.
      BUFFER-COPY bf-loc-plus_parts TO tt-clcparts.
      run clcprtsl_calc-parts in this-procedure (
                                      input recid( tt-clcparts )
                                    , input yes
                                    , input no
                                    , input bf-loc-plus_doc-line.road-tax     /* parroad-tax      */
                                    , input bf-loc-plus_doc-line.excise       /* parexcise        */
                                    , input bf-loc-plus_doc-line.VAT-pc       /* parvat-pc        */
                                    , input bf-loc-plus_doc-line.cons-vat-pc  /* parcons-vat-pc   */
                                    , input bf-loc-plus_doc-line.SLT-pc       /* parslt-pc        */
                                    , input bf_trn-doc.base-rate              /* parbase-rate     */
                                    , input bf_trn-doc.base-scale             /* parbase-scale    */
                                    , input "":U                              /* parr-b           */
                                    , input 0.0                               /* parcur-base      */
                                    , input 0.0                               /* parcurroad-tax   */
                                    , input 0.0                               /* parcurexcise     */
                                    , input 0.0                               /* parcurvat-pc     */
                                    , input 0.0                               /* parcurcons-vat-pc*/
                                    , input 0.0                               /* parcurslt-pc     */
                                ).
      FIND FIRST tt-allsum WHERE tt-allsum.sum-type = {&sum-general} NO-ERROR.
      if available tt-allsum then do:
        ASSIGN
          tt-doc-line-cashe-plus.qnty               = tt-doc-line-cashe-plus.qnty               + tt-allsum.fact-qnty
          tt-doc-line-cashe-plus.sum-rubl           = tt-doc-line-cashe-plus.sum-rubl           + tt-allsum.sum-dsc-rubl-doc
          tt-doc-line-cashe-plus.sum-base           = tt-doc-line-cashe-plus.sum-base           + tt-allsum.sum-dsc-base-doc
          tt-doc-line-cashe-plus.vat-rubl           = tt-doc-line-cashe-plus.vat-rubl           + tt-allsum.vat-rubl-doc
          tt-doc-line-cashe-plus.vat-base           = tt-doc-line-cashe-plus.vat-base           + tt-allsum.vat-base-doc
          tt-doc-line-cashe-plus.write-off-qnty     = tt-doc-line-cashe-plus.write-off-qnty     + tt-clcparts.real-qnty
          tt-doc-line-cashe-plus.write-off-sum-rubl = tt-doc-line-cashe-plus.write-off-sum-rubl + varprice-rubl-parts * tt-clcparts.real-qnty
          tt-doc-line-cashe-plus.write-off-sum-base = tt-doc-line-cashe-plus.write-off-sum-base + varprice-base-parts * tt-clcparts.real-qnty
        .
      END.
    END.
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-history Dialog-Frame
PROCEDURE proc-history :
define variable loc-ref-list as character no-undo.
  &scop lock-table  table-name
  &scop table-name  doc-line

  do on error undo, return error return-value :
    if not available {&table-name} then do:
      return error.
    end.
    run str/docclins.w ( input        parparentproc,
                     input        "":U,
                     input        "doc",
                     input        {&table-name}.obj-type,
                     input        {&table-name}.obj-code,
                     input        {&table-name}.doc-code,
                     input        {&table-name}.artic,
                     input        {&table-name}.prod-type,
                     input        {&table-name}.prod-code,
                     input-output loc-ref-list             ).
    apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  end. /* do */
  &scop table-name lock-table
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-name Dialog-Frame
PROCEDURE proc-shift-name :
define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date-mem like ub.shift-obj.shift-date no-undo.
  define variable varshift-num-mem  like ub.shift-obj.shift-num  no-undo.
  if input frame {&frame-name} varshift-date <> ? then do:
    for each  bf_shift-obj where bf_shift-obj.obj-type   = bf_trn-doc.obj-type                             and
                                 bf_shift-obj.obj-code   = bf_trn-doc.obj-code                             and
                                 bf_shift-obj.shift-date = input frame {&frame-name} varshift-date no-lock on error undo, return error return-value :
      assign
        varfind-shift = varfind-shift + 1
        varshift-date-mem = bf_shift-obj.shift-date
        varshift-num-mem  = bf_shift-obj.shift-num.
    end.

    if varfind-shift = 0 or varfind-shift > 1 then do:
      if varfind-shift = 0 then do:
        message "Не найдена смена: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
                " Дата " input frame {&frame-name} varshift-date
                 " Номер смены " input frame {&frame-name} varshift-name " ."
        view-as alert-box error.
      end.
      else do:
        message "Найдено более одной смены с одним номером в сменном дне. Объект: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
                " Дата " input frame {&frame-name} varshift-date " Номер смены " input frame {&frame-name} varshift-name " ."
        view-as alert-box error.
      end.
      display varshift-name with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do: return error. end.
    end.
    else do:
      assign frame {&frame-name}
        varshift-name.
      assign
        bf_trn-doc.shift-date = varshift-date-mem
        bf_trn-doc.shift-num  = varshift-num-mem
        varshift-date = varshift-date-mem
        varshift-num = varshift-num-mem.
      display bf_trn-doc.shift-date @ varshift-date
              bf_trn-doc.shift-num  @ varshift-num
              varshift-name with frame {&frame-name}.
      if bf_trn-doc.fact-date = ? then do:
        assign bf_trn-doc.fact-date = bf_trn-doc.shift-date
               bf_trn-doc.fact-time = (24 * 60 * 60).
        display bf_trn-doc.fact-date @ varfact-date with frame {&frame-name}.
       end.
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-num Dialog-Frame
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  if input frame {&frame-name} varshift-date <> ? then do:
    find first bf_shift-obj where bf_shift-obj.obj-type   = bf_trn-doc.obj-type                     and
                                  bf_shift-obj.obj-code   = bf_trn-doc.obj-code                     and
                                  bf_shift-obj.shift-date = input frame {&frame-name} varshift-date AND
                                  bf_shift-obj.shift-num  = input frame {&frame-name} varshift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      message "Не найдена смена на объекте: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
              " Дата " input frame {&frame-name} varshift-date " Порядок смены " varshift-num " ."
      view-as alert-box error.
      display varshift-num with frame {&frame-name}.
      run proc-sht in this-procedure no-error.
      if error-status:error then do:
        return error.
      end.
    end.
    else do:
      assign
        bf_trn-doc.shift-date = bf_shift-obj.shift-date
        bf_trn-doc.shift-num  = bf_shift-obj.shift-num
        varshift-name    = bf_shift-obj.shift-name
        varshift-date = bf_shift-obj.shift-date.
      display bf_trn-doc.shift-date @ varshift-date
              bf_trn-doc.shift-num  @ varshift-num
              varshift-name with frame {&frame-name}.
      if bf_trn-doc.fact-date = ? then do:
        assign
          bf_trn-doc.fact-date = bf_trn-doc.shift-date
          bf_trn-doc.fact-time = (24 * 60 * 60).
        display bf_trn-doc.fact-date @ varfact-date with frame {&frame-name}.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sht Dialog-Frame
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define buffer bf_shift-staff for ub.shift-staff.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (INPUT parparentproc,
                 INPUT bf_trn-doc.obj-type,
                 INPUT bf_trn-doc.obj-code,
                 INPUT 'b-sel',
                 INPUT 'obj',
                 INPUT bf_trn-doc.obj-type,
                 INPUT bf_trn-doc.obj-code,
                 INPUT '':u,
                 input-output varrid-list)
  no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        bf_trn-doc.shift-date = bf_shift-obj.shift-date
        bf_trn-doc.shift-num  = bf_shift-obj.shift-num
        varshift-name    = bf_shift-obj.shift-name
        varshift-date = bf_shift-obj.shift-date
        varshift-num = bf_shift-obj.shift-num.
      display bf_trn-doc.shift-date @ varshift-date
              bf_trn-doc.shift-num  @ varshift-num
              varshift-name with frame {&frame-name}.
/*      if bf_trn-doc.fact-date = ? then do:*/
        assign
          bf_trn-doc.fact-date = bf_trn-doc.shift-date
          bf_trn-doc.fact-time = (24 * 60 * 60).
        display bf_trn-doc.fact-date @ varfact-date with frame {&frame-name}.
/*      end.*/
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc-line Dialog-Frame
PROCEDURE recalc-line :
DEFINE BUFFER bf-recalc_doc-line FOR ub.doc-line.
DEFINE BUFFER bf-recalc_parts    FOR ub.parts.
DEFINE VARIABLE varsum-base  LIKE ub.parts.price-base.
DEFINE VARIABLE varsum-rubl  LIKE ub.parts.price-rubl.
DEFINE VARIABLE varfact-qnty LIKE ub.parts.fact-qnty.
DO ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
FOR EACH tt-recalc-line ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  FIND FIRST bf-recalc_doc-line WHERE bf-recalc_doc-line.doc-code  = tt-recalc-line.doc-code  AND
                                      bf-recalc_doc-line.artic     = tt-recalc-line.artic     AND
                                      bf-recalc_doc-line.prod-type = tt-recalc-line.prod-type AND
                                      bf-recalc_doc-line.prod-code = tt-recalc-line.prod-code EXCLUSIVE-LOCK.
  assign
    varsum-base  = 0.00
    varsum-rubl  = 0.00
    varfact-qnty = 0.00
  .
  FOR EACH bf-recalc_parts WHERE bf-recalc_parts.out-code  = bf-recalc_doc-line.doc-code  AND
                                 bf-recalc_parts.obj-type  = bf-recalc_doc-line.obj-type  AND
                                 bf-recalc_parts.obj-code  = bf-recalc_doc-line.obj-code  AND
                                 bf-recalc_parts.artic     = bf-recalc_doc-line.artic     AND
                                 bf-recalc_parts.prod-type = bf-recalc_doc-line.prod-type AND
                                 bf-recalc_parts.prod-code = bf-recalc_doc-line.prod-code ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    ASSIGN
      varsum-base  = varsum-base  + bf-recalc_parts.price-base * bf-recalc_parts.fact-qnty
      varsum-rubl  = varsum-rubl  + bf-recalc_parts.price-rubl * bf-recalc_parts.fact-qnty
      varfact-qnty = varfact-qnty + bf-recalc_parts.fact-qnty.
  END.
  ASSIGN
    bf-recalc_doc-line.price-base = varsum-base / varfact-qnty
    bf-recalc_doc-line.price-rubl = varsum-rubl / varfact-qnty.
END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rsrv-gds-dtl Dialog-Frame
PROCEDURE rsrv-gds-dtl :
DEFINE INPUT PARAMETER pardoc-code  LIKE ub.doc-line.doc-code  NO-UNDO.
DEFINE INPUT PARAMETER parartic     LIKE ub.doc-line.artic     NO-UNDO.
DEFINE INPUT PARAMETER parprod-type LIKE ub.doc-line.prod-type NO-UNDO.
DEFINE INPUT PARAMETER parprod-code LIKE ub.doc-line.prod-code NO-UNDO.
DEFINE INPUT PARAMETER paravaiparts AS   LOGICAL               NO-UNDO.
DEFINE INPUT PARAMETER parrsrv-qnty AS   DECIMAL               NO-UNDO.
DEFINE BUFFER bf-del_doc-line     FOR ub.doc-line.
DEFINE BUFFER bf-del_goods        FOR ub.goods.
DEFINE BUFFER bf-del_gds-dtl      FOR ub.gds-dtl.
define buffer bf-del-next_gds-dtl for ub.gds-dtl.
define variable varrsrv-qnty-gds-dtl as decimal no-undo.
define variable vargds-dtl-doc-qnty  as decimal no-undo.
do on error undo, return error return-value :
FIND FIRST bf-del_doc-line WHERE bf-del_doc-line.doc-code  = pardoc-code  AND
                                 bf-del_doc-line.artic     = parartic     AND
                                 bf-del_doc-line.prod-type = parprod-type AND
                                 bf-del_doc-line.prod-code = parprod-code EXCLUSIVE-LOCK.
FIND FIRST bf-del_goods WHERE bf-del_goods.artic     = bf-del_doc-line.artic     AND
                              bf-del_goods.prod-type = bf-del_doc-line.prod-type AND
                              bf-del_goods.prod-code = bf-del_doc-line.prod-code NO-LOCK.
  if bf-del_doc-line.fact-qnty = 0    and
     not paravaiparts then do:
     /* признаки удалим далее в local-line-delete */
  end.
  else do:
    /* подкорректируем признаки */
    assign
      varrsrv-qnty-gds-dtl = 0.00.
    cycle-gds-dtl:
    for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                  bf-del_gds-dtl.artic     = bf-del_goods.artic     and
                                  bf-del_gds-dtl.prod-type = bf-del_goods.prod-type and
                                  bf-del_gds-dtl.prod-code = bf-del_goods.prod-code
                                  exclusive-lock
                                  break by bf-del_gds-dtl.doc-qnty descending
                                  on error undo, return error return-value :
      if bf-del_gds-dtl.doc-qnty < 0 then do:
        if - bf-del_gds-dtl.doc-qnty >= (parrsrv-qnty - varrsrv-qnty-gds-dtl) then do:
          assign
            bf-del_gds-dtl.doc-qnty  = bf-del_gds-dtl.doc-qnty + (parrsrv-qnty - varrsrv-qnty-gds-dtl)
          .
          leave cycle-gds-dtl.
        end.
        else do:
          assign
            varrsrv-qnty-gds-dtl = varrsrv-qnty-gds-dtl + (- bf-del_gds-dtl.doc-qnty)
            bf-del_gds-dtl.doc-qnty  = 0
            .
        end.
      end.
      else do:
        assign
          bf-del_gds-dtl.doc-qnty  = bf-del_gds-dtl.doc-qnty + (parrsrv-qnty - varrsrv-qnty-gds-dtl)
        .
        leave cycle-gds-dtl.
      end.
    end.
    /*проверим, что признаки корректно подрезались*/
    assign
      vargds-dtl-doc-qnty  = 0.00.
    for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                  bf-del_gds-dtl.artic     = bf-del_goods.artic     and
                                  bf-del_gds-dtl.prod-type = bf-del_goods.prod-type and
                                  bf-del_gds-dtl.prod-code = bf-del_goods.prod-code on error undo, return error return-value :
      assign
        vargds-dtl-doc-qnty  = vargds-dtl-doc-qnty  + bf-del_gds-dtl.doc-qnty.
    end.
    if bf-del_doc-line.fact-qnty <> vargds-dtl-doc-qnty then do:
       undo, return error substitute ("Ошибочно произведено разрезервирование по признакам для товара списания. Товар &1 &2 &3 &4. Количество по строке &5. Количество по признакам &6.",
                                      bf-del_goods.artic,
                                      bf-del_goods.prod-type,
                                      bf-del_goods.prod-code,
                                      bf-del_goods.gds-name,
                                      bf-del_doc-line.fact-qnty,
                                      vargds-dtl-doc-qnty).
    end.
    /*Зачистим нулевые признаки*/
    FIND FIRST bf-del_gds-dtl WHERE bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  AND
                                    bf-del_gds-dtl.artic     = bf-del_doc-line.artic     AND
                                    bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type AND
                                    bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code AND
                                    bf-del_gds-dtl.doc-qnty  <> 0                        NO-ERROR.
    IF AVAILABLE bf-del_gds-dtl THEN DO:
      FOR EACH bf-del_gds-dtl WHERE bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  AND
                                    bf-del_gds-dtl.artic     = bf-del_doc-line.artic     AND
                                    bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type AND
                                    bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code AND
                                    bf-del_gds-dtl.doc-qnty = 0                         ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
        DELETE bf-del_gds-dtl.
      END.
    END.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rsrv-gds-dtl-plus Dialog-Frame
PROCEDURE rsrv-gds-dtl-plus :
define input parameter pardoc-code  like ub.doc-line.doc-code  no-undo.
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define input parameter paravaiparts as   logical               no-undo.
define input parameter parrsrv-qnty as   decimal               no-undo.
define variable varrsrv-qnty-gds-dtl-plus as decimal            no-undo.
define buffer bf-del-plus_doc-line for ub.doc-line.
define buffer bf-del-plus_gds-dtl      for ub.gds-dtl.
define buffer bf-del-next-plus_gds-dtl for ub.gds-dtl.
do on error undo, return error return-value :
find first bf-del-plus_doc-line where bf-del-plus_doc-line.doc-code  = pardoc-code  and
                                      bf-del-plus_doc-line.artic     = parartic     and
                                      bf-del-plus_doc-line.prod-type = parprod-type and
                                      bf-del-plus_doc-line.prod-code = parprod-code exclusive-lock.
assign
  varrsrv-qnty-gds-dtl-plus = 0.00.
cycle-gds-dtl-plus:
for each bf-del-plus_gds-dtl where bf-del-plus_gds-dtl.doc-code  = pardoc-code         and
                                   bf-del-plus_gds-dtl.artic     = parartic     and
                                   bf-del-plus_gds-dtl.prod-type = parprod-type and
                                   bf-del-plus_gds-dtl.prod-code = parprod-code
                                   exclusive-lock
                                   break by bf-del-plus_gds-dtl.doc-qnty descending
                                   on error undo, return error return-value :
  if bf-del-plus_gds-dtl.doc-qnty > 0 then do:
    if bf-del-plus_gds-dtl.doc-qnty >= (parrsrv-qnty - varrsrv-qnty-gds-dtl-plus) then do:
      assign
        bf-del-plus_gds-dtl.doc-qnty = bf-del-plus_gds-dtl.doc-qnty - (parrsrv-qnty - varrsrv-qnty-gds-dtl-plus).
      leave cycle-gds-dtl-plus.
    end.
    else do:
      assign
        varrsrv-qnty-gds-dtl-plus = varrsrv-qnty-gds-dtl-plus + bf-del-plus_gds-dtl.doc-qnty.
      assign
        bf-del-plus_gds-dtl.doc-qnty  = 0.00
      .
    end.
  end.
  else do:
    assign
      bf-del-plus_gds-dtl.doc-qnty = bf-del-plus_gds-dtl.doc-qnty - (parrsrv-qnty - varrsrv-qnty-gds-dtl-plus).
    leave cycle-gds-dtl-plus.
  end.
end.

if bf-del-plus_doc-line.fact-qnty = 0    and
   not paravaiparts then do:
  run local-recalc in this-procedure (input "delete":u,
                                      input recid(bf-del-plus_doc-line),
                                      input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: &1", return-value).
  end.
  run local-line-delete in this-procedure (input recid(bf-del-plus_doc-line)) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при удалении строки документа. Оприходованный товар: &1 &2 &3.", bf-del-plus_doc-line.artic, bf-del-plus_doc-line.prod-type, bf-del-plus_doc-line.prod-code).
  end.
end.
else do:
  run local-recalc in this-procedure (input "update":u,
                                      input recid(bf-del-plus_doc-line),
                                      input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа по оприходованным товарам: &1", return-value).
  end.
  /*Зачистим нулевые признаки*/
  find first bf-del-plus_gds-dtl where bf-del-plus_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                       bf-del-plus_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                       bf-del-plus_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                       bf-del-plus_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                       bf-del-plus_gds-dtl.doc-qnty <> 0                              no-error.
  if available bf-del-plus_gds-dtl then do:
    for each bf-del-plus_gds-dtl where bf-del-plus_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                       bf-del-plus_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                       bf-del-plus_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                       bf-del-plus_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                       bf-del-plus_gds-dtl.doc-qnty  = 0                              on error undo, return error return-value :
      delete bf-del-plus_gds-dtl.
    end.
  end.
end.
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-reason Dialog-Frame
PROCEDURE select-reason :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.

  define buffer bf_trn-reason for ub.trn-reason.

  do on error undo, return error return-value :
    assign
      j-rsn-code = ( input frame {&FRAME-NAME} varreason-code )
    .
    run str/trn-reas.w ( input ParParentProc, input {&choose}, input-output j-rsn-code ).
    find first bf_trn-reason no-lock where
               bf_trn-reason.reason-code = j-rsn-code no-error.
    if available bf_trn-reason then do:
      assign
        varreason-name    = bf_trn-reason.reason-name
        bf_trn-doc.reason-code = bf_trn-reason.reason-code
        varreason-code    = bf_trn-reason.reason-code
      .
      display varreason-code
              varreason-name
      with frame {&FRAME-NAME}.
    end.
  end. /* on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on Dialog-Frame
PROCEDURE ui-on :
define input parameter fnc as character no-undo.
define buffer bf_contract for ub.contract.
define buffer bf_clients  for ub.clients.
define variable varhave-shift     as logical   no-undo.
define variable varadd-back-date  as logical   no-undo.
do on error undo, return error return-value :
  for each tt-del-list on error undo, return error return-value :
    delete tt-del-list.
  end.
  case pardoc-mode :
    when {&lookup} then do:
      /*уже проenableно по умолчанию*/
        if parext-doc-mode = "reason-code" then do:
          enable r-reas with frame {&FRAME-NAME}.
        end.

    end.
    otherwise do:
      enable b-mark b-add b-chg b-del
             varwrkr varagnt varboss
             r-wrkr r-agnt r-boss
             r-reas
      with frame {&frame-name}.
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_tdedt-peresort_add-back-date':u
        {&cntxt-object}
        bf_trn-doc.host-code
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        0
        0
        0
        false
        varadd-back-date
      }
      if varadd-back-date then do:
        enable varfact-date with frame {&frame-name}.
      end.
      { gbl/objat.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        "'shift-on=request'"
        varhave-shift
        no-error
      }
      if error-status :error then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при запуске процедуры objat" skip
        return-value skip
        view-as alert-box error .
        return error.
      end.
      if not varhave-shift then do:
       hide varshift-date varshift-num varshift-name r-sht in frame {&frame-name}.
      end.
      ELSE DO:
        if varadd-back-date then do:
          ENABLE varshift-date varshift-num varshift-name r-sht WITH frame {&frame-name}.
        end.
      END.
    end. /* update */
  end case. /* pardoc-mode */
  if not parold-supp-cntr then do:
    if bf_trn-doc.contract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code     and
                                   bf_contract.contract-code = bf_trn-doc.contract-code no-lock.
      assign
        varcontract-prn-code = bf_contract.contract-prn-code
        varcontract-name     = bf_contract.contract-name
       .
    end.
    assign
      vardoc-date  = bf_trn-doc.doc-date
      varfact-date = bf_trn-doc.fact-date
      varcli-type  = bf_trn-doc.cli-type
      varcli-code  = bf_trn-doc.cli-code
      varcli-name  = bf_trn-doc.cli-name .

    display vardoc-date
            varfact-date
            varcli-type
            varcli-code
            varcli-name
            varcontract-prn-code
            varcontract-name
    with frame {&frame-name}.
  end.
  else do:
    display varinformation with frame {&frame-name}.
  end.
  IF varhave-shift THEN DO:
    if bf_trn-doc.shift-date <> ? then do:
      assign
        varshift-date = bf_trn-doc.shift-date
        varshift-num  = bf_trn-doc.shift-num
        varshift-name = bf_trn-doc.shift-name
      .
      display varshift-date varshift-num  varshift-name  with frame {&frame-name}.
    end.
  end.
  assign
    varfact-date = bf_trn-doc.fact-date.
  display varfact-date with frame {&frame-name}.
  assign
    frame {&frame-name} :title = bf_trn-doc.obj-type + " " + string( bf_trn-doc.obj-code, ">>>>9":U ) + "  : ПЕРЕСОРТИЦА " +
    bf_trn-doc.status_ + " " + string( bf_trn-doc.flag_, "+/-":U ) + " № " + bf_trn-doc.doc-code + "   - " + pardoc-mode.
  ASSIGN
    varwrkr = bf_trn-doc.wrkr
    varagnt = bf_trn-doc.agnt
    varboss = bf_trn-doc.boss
   .

  display varwrkr varagnt varboss with frame {&frame-name}.
  find first bf_clients where bf_clients.obj-type = {&prs}  and
                              bf_clients.obj-code = varwrkr no-lock no-error.
  if available bf_clients then do:
    display bf_clients.obj-name @ varwrkr-name with frame {&frame-name}.
  end.
  find first bf_clients where bf_clients.obj-type = {&prs}  and
                              bf_clients.obj-code = varagnt no-lock no-error.
  if available bf_clients then do:
    display bf_clients.obj-name @ varagnt-name with frame {&frame-name}.
  end.
  find first bf_clients where bf_clients.obj-type = {&prs}  and
                              bf_clients.obj-code = varboss no-lock no-error.
  if available bf_clients then do:
    display bf_clients.obj-name @ varboss-name with frame {&frame-name}.
  end.
  define buffer bf_trn-reason for ub.trn-reason  .
  find bf_trn-reason no-lock where
       bf_trn-reason.reason-code = bf_trn-doc.reason-code no-error.
  assign
    varreason-name = ( if available bf_trn-reason then bf_trn-reason.reason-name else "":U )
    varreason-code  = bf_trn-doc.reason-code
  .

  display
  varreason-name
  varreason-code
  with frame {&frame-name} .

  {&open-query-b-goods-}
  {&open-query-b-goods}
end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-deviation-abs-base Dialog-Frame
FUNCTION get-deviation-abs-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
   FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                           tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                           tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                           tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                           tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                           tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                           tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
   IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
     RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
   END.
   RETURN tt-doc-line-cashe-plus.sum-base - tt-doc-line-cashe-plus.write-off-sum-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-deviation-abs-rubl Dialog-Frame
FUNCTION get-deviation-abs-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
    FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                            tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                            tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                            tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                            tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                            tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                            tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
    IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
      RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                              tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                              tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                              tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                              tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                              tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                              tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
    END.
    RETURN tt-doc-line-cashe-plus.sum-rubl - tt-doc-line-cashe-plus.write-off-sum-rubl.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-deviation-percent Dialog-Frame
FUNCTION get-deviation-percent RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
    FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                            tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                            tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                            tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                            tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                            tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                            tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
    IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
      RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                              tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                              tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                              tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                              tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                              tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                              tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
    END.
    RETURN (tt-doc-line-cashe-plus.sum-rubl - tt-doc-line-cashe-plus.write-off-sum-rubl) / tt-doc-line-cashe-plus.sum-rubl * 100.00.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-income-qnty Dialog-Frame
FUNCTION get-income-qnty RETURNS DECIMAL
  ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
   FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                           tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                           tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                           tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                           tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                           tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                           tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
   IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
     RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
   END.
   RETURN tt-doc-line-cashe-plus.qnty.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-income-sum-base Dialog-Frame
FUNCTION get-income-sum-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.sum-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-income-sum-rubl Dialog-Frame
FUNCTION get-income-sum-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.sum-rubl.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-income-vat-base Dialog-Frame
FUNCTION get-income-vat-base RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.vat-base.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-income-vat-rubl Dialog-Frame
FUNCTION get-income-vat-rubl RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
     FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
     IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
       RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
       FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     END.
     RETURN tt-doc-line-cashe-plus.vat-rubl.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  (buffer local-doc-line for ub.doc-line) :
find first tt-del-list where tt-del-list.rec-id = recid (local-doc-line) no-error.
if available tt-del-list then do:
  return "*".
end.
else do:
  return "".
end.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-price Dialog-Frame
FUNCTION get-price RETURNS DECIMAL
(BUFFER local-goods FOR ub.goods):
DEFINE BUFFER bf-fnc_gds-dtl      FOR ub.gds-dtl.
DEFINE BUFFER bf-fnc-spec_gds-dtl FOR ub.gds-dtl.
DEFINE BUFFER bf-fnc_gds-prt      FOR ub.gds-prt.
DEFINE VARIABLE varqnty AS DECIMAL NO-UNDO.
DEFINE VARIABLE varsum  AS DECIMAL NO-UNDO.
FIND FIRST bf-fnc_gds-dtl WHERE bf-fnc_gds-dtl.doc-code   = bf_trn-doc.doc-code   AND
                                bf-fnc_gds-dtl.artic      = local-goods.artic     AND
                                bf-fnc_gds-dtl.prod-type  = local-goods.prod-type AND
                                bf-fnc_gds-dtl.prod-code  = local-goods.prod-code NO-LOCK.
find first bf-fnc_gds-prt where bf-fnc_gds-prt.upper-code = local-goods.prt-root no-lock.
if bf-fnc_gds-prt.node-name = {&empty-scale} then do:
  IF varr-b = "rubl" THEN DO:
    RETURN bf-fnc_gds-dtl.price-rubl.
  END.
  ELSE DO:
    RETURN bf-fnc_gds-dtl.price-base.
  END.
END.
ELSE DO:
  FIND FIRST bf-fnc-spec_gds-dtl WHERE bf-fnc-spec_gds-dtl.doc-code    = bf_trn-doc.doc-code   AND
                                       bf-fnc-spec_gds-dtl.artic       = local-goods.artic     AND
                                       bf-fnc-spec_gds-dtl.prod-type   = local-goods.prod-type AND
                                       bf-fnc-spec_gds-dtl.prod-code   = local-goods.prod-code AND
                                       bf-fnc-spec_gds-dtl.price-rubl <> bf-fnc_gds-dtl.price-rubl NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf-fnc-spec_gds-dtl THEN DO:
    IF varr-b = "rubl" THEN DO:
      RETURN bf-fnc_gds-dtl.price-rubl.
    END.
    ELSE DO:
      RETURN bf-fnc_gds-dtl.price-base.
    END.
  END.
  ELSE DO:
    ASSIGN
      varqnty = 0.00
      varsum  = 0.00.
    FOR EACH bf-fnc_gds-dtl WHERE bf-fnc_gds-dtl.doc-code   = bf_trn-doc.doc-code   AND
                                  bf-fnc_gds-dtl.artic      = local-goods.artic     AND
                                  bf-fnc_gds-dtl.prod-type  = local-goods.prod-type AND
                                  bf-fnc_gds-dtl.prod-code  = local-goods.prod-code NO-LOCK :
      ASSIGN
        varqnty = VARqnty + bf-fnc_gds-dtl.fact-qnty
        varsum  = varsum + (IF varr-b = "rubl" THEN bf-fnc_gds-dtl.price-rubl ELSE bf-fnc_gds-dtl.price-base) * bf-fnc_gds-dtl.fact-qnty.
    END.
    RETURN ABS (varsum / varqnty).

  END.
END.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-write-off-for-income-qnty Dialog-Frame
FUNCTION get-write-off-for-income-qnty RETURNS DECIMAL
    ( BUFFER local-doc-line FOR ub.doc-line, BUFFER local-doc-line-plus FOR ub.doc-line ) :
    FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                            tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                            tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                            tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                            tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                            tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                            tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code NO-ERROR.
    IF NOT AVAILABLE tt-doc-line-cashe-plus THEN DO:
      RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
      FIND FIRST tt-doc-line-cashe-plus WHERE tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       AND
                                              tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          AND
                                              tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      AND
                                              tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                              tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     AND
                                              tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type AND
                                              tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
    END.
    RETURN tt-doc-line-cashe-plus.write-off-qnty.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-write-off-qnty Dialog-Frame
FUNCTION get-write-off-qnty RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.qnty.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-write-off-sum-base Dialog-Frame
FUNCTION get-write-off-sum-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.sum-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-write-off-sum-rubl Dialog-Frame
FUNCTION get-write-off-sum-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.sum-rubl.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-write-off-vat-base Dialog-Frame
FUNCTION get-write-off-vat-base RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
       END.
       RETURN tt-doc-line-cashe.vat-base.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-write-off-vat-rubl Dialog-Frame
FUNCTION get-write-off-vat-rubl RETURNS DECIMAL
  ( buffer local-doc-line for ub.doc-line ) :
      FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code NO-ERROR.
      IF NOT AVAILABLE tt-doc-line-cashe THEN DO:
        RUN proc-get-write-off in this-procedure (BUFFER local-doc-line).
        FIND FIRST tt-doc-line-cashe WHERE tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  AND
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     AND
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type AND
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      END.
      RETURN tt-doc-line-cashe.vat-rubl.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME