/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение переменных для разбора записи goods

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define temp-table locb-bar-code     no-undo like ub.bar-code.
define temp-table locb-prod-bc      no-undo like ub.prod-bc.
define temp-table locb-tax-rate-gds      no-undo like ub.tax-rate-gds.
/* $Workfile$ e n d */