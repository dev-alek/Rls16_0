/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием масок МЦ в новостях

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/15/07
Author: Polina Gridchina
Creation date: 08/15/07


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

buffer-copy  wt-wth-ser to tb-wth-ser.
   run fill-wth-ser-list in p-imp-handle ( buffer tb-wth-ser).
/* $Workfile$ e n d */