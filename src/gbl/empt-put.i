/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Очистка временных файлов мягких фильтров

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

output to value(string(g#report-num) + ".whr") /* "where.flp" */.
put.
output close.
output to value(string(g#report-num) + ".srt"). /*'sort.flp'*/.
put.
output close.

/* $Workfile$ e n d */