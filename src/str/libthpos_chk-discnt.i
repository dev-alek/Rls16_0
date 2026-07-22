/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 08/06/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table {1} no-undo like ub.chk-discnt before-table {2}
field delta-discnt  as decimal help {&dr-flddf_dline_delta-discnt}
field nonunique     as character help {&dr-flddf_dline_nonunique}
field discnt-role as character help {&dr-flddf_dline_discnt-role}
field charkey as character help {&dr-flddf_dline_charkey}
field intended as logical help {&dr-flddf_dline_intended}
field not-found as logical help {&dr-flddf_dline_not-found}
field src-price-netto as decimal
INDEX pi is unique primary
doc-code
record-type
line-num
discnt-id
object-line-num
index dcard
d-card
record-type
INDEX discnt-type
line-type
discnt-type
record-type
index icharkey_one
discnt-role
rule-num
charkey
.

/* $Workfile$ e n d */