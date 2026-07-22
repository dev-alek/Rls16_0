/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения временных таблиц для приема истории изменения сверок

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/19/07
Author: Dmitry Ukhanov
Creation date: 10/19/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table locb-c-rvs-line      no-undo like ub.c-rvs-line.
define temp-table locb-c-rvs-line-pump no-undo like ub.c-rvs-line-pump.
define temp-table locbr-c-doc-attr     no-undo like ub.c-doc-attr.
/*define temp-table locbr-c-rvs-line-attr   no-undo like ub.c-rvs-line-attr.*/