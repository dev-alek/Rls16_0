/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Врем таблица для хранения списка атрибутов товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/21/03
Author: Bakhtadze Natalya
Creation date: 06/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then
def {3} temp-table {1} no-undo like ub.gds-obj-attr
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index gds-code-i is primary gds-code obj-type obj-code attr-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
&endif

/* $Workfile$ e n d */