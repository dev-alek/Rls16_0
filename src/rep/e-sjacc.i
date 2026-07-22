/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Журнал продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/05
Author: Bakhtadze Natalya
Creation date: 12/03/05


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty  (SUB-TOTAL BY ( {1}  ))
    sj-adv.qnty-2 (SUB-TOTAL BY ( {1}  ))
    sj-adv.qnty-3 (SUB-TOTAL BY ( {1}  ))
    sj-adv.brutto-sum  (SUB-TOTAL BY (  {1}  ))
    sj-adv.discnt-sum  (SUB-TOTAL BY ( {1}  ))
    sj-adv.netto-sum  (SUB-TOTAL BY (  {1}  ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY (  {1}  ))
    sj-adv.netto-sum-r  (SUB-TOTAL BY (  {1}  ) )
    sj-adv.num-lines ( SUB-TOTAL BY (  {1}  ))
    sj-adv.num-docs (SUB-TOTAL BY (  {1}  ))
&if "{2}" = "-t" &then
    sj-adv.qnty  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.qnty-2 (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.qnty-3 (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.brutto-sum  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.discnt-sum  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.netto-sum  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY ( sj-goods.b-code ) )
    sj-adv.netto-sum-r  (SUB-TOTAL BY ( sj-goods.b-code ) )
&endif
    sj-adv.qnty (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.num-lines ( SUB-TOTAL BY sj-goods.saleman-chr )
    sj-adv.num-docs ( SUB-TOTAL BY sj-goods.saleman-chr )
    .

/* $Workfile$ e n d */