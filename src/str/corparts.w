/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Интерфейс документа коррекции партий свободной зоны

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

*/

define input        parameter parparentproc   as   handle                  no-undo.
define input-output parameter pardoc-rec      as   recid                   no-undo.
define input        parameter pardoc-mode     as   character               no-undo.
define input        parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input        parameter paris-hold      as   logical                 no-undo.
define input-output parameter parnext-prev    as   logical                 no-undo.
define input-output parameter line-rec        as   recid                   no-undo.
define input        parameter br-handle       as   handle                  no-undo.
define input        parameter bf-handle       as   handle                  no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".


define buffer  t-doc     for ub.trn-doc.


define buffer bf-orig_parts        for ub.parts.
define buffer bf-orig_goods        for ub.goods.
define buffer bf-caus_parts        for ub.parts.
define buffer bf_parts-root        for ub.parts-root.
define buffer bf_doc-line          for ub.doc-line.
define buffer cli-buf              for ub.clients.
define buffer bf_goods             for ub.goods.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
define buffer bf_sysconf           for ub.sysconf.
define buffer clients              for ub.clients  .
define buffer pay-type             for ub.pay-type  .
define buffer firm                 for ub.firm  .
define buffer curr-accnt           for ub.curr-accnt  .
define buffer doc-line for ub.doc-line  .

define variable vartot-docold                       like ub.trn-doc.tot-doc                    no-undo.
define variable vartot-rublold                      like ub.trn-doc.tot-rubl                   no-undo.
define variable i-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov                     no-undo.
define variable i-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl                  no-undo.
define variable i-total-doc-line_fact-baseold       like ub.trn-doc.fact-base                  no-undo.
define variable i-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty                  no-undo.
define variable i-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty                   no-undo.
define variable i-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty                   no-undo.
define variable i-total-parts_fact-baseold          as   decimal                               no-undo.
define variable i-total-parts_fact-rublold          as   decimal                               no-undo.
define variable i-total-parts_fact-qntyold          as   decimal                               no-undo.
define variable varto-exp-rubl                      as   decimal                               no-undo.
define variable varto-exp-base                      as   decimal                               no-undo.
define variable varto-inc-rubl                      as   decimal                               no-undo.
define variable varto-inc-base                      as   decimal                               no-undo.
define variable varprice-base                       like ub.parts.price-base                   no-undo.
define variable varsum-base                         like ub.parts.price-base                   no-undo.
define variable varprice-rubl                       like ub.parts.price-rubl                   no-undo.
define variable varsum-rubl                         like ub.parts.price-rubl                   no-undo.
define variable varprice-cli                        like ub.parts.price-rubl                   no-undo.
define variable varsum-cli                          like ub.parts.price-rubl                   no-undo.
define variable varcli-base-rate                    like ub.parts.cli-base-rate                no-undo.
define variable varvat-type                         like ub.parts.vat-type                     no-undo.
define variable varslt-type                         like ub.parts.slt-type                     no-undo.
define variable varvat-pc                           like ub.parts.vat-pc                       no-undo.
define variable varvat-base                         like ub.parts.price-base                   no-undo.
define variable varsum-vat-base                     like ub.parts.price-base                   no-undo.
define variable varvat-rubl                         like ub.parts.price-rubl                   no-undo.
define variable varsum-vat-rubl                     like ub.parts.price-rubl                   no-undo.
define variable varvat-cli                          like ub.parts.price-rubl                   no-undo.
define variable varsum-vat-cli                      like ub.parts.price-rubl                   no-undo.
define variable varslt-pc                           like ub.parts.slt-pc                       no-undo.
define variable varslt-base                         like ub.parts.price-base                   no-undo.
define variable varsum-slt-base                     like ub.parts.price-base                   no-undo.
define variable varslt-rubl                         like ub.parts.price-rubl                   no-undo.
define variable varsum-slt-rubl                     like ub.parts.price-rubl                   no-undo.
define variable varslt-cli                          like ub.parts.price-rubl                   no-undo.
define variable varsum-slt-cli                      like ub.parts.price-rubl                   no-undo.
define variable varroad-tax-base                    like ub.parts.road-tax-base   initial 0.00 no-undo.
define variable varsum-road-tax-base                like ub.parts.road-tax-base   initial 0.00 no-undo.
define variable varroad-tax-rubl                    like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable varsum-road-tax-rubl                like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable varroad-tax-cli                     like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable varsum-road-tax-cli                 like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable vartransport-base                   like ub.parts.transport-base  initial 0.00 no-undo.
define variable varsum-transport-base               like ub.parts.transport-base  initial 0.00 no-undo.
define variable vartransport-rubl                   like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable varsum-transport-rubl               like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable vartransport-cli                    like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable varsum-transport-cli                like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable varother-base                       like ub.parts.other-base      initial 0.00 no-undo.
define variable varsum-other-base                   like ub.parts.other-base      initial 0.00 no-undo.
define variable varother-rubl                       like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varsum-other-rubl                   like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varother-cli                        like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varsum-other-cli                    like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varrdtaxname                        as   character                             no-undo.
define variable varsum-exp-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varsum-inc-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varsum-exp-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varsum-inc-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-exp-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-inc-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-exp-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-inc-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varlog-err                          as   logical                               no-undo.
define variable varcntr-prn-code                    like ub.contract.contract-prn-code         no-undo.
define variable varcntr-name                        like ub.contract.contract-name             no-undo.
define variable varpurch-code                       like ub.parts.purch-code                   no-undo.
define variable varlog                              as   logical                               no-undo.
define variable ref-rec                             as   recid                                 no-undo.
define variable varfile-name                        as   character initial "log-cor.err"       no-undo.
define variable parext-doc-mode                     as   character                             no-undo.

define stream str-err.

define temp-table tt-chs-parts no-undo like ub.parts.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i noprocess }
{ str/hvrdtax.i  }
{ cmp/strcodec.i }
{ str/doc-code.i }
{ cmp/titlmode.i }
{ str/lib-trn.i  }
{ str/clcprtsl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ trg/holdprts.i }
{ gbl/tax-name.i }
{ str/cntrcode.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ str/vrclvmd.i  }


define temp-table temp-parts no-undo
  like ub.parts
  field free-qnty as decimal
  field free-cli-qnty as decimal
.

define temp-table tt-old-doc-line-sum no-undo like ub.doc-line-sum.

function disp-unit-base return character (buffer local-parts for bf-orig_parts).
define buffer bf_goods for ub.goods.
find first bf_goods where bf_goods.artic     = local-parts.artic     and
                          bf_goods.prod-type = local-parts.prod-type and
                          bf_goods.prod-code = local-parts.prod-code no-lock.
return bf_goods.unit-base.
end function.

define temp-table tt-del-list no-undo
field rec-id as recid
index rec-id is unique primary rec-id.

define temp-table tt-del-list-op no-undo
field rec-id as recid
index rec-id is unique primary rec-id.

define temp-table tt-cur-parts no-undo like ub.parts.
define temp-table tt-new-parts no-undo like ub.parts.

function get-mark-orig return character (buffer local-parts for bf-orig_parts ).
   find first tt-del-list-op where tt-del-list-op.rec-id = recid( local-parts ) no-error.
   if available tt-del-list-op then do:
     return "*".
   end.
   else do:
     return "".
   end.
end function.

function get-mark return character (buffer local-doc-line for ub.doc-line).
   find first tt-del-list where tt-del-list.rec-id = recid( local-doc-line ) no-error.
   if available tt-del-list then do:
     return "*".
   end.
   else do:
     return "".
   end.
end function.

function fpurch-code return character (buffer local-parts for ub.parts).
  &scop purchase-code string(local-parts.purch-code)
  return {&purchase-codes-name}.
end.

&scop window-name          d-doc
&scop frame-name           d-doc

&scop browse-name          br
&scop label-clmn_1-br      '*'
&scop sort-clmn_1-br       get-mark (buffer bf_doc-line)
&scop label-clmn_2-br      'Артикул'
&scop sort-clmn_2-br       bf_doc-line.artic
&scop label-clmn_3-br      'Название товара'
&scop sort-clmn_3-br       bf_goods.gds-name
&scop label-clmn_4-br      'Тип'
&scop sort-clmn_4-br       bf_doc-line.prod-type
&scop label-clmn_5-br      'Код произ'
&scop sort-clmn_5-br       bf_doc-line.prod-code
&scop label-clmn_6-br      'Изм. кол-во'
&scop sort-clmn_6-br       bf-expp_doc-line-sum.fact-qnty
&scop label-clmn_7-br      'Расход сумма ({&abbr_rub})'
&scop sort-clmn_7-br       bf-expp_doc-line-sum.cost-sum-rubl
&scop label-clmn_8-br      'Расход сумма (вал)'
&scop sort-clmn_8-br       bf-expp_doc-line-sum.cost-sum-base
&scop label-clmn_9-br      'Приход сумма ({&abbr_rub})'
&scop sort-clmn_9-br       bf-incp_doc-line-sum.cost-sum-rubl
&scop label-clmn_10-br     'Приход сумма (вал)'
&scop sort-clmn_10-br      bf-incp_doc-line-sum.cost-sum-base
&scop label-clmn_11-br     'Расход НДС ({&abbr_rub})'
&scop sort-clmn_11-br      bf-expp_doc-line-sum.cost-vat-rubl
&scop label-clmn_12-br     'Расход НДС (вал)'
&scop sort-clmn_12-br      bf-expp_doc-line-sum.cost-vat-base
&scop label-clmn_13-br     'Приход НДС ({&abbr_rub})'
&scop sort-clmn_13-br      bf-incp_doc-line-sum.cost-vat-rubl
&scop label-clmn_14-br     'Приход НДС (вал)'
&scop sort-clmn_14-br      bf-incp_doc-line-sum.cost-vat-base
&scop label-clmn_15-br     'Расход НП ({&abbr_rub})'
&scop sort-clmn_15-br      bf-expp_doc-line-sum.cost-slt-rubl
&scop label-clmn_16-br     'Расход НП (вал)'
&scop sort-clmn_16-br      bf-expp_doc-line-sum.cost-slt-base
&scop label-clmn_17-br     'Приход НП ({&abbr_rub})'
&scop sort-clmn_17-br      bf-incp_doc-line-sum.cost-slt-rubl
&scop label-clmn_18-br     'Приход НП (вал)'
&scop sort-clmn_18-br      bf-incp_doc-line-sum.cost-slt-base
&scop label-clmn_19-br     ''
&scop sort-clmn_19-br      bf-expp_doc-line-sum.cost-road-tax-rubl
&scop label-clmn_20-br     ''
&scop sort-clmn_20-br      bf-expp_doc-line-sum.cost-road-tax-base
&scop label-clmn_21-br     ''
&scop sort-clmn_21-br      bf-incp_doc-line-sum.cost-road-tax-rubl
&scop label-clmn_22-br     ''
&scop sort-clmn_22-br      bf-incp_doc-line-sum.cost-road-tax-base
&scop label-clmn_23-br     'Расход трансп. и прочие расходы ({&abbr_rub})'
&scop sort-clmn_23-br      bf-expp_doc-line-sum.cost-transport-rubl + bf-expp_doc-line-sum.cost-other-rubl
&scop label-clmn_24-br     'Расход трансп. и прочие расходы (вал)'
&scop sort-clmn_24-br      bf-expp_doc-line-sum.cost-transport-base + bf-expp_doc-line-sum.cost-other-base
&scop label-clmn_25-br     'Приход трансп. и прочие расходы ({&abbr_rub})'
&scop sort-clmn_25-br      bf-incp_doc-line-sum.cost-transport-rubl + bf-incp_doc-line-sum.cost-other-rubl
&scop label-clmn_26-br     'Приход трансп. и прочие расходы (вал)'
&scop sort-clmn_26-br      bf-incp_doc-line-sum.cost-transport-base + bf-incp_doc-line-sum.cost-other-base

&scop browse-name-op       br-op
&scop label-clmn_1-br-op   '*'
&scop sort-clmn_1-br-op    get-mark-orig (buffer bf-orig_parts)
&scop label-clmn_2-br-op   'Номер док-та'
&scop sort-clmn_2-br-op    bf-orig_parts.in-code
&scop label-clmn_3-br-op   'Код партии'
&scop sort-clmn_3-br-op    bf-orig_parts.part-code
&scop label-clmn_4-br-op   'Количество'
&scop sort-clmn_4-br-op    bf-orig_parts.qnty
&scop label-clmn_5-br-op   'Факт'
&scop sort-clmn_5-br-op    bf-orig_parts.fact-qnty
&scop label-clmn_6-br-op   'Изм'
&scop sort-clmn_6-br-op    disp-unit-base (buffer bf-orig_parts)
&scop label-clmn_7-br-op   'Цена ({&abbr_rub})'
&scop sort-clmn_7-br-op    bf-orig_parts.price-rubl
&scop label-clmn_8-br-op   'Цена(баз.вал.)'
&scop sort-clmn_8-br-op    bf-orig_parts.price-base
&scop label-clmn_9-br-op   'НДС'
&scop sort-clmn_9-br-op    bf-orig_parts.vat-pc
&scop label-clmn_10-br-op  'НП'
&scop sort-clmn_10-br-op   bf-orig_parts.slt-pc
&scop label-clmn_11-br-op  ''
&scop sort-clmn_11-br-op   bf-orig_parts.road-tax-rubl
&scop label-clmn_12-br-op  ''
&scop sort-clmn_12-br-op   bf-orig_parts.road-tax-base
&scop label-clmn_13-br-op  'Транспортные расходы({&abbr_rub})'
&scop sort-clmn_13-br-op   bf-orig_parts.transport-rubl
&scop label-clmn_14-br-op  'Транспортные расходы(баз.вал.)'
&scop sort-clmn_14-br-op   bf-orig_parts.transport-base
&scop label-clmn_15-br-op  'Прочие расходы({&abbr_rub})'
&scop sort-clmn_15-br-op   bf-orig_parts.other-rubl
&scop label-clmn_16-br-op  'Прочие расходы(баз.вал.)'
&scop sort-clmn_16-br-op   bf-orig_parts.other-base
&scop label-clmn_17-br-op  'Тип приобретения'
&scop sort-clmn_17-br-op   fpurch-code (buffer bf-orig_parts)

&scop browse-name-cp       br-cp
&scop label-clmn_1-br-cp   'Код партии'
&scop sort-clmn_1-br-cp    bf-caus_parts.part-code
&scop label-clmn_2-br-cp   'Количество'
&scop sort-clmn_2-br-cp    bf-caus_parts.qnty
&scop label-clmn_3-br-cp   'Факт'
&scop sort-clmn_3-br-cp    bf-caus_parts.fact-qnty
&scop label-clmn_4-br-cp   'Изм'
&scop sort-clmn_4-br-cp    disp-unit-base (buffer bf-caus_parts)
&scop label-clmn_5-br-cp   'Цена ({&abbr_rub})'
&scop sort-clmn_5-br-cp    bf-caus_parts.price-rubl
&scop label-clmn_6-br-cp   'Цена(баз.вал.)'
&scop sort-clmn_6-br-cp    bf-caus_parts.price-base
&scop label-clmn_7-br-cp   'НДС'
&scop sort-clmn_7-br-cp    bf-caus_parts.vat-pc
&scop label-clmn_8-br-cp   'НП'
&scop sort-clmn_8-br-cp    bf-caus_parts.slt-pc
&scop label-clmn_9-br-cp   ''
&scop sort-clmn_9-br-cp    bf-caus_parts.road-tax-rubl
&scop label-clmn_10-br-cp  ''
&scop sort-clmn_10-br-cp   bf-caus_parts.road-tax-base
&scop label-clmn_11-br-cp  'Транспортные расходы({&abbr_rub})'
&scop sort-clmn_11-br-cp   bf-caus_parts.transport-rubl
&scop label-clmn_12-br-cp  'Транспортные расходы(баз.вал.)'
&scop sort-clmn_12-br-cp   bf-caus_parts.transport-base
&scop label-clmn_13-br-cp  'Прочие расходы({&abbr_rub})'
&scop sort-clmn_13-br-cp   bf-caus_parts.other-rubl
&scop label-clmn_14-br-cp  'Прочие расходы(баз.вал.)'
&scop sort-clmn_14-br-cp   bf-caus_parts.other-base
&scop label-clmn_15-br-cp  'Тип приобретения'
&scop sort-clmn_15-br-cp   fpurch-code (buffer bf-caus_parts)

/* запрос по исходным партиям */
&scop open-query-br open query {&browse-name} ~
   for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code, ~
     first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and ~
                                bf_goods.prod-type = bf_doc-line.prod-type and ~
                                bf_goods.prod-code = bf_doc-line.prod-code ,   ~
      first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and ~
                                       bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and ~
                                       bf-expp_doc-line-sum.sum-type = {&sum-expense-parts} ,    ~
        first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and ~
                                         bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and ~
                                         bf-incp_doc-line-sum.sum-type = {&sum-income-parts}

&scop open-query-br-op open query {&browse-name-op} ~
  for each bf-orig_parts where bf-orig_parts.out-code  = t-doc.doc-code        and   ~
                               bf-orig_parts.obj-type  = t-doc.obj-type        and   ~
                               bf-orig_parts.obj-code  = t-doc.obj-code        and   ~
                               bf-orig_parts.artic     = bf_doc-line.artic     and   ~
                               bf-orig_parts.prod-type = bf_doc-line.prod-type and   ~
                               bf-orig_parts.prod-code = bf_doc-line.prod-code and   ~
                               bf-orig_parts.in-code  <> t-doc.doc-code no-lock, ~
      first bf-orig_goods where bf-orig_goods.artic     = bf-orig_parts.artic     and      ~
                                bf-orig_goods.prod-type = bf-orig_parts.prod-type and      ~
                                bf-orig_goods.prod-code = bf-orig_parts.prod-code no-lock
/* запрос по порожденным партиям */
&scop open-query-br-cp open query {&browse-name-cp} ~
  for each bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code  and      ~
                               bf_parts-root.orig-in-code   = bf-orig_parts.in-code   and      ~
                               bf_parts-root.orig-gds-code  = bf-orig_goods.gds-code  and      ~
                               bf_parts-root.orig-part-code = bf-orig_parts.part-code no-lock, ~
      first bf-caus_parts where bf-caus_parts.out-code  = bf_parts-root.doc-code  and ~
                                bf-caus_parts.obj-type  = bf-orig_parts.obj-type  and ~
                                bf-caus_parts.obj-code  = bf-orig_parts.obj-code  and ~
                                bf-caus_parts.artic     = bf-orig_parts.artic     and ~
                                bf-caus_parts.prod-type = bf-orig_parts.prod-type and ~
                                bf-caus_parts.prod-code = bf-orig_parts.prod-code and ~
                                bf-caus_parts.in-code   = bf_parts-root.in-code   and ~
                                bf-caus_parts.part-code = bf_parts-root.part-code

define query {&browse-name} for bf_doc-line except, bf_goods except, bf-expp_doc-line-sum except, bf-incp_doc-line-sum except
scrolling.
define query {&browse-name-op} for bf-orig_parts except, bf-orig_goods except scrolling.
define query {&browse-name-cp} for bf_parts-root except, bf-caus_parts except scrolling.

define browse {&browse-name} query {&browse-name} no-lock display
  {&sort-clmn_1-br}    column-label {&label-clmn_1-br} format "x(1)"
  {&sort-clmn_2-br}    column-label {&label-clmn_2-br}
  {&sort-clmn_3-br}    column-label {&label-clmn_3-br} format "x(20)"
  {&sort-clmn_4-br}    column-label {&label-clmn_4-br} format "x(3)"
  {&sort-clmn_5-br}    column-label {&label-clmn_5-br}
  {&sort-clmn_6-br}    column-label {&label-clmn_6-br}
  {&sort-clmn_7-br}    column-label {&label-clmn_7-br}
  {&sort-clmn_8-br}    column-label {&label-clmn_8-br}
  {&sort-clmn_9-br}    column-label {&label-clmn_9-br}
  {&sort-clmn_10-br}   column-label {&label-clmn_10-br}
  {&sort-clmn_11-br}   column-label {&label-clmn_11-br}
  {&sort-clmn_12-br}   column-label {&label-clmn_12-br}
  {&sort-clmn_13-br}   column-label {&label-clmn_13-br}
  {&sort-clmn_14-br}   column-label {&label-clmn_14-br}
  {&sort-clmn_15-br}   column-label {&label-clmn_15-br}
  {&sort-clmn_16-br}   column-label {&label-clmn_16-br}
  {&sort-clmn_17-br}   column-label {&label-clmn_17-br}
  {&sort-clmn_18-br}   column-label {&label-clmn_18-br}
  {&sort-clmn_19-br}   column-label {&label-clmn_19-br}
  {&sort-clmn_20-br}   column-label {&label-clmn_20-br}
  {&sort-clmn_21-br}   column-label {&label-clmn_21-br}
  {&sort-clmn_22-br}   column-label {&label-clmn_22-br}
  {&sort-clmn_23-br}  @ varto-exp-rubl column-label {&label-clmn_23-br}
  {&sort-clmn_24-br}  @ varto-exp-base column-label {&label-clmn_24-br}
  {&sort-clmn_25-br}  @ varto-inc-rubl column-label {&label-clmn_25-br}
  {&sort-clmn_26-br}  @ varto-inc-base column-label {&label-clmn_26-br}
  enable {&sort-clmn_5-br}
  with size 98 by 5 separators.

