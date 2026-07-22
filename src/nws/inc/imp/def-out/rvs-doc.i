/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения временных таблиц для приема сверок

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/15/07
Author: Dmitry Ukhanov
Creation date: 02/15/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/04/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table locb-rvs-line      no-undo like ub.rvs-line.
define temp-table locbr-rvs-line-attr no-undo like ub.rvs-line-attr.
define temp-table locb-rvs-line-pump no-undo like ub.rvs-line-pump.
define temp-table locbr-doc-attr     no-undo like ub.doc-attr.
define temp-table locbr-doc-line-attr     no-undo like ub.doc-line-attr.
define temp-table locbr-rvs-pump     no-undo like ub.rvs-pump.