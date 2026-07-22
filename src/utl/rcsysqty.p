block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcsysqty.p $
$Archive: utl/rcsysqty.p $

Пересчет system-cli-qnty в сверке

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/
{ cmp/str-glbl.i }
define input parameter parrvs-code like ub.rvs-doc.rvs-code no-undo.
define buffer bf_rvs-doc  for ub.rvs-doc.
define buffer bf_rvs-line for ub.rvs-line.
define buffer bf_goods    for ub.goods.
define buffer bf-prev_doc-line for ub.doc-line.
define buffer bf-prev_inv-line for ub.inv-line.
define temp-table tt-goods no-undo like ub.goods
field total-qnty-l as decimal.
find first bf_rvs-doc where bf_rvs-doc.rvs-code = parrvs-code exclusive-lock.
for each bf_rvs-line where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code no-lock,
  first bf_goods where bf_goods.gds-code = bf_rvs-line.gds-code no-lock :
  find first tt-goods where tt-goods.gds-code = bf_rvs-line.gds-code no-error.
  if not available tt-goods then do:
    create tt-goods.
    assign
      tt-goods.artic     = bf_goods.artic
      tt-goods.prod-type = bf_goods.prod-type
      tt-goods.prod-code = bf_goods.prod-code
      tt-goods.gds-code  = bf_goods.gds-code
    .
  end.
  assign
    tt-goods.total-qnty-l = tt-goods.total-qnty-l + bf_rvs-line.system-qnty.
end.
for each bf_rvs-line where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code exclusive-lock,
  first bf_goods where bf_goods.gds-code = bf_rvs-line.gds-code no-lock :
  find first tt-goods where tt-goods.gds-code = bf_rvs-line.gds-code.
  find last bf-prev_doc-line where bf-prev_doc-line.obj-type   = bf_rvs-line.obj-type and
                                   bf-prev_doc-line.obj-code   = bf_rvs-line.obj-code and
                                   bf-prev_doc-line.prod-type  = bf_goods.prod-type   and
                                   bf-prev_doc-line.prod-code  = bf_goods.prod-code   and
                                   bf-prev_doc-line.artic      = bf_goods.artic       and
                                   bf-prev_doc-line.status_    = {&fact}              and
                                   bf-prev_doc-line.fact-order < bf_rvs-doc.fact-order use-index fact-order no-lock no-error.
  if available bf-prev_doc-line then do:
    find first bf-prev_inv-line where bf-prev_inv-line.doc-code  = bf-prev_doc-line.doc-code  and
                                      bf-prev_inv-line.artic     = bf-prev_doc-line.artic     and
                                      bf-prev_inv-line.prod-type = bf-prev_doc-line.prod-type and
                                      bf-prev_inv-line.prod-code = bf-prev_doc-line.prod-code no-lock no-error.
    if available bf-prev_inv-line then do:
      assign
        bf_rvs-line.system-cli-qnty = bf-prev_inv-line.after-cli-qnty * bf_rvs-line.system-qnty / tt-goods.total-qnty-l.
    end.
  end.
end.
message "Расчет закончен" view-as alert-box.