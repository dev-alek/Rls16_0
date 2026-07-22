/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение temp-table для групп товаров в почасовых отчетах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} temp-table full-grp no-undo
&if "{2}" = "obj-code" &then
    field obj-code like ub.clients.obj-code
&endif
    field grp-code like ub.gds-grp.node-code
    field full-name like ub.goods.grp-name
    field other-code as integer
    INDEX i1 full-name ASCENDING
    INDEX i2
&if "{2}" = "obj-code" &then
    obj-code
&endif
    grp-code other-code
      .

/* $Workfile$ e n d */