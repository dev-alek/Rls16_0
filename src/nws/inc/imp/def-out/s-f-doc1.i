/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/24/06
Author: Michael Kochetkov
Creation date: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

define temp-table locb-c-schet-fact-line no-undo like ub.c-schet-fact-line.