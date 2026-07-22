block-level on error undo, throw.
/*

$Revision: a1ec81b583b9, 1957, rls $
$Author: SSlivenko $
$Date: 2019/07/26 08:40:52 $
$Workfile: gas-autosl.p $
$Archive: str/gas-autosl.p $

Создание приходного документа по документу продажи газа (ТГУ)

Автор: Кирюхин Сергей
Дата создания: 10/09/13
Author: SKiryxin
Creation date: 10/09/13

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-log-handle as handle no-undo.
define input parameter log-file-name as character no-undo.
define input parameter p-auto as integer no-undo.
define input parameter p-inkas-code as character no-undo.
define input parameter v-curr-r-b as character no-undo.
define input parameter p-cli-type as character no-undo. /* из shattr */
define input parameter p-cli-code as integer no-undo. /* из shattr */
define output parameter p-doc-code as character no-undo.
define output parameter p-root-node as character no-undo.
/* документ продажи */
define parameter buffer buf-sale_trn-doc for ub.trn-doc.
/* линия продажи */
define parameter buffer buf-sale_doc-line for ub.doc-line.
/* создарнный документ прихода */
define parameter buffer buf-new_trn-doc for ub.trn-doc.

define variable vss-revision as character no-undo init "$Revision: a1ec81b583b9, 1957, rls $":U .
define variable vss-author as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date as character no-undo init "$Date: 2019/07/26 08:40:52 $":U .
define variable vss-workfile as character no-undo init "$Workfile: gas-autosl.p $":U .
define variable vss-archive as character no-undo init "$Archive: str/gas-autosl.p $":U .
define variable vss-description as character no-undo init "Создание приходного документа техпролива по документу продажи газа (ТГУ)".
{cmp/vssrevis.i}

/* Inclides */
{cmp/trg-def.i}
{str/lib-trn.i}
{gbl/getsect.i def }
{str/doc-code.i}
{trg/partscr.i}
{str/trdcalib.i}
{cmp/gds-list.i gds-list def "new shared"}


/* Local variables */
define variable v-vat-type as character no-undo.
define variable v-vat-pc as decimal no-undo.
define variable v-slt-type as character no-undo.
define variable v-slt-pc as decimal no-undo.
define variable v-doc-pl-rowid as rowid no-undo.
define variable varchg-inv as logical no-undo.
define variable v-cntxt-rsrv-time as integer no-undo.
define variable v-cntxt-load-time as integer no-undo.
define variable v-cntxt-holidays as character no-undo.
define variable v-wrkr    as integer no-undo .
define variable v-agnt    as integer no-undo .
define variable v-boss    as integer no-undo .
/* Buffers */
define buffer buf_clients for ub.clients.
define buffer buf-spis_trn-doc for ub.trn-doc.
define buffer buf-spis_doc-line for ub.doc-line.
define buffer buf-new_doc-line for ub.doc-line.
define buffer buf_parts for ub.parts.
define buffer buf_goods for ub.goods.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf-new_doc-pl for ub.doc-pl.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_sale-gds-dtl for ub.gds-dtl.
define buffer buf_spis-gds-dtl for ub.gds-dtl.
define buffer buf-new_sale-gds-dtl for ub.gds-dtl.

/*-----------------------------------------------------------------------------------------------------*/

/* Получим код для новой накладной */
run doc-code in this-procedure (input "chip",
                                input buf-sale_trn-doc.obj-type,
                                input buf-sale_trn-doc.obj-code,
                                input buf-sale_trn-doc.doc-code,
                                output p-doc-code) no-error.

/* Создадим шапку нового документа */

find first buf_clients where buf_clients.obj-type = p-cli-type
                         and buf_clients.obj-code = p-cli-code no-lock.

/* Отсюда возьмём суммы */
find first buf_sale-gds-dtl where buf_sale-gds-dtl.doc-code = buf-sale_doc-line.doc-code
                              and buf_sale-gds-dtl.artic = buf-sale_doc-line.artic
                              and buf_sale-gds-dtl.prod-code = buf-sale_doc-line.prod-code
                              and buf_sale-gds-dtl.prod-type = buf-sale_doc-line.prod-type no-lock.

{str/crtrndoc.i
 ?
 ?
 buf-sale_trn-doc.base-rate
 buf-sale_trn-doc.base-scale
 buf_clients.obj-code
 buf_clients.obj-type
 buf_clients.obj-name
 buf-sale_trn-doc.cr-db-num
 g#userid
 "''"
 p-doc-code
 buf-sale_trn-doc.doc-date
 {&income}
 buf-sale_trn-doc.flag
 buf-sale_trn-doc.host-code
 false
 buf-sale_trn-doc.obj-code
 buf-sale_trn-doc.obj-type
 false
 buf-sale_trn-doc.pay-code
 '"ПН для продажи природного газа"'
 false
 {&without-SLT}
 {&wayb}
 "{&inc-VAT}"
 {&TDEDT_Pri_Vnesh}
 {&bef-repayment-code}
 no-error}

/* Встанем на созданный документ */
find first buf-new_trn-doc where buf-new_trn-doc.doc-code = p-doc-code exclusive-lock.