define browse {&browse-name-op} query {&browse-name-op} no-lock display
  {&sort-clmn_1-br-op}  column-label {&label-clmn_1-br-op} format "x(1)"
  {&sort-clmn_2-br-op}  column-label {&label-clmn_2-br-op}
  {&sort-clmn_3-br-op}  column-label {&label-clmn_3-br-op}
  {&sort-clmn_4-br-op}  column-label {&label-clmn_4-br-op}
  {&sort-clmn_5-br-op}  column-label {&label-clmn_5-br-op}
  {&sort-clmn_6-br-op}  column-label {&label-clmn_6-br-op} format "x(3)"
  {&sort-clmn_7-br-op}  column-label {&label-clmn_7-br-op}
  {&sort-clmn_8-br-op}  column-label {&label-clmn_8-br-op}
  {&sort-clmn_9-br-op}  column-label {&label-clmn_9-br-op}
  {&sort-clmn_10-br-op} column-label {&label-clmn_10-br-op}
  {&sort-clmn_11-br-op} column-label {&label-clmn_11-br-op}
  {&sort-clmn_12-br-op} column-label {&label-clmn_12-br-op}
  {&sort-clmn_13-br-op} column-label {&label-clmn_13-br-op}
  {&sort-clmn_14-br-op} column-label {&label-clmn_14-br-op}
  {&sort-clmn_15-br-op} column-label {&label-clmn_15-br-op}
  {&sort-clmn_16-br-op} column-label {&label-clmn_16-br-op}
  {&sort-clmn_17-br-op} column-label {&label-clmn_17-br-op} format "x(20)"
  enable {&sort-clmn_4-br-op}
  with size 98 by 4 separators.

define browse {&browse-name-cp} query {&browse-name-cp} no-lock display
  {&sort-clmn_1-br-cp}  column-label {&label-clmn_1-br-cp}
  {&sort-clmn_2-br-cp}  column-label {&label-clmn_2-br-cp}
  {&sort-clmn_3-br-cp}  column-label {&label-clmn_3-br-cp}
  {&sort-clmn_4-br-cp}  column-label {&label-clmn_4-br-cp} format "x(3)"
  {&sort-clmn_5-br-cp}  column-label {&label-clmn_5-br-cp}
  {&sort-clmn_6-br-cp}  column-label {&label-clmn_6-br-cp}
  {&sort-clmn_7-br-cp}  column-label {&label-clmn_7-br-cp}
  {&sort-clmn_8-br-cp}  column-label {&label-clmn_8-br-cp}
  {&sort-clmn_9-br-cp}  column-label {&label-clmn_9-br-cp}
  {&sort-clmn_10-br-cp} column-label {&label-clmn_10-br-cp}
  {&sort-clmn_11-br-cp} column-label {&label-clmn_11-br-cp}
  {&sort-clmn_12-br-cp} column-label {&label-clmn_12-br-cp}
  {&sort-clmn_13-br-cp} column-label {&label-clmn_13-br-cp}
  {&sort-clmn_14-br-cp} column-label {&label-clmn_14-br-cp}
  {&sort-clmn_15-br-cp} column-label {&label-clmn_15-br-cp} format "x(20)"
  enable {&sort-clmn_2-br-cp}
  with size 98 by 4 separators.

/* ***********************  control definitions  ********************** */
define variable agnt-name as character format "x(256)":u
      view-as text
     size 15.5 by 1 no-undo.

define variable wrkr-name as character format "x(256)":u
      view-as text
     size 15.5 by 1 no-undo.

define variable boss-name as character format "x(256)":u
      view-as text
     size 15.5 by 1 no-undo.
define variable ref-list     as character no-undo.

define variable rsn-name as character no-undo view-as fill-in size 37 by .88 fgcolor 4 format "x(256)":U.

define button b-mark
     label "&*":l
     size 3 by 1.

define button b-mark-op
     label "&*О":l
     size 3 by 1.

define button b-add
     label "&Добавить":l
     size 9 by 1.

define button b-chg
     label "&Изменить":l
     size 9 by 1.

define button b-chgvat
     label "&Заменить НДС":l
     size 13 by 1.

define button b-lkp
     label "&Партии"
     size 8 by 1.

define button b-lkp-op
     label "&Просм ориг":l
     size 15 by 1.

define button b-lkp-cp
     label "Просм поро&жд":l
     size 15 by 1.

define button b-chg-cp
     label "&Изм порожд":l
     size 15 by 1.

define button b-del
     label "&Удалить":l
     size 8 by 1.

define button b-notes
     label "При&меч":l
     size 8 by 1.

define button b-arch
     label "Уч&ет":l
     size 8 by 1.

define button b-cnt
     label "&ДогП":l
     size 8 by 1.

define button b-history
     label "Ис&тория"
     size 8 by 1.

define button b-help
     label "Помо&щь":l
     size 8 by 1.

define button b-exit auto-go
     label "&Выход":l
     size 6 by 1.

define button b-next auto-go
     label "&>>":l
     size 3 by 1.

define button b-prev auto-go
     label "&<<":l
     size 3 by 1.

define button b-sum-doc
     label "&СумДок":l
     size 8 by 1.

define button b-sum-goods
     label "&СумТов":l
     size 8 by 1.

define button b-file
     label "&Файл":l
     size 8 by 1.

define button r-agnt
       image-up          file "btn-down-arrow"
       image-down        file "btn-down-arrow"
       image-insensitive file "btn-down-arrow"
       size 3 by .88.

define rectangle rect-1 size 90 by 3 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.

define button r-boss    like r-agnt.
define button r-wrkr    like r-agnt.
define button r-acc     like r-agnt.
define button r-clients like r-agnt.
define button r-reas    like r-agnt.
/*define button r-sht     like r-agnt.*/


/* ************************  frame definitions  *********************** */
define frame {&frame-name}
  t-doc.cli-code      at row 1    col 17 colon-aligned label "Контра&гент" view-as fill-in size 10 by 1 format ">>>>>>>>9"
  t-doc.cli-type      at row 1    col 28 colon-aligned no-label view-as fill-in size 4 by 1
  r-clients           at row 1    col 35 no-label
  clients.obj-name    at row 1    col 36 colon-aligned no-label view-as fill-in size 35 by 1 fgcolor 4
  b-exit              at row 1    col 1
  b-prev              at row 2    col 1
  b-next              at row 2    col 4
  varcntr-prn-code    at row 1    col 62 colon-aligned label "Договор"
  varcntr-name        at row 1    col 80 colon-aligned no-label format "x(15)"
  b-mark              at row 22.5 col 1
  b-add               at row 22.5 col 4
  b-lkp               at row 22.5 col 13
  b-chg               at row 22.5 col 21
  b-chgvat            at row 22.5 col 30
  b-del               at row 22.5 col 43
  b-file              at row 22.5 col 51
  b-notes             at row 22.5 col 59
  b-arch              at row 22.5 col 67
  b-cnt               at row 22.5 col 75
  b-history               at row 22.5 col 83
  b-help              at row 22.5 col 91
  t-doc.fact-rubl     at row 1.8  col 17 colon-aligned label "Сумма({&abbr_rub})"
  t-doc.fact-base     at row 2.6  col 17 colon-aligned label "Сумма(вал)"
  varsum-exp-rubl     at row 1.8  col 46 colon-aligned label "Расход({&abbr_rub})"
  varsum-inc-rubl     at row 1.8  col 75 colon-aligned label "Приход({&abbr_rub})"
  varsum-exp-base     at row 2.6  col 46 colon-aligned label "Расход(вал)"
  varsum-inc-base     at row 2.6  col 75 colon-aligned label "Приход(вал)"
  varvat-exp-rubl     at row 3.4  col 18 colon-aligned label "Расход НДС ({&abbr_rub})" bgcolor 3 fgcolor 15
  varvat-inc-rubl     at row 3.4  col 62 colon-aligned label "Приход НДС ({&abbr_rub})" bgcolor 3 fgcolor 15
  varvat-exp-base     at row 4.2  col 18 colon-aligned label "Расход НДС (вал)" bgcolor 3 fgcolor 15
  varvat-inc-base     at row 4.2  col 62 colon-aligned label "Приход НДС (вал)" bgcolor 3 fgcolor 15
.
define frame {&frame-name}
  t-doc.wrkr          format "999999999" at row 5.1 col 8  colon-aligned view-as fill-in size 10 by 1
  wrkr-name           at row 5.2 col 18 colon-aligned no-label  fgcolor 4
  r-wrkr              at row 5.2 col 41 no-label
  t-doc.agnt          format "999999999" at row 6 col 8 colon-aligned view-as fill-in size 10 by 1
  agnt-name           at row 6.1 col 18 colon-aligned no-label fgcolor 4
  r-agnt              at row 6.1 col 41 no-label
  t-doc.boss          format "999999999" at row 7 col 8 colon-aligned view-as fill-in size 10 by 1
  boss-name           at row 7 col 18 colon-aligned no-label fgcolor 4
  r-boss              at row 7 col 41 no-label
  t-doc.doc-date      at row 5 col 50 colon-aligned label "&Дата"  view-as fill-in size 9 by 1 fgcolor 4
  t-doc.fact-date     at row 6 col 50 colon-aligned label "&Факт"  view-as fill-in size 9 by 1 fgcolor 4
  t-doc.shift-date    at row 7 col 50 colon-aligned label "&Смена" view-as fill-in size 9 by 1 fgcolor 4
  t-doc.shift-name    at row 7 col 63 colon-aligned label "№"      view-as fill-in size 3 by 1 fgcolor 4
  t-doc.shift-num     at row 7 col 69 colon-aligned label "П"      view-as fill-in size 3 by 1 fgcolor 4
  /*r-sht               at row 7 col 73 colon-aligned*/
  t-doc.reason-code   at row 5.12 col 64     label "Код основ.(причины)" format ">>>>>>>>>9":U view-as fill-in size 11 by .88
  r-reas              at row 5.12 col 96
  rsn-name            at row 6.12 col 62  no-label

  {&browse-name}      at row 8 col 1
  {&browse-name-op}   at row 13 col 1
  b-mark-op           at row 17.5 col 1
  b-lkp-op            at row 17.5 col 4
  b-lkp-cp            at row 17.5 col 19
  b-chg-cp            at row 17.5 col 34
  {&browse-name-cp}   at row 18.5 col 1
  space(0) skip(0) with view-as dialog-box side-labels three-d scrollable keep-tab-order.

assign
  {&browse-name}:num-locked-columns    in frame {&frame-name} = 5
  {&browse-name-op}:num-locked-columns in frame {&frame-name} = 3
  {&browse-name-cp}:num-locked-columns in frame {&frame-name} = 1
  frame {&frame-name}:scrollable  = false
       .

assign
  r-reas            :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа. Вызов справочника"
  t-doc.reason-code :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа. Ввод кода"
  rsn-name          :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа"
.

{ gbl/mv-clmn.i
 &ext-col      = 17
 &frame-name   = {&frame-name}
 &browse-name  = {&browse-name-op}
 &start-column = 4
}

{ gbl/mv-clmn.i
 &ext-col      = 15
 &frame-name   = {&frame-name}
 &browse-name  = {&browse-name-cp}
 &start-column = 2
}


{ gbl/mv-clmn.i
 &ext-col      = 26
 &frame-name   = {&frame-name}
 &browse-name  = {&browse-name}
 &start-column = 3
}

{ gbl/srt-clmn.i
&browse-name   = {&browse-name}
&frame-name    = {&frame-name}
&table-name    = "bf_doc-line"
&ext-col       = 26
&start-column  = 3
&label-clmn_1  = "{&label-clmn_1-br}"
&sort-clmn_1   = "{&sort-clmn_1-br}"
&label-clmn_2  = "{&label-clmn_2-br}"
&sort-clmn_2   = "{&sort-clmn_2-br}"
&label-clmn_3  = "{&label-clmn_3-br}"
&sort-clmn_3   = "{&sort-clmn_3-br}"
&label-clmn_4  = "{&label-clmn_4-br}"
&sort-clmn_4   = "{&sort-clmn_4-br}"
&label-clmn_5  = "{&label-clmn_5-br}"
&sort-clmn_5   = "{&sort-clmn_5-br}"
&label-clmn_6  = "{&label-clmn_6-br}"
&sort-clmn_6   = "{&sort-clmn_6-br}"
&label-clmn_7  = "{&label-clmn_7-br}"
&sort-clmn_7   = "{&sort-clmn_7-br} descending"
&label-clmn_8  = "{&label-clmn_8-br}"
&sort-clmn_8   = "{&sort-clmn_8-br} descending"
&label-clmn_9  = "{&label-clmn_9-br}"
&sort-clmn_9   = "{&sort-clmn_9-br} descending"
&label-clmn_10 = "{&label-clmn_10-br}"
&sort-clmn_10  = "{&sort-clmn_10-br} descending"
&label-clmn_11 = "{&label-clmn_11-br}"
&sort-clmn_11  = "{&sort-clmn_11-br} descending"
&label-clmn_12 = "{&label-clmn_12-br}"
&sort-clmn_12  = "{&sort-clmn_12-br} descending"
&label-clmn_13 = "{&label-clmn_13-br}"
&sort-clmn_13  = "{&sort-clmn_13-br} descending"
&label-clmn_14 = "{&label-clmn_14-br}"
&sort-clmn_14  = "{&sort-clmn_14-br} descending"
&label-clmn_15 = "{&label-clmn_15-br}"
&sort-clmn_15  = "{&sort-clmn_15-br} descending"
&label-clmn_16 = "{&label-clmn_16-br}"
&sort-clmn_16  = "{&sort-clmn_16-br} descending"
&label-clmn_17 = "{&label-clmn_17-br}"
&sort-clmn_17  = "{&sort-clmn_17-br} descending"
&label-clmn_18 = "{&label-clmn_18-br}"
&sort-clmn_18  = "{&sort-clmn_18-br} descending"
&label-clmn_19 = "bf-expp_doc-line-sum.cost-road-tax-rubl:label in browse {&browse-name}"
&sort-clmn_19  = "{&sort-clmn_19-br} descending"
&label-clmn_20 = "bf-expp_doc-line-sum.cost-road-tax-base:label in browse {&browse-name}"
&sort-clmn_20  = "{&sort-clmn_20-br} descending"
&label-clmn_21 = "bf-incp_doc-line-sum.cost-road-tax-rubl:label in browse {&browse-name}"
&sort-clmn_21  = "{&sort-clmn_21-br} descending"
&label-clmn_22 = "bf-incp_doc-line-sum.cost-road-tax-base:label in browse {&browse-name}"
&sort-clmn_22  = "{&sort-clmn_22-br} descending"
&label-clmn_23 = "{&label-clmn_23-br}"
&sort-clmn_23  = "{&sort-clmn_23-br} descending"
&label-clmn_24 = "{&label-clmn_24-br}"
&sort-clmn_24  = "{&sort-clmn_24-br} descending"
&label-clmn_25 = "{&label-clmn_25-br}"
&sort-clmn_25  = "{&sort-clmn_25-br} descending"
&label-clmn_26 = "{&label-clmn_26-br}"
&sort-clmn_26  = "{&sort-clmn_26-br} descending"
&open-query = "{&open-query-{&browse-name}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name}}."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
}

/*
{ gbl/srt-clmn.i
&browse-name = {&browse-name-op}
&frame-name  = {&frame-name}
&table-name = "bf-orig_parts"
&ext-col = 17
&start-column  = 4
&label-clmn_1  = "{&label-clmn_1-br-op}"
&sort-clmn_1   = "{&sort-clmn_1-br-op}"
&label-clmn_2  = "{&label-clmn_2-br-op}"
&sort-clmn_2   = "{&sort-clmn_2-br-op}"
&label-clmn_3  = "{&label-clmn_3-br-op}"
&sort-clmn_3   = "{&sort-clmn_3-br-op}"
&label-clmn_4  = "{&label-clmn_4-br-op}"
&sort-clmn_4   = "{&sort-clmn_4-br-op}"
&label-clmn_5  = "{&label-clmn_5-br-op}"
&sort-clmn_5   = "{&sort-clmn_5-br-op}"
&label-clmn_6  = "{&label-clmn_6-br-op}"
&sort-clmn_6   = "{&sort-clmn_6-br-op}"
&label-clmn_7  = "{&label-clmn_7-br-op}"
&sort-clmn_7   = "{&sort-clmn_7-br-op}"
&label-clmn_8  = "{&label-clmn_8-br-op}"
&sort-clmn_8   = "{&sort-clmn_8-br-op}"
&label-clmn_9  = "{&label-clmn_9-br-op}"
&sort-clmn_9   = "{&sort-clmn_9-br-op}"
&label-clmn_10 = "{&label-clmn_10-br-op}"
&sort-clmn_10  = "{&sort-clmn_10-br-op}"
&label-clmn_11 = "{&label-clmn_11-br-op}"
&sort-clmn_11  = "{&sort-clmn_11-br-op}"
&label-clmn_12 = "{&label-clmn_12-br-op}"
&sort-clmn_12  = "{&sort-clmn_12-br-op}"
&label-clmn_13 = "{&label-clmn_13-br-op}"
&sort-clmn_13  = "{&sort-clmn_13-br-op}"
&label-clmn_14 = "{&label-clmn_14-br-op}"
&sort-clmn_14  = "{&sort-clmn_14-br-op}"
&label-clmn_15 = "{&label-clmn_15-br-op}"
&sort-clmn_15  = "{&sort-clmn_15-br-op}"
&label-clmn_16 = "{&label-clmn_16-br-op}"
&sort-clmn_16  = "{&sort-clmn_16-br-op}"
&label-clmn_17 = "{&label-clmn_17-br-op}"
&sort-clmn_17  = "{&sort-clmn_17-br-op}"
&open-query = "{&open-query-{&browse-name-op}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name-op}}."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
}

{ gbl/srt-clmn.i
&browse-name = {&browse-name-cp}
&frame-name  = {&frame-name}
&table-name = "bf_parts-root"
&ext-col = 15
&start-column  = 2
&label-clmn_1  = "{&label-clmn_1-br-cp}"
&sort-clmn_1   = "{&sort-clmn_1-br-cp}"
&label-clmn_2  = "{&label-clmn_2-br-cp}"
&sort-clmn_2   = "{&sort-clmn_2-br-cp}"
&label-clmn_3  = "{&label-clmn_3-br-cp}"
&sort-clmn_3   = "{&sort-clmn_3-br-cp}"
&label-clmn_4  = "{&label-clmn_4-br-cp}"
&sort-clmn_4   = "{&sort-clmn_4-br-cp}"
&label-clmn_5  = "{&label-clmn_5-br-cp}"
&sort-clmn_5   = "{&sort-clmn_5-br-cp}"
&label-clmn_6  = "{&label-clmn_6-br-cp}"
&sort-clmn_6   = "{&sort-clmn_6-br-cp}"
&label-clmn_7  = "{&label-clmn_7-br-cp}"
&sort-clmn_7   = "{&sort-clmn_7-br-cp}"
&label-clmn_8  = "{&label-clmn_8-br-cp}"
&sort-clmn_8   = "{&sort-clmn_8-br-cp}"
&label-clmn_9  = "{&label-clmn_9-br-cp}"
&sort-clmn_9   = "{&sort-clmn_9-br-cp}"
&label-clmn_10 = "{&label-clmn_10-br-cp}"
&sort-clmn_10  = "{&sort-clmn_10-br-cp}"
&label-clmn_11 = "{&label-clmn_11-br-cp}"
&sort-clmn_11  = "{&sort-clmn_11-br-cp}"
&label-clmn_12 = "{&label-clmn_12-br-cp}"
&sort-clmn_12  = "{&sort-clmn_12-br-cp}"
&label-clmn_13 = "{&label-clmn_13-br-cp}"
&sort-clmn_13  = "{&sort-clmn_13-br-cp}"
&label-clmn_14 = "{&label-clmn_14-br-cp}"
&sort-clmn_14  = "{&sort-clmn_14-br-cp}"
&label-clmn_15 = "{&label-clmn_15-br-cp}"
&sort-clmn_15  = "{&sort-clmn_15-br-cp}"
&open-query = "{&open-query-{&browse-name-cp}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name-cp}}."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
}
*/

on F9 of browse {&browse-name} anywhere do:
  define buffer bfl_goods for ub.goods.
    if not available bf_doc-line then
    return no-apply.
  find first bfl_goods where bfl_goods.artic     = bf_doc-line.artic     and
                             bfl_goods.prod-type = bf_doc-line.prod-type and
                             bfl_goods.prod-code = bf_doc-line.prod-code no-lock.
  run str/showgds.p ( input parparentproc
                    , input ? /*p-call-handle*/
                    , input bfl_goods.gds-code
                    , input {&lookup} ).
  apply "entry" to {&browse-name} in frame {&frame-name}.
  return no-apply.
end.

{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ str/n-p-l.i
  &doc-rec    = "pardoc-rec"
}
{ str/st-perc.i }

on end-error, stop of frame d-doc do:
  apply "choose" to b-exit in frame d-doc.
  return no-apply.
end.

on choose of b-notes in frame {&frame-name} do:
  run notes-tr in this-procedure.
end.

on choose of b-history   in frame {&frame-name} do:
  run proc-history no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-exit  in frame {&frame-name} /* Вых */
do:
  run proc-exit in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-arch in frame {&frame-name} /* Просмотр в учетных ценах */
do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }

  if not varlog then do: return no-apply. end.
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid( t-doc )
    ).
end.

on choose of b-cnt in frame {&frame-name} /* Просмотр разбивку по дог. пост. */
do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_cost':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if not varlog then do: return no-apply. end.
  run str/scntdoc.w ( input t-doc.doc-code, input ( v-cntxt-db-num = bf_sysconf.firm-db-num ) ).
end.

/*
on leave of t-doc.fact-date in frame {&frame-name} do:
  run chk-upd-date in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  assign frame {&frame-name} t-doc.fact-date.
end.
*/
/* Секция триггеров обработки смены
on return of t-doc.shift-date in frame {&frame-name} do:
  apply "entry" to t-doc.shift-name in frame {&frame-name}.
  return no-apply.
end.
on return of t-doc.shift-name in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on return of t-doc.shift-num in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.
on choose of r-sht in frame {&frame-name} do:
  run proc-sht.
end.
on leave of t-doc.shift-num  in frame {&frame-name} do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-name in frame {&frame-name} do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-date in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name = ""
      t-doc.shift-num  = 0.
    display t-doc.shift-name t-doc.shift-num with frame {&frame-name}.
    apply "entry" to t-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.
end.
*/
on choose of b-add in frame {&frame-name} /* Добав */
do:
define variable varuser-action as character no-undo.
define variable varprinted     as logical   no-undo.
assign
  varlog-err = no.
