/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Врвменная таблица для ДНЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/09
Author: Bakhtadze Natalya
Creation date: 03/24/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{2}" = "def" &then

define {3} temp-table {1} no-undo like ub.price-doc-forming
field to-del     as logical
field order-num  as integer
index pi  is primary unique plt-id plt-db-num pdf-id pdf-db
index oi order-num
.
&endif
/* $Workfile$ e n d */