/* пишем поля */
assign
buf-new_trn-doc.out-code = buf-sale_trn-doc.doc-code
buf-new_trn-doc.fact-date  = buf-sale_trn-doc.fact-date
buf-new_trn-doc.shift-date = buf-sale_trn-doc.shift-date
buf-new_trn-doc.shift-num  = buf-sale_trn-doc.shift-num
buf-new_trn-doc.shift-name = buf-sale_trn-doc.shift-name
buf-new_trn-doc.base-rate = buf-sale_trn-doc.base-rate
buf-new_trn-doc.base-scale = buf-sale_trn-doc.base-scale
buf-new_trn-doc.exch-scale = buf-sale_trn-doc.exch-scale
buf-new_trn-doc.exch-rate = buf-sale_trn-doc.exch-rate
buf-new_trn-doc.pay-code = buf-sale_trn-doc.pay-code
buf-new_trn-doc.tot-lines = 1
buf-new_trn-doc.tot-doc = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-fact = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-rubl = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-sale = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-cli = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty
buf-new_trn-doc.tot-calc = buf_sale-gds-dtl.price-base * buf_sale-gds-dtl.fact-qnty.

/* Создадим линию накладной */
{str/crdoclin.i
 buf-new_trn-doc.doc-code
 buf-sale_doc-line.artic
 buf-sale_doc-line.prod-type
 buf-sale_doc-line.prod-code
 buf-new_trn-doc.obj-type
 buf-new_trn-doc.obj-code
 "''"
 buf-new_trn-doc.ext-doc-type
 buf-sale_doc-line.prt-root
 buf-sale_doc-line.vat-pc
 buf-sale_doc-line.slt-pc
 buf-sale_doc-line.cons-vat-pc
 no-error}

/* Встанем на созданную линию */
find first buf-new_doc-line where buf-new_doc-line.doc-code = buf-new_trn-doc.doc-code  exclusive-lock.

/* Определим товар */
find first buf_goods where buf_goods.artic = buf-new_doc-line.artic
                       and buf_goods.prod-type = buf-new_doc-line.prod-type
                       and buf_goods.prod-code = buf-new_doc-line.prod-code no-lock.

/* И место */
find first buf_pl-gds where buf_pl-gds.obj-type = buf-new_trn-doc.obj-type
                        and buf_pl-gds.obj-code = buf-new_trn-doc.obj-code
                        and buf_pl-gds.gds-code = buf_goods.gds-code
                        and buf_pl-gds.status_ = {&current-status} no-lock.



/* Добавим всё нужное в линию */
assign
buf-new_doc-line.fact-density = buf-sale_doc-line.fact-density
buf-new_doc-line.cli-qnty = buf-sale_doc-line.fact-qnty * buf-sale_doc-line.fact-density
buf-new_doc-line.fact-qnty = buf-sale_doc-line.fact-qnty
buf-new_doc-line.doc-qnty = buf-sale_doc-line.fact-qnty
buf-new_doc-line.price-rubl = buf_sale-gds-dtl.price-rubl
buf-new_doc-line.price-base = buf_sale-gds-dtl.price-base
buf-new_doc-line.price-cli = buf_sale-gds-dtl.price-base / buf-sale_doc-line.fact-density
buf-new_doc-line.unit-cli = buf_goods.unit-cli
buf-new_doc-line.cli-base-rate = 1 / buf-sale_doc-line.fact-density
buf-new_doc-line.doc-density = buf-sale_doc-line.doc-density.

for each buf-spis_trn-doc no-lock where buf-spis_trn-doc.out-code = buf-sale_trn-doc.doc-code
                                    and buf-spis_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} :

  find first buf-spis_doc-line exclusive-lock where buf-spis_doc-line.doc-code = buf-spis_trn-doc.doc-code
                                         and buf-spis_doc-line.artic = buf-sale_doc-line.artic
                                         and buf-spis_doc-line.prod-type = buf-sale_doc-line.prod-type
                                         and buf-spis_doc-line.prod-code = buf-sale_doc-line.prod-code
                                         and rowid(buf-spis_doc-line) <> rowid(buf-sale_doc-line)
                                         no-error .
  if available buf-spis_doc-line
  then do :
    assign
      buf-new_doc-line.cli-qnty = buf-new_doc-line.cli-qnty + buf-spis_doc-line.fact-qnty * buf-spis_doc-line.fact-density
      buf-new_doc-line.fact-qnty = buf-new_doc-line.fact-qnty + buf-spis_doc-line.fact-qnty
      buf-new_doc-line.doc-qnty = buf-new_doc-line.doc-qnty + buf-spis_doc-line.fact-qnty
    .
    assign
      buf-new_trn-doc.tot-cli = buf-new_trn-doc.tot-cli + buf_sale-gds-dtl.price-base * buf-spis_doc-line.fact-qnty
    .
  end.
end.    

{str/crdocpl.i
 buf-new_trn-doc.doc-code
 buf_goods.gds-code
 buf_pl-gds.pl-code
 buf-new_trn-doc.obj-type
 buf-new_trn-doc.obj-code
 v-doc-pl-rowid
 no-error}

