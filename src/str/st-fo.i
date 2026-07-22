/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проставление признака генерации ФО в складских документах в библиотеке libtfarh

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name libtfarh_st-fo
{&run_proc_libtfarh}
(input  {1}  /*pardoc-code*/
) {2}.
/* $Workfile$ e n d */