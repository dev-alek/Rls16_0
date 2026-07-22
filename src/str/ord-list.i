/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблицы для работы с заказми

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/01/08
Author: Bakhtadze Natalya
Creation date: 10/01/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then

define {3} temp-table {1} no-undo
field host-code  like ub.ord-doc.host-code
field cli-type   like ub.ord-doc.cli-type
field cli-code   like ub.ord-doc.cli-code
field doc-date   like ub.ord-doc.doc-date
field doc-code   like ub.ord-doc.doc-code
field obj-type   like ub.ord-doc.obj-type
field obj-code   like ub.ord-doc.obj-code
field fact-num   like ub.ord-doc.fact-num
field fact-date  like ub.ord-doc.fact-date
field shift-date like ub.ord-doc.shift-date
field shift-num  like ub.ord-doc.shift-num
field shift-name like ub.ord-doc.shift-name
field ord-int1   like ub.ord-doc.ord-int1
field cli-out-doc like ub.ord-doc.cli-out-doc
field ship-date  like ub.ord-doc.ship-date
field ship-time  like ub.ord-doc.ship-time
field status_    as character
field trn-doc    as character
field fact-order as decimal
field is-trn-doc as logical
field doc-type   like ub.ord-doc.doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field ps         as character
field dm         as integer /*метод доставки*/
field charkey_one as character
index xpk is primary unique doc-code doc-type trn-doc
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
.

&endif
/* $Workfile$ */