find first buf-new_doc-pl where rowid(buf-new_doc-pl) = v-doc-pl-rowid exclusive-lock.
assign
buf-new_doc-pl.doc-qnty = buf-new_doc-line.doc-qnty
buf-new_doc-pl.fact-qnty = buf-new_doc-line.fact-qnty
buf-new_doc-pl.cli-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.cli-doc-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.cli-fact-qnty = buf-new_doc-line.cli-qnty
buf-new_doc-pl.out-code = buf-new_doc-line.doc-code.

{gbl/rootnode.i
 buf-new_doc-line.artic
 buf-new_doc-line.prod-type
 buf-new_doc-line.prod-code
 p-root-node}

{str/crgdsdtl.i
 buf-new_trn-doc.obj-code
 buf-new_trn-doc.obj-type
 buf-new_trn-doc.doc-code
 buf-new_doc-line.artic
 buf-new_doc-line.prod-code
 buf-new_doc-line.prod-type
 p-root-node
 false}

find first buf-new_sale-gds-dtl where buf-new_sale-gds-dtl.doc-code = p-doc-code exclusive-lock.

assign
buf-new_sale-gds-dtl.price-base = buf-new_doc-line.price-base
buf-new_sale-gds-dtl.price-rubl = buf-new_doc-line.price-rubl
buf-new_sale-gds-dtl.doc-qnty = buf-new_doc-line.doc-qnty
buf-new_sale-gds-dtl.fact-qnty = buf-new_doc-line.fact-qnty.

{str/saledoc.i}

run saledoc-create in this-procedure (
    input p-inkas-code,
    input buf-sale_trn-doc.host-code,
    input buf-sale_trn-doc.obj-type,
    input buf-sale_trn-doc.obj-code,
    input {&sale-add-nat-gas},
    input {&gds-goods},
    input no,
    input '':U,
    input '':U,
    input 0,
    buffer buf-new_trn-doc) no-error.

find first buf_sysconf where buf_sysconf.host-code = buf-new_trn-doc.host-code no-lock.

assign
v-cntxt-rsrv-time = buf_sysconf.rsrv-time
v-cntxt-load-time = buf_sysconf.load-time
v-cntxt-holidays = buf_sysconf.holidays.

run partscr_get-default-values in this-procedure (buffer buf-new_doc-line,
                                                  output v-vat-type,
                                                  output v-vat-pc,
                                                  output v-slt-type,
                                                  output v-slt-pc).
run partscr in this-procedure
      (input  parparentproc,
       input  buf-new_trn-doc.cr-db-num,
       input  g#userid,
       input  {trg/partsprm.i "supp-type" "buf-new_trn-doc."},
       input  {trg/partsprm.i "supp-code" "buf-new_trn-doc."},
       input  '':U,
       input  '':U,
       input  '':U,
       input  '':U,
       input  buf-new_doc-line.price-base,
       input  buf-new_doc-line.price-rubl,
       input  v-vat-type,
       input  v-vat-pc,
       input  v-slt-type,
       input  v-slt-pc,
       input  buf-new_doc-line.fact-qnty,
       input  "prompt=disable-create",
       input  buf-new_doc-line.cli-qnty,
       input  ?,
       input  ?,
       input  buf_pl-gds.pl-code,
       buffer buf-new_doc-line,
       buffer buf_parts) no-error.

{str/calc-in.i
 parparentproc
 recid(buf-new_trn-doc)
 this-procedure
 no-error}
 
buf-new_trn-doc.tot-calc = buf-new_trn-doc.tot-cli .

{ str/tdat-wrt.i                                    
   buf-new_trn-doc.doc-code
   {&trdcattr-is-auto-trn}
   "yes" 
no-error}

{ str/tdat-wrt.i                                    
   buf-new_trn-doc.doc-code
   {&trdcattr-is-fuel}
   "yes" 
no-error}

{ gbl/getsect.i run buf-new_trn-doc.obj-type buf-new_trn-doc.obj-code {&attr-autosale} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-autosale_wrkr} then assign v-wrkr = thbjattr_thbj-attr.property-value-integer .
  if thbjattr_thbj-attr.prop-code = {&attr-autosale_agnt} then assign v-agnt = thbjattr_thbj-attr.property-value-integer .
  if thbjattr_thbj-attr.prop-code = {&attr-autosale_boss} then assign v-boss = thbjattr_thbj-attr.property-value-integer .
end. 

assign
  buf-new_trn-doc.wrkr  = v-wrkr
  buf-new_trn-doc.agnt  = v-agnt
  buf-new_trn-doc.boss  = v-boss
.
 
run str/trn-stat.p (
    input parparentproc,
    input this-procedure,
    input {&close-fact} ,
    input buf-new_trn-doc.doc-code,
    input false,
    input g#db-num,
    input false,
    input v-cntxt-rsrv-time,
    input v-cntxt-load-time,
    input v-cntxt-holidays,
    input false,
    output varchg-inv,
    output table gds-list) no-error.
if error-status:error then  message error-status:get-message(1) skip return-value view-as alert-box warning.
