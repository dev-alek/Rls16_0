/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы по промоакциям

Автор: Шкляр Елена
Дата создания: 16/10/20202
Author: Shklyar Elena
Creation date: 16/10/20202

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE PromoAction-list no-undo
FIELD ID as int64
FIELD db-num as integer
FIELD del_ as logical   
index pi IS PRIMARY unique ID db-num
.

/* $Workfile$ e n d */