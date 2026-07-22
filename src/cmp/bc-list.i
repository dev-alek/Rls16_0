/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

врем таблица для хранения списка бар-кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then
def {3} shared temp-table {1} no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
&endif

/* $Workfile$ e n d */