if search (varfile-name) <> ? then do:
  os-delete varfile-name.
end.
output stream str-err to value(varfile-name).
run local-add in this-procedure no-error.
if error-status :error then do:
  output stream str-err close.
  return no-apply.
end.
output stream str-err close.
if varlog-err = yes then do:
  message "При добавлении товаров были ошибки и замечания. Смотрите файл log-cor.err."
  view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки и замечания, возникшие при добавлении товаров"
    ,input  0
    ,input  varfile-name
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
end.
end.

on choose of b-chg in frame {&frame-name}  do:
  run local-chg in this-procedure.
  run ui-on in this-procedure ( input "line":U ).
  apply "entry" to {&browse-name} in frame {&frame-name} .
  reposition {&browse-name} to recid line-rec no-error.
end.

on choose of b-chgvat in frame {&frame-name}  do:
  define variable varuser-action as character no-undo.
  define variable varprinted     as logical   no-undo.

  assign
    varlog-err = no.
  if search ("log-cor.err") <> ? then do:
    os-delete "log-cor.err".
  end.
  output stream str-err to value("log-cor.err").
  run local-chg-vat in this-procedure no-error.
  if error-status :error then do:
    output stream str-err close.
    return no-apply.
  end.
  output stream str-err close.
  if varlog-err = yes then do:
    message "При изменении НДС были ошибки и замечания. Смотрите файл log-cor.err."
    view-as alert-box error.
    run gbl/prnfilen.w
      (input  "Ошибки и замечания, возникшие при изменении НДС"
      ,input  0
      ,input  "log-cor.err"
      ,input  7
      ,output varuser-action
      ,output varprinted
      ).
  end.
  run ui-on in this-procedure ( input "line":U ).
  apply "entry" to {&browse-name} in frame {&frame-name} .
  reposition {&browse-name} to recid line-rec no-error.
end.

on choose of b-file in frame {&frame-name} do:
run str/file-cor.p (input parparentproc, input t-doc.doc-code) no-error.
if error-status:error then do:
  message "Во время обработки файла произошли ошибки или не верно был выбран файл. Файл не был обработан."
          return-value
  view-as alert-box error.
  return no-apply.
end.
run ui-on ("line":u).
apply "entry" to {&browse-name} in frame {&frame-name} .
end.

on choose of b-chg-cp in frame {&frame-name}  do:
define buffer bf_goods for ub.goods.
define variable varhvrdtax as logical no-undo.
define variable varslt-yes as logical no-undo.
define variable varis-ok   as logical no-undo.
define variable varexch-rate  like ub.trn-doc.exch-rate  no-undo.
define variable varexch-scale like ub.trn-doc.exch-scale no-undo.
define variable varabbr-code  as   character             no-undo.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
do transaction on error undo, return no-apply :
if not available bf-caus_parts then do:
  message "Неверный выбор партии." view-as alert-box.
  return no-apply.
end.
run local-recalc in this-procedure ( input "old":U,
                                     input recid( bf_doc-line ) ) no-error.
if error-status :error then do:
  message
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim(error-status :get-message(1))
    view-as alert-box error.
  undo, return no-apply .
end.
find first bf_goods where bf_goods.artic     = bf-caus_parts.artic     and
                          bf_goods.prod-type = bf-caus_parts.prod-type and
                          bf_goods.prod-code = bf-caus_parts.prod-code no-lock.
assign
  varhvrdtax = hvrdtax ( recid( bf_goods ) ).
find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
{ str/chpsltpc.i
  t-doc.internal
  t-doc.doc-type
  bf-caus_parts.pay-code
  bf_sysconf.cash-pay
  bf-caus_parts.slt-type
  varslt-yes
  parext-doc-type
}
if bf-caus_parts.slt-type <> {&inc-slt} and
   bf-caus_parts.slt-type <> {&no-slt}  then do:
  assign
    varslt-yes = no.
end.
for each tt-chs-parts on error undo, return no-apply return-value :
  delete tt-chs-parts.
end.
assign
  varcli-base-rate = bf-caus_parts.cli-base-rate
  varvat-type      = bf-caus_parts.vat-type
  varslt-type      = bf-caus_parts.slt-type.
{ gbl/exchrate.i bf-caus_parts.exch-code t-doc.exch-date varexch-rate varexch-scale varabbr-code }
run str/pr-prt.w (
  input  "part":u,
  input  bf_goods.gds-code,
  input  t-doc.cli-type,
  input  t-doc.cli-code,
  input  t-doc.obj-type,
  input  t-doc.obj-code,
  input  bf-caus_parts.in-code,
  input  bf-caus_parts.out-code,
  input  bf-caus_parts.part-code,
  input  t-doc.base-rate,
  input  t-doc.base-scale,
  input  bf-caus_parts.exch-code,
  input  varexch-rate,
  input  varexch-scale,
  input  varslt-yes,
  input  varhvrdtax,
  input  t-doc.contract-code,
  input  table tt-chs-parts,
  output varprice-base,
  output varsum-base,
  output varprice-rubl,
  output varsum-rubl,
  input-output varcli-base-rate,
  input-output varvat-type,
  input-output varslt-type,
  output varprice-cli,
  output varsum-cli,
  output varvat-pc,
  output varvat-base,
  output varsum-vat-base,
  output varvat-rubl,
  output varsum-vat-rubl,
  output varvat-rubl,
  output varsum-vat-rubl,
  output varslt-pc,
  output varslt-base,
  output varsum-slt-base,
  output varslt-rubl,
  output varsum-slt-rubl,
  output varslt-cli,
  output varsum-slt-cli,
  output varroad-tax-base,
  output varsum-road-tax-base,
  output varroad-tax-rubl,
  output varsum-road-tax-rubl,
  output varroad-tax-cli,
  output varsum-road-tax-cli,
  output vartransport-base,
  output varsum-transport-base,
  output vartransport-rubl,
  output varsum-transport-rubl,
  output varother-base,
  output varsum-other-base,
  output varother-rubl,
  output varsum-other-rubl,
  output varpurch-code,
  output varis-ok         ) no-error.
if error-status :error then do:
  message
    "Ошибка при установке цен." skip
    return-value skip
    error-status :get-message( 1 )
    view-as alert-box error.
  undo, return no-apply .
end.
if varis-ok <> yes then do:
  undo, return no-apply .
end.

find current bf-caus_parts exclusive-lock.
assign
  bf-caus_parts.price-rubl     = varprice-rubl
  bf-caus_parts.price-base     = varprice-base
  bf-caus_parts.price-cli      = varprice-cli
  bf-caus_parts.cli-base-rate  = varcli-base-rate
  bf-caus_parts.vat-type       = varvat-type
  bf-caus_parts.slt-type       = varslt-type
  bf-caus_parts.vat-pc         = varvat-pc
  bf-caus_parts.slt-pc         = varslt-pc
  bf-caus_parts.road-tax-rubl  = varroad-tax-rubl
  bf-caus_parts.road-tax-base  = varroad-tax-base
  bf-caus_parts.transport-rubl = vartransport-rubl
  bf-caus_parts.transport-base = vartransport-base
  bf-caus_parts.other-rubl     = varother-rubl
  bf-caus_parts.other-base     = varother-base
  .
if varpurch-code <> ? then do:
  assign
    bf-caus_parts.purch-code = varpurch-code.
end.
end.
run local-recalc in this-procedure ( input "update":U,
                                     input recid( bf_doc-line ) ) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim(error-status :get-message(1))
    view-as alert-box error.
  undo, return no-apply .
end.
find first bf-expp_trn-doc-sum where bf-expp_trn-doc-sum.doc-code = t-doc.doc-code       and
                                     bf-expp_trn-doc-sum.sum-type = {&sum-expense-parts} no-lock no-error.
find first bf-incp_trn-doc-sum where bf-incp_trn-doc-sum.doc-code = t-doc.doc-code      and
                                     bf-incp_trn-doc-sum.sum-type = {&sum-income-parts} no-lock no-error.
display
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-rubl else ?) @ varsum-exp-rubl
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-rubl else ?) @ varsum-inc-rubl
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-base else ?) @ varsum-exp-base
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-base else ?) @ varsum-inc-base
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-rubl else ?) @ varvat-exp-rubl
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-rubl else ?) @ varvat-inc-rubl
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-base else ?) @ varvat-exp-base
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-base else ?) @ varvat-inc-base
with frame {&frame-name}.
display t-doc.fact-base t-doc.fact-rubl with frame {&frame-name}.
display
  bf-expp_doc-line-sum.fact-qnty
  bf-expp_doc-line-sum.cost-sum-rubl
  bf-expp_doc-line-sum.cost-sum-base
  bf-incp_doc-line-sum.cost-sum-rubl
  bf-incp_doc-line-sum.cost-sum-base
  bf-expp_doc-line-sum.cost-vat-rubl
  bf-expp_doc-line-sum.cost-vat-base
  bf-incp_doc-line-sum.cost-vat-rubl
  bf-incp_doc-line-sum.cost-vat-base
  bf-expp_doc-line-sum.cost-slt-rubl
  bf-expp_doc-line-sum.cost-slt-base
  bf-incp_doc-line-sum.cost-slt-rubl
  bf-incp_doc-line-sum.cost-slt-base
  bf-expp_doc-line-sum.cost-road-tax-rubl
  bf-expp_doc-line-sum.cost-road-tax-base
  bf-incp_doc-line-sum.cost-road-tax-rubl
  bf-incp_doc-line-sum.cost-road-tax-base
  bf-expp_doc-line-sum.cost-transport-rubl + bf-expp_doc-line-sum.cost-other-rubl @ varto-exp-rubl
  bf-expp_doc-line-sum.cost-transport-base + bf-expp_doc-line-sum.cost-other-base @ varto-exp-base
  bf-incp_doc-line-sum.cost-transport-rubl + bf-incp_doc-line-sum.cost-other-rubl @ varto-inc-rubl
  bf-incp_doc-line-sum.cost-transport-base + bf-incp_doc-line-sum.cost-other-base @ varto-inc-base
  with browse {&browse-name}.
display bf-caus_parts.price-rubl bf-caus_parts.price-base bf-caus_parts.vat-pc bf-caus_parts.slt-pc
        bf-caus_parts.road-tax-rubl bf-caus_parts.road-tax-base  bf-caus_parts.transport-rubl bf-caus_parts.transport-base
        bf-caus_parts.other-rubl  bf-caus_parts.other-base    with browse {&browse-name-cp}.
end.

{ gbl/hot-key.i b-mark }

on choose of b-mark in frame {&frame-name} do:
 run mark-list in this-procedure.
end.

on choose of b-mark-op in frame {&frame-name} do:
 run mark-list-op in this-procedure.
end.

on choose of b-del in frame {&frame-name} do:
  define variable varrep-rec as recid no-undo.

  run local-del in this-procedure ( output varrep-rec ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении партий."  skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    return no-apply.
  end.
  run ui-on in this-procedure ( input "line":U ).
  apply "entry" to {&browse-name} in frame {&frame-name} .
  if varrep-rec <> ? then do:
    reposition {&browse-name} to recid varrep-rec no-error.
  end.
end.

on choose of b-lkp in frame {&frame-name}
do:
  run local-lockup in this-procedure.
end.

on choose of b-lkp-op in frame {&frame-name}
do:
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_goods    for ub.goods.
  define variable prt-rec as recid no-undo.
  if not available bf-orig_parts then do:
    message "Неправильно выбрана оригинальная партия." view-as alert-box information.
    return no-apply.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = bf-orig_parts.out-code  and
                              bf_doc-line.artic     = bf-orig_parts.artic     and
                              bf_doc-line.prod-type = bf-orig_parts.prod-type and
                              bf_doc-line.prod-code = bf-orig_parts.prod-code no-lock.

  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  assign
    prt-rec   = recid( bf-orig_parts )
    .
  run str/parts-f.w
    (input        parparentproc        /* parparentproc */
    ,input        ?                    /* h-call-prog   */
    ,input        {&lookup}            /* p-mode        */
    ,input        bf_doc-line.doc-code /* p-doc-code    */
    ,input        bf_goods.gds-code    /* p-gds-code    */
    ,input        0                    /* p-pl-code     */
    ,input-output prt-rec              /* p-parts-recid */
    ).
end.

on choose of b-lkp-cp in frame {&frame-name}
do:
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_goods    for ub.goods.
  define variable prt-rec as recid no-undo.
  if not available bf-caus_parts then do:
    message "Неправильно выбрана порожденная партия." view-as alert-box information.
    return no-apply.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = bf-caus_parts.out-code  and
                              bf_doc-line.artic     = bf-caus_parts.artic     and
                              bf_doc-line.prod-type = bf-caus_parts.prod-type and
                              bf_doc-line.prod-code = bf-caus_parts.prod-code no-lock.

  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  assign
    prt-rec   = recid( bf-caus_parts )
    .
  run str/parts-f.w
    (input        parparentproc        /* parparentproc */
    ,input        ?                    /* h-call-prog   */
    ,input        {&lookup}            /* p-mode        */
    ,input        bf_doc-line.doc-code /* p-doc-code    */
    ,input        bf_goods.gds-code    /* p-gds-code    */
    ,input        0                    /* p-pl-code     */
    ,input-output prt-rec              /* p-parts-recid */
    ).
end.

on value-changed of browse {&browse-name} do:
 {&open-query-br-op}.
 {&open-query-br-cp}.
end.

on value-changed of browse {&browse-name-op} do:
  {&open-query-br-cp}.
end.

on entry of t-doc.cli-code, r-clients in frame {&frame-name} do:
  if t-doc.cli-code <> ? then do:
    assign pardoc-mode = {&add-def}.
    run UI-on in this-procedure ( input "enable" ).
  end.
end.

on choose of r-clients in frame {&frame-name}
do:

  define buffer bf_clients for ub.clients.

  run ref/cli-all.w (  input parparentproc
                ,  input "b-sel"
                ,  input ?
                ,  input ?
                ,  input ?
                ,  input ?
                ,  input ?
                ,  input ?
                , output ref-list ) .
  if ref-list <> "" then do:
    assign
      ref-rec = integer (ref-list).
    find first bf_clients where recid( bf_clients ) = ref-rec no-lock.
    display bf_clients.obj-code @ t-doc.cli-code
        bf_clients.obj-name @ clients.obj-name
        bf_clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
  end.
  run check-cli in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.
end.

on mouse-select-dblclick, return of t-doc.cli-code, t-doc.cli-type
  in frame {&frame-name} /* Контрагент */
do:
  run choose-cli in this-procedure no-error.
  if error-status :error then do:
    display ? @ t-doc.cli-type ? @ t-doc.cli-code with frame {&frame-name}.
  end.
  return no-apply.
end.

on leave of t-doc.reason-code in frame {&frame-name} do:
  run check-reason in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on return of t-doc.reason-code in frame {&frame-name} do:
  run check-reason in this-procedure no-error .
  if error-status :error then do: return no-apply. end.
end.

on choose of r-reas in frame {&frame-name} do:
  run select-reason in this-procedure.
end.

/* ***************************  main block  *************************** */

if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.

on window-close of frame {&frame-name} apply "end-error":u to self.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=br }

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-op :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-cp :handle
  ) .
run diasize_init in this-procedure .


/* зацикливание формы */
assign
  parnext-prev = yes.

n-p:
do while parnext-prev :
  assign
    parext-doc-mode =
      ( if num-entries( pardoc-mode, '{&delim-flt}':U ) > 1 then entry( 2, pardoc-mode, '{&delim-flt}':U ) else '':U )
    pardoc-mode     = entry( 1, pardoc-mode, '{&delim-flt}':U )
  .
  {&check_trdcalib}

  main-block:
  do on error undo main-block, leave main-block :
    define variable varroad-tax-label as character no-undo.
    run tax-name in this-procedure ( input {&road-tax}, output varroad-tax-label ) no-error.
    if error-status :error then do:
      assign
        parnext-prev = no.
      return error.
    end.
    assign
      bf-expp_doc-line-sum.cost-road-tax-rubl:label in browse {&browse-name} =  "Расход <" + varroad-tax-label + "> ({&abbr_rub})"
      bf-expp_doc-line-sum.cost-road-tax-base:label in browse {&browse-name} =  "Расход <" + varroad-tax-label + "> (вал)"
      bf-incp_doc-line-sum.cost-road-tax-rubl:label in browse {&browse-name} =  "Приход <" + varroad-tax-label + "> ({&abbr_rub})"
      bf-incp_doc-line-sum.cost-road-tax-base:label in browse {&browse-name} =  "Приход <" + varroad-tax-label + "> (вал)"
    .
    assign
      bf-orig_parts.road-tax-rubl:label in browse {&browse-name-op} = varroad-tax-label + "({&abbr_rub})"
      bf-orig_parts.road-tax-base:label in browse {&browse-name-op} = varroad-tax-label + "(вал)"
      bf-caus_parts.road-tax-rubl:label in browse {&browse-name-cp} = varroad-tax-label + "({&abbr_rub})"
      bf-caus_parts.road-tax-base:label in browse {&browse-name-cp} = varroad-tax-label + "(вал)"
    .

     run mode-on in this-procedure no-error.
     if error-status :error then do:
       assign
         parnext-prev = no.
       return error.
     end.
     run ui-on in this-procedure ( input "enable":U ) no-error.
     if error-status:error then do:
       assign
         parnext-prev = no.
       return error.
     end.
     find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
     if pardoc-mode = {&lookup} then do:
       wait-for go of frame {&frame-name} focus b-lkp.
     end.
     else do:
       if pardoc-mode = {&add-def} then do:
         wait-for go of frame {&frame-name} focus t-doc.cli-code.
       end.
       else do:
         wait-for go of frame {&frame-name} focus b-add.
       end.
     end.
  end.
end. /* do while */
run disable_ui in this-procedure.

/* **********************  internal procedures  *********************** */

procedure disable_ui :
  hide frame {&frame-name}.
end procedure.

procedure ui-on :
  define input parameter fnc as character no-undo.

  define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.

  do on error undo, return error return-value :
    for each tt-del-list-op on error undo, return error return-value :
      delete tt-del-list-op.
    end.
    for each tt-del-list on error undo, return error return-value :
      delete tt-del-list.
    end.
    if fnc = "enable":U then do:
      assign
        {&sort-clmn_5-br}:read-only    in browse {&browse-name}    = yes
        {&sort-clmn_4-br-op}:read-only in browse {&browse-name-op} = yes
        {&sort-clmn_2-br-cp}:read-only in browse {&browse-name-cp} = yes.
      disable all with frame {&frame-name}.
      enable b-exit b-lkp b-lkp-op b-lkp-cp b-help
             {&browse-name} {&browse-name-op} {&browse-name-cp}
             b-arch b-cnt b-history b-notes
      with frame {&frame-name}.
      if pardoc-mode <> {&lookup} or pardoc-mode = {&lookup} and parext-doc-mode = "reason-code" then do:
        enable r-reas t-doc.reason-code with frame {&frame-name}.
      end.
      case pardoc-mode :
        when {&lookup} then do:
          enable b-prev b-next with frame {&frame-name}.
        end.
        when {&add-def} then do:
          enable t-doc.cli-code t-doc.cli-type r-clients with frame {&frame-name}.
        end.
        otherwise do:
          enable b-add b-chg b-chgvat b-del b-mark b-file
                 b-mark-op
                 b-chg-cp
                 t-doc.wrkr t-doc.agnt t-doc.boss
                 r-wrkr r-agnt r-boss
          with frame {&frame-name}.
          { gbl/objat.i
            t-doc.obj-type
            t-doc.obj-code
            "'shift-on=request'"
            varlog
            no-error
          }
          if error-status :error then do:
            message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запуске процедуры objat" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
            return error.
          end.
          if not varlog then do:
           hide t-doc.shift-date t-doc.shift-num t-doc.shift-name /*r-sht*/ in frame {&frame-name}.
          end.
        end. /* update */
      end case. /* pardoc-mode */
    end. /* fnc = "enable" */
    find first bf-expp_trn-doc-sum no-lock where
               bf-expp_trn-doc-sum.doc-code = t-doc.doc-code       and
               bf-expp_trn-doc-sum.sum-type = {&sum-expense-parts} no-error.
    find first bf-incp_trn-doc-sum no-lock where
               bf-incp_trn-doc-sum.doc-code = t-doc.doc-code       and
               bf-incp_trn-doc-sum.sum-type = {&sum-income-parts}  no-error.
    display
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-rubl else ? ) @ varsum-exp-rubl
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-rubl else ? ) @ varsum-inc-rubl
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-base else ? ) @ varsum-exp-base
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-base else ? ) @ varsum-inc-base
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-rubl else ? ) @ varvat-exp-rubl
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-rubl else ? ) @ varvat-inc-rubl
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-base else ? ) @ varvat-exp-base
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-base else ? ) @ varvat-inc-base
    with frame {&frame-name}.

    display t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name
            t-doc.fact-rubl
            t-doc.fact-base
            t-doc.cli-type t-doc.cli-code
            varcntr-prn-code
            varcntr-name
    with frame {&frame-name}.
    find first clients where
               clients.obj-type = t-doc.cli-type and
               clients.obj-code = t-doc.cli-code no-error.
    if available clients then do:
      display clients.obj-name with frame {&frame-name}.
    end.

    find ub.trn-reason no-lock where
         ub.trn-reason.reason-code = t-doc.reason-code no-error.
    assign
      rsn-name = ( if available ub.trn-reason then ub.trn-reason.reason-name else "":U )
    .
    display t-doc.reason-code rsn-name with frame {&FRAME-NAME}.

    assign
      frame {&frame-name} :title = t-doc.obj-type + " " + string( t-doc.obj-code, ">>>>9":U ) + "  : КОРРЕКЦИЯ " +
      ( if t-doc.ext-doc-type = {&TDEDT_Corr_ACC_Price}   then "УЧЕТНЫХ ЦЕН "         else
      ( if t-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} then "ОТРИЦАТЕЛЬНЫХ ПАРТИЙ" else "ТИПА ПРИОБРЕТЕНИЯ" ) ) +
      t-doc.status_ + " " + string( t-doc.flag_, "+/-":U ) + " № " + t-doc.doc-code + "   - ".
    assign frame {&frame-name} :title = frame {&frame-name} :title +
      ( if parext-doc-mode = ""            then title-mode( pardoc-mode ) else ( caps( '{&bef-fact-edit}':U ) +
      ( if parext-doc-mode = "reason-code" then " кода основания"         else "":U ) ) ).

    display t-doc.wrkr t-doc.agnt t-doc.boss with frame {&frame-name}.

    { str/psn-chk.i wrkr on t-doc ref-rec }
    { str/psn-chk.i agnt on t-doc ref-rec }
    { str/psn-chk.i boss on t-doc ref-rec }

    run open-all-browse in this-procedure.
  end. /* do on error */
