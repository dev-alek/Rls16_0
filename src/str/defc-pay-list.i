/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по типам кассовых платежей

Автор: Рубан Дмитрий Андреевич
Дата создания: 16/10/20202
Author: Ruban Dmitriy
Creation date: 16/10/20202

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE cash-pay-list no-undo
FIELD cdpay-code as integer
FIELD curr-code as integer
index pi IS PRIMARY unique cdpay-code curr-code
.

/* $Workfile$ e n d */