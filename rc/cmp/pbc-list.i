/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

врем таблица для хранения списка доп бар-кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then
def {3} shared temp-table {1} no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
&endif

/* $Workfile$ e n d */