end procedure. /* ui-on */

procedure mark-list:
do on error undo, return error return-value :
if not available bf_doc-line then do:
  message "Неправильный выбор строки.".
  return no-apply.
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
{&browse-name}:refresh() in frame {&frame-name}.
varlog = {&browse-name}:select-next-row () in frame {&frame-name}.
apply "entry" to {&browse-name} in frame {&frame-name}.
end.
end procedure.

procedure mark-list-op:
do on error undo, return error return-value :
if not available bf-orig_parts then do:
  message "Неправильный выбор строки.".
  return no-apply.
end.
find first tt-del-list-op where tt-del-list-op.rec-id = recid( bf-orig_parts ) no-error.
if available tt-del-list-op then do:
  delete tt-del-list-op.
end.
else do:
  create tt-del-list-op.
  assign
    tt-del-list-op.rec-id = recid( bf-orig_parts ).
end.
{&browse-name-op}:refresh() in frame {&frame-name}.
varlog = {&browse-name-op}:select-next-row () in frame {&frame-name}.
apply "entry" to {&browse-name-op} in frame {&frame-name}.
end.
end procedure.

procedure local-del:
define output parameter parrep-rec as recid no-undo.
define variable vartemp-rec as recid no-undo.
define buffer bf-del_doc-line   for ub.doc-line.
define buffer bf-del-orig_parts for ub.parts.
do on error undo, return error return-value :
find first tt-del-list no-error.
if not available tt-del-list then do:
  /* удаление 1 строки */
  if not available bf_doc-line then do:
    message "Неправильный выбор строки.".
    return error.
  end.
  assign
    varlog = no.
  message "Удалить строку из документа? Вы уверены?"
          view-as alert-box question buttons ok-cancel update varlog.
  if not varlog then return error.
  assign
    vartemp-rec =  recid( bf_doc-line ).
  create tt-del-list.
    assign
    tt-del-list.rec-id = recid( bf_doc-line ).
  get next {&browse-name}.
  if available bf_doc-line then do:
    assign
      parrep-rec = recid( bf_doc-line ).
  end.
  else do:
    reposition {&browse-name} to recid vartemp-rec no-error.
    get prev {&browse-name}.
    assign
      parrep-rec = recid( bf_doc-line ).
  end.
end.
else do:
  /* удаление отмеченных строк */
  assign
    varlog = no.
  message "УДАЛИТЬ ВСЕ ОТМЕЧЕННЫЕ строки документа? Вы уверены ?"
  view-as alert-box question buttons ok-cancel update varlog.
  if not varlog then do:
    return error.
  end.
  assign
    parrep-rec = ?.
