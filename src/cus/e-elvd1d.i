/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные таблицы для отчета по покупкам постоянных клиентов (с дисконтными картами)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/24/07
Author: Bakhtadze Natalya
Creation date: 07/24/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table dcards  no-undo
field cli-type      like ub.chk-doc.cli-type
field cli-code      like ub.chk-doc.cli-code
field cli-name      like ub.clients.obj-name
field sum           as decimal
index pi
IS unique PRIMARY
cli-type cli-code
index pname cli-name
.

/* $Workfile$ e n d */