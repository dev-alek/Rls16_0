/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение врем таблиц используемых для компенсации в отчете о продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE TEMP-TABLE temp-pl NO-UNDO
FIELD pl-code like ub.bar-code.b-code
FIELD IS-OUT as integer
FIELD Doc-qnty like ub.doc-prts.doc-qnty
FIELD fact-qnty like ub.doc-prts.fact-qnty
field new-fact-qnty like ub.doc-pl.fact-qnty
INDEX pi is UNIQUE PRIMARY is-out
                           pl-code
index qnty doc-qnty
.



DEFINE TEMP-TABLE temp-prts NO-UNDO
FIELD b-code like ub.bar-code.b-code
FIELD IS-OUT as integer
FIELD Doc-qnty like ub.doc-prts.doc-qnty
FIELD fact-qnty like ub.doc-prts.fact-qnty
field new-fact-qnty like ub.doc-prts.fact-qnty
FIELD RC as character
FIELD twounit as logical
FIELD compensed as logical
INDEX pi is UNIQUE PRIMARY is-out
                           b-code
                           rc
index qnty compensed
           doc-qnty
.

/* $Workfile$ e n d */