end.
for each tt-del-list on error undo, return error return-value :
  find first bf-del_doc-line where recid( bf-del_doc-line ) = tt-del-list.rec-id exclusive-lock no-error.
  if not available bf-del_doc-line then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении линии. Не найдена линия для удаления." skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run local-recalc in this-procedure ( input "old":U,
                                       input recid( bf-del_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run trg/rsrv-del.p ( input bf-del_doc-line.doc-code,
                   input bf-del_doc-line.artic,
                   input bf-del_doc-line.prod-type,
                   input bf-del_doc-line.prod-code ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip "Ошибка при разрезервировании по линии документа" skip
      return-value skip trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run local-recalc in this-procedure ( input "delete":U,
                                       input recid( bf-del_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run local-delete in this-procedure ( input recid( bf-del_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении строки документа." skip
      "Товар " bf-del_doc-line.artic " " bf-del_doc-line.prod-type " " bf-del_doc-line.prod-code skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
end.
end. /* do on error */
end procedure.

define temp-table tt-doc-line no-undo like ub.doc-line.

procedure local-check-gds:
define input parameter parrec-gds as recid no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_parts for ub.parts.
define variable l-inv-on as logical no-undo .
find first bf_goods where recid( bf_goods ) = parrec-gds no-lock.
  { gbl/gdsobjat.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    "'inv-on=request'"
    l-inv-on
    no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка получения признака товара на объекте" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  if l-inv-on then do:
    assign
      varlog-err = yes.
    put stream str-err unformatted "Артикул : " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " - товар в инвентаризации. Операция невозможна." skip.
    return error.
  end.
  for each tt-doc-line :
    delete tt-doc-line.
  end.
  create tt-doc-line.
  assign
    tt-doc-line.doc-code  = t-doc.doc-code
    tt-doc-line.obj-type  = t-doc.obj-type
    tt-doc-line.obj-code  = t-doc.obj-code
    tt-doc-line.artic     = bf_goods.artic
    tt-doc-line.prod-type = bf_goods.prod-type
    tt-doc-line.prod-code = bf_goods.prod-code.
  bl-inv-on:
  for { str/invchkrs.i t-doc.doc-code bf_parts tt-doc-line } on error undo bl-inv-on, return error :
    assign
      varlog-err = yes.
    put stream str-err unformatted "Включить инвентаризацию нельзя - на товарах есть резервы. Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " Документ " bf_parts.out-code skip.
    undo bl-inv-on, return error.
  end.
end procedure.

procedure chk-upd-date:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
if input frame {&frame-name} t-doc.fact-date > v-today then do:
   message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
   display t-doc.fact-date with frame {&frame-name}.
   return error.
end.
if input frame {&frame-name} t-doc.fact-date < v-today - 7 then do:
   varlog = yes.
   message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
           "Отказаться от заведения даты?" view-as alert-box question
           buttons yes-no update varlog.
   if varlog then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
end.
if input frame {&frame-name} t-doc.fact-date <> t-doc.fact-date then do:
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
      display t-doc.fact-date with frame {&frame-name}.
      return error.
    end.


   assign varlog = no.
   case t-doc.doc-type
   :
     when {&income}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_add-back-date':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
     end.
     when {&expense}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_add-back-date':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
     end.
     when {&write-off}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_write-off_add-back-date':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
     end.
     when {&return}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_return_add-back-date':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
     end.
     when {&inventory}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_add-back-date':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
     end.
     otherwise do:
       message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" skip
         "Тип документа" t-doc.doc-type skip
         "Код документа" t-doc.doc-code skip
         view-as alert-box error .
       undo, return error return-value .
     end.
   end case .

   if varlog = no then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
   varlog = no.
   message "Вы хотите изменить фактическую дату?" skip
           "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
   view-as alert-box question buttons yes-no update varlog.
   if not varlog then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
   assign t-doc.fact-time = (24 * 60 * 60).
end.
end procedure.

procedure mode-on :
define buffer bf_clients for ub.clients.
define buffer bf_store   for ub.store.
define variable varrecid as recid no-undo.
define variable varactive-obj as logical no-undo.
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
  find first t-doc where recid(t-doc) = pardoc-rec no-lock.
  if available t-doc then do:
    if pardoc-mode = {&update} then do:
      if t-doc.status_ <> {&wayb} then do:
        message "Документ закрыт." skip (1)
                "Редактирование невозможно."
                view-as alert-box error.
        return error.
      end.
      else do:
        find first bf_clients where bf_clients.obj-type = v-cntxt-obj-type and
                                    bf_clients.obj-code = v-cntxt-obj-code no-lock.
        if v-cntxt-db-num <> bf_clients.db-num then do:
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
end procedure.

procedure add-doc:
define output parameter parrecid as recid no-undo.
define variable vardoc-code   like ub.trn-doc.doc-code    no-undo.
define variable v-today       as date                     no-undo.
do on error undo, return error :
  if not can-find (pay-type where pay-type.obj-code = v-cntxp-inv-pay no-lock) then do:
    message "Не задан код оплаты для инвентаризации в настройках по текущему объекту.".
    return error.
  end.
  run doc-code in this-procedure
  (input  "main",
   input  v-cntxt-obj-type,
   input  v-cntxt-obj-code,
   input  ?,
   output vardoc-code ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при генерации номера документа." skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
    undo, return error .
  end.
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
  { str/crtrndoc.i
    ?
    ?
    1
    1
    ?
    ?
    ?
    v-cntxt-db-num
    v-cntxt-userid
    "' '"
    vardoc-code
    v-today
    {&inventory}
    no
    v-cntxt-host-code-obj
    no
    v-cntxt-obj-code
    v-cntxt-obj-type
    no
    v-cntxp-inv-pay
    "'@  '"
    no
    "{&without-slt}"
    {&wayb}
    "{&inc-vat}"
    {&TDEDT_Corr_Acc_Price}
    ?
    no-error
    }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа процедурой crtrndoc" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  find t-doc where t-doc.doc-code = vardoc-code.
  assign
    pardoc-rec = recid( t-doc ).
  assign parrecid = recid( t-doc ).
end.
end procedure.

procedure open-all-browse :
  {&open-query-br}.
  if line-rec <> ? then do:
    reposition {&browse-name} to recid line-rec no-error.
  end.
  {&open-query-br-op}.
  {&open-query-br-cp}.
end procedure.

procedure local-add:
define variable varartic   like ub.doc-line.artic no-undo.
define variable recid-line as   recid             no-undo.
define variable varmode    as   character         no-undo.
define variable varhvrdtax as   logical           no-undo.
define variable varlog     as   logical           no-undo.
define variable varis-ok   as   logical           no-undo.
define buffer bf_goods      for ub.goods.
define buffer bf-free_parts for ub.parts.
define buffer bf_contract   for ub.contract.
define variable varnum as integer no-undo.
define variable varstay-lns-cnt as integer no-undo.
define variable varnotes as character no-undo.
define variable varlns-cnt as integer no-undo.
do on error undo, return error return-value :
run str/chs-gds.w
  ( input parparentproc,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    input "":u,
    input t-doc.status_,
    input "Строка накладной № " + t-doc.doc-code,
    input ?, /*режим вызова справочника товаров*/
    input ?,
    input ?,
    input v-cntxt-host-code-obj,
    input parext-doc-type,
    input-output varartic,
    output varnotes
    ) .
if varnotes = '' then do: return error. end.
varlns-cnt = 1.
cycle:
do while varlns-cnt <= num-entries (varnotes) on error undo, return error return-value :
gds:
do transaction on error undo, leave :
  find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
  assign
    varlns-cnt = varlns-cnt + 1.
  if hvrdtax ( recid( bf_goods ) ) = no then do:
    assign
      varhvrdtax = no.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = t-doc.doc-code     and
                               bf_doc-line.artic     = bf_goods.artic     and
                               bf_doc-line.prod-type = bf_goods.prod-type and
                               bf_doc-line.prod-code = bf_goods.prod-code no-error.
  if available bf_doc-line then do:
    message "Товар " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code " " bf_goods.gds-name " уже есть в данной накладной." skip
            "Хотите отредактировать его?" view-as alert-box question buttons yes-no update varlog.
    if not varlog then do:
      undo, leave gds.
    end.
    run gbl/d-askw.w
    (input "Смена цен"
    ,input "Товар " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + substring(bf_goods.gds-name,1,30)
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
    ,input "Все|Новые|Отменить" /* список названий кнопок  */
    ,input "Всем выбранным партиям из свободной зоны|" /* список описаний кнопок */
         + "Новым выбранным партиям из свободной зоны|"
         + "Прекратить обработку товаров"
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 3 /* значение возвращаемое при нажатии escape */
    ,output varnum /* выбор пользователя */
    ).
    case varnum :
      when 1 then do:
        assign
          varmode = "chg_parts":u.
      end.
      when 2 then do:
        assign
          varmode = "chg_new_parts":u.
      end.
      when 3 then do:
        assign
          varlog-err = yes.
        assign
          varstay-lns-cnt = varlns-cnt.
        do while varstay-lns-cnt <= num-entries (varnotes) on error undo, return error return-value :
          find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
          assign
            varstay-lns-cnt = varstay-lns-cnt + 1.
          put stream str-err unformatted "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " ,из списка выбранных, не обрабатывался в связи с нажатием кнопки 'Отмена'." skip.
        end.
        undo gds, leave cycle.
      end.
    end case.
  end.
  else do:
    { str/chkgdsd.i recid(t-doc) recid(bf_goods) no-error }
    if error-status :error then do:
      assign
        varlog-err = yes.
      put stream str-err unformatted return-value.
      undo, leave gds.
    end.

    find first bf-free_parts where bf-free_parts.host-code     = t-doc.host-code       and
                                   bf-free_parts.supp-type     = t-doc.cli-type        and
                                   bf-free_parts.supp-code     = t-doc.cli-code        and
                                   bf-free_parts.status_       = no                    and
                                   bf-free_parts.obj-type      = t-doc.obj-type        and
                                   bf-free_parts.obj-code      = t-doc.obj-code        and
                                   bf-free_parts.rsrv-free     = yes                   and
                                   bf-free_parts.out-code      = {&free-code}          and
                                   bf-free_parts.prod-type     = bf_goods.prod-type    and
                                   bf-free_parts.prod-code     = bf_goods.prod-code    and
                                   bf-free_parts.artic         = bf_goods.artic        and
                                   bf-free_parts.contract-code = t-doc.contract-code   no-lock no-error.
    if not available bf-free_parts then do:
      if t-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code     and
                                     bf_contract.contract-code = t-doc.contract-code no-lock.
      end.
      assign
        varlog-err = yes.
      put stream str-err unformatted
              "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name "."
              "Объект: " t-doc.obj-type " " t-doc.obj-code
              "Поставщик " t-doc.cli-type " " t-doc.cli-code " " t-doc.cli-name " "
              (if available bf_contract then "Договор " + bf_contract.contract-prn-code else "")
              "Нет товара от поставщика в свободной зоне на объекте."
              "Пропускаем." skip.
      undo, leave gds.
    end.
    run gbl/d-askw.w
    (input "Смена цен"
    ,input "Товар " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + substring(bf_goods.gds-name,1,30)
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
    ,input "Все|Выбор|Отменить" /* список названий кнопок  */
    ,input "Всем партиям свободной зоны по поставщику|" /* список описаний кнопок */
         + "Выбранным партиям из свободной зоны|"
         + "Прекратить обработку товаров"
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 3 /* значение возвращаемое при нажатии escape */
    ,output varnum /* выбор пользователя */
    ).
    case varnum :
      when 1 then do:
        assign
          varmode = "all_parts":u.
      end.
      when 2 then do:
        assign
          varmode = "chg_parts":u.
      end.
      when 3 then do:
        assign
          varlog-err = yes.
        assign
          varstay-lns-cnt = varlns-cnt.
        do while varstay-lns-cnt <= num-entries (varnotes) on error undo, return error return-value :
          find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
          assign
            varstay-lns-cnt = varstay-lns-cnt + 1.
          put stream str-err unformatted "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " ,из списка выбранных, не обрабатывался в связи с нажатием кнопки 'Отмена'." skip.
        end.
        undo gds, leave cycle.
      end.
    end case.
    { str/addcorln.i recid(t-doc) recid(bf_goods) recid-line no-error }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при добавлении товара " skip
        bf_goods.artic skip
        bf_goods.prod-type skip
        bf_goods.prod-code skip
        " в документ."
        return-value skip
        trim( error-status :get-message( 1 ) )
        view-as alert-box error.
      undo, leave gds.
    end.
    find first bf_doc-line where recid( bf_doc-line ) = recid-line.
  end.
  assign
    bf_doc-line.prt-OK = ?.
  run local-recalc in this-procedure ( input "old":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim(error-status :get-message(1))
    view-as alert-box error.
    undo, leave gds.
  end.
  find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
  run update-line in this-procedure (   input varmode
                                      , input recid( bf_doc-line )
                                      , input bf_sysconf.cash-pay
                                      , input ?
                                      , input ?
                                      , input ?
                                      , input ?
                                      )  no-error.
  if error-status :error then do:
    if return-value <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара " skip
        bf_doc-line.artic skip
        bf_doc-line.prod-type skip
        bf_doc-line.prod-code skip
        return-value skip
        trim(error-status :get-message(1))
        view-as alert-box error.
    end.
    undo, leave gds.
  end.
  if available bf_doc-line then do:
    run local-recalc in this-procedure ( input "update":U,
                                         input recid( bf_doc-line ) ) no-error.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
      undo, leave gds.
    end.
  end.
end.
end.
run ui-on in this-procedure ( input "line" ).
end.
end procedure.

procedure add-doc-inv-line:
define input parameter parrec-goods as recid no-undo.
define output parameter parrecid as recid no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc      no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc      no-undo.
define variable v-have-slt-pc   as logical                no-undo.
define variable v-host-code     like ub.sysconf.host-code    no-undo.
define variable varn-c          like ub.gds-prt.node-code no-undo.
define variable l-inv-on        as logical                no-undo.
define buffer bf_goods    for ub.goods.
define buffer bf_doc-line for ub.doc-line.
do on error undo, return error return-value :
find first bf_goods where recid( bf_goods ) = parrec-goods no-lock.
if bf_goods.gds-type = {&gds-office} then do:
  message
    vss-workfile vss-revision vss-description skip
    "Услуги нельзя добавлять в данный документ" skip
    return-value skip
    trim( error-status :get-message( 1 ) )
    view-as alert-box error.
  undo, return error .
end.
find bf_doc-line where bf_doc-line.artic     = bf_goods.artic
                   and bf_doc-line.prod-type = bf_goods.prod-type
                   and bf_doc-line.prod-code = bf_goods.prod-code
                   and bf_doc-line.doc-code  = t-doc.doc-code no-error.
if not available bf_doc-line then do:
  { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
  { gbl/pftxvalg.i bf_goods.gds-code {&vat-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
  find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
  { str/st-sltpc.i
    recid(bf_goods)
    recid(t-doc)
    bf_sysconf.cash-pay
    v-slt-pc
  }
  define variable v-cons-vat-pc like ub.sysconf.cons-vat-pc no-undo.
  { gbl/hostcvat.i t-doc.host-code v-cons-vat-pc }
  if v-vat-pc = ? then do:
   return error substitute ("Не установлен консигнационный НДС по фирме &1.", t-doc.host-code).
  end.
  { str/crdoclin.i
    t-doc.doc-code
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    t-doc.obj-type
    t-doc.obj-code
    t-doc.status_
    t-doc.ext-doc-type
    bf_goods.prt-root
    v-vat-pc
    v-slt-pc
    v-cons-vat-pc
  }
  find first bf_doc-line where bf_doc-line.doc-code  = t-doc.doc-code     and
                               bf_doc-line.artic     = bf_goods.artic     and
                               bf_doc-line.prod-type = bf_goods.prod-type and
                               bf_doc-line.prod-code = bf_goods.prod-code exclusive-lock.

  assign
    bf_doc-line.price-base     = 0
    bf_doc-line.price-rubl     = 0
    bf_doc-line.road-tax       = 0
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0
    .
   { gbl/termnode.i bf_goods.prt-root varn-c }
   { str/crgdsdtl.i
     t-doc.obj-code
     t-doc.obj-type
     t-doc.doc-code
     bf_goods.artic
     bf_goods.prod-code
     bf_goods.prod-type
     varn-c
     yes
     no-error
   }
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при создании терминального признака по товару:" skip
       bf_goods.artic skip
       bf_goods.prod-type skip
       bf_goods.prod-code skip
       return-value skip
       trim(error-status :get-message(1))
       view-as alert-box error.
     undo, return error .
   end.
   /*Выставляем флаг - товар в инвентаризации*/
   { gbl/gdsobjat.i
     bf_doc-line.obj-type
     bf_doc-line.obj-code
     bf_doc-line.artic
     bf_doc-line.prod-type
     bf_doc-line.prod-code
     "'inv-on=true'"
     l-inv-on
     no-error
   }
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка установки атрибута товара на объекте" skip
       "Документ" bf_doc-line.doc-code skip
       "Объект" bf_doc-line.obj-type bf_doc-line.obj-code skip
       "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
       "l-new-inv-on" l-inv-on skip
       view-as alert-box error .
     undo, return error .
   end.
end.
assign parrecid = recid( bf_doc-line ).
end.
end procedure.

procedure update-line :
define input parameter parmode         as   character          no-undo.
define input parameter parrec-line     as   recid              no-undo.
define input parameter parcash-pay     as   integer            no-undo.
define input parameter paroldvat-pc    like ub.doc-line.vat-pc no-undo.
define input parameter parvat-pc       like ub.doc-line.vat-pc no-undo.
define input parameter parpurch-list   as   character          no-undo.
define input parameter parchange-price as   logical            no-undo.
define buffer bf_doc-line    for ub.doc-line.
define buffer bf_gds-dtl     for ub.gds-dtl.
define buffer bf_goods       for ub.goods.
define buffer bf_parts       for ub.parts.
define buffer bf-free_parts  for ub.parts.
define buffer bf-orig_parts  for ub.parts.
define buffer bf-caus_parts  for ub.parts.
define buffer bf_parts_root  for ub.parts-root.
define buffer bf2_parts-root for ub.parts-root.
define buffer bf-hv_parts    for ub.parts.
define buffer bf_contract    for ub.contract.
define variable parreccaus-parts     as   recid                  no-undo.
define variable varn-c               like ub.gds-prt.node-code   no-undo.
define variable varfree-qnty         like ub.parts.fact-qnty     no-undo.
define variable vartext              as   character              no-undo.
define variable varis-rsrv           as   logical                no-undo.
define variable l-goods-twounit      as   logical                no-undo.
define variable vargds-dtlrec        as   recid                  no-undo.
define variable varhvrdtax           as   logical                no-undo.
define variable varis-ok             as   logical                no-undo.
define variable varprc-chg-upd-parts as   logical                no-undo.
define variable varno-abs-tax-rubl   like ub.doc-line.price-rubl no-undo.
define variable varslt-rubl          like ub.doc-line.price-rubl no-undo.
define variable varvat-rubl          like ub.doc-line.price-rubl no-undo.
define variable varno-tax-rubl       like ub.doc-line.price-rubl no-undo.
define variable varexch-code         like ub.trn-doc.exch-code   no-undo.
define variable varexch-rate         like ub.trn-doc.exch-rate   no-undo.
define variable varexch-scale        like ub.trn-doc.exch-scale  no-undo.
define variable prt-rec as recid no-undo.
&scop st-price if parchange-price = yes then do: ~
                 assign                          ~
                   varno-abs-tax-rubl = (bf-orig_parts.price-rubl - bf-orig_parts.road-tax-rubl - bf-orig_parts.other-rubl - bf-orig_parts.transport-rubl) ~
                   varslt-rubl        = varno-abs-tax-rubl * bf-orig_parts.slt-pc / (100 + bf-orig_parts.slt-pc)             ~
                   varvat-rubl        = (varno-abs-tax-rubl - varslt-rubl) * bf-orig_parts.vat-pc / (100 + bf-orig_parts.vat-pc) ~
                   varno-tax-rubl     = varno-abs-tax-rubl - varslt-rubl - varvat-rubl ~
                 . ~
                 assign ~
                   varprice-rubl      = varno-tax-rubl + ~
                                        varno-tax-rubl * parvat-pc / 100 + ~
                                        (varno-tax-rubl + varno-tax-rubl * parvat-pc / 100) * bf-orig_parts.slt-pc / 100 + ~
                                        bf-orig_parts.road-tax-rubl + ~
                                        bf-orig_parts.transport-rubl + ~
                                        bf-orig_parts.other-rubl ~
                   varprice-base      = varprice-rubl * bf-orig_parts.price-base / bf-orig_parts.price-rubl ~
                   varprice-cli       = varprice-rubl * bf-orig_parts.price-cli  / bf-orig_parts.price-cli. ~
               end. ~
               else do: ~
                 assign ~
                   varprice-base     = bf-orig_parts.price-base ~
                   varprice-rubl     = bf-orig_parts.price-rubl ~
                   varprice-cli      = bf-orig_parts.price-cli  ~
                 . ~
               end. ~
               assign ~
                 varvat-pc         = parvat-pc ~
                 varslt-pc         = bf-orig_parts.slt-pc ~
                 varroad-tax-base  = bf-orig_parts.road-tax-base  ~
                 varroad-tax-rubl  = bf-orig_parts.road-tax-rubl  ~
                 vartransport-base = bf-orig_parts.transport-base ~
                 vartransport-rubl = bf-orig_parts.transport-rubl ~
                 varother-base     = bf-orig_parts.other-base    ~
                 varother-rubl     = bf-orig_parts.other-rubl   ~
               .
do transaction on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line.
find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                          bf_goods.prod-type = bf_doc-line.prod-type and
                          bf_goods.prod-code = bf_doc-line.prod-code no-lock.
{ gbl/termnode.i bf_goods.prt-root varn-c }
assign
  varhvrdtax = hvrdtax ( recid( bf_goods ) ).
find first bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                            bf_gds-dtl.artic     = bf_doc-line.artic     and
                            bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                            bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                            bf_gds-dtl.prt-code  = varn-c .
assign
  vargds-dtlrec = recid( bf_gds-dtl ).
for each tt-cur-parts on error undo, return error return-value :
  delete tt-cur-parts.
end.
for each tt-new-parts on error undo, return error return-value :
  delete tt-new-parts.
end.
/*Заполняем временную таблицу по существующим партиям*/
for each bf_parts where bf_parts.out-code  =  t-doc.doc-code
                    and bf_parts.obj-type  =  t-doc.obj-type
                    and bf_parts.obj-code  =  t-doc.obj-code
                    and bf_parts.artic     =  bf_doc-line.artic
                    and bf_parts.prod-type =  bf_doc-line.prod-type
                    and bf_parts.prod-code =  bf_doc-line.prod-code
                    and bf_parts.in-code   <> t-doc.doc-code on error undo, return error return-value :
  create tt-cur-parts.
  buffer-copy bf_parts to tt-cur-parts.
end.
case parmode:
 when "chg_parts":u     or
 when "chg_new_parts":u then do:
   run str/parts-l.w
     (input parparentproc
     ,input t-doc.obj-type            /* v-obj-type   */
     ,input t-doc.obj-code            /* v-obj-code   */
     ,input bf_goods.gds-code         /* p-gds-code   */
     ,input bf_doc-line.doc-code      /* p-doc-code   */
     ,input {&update}                 /* p-edit-mode  */
     ,input {&parts-l_parts-document} /* p-r-parts    */
        + {&comma-char} + {&parts-l_parts-no-reserv}
        + {&comma-char} + {&parts-l_parts-no-diff-check}
     ,input {&parts-l_object-current} /* p-one-all    */
     ,input {&parts-l_call-document}  /* p-call-point */
     ,output prt-rec                  /* part-recid   */
     ) .

    for each tt-chs-parts on error undo, return error return-value :
      delete tt-chs-parts.
    end.
    doc-parts:
    for each bf_parts where bf_parts.out-code  =  t-doc.doc-code
                        and bf_parts.obj-type  =  t-doc.obj-type
                        and bf_parts.obj-code  =  t-doc.obj-code
                        and bf_parts.artic     =  bf_doc-line.artic
                        and bf_parts.prod-type =  bf_doc-line.prod-type
                        and bf_parts.prod-code =  bf_doc-line.prod-code
                        and bf_parts.in-code  <>  t-doc.doc-code         on error undo, return error return-value :
      if parmode = "chg_new_parts":u then do:
        find first tt-cur-parts where tt-cur-parts.obj-type  = bf_parts.obj-type  and
                                      tt-cur-parts.obj-code  = bf_parts.obj-code  and
                                      tt-cur-parts.artic     = bf_parts.artic     and
                                      tt-cur-parts.prod-type = bf_parts.prod-type and
                                      tt-cur-parts.prod-code = bf_parts.prod-code and
                                      tt-cur-parts.in-code   = bf_parts.in-code   and
                                      tt-cur-parts.out-code  = bf_parts.out-code  and
                                      tt-cur-parts.part-code = bf_parts.part-code no-error.
        if available tt-cur-parts                       and
           tt-cur-parts.fact-qnty <= bf_parts.fact-qnty then do:
          next doc-parts.
        end.
        create tt-chs-parts.
        buffer-copy bf_parts to tt-chs-parts.
        if available tt-cur-parts then do:
          assign
            tt-chs-parts.fact-qnty = - (bf_parts.fact-qnty - tt-cur-parts.fact-qnty).
        end.
        else do:
          assign
            tt-chs-parts.fact-qnty = - tt-chs-parts.fact-qnty.
        end.
      end.
      else do:
        create tt-chs-parts.
        buffer-copy bf_parts to tt-chs-parts.
        assign
          tt-chs-parts.fact-qnty = - tt-chs-parts.fact-qnty.
      end.
    end.
    find first tt-chs-parts no-error.
    if available tt-chs-parts then do:
      run st-exch-rate in this-procedure (output varexch-code,
                                          output varexch-rate,
                                          output varexch-scale,
                                          output varcli-base-rate,
                                          output varvat-type,
                                          output varslt-type).
      run str/pr-prt.w (
      input  "parts":u,
      input  bf_goods.gds-code,
      input  t-doc.cli-type,
      input  t-doc.cli-code,
      input  t-doc.obj-type,
      input  t-doc.obj-code,
      input  ?,
      input  ?,
      input  ?,
      input  t-doc.base-rate,
      input  t-doc.base-scale,
      input  varexch-code,
      input  varexch-rate,
      input  varexch-scale,
      input  ?,
      input  varhvrdtax,
      input  t-doc.contract-code,
      input  table tt-chs-parts,
      output varprice-base,
      output varsum-base,
      output varprice-rubl,
      output varsum-rubl,
      input-output varcli-base-rate,
      input-output varvat-type,
      input-output varslt-type,
      output varprice-cli,
      output varsum-cli,
      output varvat-pc,
      output varvat-base,
      output varsum-vat-base,
      output varvat-rubl,
      output varsum-vat-rubl,
      output varvat-cli,
      output varsum-vat-cli,
      output varslt-pc,
      output varslt-base,
      output varsum-slt-base,
      output varslt-rubl,
      output varsum-slt-rubl,
      output varslt-cli,
      output varsum-slt-cli,
      output varroad-tax-base,
      output varsum-road-tax-base,
      output varroad-tax-rubl,
      output varsum-road-tax-rubl,
      output varroad-tax-cli,
      output varsum-road-tax-cli,
      output vartransport-base,
      output varsum-transport-base,
      output vartransport-rubl,
      output varsum-transport-rubl,
      output varother-base,
      output varsum-other-base,
      output varother-rubl,
      output varsum-other-rubl,
      output varpurch-code,
      output varis-ok) no-error.
      if error-status :error then do:
        message
        "Ошибка при установке цен." skip
        return-value skip
        error-status :get-message( 1 )
        view-as alert-box error.
        undo, return error .
      end.
      if varis-ok <> yes then do:
        undo, return error .
      end.
      assign
        varprc-chg-upd-parts = yes.
    end.
 end.
 when "all_parts":u or
 when "chg_vat":u   then do:
  &scop for-each-free-parts  fp: for each bf-free_parts where bf-free_parts.host-code     = t-doc.host-code          and ~
                                                              bf-free_parts.supp-type     = t-doc.cli-type           and ~
                                                              bf-free_parts.supp-code     = t-doc.cli-code           and ~
                                                              bf-free_parts.status_       = no                       and ~
                                                              bf-free_parts.obj-type      = t-doc.obj-type           and ~
                                                              bf-free_parts.obj-code      = t-doc.obj-code           and ~
                                                              bf-free_parts.rsrv-free     = yes                      and ~
                                                              bf-free_parts.out-code      = {&free-code}             and ~
                                                              bf-free_parts.prod-type     = bf_doc-line.prod-type    and ~
                                                              bf-free_parts.prod-code     = bf_doc-line.prod-code    and ~
                                                              bf-free_parts.artic         = bf_doc-line.artic        and ~
                                                              bf-free_parts.contract-code = t-doc.contract-code      on error undo, return error return-value :
   for each tt-chs-parts on error undo, return error return-value :
     delete tt-chs-parts.
   end.
   {&for-each-free-parts}
     if parmode = "chg_vat":u then do:
       if lookup (string(bf-free_parts.purch-code), parpurch-list) = 0 then do:
         next fp.
       end.
       if bf-free_parts.vat-pc <> paroldvat-pc then do:
         next fp.
       end.
     end.
     create tt-chs-parts.
     buffer-copy bf-free_parts to tt-chs-parts.
   end.
   find first tt-chs-parts no-error.
   if available tt-chs-parts then do:
     run st-exch-rate in this-procedure
         (output varexch-code,
          output varexch-rate,
          output varexch-scale,
          output varcli-base-rate,
          output varvat-type,
          output varslt-type).
   end.
   if parmode <> "chg_vat":u then do:
     run str/pr-prt.w (
       input  "goods":u,
       input  bf_goods.gds-code,
       input  t-doc.cli-type,
       input  t-doc.cli-code,
       input  t-doc.obj-type,
       input  t-doc.obj-code,
       input  ?,
       input  ?,
       input  ?,
       input  t-doc.base-rate,
       input  t-doc.base-scale,
       input  varexch-code,
       input  varexch-rate,
       input  varexch-scale,
       input  ?,
       input  varhvrdtax,
       input  t-doc.contract-code,
       input  table tt-chs-parts,
       output varprice-base,
       output varsum-base,
       output varprice-rubl,
       output varsum-rubl,
       input-output varcli-base-rate,
       input-output varvat-type,
       input-output varslt-type,
       output varprice-cli,
       output varsum-cli,
       output varvat-pc,
       output varvat-base,
       output varsum-vat-base,
       output varvat-rubl,
       output varsum-vat-rubl,
       output varvat-cli,
       output varsum-vat-cli,
       output varslt-pc,
       output varslt-base,
       output varsum-slt-base,
       output varslt-rubl,
       output varsum-slt-rubl,
       output varslt-cli,
       output varsum-slt-cli,
       output varroad-tax-base,
       output varsum-road-tax-base,
       output varroad-tax-rubl,
       output varsum-road-tax-rubl,
       output varroad-tax-cli,
       output varsum-road-tax-cli,
       output vartransport-base,
       output varsum-transport-base,
       output vartransport-rubl,
       output varsum-transport-rubl,
       output varother-base,
       output varsum-other-base,
       output varother-rubl,
       output varsum-other-rubl,
       output varpurch-code,
       output varis-ok) no-error.
     if error-status :error then do:
       message
         "Ошибка при установке цен." skip
         return-value skip
         error-status :get-message( 1 )
         view-as alert-box error.
       undo, return error return-value.
     end.
     if varis-ok <> yes then do:
       undo, return error return-value.
     end.
   end.
   assign
     varfree-qnty = 0.
   {&for-each-free-parts}
     if parmode = "chg_vat":u then do:
       if lookup (string(bf-free_parts.purch-code), parpurch-list) = 0 then do:
         next fp.
       end.
       if bf-free_parts.vat-pc <> paroldvat-pc then do:
         next fp.
       end.
     end.
     { gbl/gdsat.i bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code "'twounit=request':u"  l-goods-twounit no-error }
     assign
       varfree-qnty = - bf-free_parts.fact-qnty.
     { gbl/part-prc.i
       bf-free_parts
       t-doc
       yes
       bf-free_parts.in-code
       bf-free_parts.part-code
       0
       l-goods-twounit
       "'':u"
       varfree-qnty
       "true"
       vartext
       varis-rsrv
       no-error
     }
     if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при проверке возможности резервирования партии" skip
         return-value skip
         trim(error-status :get-message(1))
         view-as alert-box error.
       undo, return error .
     end.
     if varis-rsrv <> yes then next.
     run trg/rsrv-dtl.p ( parparentproc,
                      {&rsrv-dtl_action_reserv}
                + "," + {&rsrv-dtl_rsrv-single-part}
                + "," + {&rsrv-dtl_rsrv-in-code}   + "=" + str-encode(bf-free_parts.in-code, "", ",=":u)
                + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(bf-free_parts.part-code, "", ",=":u)
                 , buffer bf_gds-dtl, input-output varfree-qnty,
                 input-output bf_doc-line.price-base, input-output bf_doc-line.price-rubl,-1, "") no-error.
     if error-status :error then do:
       message
         "Ошибка при резервировании свободной зоны." skip
         return-value skip
         trim(error-status :get-message(1))
         view-as alert-box error.
       undo, return error .
     end.
   end.
 end.
 otherwise do:
   message
     vss-workfile vss-revision vss-description skip
     "Неверный режим " parmode " вызова процедуры local-update в файле corparts.w." skip
    view-as alert-box error.
   undo, return error .
 end.
end.
for each bf_parts where bf_parts.out-code      =  t-doc.doc-code
                    and bf_parts.obj-type      =  t-doc.obj-type
                    and bf_parts.obj-code      =  t-doc.obj-code
                    and bf_parts.artic         =  bf_doc-line.artic
                    and bf_parts.prod-type     =  bf_doc-line.prod-type
                    and bf_parts.prod-code     =  bf_doc-line.prod-code
                    and bf_parts.contract-code =  t-doc.contract-code
                    and bf_parts.in-code       <> t-doc.doc-code
                    on error undo, return error return-value :
  create tt-new-parts.
  buffer-copy bf_parts to tt-new-parts.
end.
for each tt-new-parts on error undo, return error return-value :
  find first bf-orig_parts where bf-orig_parts.obj-type   = tt-new-parts.obj-type
                             and bf-orig_parts.obj-code   = tt-new-parts.obj-code
                             and bf-orig_parts.artic      = tt-new-parts.artic
                             and bf-orig_parts.prod-type  = tt-new-parts.prod-type
                             and bf-orig_parts.prod-code  = tt-new-parts.prod-code
                             and bf-orig_parts.in-code    = tt-new-parts.in-code
                             and bf-orig_parts.out-code   = tt-new-parts.out-code
                             and bf-orig_parts.part-code  = tt-new-parts.part-code .

  find first tt-cur-parts where tt-cur-parts.obj-type   = tt-new-parts.obj-type
                            and tt-cur-parts.obj-code   = tt-new-parts.obj-code
                            and tt-cur-parts.artic      = tt-new-parts.artic
                            and tt-cur-parts.prod-type  = tt-new-parts.prod-type
                            and tt-cur-parts.prod-code  = tt-new-parts.prod-code
                            and tt-cur-parts.in-code    = tt-new-parts.in-code
                            and tt-cur-parts.out-code   = tt-new-parts.out-code
                            and tt-cur-parts.part-code  = tt-new-parts.part-code no-error.
  /*новая партия*/
  if not available tt-cur-parts then do:
    if parmode = "chg_vat":u then do:
      {&st-price}
    end.
    run change-price in this-procedure (
        buffer bf-orig_parts,
        input  - tt-new-parts.fact-qnty,
        input  varexch-code,
        input  varcli-base-rate,
        input  varvat-type,
        input  varslt-type,
        input  varprice-cli,
        input  varprice-base,
        input  varprice-rubl,
        input  varvat-pc,
        input  varslt-pc,
        input  varroad-tax-base,
        input  varroad-tax-rubl,
        input  vartransport-base,
        input  vartransport-rubl,
        input  varother-base,
        input  varother-rubl,
        input  parcash-pay,
        input  t-doc.internal,
        input  t-doc.doc-type,
        input  parext-doc-type,
        input  yes,
        input  ?,
        input  varpurch-code,
        output parreccaus-parts ) no-error.
     if error-status :error then do:
       message
         "Ошибка при вызове процедуры копирования партии с кодом " bf-orig_parts.part-code skip
         "порожденную документом " bf-orig_parts.in-code skip
         "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
         return-value skip
         view-as alert-box error.
       undo, return error .
     end.
  end. /*новая партия*/
  /*не новая партия*/
  else do:
    /*изменилось количество*/
    if tt-new-parts.fact-qnty <> tt-cur-parts.fact-qnty then do:
      /*Так как эти партии имеют отрицательное количество, то знак наоборот*/
      /*Количество по партии увеличилось*/
      if tt-new-parts.fact-qnty < tt-cur-parts.fact-qnty then do:
        if parmode = "chg_vat":u then do:
          {&st-price}
        end.
        run change-price in this-procedure (
            buffer bf-orig_parts,
            input tt-cur-parts.fact-qnty - tt-new-parts.fact-qnty,
            input varexch-code,
            input varcli-base-rate,
            input varvat-type,
            input varslt-type,
            input varprice-cli,
            input varprice-base,
            input varprice-rubl,
            input varvat-pc,
            input varslt-pc,
            input varroad-tax-base,
            input varroad-tax-rubl,
            input vartransport-base,
            input vartransport-rubl,
            input varother-base,
            input varother-rubl,
            input parcash-pay,
            input t-doc.internal,
            input t-doc.doc-type,
            input parext-doc-type,
            input yes,
            input ?,
            input varpurch-code,
            output parreccaus-parts ) no-error.
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры копирования партии с кодом " bf-orig_parts.part-code skip
            "порожденную документом " bf-orig_parts.in-code skip
            "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
            return-value skip
            trim(error-status :get-message(1))
            view-as alert-box error.
          undo, return error .
        end.
      end.
      else do:
        find first bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code
                                   and bf_parts-root.orig-in-code   = bf-orig_parts.in-code
                                   and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                                   and bf_parts-root.orig-part-code = bf-orig_parts.part-code.
        find first bf2_parts-root where bf2_parts-root.doc-code       = bf-orig_parts.out-code
                                    and bf2_parts-root.orig-in-code   = bf-orig_parts.in-code
                                    and bf2_parts-root.orig-gds-code  = bf_goods.gds-code
                                    and bf2_parts-root.orig-part-code = bf-orig_parts.part-code
                                    and recid( bf2_parts-root ) <> recid( bf_parts-root ) no-error.
        if available bf2_parts-root then do:
          message
            "Вы уменьшили количество c " tt-cur-parts.fact-qnty " на " tt-new-parts.fact-qnty " по партии с кодом " bf-orig_parts.part-code skip
            "порожденную документом " bf-orig_parts.in-code skip
            "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
            "Для нее существует несколько порожденных партий." skip
            "Уменьшение количества недопустимо. Удалите эту партию из документа, а затем создайте с нужным количеством." skip
          view-as alert-box.
          undo, return error .
        end.
        else do:
          find first bf-caus_parts where bf-caus_parts.obj-type   = bf_doc-line.obj-type
                                     and bf-caus_parts.obj-code   = bf_doc-line.obj-code
                                     and bf-caus_parts.artic      = bf_doc-line.artic
                                     and bf-caus_parts.prod-type  = bf_doc-line.prod-type
                                     and bf-caus_parts.prod-code  = bf_doc-line.prod-code
                                     and bf-caus_parts.in-code    = bf_doc-line.doc-code
                                     and bf-caus_parts.out-code   = bf_doc-line.doc-code
                                     and bf-caus_parts.part-code  = bf_parts-root.part-code.
          assign bf-caus_parts.qnty      = - tt-new-parts.fact-qnty
                 bf-caus_parts.fact-qnty = - tt-new-parts.fact-qnty.
        end.
      end. /*количество уменьшилось*/
    end. /*количества не равны*/
    /*количества в партии не изменились*/
    if varprc-chg-upd-parts then do:
      if parmode = "chg_parts":u then do:
        /*меняем цену во всех порожденных партиях*/
        for each bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code
                                 and bf_parts-root.orig-in-code   = bf-orig_parts.in-code
                                 and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                                 and bf_parts-root.orig-part-code = bf-orig_parts.part-code on error undo, return error return-value :
          find first bf-caus_parts where bf-caus_parts.obj-type   = bf_doc-line.obj-type
                                     and bf-caus_parts.obj-code   = bf_doc-line.obj-code
                                     and bf-caus_parts.artic      = bf_doc-line.artic
                                     and bf-caus_parts.prod-type  = bf_doc-line.prod-type
                                     and bf-caus_parts.prod-code  = bf_doc-line.prod-code
                                     and bf-caus_parts.in-code    = bf_doc-line.doc-code
                                     and bf-caus_parts.out-code   = bf_doc-line.doc-code
                                     and bf-caus_parts.part-code  = bf_parts-root.part-code.
          run change-price in this-procedure (
            buffer bf-orig_parts,
            input  0,
            input  varexch-code,
            input  varcli-base-rate,
            input  varvat-type,
            input  varslt-type,
            input  varprice-cli,
            input  varprice-base,
            input  varprice-rubl,
            input  varvat-pc,
            input  varslt-pc,
            input  varroad-tax-base,
            input  varroad-tax-rubl,
            input  vartransport-base,
            input  vartransport-rubl,
            input  varother-base,
            input  varother-rubl,
            input  parcash-pay,
            input  t-doc.internal,
            input  t-doc.doc-type,
            input  parext-doc-type,
            input  no,
            input  recid( bf-caus_parts ),
            input  varpurch-code,
            output parreccaus-parts ) no-error.
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при смене цены в партии " bf-caus_parts.part-code skip
              "порожденную документом " bf-caus_parts.in-code skip
              "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
              return-value skip
             trim(error-status :get-message(1))
             view-as alert-box error.
            undo, return error .
          end.
        end.
      end.
    end.
  end. /*не новая партия*/
end. /*идем по всем новым партиям*/
for each tt-cur-parts on error undo, return error return-value :
  find first tt-new-parts where tt-new-parts.obj-type  = tt-cur-parts.obj-type
                            and tt-new-parts.obj-code  = tt-cur-parts.obj-code
                            and tt-new-parts.artic     = tt-cur-parts.artic
                            and tt-new-parts.prod-type = tt-cur-parts.prod-type
                            and tt-new-parts.prod-code = tt-cur-parts.prod-code
                            and tt-new-parts.in-code   = tt-cur-parts.in-code
                            and tt-new-parts.out-code  = tt-cur-parts.out-code
                            and tt-new-parts.part-code = tt-cur-parts.part-code  no-error.
  /*Удалили исходную партию обнулив количество*/
  if not available tt-new-parts then do:
    for each bf_parts-root where bf_parts-root.doc-code       = tt-cur-parts.out-code
                             and bf_parts-root.orig-in-code   = tt-cur-parts.in-code
                             and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                             and bf_parts-root.orig-part-code = tt-cur-parts.part-code on error undo, return error return-value :
      find first bf-caus_parts where bf-caus_parts.obj-type   = bf_doc-line.obj-type
                                 and bf-caus_parts.obj-code   = bf_doc-line.obj-code
                                 and bf-caus_parts.artic      = bf_doc-line.artic
                                 and bf-caus_parts.prod-type  = bf_doc-line.prod-type
                                 and bf-caus_parts.prod-code  = bf_doc-line.prod-code
                                 and bf-caus_parts.in-code    = bf_doc-line.doc-code
                                 and bf-caus_parts.out-code   = bf_doc-line.doc-code
                                 and bf-caus_parts.part-code  = bf_parts-root.part-code.
      delete bf-caus_parts.
      delete bf_parts-root.
    end.
  end.
end.
/*Не осталось ни одной партии по строке*/
find first bf-hv_parts where bf-hv_parts.out-code  = bf_doc-line.doc-code  and
                             bf-hv_parts.obj-type  = t-doc.obj-type        and
                             bf-hv_parts.obj-code  = t-doc.obj-code        and
                             bf-hv_parts.artic     = bf_doc-line.artic     and
                             bf-hv_parts.prod-type = bf_doc-line.prod-type and
                             bf-hv_parts.prod-code = bf_doc-line.prod-code no-error.
if not available bf-hv_parts then do:
  run local-recalc in this-procedure ( input "delete":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
    undo, return error .
  end.
  run local-delete in this-procedure ( input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  /*Могли замочить по отсутствию партий*/
  if available bf_gds-dtl then do:
    delete bf_gds-dtl.
  end.
end.
if available bf_doc-line then do:
  run check-line in this-procedure ( input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message "Ошибка при проверке линии товара " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    undo, return error.
  end.
  find first bf_gds-dtl where recid( bf_gds-dtl ) = vargds-dtlrec.
  assign
    bf_doc-line.price-cli  = 0
    bf_doc-line.price-base = 0
    bf_doc-line.price-rubl = 0
    bf_doc-line.cli-qnty   = 0
    bf_doc-line.fact-qnty  = 0
    bf_doc-line.doc-qnty   = 0
    bf_gds-dtl.doc-qnty    = 0
    bf_gds-dtl.fact-qnty   = 0
  .
end.
end. /*do*/
end procedure.

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

procedure local-recalc :
define input parameter parmode as character no-undo.
define input parameter parrec-line as recid no-undo.
define variable p-value as character no-undo.
define variable p-type  as character no-undo.
define buffer bf_goods         for ub.goods.
define buffer bf_parts         for ub.parts.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.

do on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line.
find first bf_goods    where bf_goods.artic     = bf_doc-line.artic     and
                             bf_goods.prod-type = bf_doc-line.prod-type and
                             bf_goods.prod-code = bf_doc-line.prod-code no-lock.
 { str/reclcinv.i
   parmode
   parrec-line
   t-doc.doc-code
   vartot-docold
   vartot-rublold
   i-total-doc-line_tot-ovold
   i-total-doc-line_fact-rublold
   i-total-doc-line_fact-baseold
   i-total-doc-line_fact-qntyold
   i-total-doc-line_doc-qntyold
   i-total-doc-line_cli-qntyold
   i-total-parts_fact-baseold
   i-total-parts_fact-rublold
   i-total-parts_fact-qntyold
   no-error
 }
if error-status :error then do:
    message
    "Ошибка при обсчете линии по товару " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code skip
    view-as alert-box error.
  undo, return no-apply .
end.
if parmode <> "delete" then do:
  find first bf-expp_doc-line-sum where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code
                                    and bf-expp_doc-line-sum.gds-code = bf_goods.gds-code
                                    and bf-expp_doc-line-sum.sum-type = {&sum-expense-parts} exclusive-lock no-error.
  if not available bf-expp_doc-line-sum then do:
    create bf-expp_doc-line-sum.
    assign
      bf-expp_doc-line-sum.doc-code     = t-doc.doc-code
      bf-expp_doc-line-sum.ext-doc-type = t-doc.ext-doc-type
      bf-expp_doc-line-sum.obj-type     = t-doc.obj-type
      bf-expp_doc-line-sum.obj-code     = t-doc.obj-code
      bf-expp_doc-line-sum.gds-code     = bf_goods.gds-code
      bf-expp_doc-line-sum.sum-type     = {&sum-expense-parts}
    .
  end.
  find first bf-incp_doc-line-sum where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code
                                    and bf-incp_doc-line-sum.gds-code = bf_goods.gds-code
                                    and bf-incp_doc-line-sum.sum-type = {&sum-income-parts} exclusive-lock no-error.
  if not available bf-incp_doc-line-sum then do:
    create bf-incp_doc-line-sum.
    assign
      bf-incp_doc-line-sum.doc-code     = t-doc.doc-code
      bf-incp_doc-line-sum.ext-doc-type = t-doc.ext-doc-type
      bf-incp_doc-line-sum.obj-type     = t-doc.obj-type
      bf-incp_doc-line-sum.obj-code     = t-doc.obj-code
      bf-incp_doc-line-sum.gds-code     = bf_goods.gds-code
      bf-incp_doc-line-sum.sum-type     = {&sum-income-parts}
    .
  end.
end.
if parmode <> "old":u then do:
  if parmode <> "delete" then do:
    assign
      bf-expp_doc-line-sum.fact-qnty           = 0
      bf-expp_doc-line-sum.cost-sum-base       = 0
      bf-expp_doc-line-sum.cost-sum-rubl       = 0
      bf-expp_doc-line-sum.cost-vat-base       = 0
      bf-expp_doc-line-sum.cost-vat-rubl       = 0
      bf-expp_doc-line-sum.cost-slt-base       = 0
      bf-expp_doc-line-sum.cost-slt-rubl       = 0
      bf-expp_doc-line-sum.cost-road-tax-base  = 0
      bf-expp_doc-line-sum.cost-road-tax-rubl  = 0
      bf-expp_doc-line-sum.cost-excise-base    = 0
      bf-expp_doc-line-sum.cost-excise-rubl    = 0
      bf-expp_doc-line-sum.cost-transport-base = 0
      bf-expp_doc-line-sum.cost-transport-rubl = 0
      bf-expp_doc-line-sum.cost-other-base     = 0
      bf-expp_doc-line-sum.cost-other-rubl     = 0

      bf-incp_doc-line-sum.fact-qnty           = 0
      bf-incp_doc-line-sum.cost-sum-base       = 0
      bf-incp_doc-line-sum.cost-sum-rubl       = 0
      bf-incp_doc-line-sum.cost-vat-base       = 0
      bf-incp_doc-line-sum.cost-vat-rubl       = 0
      bf-incp_doc-line-sum.cost-slt-base       = 0
      bf-incp_doc-line-sum.cost-slt-rubl       = 0
      bf-incp_doc-line-sum.cost-road-tax-base  = 0
      bf-incp_doc-line-sum.cost-road-tax-rubl  = 0
      bf-incp_doc-line-sum.cost-excise-base    = 0
      bf-incp_doc-line-sum.cost-excise-rubl    = 0
      bf-incp_doc-line-sum.cost-transport-base = 0
      bf-incp_doc-line-sum.cost-transport-rubl = 0
      bf-incp_doc-line-sum.cost-other-base     = 0
      bf-incp_doc-line-sum.cost-other-rubl     = 0
    .

    for each bf_parts where bf_parts.out-code  = t-doc.doc-code     and
                            bf_parts.obj-type  = t-doc.obj-type     and
                            bf_parts.obj-code  = t-doc.obj-code     and
                            bf_parts.artic     = bf_goods.artic     and
                            bf_parts.prod-type = bf_goods.prod-type and
                            bf_parts.prod-code = bf_goods.prod-code on error undo, return error return-value :
      for each tt-clcparts :
        delete tt-clcparts.
      end.
      create tt-clcparts.
      buffer-copy bf_parts to tt-clcparts.
      run clcprtsl_calc-parts in this-procedure
         (input recid( tt-clcparts ),
          input no,
          input no,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?
         ).
      find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
      if bf_parts.in-code <> bf_parts.out-code then do:
         assign
           bf-expp_doc-line-sum.fact-qnty           = bf-expp_doc-line-sum.fact-qnty            - tt-allsum.fact-qnty
           bf-expp_doc-line-sum.cost-sum-base       = bf-expp_doc-line-sum.cost-sum-base        - tt-allsum.sum-dsc-base-acc
           bf-expp_doc-line-sum.cost-sum-rubl       = bf-expp_doc-line-sum.cost-sum-rubl        - tt-allsum.sum-dsc-rubl-acc
           bf-expp_doc-line-sum.cost-vat-base       = bf-expp_doc-line-sum.cost-vat-base        - tt-allsum.vat-base-acc
           bf-expp_doc-line-sum.cost-vat-rubl       = bf-expp_doc-line-sum.cost-vat-rubl        - tt-allsum.vat-rubl-acc
           bf-expp_doc-line-sum.cost-slt-base       = bf-expp_doc-line-sum.cost-slt-base        - tt-allsum.slt-base-acc
           bf-expp_doc-line-sum.cost-slt-rubl       = bf-expp_doc-line-sum.cost-slt-rubl        - tt-allsum.slt-rubl-acc
           bf-expp_doc-line-sum.cost-road-tax-base  = bf-expp_doc-line-sum.cost-road-tax-base   - tt-allsum.road-tax-base-acc
           bf-expp_doc-line-sum.cost-road-tax-rubl  = bf-expp_doc-line-sum.cost-road-tax-rubl   - tt-allsum.road-tax-rubl-acc
           bf-expp_doc-line-sum.cost-excise-base    = bf-expp_doc-line-sum.cost-excise-base     - tt-allsum.excise-base-acc
           bf-expp_doc-line-sum.cost-excise-rubl    = bf-expp_doc-line-sum.cost-excise-rubl     - tt-allsum.excise-rubl-acc
           bf-expp_doc-line-sum.cost-transport-base = bf-expp_doc-line-sum.cost-transport-base  - tt-allsum.transport-base-acc
           bf-expp_doc-line-sum.cost-transport-rubl = bf-expp_doc-line-sum.cost-transport-rubl  - tt-allsum.transport-rubl-acc
           bf-expp_doc-line-sum.cost-other-base     = bf-expp_doc-line-sum.cost-other-base      - tt-allsum.other-base-acc
           bf-expp_doc-line-sum.cost-other-rubl     = bf-expp_doc-line-sum.cost-other-rubl      - tt-allsum.other-rubl-acc
         .
      end.
      else do:
         assign
           bf-incp_doc-line-sum.fact-qnty           = bf-incp_doc-line-sum.fact-qnty            + tt-allsum.fact-qnty
           bf-incp_doc-line-sum.cost-sum-base       = bf-incp_doc-line-sum.cost-sum-base        + tt-allsum.sum-dsc-base-acc
           bf-incp_doc-line-sum.cost-sum-rubl       = bf-incp_doc-line-sum.cost-sum-rubl        + tt-allsum.sum-dsc-rubl-acc
           bf-incp_doc-line-sum.cost-vat-base       = bf-incp_doc-line-sum.cost-vat-base        + tt-allsum.vat-base-acc
           bf-incp_doc-line-sum.cost-vat-rubl       = bf-incp_doc-line-sum.cost-vat-rubl        + tt-allsum.vat-rubl-acc
           bf-incp_doc-line-sum.cost-slt-base       = bf-incp_doc-line-sum.cost-slt-base        + tt-allsum.slt-base-acc
           bf-incp_doc-line-sum.cost-slt-rubl       = bf-incp_doc-line-sum.cost-slt-rubl        + tt-allsum.slt-rubl-acc
           bf-incp_doc-line-sum.cost-road-tax-base  = bf-incp_doc-line-sum.cost-road-tax-base   + tt-allsum.road-tax-base-acc
           bf-incp_doc-line-sum.cost-road-tax-rubl  = bf-incp_doc-line-sum.cost-road-tax-rubl   + tt-allsum.road-tax-rubl-acc
           bf-incp_doc-line-sum.cost-excise-base    = bf-incp_doc-line-sum.cost-excise-base     + tt-allsum.excise-base-acc
           bf-incp_doc-line-sum.cost-excise-rubl    = bf-incp_doc-line-sum.cost-excise-rubl     + tt-allsum.excise-rubl-acc
           bf-incp_doc-line-sum.cost-transport-base = bf-incp_doc-line-sum.cost-transport-base  + tt-allsum.transport-base-acc
           bf-incp_doc-line-sum.cost-transport-rubl = bf-incp_doc-line-sum.cost-transport-rubl  + tt-allsum.transport-rubl-acc
           bf-incp_doc-line-sum.cost-other-base     = bf-incp_doc-line-sum.cost-other-base      + tt-allsum.other-base-acc
           bf-incp_doc-line-sum.cost-other-rubl     = bf-incp_doc-line-sum.cost-other-rubl      + tt-allsum.other-rubl-acc
         .
      end.
    end.
  end.
  { str/tdat-val.i
      t-doc.doc-code
      {&trdcattr-addsum}
      p-value
      p-type
  }
  if lookup( {&sum-expense-parts}, p-value ) = 0 then do:
    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-addsum}
        "( p-value + min( p-value, ',' ) + {&sum-expense-parts} )"
    }
  end.
  find first bf-expp_trn-doc-sum where bf-expp_trn-doc-sum.doc-code = t-doc.doc-code       and
                                       bf-expp_trn-doc-sum.sum-type = {&sum-expense-parts} exclusive-lock no-error.
  if not available bf-expp_trn-doc-sum then do:
    create bf-expp_trn-doc-sum.
    assign
      bf-expp_trn-doc-sum.doc-code     = t-doc.doc-code
      bf-expp_trn-doc-sum.ext-doc-type = t-doc.ext-doc-type
      bf-expp_trn-doc-sum.obj-type     = t-doc.obj-type
      bf-expp_trn-doc-sum.obj-code     = t-doc.obj-code
      bf-expp_trn-doc-sum.sum-type     = {&sum-expense-parts}.
  end.
  if lookup( {&sum-income-parts}, p-value ) = 0 then do:
    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-addsum}
        "( p-value + min( p-value, ',' ) + {&sum-income-parts} )"
    }
  end.
  find first bf-incp_trn-doc-sum where bf-incp_trn-doc-sum.doc-code = t-doc.doc-code      and
                                       bf-incp_trn-doc-sum.sum-type = {&sum-income-parts} exclusive-lock no-error.
  if not available bf-incp_trn-doc-sum then do:
    create bf-incp_trn-doc-sum.
    assign
      bf-incp_trn-doc-sum.doc-code     = t-doc.doc-code
      bf-incp_trn-doc-sum.ext-doc-type = t-doc.ext-doc-type
      bf-incp_trn-doc-sum.obj-type     = t-doc.obj-type
      bf-incp_trn-doc-sum.obj-code     = t-doc.obj-code
      bf-incp_trn-doc-sum.sum-type     = {&sum-income-parts}.
  end.
  assign
    bf-expp_trn-doc-sum.fact-qnty           = bf-expp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-expp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-exp
    bf-expp_trn-doc-sum.cost-sum-base       = bf-expp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-exp
    bf-expp_trn-doc-sum.cost-sum-rubl       = bf-expp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-exp
    bf-expp_trn-doc-sum.cost-vat-base       = bf-expp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-exp
    bf-expp_trn-doc-sum.cost-vat-rubl       = bf-expp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-exp
    bf-expp_trn-doc-sum.cost-slt-base       = bf-expp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-exp
    bf-expp_trn-doc-sum.cost-slt-rubl       = bf-expp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-exp
    bf-expp_trn-doc-sum.cost-road-tax-base  = bf-expp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-exp
    bf-expp_trn-doc-sum.cost-road-tax-rubl  = bf-expp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-exp
    bf-expp_trn-doc-sum.cost-excise-base    = bf-expp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-exp
    bf-expp_trn-doc-sum.cost-excise-rubl    = bf-expp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-exp
    bf-expp_trn-doc-sum.cost-transport-base = bf-expp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-exp
    bf-expp_trn-doc-sum.cost-transport-rubl = bf-expp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-exp
    bf-expp_trn-doc-sum.cost-other-base     = bf-expp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-exp
    bf-expp_trn-doc-sum.cost-other-rubl     = bf-expp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-exp

    bf-incp_trn-doc-sum.fact-qnty           = bf-incp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-incp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-inp
    bf-incp_trn-doc-sum.cost-sum-base       = bf-incp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-inp
    bf-incp_trn-doc-sum.cost-sum-rubl       = bf-incp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-inp
    bf-incp_trn-doc-sum.cost-vat-base       = bf-incp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-inp
    bf-incp_trn-doc-sum.cost-vat-rubl       = bf-incp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-inp
    bf-incp_trn-doc-sum.cost-slt-base       = bf-incp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-inp
    bf-incp_trn-doc-sum.cost-slt-rubl       = bf-incp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-inp
    bf-incp_trn-doc-sum.cost-road-tax-base  = bf-incp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-inp
    bf-incp_trn-doc-sum.cost-road-tax-rubl  = bf-incp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-inp
    bf-incp_trn-doc-sum.cost-excise-base    = bf-incp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-inp
    bf-incp_trn-doc-sum.cost-excise-rubl    = bf-incp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-inp
    bf-incp_trn-doc-sum.cost-transport-base = bf-incp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-inp
    bf-incp_trn-doc-sum.cost-transport-rubl = bf-incp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-inp
    bf-incp_trn-doc-sum.cost-other-base     = bf-incp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-inp
    bf-incp_trn-doc-sum.cost-other-rubl     = bf-incp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-inp
  .
end.
else do:
  assign
    varoldfact-qnty-exp            =   bf-expp_doc-line-sum.fact-qnty
    varoldcost-sum-base-exp        =   bf-expp_doc-line-sum.cost-sum-base
    varoldcost-sum-rubl-exp        =   bf-expp_doc-line-sum.cost-sum-rubl
    varoldcost-vat-base-exp        =   bf-expp_doc-line-sum.cost-vat-base
    varoldcost-vat-rubl-exp        =   bf-expp_doc-line-sum.cost-vat-rubl
    varoldcost-slt-base-exp        =   bf-expp_doc-line-sum.cost-slt-base
    varoldcost-slt-rubl-exp        =   bf-expp_doc-line-sum.cost-slt-rubl
    varoldcost-road-tax-base-exp   =   bf-expp_doc-line-sum.cost-road-tax-base
    varoldcost-road-tax-rubl-exp   =   bf-expp_doc-line-sum.cost-road-tax-rubl
    varoldcost-excise-base-exp     =   bf-expp_doc-line-sum.cost-excise-base
    varoldcost-excise-rubl-exp     =   bf-expp_doc-line-sum.cost-excise-rubl
    varoldcost-transport-base-exp  =   bf-expp_doc-line-sum.cost-transport-base
    varoldcost-transport-rubl-exp  =   bf-expp_doc-line-sum.cost-transport-rubl
    varoldcost-other-base-exp      =   bf-expp_doc-line-sum.cost-other-base
    varoldcost-other-rubl-exp      =   bf-expp_doc-line-sum.cost-other-rubl

    varoldfact-qnty-inp            =   bf-incp_doc-line-sum.fact-qnty
    varoldcost-sum-base-inp        =   bf-incp_doc-line-sum.cost-sum-base
    varoldcost-sum-rubl-inp        =   bf-incp_doc-line-sum.cost-sum-rubl
    varoldcost-vat-base-inp        =   bf-incp_doc-line-sum.cost-vat-base
    varoldcost-vat-rubl-inp        =   bf-incp_doc-line-sum.cost-vat-rubl
    varoldcost-slt-base-inp        =   bf-incp_doc-line-sum.cost-slt-base
    varoldcost-slt-rubl-inp        =   bf-incp_doc-line-sum.cost-slt-rubl
    varoldcost-road-tax-base-inp   =   bf-incp_doc-line-sum.cost-road-tax-base
    varoldcost-road-tax-rubl-inp   =   bf-incp_doc-line-sum.cost-road-tax-rubl
    varoldcost-excise-base-inp     =   bf-incp_doc-line-sum.cost-excise-base
    varoldcost-excise-rubl-inp     =   bf-incp_doc-line-sum.cost-excise-rubl
    varoldcost-transport-base-inp  =   bf-incp_doc-line-sum.cost-transport-base
    varoldcost-transport-rubl-inp  =   bf-incp_doc-line-sum.cost-transport-rubl
    varoldcost-other-base-inp      =   bf-incp_doc-line-sum.cost-other-base
    varoldcost-other-rubl-inp      =   bf-incp_doc-line-sum.cost-other-rubl
  .
end.
end.
end procedure.

procedure local-delete :
define input parameter parrec-line as recid no-undo.
define buffer bf_doc-line for ub.doc-line.
define variable l-inv-on as logical no-undo.
do on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line.
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
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка установки атрибута товара на объекте" skip
    "Документ" bf_doc-line.doc-code skip
    "Объект" bf_doc-line.obj-type bf_doc-line.obj-code skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "l-inv-on" l-inv-on skip
    view-as alert-box error .
  undo, return error .
end.
delete bf_doc-line.
end.
end procedure.

procedure local-chg:
define buffer bf_goods for ub.goods.
define variable varhvrdtax        as   logical                  no-undo.
define variable varis-ok as logical no-undo.
define variable varlog as logical no-undo.
define variable varmode as character no-undo.
if not available bf_doc-line then do:
  message "Неправильный выбор строки.".
  return no-apply.
end.
do transaction on error undo, return no-apply :
run local-recalc in this-procedure ( input "old":U,
                                     input recid( bf_doc-line ) ) no-error.
if error-status :error then do:
  undo, return error "Ошибка при пересчете строки документа".
end.

find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                          bf_goods.prod-type = bf_doc-line.prod-type and
                          bf_goods.prod-code = bf_doc-line.prod-code no-lock.
assign
  varhvrdtax = hvrdtax ( recid( bf_goods ) ).
assign
  varlog = ?.
message
"Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name
"Вы можете поменять цены по: " skip
" - всем выбранным партиям из свободной зоны (YES) " skip
" - новым выбранным партиям из свободной зоны (NO) "
view-as alert-box question buttons yes-no update varlog.
if varlog = yes then do:
  assign
    varmode = "chg_parts":u.
end.
else do:
  varmode = "chg_new_parts":u.
end.
find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
run update-line in this-procedure
(  input varmode
 , input recid( bf_doc-line )
 , input bf_sysconf.cash-pay
 , input ?
 , input ?
 , input ?
 , input ?
) no-error.
if error-status :error then do:
  undo, return error "Ошибка при редактировании линии документа по товару " + bf_doc-line.artic + " " + bf_doc-line.prod-type + " " + string(bf_doc-line.prod-code).
end.
if available bf_doc-line then do:
  run local-recalc in this-procedure ( input "update":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    undo, return error "Ошибка при пересчете строки документа".
  end.
end.
end.
end procedure.

procedure local-lockup:
define buffer bf_goods for ub.goods.
define variable prt-rec as recid no-undo.
if available bf_doc-line then do:
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
   run str/parts-l.w
     (input parparentproc
     ,input t-doc.obj-type            /* v-obj-type   */
     ,input t-doc.obj-code            /* v-obj-code   */
     ,input bf_goods.gds-code         /* p-gds-code   */
     ,input bf_doc-line.doc-code      /* p-doc-code   */
     ,input {&lookup}                 /* p-edit-mode  */
     ,input {&parts-l_parts-document} /* p-r-parts    */
     ,input {&parts-l_object-current} /* p-one-all    */
     ,input {&parts-l_call-document}  /* p-call-point */
     ,output prt-rec                  /* part-recid   */
     ) .

end.
end procedure.

procedure change-price :
  define parameter buffer buf-orig_parts for  ub.parts .
  define input  parameter  parqnty             like ub.parts.fact-qnty      no-undo.
  define input  parameter  parexch-code        like ub.parts.exch-code      no-undo.
  define input  parameter  parcli-base-rate    like ub.parts.cli-base-rate  no-undo.
  define input  parameter  parvat-type         like ub.parts.vat-type       no-undo.
  define input  parameter  parslt-type         like ub.parts.slt-type       no-undo.
  define input  parameter  parprice-cli        like ub.parts.price-cli      no-undo.
  define input  parameter  parprice-base       like ub.parts.price-base     no-undo.
  define input  parameter  parprice-rubl       like ub.parts.price-rubl     no-undo.
  define input  parameter  parvat-pc           like ub.parts.vat-pc         no-undo.
  define input  parameter  parslt-pc           like ub.parts.slt-pc         no-undo.
  define input  parameter  parroad-tax-base    like ub.parts.road-tax-base  no-undo.
  define input  parameter  parroad-tax-rubl    like ub.parts.road-tax-rubl  no-undo.
  define input  parameter  partransport-base   like ub.parts.transport-base no-undo.
  define input  parameter  partransport-rubl   like ub.parts.transport-rubl no-undo.
  define input  parameter  parother-base       like ub.parts.other-base     no-undo.
  define input  parameter  parother-rubl       like ub.parts.other-rubl     no-undo.
  define input  parameter  parcash-pay         like ub.parts.pay-code       no-undo.
  define input  parameter  parinternal         like ub.trn-doc.internal     no-undo.
  define input  parameter  pardoc-type         like ub.trn-doc.doc-type     no-undo.
  define input  parameter  parext-doc-type     like ub.trn-doc.ext-doc-type no-undo.
  define input  parameter  parcreate-new-parts as   logical                 no-undo.
  define input  parameter  parrecid-caus-parts as   recid                   no-undo.
  define input  parameter  parpurch-code       like ub.parts.purch-code     no-undo.
  define output parameter  parrec-parts        as   recid                   no-undo.
  define buffer buf-caus_parts for ub.parts.
  define buffer buf_units      for ub.units.
  define buffer buf-have_parts for ub.parts.
  define variable varnew-slt-type as character no-undo.
  define variable varpart-code like ub.parts.part-code no-undo.
  define variable varslt-yes as logical no-undo.
  define buffer buf_goods      for ub.goods.
  define buffer buf_parts-root for ub.parts-root.
  do on error undo, return error return-value :
    find first buf_goods           no-lock where
               buf_goods.artic     = buf-orig_parts.artic
           and buf_goods.prod-type = buf-orig_parts.prod-type
           and buf_goods.prod-code = buf-orig_parts.prod-code .
    find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock.
    if (parroad-tax-base <> 0 and
        parroad-tax-base <> ?     ) or
       (parroad-tax-rubl <> 0 and
        parroad-tax-rubl <> ?     )
       then do:
       if hvrdtax ( recid( buf_goods ) ) = no then do:
         message
           vss-workfile vss-revision vss-description skip
           "Для товара " buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
           " недопустима установка дополнительной компоненты отличной от 0." skip
         view-as alert-box error.
         undo, return error .
       end.
    end.
    if parcreate-new-parts then do:
      /*У серийного товара проставляем код оригинальной партии*/
      if lookup({&serial}, buf_units.type) > 0 then do:
        find first buf-have_parts where buf-have_parts.obj-type  = buf-orig_parts.obj-type  and
                                        buf-have_parts.obj-code  = buf-orig_parts.obj-code  and
                                        buf-have_parts.artic     = buf-orig_parts.artic     and
                                        buf-have_parts.prod-type = buf-orig_parts.prod-type and
                                        buf-have_parts.prod-code = buf-orig_parts.prod-code and
                                        buf-have_parts.in-code   = buf-orig_parts.out-code  and
                                        buf-have_parts.out-code  = buf-orig_parts.out-code  and
                                        buf-have_parts.part-code = buf-orig_parts.part-code no-lock no-error.

        if available buf-have_parts then do:
          message "Товар " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name " - серийный." skip
                  "Делаем коррекцию учетной цены по партии с кодом " buf-orig_parts.part-code "." skip
                  "Но в документе уже есть порожденная партия этого товара с таким кодом либо в данном процессе должны породиться две партии с таким кодом."
          view-as alert-box error.
          undo, return error return-value.
        end.
        else do:
          assign
            varpart-code = buf-orig_parts.part-code.
        end.
      end.
      else do:
        run holdprts-get-part-code in this-procedure (  input buf-orig_parts.out-code
                                                     , output varpart-code
                                                      ) no-error .
        if error-status :error then dO:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при получении кода партии." skip
            return-value skip
            trim(error-status :get-message(1)) skip
            view-as alert-box error.
          undo, return error return-value.
        end.
      end.
      create buf-caus_parts .
      buffer-copy buf-orig_parts
      except in-code rsrv-free status_ qnty fact-qnty real-qnty cli-qnty price-rubl price-base
             vat-pc slt-pc road-tax-rubl road-tax-base transport-rubl transport-base other-rubl
             other-base part-code exch-code cli-base-rate price-cli vat-type slt-type to buf-caus_parts.
      assign
        buf-caus_parts.in-code        = buf-caus_parts.out-code
        buf-caus_parts.part-code      = varpart-code
        buf-caus_parts.rsrv-free      = ?
        buf-caus_parts.status_        = no
        buf-caus_parts.qnty           = parqnty
        buf-caus_parts.fact-qnty      = parqnty
        buf-caus_parts.real-qnty      = 0
        buf-caus_parts.cli-base-rate  = parcli-base-rate
        buf-caus_parts.vat-type       = parvat-type
        buf-caus_parts.slt-type       = parslt-type
        buf-caus_parts.cli-qnty       = parqnty / parcli-base-rate
        buf-caus_parts.exch-code      = parexch-code
      .
      find first buf_parts-root where
                 buf_parts-root.doc-code       = buf-caus_parts.out-code
           and   buf_parts-root.in-code        = buf-caus_parts.in-code
           and   buf_parts-root.gds-code       = buf_goods.gds-code
           and   buf_parts-root.part-code      = buf-caus_parts.part-code
           and   buf_parts-root.orig-in-code   = buf-orig_parts.in-code
           and   buf_parts-root.orig-gds-code  = buf_goods.gds-code
           and   buf_parts-root.orig-part-code = buf-orig_parts.part-code no-error .
      if not available buf_parts-root then do:
        create buf_parts-root.
        assign
          buf_parts-root.doc-code       = buf-caus_parts.out-code
          buf_parts-root.in-code        = buf-caus_parts.in-code
          buf_parts-root.gds-code       = buf_goods.gds-code
          buf_parts-root.part-code      = buf-caus_parts.part-code
          buf_parts-root.orig-in-code   = buf-orig_parts.in-code
          buf_parts-root.orig-gds-code  = buf_goods.gds-code
          buf_parts-root.orig-part-code = buf-orig_parts.part-code
        .
      end.
    end.
    else do:
      find first buf-caus_parts where recid( buf-caus_parts ) = parrecid-caus-parts.
    end.
    assign
      buf-caus_parts.price-rubl     = parprice-rubl
      buf-caus_parts.price-base     = parprice-base
      buf-caus_parts.price-cli      = parprice-cli
      buf-caus_parts.vat-pc         = parvat-pc
      buf-caus_parts.slt-pc         = parslt-pc
      buf-caus_parts.road-tax-rubl  = parroad-tax-rubl
      buf-caus_parts.road-tax-base  = parroad-tax-base
      buf-caus_parts.transport-rubl = partransport-rubl
      buf-caus_parts.transport-base = partransport-base
      buf-caus_parts.other-rubl     = parother-rubl
      buf-caus_parts.other-base     = parother-base
    .
    if parslt-pc <> 0 then do:
      if buf-caus_parts.slt-type <> {&inc-slt} and
         buf-caus_parts.slt-type <> {&no-slt}  then do:
        assign
          buf-caus_parts.slt-type = {&inc-slt} .
      end.
    end.
    if parpurch-code <> ? then do:
      assign
        buf-caus_parts.purch-code = parpurch-code.
    end.
  end.
end procedure.

procedure check-cli :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer bf_contract for ub.contract.
define buffer bf_currency for ub.currency.
define variable varexch-rate  like ub.trn-doc.exch-rate  no-undo.
define variable varexch-scale like ub.trn-doc.exch-scale no-undo.
define variable varcurr-abbr  as   character             no-undo.
define variable varcontract-code like ub.contract.contract-code no-undo.
define variable varbase-code like ub.sysconf.base-code no-undo.
do on error undo, return error return-value :
if input frame {&frame-name} t-doc.cli-type = ? or input frame {&frame-name} t-doc.cli-type = "" then do:
  if can-find (clients where clients.obj-code = input frame {&frame-name} t-doc.cli-code
                         and clients.obj-type = {&cmp} no-lock) then do:
    display {&cmp} @ t-doc.cli-type with frame {&frame-name}.
  end.
  else do:
    display {&prs} @ t-doc.cli-type with frame {&frame-name}.
  end.
end.
find clients where clients.obj-code = input frame {&frame-name} t-doc.cli-code
               and clients.obj-type = input frame {&frame-name} t-doc.cli-type no-error.
if not available clients then do:
  if input frame {&frame-name} t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
  message "Неправильный код или тип контрагента.".
  apply "entry" to t-doc.cli-code in frame {&frame-name}.
  return error.
end.
display clients.obj-type @ t-doc.cli-type with frame {&frame-name}.
if clients.obj-type = {&stock} or
   clients.obj-type = {&shop}  then do:
  release clients no-error.
  message "Выберите организацию или человека.".
  apply "entry" to t-doc.cli-code in frame {&frame-name}.
  return error.
end.

define variable v-err as logical   no-undo .
  run ver-clients  ( clients.obj-type , clients.obj-code , output v-err ) .
  if  v-err then do:
    apply "entry" to t-doc.cli-code in frame {&frame-name}.
    return error.
  end.


assign
  t-doc.cli-code = input frame {&frame-name} t-doc.cli-code
  t-doc.cli-type = input frame {&frame-name} t-doc.cli-type.
display clients.obj-name with frame {&frame-name}.
assign
  pardoc-mode = {&update}.
find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                             bf_contract.cli-type  = input frame {&frame-name} t-doc.cli-type and
                             bf_contract.cli-code  = input frame {&frame-name} t-doc.cli-code and
                             bf_contract.status_   = {&current-contr}                         no-lock no-error.
if not available bf_contract then do:
  assign
    t-doc.contract-code  = 0
    varcntr-prn-code     = ""
    varcntr-name         = "БЕЗ ДОГОВОРА"
    .
end.
else do:
  run check-contract-code in this-procedure (input  "choose":u,
                                             input  t-doc.host-code,
                                             input  input frame {&frame-name} t-doc.cli-type,
                                             input  input frame {&frame-name} t-doc.cli-code,
                                             input  ?,
                                             input  parparentproc,
                                             input  t-doc.doc-date,
                                             input  "" ,
                                             output varcontract-code) no-error.
  if error-status :error    or
     varcontract-code = ?  or
     varcontract-code = 0  then do:
    message "Вы не выбрали договор. Вы хотите редактировать партии свободной зоны по приходам без договора?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog = no then do:
      apply "entry" to t-doc.cli-code in frame {&frame-name}.
      return error.
    end.
    else do:
      assign
        t-doc.contract-code = 0
        varcntr-prn-code    = ""
        varcntr-name        = "БЕЗ ДОГОВОРА"
      .
    end.
  end.
  else do:
    find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                 bf_contract.contract-code = varcontract-code no-lock.
    find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
    if not available bf_currency then do:
      message "В договоре указана валюта " bf_contract.curr-code "." skip
              "Но этой валюты нет в справочнике валют."
      view-as alert-box error.
      apply "entry" to t-doc.cli-code in frame {&frame-name}.
      return error.
    end.
    { gbl/exchrate.i
      bf_currency.curr-code
      t-doc.exch-date
      varexch-rate
      varexch-scale
      varcurr-abbr
      no-error
    }
    if error-status :error then do:
      message "Ошибка при поиске курса валюты поставки по договору." skip
              return-value skip
              error-status :get-message( 1 ) skip
              error-status :get-message( 2 )
      view-as alert-box error.
      return error.
    end.
    assign
      t-doc.contract-code = varcontract-code
      t-doc.exch-code     = bf_contract.curr-code
      t-doc.exch-rate     = varexch-rate
      t-doc.exch-scale    = varexch-scale
      varcntr-prn-code    = bf_contract.contract-prn-code
      varcntr-name        = bf_contract.contract-name
    .
  end.
end.
if clients.obj-type = {&cmp} then do:
  /* ищем менеджера */
  find firm where firm.firm-code = clients.obj-code no-lock.
  find clients where clients.obj-type = {&prs}
                        and clients.obj-code = firm.tobj-code no-lock no-error.
  if available clients then
    display clients.obj-code @ t-doc.boss
            clients.obj-name @ boss-name with frame {&frame-name}.
end.
release clients.
{ gbl/curobjdt.i t-doc.obj-type t-doc.obj-code v-today }
{ gbl/basecode.i t-doc.host-code varbase-code }
find last curr-accnt where curr-accnt.curr-code  = varbase-code
                       and curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
if not available curr-accnt then do:
   message "На дату" v-today "неизвестен курс базовой валюты." SKIP
   view-as alert-box error.
   return error.
end.
else do:
  assign
    t-doc.base-rate  = curr-accnt.exch-rate
    t-doc.base-scale = curr-accnt.exch-scale.
end.
assign
  t-doc.exch-date     = v-today
  t-doc.print-rubl    = yes.
run UI-on in this-procedure ( input "enable" ).
if b-add :sensitive = yes then apply "entry" to b-add in frame {&frame-name}.
end.
end procedure.

procedure choose-cli:
define variable varfirm-code like firm.firm-code no-undo.
define buffer bf_clients for ub.clients.
do on error undo, return error return-value :
run check-cli in this-procedure no-error.
if error-status :error then do:
  run ref/cli-all.w (parparentproc
                , "b-sel"
                , {&cmp}
                , ?
                , ?
                , ?
                , ?
                , ?
                , output ref-list) .
  if ref-list <> "" then do:
    ref-rec = integer (ref-list).
    find first bf_clients where recid( bf_clients ) = ref-rec no-lock.
    display bf_clients.obj-code @ t-doc.cli-code
            bf_clients.obj-name @ clients.obj-name with frame {&frame-name}.
    display bf_clients.obj-type @ t-doc.cli-type   with frame {&frame-name}.
  end.
  run check-cli in this-procedure no-error.
  if error-status :error then do:
    return error return-value.
  end.
end.
end.
end procedure.

procedure check-line :
define input parameter parrec-line as recid no-undo.
define buffer bf_doc-line   for ub.doc-line.
define buffer bf_goods      for ub.goods.
define buffer bf_parts-root for ub.parts-root.
define buffer bf_parts      for ub.parts.
define buffer bf-cr_parts   for ub.parts.
define variable varqnty    as decimal no-undo.
define variable varcr-qnty as decimal no-undo.
do on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line no-error.
if not available bf_doc-line then do:
  return error substitute ("Не найдена строка документа в процедуре check-line.").
end.
find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                          bf_goods.prod-type = bf_doc-line.prod-type and
                          bf_goods.prod-code = bf_doc-line.prod-code no-lock.
/*Взятые партии имеют под собой порожденные с тем же количеством*/
for each bf_parts where bf_parts.out-code      = t-doc.doc-code
                    and bf_parts.obj-type      = t-doc.obj-type
                    and bf_parts.obj-code      = t-doc.obj-code
                    and bf_parts.artic         = bf_doc-line.artic
                    and bf_parts.prod-type     = bf_doc-line.prod-type
                    and bf_parts.prod-code     = bf_doc-line.prod-code
                    and bf_parts.in-code      <> t-doc.doc-code         on error undo, return error return-value :
  assign
    varqnty = varqnty + bf_parts.fact-qnty.
  for each bf_parts-root where bf_parts-root.doc-code       = bf_parts.out-code
                           and bf_parts-root.orig-in-code   = bf_parts.in-code
                           and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                           and bf_parts-root.orig-part-code = bf_parts.part-code on error undo, return error return-value :
    find first bf-cr_parts where bf-cr_parts.obj-type  = t-doc.obj-type
                             and bf-cr_parts.obj-code  = t-doc.obj-code
                             and bf-cr_parts.artic     = bf_doc-line.artic
                             and bf-cr_parts.prod-type = bf_doc-line.prod-type
                             and bf-cr_parts.prod-code = bf_doc-line.prod-code
                             and bf-cr_parts.in-code   = bf_parts-root.in-code
                             and bf-cr_parts.out-code  = bf_parts-root.doc-code
                             and bf-cr_parts.part-code = bf_parts-root.part-code .
    assign
      varcr-qnty = varcr-qnty + bf-cr_parts.fact-qnty.
  end.
end.
if varqnty <> - varcr-qnty then do:
  return error substitute ("Критическая ошибка. Кол-во по взятым партиям из свободной зоны &1. Количество по созданым партиям &2.", varqnty, varcr-qnty).
end.
/*Все записи parts-root по документу имеют родителя и ребенка*/
for each bf_parts-root where bf_parts-root.doc-code = t-doc.doc-code on error undo, return error return-value :
  find first bf_goods where bf_goods.gds-code = bf_parts-root.gds-code.
  find first bf_parts where bf_parts.obj-type  = t-doc.obj-type
                        and bf_parts.obj-code  = t-doc.obj-code
                        and bf_parts.artic     = bf_goods.artic
                        and bf_parts.prod-type = bf_goods.prod-type
                        and bf_parts.prod-code = bf_goods.prod-code
                        and bf_parts.in-code   = bf_parts-root.orig-in-code
                        and bf_parts.part-code = bf_parts-root.orig-part-code no-error.
  if not available bf_parts then do:
    return error substitute ("Критическая ошибка. Есть запись parts-root c ссылкой на родительскую партию. Партия: Объект &1 &2. Товар &3 &4 &5. Порожд. док-т. &6. Код партии &7.",
                            t-doc.obj-type,
                            t-doc.obj-code,
                            bf_goods.artic,
                            bf_goods.prod-type,
                            bf_goods.prod-code,
                            bf_parts-root.orig-in-code,
                            bf_parts-root.orig-part-code
                           ).
  end.
  find first bf-cr_parts where bf-cr_parts.obj-type  = t-doc.obj-type
                           and bf-cr_parts.obj-code  = t-doc.obj-code
                           and bf-cr_parts.artic     = bf_goods.artic
                           and bf-cr_parts.prod-type = bf_goods.prod-type
                           and bf-cr_parts.prod-code = bf_goods.prod-code
                           and bf-cr_parts.in-code   = bf_parts-root.in-code
                           and bf-cr_parts.out-code  = bf_parts-root.doc-code
                           and bf-cr_parts.part-code = bf_parts-root.part-code no-error.
  if not available bf-cr_parts then do:
    return error substitute ("Критическая ошибка. Есть запись parts-root c ссылкой на дочернюю партию. Партия: Объект &1 &2. Товар &3 &4 &5. Порожд. док-т. &6. Док-т &7. Код партии &8.",
                            t-doc.obj-type,
                            t-doc.obj-code,
                            bf_goods.artic,
                            bf_goods.prod-type,
                            bf_goods.prod-code,
                            bf_parts-root.in-code,
                            bf_parts-root.doc-code,
                            bf_parts-root.part-code
                           ).
  end.
end.
/*Каждая порожденная партия имеет над собой parts-root*/
for each bf-cr_parts where bf-cr_parts.out-code  = t-doc.out-code
                       and bf-cr_parts.obj-type  = t-doc.obj-type
                       and bf-cr_parts.obj-code  = t-doc.obj-code
                       and bf-cr_parts.artic     = bf_doc-line.artic
                       and bf-cr_parts.prod-type = bf_doc-line.prod-type
                       and bf-cr_parts.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
  find first bf_parts-root where bf_parts-root.doc-code  = bf-cr_parts.out-code
                             and bf_parts-root.in-code   = bf-cr_parts.out-code
                             and bf_parts-root.gds-code  = bf_goods.gds-code
                             and bf_parts-root.part-code = bf-cr_parts.part-code no-error.
  if not available bf_parts-root then do:
    return error substitute ("Критическая ошибка. Не найден parts-root для партии. Объект &1 &2. Товар &3 &4 &5. Код партии &6.",
                             bf-cr_parts.obj-type,
                             bf-cr_parts.obj-code,
                             bf-cr_parts.artic,
                             bf-cr_parts.prod-type,
                             bf-cr_parts.prod-code,
                             bf-cr_parts.part-code).
  end.
end.
end.
end procedure.

procedure local-chg-vat :
define variable varlog           as   logical            no-undo.
define variable varvat-pc        like ub.doc-line.vat-pc no-undo.
define variable varpurch-list    as   character          no-undo.
define variable varoldvat-pc     like ub.doc-line.vat-pc no-undo.
define variable varchange-price  as   logical            no-undo.
define variable varis-ok         as   logical            no-undo.
define variable varartic         like ub.goods.artic     no-undo.
define variable recid-line       as   recid              no-undo.
define variable varcount         as   integer            no-undo.
define variable vartime          as   integer            no-undo.
define variable varoutput-string as   character          no-undo.
define variable varnotes as character no-undo.
define variable varlns-cnt as integer no-undo.
define buffer bf_goods      for ub.goods.
define buffer bf-free_parts for ub.parts.
assign
  vartime = time.
do on error undo, return error return-value :
message "Вы хотите поменять НДС по всем партиям свободной зоны для списка товаров?" skip
        view-as alert-box question button yes-no update varlog.
if varlog <> yes then do:
  return.
end.
run str/chg-vat.w (output varoldvat-pc,
               output varvat-pc,
               output varpurch-list,
               output varchange-price,
               output varis-ok)     no-error.
if error-status :error then do:
  if return-value <> "" then do:
    message "Ошибка при установке процента НДС." skip
            return-value skip
    view-as alert-box error.
    return error.
  end.
end.
if varis-ok <> yes then do:
  return error.
end.
run str/chs-gds.w
  ( input parparentproc,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    input "":u,
    input t-doc.status_,
    input "Строка накладной № " + t-doc.doc-code,
    input ?, /*режим вызова справочника товаров*/
    input ?,
    input ?,
    input v-cntxt-host-code-obj,
    input parext-doc-type,
    input-output varartic,
    output varnotes).

if varnotes = '' then return.
varlns-cnt = 1.
do while varlns-cnt <= num-entries (varnotes) on error undo, return error return-value :
gds:
do transaction on error undo, leave :
  find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
  varlns-cnt = varlns-cnt + 1.
  find first bf_doc-line where bf_doc-line.doc-code  = t-doc.doc-code     and
                               bf_doc-line.artic     = bf_goods.artic     and
                               bf_doc-line.prod-type = bf_goods.prod-type and
                               bf_doc-line.prod-code = bf_goods.prod-code no-error.
  if available bf_doc-line then do:
    message "Товар " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code " " bf_goods.gds-name " уже есть в данной накладной." skip
            "Хотите отредактировать его?" view-as alert-box question buttons yes-no update varlog.
    if not varlog then do:
      undo, leave gds.
    end.
  end.
  else do:
    { str/chkgdsd.i recid(t-doc) recid(bf_goods) no-error }
    if error-status :error then do:
      put stream str-err unformatted return-value.
      undo, leave gds.
    end.
    find first bf-free_parts where bf-free_parts.host-code     = t-doc.host-code       and
                                   bf-free_parts.supp-type     = t-doc.cli-type        and
                                   bf-free_parts.supp-code     = t-doc.cli-code        and
                                   bf-free_parts.status_       = no                    and
                                   bf-free_parts.obj-type      = t-doc.obj-type        and
                                   bf-free_parts.obj-code      = t-doc.obj-code        and
                                   bf-free_parts.rsrv-free     = yes                   and
                                   bf-free_parts.out-code      = {&free-code}          and
                                   bf-free_parts.prod-type     = bf_goods.prod-type    and
                                   bf-free_parts.prod-code     = bf_goods.prod-code    and
                                   bf-free_parts.artic         = bf_goods.artic        and
                                   bf-free_parts.contract-code = t-doc.contract-code   and
                                   lookup(string(bf-free_parts.purch-code), varpurch-list) > 0 no-lock no-error.
    if not available bf-free_parts then do:
      assign
        varlog-err = yes.
      put stream str-err unformatted
              "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name "."
              "Объект: " t-doc.obj-type " " t-doc.obj-code skip
              "Поставщик " t-doc.cli-type " " t-doc.cli-code " " t-doc.cli-name skip
              "Нет товара от поставщика по заданым типам приобретения в свободной зоне на объекте." skip
              "Пропускаем." skip.
      undo, leave gds.
    end.
    run add-doc-inv-line in this-procedure ( input recid( bf_goods ), output recid-line ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при добавлении товара " skip
        bf_goods.artic skip
        bf_goods.prod-type skip
        bf_goods.prod-code skip
        " в документ."
        return-value skip
        trim(error-status :get-message(1))
        view-as alert-box error.
      undo, leave gds.
    end.
    find first bf_doc-line where recid( bf_doc-line ) = recid-line.
  end.
  assign
    bf_doc-line.prt-OK = ?.
  run local-recalc in this-procedure ( input "old":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim( error-status :get-message( 1 ) )
    view-as alert-box error.
    undo, leave gds.
  end.
  assign
    varcount = varcount + 1.
  run waitfram-join in this-procedure (substitute("Коррекция НДС в партиях свободной зоны. Обрабатываем товар: &1 &2 &3 &4.", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name),
                                       substitute("Всего обработано товаров: &1.", varcount),
                                       substitute("Время: &1.", string(TIME - vartime, "hh:mm:ss")),
                                       output varoutput-string).
  run waitfram-show in this-procedure (varoutput-string).
  find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
  run update-line in this-procedure (   input "chg_vat":u
                                      , input recid( bf_doc-line )
                                      , input bf_sysconf.cash-pay
                                      , input varoldvat-pc
                                      , input varvat-pc
                                      , input varpurch-list
                                      , input varchange-price
                                      )  no-error.
  if error-status :error then do:
    if return-value <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара " skip
        bf_doc-line.artic skip
        bf_doc-line.prod-type skip
        bf_doc-line.prod-code skip
        return-value skip
        trim(error-status :get-message(1))
        view-as alert-box error.
    end.
    undo, leave gds.
  end.
  if available bf_doc-line then do:
    run local-recalc in this-procedure ( input "update":U,
                                         input recid( bf_doc-line ) ) no-error.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
      undo, leave gds.
    end.
  end.
end.
end.
run waitfram-hide in this-procedure.
end.
end procedure.

procedure notes-tr:
define variable notes as character no-undo.
assign
  notes = t-doc.PS.

run gbl/d-prompt.w (
    'title=Примечание\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + (if pardoc-mode = {&lookup} then 'readonly=yes\' else '':U)
  , input-output notes).
if pardoc-mode <> {&lookup} then do:
  if return-value = 'false':u
  then do:
    return .
  end.
  if t-doc.PS <> notes then do:
    do transaction on error undo, return error return-value :
      find t-doc where recid( t-doc ) = pardoc-rec exclusive-lock.
      assign
        t-doc.PS = notes.
    end.
  end.
end.

end procedure.

procedure proc-exit:
parnext-prev = ?.
if pardoc-mode = {&update} or pardoc-mode = {&add-def} then do:
  if not can-find (first doc-line where doc-line.doc-code = t-doc.doc-code no-lock) then do:
    varlog = yes.
    message "В документе нет строк, поэтому он удаляется." view-as alert-box
      question buttons OK-Cancel update varlog.
    if varlog then do:
      delete t-doc.
      assign pardoc-rec = ?.
      return.
    end.
    else return error.
  end.
  assign frame {&frame-name} t-doc.wrkr t-doc.agnt t-doc.boss .   /* эти поля только выводятся на экран в триггерах */
end.
end procedure.

procedure st-exch-rate:
  define output parameter parexch-code     like ub.trn-doc.exch-code   no-undo.
  define output parameter parexch-rate     like ub.trn-doc.exch-rate   no-undo.
  define output parameter parexch-scale    like ub.trn-doc.exch-scale  no-undo.
  define output parameter parcli-base-rate like ub.parts.cli-base-rate no-undo.
  define output parameter parvat-type      like ub.parts.vat-type      no-undo.
  define output parameter parslt-type      like ub.parts.slt-type      no-undo.

  define variable varcurr-abbr as character no-undo.
  define buffer bf_contract for ub.contract.

  do
  on error undo, return error return-value
  :
    find first tt-chs-parts.
    assign
      parcli-base-rate = tt-chs-parts.cli-base-rate
      parexch-code     = tt-chs-parts.exch-code
      parvat-type      = tt-chs-parts.vat-type
      parslt-type      = tt-chs-parts.slt-type .
    for each tt-chs-parts on error undo, return error return-value :
      if t-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code     and
                                    bf_contract.contract-code = t-doc.contract-code no-lock.
        if tt-chs-parts.exch-code <> bf_contract.curr-code then do:
          message "Критическая ошибка." skip
                  "Договору " bf_contract.contract-prn-code " задан в валюте с кодом " bf_contract.curr-code " ." skip
                  "Выбрана партия из свободной зоны: ПН " tt-chs-parts.in-code " Код партии " tt-chs-parts.part-code " Товар " tt-chs-parts.artic tt-chs-parts.prod-type tt-chs-parts.prod-code " в валюте с кодом " tt-chs-parts.exch-code " ."
          view-as alert-box error.
          return error.
        end.
      end.
      else do:
        if tt-chs-parts.exch-code <> parexch-code then do:
          assign
            parexch-code = ?.
        end.
      end.
      if tt-chs-parts.vat-type =  {&without-vat} and
        tt-chs-parts.vat-pc   <> 0              then do:
        message "Критическая ошибка в партии: " skip
                "Объект: " tt-chs-parts.obj-type " " tt-chs-parts.obj-code " " skip
                "Товар: " tt-chs-parts.artic " " tt-chs-parts.prod-type " " tt-chs-parts.prod-code skip
                "ПН: " tt-chs-parts.in-code skip
                "Код партии: " tt-chs-parts.part-code skip
                "Тип НДС в партии имеет тип " tt-chs-parts.vat-type " , а процент НДС в партии установлен " tt-chs-parts.vat-pc " ." skip
        view-as alert-box error.
        return error.
      end.
      if tt-chs-parts.slt-type =  {&without-slt} and
        tt-chs-parts.slt-pc   <> 0              then do:
        message "Критическая ошибка в партии: " skip
                "Объект: " tt-chs-parts.obj-type " " tt-chs-parts.obj-code " " skip
                "Товар: " tt-chs-parts.artic " " tt-chs-parts.prod-type " " tt-chs-parts.prod-code skip
                "ПН: " tt-chs-parts.in-code skip
                "Код партии: " tt-chs-parts.part-code skip
                "Тип НП в партии имеет тип " tt-chs-parts.slt-type " , а процент НП в партии установлен " tt-chs-parts.slt-pc " ." skip
        view-as alert-box error.
        return error.
      end.
      if tt-chs-parts.cli-base-rate <> parcli-base-rate then do:
        assign
          parcli-base-rate = 1.
      end.
    end.
    assign
      parvat-type = ?
      parslt-type = ?.
    if parcli-base-rate = 1 then do:
      for each tt-chs-parts on error undo, return error return-value :
        assign
          tt-chs-parts.price-cli     = tt-chs-parts.price-cli / tt-chs-parts.cli-base-rate
          tt-chs-parts.cli-base-rate = 1
        .
      end.
    end.

    if parexch-code = ? then do:
      /*Пересчитываем все партии в р_ублях*/
      for each tt-chs-parts on error undo, return error return-value :
        assign
          tt-chs-parts.exch-code = 1
          tt-chs-parts.price-cli = tt-chs-parts.price-rubl * tt-chs-parts.cli-base-rate
        .
      end.
      assign
        parexch-code = 1.
    end.
    if parvat-type = ? then do:
      for each tt-chs-parts where tt-chs-parts.vat-type <> {&inc-vat} on error undo, return error return-value :
        for each tt-clcparts on error undo, return error return-value :
          delete tt-clcparts.
        end.
        for each tt-allsum on error undo, return error return-value :
          delete tt-allsum.
        end.
        create tt-clcparts.
        buffer-copy tt-chs-parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure
            (input recid( tt-clcparts ),
            input no,
            input no,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input "":u,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0).
        find first tt-allsum where tt-allsum.sum-type = {&sum-general}.

        assign
          tt-chs-parts.vat-type  = {&inc-vat}
          tt-chs-parts.price-cli = tt-chs-parts.price-cli + tt-allsum.vat-cli-acc
        .
      end.
      assign
        parvat-type = {&inc-vat}.
    end.
    if parslt-type = ? then do:
      for each tt-chs-parts where tt-chs-parts.slt-type <> {&inc-slt} on error undo, return error return-value :
        for each tt-clcparts on error undo, return error return-value :
          delete tt-clcparts.
        end.
        for each tt-allsum on error undo, return error return-value :
          delete tt-allsum.
        end.
        create tt-clcparts.
        buffer-copy tt-chs-parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure
            (input recid( tt-clcparts ),
            input no,
            input no,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input "":u,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0).
        find first tt-allsum where tt-allsum.sum-type = {&sum-general}.

        assign
          tt-chs-parts.slt-type  = {&inc-slt}
          tt-chs-parts.price-cli = tt-chs-parts.price-cli + tt-allsum.slt-cli-acc
        .
      end.
      assign
        parslt-type = {&inc-slt}.
    end.
    if t-doc.contract-code = 0 then do:
      if parexch-code <> 0 then do:
        { gbl/exchrate.i parexch-code t-doc.exch-date parexch-rate parexch-scale varcurr-abbr }
      end.
      else do:
        assign
          parexch-rate  = 1
          parexch-scale = 1
        .
      end.
    end.
    else do:
      assign
        parexch-rate  = t-doc.exch-rate
        parexch-scale = t-doc.exch-scale
      .
    end.
  end.
end procedure.

procedure proc-history :

  define variable loc-ref-list as character no-undo.
  define variable loc-doc-save as recid     no-undo.
  define variable loc-mode     as character no-undo.
  define variable loc#stat     as character no-undo.
  define variable loc#type     as character no-undo.
  define variable loc#internal as logical   no-undo.

  do
  on error undo, return error return-value
  :
    if not available t-doc then do:
      message "Неправильный выбор документа." view-as alert-box.
      return error.
    end.
    assign
      pardoc-rec = recid( t-doc )
    .

/*    assign */
/*      list-mode  = 'doc':U */
/*    .*/

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_c-documents_all':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      true
      varlog
    }

    if varlog <> yes then do: return no-apply. end.
    run str/calldocs.w ( input  parparentproc,
                     input  loc-mode,
                     input  loc#stat,
                     input  loc#type,
                     input  ?,
                     input  loc#internal,
                     input  "":U,
                     input  t-doc.ext-doc-type,
                     input  ?,
                     input  recid(t-doc),
                     input t-doc.obj-type,
                     input t-doc.obj-code,
                     output loc-ref-list ).
    apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  end. /* do */
end procedure. /* proc-history */

procedure check-reason :
  define variable j_rsn-code like ub.trn-reason.reason-code no-undo.

  assign j_rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = j_rsn-code no-error.
  if not available ub.trn-reason then do:
    if j_rsn-code <> ? and j_rsn-code <> 0 then do:
      message "Неверно указано основание (причина) создания документа." view-as alert-box error.
    end.
    assign  rsn-name = "".
    display rsn-name with frame {&FRAME-NAME}.
    if j_rsn-code = ? or j_rsn-code = 0 then do:
      assign t-doc.reason-code = 0.
      return.
    end.
    else do:
      return error.
    end.
  end.
  assign  rsn-name = ub.trn-reason.reason-name.
  display rsn-name with frame {&FRAME-NAME}.
  assign  frame {&FRAME-NAME} t-doc.reason-code.
end procedure. /* check-reason */

procedure select-reason :
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.

  assign j-rsn-code = ( input frame {&FRAME-NAME} t-doc.reason-code ).
  run str/trn-reas.w ( input ParParentProc, input {&choose}, input-output j-rsn-code ).
  find first ub.trn-reason no-lock where ub.trn-reason.reason-code = j-rsn-code no-error.
  if available ub.trn-reason then do:
    assign  rsn-name          = ub.trn-reason.reason-name
            t-doc.reason-code = ub.trn-reason.reason-code.
    display t-doc.reason-code rsn-name with frame {&FRAME-NAME}.
  end.
end procedure. /* select-reason */
/*
procedure proc-sht:
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj',t-doc.obj-type, t-doc.obj-code, '':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.
end procedure.

procedure proc-shift-num :
  define buffer bf_shift-obj   for ub.shift-obj.
  if input frame {&frame-name} t-doc.shift-date <> ? then do:
    find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                  bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                  bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                  bf_shift-obj.shift-num  = input frame {&frame-name} t-doc.shift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
              " Дата " input frame {&frame-name} t-doc.shift-date " Порядок смены " input frame {&frame-name} t-doc.shift-num " ."
      view-as alert-box error.
      display t-doc.shift-num with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do:
        return error.
      end.
    end.
    else do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.
end procedure.

procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.

  if input frame {&frame-name} t-doc.shift-date <> ? then do:

    for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                 bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                 bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                 bf_shift-obj.shift-name = input frame {&frame-name} t-doc.shift-name no-lock on error undo, return error return-value :
      assign
        varfind-shift = varfind-shift + 1
        varshift-date = bf_shift-obj.shift-date
        varshift-num  = bf_shift-obj.shift-num.
    end.

    if varfind-shift = 0 or varfind-shift > 1 then do:
      if varfind-shift = 0 then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
        view-as alert-box error.
      end.
      else do:
        message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
        view-as alert-box error.
      end.
      display t-doc.shift-name with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do: return error. end.
    end.
    else do:
      assign frame {&frame-name}
        t-doc.shift-name.
      assign
        t-doc.shift-date = varshift-date
        t-doc.shift-num  = varshift-num.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date t-doc.fact-time = (24 * 60 * 60). display t-doc.fact-date with frame {&frame-name}. end.
    end.
  end.
end procedure.
*/