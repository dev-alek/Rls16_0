/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контейнер для динамических временных таблиц для разбара XML, сслыки на которые сами хранятся в статической временной таблице temp-xml-tables

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/13/07
Author: Bakhtadze Natalya
Creation date: 03/13/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(tempcxml_i) = 0 &then

&glob tempcxml_i


define variable tempcxml_v-num_ as integer no-undo .

define {1} temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.

define {1} temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
&endif

/* $Workfile$ e n d */