/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Переменные для вызов фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

    &if "{1}" <> "vars-only" &then
&glob bef-flt-undo-value undo
&glob flt-undo-value     '{&bef-flt-undo-value}':U
    &endif
    &if "{1}" <> "no-vars"   &then
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
    &endif

/* $Workfile$   E n d */