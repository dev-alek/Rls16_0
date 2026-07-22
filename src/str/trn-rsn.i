/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Устанавливает (если есть) код основания (причины) создания документа в trn-doc

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Булгаков Андрей Николаевич
Дата создания: 10/26/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name lib-trn3_trn-rsn
{&run_proc_lib-trn3} ( input {1} ) /* doc-code */ {2} .


/* $Workfile$   E n d */