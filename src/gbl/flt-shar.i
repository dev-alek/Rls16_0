/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Затычка для фильтров

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable flt-rec as recid no-undo.
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc ( output g#report-num ).


/* $Workfile$ e n d */