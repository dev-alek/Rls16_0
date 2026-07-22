/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение temp-table для формированяи автоматических документов по чекам МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE temp-cre-doc No-UNDO
FIELD chk-type like ub.chk-doc.chk-type
FIELD inter_ like ub.wth-doc.inter_
FIELD exter_ like ub.wth-doc.exter_
FIELD doc-type like ub.wth-doc.doc-type
FIELD ext-doc-type like ub.wth-doc.ext-doc-type
FIELD cli-type like ub.wth-doc.cli-type
FIELD cli-code like ub.wth-doc.cli-code
FIELD out-w-p-code like ub.wth-place.w-p-code
FIELD doc-date like ub.wth-doc.doc-date
FIELD fact-date like ub.wth-doc.fact-date
FIELD shift-date like ub.wth-doc.shift-date
FIELD shift-num like ub.wth-doc.shift-num
FIELD shift-name like ub.wth-doc.shift-name
index pi is unique primary
chk-type
.

&if "{2}" = "temp-cash-doc" &then

DEFINE TEMP-TABLE temp-cash-doc No-UNDO
FIELD chk-type like ub.chk-doc.chk-type
FIELD chk-doc-code like ub.chk-doc.doc-code
FIELD inter_ like ub.wth-doc.inter_
FIELD exter_ like ub.wth-doc.exter_
FIELD doc-type like ub.wth-doc.doc-type
FIELD ext-doc-type like ub.wth-doc.ext-doc-type
FIELD cli-type like ub.wth-doc.cli-type
FIELD cli-code like ub.wth-doc.cli-code
FIELD w-p-code like ub.wth-place.w-p-code
FIELD out-w-p-code like ub.wth-place.w-p-code
FIELD pay-desk like ub.chk-doc.pay-desk
FIELD cashier like ub.chk-doc.cashier
FIELD doc-code like ub.wth-doc.doc-code
FIELD shift-date like ub.wth-doc.shift-date
FIELD shift-num like ub.wth-doc.shift-num
field shift-name like ub.wth-doc.shift-name
FIELD doc-date like ub.wth-doc.doc-date
FIELD fact-date like ub.wth-doc.fact-date
index pi is unique primary
chk-type
pay-desk
cashier
doc-code
.

&endif

/* $Workfile$ e n d */