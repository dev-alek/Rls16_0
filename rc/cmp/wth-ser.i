/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица масок МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/15/07
Author: Polina Gridchina
Creation date: 08/15/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then
def {3} temp-table {1} no-undo like ub.wth-ser
        field del as logical
        field rid as recid
    .
&endif

/* $Workfile$ e n d */