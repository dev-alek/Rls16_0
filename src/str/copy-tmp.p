block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: copy-tmp.p $
$Archive: str/copy-tmp.p $

Добавление в строку накладной количества по строке и признаку методом копирования.

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич 30 Nov 1999


*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-rec as recid no-undo .
define input parameter p-gds-rec as recid no-undo .
define input parameter parb-c  like ub.bar-code.b-code no-undo.
define input parameter parqnty as decimal           no-undo.

define variable vss-revision    as character no-undo init "$revision: 12 $":u .
define variable vss-author      as character no-undo init "$author: suslov $":u .
define variable vss-date        as character no-undo init "$date: 6.03.02 10:33 $":u .
define variable vss-workfile    as character no-undo init "$workfile: copy-tmp.p $":u .
define variable vss-archive     as character no-undo init "$archive: /ver12_0/str/copy-tmp.p $":u .
define variable vss-description as character no-undo init "Добавление в строку накладной количества по строке и признаку методом копирования.".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i }
{ str/tt-tax.i new }
{ str/lib-trn.i    }
{ str/cpprclig.i   }
{ gbl/waitfram.i }
define buffer buf_goods for ub.goods  .
define buffer buf_doc-line for ub.doc-line  .
define shared buffer t-doc for ub.trn-doc.
define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line
field cst-code like ub.trn-doc.cst-code
field part-code   like ub.parts.part-code
.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts no-undo like ub.parts.

define buffer d-l-b for ub.doc-line.
define buffer bf-trn-doc for ub.trn-doc.

define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable varprice-base               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable v-cash-pay                  like ub.sysconf.cash-pay    no-undo.

find t-doc where recid(t-doc) = p-doc-rec.

create tt-trn-doc.
buffer-copy t-doc except status_ flag_ to tt-trn-doc.
/*Чтобы не производилась корректировка запроса при копировании*/
assign tt-trn-doc.status_ = "temp":u.
find buf_goods where recid(buf_goods) = p-gds-rec.
find buf_doc-line where buf_doc-line.doc-code  = t-doc.doc-code  and
                   buf_doc-line.artic     = buf_goods.artic     and
                   buf_doc-line.prod-type = buf_goods.prod-type and
                   buf_doc-line.prod-code = buf_goods.prod-code no-error.
create tt-doc-line.
if not available buf_doc-line then do:
    { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
    find ub.sysconf where ub.sysconf.host-code = v-host-code no-lock.
    v-cash-pay = ub.sysconf.cash-pay.
    { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
    { str/st-sltpc.i
      recid(buf_goods)
      recid(t-doc)
      v-cash-pay
      v-slt-pc
      no-error
    }
    if error-status:error then return error return-value.
    assign
      tt-doc-line.doc-code        =    t-doc.doc-code
      tt-doc-line.status_         =    t-doc.status_
      tt-doc-line.artic           =    buf_goods.artic
      tt-doc-line.prod-code       =    buf_goods.prod-code
      tt-doc-line.prod-type       =    buf_goods.prod-type
      tt-doc-line.obj-code        =    t-doc.obj-code
      tt-doc-line.obj-type        =    t-doc.obj-type
      tt-doc-line.prt-root        =    buf_goods.prt-root
      tt-doc-line.line-num        =    next-value(s-line-num, {&db-name_schema})
      tt-doc-line.unit-cli        =    buf_goods.unit-cli
      tt-doc-line.cli-base-rate   =    buf_goods.cli-base-rate.
    /*Установим цены из cli-gds*/
    run cpprclig in this-procedure   (
      input        t-doc.doc-code             ,
      input        t-doc.cli-code             ,
      input        t-doc.cli-type             ,
      input        t-doc.host-code            ,
      input        t-doc.base-rate            ,
      input        t-doc.base-scale           ,
      input        t-doc.exch-rate            ,
      input        t-doc.exch-scale           ,
      input        t-doc.vat-type             ,
      input        t-doc.slt-type             ,
      input        buf_goods.artic                ,
      input        buf_goods.prod-type            ,
      input        buf_goods.prod-code            ,
      input        yes                        ,
      input        buf_goods.cli-base-rate        ,
      input        tt-doc-line.transport-rubl ,
      input        tt-doc-line.other-rubl     ,
      output       tt-doc-line.price-cli               ,
      output       tt-doc-line.price-base              ,
      output       tt-doc-line.price-rubl              ,
      input-output tt-doc-line.vat-pc                  ,
      input-output tt-doc-line.slt-pc                  ,
      input-output tt-doc-line.road-tax                ,
      input-output tt-doc-line.excise                  ) no-error.
    if tt-doc-line.vat-pc = ? then do:
      assign
        tt-doc-line.vat-pc = v-vat-pc.
    end.
    if tt-doc-line.slt-pc = ? then do:
      assign
        tt-doc-line.slt-pc = v-slt-pc.
    end.
    if can-do( {&inquiry}, t-doc.status_ ) and ( not t-doc.flag_ ) then do:
       find first ub.goods no-lock where recid(ub.goods)  = recid(buf_goods) .
       { str/stprqr.i tt-doc-line. }
    end.
end.
else do:
   buffer-copy buf_doc-line except cli-qnty doc-qnty fact-qnty to tt-doc-line.
end.
find first ub.units where ub.units.unit-name = buf_goods.unit-base no-lock.
assign
  tt-doc-line.cli-qnty        =    if not t-doc.flag_ then parqnty / tt-doc-line.cli-base-rate else 0
  tt-doc-line.doc-qnty        =    if not t-doc.flag_ then parqnty else 0
  tt-doc-line.fact-qnty       =    parqnty.
find ub.bar-code where ub.bar-code.b-code  = parb-c no-lock.
create tt-gds-dtl.
assign
        tt-gds-dtl.doc-code      = t-doc.doc-code
        tt-gds-dtl.artic         = buf_goods.artic
        tt-gds-dtl.prod-code     = buf_goods.prod-code
        tt-gds-dtl.prod-type     = buf_goods.prod-type
        tt-gds-dtl.prt-code      = ub.bar-code.node-code
        tt-gds-dtl.obj-code      = t-doc.obj-code
        tt-gds-dtl.obj-type      = t-doc.obj-type
        tt-gds-dtl.doc-qnty      = if not t-doc.flag_ then parqnty else 0
        tt-gds-dtl.fact-qnty     = parqnty.

{ str/copy-in.i
  parparentproc
  recid(t-doc)
  tt-trn-doc
  tt-doc-line
  tt-doc-line-attr
  tt-gds-dtl
  tt-parts
  yes
  yes
  no
  yes
  this-procedure
  no-error }

if error-status:error then do:
   message
     vss-workfile vss-revision vss-description skip
     "Не удалось добавить товар" skip
     return-value skip
     trim(error-status :get-message(1))
     trim(error-status :get-message(2))
     trim(error-status :get-message(3))
     trim(error-status :get-message(4))
     trim(error-status :get-message(5)) skip
     view-as alert-box error.
   undo, return error .
end.