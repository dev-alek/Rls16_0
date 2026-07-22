/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Внутренние temp-table для использования в библиотеке атрибутов объектов TH thbjattr.i и attr-lib.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/14/07
Author: Bakhtadze Natalya
Creation date: 01/14/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(thbj-def_i) = 0 &then

&glob thbj-def_i

define temp-table thbjattr{1}_thbj-attr no-undo like ub.thbj-attr.

&endif

/* $Workfile$ e n d */